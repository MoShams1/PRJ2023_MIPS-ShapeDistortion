from psychopy import visual, logging
from lib import stim_flow_control as sfc
import matplotlib.pyplot as plt
import numpy as np
import os

mon = sfc.config_mon_dell()
win = sfc.config_win(mon=mon, fullscr=False)

win.recordFrameIntervals = True
win.refreshThreshold = (1 / 60) + (4 / 1000)
logging.console.setLevel(logging.WARNING)

nframes = 2 * 60

ring_directory = os.path.join('../stimulus/image', 'static.png')
ring = visual.ImageStim(win,
                        image=ring_directory,
                        size=(7, 7),
                        opacity=1,
                        pos=(0, 0))
fix_marker = 'o'
fixdot = visual.TextStim(win=win,
                         text=fix_marker,
                         height=.35,
                         pos=(0, 0),
                         color='black')

for iframe in range(10 * 60):
    ring.ori = iframe / nframes * 360
    ring.draw()
    fixdot.draw()
    win.flip()

print(f'/// Overal, {win.nDroppedFrames} frames were dropped. ///')

intervals = np.round(np.array(win.frameIntervals) * 1000, 2)

print(intervals)
plt.plot(intervals)
plt.show()

win.close()
