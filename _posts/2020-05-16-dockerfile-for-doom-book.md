---
layout: post
title:  Dockerfile for Doom Book
date:   2020-05-16 16:19 +0200
image:  old-books-436498_1280.jpg
credit: https://pixabay.com/de/photos/alte-b%C3%BCcher-buch-alte-bibliothek-436498/
tags:   dockerfile doom
---

> Doom is a 1993 first-person shooter developed by id Software for MS-DOS. Players assume the role of a space marine, popularly known as "Doomguy" ... -- [Wikipedia: Doom](https://en.wikipedia.org/wiki/Doom_(1993_video_game))

[@sylefeb](https://twitter.com/sylefeb) tweeted about his [Doom on FPGA](https://twitter.com/sylefeb/status/1258808333265514497) project and [mentioned](https://twitter.com/sylefeb/status/1258809057739235328) the [Game Engine Black Book: Doom](https://fabiensanglard.net/gebb/index.html) from [Fabien Sanglard](https://fabiensanglard.net/), who provided the [LateX source code](https://github.com/fabiensanglard/gebbdoom) of the book.

You can download the PDF (and give a gift 🎁) or buy the book. But why not generate the PDF yourself? However, I didn't want to install the necessary software directly and therefore I wrote a Dockerfile:

```Docker
FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    inkscape texlive texlive-font-utils texlive-latex-extra \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /build
VOLUME [ "/build" ]
WORKDIR /build

CMD ./make.sh
```

These are the things the Dockerfile do:

- Use Ubuntu 18.04 (see tkz-obj-angles.tex).
- A package wants to interact with me, but I don't want to, so I added the `ARG` command.
- Install all necessary packages.
- Create a build directory to mount a volume.
- Run make.sh to generate the PDF.

This is how the Docker image is built:

```bash
docker build -t choas/gebb .
```

To generate the book go to the root path of the documents and run the Docker image. You need to mount the actual path (_$PWD_):

```bash
docker run --volume $PWD:/build choas/gebb
```

This take some time and you will find the book in the `output` folder of the current path. The docker image works not only for Doom, but also generates the [Game Engine Black Book: Wolfenstein 3D](https://github.com/fabiensanglard/gebbwolf3) book.

## tkz-obj-angles.tex

First I used Ubuntu 20.04, but this version installs newer latex packages. This resulted in an error that complained about tkz-obj-angles.tex. One of these packages is tkz-euclide and since version 3.02 _\usetkzobj{all}_ is no longer necessary. See also [LaTeX can't find file 'tkz-obj-angles.tex'](https://tex.stackexchange.com/questions/529550/latex-cant-find-file-tkz-obj-angles-tex/529562#529562).

## Summary

With this Dockerfile you can generate the Doom and Wolfenstein 3D books. In case you don't want to build it yourself, I have pushed the image to docker hub: [choas/gebb](https://hub.docker.com/repository/docker/choas/gebb)

I have also created a [pull request](https://github.com/fabiensanglard/gebbdoom/pull/27) and an [issue about tkz-obj-angles.tex](https://github.com/fabiensanglard/gebbdoom/issues/28).
