---
layout: post
title:  Programming an ATTiny85 with an Arduino
date:   2020-02-20 20:28 +0100
image:  board-453758_1280.jpg
credit: https://pixabay.com/de/photos/platine-elektronik-computer-453758/
tags:   attiny85 arduino
---

> A microcontroller (MCU for microcontroller unit) is a small computer on a single metal-oxide-semiconductor (MOS) integrated circuit chip. -- [Wikipedia: Microcontroller]

As a farewell gift for a colleague who is also a fireman, I thought of the following:

- I take a coloring book with a firefighter. In former times _Grisu der kleine Drache_ (Grisu the little dragon) was popular, today it is _Sam der Feuerwehrmann_ (Fireman Sam).
- The book should show a fire truck with blue lights.
- I replace the blue lights with blue LEDs.
- To make it blink, I could use two transistors, [NE555] or simply an ATTiny85.

The [ATTiny85] is a [MCU] similar to an [Arduino], but a bit smaller, with less IO pins and cheaper. It can be programmed, but not as easy as an Arduino, which you just connect to a computer with a USB cable.

![ATTiny85](/images/ATTiny85.png)

The ATTiny85 has 8 pins in total. Two of them are needed for the power supply. That leaves 4 to 5 pins which I can use as output or input. I only need two pins to connect the LEDs and one pin to switch between different flashing modes. I use two wires as a switch and when you touch both the ATTiny85 reacts. I leave the input pin open and if it is more than 1 second _HIGH_ I switch to the next mode.

![ATTiny85 schem](/images/ATTiny85_schem.png)

## Programming ATTiny85

It's not the first time that I program an ATTiny85 and there are also different guides on the internet: [Programming ATtiny85 with Arduino Uno]

What is important?

- proper wiring
- Capacitor
  - observe the polarity
  - do not use it until the Arduino has been programmed as ISP
- the programme

The following picture shows the setup for programming the ATTiny85:
![Programming an ATTiny85 - Setup](/images/ATTiny85_programming_1.jpg)

ATTiny85 programmed and wired for blinking:
![Programming an ATTiny85 - Blink](/images/ATTiny85_programming_2.jpg)

## Flash modes

As you can see in the __[source code]__ I have the following 5 flashing modes:

- both LEDs blink at the same time
- LEDs flash alternately
- LEDs only light
- LEDs are off
- LEDs flash S.O.S.

## Installation

After the ATTiny85 was programmed, I tested it first of course. For this purpose I built the circuit which I also installed in the book.

![ATTiny85 blinking](/images/ATTiny85_blinking.gif)

I put the LEDs through the paper and bent the feet, with the ATTiny85 too. Then I soldered everything with the resistor, added the USB cable and tested it. The USB cable is only for power supply. There are also examples to control [V-USB with ATtiny45 / ATtiny85 without a crystal]. This can be used for example to make the LEDs of the fire engine blink when a tweet with the text "fire" is received.

![ATTiny85 coloring book](/images/ATTiny85_coloring_book.jpg)

## Summary

A simple gift for less than 10 Euros and something to tinker. And the best thing is that many colleagues have perpetuated themselves in the coloring book.

[Wikipedia: Microcontroller]: https://en.wikipedia.org/wiki/Microcontroller
[NE555]: https://en.wikipedia.org/wiki/555_timer_IC
[ATTiny85]: https://www.microchip.com/wwwproducts/en/ATtiny85
[MCU]: https://en.wikipedia.org/wiki/Microcontroller
[Arduino]: https://store.arduino.cc/arduino-uno-rev3
[Programming ATtiny85 with Arduino Uno]: https://create.arduino.cc/projecthub/arjun/programming-attiny85-with-arduino-uno-afb829
[source code]: https://github.com/choas/sam_attiny85/blob/master/SamATTiny85/SamATTiny85.ino
[V-USB with ATtiny45 / ATtiny85 without a crystal]: https://codeandlife.com/2012/02/22/v-usb-with-attiny45-attiny85-without-a-crystal/
