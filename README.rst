Brightness Menulet
==================

**This tool is not stable and almost not maintained. Use at your own risk. Try to look at forks, there's a chance your LCD model might be supported**

Allows you to control monitor brigthness via menu in status bar.

This tool works on OSX 10.8+. If you have tested your monitor(s) with this tool, please
let me know wether it worked or not so I can add monitor models here. Preference's Debug button logs to the
console VCP codes and their values on the selected monitor.

Download app build: `BrightnessMenulet.zip`_.

.. _BrightnessMenulet.zip:
    https://raw.github.com/kalvin126/BrightnessMenulet/master/BrightnessMenulet/Brightness_Menulet.zip

.. image:: https://raw.github.com/kalvin126/BrightnessMenulet/master/BrightnessMenulet/screenshot.png

Monitors:
.......................
+------------------+---------------+
| Working          | Non-Working   |
+==================+===============+
| Dell U2014h      |               |
+------------------+---------------+
| Dell U2414h      | Philips 4065UC|
+------------------+---------------+
| Dell U2415h      | Dell P2412H   |
+------------------+---------------+
| Dell U2515h      | Dell U2412M   |
+------------------+---------------+
| Dell U2715h      | LG LB5600     |
+------------------+---------------+
| Dell U2713HM     | HP Z23i       |
+------------------+---------------+
| Dell P2415Q      |               |
+------------------+---------------+
| Dell P2715Q      |               |
+------------------+---------------+
| Dell S2216M      |               |
+------------------+---------------+
| Samsung SA 350   |               |
+------------------+---------------+
| BenQ G2410HD     |               |
+------------------+---------------+
| Viseo 230Ws      |               |
+------------------+---------------+
| Asus VS239       |               |
+------------------+---------------+
| LG 27UD88-W      |               |
+------------------+---------------+
| LG 34UC87M       |               |
+------------------+---------------+


If you have tested your monitor(s) with this tool, please let me know whether or not it work and I will update this table.


Features:
............

- Following the internal Display's Brightness (if automatic brightness is activated in the system preferences this follows the light sensor as well)
- Auto-Follow is indicated by highlighting the status bar icon
- Multi-Monitor support (no limit to amount of monitors)!
- Key bindings for Darker, Brighter and toggle the Follow-Main-Screen option
- Compatible with OSX 10.8+

Roadmap:
........

- Support for other monitor makes (Currently only tested on Dell and certian HP displays)
- Time based settings
- Fading between Auto-Follow values

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
