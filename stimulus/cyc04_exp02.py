"""
***** project: PRJ2023_MIPS-ShapeDistortion (Experiment 02)

    Mohammad Shams <m.shams.ahmar@gmail.com>
    May 2024

----------
Task Procedure:
    Either: A FG stimulus oscillates for 90 deg
    Or: A FE stimulus oscillates for half of its width
    A probe flashes at five different locations over three oscillations
    Subject adjusts the horizontal component of the "T" to obtain symmetry

----------
TWO stimuli:
    Flash-Grab stimulus
    Frame-Effect stimulus

TWO post-flash dirctions:
        -1: leftward post-flash motion
        +1: rightward post-flash motion

Three probe locations

Five repetitions per stimulus

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

subID = 'MG`'
nrep = 5
nstm = 2  # number of stimuli (FG, FE)
nloc = 3  # number of probe locations
ndir = 2  # number of direction of motions (flash-left, flash-right)
ntrs = nrep * nstm * nloc * ndir
nblocks = 2

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
FIX_X = 0  # [dva]
FIX_Y = 0  # [dva]

# FG
FG_size = 10  # [dva]
FG_x = 0  # [dva]
FG_y = 0  # [dva]
FG_pos1 = 0  # [degrees of arc]
FG_pos2 = 90  # [degrees of arc]

# FE
FE_size = 10  # [dva]
FE_x = 0  # [dva]
FE_y = 0  # [dva]
FE_pos1 = -3.9  # [dva]
FE_pos2 = 3.9  # [dva]

# probe
probe_radius = .25  # [dva]
probe_y = 4.82  # [dva]
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
stm_array = np.repeat(['FG', 'FE'], 30)
assert (stm_array.size == ntrs)
probe_x_array = np.tile(np.repeat([-1.2, 0, 1.2], 10), 2)
assert (probe_x_array.size == ntrs)
dir_array = np.tile(np.repeat([-1, 1], 5), 6)
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
probe = visual.Circle(win,
                      radius=probe_radius,
                      fillColor='red')
# fixation mark
fixdot = visual.Circle(win,
                       radius=fixdot_radius,
                       pos=(FIX_X, FIX_Y),
                       fillColor='green')

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
        sfc.block_msg(win, np.where(pause_array == itrial)[0][0]+1, nblocks)

    for igap in range(int(refresh_rate/2)+1):
        win.flip()

    for ifix in range(int(refresh_rate)):
        fixdot.draw()
        win.flip()

    for igap in range(int(refresh_rate/2) +
                      random.choice(range(int(refresh_rate/2)))):
        win.flip()

    # motion period
    for ioscillation in range(5):
        for imotion in motion_array:

            if stm_array[itrial] == 'FG':
                FG.ori = imotion
                FG.draw()
            elif stm_array[itrial] == 'FE':
                FE.pos = imotion, FE_y
                FE.draw()
            else:
                continue

            if imotion == motion_pos1 and ioscillation > 0:
                probe.pos = probe_x_array[itrial], probe_y
                probe.draw()

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

# --------------------------------
# /// report
print('===========================')
print(
    f'flash {probe_duration_frames} '
    f'+ motion {len(motion_array_base) - 2} '
    f'+ pause {probe_duration_frames} '
    f'+ motion {len(motion_array_base) - 2} [frames]'
)
print('===========================')

win.close()
