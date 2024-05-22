"""
***** project: PRJ2023_MIPS-ShapeDistortion

    Mohammad Shams <m.shams.ahmar@gmail.com>
    May 2024


Task Procedure:

    In half of the trials:
    A 4-sector FG rotates back and forth in 90 deg
    A T-shaped stimulus flashes at one of the reversal times
    Subject adjusts the horizontal component of the shape to obtain symmetry

    In the other half of the trials:
    A squared FE moves back and forth for its length
    A T-shaped stimulus flashes at one of the reversal times
    Subject adjusts the horizontal component of the shape to obtain symmetry

----------
TWO stimuli:
    Flash-Grab stimulus
    FE-Effect stimulus

TEN repetitions per stimulus
    TWO post-flash dirctions:
        d = -1: leftward post-flash motion
        d = +1: rightward post-flash motion
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

subID = 'test'
nrep = 5
nstm = 2  # number of stimuli (FG, FE)
ndir = 2  # number of direction of motions (flash-left, flash-right)
ntrs = nrep * nstm * ndir
nblocks = 1

if subID == 'test':
    full_screen = False
else:
    full_screen = True
# ----------------------------------------------------------------------------
# /// CONFIGURATION ///

# create file name
date = sfc.get_date()
time = sfc.get_time()
output_name = f"exp01_{subID}_{date}_{time}.json"
# set data directory
save_path = os.path.join("..", "data", "cyc04", output_name)
image_path = os.path.join("image", "cyc04")

# --------------------------------
# /// set stimulus parameters

# initialize the display and the keyboard
REF_RATE = 120

# define the flash duration
frame_repeat = 2

# configure the monitor and the stimulus window
# mon = sfc.config_mon_dell()
mon = sfc.config_mon_macair()
# win = sfc.config_win(mon=mon, fullscr=full_screen)
win = visual.Window(monitor=mon,
                    units='deg',
                    size=[1440, 700],
                    pos=[0, 0],
                    color=[0, 0, 0])
sfc.test_refresh_rate(win, REF_RATE)

# fixation mark
fixdot_radius = .25
FIX_X = 0
FIX_Y = 0

# FG parameters [dva]
FG_size = 10
FG_x = FIX_X
FG_y = FIX_Y

# FE parameters [dva]
FE_size = 10
FE_x = FIX_X
FE_y = FIX_Y

# probe lines [dva]
bar_size = 2.4
bar_h_y = FIX_Y + 4.2
bar_v_x = FIX_X
bar_v_y = FIX_Y + 4.2
bar_h_x_limit = bar_size / 2.52
probe_rep_factor = 1

# probe background box
# box_width = 1.6
# box_height = .9
# box_color = 'limegreen'

motion_cycle_dur = REF_RATE
motion_distance = FE_size / 2

mouse_precision_coeff = 20

# initialize mouse
mouse = event.Mouse(win=win, visible=False)

# turn off Numpy's FutureWarning
warnings.simplefilter(action='ignore', category=FutureWarning)

# ----------------------------------------------------------------------------
# /// CONDITIONS ///

# create an equal number of trials per condition
stm_array = np.repeat(['FE', 'FE'], 10)
assert (stm_array.size == ntrs)
dir_array = np.tile(np.repeat([-1, 1], 5), 2)
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
# /// VISUAL OBJECTS ///

# FG
FG_directory = os.path.join(image_path, 'FG.png')
FG = visual.ImageStim(win,
                      image=FG_directory,
                      size=FG_size,
                      pos=(FG_x, FG_y))
# FE
FE_directory = os.path.join(image_path, 'FE.png')
FE = visual.ImageStim(win,
                      image=FE_directory,
                      size=FE_size,
                      pos=(FE_x, FE_y))
# probe
bar_h_directory = os.path.join(image_path, 'bar_h.png')
bar_h = visual.ImageStim(win,
                         image=bar_h_directory,
                         size=bar_size)
bar_v_directory = os.path.join(image_path, 'bar_v.png')
bar_v = visual.ImageStim(win,
                         image=bar_v_directory,
                         size=bar_size,
                         pos=(bar_v_x, bar_v_y))
# fixation mark
fixdot = visual.Circle(win,
                       radius=fixdot_radius,
                       pos=(FIX_X, FIX_Y),
                       fillColor='gray')
# box = visual.Rect(win,
#                   width=box_width,
#                   height=box_height,
#                   pos=(0, hline_y - (vline_size / 2) + .1),
#                   fillColor=box_color)

# ----------------------------------------------------------------------------
# /// TRIAL BEGIN ///

for itrial in range(ntrs):

    print('---------------------------')
    print(f'trl: {itrial + 1}')
    print(f'stm: {stm_array[itrial]}')
    print(f'dir: {dir_array[itrial]}')

    # --------------------------------
    # /// reset variables
    mouse.setPos((0, 0))
    bar_h_x = np.nan
    loop_cntr = 0

    # --------------------------------
    # /// set up the stimulus behavior in current trial

    # add random offset to horizontal bar's onset position
    bar_h_x_offset = np.random.choice(np.arange(-bar_h_x_limit,
                                                bar_h_x_limit,
                                                0.1))

    # --------------------------------
    # /// create motion arrays

    if stm_array[itrial] == 'FG':
        motion_pos1 = 0
        motion_pos2 = dir_array[itrial] * 90
    elif stm_array[itrial] == 'FE':
        motion_pos1 = FE_size / 2
        motion_pos2 = motion_pos1 + dir_array[itrial] * FE_size
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

    # opening message
    if itrial in pause_array:
        sfc.block_msg(win, np.where(pause_array == itrial)[0][0] + 1, nblocks)

    # gap period
    for igap in range(int(REF_RATE / 2), int(REF_RATE) + 1, 1):
        win.flip()

    # motion period
    loop_flag = True
    while loop_flag:
        loop_cntr += 1
        for imotion in motion_array:

            # transfer mouse position to horizontal bar position
            bar_h_x = mouse.getPos()[0] / mouse_precision_coeff + \
                      bar_h_x_offset

            # limit horizontal bar's motion range
            if bar_h_x < -bar_h_x_limit:
                bar_h_x = -bar_h_x_limit
            if bar_h_x > bar_h_x_limit:
                bar_h_x = bar_h_x_limit

            if stm_array[itrial] == 'FG':
                FG.ori = imotion
                FG.draw()
        #         elif stm_array[itrial] == 'FE_leftEdge' or \
        #                 stm_array[itrial] == 'FE_rightEdge':
        #             FE1.pos = imotion, FE_y
        #             FE2.pos = imotion, FE_y
        #             FE1.draw()
        #             FE2.draw()
        #         else:
        #             continue

            fixdot.draw()

            #         if imotion == motion_pos1 and loop_cntr > 1:
            bar_v.draw()
            bar_h.pos = bar_h_x, bar_h_y
            bar_h.draw()

            win.flip()

            # exit loop upon proper response
            pressed_key = event.getKeys(keyList=['space', 'escape'])
            if 'escape' in pressed_key:
                core.quit()
            if 'space' in pressed_key:
                loop_flag = False
                break

# print(f'PSE: {np.round(hline_x / norm_factor, 2)}')
#
# # --------------------------------
# # /// prepare data for saving
#
# # create a dictionary of variables to be saved
# trial_dict = {'trial_num': itrial + 1,
#               'stimulus_type': stm_array[itrial],
#               'postflash_dir': dir_array[itrial],
#               'pse_x': [np.round(hline_x / norm_factor, 2)],
#               'loop_count': loop_cntr}
#
# # convert to data FE
# dfnew = pd.DataFE(trial_dict)
# # if not first trial, load the existing data FE and concatenate
# if itrial > 0:
#     df = pd.read_json(save_path)
#     dfnew = pd.concat([df, dfnew], ignore_index=True)
# # save the dataFE
# dfnew.to_json(save_path)
#
# if itrial == ntrs - 1:
#     sfc.end_screen(win)
# --------------------------------
win.close()
