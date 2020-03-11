---
layout: post
title:  AWS IoT Service Deep Dive Meetup
date:   2020-03-08 20:10 +0100
image:  speaker-2371550_1280.jpg
credit: https://pixabay.com/de/illustrations/lautsprecher-wireless-internet-iot-2371550/
tags:   Meetup AWS-IoT
---

> FreeRTOS is an open source, real-time operating system for microcontrollers that makes small, low-power edge devices easy to program, deploy, secure, connect, and manage. -- [Amazon FreeRTOS](https://aws.amazon.com/freertos/)

The Internet of Things Meetup was on Wednesday:
[AWS IoT Service Deep Dive with Vestner @ AWS Munich](https://www.meetup.com/IoTMunich/events/267957639/)

First, Philip Sacha from AWS gave a deep dive into the AWS IoT services landscape. Then Vestner, who builds elevators, gave an overview on how they use the AWS IoT services.

## AWS IoT services

The AWS IoT architecture is divided into three groups (see also [Amazon IoT - What we offer](https://aws.amazon.com/iot/#What_we_offer)):

- Device Software
- Connectivity & Control Services
- Analytics Services

Device Software consists of

- [Amazon FreeRTOS](https://aws.amazon.com/freertos/)
- AWS IoT Device SDK
- [AWS IoT Greengrass](https://aws.amazon.com/greengrass/)

FreeRTOS 👀 again, which I already mentioned at the [RISC-V Meetup](/2020/03/02/munich-risc-v-first-meetup/) last week. I (also) ordered a [ESP-WROVER-KIT](https://devices.amazonaws.com/detail/a3G0L00000AANtlUAH/ESP-WROVER-KIT) for FreeRTOS to play with FreeRTOS in the future: [Getting Started with the Espressif ESP32-DevKitC and the ESP-WROVER-KIT](https://docs.aws.amazon.com/freertos/latest/userguide/getting_started_espressif.html)

The following picture shows an overview of IoT with AWS: ![IoT with AWS](/images/AWS_IoT.jpg)

## Summary

It was an informative Meetup where I learned about [What Is AWS IoT?](https://docs.aws.amazon.com/iot/latest/developerguide/what-is-aws-iot.html)
