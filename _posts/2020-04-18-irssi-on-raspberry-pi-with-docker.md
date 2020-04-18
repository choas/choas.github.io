---
layout: post
title:  irssi on Raspberry Pi with Docker
date:   2020-04-18 18:03 +0200
image:  colors-1838392_1280.jpg
credit: https://pixabay.com/de/photos/farben-container-industrie-eisen-1838392/
tags:   irssi docker
---

> Irssi is a modular chat client that is most commonly known for its text mode user interface, but 80% of the code isn't text mode specific. Irssi comes with IRC support built in, and there are third party […] protocol modules available. — [Github: irssi](https://github.com/irssi/irssi)

Currently all chat and conference tools are used. Time to reactivate irssi. I have a Raspberry Pi in my network and therefore it would be ideal to be always online. I don't know how old this Raspberry Pi image is and therefore only an old irssi version is installed.

I could update the Raspberry Pi, create a new image or use Docker. The first two options could also be combined with Docker, so I skip them and just install Docker on this old image:

```bash
curl -fsSL https://get.docker.com | sh - && \
usermod -aG docker pi
```

Download Docker, install it and add the docker group to the pi user. This takes some time, so I run `screen`, in case my host goes to sleep 😴.

Docker Hub has an [arm32v7/irssi](https://hub.docker.com/r/arm32v7/irssi) Docker image for the Raspberry Pi. There is also an example how to run this image. I adapted it a bit because I want to write the config file on my Raspberry Pi (and the log files as well).

```bash
docker run -it --name irssi -e TERM -u $(id -u):$(id -g) \
    --log-driver=none \
    -v $HOME/.irssi:/home/user/.irssi \
    -v /etc/localtime:/etc/localtime:ro \
    arm32v7/irssi
```

Now I'm online …
