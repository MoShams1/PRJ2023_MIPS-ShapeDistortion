"""
***** project: MIPS-ShapeDis

    Mohammad Shams <m.shams.ahmar@gmail.com>
    Oct 2023


Task Procedure:

    In half of the trials:
    A 4-sector ring rotates back and forth in 90 deg

    In the other half of the trials:
    A squared frame moves back and forth for its length

    A probe flashes at every other reversal and subject has to align its
    position vertically to the fixation mark


There are seven phase conditions (flash position relative to sector/fram):
    ph = -90:15:+90
    Notes:
        - when dir>0, negative values are lefward shifts
        - when dir<0, negative values are rightward shifts
        - ph = 0 means flash occurred at the frame/sector edge
        - ph = 90 means flash occurred the middle of frame/sector

There are two direction conditions:
    d = -1: leftward post-flash motion
    d = +1: rightward post-flash motion

There are two motion conditions:
    m: static
    m: dynamic

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
ntrs = 2 * 84
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
output_name = f"{subID}_task02_{date}_{time}.json"
# set data directory
save_path = os.path.join("..", "data", "cyc03", output_name)

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

# fixation mark
fixdot_radius = .15
FIX_X = 0
FIX_Y = 0
refline_width = .05
refline_length = .3

INSTRUCT_DUR = REF_RATE  # duration of the instruction period [frames]

# ring parameters [dva]
ring_size_factor = 7
IMAGE_SIZE = np.array([ring_size_factor, ring_size_factor])
ring_x = FIX_X
ring_y = FIX_Y

# frame parameters [dva]
frame_width = ring_size_factor * np.pi / 4  # to match ring's sector length
frame_height = .85
frame_y = FIX_Y + 3.07
frame_color = 'black'
bg_width = frame_width * 4
bg_height = frame_height
bg_color = 'white'

# probe
probe_radius = 0.2
probe_ecc = 3.07
probe_color = 'red'
probe_rep_factor = 1

motion_cycle_dur = REF_RATE  # [frames]
motion_distance = frame_width / 2

# mouse factor
mouse_fact_FG = 5
mouse_fact_FE = .5

# potential gap durations (0.5 to 1 sec)
gap_dur_list = range(int(REF_RATE / 2), int(REF_RATE / 1) + 1, 1)

# initialize mouse
mouse = event.Mouse(win=win, visible=False)

# turn off Numpy's FutureWarning
warnings.simplefilter(action='ignore', category=FutureWarning)

# ----------------------------------------------------------------------------
# /// CONDITIONS ///

# create an equal number of trials per condition (contrast/direction)
stm_array = np.repeat(['FG', 'FE'], ntrs / 2)
assert (stm_array.size == ntrs)
phs_array = np.tile(np.repeat(np.linspace(-90, 90, 7),
                              int(ntrs / 14)), 2)
assert (phs_array.size == ntrs)
dir_array = np.tile(np.repeat([-1, 1],
                              int(ntrs / 28)), 14)
assert (dir_array.size == ntrs)
dyn_array = np.tile(np.repeat(['static', 'dynamic', 'dynamic'],
                              int(ntrs / 84)), 28)
assert (dyn_array.size == ntrs)

# randomize the order of each condition array
ind_shuffle = np.arange(ntrs)
np.random.shuffle(ind_shuffle)
stm_array = stm_array[ind_shuffle]
phs_array = phs_array[ind_shuffle]
dir_array = dir_array[ind_shuffle]
dyn_array = dyn_array[ind_shuffle]

# pause trials
pause_array = np.linspace(0, ntrs, nblocks + 1)
pause_array = pause_array[:-1]
# --------------------------------
# /// create visual objects

# FG
ring_directory = os.path.join('image', 'cyc03', 'FG.png')
ring = visual.ImageStim(win,
                        image=ring_directory,
                        size=IMAGE_SIZE,
                        opacity=1,
                        pos=(ring_x, ring_y))

# FE
frame = visual.Rect(win=win,
                    size=(frame_width, frame_height),
                    lineWidth=10,
                    fillColor=frame_color)
bg = visual.Rect(win=win,
                 size=(bg_width, bg_height),
                 lineWidth=10,
                 fillColor=bg_color,
                 pos=(0, frame_y))

# fixation mark
fixdot1 = visual.Circle(win,
                        radius=fixdot_radius,
                        pos=(FIX_X, FIX_Y),
                        fillColor='black')
fixdot2 = visual.Circle(win,
                        radius=fixdot_radius * .7,
                        pos=(FIX_X, FIX_Y),
                        fillColor='gray')
refline1 = visual.Rect(win,
                       width=refline_width,
                       height=refline_length,
                       pos=(0, .4),
                       fillColor='black')
refline2 = visual.Rect(win,
                       width=refline_width,
                       height=refline_length,
                       pos=(0, -.4),
                       fillColor='black')

# flashing probe
probe = visual.Circle(win,
                      radius=probe_radius,
                      pos=(0, probe_ecc),
                      fillColor=probe_color)

# ----------------------------------------------------------------------------
# /// TRIAL BEGINS ///

for itrial in range(ntrs):

    # --------------------------------
    # /// resets

    # reset mouse position
    mouse.setPos((0, 0))

    # reset pse response
    vline_x = np.nan

    # reset loop counter
    loop_cntr = 0

    # reset response
    pse_norm = np.nan

    # --------------------------------
    # /// set up the stimulus behavior in current trial

    # randomly decide on inter-trial interval
    iti = random.choice(gap_dur_list)

    # add random offset to probe's horizontal onset position
    mouse_offset_FG = np.random.choice(np.arange(-45, 45, 1))
    mouse_offset_FE = np.random.choice(np.arange(-.5, .5, .1)) * frame_width

    # --------------------------------
    print(f'trl: {itrial + 1 : 3d}  |  ',
          f'stm: {stm_array[itrial]}  |  phs: {phs_array[itrial] : 3.0f}  |  ',
          f'dir: {dir_array[itrial] : 2.0f}  |  dyn: {dyn_array[itrial] : <7}',
          end='')

    # --------------------------------
    # /// create motion arrays

    if stm_array[itrial] == 'FG':
        motion_pos1 = 0
        motion_pos2 = dir_array[itrial] * 90
    elif stm_array[itrial] == 'FE':
        motion_pos1 = frame_width / 2
        motion_pos2 = motion_pos1 + dir_array[itrial] * frame_width
    else:
        continue

    motion_offset = (motion_pos2 - motion_pos1) * phs_array[itrial] / 180

    motion_array_base = np.linspace(motion_pos1, motion_pos2,
                                    num=int(REF_RATE / frame_repeat / 2))
    motion_array_rev = np.flip(motion_array_base)
    motion_array = np.concatenate([motion_array_base[:-1],
                                   np.repeat(motion_array_base[-1],
                                             probe_rep_factor),
                                   motion_array_rev[:-1],
                                   np.repeat(motion_array_rev[-1],
                                             probe_rep_factor)])
    motion_array = np.repeat(motion_array, frame_repeat) + motion_offset

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

            if dyn_array[itrial] == 'static':
                ring.ori = motion_array[0]
                frame.pos = motion_array[0], frame_y
            else:
                ring.ori = imotion
                frame.pos = imotion, frame_y

            if stm_array[itrial] == 'FG':
                pse = mouse.getPos()[0] * mouse_fact_FG + mouse_offset_FG
                if pse < -45:
                    pse = -45
                if pse > 45:
                    pse = 45
                ring.draw()
            elif stm_array[itrial] == 'FE':
                pse = mouse.getPos()[0] * mouse_fact_FE + mouse_offset_FE
                if pse < -frame_width / 2:
                    pse = -frame_width / 2
                if pse > frame_width / 2:
                    pse = frame_width / 2
                bg.draw()
                frame.draw()
            else:
                continue

            # draw fixation mark
            fixdot1.draw()
            fixdot2.draw()
            refline1.draw()
            refline2.draw()

            if imotion == (motion_pos1 + motion_offset) and loop_cntr > -1:
                if stm_array[itrial] == 'FG':
                    probe.pos = pol2cart(probe_ecc, -pse + 90)
                    probe.draw()
                if stm_array[itrial] == 'FE':
                    probe.pos = pse, probe_ecc
                    probe.draw()
            win.flip()

            # exit loop upon proper response
            pressed_key = event.getKeys(keyList=['space', 'escape'])
            if 'escape' in pressed_key:
                core.quit()
            if 'space' in pressed_key:
                loop_flag = False
                break

    pse_x, pse_y = probe.pos[0], probe.pos[1]
    pse_rho, pse_phi = cart2pol(pse_x, pse_y)
    pse_phi = 90 - pse_phi

    if stm_array[itrial] == 'FG':
        pse_norm = pse_phi / 90 * 100
    if stm_array[itrial] == 'FE':
        pse_norm = pse_x / frame_width * 100

    print(f'       PSE(x, y): ({np.round(pse_x, 2) : 4.2f},'
          f'{np.round(pse_y, 2) : 4.2f})', end='')
    print(f'  |  PSE(rho, phi): ({np.round(pse_rho, 2) : 4.2f},'
          f'{np.round(pse_phi, 2) : 6.2f})', end='')
    print(f'  |  PSE(normalized): {np.round(pse_norm, 1) : 5.1f}%')

    # --------------------------------
    # /// prepare data for saving

    # create a dictionary of variables to be saved
    trial_dict = {'trial_num': itrial + 1,
                  'stimulus_type': stm_array[itrial],
                  'stimulus_phase': phs_array[itrial],
                  'postflash_motiondir': dir_array[itrial],
                  'stimulus_kinetic': dyn_array[itrial],
                  'pse_cart': [[np.round(pse_x, 2), np.round(pse_y, 2)]],
                  'pse_polar': [[np.round(pse_rho, 2), np.round(pse_phi, 2)]],
                  'pse_norm': [np.round(pse_norm, 1)],
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
