"""
***** project: PRJ2023_MIPS-ShapeDistortion (Experiment 02)

    Mohammad Shams <m.shams.ahmar@gmail.com>
    Jan 2024

----------
Task Procedure:
    Either: A FG stimulus oscillates for 90 deg
    Or: A FE stimulus oscillates for half of its width
    A probe flashes three times, every trial at one of the three possible
    locations.
    Subjects respond by clicking on the perceived location of the flash.

----------
TWO stimuli:
    Flash-Grab stimulus
    Frame-Effect stimulus

TWO post-flash dirctions:
        -1: leftward post-flash motion
        +1: rightward post-flash motion

Three probe locations

Four motion cycles (the first cycle without flash)

-----------
To do:

"""

import os
import random
import warnings
import numpy as np
import pandas as pd
from psychopy import event, visual, core
from lib import stim_flow_control as sfc


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

subID = 'ms-test'
nrep = 15
nstm = 2  # number of stimuli (FG, FE)
nloc = 3  # number of probe locations
ndir = 2  # number of direction of motions (flash-left, flash-right)
ntrs = nrep * nstm * nloc * ndir
nblocks = 9

slow_factor = 1  # setup = 1, mac = 2

if subID == 'test':
    full_screen = False
else:
    full_screen = True

# ----------------------------------------------------------------------------
# /// CONFIGURATION ///

# file names and directory paths
date = sfc.get_date()
time = sfc.get_time()
output_file_name = f"exp02_{subID}_{date}_{time}.json"
save_path = os.path.join("..", "data", "cyc05", output_file_name)
image_path = os.path.join("image", "cyc05")

# --------------------------------
# /// set stimulus parameters

# monitor and window
refresh_rate = 60  # [frames/s]
mon = sfc.config_mon_dell()
win = sfc.config_win(mon=mon, fullscr=full_screen)
sfc.test_refresh_rate(win, refresh_rate)

# fixation mark
fixdot_radius = .25  # [dva]
FIX_X = 6.5  # [dva]
FIX_Y = 3  # [dva]

# FG
FG_size = 24.4  # [dva]
FG_x = 0  # [dva]
FG_y = 0  # [dva]
FG_pos1 = 0  # [degrees of arc]
FG_pos2 = 90  # [degrees of arc]

# FE
FE_size = 24.4  # [dva]
FE_x = 0  # [dva]
FE_y = 0  # [dva]
FE_pos1 = -2.45  # [dva]
FE_pos2 = 2.45  # [dva]

# probe
probe1_radius = .35
probe1_color = [72, -128, -128]  # [-128 to 128] to match RGB of the T in Exp1
probe2_radius = .15  # [dva]
probe2_color = 'white'
probe_y = 4.85  # [dva]
probe_duration_frames = 3  # [frames]
probe_nflashes = 5

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
stm_array = np.repeat(['FG', 'FE'], 90)
assert (stm_array.size == ntrs)
probe_x_array = np.tile(np.repeat([-.75, 0, .75], 30), 2)
assert (probe_x_array.size == ntrs)
dir_array = np.tile(np.repeat([-1, 1], 15), 6)
assert (dir_array.size == ntrs)

# randomize the order of each condition array
ind_shuffle = np.arange(ntrs)
np.random.shuffle(ind_shuffle)
stm_array = stm_array[ind_shuffle]
probe_x_array = probe_x_array[ind_shuffle]
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
# FE
FE_directory = os.path.join(image_path, 'FE.png')
FE = visual.ImageStim(win,
                      image=FE_directory,
                      size=FE_size)
# probe
probe1 = visual.Circle(win,
                       radius=probe1_radius,
                       fillColor=probe1_color)
probe2 = visual.Circle(win,
                       radius=probe2_radius,
                       fillColor=probe2_color)
# fixation mark
fixdot = visual.Circle(win,
                       radius=fixdot_radius,
                       pos=(FIX_X, FIX_Y),
                       fillColor='black')

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
    mouse.setVisible(False)
    bar_h_x = np.nan

    # --------------------------------
    # /// set up the stimulus behavior in current trial

    # locate the fixation dot ahead of the post-flash motion
    fixdot_y_offset = np.random.choice(np.arange(-1, 1, .1))
    fixdot.pos = (FIX_X, FIX_Y + fixdot_y_offset)

    # --------------------------------
    # create motion arrays

    if stm_array[itrial] == 'FG':
        motion_pos1 = FG_pos1
        motion_pos2 = dir_array[itrial] * FG_pos2
    elif stm_array[itrial] == 'FE':
        motion_pos1 = dir_array[itrial] * FE_pos1
        motion_pos2 = dir_array[itrial] * FE_pos2
    else:
        continue

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
    for igap in range(int(refresh_rate / 2) +
                      random.choice(range(int(refresh_rate / 2)))):
        win.flip()

    # fixation only period
    for igap in range(int(refresh_rate) +
                      random.choice(range(int(refresh_rate / 2)))):
        fixdot.draw()
        win.flip()

    # motion period
    for ioscillation in range(probe_nflashes+1):
        for imotion in motion_array:
            for islow in range(slow_factor):
                if stm_array[itrial] == 'FG':
                    FG.ori = imotion
                    FG.draw()
                elif stm_array[itrial] == 'FE':
                    FE.pos = imotion, FE_y
                    FE.draw()
                else:
                    continue

                if imotion == motion_pos1 and ioscillation > 0:
                    probe1.pos = probe_x_array[itrial], probe_y
                    probe2.pos = probe_x_array[itrial], probe_y
                    probe1.draw()
                    probe2.draw()

                fixdot.draw()
                win.flip()

                # exit loop upon request
                pressed_key = event.getKeys(keyList=['escape'])
                if 'escape' in pressed_key:
                    core.quit()
                    break

    mouse = event.Mouse(visible=True,
                        newPos=[random.choice(range(-3, 3)),
                                random.choice(range(-3, 3))])
    while not mouse.getPressed()[0]:
        fixdot.draw()
        win.flip()
    while mouse.getPressed()[0]:
        pass
    click_loc = mouse.getPos()
    print(f'click location: {click_loc}')

    # --------------------------------
    # /// save

    # create a dictionary of variables to be saved
    trial_dict = {'trial_number': itrial + 1,
                  'stimulus_type': stm_array[itrial],
                  'postflash_direction': dir_array[itrial],
                  'probe_x': probe_x_array[itrial],
                  'probe_y': probe_y,
                  'click_x': round(click_loc[0], 2),
                  'click_y': round(click_loc[1], 2)}

    dfnew = pd.DataFrame(trial_dict, index=[0])

    if itrial > 0:
        df = pd.read_json(save_path)
        dfnew = pd.concat([df, dfnew], ignore_index=True)
    dfnew.to_json(save_path)

    if itrial == ntrs - 1:
        sfc.end_screen(win)

win.close()
