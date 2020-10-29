---
layout:  post
title:   Fawkes — privacy protection
date:    2020-10-29 21:12 +0100
image:   blonde-629726_1280.jpg
credit:  https://pixabay.com/de/photos/blondine-m%C3%A4dchen-einnahme-foto-629726/
tags:    privacy machine-learning
excerpt: Fawkes is "a system that helps individuals inoculate their images against unauthorized facial recognition models. Fawkes achieves this by helping users add imperceptible pixel-level changes (we call them “cloaks”) to their own photos before releasing them."
---

> Fawkes is a privacy protection system developed by researchers at SANDLab, University of Chicago. — [Fawkes](https://pypi.org/project/fawkes/)

Have you seen? The photo on the homepage looks a bit different. I changed the original photo with Fawkes and adjusted the colors with ML, some filters (e.g. sepia) with [Pixelmator Photo](https://www.pixelmator.com/photo/).

![new profil picture](/images/01.png)

## Fawkes

Fawkes is "a system that helps individuals inoculate their images against unauthorized facial recognition models. Fawkes achieves this by helping users add imperceptible pixel-level changes (we call them “cloaks”) to their own photos before releasing them."

See also [Fawkes: Protecting Privacy against Unauthorized Deep Learning Models](https://www.shawnshan.com/files/publication/fawkes.pdf)

In this way, known and unknown third parties are restricted from creating face recognition models from publicly available photos. 
If they try to identify you by giving the model an unaltered / "un camouflaged" image of you (e.g. a photo taken in public), the model will not recognize you.

Fawkes is a software tool that runs locally on your computer. Here is the result of a modification and of course I will not show the original picture 🕵️‍♂️:

![me cloaked](/images/fawkes_low_cloaked.jpg)

## Summary

The generation of a fake image takes some time and you can see patches in my face. However, this is not a photo that you want to share. Especially when you compare it with all these photos modified with Photoshop or generated with SnapChat filters.
After I ran some filters over the picture, it doesn't look that bad. Maybe the filters would have been enough, and all the effort wouldn’t be necessary?

Any comments? Write me on Twitter [@choas](https://twitter.com/choas) (DM is open).
