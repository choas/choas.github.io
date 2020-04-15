---
layout: post
title:  Munich RISC-V First Meetup
date:   2020-03-02 21:44 +0100
image:  startup-593341_1280.jpg
credit: https://pixabay.com/de/photos/start-start-up-menschen-593341/
tags:   meetup RISC-V
---

> RISC-V (pronounced "risk-five") is a free and open ISA enabling a new era of processor innovation through open standard collaboration. […] Born in academia and research, the RISC-V ISA delivers a new level of free, extensible software and hardware freedom on architecture, paving the way for the next 50 years of computing design and innovation. — [About RISC-V Foundation](https://riscv.org/risc-v-foundation/)

The [Munich RISC-V First Meetup](https://www.meetup.com/Munich-RISC-V-Meetup-Group/events/268318683/) was last week. I had looked at RISC-V some time ago, but when [Chris Lattner](https://en.wikipedia.org/wiki/Chris_Lattner) went to SiFive earlier this year, I took a closer look at RISC-V. Chris Lattner is known for LLVM, Clang, Swift, Xcode and [other 😎 stuff](http://www.nondot.org/sabre/Resume.html).

The Meetup was great. Of course, there was a brief overview of RISC-V, including the Instruction Set Architecture (ISA) and Physical Memory Protection. A list of RISC-V books (see also [RISC-V Books](https://riscv.org/risc-v-books/)):

- Computer Organization and Design RISC-V Edition: The Hardware Software Interface ([Amazon](https://www.amazon.com/dp/0128122757), ISBN-13: [978-0128122754](https://en.wikipedia.org/wiki/Special:BookSources/978-0128122754))
- The RISC-V Reader: An Open Architecture Atlas ([Amazon](https://www.amazon.com/dp/0999249118), ISBN-13: [978-0999249116](https://en.wikipedia.org/wiki/Special:BookSources/))
- Computer Architecture: A Quantitative Approach ([Amazon](https://www.amazon.com/dp/0128119055%0A), ISBN-13: [978-0128119051](https://en.wikipedia.org/wiki/Special:BookSources/978-0128119051%0A))

… and some lightning talks:

- [OpenTitan](https://opentitan.org/)
- Alexander Zeh about [MiG-V](https://wordpress.hensoldtcyber.de/mig-v/): The First Logically Obfuscated 64-bit RISC-V Core For [seL4](https://en.wikipedia.org/wiki/L4_microkernel_family#High_assurance:_seL4)
- Sven Beyer about Proving Your RISC-V Design Correct: [OneSpin RISC-V Formal Verification](https://www.onespin.com/solutions/risc-v) completely verifies RISC-V Core RTL implementations with full proofs.
- A [Universal Sensor Plattform (USeP)](https://www.forschungsfabrik-mikroelektronik.de/en/Range_Of_Services/Technologies/extended-cmos/USeP.html) for IIoT and Edge Devices
- How to run Linux on RISC-V (see also [FOSDEM’20](https://fosdem.org/2020/schedule/event/riscv_fpga/)) … on a $13 [Sipeed MAix BiT](https://www.seeedstudio.com/Sipeed-MAix-BiT-for-RISC-V-AI-IoT-p-2872.html)
- [Renode](https://renode.io/): an open source framework to scale the RISC-V

## Renode

I am very enthusiastic about Renode, therefore I list a few points from the presentation and a few additional links I found:

- entire SoC complex, with I/O like USB, PCIe, CAN, I2C, SPI, GPIO, … (see also [Microsemi Mi-V example](https://renode.readthedocs.io/en/latest/tutorials/miv-example.html))
- used by Amazon FreeRTOS team (see also [AWS Announces RISC-V Support in the FreeRTOS Kernel](https://aws.amazon.com/about-aws/whats-new/2019/02/aws-announces-riscv-support-freertos-kernel/) and [Using FreeRTOS on RISC-V Microcontrollers](https://www.freertos.org/Using-FreeRTOS-on-RISC-V.html))
- potential for onboarding customers into FreeRTOS without hardware
- primary development platform, IDE integration
- Dornerworks seL4 porting used Renode to port to RISC-V (see also [Using Renode To Build Secure Products On The seL4 Microkernel and RISC-V Architecture](https://dornerworks.com/news/using-renode-to-build-secure-products-on-the-sel4-microkernel-and-risc-v-architecture))
- Zephyr relies on Remonde for testing its TSN subsystem (see also [Testing Zephyr PTP support](https://renode.readthedocs.io/en/latest/tutorials/zephyr-ptp-testing.html))

… and Renode does not only simulate RISC-V processors.

## Summary

It was an overall very well done meetup where I learned a lot. I have ordered a Sipeed Mix BiT and look into Renode. I am already curious about the 2nd Meetup. Thanks also to [Andes Technology](http://www.andestech.com/en/about-andes/) and the [Munich University of Applied Sciences](https://www.hm.edu/) for supporting the Meetup.
