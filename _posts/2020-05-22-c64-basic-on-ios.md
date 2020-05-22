---
layout: post
title:  C64 BASIC on iOS
date:   2020-05-22 11:38 +0200
image:  music-1285165_1280.jpg
credit: https://pixabay.com/de/photos/musik-kassette-retro-audio-band-1285165/
tags:   ios c64-basic
---


> BASIC (Beginners' All-purpose Symbolic Instruction Code or Beginners All-purpose Symbolic Instruction Code) is a family of general-purpose, high-level programming languages whose design philosophy emphasizes ease of use. -- [Wikipedia: BASIC](https://en.wikipedia.org/wiki/BASIC)

After running [C64 BASIC on a microcontroller, in a Docker image](/2020/05/02/dockerfile-from-as-c64-emulator/) and also on the console, I thought, why not on an iPhone?

My idea is to create an iOS app for the output and an input field for the commands. I send the commands to a C64 BASIC interpreter and read the output to display it in the app. I adjust the color and font and then I will have a C64 on my iPhone.
![C64 BASIC iOS Screenshot](https://raw.githubusercontent.com/choas/C64-BASIC-iOS-emu6502-cbm/master/screenshot.png)

## C64 BASIC Libraries

At the end I wrote two apps because I had two libraries with a C64 BASIC interpreter, and each library has an advantage over the other one:

- [cbmbasic](https://github.com/mist64/cbmbasic)
- [c-simple-emu6502-cbm](https://github.com/davervw/c-simple-emu6502-cbm)

### cbmbasic

The project started 11 years ago, and the last activity was 6 years ago. As you can read in the README file, _any code is completely native_. But and this is a __very big disadvantage__, the code was generated (with LLVM), and therefore everything is in one 1.8 MByte file - Xcode doesn't like that. The whole interpreter runs in the main function, in a single loop, and the file has 3222 goto commands. The code is not readable.

The good thing about this project is, that some code is separated into own functions. This allows me to hook into the input and output handling.

The advantage of this project is the extensibility. You can add your own BASIC commands and activate them with the SYS 1 command. As an example, [Bill Gates’ Personal Easter Eggs in 8 Bit BASIC](https://www.pagetable.com/?p=43) was implemented. If I think further, this could be an opportunity to communicate with iOS and call from BASIC some Swift code.

### c-simple-emu6502-cbm

I don't know if you need to know 6502 assembler code, but it's fun. The c-simple-emu6502-cbm project is a month old and it emulates a 6502 processor. Every 6502-assembler command is implemented in C. The [LDA](https://www.masswerk.at/6502/6502_instruction_set.html#LDA) (Load Accumulator) command with the [opcode](https://en.wikipedia.org/wiki/Opcode) _0xA9_ is implemented like this in the [emu6502.c](https://github.com/davervw/c-simple-emu6502-cbm/blob/master/emu6502.c#L808) file:

```c
case 0xA9: SetA(GetIM(PC, &bytes)); break;
```

In case of 0xA9, the `SetA` method is called with the return value of the `getIM` method. The 'IM' stands for [immediate addressing](https://www.c64-wiki.com/wiki/Immediate_addressing) and returns the value after the PC (program counter).

The `p_bytes` value is added to the PC at the end. It is set to 2, because the operator requires two bytes. One for the _LDA_ command and the second for the value that is passed.

```c
static byte GetIM(ushort addr, byte *p_bytes)
{
  *p_bytes = 2;
  return GetMemory((ushort)(addr + 1));
}
```

The `SetA` method sets the `value` to the register A (accumulator).

```c
static void SetA(int value)
{
  SetReg(&A, value);
}
```

This command influences also the flags Z (zero) and N (negativ). Therefore, the `SetReg` method checks the `value`. If it is null, Z is true and if it is negativ (bit 7 is high) the N flag is true.

```c
static void SetReg(byte *p_reg, int value)
{
  *p_reg = (byte)value;
  Z = (*p_reg == 0);
  N = ((*p_reg & 0x80) != 0);
}
```

The [6502 Microprocessor Instant Reference Card](https://archive.org/details/6502MicroprocessorInstantReferenceCard) is an old but also beautiful document. Isn’t it nice?

## iOS Framework

To integrate one of the C64 BASIC interpreters I have created an iOS framework. The article [Xcode: Frameworks](http://www.thomashanning.com/xcode-frameworks/) and [Wrapping a C Library in a Swift Framework](https://colindrake.me/post/wrapping-a-c-library-in-a-swift-framework/) describes the necessary steps to create an iOS framework project. See also [What are Frameworks?](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPFrameworks/Concepts/WhatAreFrameworks.html)

## Architecture and workflow

The iOS app is responsible for input and output. It uses a UITextView with C64 colors and a C64 font for the output and a UITextField for the input. The C64 BASIC interpreter is part of an iOS framework, which provides the interface for sending and receiving data of the iOS application. The interpreter receives the input data and returns the output. An Objective-C wrapper is used for this.

![C64 BASIC iOS Workflow](/images/c64_basic_ios_workflow.png)

The figure shows the files for the example _c-simple-emu6502-cbm_, they are similar for the _cbmbasic_ project. The Swift application communicates with the Swift interface of the iOS framework. This one with the Objective-C wrapper and this one with the C64 BASIC interpreter.

The iOS app starts the emulator with the `run` command. The user input is sent with the `cmd` method. The `read` method reads the C64 output.

The Swift interface implements the `run`, `cmd` and `read` methods. The `run` method calls the `C64_Init` method with the ROM file names. Additionally, it calls the `MyResetRun` method, which is a simple wrapper method — otherwise I would have had to deal with function pointers of the original method. The `cmd` method writes the user input into a char array, and the `read` method fetches the C64 output data.

`CBM_Console_ReadChar` and `writeChar` implement the input and output.
Both interpreters use _stdin_ and _stdout_ to read and write. But it is not a console application and therefore I have redirected the input and output.

### Input and Output

The `CBM_Console_ReadChar` function loops and looks if there is something new in a command buffer and then sends the character back as "keyboard input". This allows me to write from the app to the framework/lib via Swift, Objective-C and C into the buffer. To prevent the battery from burning 🔥 out I have a sleep in the while loop. Otherwise the CPU would be at 100%.
The `writeChar` function writes the C64 output into a char array, which is implemented as a ring buffer. I fetch the output characters in the app with the `read` method and display them. The app runs a timer which reads the output every 100 ms. Since there is no trigger within C64 BASIC that signals an end, I read the output buffer continuously.

## C64 look and feel

To make the application look like a C64 I have modified the colors 🎨 and font. But the feeling of a C64 is not possible with a touchscreen. Did the C64 keyboard feel like a mechanical keyboard, only clunkier?

### Font

The document [Adding a Custom Font to Your App](https://developer.apple.com/documentation/uikit/text_display_and_fonts/adding_a_custom_font_to_your_app) describes how you can change the font of your app. I found two fonts and choose the first one:

- [C64 TrueType (TTF) Fonts](https://style64.org/c64-truetype)
- [dafont commodore-64 font](https://www.dafont.com/commodore-64.font)

### Colors

I adapted the foreground and background color based on the [Wikipedia: List of 8-bit computer hardware graphics — C64](https://en.wikipedia.org/wiki/List_of_8-bit_computer_hardware_graphics#C-64) image. I’ve selected the colors with a pipette.

## Load ROMs

The iPhone app runs within a sandbox; therefore it is not possible to simply access e.g. "basic" as a file. This file is located somewhere in the file system and it must be part of the build target to access it. `Bundle.main.path` returns the path of the file and with this the CBM library can open the file. This can also be used to start the emulator with a C64 program.

## Summary

Since the 6502 is emulated, I can now run everything on it and so I thought: How about COBOL on a 6502? And then I found this:

"The T-800’s visual systems (at least) appear to be programmed in COBOL and 6502 assembly \[…\]" — [T-800 - Terminator Fandom Wiki](https://terminator.fandom.com/wiki/T-800)

Both interpreters were designed for the console, they just print the output. However, they do not handle the memory of the monitor, which is in the 0x0400 range (see [Screen RAM](https://www.c64-wiki.com/wiki/Screen_RAM#Memory_adresses)). The graphical output is also not possible. [VICE](https://vice-emu.sourceforge.io/) is an emulator which supports it but isn't available for iOS.

Another interesting project is the [flooh / chips](https://github.com/floooh/chips) project on which the C64 Docker image is based, which I mentioned in the [Dockerfile FROM AS — C64 Emulator](/2020/05/02/dockerfile-from-as-c64-emulator/) blog post. I will take a closer look at this project, because different emulators (e.g. Z80, CPC) run in the browser as [WebAssembly](https://en.wikipedia.org/wiki/WebAssembly).

But it's enough for now. I have two iOS apps with different C64 BASIC interpreters:

- [C64-BASIC-iOS-emu6502-cbm](https://github.com/choas/C64-BASIC-iOS-emu6502-cbm)
- [C64-BASIC-iOS-cbmbasic](https://github.com/choas/C64-BASIC-iOS-cbmbasic)

In an upcoming blog post I will take a look at the RND function.

99 END
