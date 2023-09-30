# x16-tile-editor
Tile/Sprite Editor for the Commander X16

## Overview
This application is going to be part of the official [Commander X16 ROM](https://github.com/X16Community/x16-rom) as an always-available development tool for creating and editing sprite and tile graphics. The asset files it creates can be loaded into VRAM using built-in BASIC and Kernal routines. It supports all of the tile/sprite dimensions and color depths allowed by the VERA graphics adapter, and also lets you define and save a custom 256-color palette.

## Building and Deployment
It is highly recommended that you use one of the [pre-built releases on this GitHub repo](https://github.com/SlithyMatt/x16-tile-editor/releases) unless you want to have your own custom build.

The only tool needed to build this program is [cc65](https://cc65.github.io/), a multi-platform cross-development suite for 6502-based systems, including the Commander X16. There are pre-built binaries for Linux, Mac and Windows, but the source code can easily compile on most modern systems. The only other thing highly recommended is a means of executing Unix-style shell scripts, which you automatically get with Linux and Mac, and can be freely obtained on Windows using something like Git Bash or Windows Linux Subsystem.

Once you have the cc65 binaries on your execution path (which is done automatically using an installer), open a terminal in the directory containing this workspace and run the build script.

```$ ./build.sh```

This will generate **TILEEDIT.ROM**, which contains all the code for the program. Tou can then use one of the BASIC loaders to load and run the program.

To run the program and get started on your own tileset, use **tileedit.bas**, which is a plain text version of the default loader. You can use the [Commander X16 Emulator](https://github.com/X16Community/x16-emulator) to both tokenise this program and try out the editor for the first time.

```$ x16emu -bas tileedit.bas -run```

If you want to start with the current character set, you can use the **charload.bas** loader instead.

## How to Use

### Tile Editing

### Palette Editing

### Settings

### Preview

## File Formats

## For more information...



