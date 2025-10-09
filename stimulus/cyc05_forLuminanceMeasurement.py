"""
***** project: PRJ2023_MIPS-ShapeDistortion

    Mohammad Shams <m.shams.ahmar@gmail.com>
    Oct 2025

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
# SETTINGS

full_screen = True

# ----------------------------------------------------------------------------
# /// CONFIGURATION ///

# file names and directory paths
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

# replica/probe
bar_size = 1.5  # [dva]

# T-probe
bar_probe_h_x = 0  # [dva]
bar_probe_h_y = 4.3  # [dva]
bar_probe_v_x = 0  # [dva]
bar_probe_v_y = 4.3  # [dva]
probe_duration_frames = 3  # [frames]

# dot-probe
probe1_radius = .35
probe1_color = 'black'
probe2_radius = .15  # [dva]
probe2_color = 'white'
dot_probe_x = 0  # [dva]
dot_probe_y = 4.85+1  # [dva]

# turn off Numpy's FutureWarning
warnings.simplefilter(action='ignore', category=FutureWarning)

# ----------------------------------------------------------------------------
# /// VISUAL OBJECTS ///

# FG
FG_directory = os.path.join(image_path, 'FG.png')
FG = visual.ImageStim(win,
                      image=FG_directory,
                      size=FG_size,
                      pos=(-5, -5))
# FE
FE_directory = os.path.join(image_path, 'FE.png')
FE = visual.ImageStim(win,
                      image=FE_directory,
                      size=FE_size,
                      pos=(-5, +5))
# T-probe
bar_h_directory = os.path.join(image_path, 'bar_h.png')
bar_v_directory = os.path.join(image_path, 'bar_v.png')
bar_probe_h = visual.ImageStim(win,
                               image=bar_h_directory,
                               pos=(bar_probe_h_x, bar_probe_h_y),
                               size=bar_size)
bar_probe_v = visual.ImageStim(win,
                               image=bar_v_directory,
                               size=bar_size,
                               pos=(bar_probe_v_x, bar_probe_v_y))

# dot-probe
probe1 = visual.Circle(win,
                       radius=probe1_radius,
                       fillColor=probe1_color,
                       pos=(dot_probe_x, dot_probe_y))
probe2 = visual.Circle(win,
                       radius=probe2_radius,
                       fillColor=probe2_color,
                       pos=(dot_probe_x, dot_probe_y))
# fixation mark
fixdot = visual.Circle(win,
                       radius=fixdot_radius,
                       fillColor='black')

# ----------------------------------------------------------------------------
# /// SHOW OBJECTS ///

while True:

    # draw FG
    FG.draw()

    # draw FE
    FE.draw()

    # draw T-probe
    bar_probe_v.draw()
    bar_probe_h.draw()

    # draw dot-probe
    probe1.draw()
    probe2.draw()

    # draw fixation dot
    fixdot.draw()

    win.flip()

    # exit loop upon request
    pressed_key = event.getKeys(keyList=['escape'])
    if 'escape' in pressed_key:
        break

win.close()
