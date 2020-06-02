---
layout:  post
title:   Mandelbrot Set — Calling C64 BASIC from iOS
date:    2020-06-01 12:14 +0200
image:   mandelbrot_c64_app_run1.png
excerpt: A mathematics phenomenon known as the Mandelbrot Set can provide the basis for some stunning computer graphics. — “Compute! Magazine Issue 074”
---

> The Mandelbrot Set is the set of complex numbers c for which the function `fc(z) = z^2 + c` does not diverge when iterated from z=0, i.e., for which the sequence fc(0), fc(fc(0)), etc., remains bounded in absolute value. — [Wikipedia: Mandelbrot Set]

In the blog post [C64 BASIC on iOS] I wrote how a C64 BASIC emulator can run as an application on an iPhone. The interpreter can execute BASIC commands and programs. But between the iOS app and the C64 interpreter only the data for the commands and the output is sent. But the screen RAM is not read, and the status is not taken into account whether the program is finished or not.

Now I want to integrate BASIC into iOS, like [I did with Lua]. An iOS application calls the BASIC code within Swift or Objective-C, passes a few values, the BASIC application is executed and returns the result.

I already asked myself why I want to do this with Lua, but there might be some legacy C64 BASIC code that you want to integrate into iOS. Although I don't believe that someone unpacks his floppy disk or [datasette[] and has a miracle calculation that only runs on a C64. But when I look at the code example for the Mandelbrot Set calculation, the code with two GOSUB calls is not intuitive the first time you read it. On the other side, I don't want to rewrite a bigger BASIC application into another programming language.

## Data transfer

A direct interface where I can call `result = command(parameter)` does not exist within the interpreters. But BASIC can read or write memory contents with the `PEEK` and `POKE` commands:

- A BASIC application which is waiting for user input could read a value with `PEEK`.
- The iOS application can read the result from memory, which the BASIC application writes to memory using `POKE`.

This makes it possible to call a BASIC program with parameters and read the result. It would also be possible that iOS reads the value of the iPhone e.g. gyroscope and writes it to memory and the BASIC program reads it and performs some calculation. But why not implement it in Swift or Objective-C?

## Mandelbrot Set example

Which example should I use? A Hello World application is boring. Maybe the [factor calculation] as I used it in the Lua example? The great thing there was that I called a Swift factor method within the Lua factor method. But I don't want to try or implement that with the C64 BASIC. But how about calculating the Mandelbrot Set?

### Mandelbrot Set

I had the idea for the Mandelbrot Set recently when I watched [The Art of Code] from [Dylan Beattie] at the [TNG Big TechDay]. At about 10 minutes and 30 seconds he talks about Mandelbrot Set and how the idea behind it works. That's why I don't want to start explaining the principle here and deal with complex numbers and imaginary numbers, that have nothing to do with any conspiracy theory (at least I don't know any). Have a look at the video — the whole thing is preferable.

### C64 BASIC Mandelbrot Set

Is anyone else here, or did I lose you watching the video? Cause now I need code with a Mandelbrot Set calculation example. Unlike in the past when you typed code from a magazine — really — today you copy something from Stack Overflow. But in this case, there is no example of Stack Overflow, but the internet is big: [How to simply create the Mandelbrot Set on the Commodore 64]. This blog post also explains in detail how complex numbers and the Mandelbrot Set work.

The original code example looks like this:

```BASIC
90 REM **TO CHANGE THE SHAPE, CHANGE**
91 REM **XL,XU,YL,YU. REPS CHANGES  **
92 REM **THE RESOLUTION**
100 XL = -2.000:XU = 0.500
110 YL = -1.100:YU = 1.100
115 REPS = 20
120 WIDTH = 40:HEIGHT = 25
130 XINC = (XU-XL)/WIDTH
140 YINC = (YU-YL)/HEIGHT

200 REM MAIN ROUTINE
205 PRINT "{CLEAR}"
210 FOR J = 0 TO HEIGHT - 1
220 : FOR I = 0 TO WIDTH - 1
230 :   GOSUB 300
231 :   GOSUB 400
240 : NEXT I
250 NEXT J
290 GET A$:IF A$ = "" THEN 290
299 END

300 REM CALCULATE MANDELBROT
310 ISMND = -1
312 NREAL = XL + I * XINC
313 NIMG  = YL + J * YINC
315 RZ = 0:IZ = 0
316 R2Z = 0:I2Z = 0
320 FOR K = 1 TO REPS
330 : R2Z = RZ*RZ - IZ*IZ
340 : I2Z  = 2*RZ*IZ
350 : RZ  = R2Z+NREAL
360 : IZ   = I2Z +NIMG
370 : IF (RZ*RZ + IZ*IZ)>4 THEN ISMND=0:K=REPS
390 NEXT K
399 RETURN

400 REM PLOT MANDELBROT
410 COUNT = I+J*WIDTH
420 POKE 1024+COUNT,160
430 POKE 55296+COUNT,2 AND NOT ISMND
499 RETURN
```

The lines 100 to 120 define the parameters:

- XL and XU the left and right range
- YL and YU the lower and upper range
- REPS the number of steps
- WIDTH and HEIGHT the screen resolution

The 200+ lines define the Main method. Within two loops for width and height, each point is calculated and displayed.

The 300+ lines are responsible for the calculation. Within a loop with the REPS, the calculation is performed. If the result is greater than 4, the point is outside the Mandelbrot Set. The blog post explains what it is about the 4.

The output is in the 400+ lines. `POKE 1024+COUNT,160` sets a filled  character on the screen and the Color RAM starts from memory location 55296 (0xD800). This is where the color is set.

## iOS with C64 BASIC and Mandelbrot Set

For the Mandelbrot Set example, I used my [C64-BASIC-iOS-emu6502-cbm] example. But when I execute the example, not much happens, because the program writes directly to the screen RAM. The interpreter only outputs text without showing what is really visible on the monitor. For this reason, I have extended the [Emu6502Cbm] iOS framework to read the memory from the C64 with `readRam` and `writeRam`.

![C64 BASIC Manndelbrot Set as text](/images/mandelbrot_c64_basic_text.png)

Within the iOS application, I read the color values from the memory location 55296 and then printed them as text — all black dots as star and all others as dot. The image shows the typical Mandelbrot Set — but it doesn't look that great. I used a mono font and adjusted the colors a bit, but I need another app. Let's take a look at the iOS implementation.

## C64 Mandelbrot Set App

Printing the Mandelbrot Set only as text looks good only in the first moment. Something with graphics will look better. But I have to consider that I only have a resolution of 40x25, which is less pixels than a browser favicon has.

The two colors are also very boring. If you look in the internet for Mandelbrot Set pictures, they have these nice colors, especially at the edges. The first step is to increase the colors.

### Adaptations

As the C64 supports 16 colors, I have adapted the code a bit, so that all 16 colors are used. You can say what you want, but I just append these three lines to the listing, and I have both the original code and the modifications. But as I said before, BASIC is not exactly a clear language.

```BASIC
310 ISMND = 0
370 : IF (RZ*RZ + IZ*IZ)>4 THEN ISMND=K:K=REPS
430 POKE 55296+COUNT,ISMND
```

This is the output on the VICE emulator, which is slow, even when I set the emulator speed to _warp_. The output on the iPhone is much faster with the same code.

![16 color Mandelbrot Set](/images/mandelbrot_c64_16colors.png)

### C64 Boot Time

In contrast to the Lua example, where the interpreter only has to be started, the C64 Emulator first has to start the C64 system or even boot it. The Kernal ROM and Basic ROM are loaded and the C64 BASIC is executed, so that the user can execute a program. But this means that I have to wait until the whole system is booted and then I can set the parameters and execute the code. But this is just necessary the first time.

I read the value at the first position of the 5th line and when it is 18 the C64 is started. 18 is the 'R' of 'READY'. The [Character set] is something different in the C64 than in the [ASCII] character set.

After the C64 is started I can set the parameters and start the Mandelbrot Set program.

### Program End

How do I determine when a BASIC program is finished? That depends on the program, of course. If I am just waiting for a result, I can check the text output or a memory location. For continuous values, like the Mandelbrot Set calculation, I can check the last value. But the easiest way is to write the status with `POKE` into a memory location and read this value within the iOS application:

- Program started
- Program runs
- Program finished

### Graphical Output

For the output, I thought I would display the 40x25 characters as large dots. This will fill the whole screen. The single dots are displayed point by point and depending on the value in different color or brightness. The display is created as one big image, integrated in a ScrollView in SwiftUI.

The Mandelbrot Set program writes directly into the Color RAM. But this is handled specially, so I can't really read the value that is written. For the example shown at the beginning, I get the values 240 and 242, so I write the result to memory location 38000.

```BASIC
430 POKE 38000+COUNT,ISMND
```

The output with the big dots looks like this:

![C64 Mandelbrot Set 1st run](/images/mandelbrot_c64_app_run1.png)

To represent different areas within the Mandelbrot Set, I thought that if I double-tapped on the image, I would calculate a new representation. For this I have to pass the parameters to the BASIC application.

### Parameters

I have thought of two ways to pass the parameters. Either in the BASIC code, so that I can pass the parameters `xl` and `xu` as shown in the following example:

```Swift
let param = "100 XL = \(xl):XU = \(xu)"
```

This is easy, almost too easy, because I can transfer double values without any problems. But the BASIC code becomes more confusing and I don't want to deal with a template engine.

With the second variant I write the parameters into memory and the C64 program reads them at the beginning. But the memory can only store 8Bit values. However, the parameters for the Mandelbrot Set are floating-point values.

I divide each parameter value into 8 bytes. The 8th bit in the first byte signals the negative value, if the bit is set, then the value is negative. The remaining bits and bytes I use for the floating-point value. For this I divide the value by 1 and store the integer value. Then I multiply the rest (the decimal places) by 256 and store the integer value in the next memory location. Then I multiply the 256 by 256 (=65536) and with this value I multiply the remaining value, store the integer and repeat this until all 8 bytes are calculated.

I store these values for all parameters in the C64 memory. Then I start the C64 BASIC program that reads the memory and converts the parameters into floating-point values. Thereby the application divides the values by 1, 256, 65536, and so on. If the eighth bit in the first byte is set, then it is a negative value and the program multiplies the result with -1.

Now the Mandelbrot Set calculation can be started by jumping to line 120, otherwise the program will overwrite the parameters, defined by line 100 and 110.

Here is an example for the parameters `xu=-0.6`, `xl=-0.5`, `yu=-0.6`, `yl=-0.7` and `reps=40`.

![C64 Mandelbrot Set 2nd run](/images/mandelbrot_c64_app_run2.png)

## 6502 — No Multiplication

The 6502 of the C64 has no multiplication opcode (machine code). This is done with software, bit shifting and addition of numbers. You have to keep in mind that the 6502 was released in 1975. The 8087, an FPU (floating-point unit) 1980 — five years later. This was a co-processor, specialized in mathematical operations and floating-point calculation. At that time, it was an expensive co-processor, which existed until 80464 as 80467. Today nobody worries about the fact that a multiplication is not part of a processor and the calculations of floating-point numbers are done within hardware.

As you can see in the example code above, the Mandelbrot Set calculation uses many multiplications. The code for the [Floating multiplication and division] is in ROM at position 0xBA2B. I have checked at this point how often the Mandelbrot Set calculation calls the multiplication. It is 96735 times for all 1000 points, so about 96-97 times per point.

But much more interesting is the comment `SLOW AS A TURTLE !` 🐢 at the position 0xBA89. This position is called over 2.8 million (2829335) times during the calculation, so more than 2800 times per point. For this reason, you can see how the application draws each point one by one — this is very relaxing.

## Summary

I did not use the Mandelbrot Set example because it runs very fast on a C64 BASIC emulator. Rather the opposite, because it runs slower and you can see the calculation and the processes. I can watch almost every single point and see if it is part of the Mandelbrot Set or not. With the following code line you can see how the dot gets lighter and lighter and then maybe disappears.

```BASIC
321 POKE 38000+(I+J*WIDTH),K
```

BASIC was my first programming language, although I don't want to say that it is an ideal beginner programming language. Maybe a modern Basic? __In your opinion, what would be a beginner programming language?__

The iOS framework with the C64 BASIC emulators is a nice playground. I uploaded the source code for the Mandelbrot Set calculation into the [C64-BASIC-iOS-emu6502-cbm] project on Github. The project was exciting, the parameter passing interesting and let's see what I do next ... stay tune.

[Wikipedia: Mandelbrot Set]: https://en.wikipedia.org/wiki/Mandelbrot_set
[C64 BASIC on iOS]: /2020/05/22/c64-basic-on-ios/
[I did with Lua]: /2019/12/27/lua-and-swift-in-ios/
[datasette]: https://en.wikipedia.org/wiki/Commodore_Datasette
[factor calculation]: /2019/12/29/factorial-calculation-with-lua-and-swift/
[The Art of Code]: https://www.youtube.com/watch?v=6avJHaC3C2U
[Dylan Beattie]: https://dylanbeattie.net/
[TNG Big TechDay]: https://www.tngtech.com/en/tng-about-us/bigtechday/big-techday-13.html
[How to simply create the Mandelbrot Set on the Commodore 64]: https://semioriginalthought.blogspot.com/2012/04/how-to-simply-create-mandelbrot-set-on.html
[C64-BASIC-iOS-emu6502-cbm]: https://github.com/choas/C64-BASIC-iOS-emu6502-cbm
[Emu6502Cbm]: https://github.com/choas/C64-BASIC-iOS-emu6502-cbm/tree/master/Emu6502Cbm
[Character set]: https://www.c64-wiki.com/wiki/Character_set
[ASCII]: https://en.wikipedia.org/wiki/ASCII
[floating-point unit]: https://en.wikipedia.org/wiki/Floating-point_unit
[Floating multiplication and division]: https://www.pagetable.com/c64ref/c64disasm/#BA2B
