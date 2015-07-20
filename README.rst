Brightness Menulet
==================

This tool only works on pre OSX 10.09. In 10.10+ I2C tools are not able to detect monitor buses for communication.
I won't be updating this until I2C is fixed or I can find a work arround.

Allows you to control monitor brigthness via menu in status bar.

Download app build: `BrightnessMenulet.dmg`_.

.. _BrightnessMenulet.zip:
    https://raw.github.com/kalvin126/BrightnessMenulet/master/Brightness_Menulet.zip

.. image:: https://raw.github.com/kalvin126/BrightnessMenulet/master/screenshot.png

Change list:
............

- Added OSD lock toggle
- Monitor based Color Presets for Standard and sRBG
- Preferences window for RGB, Contrast and Brightness controls
- More specific changes can be found in the commit history

Original:
- Fixed brightness control ( at least it works for my Dell monitor )
- Removed brightness value polling (too slow)


Roadmap:
........

- Support for other monitor makes (Currently only tested on Dell and certian HP displays)
- Multiple monitor Support (Currently tested on one Dell monitor)
- Time based settings
- Custom presets
- Add keyboard bindings

Credits:
........

- `Alec Jacobson`_ - `original Brightness Menulet app`_ creator
- Jon Taylor - `DDC/CI bindings`_
- Victor Miroshnikov - copy&paste&debug job

.. _DDC/CI bindings:
    https://github.com/jontaylor/DDC-CI-Tools-for-OS-X

.. _Alec Jacobson:
    http://www.alecjacobson.com/weblog/

.. _original Brightness Menulet app:
    http://www.alecjacobson.com/weblog/?p=1127
