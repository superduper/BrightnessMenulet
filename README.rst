Brightness Menulet
==================

Allows you to control monitor brigthness via menu in status bar.

This tool works on OSX 10.8+. If you have tested your monitor(s) with this tool, please
let me know wether it worked or not. Preference's Debug button logs to the
console VCP codes and their values on the selected monitor.

Modified version!
See commit messages for more information.

No Binary download available.

.. image:: https://raw.github.com/kalvin126/BrightnessMenulet/master/BrightnessMenulet/screenshot.png

Features:
............

- Automatic Brightness using built in light sensor (Modify LMUController’s percentageForSensorValue: to your liking)
- Multi-Monitor support (no limit to amount of monitors)!
- Compatible with OSX 10.8+
- Keyboard bindings (hardcoded)

Roadmap:
........

- Support for other monitor makes (Currently only tested on Dell and certian HP displays)
- Time based settings

Credits:
........

- `Alec Jacobson`_ - `original Brightness Menulet app`_ creator
- Jon Taylor - `DDC/CI bindings`_
- Victor Miroshnikov - copy&paste&debug job
- `Joey Korkames`_: EDID Reading

.. _DDC/CI bindings:
    https://github.com/jontaylor/DDC-CI-Tools-for-OS-X

.. _Alec Jacobson:
    http://www.alecjacobson.com/weblog/

.. _Joey Korkames:
    https://github.com/kfix/ddcctl

.. _original Brightness Menulet app:
    http://www.alecjacobson.com/weblog/?p=1127
