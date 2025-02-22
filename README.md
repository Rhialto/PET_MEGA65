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

v0.00011
--------
This prerelease adds/changes, compared to v0.00010:

- Starts up as model 8032: with CRTC, 80 columns, B keyboard, 8032b.rom. Some people preferred this.
- Updated ColourPET editor ROM `4032n+colour.rom` to [cpet-c0-40-n-mega-wedge (2025-01-31).bin](https://github.com/sjgray/cbm-edit-rom/blob/269e4fb2f405f558f6d94e1a3dfefce39e28b60b/binaries/ColourPET/Test/cpet-c0-40-n-mega-wedge%20(2025-01-31).bin). Copy the new version to your sdcard.
- Imported 4040 dual disk drive from [CBM-II_MiSTer core](https://github.com/eriks5/CBM-II_MiSTer/tree/e011b6586fce3deaf1a7e5ce361e8cd2ff80420e/rtl/ieee_drive) by Erik Scheffers. This drive is not considered final yet so there may be updates in the future.
- Loading custom drive ROMs is for now not possible (the feature is missing from the 4040's code).
- There are 3 LEDs to show (2 drive activity LEDs and the error LED). I tried to map them to the 2 halves of the M65's drive LED but you could not really see a difference between left and right in most cases. So I mapped them to colours: red = error, green = drive 0, blue = drive 1.
- The Power LED is yellow when the drive cache is dirty and/or being flushed. This previously was the task of the drive LED.

v0.00010
--------
This prerelease adds, compared to v0.00009:

- Steve Gray's [ColourPET](http://cbmsteve.ca/colourpet/index.html) board. Try it with [GridRunner](https://milasoft64.itch.io/gridrunner). I have included a test version of an editor ROM set for 40 columns `4032n+colour.rom`, specially created by Steve Gray for the MegaPET. Keep an eye on [github](https://github.com/sjgray/cbm-edit-rom/tree/master/binaries/ColourPET) for updates.
- You can now select 8, 16 or 32 KB as the basic memory size.
- 64 KB memory extension board, 8096-style. Not so well-tested but it seems ok.
- The optional second half of the character ROM can now be used (if it is 4 KB), by setting MA13 (`poke 59520,12: poke 59521,3\*16`). The MegaPET comes loaded with the character ROM from the SuperPET, which has ASCII and APL characters in the extra part. To go back to normal use `poke 59520,12: 59521,1\*16`.
- Similarly the screen as a whole can be inverted by unsetting MA12 (use `poke 59521,0\*16` or `2\*16`).
  These features only work with the CRTC, and these address bits may be repurposed in later PET models: for example, the HRE uses MA12.
- Incorporated upstream fixes from the to-be-released next version of the M2M framework, fixing the "barcode" issue that affects a small number of Mega65 revision 6 machines.

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
- I am including a `petcfg` file which you can copy to the `/PET` directory on the sd-card. It will remember the menu selections. Unfortunately not the ROM file you loaded, so it is less useful than it could be. Actually I would recommend against using this. It got me into a scare when I left it set to 80 columns, and on the next load of the core I just got a black screen, because the corresponding ROM was not loaded any more...

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
    These are the "2001" machines. `2001.rom` is the appropriate ROM for this, although you probably want to use `2001+ieee.rom` instead. It adds a ROM patch, taken from [VICE](https://vice-emu.sourceforge.io/), to make loading from disk drives work. For the correct character set, you need `PET2001-chars.rom`.

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

SETTINGS
--------

These are the settings in the "Model options..." submenu.

### 2001 screen blank etc

This option enables the "2001 quirks":

  - screen snow, when the CPU accesses screen memory at the same time as the video system.
  - the screen blanks when EOI is sent on the IEEE-488 bus. This is used by the ROM to mask the previous effect when scrolling (only the non-CRTC ROMs do this).
  - the 1 KB of screen memory $8000-$83FF is repeated 3 more times, up to $8FFF. Later models go only up to $87FF.

For the full "2001 experience", enable this option, "2001 white" and "8 KB". Also load "2001+ieee.rom" (which allows you to use the disk drive, so this is cheating a bit).

### 2001 white

This changes the display colour to an approximation of that of the 2001, which was a slightly blue-ish white.
The default colour is green.

### B keyboard

Normally an N (normal) keyboard is used, but with this option the Business mapping is used. This setting needs to correspond to what the Editor ROM expects. See below for the mapping from the Mega-65 keyboard to the PET keyboard types.

### 6545 CRT Controller

This option enables the CRT Controller, as present in the 40xx and 8xxx models. When enabled you need an Editor ROM that supports it. (You can mostly get away with using an Editor ROM that expects a CRTC when you have it disabled)

### 80 columns

This enables 80 columns of text (rather than the default 40), making an 8xxx model. Again, needs an Editor ROM that supports it. Most of those also expect a B keyboard and all need a CRTC. Therefore enabling this option implicitly enables the CRTC.

### ColourPET rgbi

This enables the [ColourPET extension](http://cbmsteve.ca/colourpet/index.html) from Steve Gray. It is made for 40 columns but in principle it could be made to work with 80 columns. Again, needs a supporting [Editor ROM](http://cbmsteve.ca/editrom/index.html). Enabling this option implicitly enables the CRTC.

Without a supporting Editor ROM, the colour memory ($8800...) will be initialized to all zero bytes and your text will be black on black: invisible. (On real PET hardware, screen memory is random on power-on). To help a bit with that, the "2001 white" option will partially override the Colour option and display in b/w, while keeping the colour RAM enabled so you can initialize it.

### 8 KB memory, 16 KB memory, 32 KB memory

A group of 3 options. Choose one for the amount of "normal" memory (available to Basic).

### PET ROM: \<Load>

Load a ROM file. See below in the ROMMAKER section for how these are put together.

### Charset: \<Load>

Load a character generator ROM. These can be 2 KB or 4 KB. Only the non-reversed characters are present. Inverting them is done in hardware.

The optional second half of the character ROM can be used (if it is 4 KB), by setting MA13 (poke 59520,12: poke 59521,3\*16). The MegaPET comes loaded with the character ROM from the SuperPET, which has ASCII and APL characters in the extra part.
Similarly the screen as a whole can be inverted by unsetting MA12 (use poke 59521,0\*16 or 2\*16).
These features only work with the CRTC, and these address bits may be repurposed in later PET models: the HRE uses MA12.

### Drive ROM: \<Load>

Actually I didn't test this yet. There aren't so many alternative ROM sets for a 2031 drive.

ROMMAKER
--------
MegaPET ROM files are 32 KB which cover addresses $8000-$FFFF. The first 4 KB, $8000-$8FFF aren't actually used (this is screen memory area) but this is simpler for the implementation. The range $E800-$E8FF also isn't used since this is where the I/O chips are addressed.

The Python program `./CORE/PET2001_MiSTer/roms/rommaker.py` is included in the submodule to help with creating ROM sets from the parts that are separately available. This can be helpful to make new combinations that aren't supplied here.

It has built-in knowledge of many ROM part numbers to know at which address they belong. For unknown ones, it falls back to an address in the file name.

You use it by calling `python3 rommaker.py -o OUTPUT file1 file2` or `python3 rommaker -p PRESET` (use `-p help` to see which presets are available). `.rom` is automatically appended. Also a `.hex` file is created, suitable for using in core development.

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
* The work-in-progress [CBM-II_MiSTer](https://github.com/eriks5/CBM-II_MiSTer) from which I first used the 6845 CRTC and the 4040 / 8250 dual disk drive.
* The BBC micro implementation [BeebFpga](https://github.com/hoglet67/BeebFpga) from which I used the updates to the CRTC.
* Steve Gray's [ColourPET](http://cbmsteve.ca/colourpet/index.html) and [Edit ROM](http://cbmsteve.ca/editrom/index.html) projects. 

/* vim:lbr
