Brightness Menulet
==================

This tool works up to OSX 0.11. In 10.10+ I2C tools are not able to detect monitor buses for communication.
The main API calls for DDC communication is deprecated so this project could be obselete if Apple removes
CGDisplayIOServicePort.

Allows you to control monitor brigthness via menu in status bar.

Download app build: `BrightnessMenulet.dmg`_.

.. _BrightnessMenulet.zip:
    https://raw.github.com/kalvin126/BrightnessMenulet/master/Brightness_Menulet.zip

.. image:: https://raw.github.com/kalvin126/BrightnessMenulet/master/screenshot.png

Features:
............

- Multi-Monitor support!
- 10.10+ working on any Mac (testing only on my Dells)

Roadmap:
........

- Support for other monitor makes (Currently only tested on Dell and certian HP displays)
- Time based settings
- Custom presets/profiles
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
