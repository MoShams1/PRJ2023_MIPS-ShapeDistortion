"""
***** project: MIPS-ShapeDis

    Mo Shams <MShamsCBR@gmail.com>
    Sep 14, 2023


Task Procedure:
    A squared frame moves back and forth for its length
    A T-shaped stimulus flashes at one of the reversal times
    Subject adjusts the horizontal component of the shape to obtain symmetry

There are two direction conditions:
    d > 0: right-flash-left
    d < 0: left-flash-right

There are X contrast conditions:
    c1: contrast 0% + edges
    c2: contrast 5%
    c3: contrast 10%
    c4: contrast 20%
    c5: contrast 40%
    c6: contrast 80%
"""

import os
import random
import warnings
import numpy as np
import pandas as pd
from lib import stim_flow_control as sfc
from psychopy import event, visual, core

# disable Panda's false warning message
pd.options.mode.chained_assignment = None  # default='warn'

# ----------------------------------------------------------------------------

# /// INSERT SESSION'S META DATA ///

subID = "MS01"
N_CNT = 6  # number of contrasts
N_REP = 6  # repetition of each contrast (min = 2; has to be Even)
N_TRIALS = N_CNT * N_REP
full_screen = True  # (True/False)
show_bg_box = False
# ----------------------------------------------------------------------------

# /// CONFIGURE LOAD/SAVE FILES & DIRECTORIES ///

# create file nameTrue
date = sfc.get_date()
time = sfc.get_time()
output_name = f"{subID}_task02_{date}_{time}.json"
# set data directory
save_path = os.path.join("../..", "data", "cyc01", output_name)
# ----------------------------------------------------------------------------

# /// CONFIGURE STIMULUS PARAMETERS AND INPUTS ///

# initialize the display and the keyboard
REF_RATE = 60

# define the flash duration in frames
frame_repeat = 2

# configure the monitor and the stimulus window
mon = sfc.config_mon_dell()
if not full_screen:
    win = visual.Window(monitor=mon,
                        units='deg',
                        pos=[0, 0],
                        size=[1920, 700],
                        color=[0, 0, 0])
else:
    win = visual.Window(monitor=mon,
                        units='deg',
                        pos=[0, 0],
                        fullscr=full_screen,
                        color=[0, 0, 0])

sfc.test_refresh_rate(win, REF_RATE)

# fixation cross
FIX_SIZE = .35
FIX_X = 0
FIX_Y = 0

INSTRUCT_DUR = REF_RATE  # duration of the instruction period [frames]

# ring size [deg]
frame_width = 7
frame_height = 5
RING_POS0_X = FIX_X
RING_POS0_Y = FIX_Y + 4

# motion
motion_cycle_dur = REF_RATE  # [frames]
motion_distance = frame_width / 2

# probe lines [deg]
line_width = 0.3
hline_y = 4.8
hline_size = 2
vline_size = 1
line_color = 'tomato'

# probe background box
box_width = 4
box_height = 1.5
box_color = 'darkgreen'

# mouse position downsample factor
mouse_dsf = 10

# potential gap durations (0.5 to 1 sec)
gap_dur_list = range(int(REF_RATE / 2), int(REF_RATE / 1) + 1, 1)

# define a timer to measure the change-detection reaction time
timer = core.Clock()

# show a message before the block begins
# sfc.block_msg(win, iblock, N_BLOCKS, command_keys)

# initialize mouse
mouse = event.Mouse(win=win, visible=False)

# create an equal number of trials per condition (contrast/direction)
cnt_array = np.repeat([np.arange(1, N_CNT + 1, 1)], N_REP)
dir_array = np.repeat(np.tile([-motion_distance, motion_distance], N_CNT),
                      int(N_REP / 2))
# randomize the order of each condition array
cnd_ind_arr = np.arange(cnt_array.shape[0])
np.random.shuffle(cnd_ind_arr)
cnt_array = cnt_array[cnd_ind_arr]
dir_array = dir_array[cnd_ind_arr]

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

    # create frame
    if cnt_array[itrial] == 1:
        win.color = [0, 0, 0]
        fill_color = win.color
        edge_color = [-1, -1, -1]
        ring = visual.Rect(win=win,
                           size=(frame_width, frame_height),
                           lineWidth=5,
                           fillColor=fill_color,
                           lineColor=edge_color,
                           pos=(RING_POS0_X, RING_POS0_Y))

    if cnt_array[itrial] == 2:
        win.color = [.025, .025, .025]
        fill_color = -win.color
    if cnt_array[itrial] == 3:
        win.color = [.05, .05, .05]
        fill_color = -win.color
    if cnt_array[itrial] == 4:
        win.color = [.1, .1, .1]
        fill_color = -win.color
    if cnt_array[itrial] == 5:
        win.color = [.2, .2, .2]
        fill_color = -win.color
    if cnt_array[itrial] == 6:
        win.color = [.4, .4, .4]
        fill_color = -win.color
    if cnt_array[itrial] > 1:
        ring = visual.Rect(win=win,
                           size=(frame_width, frame_height),
                           lineWidth=10,
                           fillColor=fill_color,
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

    # --------------------------------
    # /// run the stimulus

    hline_x = np.nan

    # add random offset to hline's horizontal onset position
    hline_x_offset = np.random.choice(np.arange(-1, 1, 0.1))

    # gap period
    for igap in range(gap_dur):
        win.flip()

    timer.reset()
    loop_flag = True

    vline = visual.Rect(win,
                        width=line_width,
                        height=vline_size,
                        pos=(0, hline_y - (vline_size / 2)),
                        fillColor=line_color)
    hline = visual.Rect(win,
                        width=hline_size,
                        height=line_width,
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

            if hline_x < -hline_size / 2:
                hline_x = -hline_size / 2
            if hline_x > hline_size / 2:
                hline_x = hline_size / 2

            # draw the ring
            ring.pos = iori, RING_POS0_Y
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

            win.flip()

            # exit loop upon proper response
            pressed_key = event.getKeys(keyList=['space', 'escape'])
            if 'escape' in pressed_key:
                core.quit()
            if 'space' in pressed_key:
                loop_flag = False
                break

    print(f'PSE: {np.round(hline_x, 2)}')

    # --------------------------------

    # /// prepare data for saving

    # create a dictionary of variables to be saved
    trial_dict = {'trial_num': itrial + 1,
                  'contrast': cnt_array[itrial],
                  'direction': dir_array[itrial],
                  'pse_x': [np.round(hline_x, 2)]}

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
