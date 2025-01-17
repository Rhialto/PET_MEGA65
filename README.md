MEGAPET
=======

This is the MegaPET, the PET implementation on the Mega-65 hardware.

*THIS IS A WORK IN PROGRESS! IT IS NOT FINISHED!*

There have been many different versions of PET, and the MegaPET aims to support most of them, eventually.

This project is organized in 3 git repositories. The top-level one is a snapshot of the MiSTer2MEGA65 framework (which also brings the QNICE repo with it), and much of the actual PET is in a submodule [CORE/PET2001_MiSTer](https://github.com/Rhialto/PET2001_MiSTer). If you want to get the source code, use these commands:

* `git clone https://github.com/Rhialto/PET_MEGA65`
* `cd PET_MEGA65`
* `git submodule init`
* `git submodule update`

Releases
--------
There are currently no releases.

From time to time there is a pre-release, when there seems to be some useful addition to the code base. There is absolutely no guarantee when those happen.

v0.00009
--------
This prerelease adds, compared to v0.00007:

- 80 columns of text. Enabling this option automatically enables the CRTC too, but you need to load the `8032b.rom` yourself. You will also need to enable the following new feature:
- B-type ("business") keyboard. By itself this is not so interesting, since with the symbolic mapping of the Mega-65 keyboard you don't notice much difference (but do refer to the keyboard mapping section below).
- 2001-style screen snow. This is enabled as part of "2001 screen blank etc". This option affects 2001-specific quirks as part of the "etcetera". At his time they are:
  - screen snow, when the CPU accesses screen memory at the same time as the video system.
  - the screen blanks when EOI is sent on the IEEE-488 bus. This is used by the ROM to mask the previous effect when scrolling (only the non-CRTC ROMs do this).
  - the 1 KB of screen memory $8000-$83FF is repeated 3 more times, up to $8FFF. Later models go only up to $87FF.
- I have extended the set of ROMs with B keyboard and 80 column ROMs. You can get more variants from the well-known Zimmers site.
- I am including a `petcfg` file which you can copy to the `/PET` directory on the sd-card. It will remember the menu selections. Unfortunately not the ROM file you loaded, so it is less useful than it could be.

v0.00007
--------
As of v0.00007, the core features:

- R3 and R6 versions. I have an R6 myself and the R3 is generated from the MiSTeR2MEGA framework but not tested.
- PET with or without CRTC (the CRT Controller which is used in later models)
- 40 columns only
- with "2001" properties, or without (= screen blanks when EOI is sent, screen memory has more mirrors)
- with "2001" blue-ish white, or green screen
- for now, some ROM files are available from https://github.com/Rhialto/PET_MEGA65/releases/tag/v0.00005
- a 2031 floppy drive on the IEEE bus. At some point this will become a 4040. Even an 8250, if I can store disk images in Attic RAM (the 2 drives with 1 MB per disk image is too much for the BRAM in the core, I think).
- default directory for the SD-card file selector is "/PET" so storing your ROM files and disk images is probably the most convenient.
- the core includes the "4032n-nocrtc" ROM by default, so it is usable even before you copy over ROM files or whatever to your SD-card.
- Furture plans include saving the settings, 80 columns, ColourPET mode, 8096 memory expansion, 8296 memory expansion, but nobody knows when those things might be realised.

I have only tested IMDH output, not VGA output. One report mentions that VGA output isn't very good. As far as the VGA output follows the PET core output, rather than the scaled output, this is to be expected: PET video timings are certainly not "standard" and differ from ROM to ROM. Many have a 16 KHz line frequency but I think 20 KHz and other values occur as well.

PET MODELS
----------

First, a bit about the different models of PET. MegaPET has several settings so that it can do many of them, but that also means that some combinations of settings make no sense and will not work. Additionally, you need to choose the correct set of ROMs for the hardware.

Note that when I say ROM I do mean actual data that originally was in ROM chips. This in contrast to how people in emulator circles often seem to mis-use the word for other things.

At least the following variations of PET exist:

-   Basic 1.0
    These all have a "chicklet" keyboard, functionally identical to the N keyboard, no CRT controller chip, 60 Hz refresh, 40 columns, shifted characters can be lower case.
    These are the "2001" machines. `2001.rom` is the appropriate ROM for this, although you probably want to use `2001+ieee.rom` instead. It adds a ROM patch, taken from (VICE)[https://vice-emu.sourceforge.io/], to make loading from disk drives work. For the correct character set, you need `PET2001-chars.rom`.

-   Basic 2.0
    The character generator ROM has changed: in upper/lowercase mode, the unshifted characters are now lower case.
    *   with N keyboard (Normal, or Graphic) (use `3032.rom`)
    *   with B keyboard (Business, without graphic symbols)	(use `3032b.rom`)

-   Basic 4.0
    *   with N keyboard (Normal, or Graphic) (`4032n.rom`) or
    *   with B keyboard (Business, without graphic symbols), (`4032b.rom`)
	and
    *   as upgrade for machines without CRT controller (`-nocrtc` rom files), or
    *   for new machines with CRT controller (default),
	and
    *   40 columns, or
    *   80 columns (unimplemented so far),
	and
    *   50 Hz screen refresh (and IRQ), or
    *   60 Hz screen refresh (and IRQ).

Fortunately not all combinations exist, but there are still a lot.

-   no CRTC implies 60 Hz and 40 columns.
-   80 columns implies CRTC and B keyboard, although N versions have been made
by 3rd parties.

All the differences in display and keyboard manifest in the "editor" ROM. The Basic and Kernal ROMs only come in versions 1, 2 and 4 (apart from 2 cases of bug fixes which I will further ignore).

Later models are all variants of the 8032 model. These include a 64 KB memory expansion (making a 8096) and the 8296 which has 128 KB of memory (essentially the 64 KB memory expansion built-in and using 2 banks of 64 Kbit RAM chips).
A different and incompatible expansion is the SuperPET a.k.a. MicroMainFrame 9000 (an 8032 with an additional 6809 CPU and a *different* 64 KB memory expansion).
This is all not implemented at this time.

ROMMAKER
--------
MegaPET ROM files are 32 KB which cover addresses $8000-$FFFF. The first 4 KB, $8000-$8FFF aren't actually used (this is screen memory area) but this is simpler for the implementation. The range $E800-$E8FF also isn't used since this is where the I/O chips are addressed.

The Python program `./CORE/PET2001_MiSTer/roms/rommaker.py` is included in the submodule to help with creating ROM sets from the parts that are separately available. This can be helpful to make new combinations that aren't supplied here.

It has built-in knowledge of many ROM part numbers to know at which address they belong. For unknown ones, it falls back to an address in the file name.

You use it by calling `python3 rommaker.py -o OUTPUT.rom file1 file2` or `python3 rommaker -p PRESET` (use `-p help` to see which presets are available).

You can also use the rommaker to modify an existing 32 KB ROM file, by listing it as the first input. The next ROM files will be overlaid on top of this, effectively modifying the contents. This would be convenient for plugging for example a Toolkit ROM into the $9xxx, $Axxx or $Bxxx EPROM socket. As long as the file name contains "9000", "a000" or "b000", rommaker knows where to place it.

PET ROM files are easily found online by googling for the part numbers known to rommaker.

KEYBOARD MAPPING
----------------
MegaPET can be set to both keyboard layouts. Use the submenu item `B keyboard` to choose the B layout. The N version is default.

Both layouts have a numerical keypad, which the Mega-65's keyboard is unfortunately lacking. Therefore some compromises have to be made. Apart from that, the keyboard has more or less all required keys.

### N keyboard

* `CTRL`: works as the `OFF/RVS` key
* `0123456789/*+=.-` keys are keypad keys
* `!"#$%&'()<>?[]` are shifted on the Mega-65 keyboard but the shift key will be ignored for the PET.
* `Mega` + the above keys: if you want to access the PET graphic characters on `!"#` etc, additionally press the `Mega` key. This *will* activate the PET's shift key.

The ROMs slow down scrolling if you press the OFF/RVS key.

### B keyboard

The B keyboard has 2 sets of number keys (and `.`): once on the numeric keypad, and once on the main. By default typing these keys will activate the version on the PET's main keyboard.

* `Mega` + `1234567890.`: use the keypad version of the key.
* `Mega` + `[]`: press the PET's shift key along with the main key. Normally this makes no difference, but potentially some software cares.
* `ALT` functions as `REPEAT`
* `ESC` and `TAB` are 2 more extra keys compared to the N keyboard
* `CTRL`: works as the `OFF/RVS` key

The ROMs slow down scrolling if you press the `<-` key (arrow left, not the cursor key). `:` works as a no-scroll key.

### Diagnostic Sense

Normally the PET's memory counting is destructive. This is annoying when you're trying to debug some program: pressing reset causes you to lose the memory contents. However in ROM versons 2 and higher there is a built-in monitor available. This monitor is entered if the so-called "diagnostic sense" line is pulled low when resetting.

On the MegaPET you can press `Mega` + `CTRL` to pull down the diagnostic sense line. While holding these, additionally press the reset button. Since both are on the left-hand side of the Mega-65, you can conveniently press `Mega` + `CTRL` with a thumb while using a finger around the corner for the reset. This will land you in the machine language monitor.

There's more: you're not yet out of the woods. Type a semicolon followed by RETURN; PET will respond with a question mark. Now move the cursor back to your register display line, and change the Stack Pointer (SP) value from 01 to F8. This strange procedure is important: you must follow it exactly. Once you've done so, you're clear. You may return to Basic with an X if you like, or proceed in the MLM.

Source: Jim Butterfield in [Compute! Magazine, issue #1, page 89](https://archive.org/details/compute_0001_fal79/page/88/mode/2up) I would recommend reading all early issues of Compute! for interesting information about your MegaPET.


CREDITS
-------

This project is based on, and would have been impossible without, the following other projects:

* [MiSTer2MEGA65](https://github.com/sy2002/MiSTer2MEGA65) by MJoergen and sy2002 is a framework to simplify porting MiSTer cores to the MEGA65.
* [PET2001_MiSTer](https://github.com/MiSTer-devel/PET2001_MiSTer) from sorgelig. This was the starting point of the PET core.
* [C64_MiSTerMEGA65](https://github.com/MJoergen/C64_MiSTerMEGA65) by MJoergen and sy2002 and contributors. I used the 1541 from this, and converted it to a 2031 drive (replaced the serial IEC bus with a parallel IEEE-488 bus) so it can connect to a PET.
* The work-in-progress [CBM-II_MiSTer](https://github.com/eriks5/CBM-II_MiSTer) from which I first used the 6845 CRTC.
* The BBC micro implementation [BeebFpga](https://github.com/hoglet67/BeebFpga) rom which I used the updates to the CRTC.

/* vim:lbr
