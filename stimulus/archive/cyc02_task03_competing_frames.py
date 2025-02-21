"""
***** project: MIPS-ShapeDis

    Mo Shams <MShamsCBR@gmail.com>
    Sep 15, 2023


Task Procedure:
    A 4-sector ring rotates back and forth in 90 deg
    A T-shaped stimulus flashes at one of the reversal times
    Subject adjusts the horizontal component of the shape to obtain symmetry

There are two direction conditions (zero deg means top):
    d -90: ccw-cw, flash at -90 deg
    d +90: cw-ccw, flash at +90 deg

There are three contrast conditions:
    c1: b100, w0 (black frame)
    c2: b100, w100 (flash grab)
    c3: b0, w100 (white frame)

"""

import os
import random
import warnings
import numpy as np
import pandas as pd
from lib import stim_flow_control as sfc
from psychopy import event, visual, core


def deg2rad(angle):
    return angle / 360 * 2 * np.pi


def rad2deg(angle):
    return angle / (2 * np.pi) * 360


def pol2cart(rho, phi):
    phi = deg2rad(phi)
    x_cart = rho * np.cos(phi)
    y_cart = rho * np.sin(phi)
    return x_cart, y_cart


def cart2pol(x_cart, y_cart):
    rho = np.sqrt(x_cart ** 2 + y_cart ** 2)
    phi = np.arctan2(y_cart, x_cart)
    phi = rad2deg(phi)
    return rho, phi


# disable Panda's false warning message
pd.options.mode.chained_assignment = None  # default='warn'

# ----------------------------------------------------------------------------

# /// INSERT SESSION'S META DATA ///

subID = 'MS01'
N_CNT = 7  # number of contrasts
N_REP = 4  # repetition of each contrast (min = 2; has to be Even)
N_TRIALS = N_CNT * N_REP
show_bg_box = True
if subID == 'test':
    full_screen = False
else:
    full_screen = True
# ----------------------------------------------------------------------------

# /// CONFIGURE LOAD/SAVE FILES & DIRECTORIES ///

# create file nameTrue
date = sfc.get_date()
time = sfc.get_time()
output_name = f"{subID}_task01_{date}_{time}.json"
# set data directory
save_path = os.path.join("../..", "data", "cyc02", output_name)
# ----------------------------------------------------------------------------

# /// CONFIGURE STIMULUS PARAMETERS AND INPUTS ///

# initialize the display and the keyboard
REF_RATE = 60

# define the flash duration in frames
frame_repeat = 2

# configure the monitor and the stimulus window
mon = sfc.config_mon_dell()
win = sfc.config_win(mon=mon, fullscr=full_screen)
sfc.test_refresh_rate(win, REF_RATE)

# fixation cross
FIX_SIZE = .35
FIX_X = 0
FIX_Y = 0

INSTRUCT_DUR = REF_RATE  # duration of the instruction period [frames]

# ring size [deg]
ring_size_factor = 7
IMAGE_SIZE = np.array([ring_size_factor, ring_size_factor])

RING_POS0_X = FIX_X
RING_POS0_Y = FIX_Y

motion_cycle_dur = REF_RATE  # [frames]

# probe lines [deg]
hline_width = 0.12
hline_y = 3.2
hline_size = .7
vline_width = 0.12
vline_size = .5
line_color = 'black'
norm_factor = (hline_size / 2) - (vline_width / 2)

# probe background box
box_width = 1.6
box_height = .9
box_color = 'limegreen'

# mouse position downsample factor
mouse_dsf = 20

# potential gap durations (0.5 to 1 sec)
gap_dur_list = range(int(REF_RATE / 2), int(REF_RATE / 1) + 1, 1)

# define a timer to measure the change-detection reaction time
timer = core.Clock()

# show a message before the block begins
# sfc.block_msg(win, iblock, N_BLOCKS, command_keys)

# initialize mouse
mouse = event.Mouse(win=win, visible=False)

# create an equal number of trials per condition (contrast/direction)
cnt_array = np.repeat(['empty', 'static', 'bbww', 'bb', 'ww', 'b', 'w'], N_REP)
# cnt_array = np.repeat(['empty', 'static', 'bbww'], N_REP)
dir_array = np.repeat(np.tile([-90, 90], N_CNT), int(N_REP / 2))
# randomize the order of each condition array
ind_shuffle = np.arange(cnt_array.shape[0])
np.random.shuffle(ind_shuffle)
cnt_array = cnt_array[ind_shuffle]
dir_array = dir_array[ind_shuffle]

# turn off Numpy's FutureWarning
warnings.simplefilter(action='ignore', category=FutureWarning)
# ----------------------------------------------------------------------------

# /// TRIAL BEGINS ///

for itrial in range(N_TRIALS):

    # pre-allocate variables
    response_time = [np.nan]

    # --------------------------------
    # /// set up the stimulus behavior in current trial

    # randomly decide on gap duration
    gap_dur = random.choice(gap_dur_list)

    # the annulus orientation, at which the shape flashes
    flash_at_ori = dir_array[itrial]

    # reset mouse position
    mouse.setPos((0, 0))

    # --------------------------------
    # set image properties and load
    ring_directory = os.path.join("../image", f"im_{cnt_array[itrial]}.png")

    # load image
    ring = visual.ImageStim(win,
                            image=ring_directory,
                            size=IMAGE_SIZE,
                            opacity=1,
                            pos=(RING_POS0_X, RING_POS0_Y))

    # --------------------------------
    # create orientation array
    ori_array_base = np.linspace(0, dir_array[itrial],
                                 num=int(REF_RATE / frame_repeat / 2))
    ori_array_rev = np.flip(ori_array_base)
    ori_array = np.concatenate([ori_array_base[:-1],
                                np.repeat(ori_array_base[-1], 3),
                                ori_array_rev[:-1],
                                np.repeat(ori_array_rev[-1], 3)])
    ori_array = np.repeat(ori_array, frame_repeat)

    # flip horizontally (rotate the ring 90 deg) to keep the top color fixed
    # in both direction conditions
    if dir_array[itrial] == 90:
        ori_array += 90
        flash_at_ori += 90

    if cnt_array[itrial] == 'w' and dir_array[itrial] == -90:
        ori_array += 180
        flash_at_ori += 180

    # --------------------------------
    # /// run the stimulus

    hline_x = np.nan

    # add random offset to hline's horizontal onset position
    hline_x_offset = np.random.choice(np.arange(-hline_size / 2,
                                                hline_size / 2, 0.1))

    # gap period
    for igap in range(gap_dur):
        win.flip()

    timer.reset()
    loop_flag = True

    vline = visual.Rect(win,
                        width=vline_width,
                        height=vline_size,
                        pos=(0, hline_y - (vline_size / 2)),
                        fillColor=line_color)
    hline = visual.Rect(win,
                        width=hline_size,
                        height=hline_width,
                        fillColor=line_color)
    box = visual.Rect(win,
                      width=box_width,
                      height=box_height,
                      pos=(0, hline_y - (vline_size / 2) + .1),
                      fillColor=box_color)

    print('---------------------------')
    print(f'trial: {itrial + 1}')
    print(f'contrast: {cnt_array[itrial]}')
    print(f'rotation direction: {dir_array[itrial]}')

    while loop_flag:
        for iori in ori_array:
            # get mouse x-position
            hline_x = mouse.getPos()[0] / mouse_dsf + hline_x_offset

            # print(hline_x, hline_y)

            if hline_x < -hline_size / 2 + (vline_width / 2):
                hline_x = -hline_size / 2 + (vline_width / 2)
            if hline_x > hline_size / 2 - (vline_width / 2):
                hline_x = hline_size / 2 - (vline_width / 2)

            # draw the ring
            if (cnt_array[itrial] == 'static2') or \
                    (cnt_array[itrial] == 'empty'):
                ring.ori = ori_array[0]
                ring.draw()
            else:
                ring.ori = iori
                ring.draw()

            # draw fixation mark
            sfc.draw_fixdot(win=win, size=FIX_SIZE,
                            pos=(FIX_X, FIX_Y))

            if iori == flash_at_ori:
                if show_bg_box:
                    # draw background box
                    box.draw()
                # draw vertical line
                vline.draw()
                # set pos and draw horizontal line
                hline.pos = hline_x, hline_y
                hline.draw()

            # print(f"/// PSE: "
            #       f"{np.round(hline_x / norm_factor, 2)}"
            #       f" ///")
            win.flip()

            # exit loop upon proper response
            pressed_key = event.getKeys(keyList=['space', 'escape'])
            if 'escape' in pressed_key:
                core.quit()
            if 'space' in pressed_key:
                loop_flag = False
                break

    print(f'PSE: {np.round(hline_x / norm_factor, 2)}')

    # --------------------------------

    # /// prepare data for saving

    # create a dictionary of variables to be saved
    trial_dict = {'trial_num': itrial + 1,
                  'contrast': cnt_array[itrial],
                  'direction': dir_array[itrial],
                  'pse_x': [np.round(hline_x / norm_factor, 2)]}

    # convert to data frame
    dfnew = pd.DataFrame(trial_dict)
    # if not first trial, load the existing data frame and concatenate
    if itrial > 0:
        df = pd.read_json(save_path)
        dfnew = pd.concat([df, dfnew], ignore_index=True)
    # save the dataframe
    dfnew.to_json(save_path)
# --------------------------------

win.close()
