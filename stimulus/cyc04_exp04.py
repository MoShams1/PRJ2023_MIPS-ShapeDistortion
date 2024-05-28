"""
***** project: PRJ2023_MIPS-ShapeDistortion (Experiment 04)

    Mohammad Shams <m.shams.ahmar@gmail.com>
    May 2024

----------
Task Procedure:
    Either: A FG stimulus oscillates for 90 deg
    Or: A FE stimulus oscillates for half of its width
    A T-shaped stimulus flashes at one of the reversals
    Subject adjusts the horizontal component of the "T" to obtain symmetry

----------
TWO fixation positions

Two post-flash dirctions:
        -1: leftward post-flash motion
        +1: rightward post-flash motion

FIVE repetitions per stimulus

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

subID = 'MS'
nrep = 5
nfix = 2  # number of fixation locations
ndir = 2  # number of direction of motions (flash-left, flash-right)
ntrs = nrep * nfix * ndir
nblocks = 1

if subID == 'test':
    full_screen = False
else:
    full_screen = True
# ----------------------------------------------------------------------------
# /// CONFIGURATION ///

# file names and directory paths
date = sfc.get_date()
time = sfc.get_time()
output_file_name = f"exp04_{subID}_{date}_{time}.json"
save_path = os.path.join("..", "data", "cyc04", output_file_name)
image_path = os.path.join("image", "cyc04")

# --------------------------------
# /// set stimulus parameters

# monitor and window
refresh_rate = 60  # [frames/s]
mon = sfc.config_mon_dell()
win = sfc.config_win(mon=mon, fullscr=full_screen)
sfc.test_refresh_rate(win, refresh_rate)

# fixation mark
fixdot_radius = .25  # [dva]
FIX_Y = 3.5  # [dva]

# FG
FG_size = 10  # [dva]
FG_x = 0  # [dva]
FG_y = 0  # [dva]
FG_pos1 = 0  # [degrees of arc]
FG_pos2 = 90  # [degrees of arc]

# probe
bar_size = 2.4  # [dva]
bar_h_y = 4.2  # [dva]
bar_v_x = 0  # [dva]
bar_v_y = 4.2  # [dva]
bar_h_x_limit = .95  # [dva]
probe_duration_frames = 3  # [frames]

# motion
motion_cycle_dur_s = .8
motion_cycle_dur_frames = motion_cycle_dur_s * refresh_rate

# response
mouse_precision_coeff = 10
mouse = event.Mouse(win=win, visible=False)

# turn off Numpy's FutureWarning
warnings.simplefilter(action='ignore', category=FutureWarning)

# ----------------------------------------------------------------------------
# /// CONDITIONS ///

# create an equal number of trials per condition
fix_x_array = np.repeat([-3.5, 3.5], 10)
assert (fix_x_array.size == ntrs)
dir_array = np.tile(np.repeat([-1, 1], 5), 2)
assert (dir_array.size == ntrs)

# randomize the order of each condition array
ind_shuffle = np.arange(ntrs)
np.random.shuffle(ind_shuffle)
fix_x_array = fix_x_array[ind_shuffle]
dir_array = dir_array[ind_shuffle]

# inter-block trials: trials that define the end of a block
pause_array = np.linspace(0, ntrs, nblocks + 1)
pause_array = pause_array[:-1]

# ----------------------------------------------------------------------------
# /// VISUAL OBJECTS ///

# FG
FG_directory = os.path.join(image_path, 'FG.png')
FG = visual.ImageStim(win,
                      image=FG_directory,
                      size=FG_size)
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
                       fillColor='green')

# ----------------------------------------------------------------------------
# /// TRIAL BEGIN ///

for itrial in range(ntrs):

    print('---------------------------')
    print(f'trl: {itrial + 1}')
    print(f'stm: {fix_x_array[itrial]}')
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
    # create motion arrays

    motion_pos1 = FG_pos1
    motion_pos2 = dir_array[itrial] * FG_pos2

    motion_array_base = np.linspace(motion_pos1, motion_pos2,
                                    num=int(motion_cycle_dur_frames / 2) + 2)
    motion_array_rev = np.flip(motion_array_base)
    motion_array = np.concatenate(
        [
            np.repeat(motion_array_base[0], probe_duration_frames),
            motion_array_base[1:-1],
            np.repeat(motion_array_rev[0], probe_duration_frames),
            motion_array_rev[1:-1],
        ]
    )

    # --------------------------------
    # /// run stimulus

    # opening message
    if itrial in pause_array:
        sfc.block_msg(win, np.where(pause_array == itrial)[0][0] + 1, nblocks)

    # gap period
    for igap in range(int(refresh_rate/2) +
                      random.choice(range(int(refresh_rate/2)))):
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

            FG.ori = imotion
            FG.draw()

            if imotion == motion_pos1 and loop_cntr > 1:
                bar_v.draw()
                bar_h.pos = bar_h_x, bar_h_y
                bar_h.draw()

            fixdot.pos = fix_x_array[itrial], FIX_Y
            fixdot.draw()
            win.flip()

            # exit loop upon request
            pressed_key = event.getKeys(keyList=['space', 'escape'])
            if 'escape' in pressed_key:
                core.quit()
            if 'space' in pressed_key:
                loop_flag = False
                break

    print(f'PSE_dva: {np.round(bar_h_x, 2)}')
    print(f'PSE_normalized: {np.round(bar_h_x / bar_h_x_limit, 2)}')

    # --------------------------------
    # /// save

    # create a dictionary of variables to be saved
    trial_dict = {'trial_number': itrial + 1,
                  'stimulus_type': fix_x_array[itrial],
                  'postflash_direction': dir_array[itrial],
                  'pse_dva': np.round(bar_h_x, 2),
                  'pse_normalized': np.round(bar_h_x / bar_h_x_limit, 2),
                  'loop_count': loop_cntr}

    dfnew = pd.DataFrame(trial_dict, index=[0])

    if itrial > 0:
        df = pd.read_json(save_path)
        dfnew = pd.concat([df, dfnew], ignore_index=True)
    dfnew.to_json(save_path)

    if itrial == ntrs - 1:
        sfc.end_screen(win)

# --------------------------------
# /// report
print('===========================')
print(
    f'flash {probe_duration_frames} '
    f'+ motion {len(motion_array_base)-2} '
    f'+ pause {probe_duration_frames} '
    f'+ motion {len(motion_array_base)-2} [frames]'
)
print('===========================')

win.close()
