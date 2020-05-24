---
layout: post
title:  C64 BASIC — How I fixed RND
date:   2020-05-24 12:53 +0200
image:  cube-568193_1280.jpg
credit: https://pixabay.com/de/photos/w%C3%BCrfel-spielw%C3%BCrfel-augenzahl-zahlen-568193/
tags:   C64 pseudorandom
---

> A pseudorandom number generator (PRNG), also known as a deterministic random bit generator (DRBG), is an algorithm for generating a sequence of numbers whose properties approximate the properties of sequences of random numbers. — [Wikipedia: Pseudorandom number generator](https://en.wikipedia.org/wiki/Pseudorandom_number_generator)

I describe in this blog post how I adapted a BASIC example, but also the code for an RND function of an emulator. The c-simple-emu6502-cbm project has the guess2 example. You have to guess a number between 1 and 100. If the number you enter is too high, you get a hint, if it is too low you get a hint as well. When you have found the number, the number of guesses is shown, and you can guess a new number.

Here is the original code:

```BASIC
10 PRINT "I'm thinking of a number between 1 and 100"
15 C=0
20 X=INT(RND(1)*100+1)
25 G=0
30 PRINT "GUESS";:INPUT G
40 IF G<=0 OR G>=100 OR G<>INT(G) THEN PRINT "TRY AGAIN":GOTO 30
50 C=C+1
60 IF G=X THEN PRINT "YOU GUESSED IN "C" TRIES":GOTO 10
70 IF G<X THEN PRINT "TOO LOW, TRY HIGHER"
80 IF G>X THEN PRINT "TOO HIGH, TRY LOWER"
90 GOTO 30
```

This example has two bugs:

- 100 is not possible as input.
- The program comes up with the same “random” numbers.

## 100 is not possible

This is a simple bug. In line 40 it should be `G>100` instead of `G>=100`, otherwise 99 is the last valid number, but 100 could be a possible number to guess.

## Pseudo Random Numbers

When I run the following for loop in a fresh started cbmbasic, c-emu6502-cbm or VICE instance I’ll get the following five numbers. This happens every time — when I restart the C64 BASIC interpreter.

```BASIC
FOR I=1 TO 5: PRINT INT(RND(1)*100+1): NEXT
 19
 5
 83
 56
 90
```

Do you know the games or tests where you have some numbers and you should come up with the next number? __So what is the next number?__ If you want, you can guess the number 🤔 and answer on this [tweet] or send me a direct message. I will answer (manually) with 'too high' or 'too low'.

Maybe you have already found a pattern with these five numbers and know more than 19, lower, higher, lower, higher? Another possibility is to know the algorithm behind this pseudo random number generation. The [Ultimate Commodore 64 BASIC & KERNAL ROM Disassembly](https://www.pagetable.com/c64disasm/) document has some sources that explain the C64 BASIC assembler code, including the algorithm of the [RND](https://www.pagetable.com/c64ref/c64disasm/#E08D) function:

```assembler
;PSUEDO-RANDOM NUMBER GENERATOR.
;IF ARG=0, THE LAST RANDOM NUMBER GENERATED IS RETURNED.
;IF ARG .LT. 0, A NEW SEQUENCE OF RANDOM NUMBERS IS
;STARTED USING THE ARGUMENT.
;   TO FORM THE NEXT RANDOM NUMBER IN THE SEQUENCE,
;MULTIPLY THE PREVIOUS RANDOM NUMBER BY A RANDOM CONSTANT
;AND ADD IN ANOTHER RANDOM CONSTANT. THE THEN HO
;AND LO BYTES ARE SWITCHED, THE EXPONENT IS PUT WHERE
;IT WILL BE SHIFTED IN BY NORMAL, AND THE EXPONENT IN THE FAC
;IS SET TO 200 SO THE RESULT WILL BE LESS THAN 1. THIS
;IS THEN NORMALIZED AND SAVED FOR THE NEXT TIME.
;THE HO AND LOW BYTES WERE SWITCHED SO THERE WILL BE A
;RANDOM CHANCE OF GETTING A NUMBER LESS THAN OR GREATER
;THAN .5 .
```

### RND

But how do I get a different random value? As you can read in the above comment about the RND function and also in the [C64 Wiki: RND](https://www.c64-wiki.com/wiki/RND), the RND function starts a new sequence of random numbers when it receives a negative parameter. I use -23 as parameter, but for the guess example nothing really changes. The application asks for different numbers, but always the same ones.

```BASIC
X=RND(-23):FOR I=1 TO 5: PRINT INT(RND(1)*100+1): NEXT
 93
 83
 91
 2
 31
```

In the [C64 Wiki: RND](https://www.c64-wiki.com/wiki/RND) you can see the entry `X = RND(-TI)`, where `TI` is the `TIME` variable. The negative value restarts the random sequence and since the timer always has a different value, the random sequence is also different at each start. For this I add a 19th line to the guess2 BASIC program:

```BASIC
19 X=RND(-TI)
```

This works for the cbmbasic project, but not for the c-simple-emu6502-cbm project. Why?

cbmbasic returns e.g. the value 3704360 for `PRINT TI` and this value changes every time. The c-simple-emu6502-cbm project, on the other hand, always returns 0.

A look at the [Ultimate Commodore 64 BASIC & KERNAL ROM Disassembly](https://www.pagetable.com/c64disasm/) documentation shows at the ROM address [0xE09C](https://www.pagetable.com/c64ref/c64disasm/#E09C) of the RND function that when _0_ is passed as a parameter, the timer is called to use its value. Like in the [C64 Wiki: TIME](https://www.c64-wiki.com/wiki/TIME), this has something to do with the [CIA (Complex Interface Adapter)](https://www.c64-wiki.com/wiki/CIA), whose values can be read at 0xDC00.

## Bug 3: RND(-TI) / RND(0)

To have a closer look at it I set a breakpoint in the C64-BASIC-iOS-emu6502-cbm app when reading the memory. The breakpoint is at line 334 of the `GetMemory` function with a condition to stop when `addr` equals 0xDC04. This is the 'TIMER A' address of the CIA interface. I ran `X=RND(0)` and the debugger stopped. Then I went through the code step by step and found out that the `GetMemory` function returns 0 at the end. Problem found and to solve it I return for the memory addresses 0xDC04, 0xDC05, 0xDC08 and 0xDC09 some bits from the `TIME` C function. Therefore `RND(0)` will have a different value.

## Bug 4: TIME$

Let's go back one step; the reason why `RND(-TI)` doesn't work is because `TI` returns the value 0 and this causes `RND` to be called with 0. `RND(0)` again reads the values from the CIA interfaces, but all of them return 0 — before I fixed it.

What happens if `-TI` returns the time? `RND(-TI)` would already be initialized with the time value and would immediately provide a different random sequence without calling `RND(0)`.

### RDTIM

A look into the [Ultimate Commodore 64 BASIC & KERNAL ROM Disassembly](https://www.pagetable.com/c64disasm/) documentation shows at the position [0xF6DD](https://www.pagetable.com/c64ref/c64disasm/#F6DD) the _RDTIM_ (read real time clock) function, which writes three values from the [TIME](https://www.pagetable.com/c64ref/c64mem/#TIME) address into the registers A, X and Y. The _TIME_ address is located at the RAM position 0x00A0 to 0x00A2 (see _software jiffy clock, updated by KERNAL IRQ every 1/60 second_ at the [Zeropage](https://www.c64-wiki.com/wiki/Zeropage)).The cbmbasic project has already implemented the [calculation of the values](https://github.com/choas/C64-BASIC-iOS-cbmbasic/blob/master/Cbmbasic/CbmBasic/Dependencies/cbmbasic/runtime.c#L769). I just have to look inside the `GetMemory` function if address 0x00A2 is read and then write the time data into the corresponding RAM. The `GetMemory` function returns the appropriate values.

As a result, `PRINT TIME$` writes the current time in the format _HHMMSS_. Also the `RND` function with the call `RND(-TI)` gets the current time and can return random values.

## Summary

As I already wrote in my previous C64 blog post, I really like to look at the assembler code of the C64 and 6502. The book [Ultimate Commodore 64 BASIC & KERNAL ROM Disassembly](https://www.pagetable.com/c64disasm/) is a nice collection of the C64 BASIC and ROM code.

I created a [pull request](https://github.com/davervw/c-simple-emu6502-cbm/pull/1) for the c-simple-emu6502-cbm project and also [adapted my iOS app](https://github.com/choas/C64-BASIC-iOS-emu6502-cbm/commit/498cf168c50c22cee39757e291d2f88da9d9212a). You can read more about [Random Numbers - In Machine Language For Commodore 64](https://www.atarimagazines.com/compute/issue72/random_numbers.php) or take a look to [Commodore’s “Inner Space”](http://www.mos6502.com/commodore-tech-corner/commodores-inner-space/) to see some ICs.

... and don’t forget to guess the number on this [tweet].

[tweet]: https://twitter.com/choas/status/1264510983453782018
