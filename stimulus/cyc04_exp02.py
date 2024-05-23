"""
***** project: PRJ2023_MIPS-ShapeDistortion

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
    FE-Effect stimulus

TWO post-flash dirctions:
        -1: leftward post-flash motion
        +1: rightward post-flash motion

Five probe locations

Five repetitions per stimulus

"""

import os
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
output_file_name = f"exp01_{subID}_{date}_{time}.json"
save_path = os.path.join("..", "data", "cyc04", output_file_name)
image_path = os.path.join("image", "cyc04")

# --------------------------------
# /// set stimulus parameters

# monitor and window
refresh_rate = 120  # [frames/s]
# mon = sfc.config_mon_dell()
mon = sfc.config_mon_macair()
# win = sfc.config_win(mon=mon, fullscr=full_screen)
win = visual.Window(monitor=mon,
                    units='deg',
                    size=[1440, 700],
                    pos=[0, 0],
                    color=[0, 0, 0])
sfc.test_refresh_rate(win, refresh_rate)

# fixation mark
fixdot_radius = .25  # [dva]
FIX_X = 0
FIX_Y = 0

# FG
FG_size = 10  # [dva]
FG_x = FIX_X
FG_y = FIX_Y

# FE
FE_size = 10  # [dva]
FE_x = FIX_X
FE_y = FIX_Y + .5

# probe
probe_radius = .25  # [dva]
probe_y = FIX_Y + 4.82  # [dva]
probe_duration = 4  # [frames]

# motion
motion_cycle_dur = refresh_rate

# response
mouse_precision_coeff = 20
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
    bar_h_x = np.nan
    loop_cntr = 0

    # --------------------------------
    # /// set up the stimulus behavior in current trial

    # add random offset to horizontal bar's onset position
    # bar_h_x_offset = np.random.choice(np.arange(-bar_h_x_limit,
    #                                             bar_h_x_limit,
    #                                             0.1))

    # --------------------------------
    # /// create motion arrays

    if stm_array[itrial] == 'FG':
        motion_pos1 = 0
        motion_pos2 = dir_array[itrial] * 90
    elif stm_array[itrial] == 'FE':
        motion_pos1 = -dir_array[itrial] * FE_size / 2.55
        motion_pos2 = dir_array[itrial] * FE_size / 2.55
    else:
        continue

    motion_array_base = np.linspace(motion_pos1, motion_pos2,
                                    num=int(refresh_rate / 2))
    motion_array_rev = np.flip(motion_array_base)
    motion_array = np.concatenate(
        [motion_array_base[:-1],
         np.repeat(motion_array_base[-1], probe_duration),
         motion_array_rev[:-1],
         np.repeat(motion_array_rev[-1], probe_duration)])

    # --------------------------------
    # /// run stimulus

    # ----------------
    # TEST
    # for i in range(int(refresh_rate * 2)):
    #     FG.ori = 0
    #     FG.draw()
    #     probe.pos = probe_x_array[0], probe_y
    #     probe.draw()
    #     fixdot.draw()
    #     win.flip()
    # ----------------

    # opening message
    if itrial in pause_array:
        sfc.block_msg(win, np.where(pause_array == itrial)[0][0] + 1, nblocks)

    # gap period
    for igap in range(int(refresh_rate / 2), int(refresh_rate) + 1, 1):
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

            fixdot.draw()
            win.flip()

            # exit loop upon request
            pressed_key = event.getKeys(keyList=['space', 'escape'])
            if 'escape' in pressed_key:
                core.quit()
            if 'space' in pressed_key:
                loop_flag = False
                break

    mouse = event.Mouse(visible=True,
                        newPos=[0, 0])
    while not mouse.getPressed()[0]:
        win.flip()
    while mouse.getPressed()[0]:
        pass
    click_loc = mouse.getPos()
    print(click_loc)

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

    # if itrial > 0:
    #     df = pd.read_json(save_path)
    #     dfnew = pd.concat([df, dfnew], ignore_index=True)
    # dfnew.to_json(save_path)
    #
    # if itrial == ntrs - 1:
    #     sfc.end_screen(win)
    # --------------------------------
win.close()
