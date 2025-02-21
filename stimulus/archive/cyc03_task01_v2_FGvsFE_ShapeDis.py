"""
***** project: MIPS-ShapeDis

    Mohammad Shams <m.shams.ahmar@gmail.com>
    Oct 2023


Task Procedure:

    In half of the trials:
    A 4-sector ring rotates back and forth in 90 deg
    A T-shaped stimulus flashes at one of the reversal times
    Subject adjusts the horizontal component of the shape to obtain symmetry

    In the other half of the trials:
    A squared frame moves back and forth for its length
    A T-shaped stimulus flashes at one of the reversal times
    Subject adjusts the horizontal component of the shape to obtain symmetry

There are two direction conditions:
    d = -1: leftward post-flash motion
    d = +1: rightward post-flash motion

There are three stimulus types:
    FG: classic flash-grab
    GF: straightend flash-grab
    FE: classic frame effect

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
nrep = 10
nstm = 5  # number of stimuli (FG, BB, WB, FE1, FE2)
ndir = 2  # number of direction of motions (flash-left, flash-right)
ntrs = nrep * nstm * ndir
nblocks = 4

if subID == 'test':
    full_screen = False
else:
    full_screen = True
# ----------------------------------------------------------------------------
# /// CONFIGURATION ///

# create file nameTrue
date = sfc.get_date()
time = sfc.get_time()
output_name = f"{subID}_task01_v2_{date}_{time}.json"
# set data directory
save_path = os.path.join("../..", "data", "cyc03", output_name)

# --------------------------------
# /// set stimulus parameters

# initialize the display and the keyboard
REF_RATE = 60

# define the flash duration in frames
frame_repeat = 2

# configure the monitor and the stimulus window
mon = sfc.config_mon_dell()
win = sfc.config_win(mon=mon, fullscr=full_screen)
sfc.test_refresh_rate(win, REF_RATE)

# fixation cross
fixdot_radius = .15
FIX_X = 0
FIX_Y = 0

INSTRUCT_DUR = REF_RATE  # duration of the instruction period [frames]

# ring parameters [dva]
ring_size_factor = 7
IMAGE_SIZE = np.array([ring_size_factor, ring_size_factor])
ring_x = FIX_X
ring_y = FIX_Y

# frame parameters [dva]
frame_width = ring_size_factor * np.pi / 4  # to match ring's sector length
# ring
frame_height = .85
frame_y = FIX_Y + 3
frame_color = 'black'
bg_width = frame_width * 4
bg_height = frame_height
bg_color = 'white'

# probe lines [dva]
hline_width = 0.12
hline_y = 3.2
hline_size = .7
vline_width = 0.12
vline_size = .5
line_color = 'black'
norm_factor = (hline_size / 2) - (vline_width / 2)
probe_rep_factor = 1

# probe background box
box_width = 1.6
box_height = .9
box_color = 'limegreen'

motion_cycle_dur = REF_RATE  # [frames]
motion_distance = frame_width / 2

# mouse position downsample factor
mouse_dsf = 20

# potential gap durations (0.5 to 1 sec)
gap_dur_list = range(int(REF_RATE / 2), int(REF_RATE / 1) + 1, 1)

# initialize mouse
mouse = event.Mouse(win=win, visible=False)

# turn off Numpy's FutureWarning
warnings.simplefilter(action='ignore', category=FutureWarning)

# ----------------------------------------------------------------------------
# /// CONDITIONS ///

# create an equal number of trials per condition (contrast/direction)
stm_array = np.repeat(['FG',
                       'BB_leftEdge', 'WB_rightEdge',
                       'FE_leftEdge', 'FE_rightEdge'],
                      ntrs / 5)
assert (stm_array.size == ntrs)
dir_array = np.tile(np.repeat([-1, 1], int(ntrs / 10)), 5)
assert (dir_array.size == ntrs)

# randomize the order of each condition array
ind_shuffle = np.arange(ntrs)
np.random.shuffle(ind_shuffle)
stm_array = stm_array[ind_shuffle]
dir_array = dir_array[ind_shuffle]

# pause trials
pause_array = np.linspace(0, ntrs, nblocks + 1)
pause_array = pause_array[:-1]

# ----------------------------------------------------------------------------
# /// TRIAL BEGINS ///

for itrial in range(ntrs):

    # --------------------------------
    # /// resets

    # reset mouse position
    mouse.setPos((0, 0))

    # reset pse response
    hline_x = np.nan

    # reset loop counter
    loop_cntr = 0

    # --------------------------------
    # /// set up the stimulus behavior in current trial

    # randomly decide on inter-trial interval
    iti = random.choice(gap_dur_list)

    # add random offset to hline's horizontal onset position
    hline_x_offset = np.random.choice(np.arange(-hline_size / 2,
                                                hline_size / 2, 0.1))

    # --------------------------------
    print('---------------------------')
    print(f'trl: {itrial + 1}')
    print(f'stm: {stm_array[itrial]}')
    print(f'dir: {dir_array[itrial]}')

    # --------------------------------
    # /// create visual objects

    # FG
    ring_directory = os.path.join('../image', 'cyc03', 'FG.png')
    ring = visual.ImageStim(win,
                            image=ring_directory,
                            size=IMAGE_SIZE,
                            opacity=1,
                            pos=(ring_x, ring_y))

    # Block (B)
    frame = visual.Rect(win=win,
                        size=(frame_width, frame_height),
                        lineWidth=10, )
    bg = visual.Rect(win=win,
                     size=(bg_width, bg_height),
                     lineWidth=10,
                     pos=(0, frame_y))

    # FE
    frame1 = visual.Rect(win=win,
                         size=(frame_width, frame_height),
                         lineWidth=10,
                         fillColor='black')
    frame2 = visual.Rect(win=win,
                         size=(frame_width - .15, frame_height - .15),
                         lineWidth=10,
                         fillColor='gray')

    # fixation mark
    fixdot1 = visual.Circle(win,
                            radius=fixdot_radius,
                            pos=(FIX_X, FIX_Y),
                            fillColor='black')
    fixdot2 = visual.Circle(win,
                            radius=fixdot_radius * .7,
                            pos=(FIX_X, FIX_Y),
                            fillColor='gray')
    # flashing shape
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

    # --------------------------------
    # /// create motion arrays

    if stm_array[itrial] == 'FG':
        motion_pos1 = 0
        motion_pos2 = dir_array[itrial] * 90
    elif (stm_array[itrial] == 'BB_leftEdge') or \
            (stm_array[itrial] == 'FE_leftEdge'):
        motion_pos1 = frame_width / 2
        motion_pos2 = motion_pos1 + dir_array[itrial] * frame_width
    elif (stm_array[itrial] == 'WB_rightEdge') or \
            (stm_array[itrial] == 'FE_rightEdge'):
        motion_pos1 = -frame_width / 2
        motion_pos2 = motion_pos1 + dir_array[itrial] * frame_width
    else:
        continue

    motion_array_base = np.linspace(motion_pos1, motion_pos2,
                                    num=int(REF_RATE / frame_repeat / 2))
    motion_array_rev = np.flip(motion_array_base)
    motion_array = np.concatenate([motion_array_base[:-1],
                                   np.repeat(motion_array_base[-1],
                                             probe_rep_factor),
                                   motion_array_rev[:-1],
                                   np.repeat(motion_array_rev[-1],
                                             probe_rep_factor)])
    motion_array = np.repeat(motion_array, frame_repeat)

    # --------------------------------
    # /// run the stimulus

    if itrial in pause_array:
        sfc.block_msg(win, np.where(pause_array == itrial)[0][0] + 1, nblocks)

    # gap period
    for igap in range(iti):
        win.flip()

    # motion period
    loop_flag = True
    while loop_flag:
        loop_cntr += 1
        for imotion in motion_array:

            # get mouse x-position
            hline_x = mouse.getPos()[0] / mouse_dsf + hline_x_offset

            # limit horizontal bar's motion range
            if hline_x < -hline_size / 2 + (vline_width / 2):
                hline_x = -hline_size / 2 + (vline_width / 2)
            if hline_x > hline_size / 2 - (vline_width / 2):
                hline_x = hline_size / 2 - (vline_width / 2)

            if stm_array[itrial] == 'FG':
                ring.ori = imotion
                ring.draw()
            elif stm_array[itrial] == 'BB_leftEdge':
                frame.pos = imotion, frame_y
                frame.fillColor = 'black'
                bg.fillColor = 'white'
                bg.draw()
                frame.draw()
            elif stm_array[itrial] == 'WB_rightEdge':
                frame.pos = imotion, frame_y
                frame.fillColor = 'white'
                bg.fillColor = 'black'
                bg.draw()
                frame.draw()
            elif stm_array[itrial] == 'FE_leftEdge' or \
                    stm_array[itrial] == 'FE_rightEdge':
                frame1.pos = imotion, frame_y
                frame2.pos = imotion, frame_y
                frame1.draw()
                frame2.draw()
            else:
                continue

            # draw fixation mark
            fixdot1.draw()
            fixdot2.draw()

            if imotion == motion_pos1 and loop_cntr > 1:
                hline.pos = hline_x, hline_y
                box.draw()
                vline.draw()
                hline.draw()

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
                  'stimulus_type': stm_array[itrial],
                  'postflash_dir': dir_array[itrial],
                  'pse_x': [np.round(hline_x / norm_factor, 2)],
                  'loop_count': loop_cntr}

    # convert to data frame
    dfnew = pd.DataFrame(trial_dict)
    # if not first trial, load the existing data frame and concatenate
    if itrial > 0:
        df = pd.read_json(save_path)
        dfnew = pd.concat([df, dfnew], ignore_index=True)
    # save the dataframe
    dfnew.to_json(save_path)

    if itrial == ntrs - 1:
        sfc.end_screen(win)
# --------------------------------
win.close()
