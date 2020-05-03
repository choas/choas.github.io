---
layout: post
title:  Dockerfile FROM AS — C64 Emulator
date:   2020-05-02 00:19 +0200
image:  commodore-528139_1280.jpg
credit: https://pixabay.com/de/photos/commodore-c-64-computer-tastatur-528139/
tags:   docker c64
---

> The Commodore 64, also known as the C64 or the CBM 64, is an 8-bit home computer introduced in January 1982 by Commodore International -- [Wikipedia: Commodore 64]

First, I looked at C64 emulators for STM32 boards and found a project: [Commodore 64 for STM32F429 Discovery board]. This project shows on the LCD display of a DISCO STM32F429ZI the output from a C64 emulator. Unfortunately, I do not have this board. Therefore, I looked at another project by Dave Van Wagner, where I can access a STM32 board (e.g. [NUCLEO STM32F401RE]) via a serial connection, on which a C64 emulator is running: [c-simple-emu6502-cbm]

![C64 emulator in terminal](/images/c-simple-emu-cbm.png)

Kinda cool 😎, a board with USB, a serial connection, the background color of a terminal window in blue and I can write some BASIC like on a C64:

```BASIC
10 PRINT "HELLO C64"
20 GOTO 10
RUN
```

I adapted the code of the C64 emulator a bit, because the C64 understood the commands (BASIC token) only in capital letters. I don't know if the C64 knew lower case letters?

## C64 Docker Image

Then I asked myself, if there is a docker image for a C64 emulator. Of course, there is at least one image: [docker-c64]

![C64 Emulator in Docker](/images/c64-docker.png)

I looked at the [Dockerfile] of this project and discovered something interesting: [FROM AS]

I never noticed this before. Maybe it's because I always think about which base image, I use for the docker file (e.g. alpine, ubuntu). I have never looked at the 'FROM' and its possibilities. With the 'AS' parameter you can e.g. create a build image containing the compiler and the necessary libraries. For the final image you can use `COPY --from` to get the compiled files.

I have adapted the Dockerfile in the [TinyMUSH] posting. This reduced the size of the docker image from 435 MByte to 80.2 MByte. It has only 1/5 of the original size.

## Summary

FROM AS is a way to reduce the image size when you create a Docker image and compile it.

By the way, I didn't have a C64 in the past, but a [CPC 464] from Schneider, built by Amstrad.

BASIC is so 🤓 with the line numbers and GOTOs you can write [Spaghetti code] 🍝 in less than 3 minutes:

```BASIC
1 A = 1
5 GOTO 15
10 PRINT "  FINE!"
12 IF A>7 THEN 20
15 PRINT "HOW ARE YOU?"
17 A=A+1
18 GOTO 10
20 PRINT "END"
```

## Update

I got a note ([@mmaciaszek Tweet]), that there is a Commodore Basic for the command line: [cbmbasic]

[Wikipedia: Commodore 64]: https://en.wikipedia.org/wiki/Commodore_64
[Commodore 64 for STM32F429 Discovery board]: https://techwithdave.davevw.com/2020/04/commodore-64-for-stm32f429-discovery.html
[NUCLEO STM32F401RE]: https://www.st.com/en/evaluation-tools/nucleo-f401re.html
[c-simple-emu6502-cbm]: https://github.com/choas/c-simple-emu6502-cbm
[docker-c64]: https://github.com/floooh/docker-c64
[Dockerfile]: https://github.com/floooh/docker-c64/blob/master/Dockerfile
[BASIC token]: https://www.c64-wiki.com/wiki/BASIC_token
[TinyMUSH]: /2020/04/14/dvorak-game-tinymush/
[CPC 464]: https://en.wikipedia.org/wiki/Amstrad_CPC_464
[FROM AS]: https://docs.docker.com/engine/reference/builder/#from
[Spaghetti code]: https://en.wikipedia.org/wiki/Spaghetti_code
[@mmaciaszek Tweet]: https://twitter.com/mmaciaszek/status/1256576102530719744
[cbmbasic]: https://github.com/mist64/cbmbasic
