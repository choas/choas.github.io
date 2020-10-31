---
layout:  post
title:   Raspberry Pi and Docker
date:    2020-10-31 09:29 +0100
image:   forklift-835340_1280.jpg
credit:  https://pixabay.com/de/photos/gabelstapler-lagerhaus-maschine-835340/
tags:    docker raspberry-pi
excerpt: If the Raspberry Pi should say goodbye, I only need to know how to start the Docker image.
---

> Opposed to most other Linux distributions, Raspberry Pi is based on ARM architecture. Hence, not all Docker images will work on your Raspberry Pi. — [How to Install Docker on Raspberry Pi](https://phoenixnap.com/kb/docker-on-raspberry-pi)

I have already shown how I installed Docker on a Raspberry Pi in my blog post [irssi on Raspberry Pi with Docker](/2020/04/18/irssi-on-raspberry-pi-with-docker/). But why do I install Docker on a Raspberry Pi?

The advantage of Docker is that the program runs in a closed environment. Necessary libraries do not affect the main system and other applications. This allows you to use newer libraries on an older Linux distribution.
Additionally, all necessary steps are described in a Docker file or image. Didn't you just want to try a program and then had to compile a library and search the Internet for a solution to an error message?

If the Raspberry Pi should say goodbye 👋, I only need to know how to start the image and, as in the case of Irssi, I also need a configuration file.
This is very interesting for those programs that cannot be installed directly via apt-get. Either there is already a Docker image, or a Dockerfile that describes the dependencies, like the [C64 Dockerfile](https://github.com/floooh/docker-c64/blob/master/Dockerfile) or [Dockerfile for Doom Book](/2020/05/16/dockerfile-for-doom-book/).

## Install Docker

[How to Install Docker on Raspberry Pi](https://phoenixnap.com/kb/docker-on-raspberry-pi) is a great tutorial. I have listed the commands here in case the page does not work anymore:

```bash
sudo apt-get update && sudo apt-get upgrade
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker pi
```

An update and upgrade are always good, especially if you just installed the Raspberry Pi. The get.docker.com site provides a shell script that also works on the Raspberry Pi and installs Docker. Finally, I add the `pi` user to the `docker` group.

## Test Docker

I’ve rebooted the Raspberry Pi. For testing Docker, `docker version` and `docker info` should not show any errors:

```bash
docker version
docker info
```

Finally, run the hello-world image:

```bash
docker run hello-world
```

This should output "This message shows that your installation appears to be working correctly", then everything has worked.

In my previous blog post [Load Average on 7-Segment](https://www.larsgregori.de/2020/10/18/load-average-on-7-segment/) I displayed the load average on a 7-Segment display. When installing Docker, the load average goes up to 1.14 but then down to 0.0 again.

### Disk Usage

Since I install Docker images and the SD card has only a limited space, I now show the free disk space on the AlphaNum display. On StackOverflow there is (of course) an example for Python: [Get actual disk space of a file](https://stackoverflow.com/a/7285509)

Every 10 seconds it shows the free space by showing a 'd' at the first display and a 'l' for the Load.

What else can I display? Any ideas?

## Summary

Now I have a fresh Raspberry Pi with Docker. Another advantage of Docker is the possibility to delete the Docker image with all dependencies. This allows me to simply try out an image. It takes a while, but I can see on the 7-segment display when the Docker image is ready when the load average goes down.

Any comments? Write me on Twitter [@choas](https://twitter.com/choas) (DM is open).
