---
layout:  post
title:   Load Average on 7-Segment
date:    2020-10-18 13:09 +0200
image:   truck-1030846_1280.jpg
credit:  https://pixabay.com/de/photos/lkw-transport-logistik-1030846/
excerpt: Displaying the load average of a Raspberry Pi on AlphaNum display via I2C
---

> I2C (Inter-Integrated Circuit), pronounced I-squared-C, is a synchronous, [...], packet switched, single-ended, serial communication bus invented in 1982 by Philips Semiconductor (now NXP Semiconductors) –– [Wikipedia: I2C](https://en.wikipedia.org/wiki/I%C2%B2C)

I have setup a Raspberry Pi and it is right next to me. Therefore I thought I show the load average of the Raspberry Pi on an [alphanumeric display](https://www.adafruit.com/product/2157) from Adafruit which is controlled by I2C.

![Photo Raspberry Pi and AlphaNum](/images/photo_raspberry_pi_alphanum.jpg)

## Raspberry Pi Setup

First activate I2C. I use [raspbian](https://www.raspberrypi.org/downloads/raspberry-pi-os/), which is now called Raspberry Pi OS. For this I use `sudo raspi-config` and activate I2C under _5 Interfacing Options_. Take a look at this manual: [Configuring I2C on the Raspberry Pi](https://pimylifeup.com/raspberry-pi-i2c/)

Then install the _i2c-tools_ library:

```bash
sudo apt install -y i2c-tools
```

… and, since I have setup the Raspberry Pi fresh, I still need _pip3_:

```bash
sudo apt-get -y install python3-pip
```

## Connect AlphaNum Display

The AlphaNum display uses I2C. Here you can see the [Raspberry Pi I2C Pinout](https://pinout.xyz/pinout/i2c#). The display must be connected as follows:

![I2C Raspberry Pi AlphaNum](/images/led_matrices_raspberry-pi-alphanum_bb.jpg)

A manual 📃 is available here: [Python Wiring and Setup](https://learn.adafruit.com/adafruit-led-backpack/0-54-alphanumeric-python-wiring-and-setup)

## Test I2C

With `sudo i2cdetect -y 1` you should see this output:

```text
     0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
00:          -- -- -- -- -- -- -- -- -- -- -- -- --
10: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
20: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
30: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
40: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
50: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
60: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
70: 70 -- -- -- -- -- -- --
```

The display uses address 0x70.

## Source Code

First we need the Python libraries:

```bash
pip3 install adafruit-circuitpython-ht16k33
```

The program imports some libraries and initializes the AlphaNum display using Seg14x4. Seg7x4 is for a 7-segment display. Then the display is cleared and the brightness set.

```python
import time
import board
import busio
import os
from adafruit_ht16k33 import segments

# Create the I2C interface.
i2c = busio.I2C(board.SCL, board.SDA)

# Create the LED segment class.
# This creates a 14 segment 4 character display:
display = segments.Seg14x4(i2c)

# Clear the display.
display.fill(0)

# set brightness, range 0-1.0, 1.0 max brightness
display.brightness = 0.1

while True:
  load1, load5, load15 = os.getloadavg()
  text = " {load:.2f}"
  display.print(text.format(load = load1))
  time.sleep(1)
```

In the while loop the load average values 1, 5, and 15 are read every second. I convert the _load1_ value into a text and send it to the display.

## Summary

As I have an alphanumeric display and not only a 7-segment display, it could display some text. The [14-Segment Alphanumeric Display example](https://learn.adafruit.com/matrix-7-segment-led-backpack-with-the-raspberry-pi/14-segment-alphanumeric-display)  shows a scrollable text.
I could also set up a REST server and you can send me some messages …
