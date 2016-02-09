Brightness Menulet
==================

Allows you to control monitor brigthness via menu in status bar.

This tool works on OSX 10.8+. In 10.8+, I2C tools are not able to detect monitor buses for communication.
The main API calls for DDC communication is deprecated so this project could be obselete if Apple 
completely removes CGDisplayIOServicePort. If you have tested your monitor(s) with this tool, please
let me know wether it worked or not so I can add monitor models here.

Download app build: `BrightnessMenulet.zip`_.

.. _BrightnessMenulet.zip:
    https://raw.github.com/kalvin126/BrightnessMenulet/master/BrightnessMenulet/Brightness_Menulet.zip

.. image:: https://raw.github.com/kalvin126/BrightnessMenulet/master/BrightnessMenulet/screenshot.png

Monitors:
.......................
+-------------+------------+
| Working     | Non-Working|
+=============+============+
| Dell U2014h | Dell P2715Q| 
+-------------+------------+
| Dell U2414h |            |
+-------------+------------+
| Dell U2415h |            | 
+-------------+------------+
| Dell U2515h |            | 
+-------------+------------+
| Dell U2715h |            | 
+-------------+------------+
| Dell U2713HM|            | 
+-------------+------------+

If you have tested your monitor(s) with this tool, please let me know whether or not it work and I will update this table.


Features:
............

- Automatic Brightness using built in light sensor (Modify LMUController’s percentageForSensorValue: to your liking)
- Multi-Monitor support (no limit to amount of monitors)!
- Compatible with OSX 10.8+ (tested only with my Dells)

Roadmap:
........

- Support for other monitor makes (Currently only tested on Dell and certian HP displays)
- Time based settings
- Add keyboard bindings

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
