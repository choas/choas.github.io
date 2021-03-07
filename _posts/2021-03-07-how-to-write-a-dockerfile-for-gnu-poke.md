---
layout:  post
title:   How to write a Dockerfile for gnu-poke
date:    2021-03-07 16:59 +0100
image:   gwen-weustink-C3DTMUL4rgE-unsplash.jpg
credit:  https://unsplash.com/photos/C3DTMUL4rgE
tags:    dockerfile gnu-poke
excerpt: In this blog post I describe how I've created a Dockerfile for gnu-poke.
---

> GNU poke is an interactive, extensible editor for binary data.  Not
limited to editing basic entities such as bits and bytes, it provides
a full-fledged procedural, interactive programming language designed
to describe data structures and to operate on them. -- [gnu-poke](http://www.jemarch.net/poke)

[gnu-poke](http://www.jemarch.net/poke) 1.0 was [released](http://www.jemarch.net/poke-1.0-relnotes.html), but I didn't find a corresponding package for any Linux distribution. So I build my own version and wrote a Dockerfile for it.

## Dockerfile

Bevor I write a Dockerfile I start a docker image, e.g. `docker run -it debian:bullseye /bin/bash`. Then I run all commands inside of the docker image and document each individual step in the Dockerfile.

For gnu-poke I use [Debian bullseye](https://wiki.debian.org/DebianBullseye) as base distribution, because the library _gettext_ should be \>= version 0.21.

```Dockerfile
FROM debian:bullseye
```

The gnu-plot project describes the necessary libraries in two files. In the [DEPENDENCIES](https://git.savannah.gnu.org/cgit/poke.git/tree/DEPENDENCIES) file the description is detailed in the [HACKING](https://git.savannah.gnu.org/cgit/poke.git/tree/HACKING) file with some kind of _prose_📙. But unfortunately, only some of the necessary libraries are described.

I collected all necessary libraries and added them in the Dockerfile:

```Dockerfile
RUN apt-get update
RUN apt-get install -y build-essential \
  libgc-dev libreadline-dev libjson-c-dev tcl-dev tk-dev libnbd-dev \
  gettext pkg-config \
  automake dejagnu flex bison \
  libtool texinfo autopoint help2man gawk \
  git
```

I found the appropriate libraries by trial and error and with the help of the Debian package search (e.g. [gettext](https://packages.debian.org/bullseye/gettext)).

The released tar file does not work. Therefore, I need git and also for the bootstrap call. This call is described in the HACKING file:

```Dockerfile
RUN git clone https://git.savannah.gnu.org/git/poke.git /poke

WORKDIR /poke

RUN ./bootstrap --skip-po
```

Now I can run the usual _configure_ and _make_:

```Dockerfile
RUN mkdir build/ && cd build && ../configure && make && make check
```

To save some space I remove a few libraries. Maybe I can remove more?, but the developers might know it better ;)

```Dockerfile
RUN apt-get remove -y build-essential \
  pkg-config \
  automake dejagnu flex bison \
  libtool texinfo autopoint help2man \
  git
RUN rm -rf /var/lib/apt/lists/*
```

Finally, I define the entrypoint:

```Dockerfile
ENTRYPOINT [ "/poke/build/run", "poke" ]
```

This call, which is also described in the HACKING file, starts _poke_. Since it is defined as entrypoint, I can also specify parameters with the call.

### Build

First, I build the image:

```shell
docker build -t gnupoke .
```

### Run

… and this is how I run the image:

```shell
docker run -it gnupoke
```

But I can also change the entrypoint to call a bash shell. In this example I also mount the current host directory into the _/data_ directory of the image. This allows me to access data from the host.

```shell
docker run -it -v $PWD:/data --entrypoint /bin/bash gnupoke
```

I this case I need to start _poke_ inside of the image with: `/poke/build/run poke`

## Summary

As mentioned above I wonder why not all necessary libraries are described in the documentation. Of course, this depends on the distribution and version and can be complex. But why is not a Dockerfile created? On one hand, the Dockerfile documents the necessary steps and at the same time it setup a defined environment. Nobody needs to say: _but it runs on my machine_.

And if you want to try gnu-poke by your own you can take a look at the [manual](http://www.jemarch.net/poke-1.0-manual/).
