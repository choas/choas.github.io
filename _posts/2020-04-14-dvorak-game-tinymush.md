---
layout: post
title:  Dvorak Game — TinyMUSH
date:   2020-04-14 19:48 +0200
image:  mockup-2878906_1280.jpg
credit: https://pixabay.com/de/photos/mock-up-wei%C3%9F-anmelden-gesch%C3%A4ft-2878906/
tags:   dvorak-game games
---

> Dvorak is a customizable card game that begins with a deck of blank index cards. These index cards … are written and drawn upon by players before or during the game. Alternatively, games of Dvorak can be played online via a MUSH … — [Wikipedia: Dvorak Game](https://en.wikipedia.org/wiki/Dvorak_(game))

In the 📺 Big Bang Theory episode ([S3E5 - The Creepy Candy Coating Corollary](https://bigbangtheory.fandom.com/wiki/The_Creepy_Candy_Coating_Corollary)) Howard, Leonard, Raj, and Penny played the game [Mystic Warlords of Ka’a](https://bigbangtheory.fandom.com/wiki/Mystic_Warlords_of_Ka%27a). This is not a real game. It was developed for the series.

There is a discussion in the [Board Game Geek (BGG) Forum](https://boardgamegeek.com/thread/597333/article/6068691#6068691) about how to create this game, and one suggestion is to use the [Dvorak Game](http://dvorakgame.co.uk/) rules. "Dvorak" like the [Dvorak keyboard layout](https://en.wikipedia.org/wiki/Dvorak_keyboard_layout)? No, in this case no music and no keyboard.

Mystic Warlords of Ka'a has been implemented as a real game. But I haven't found anything about it. Unfortunately there is also no Dvorak Game variant. But how does a Dvorak Game work?

## Dvorak Game

Dvorak Game was developed by [Kevan Davis](https://kevan.org/). The basic idea is to use an existing deck of cards or to create and customize your own deck with your friends.

The basic rules are very simple:

1. draw a card
2. perform a thing and / or an action
3. discard excess cards

You can find the full rules on [dvorakgame.co.uk](http://www.dvorakgame.co.uk/index.php/Rules) or [Wikipedia: Dvorak Game](https://en.wikipedia.org/wiki/Dvorak_(game)).

## TinyMUSH Docker Image

You can play Dvorak online with Telnet on a [MUSH](https://en.wikipedia.org/wiki/MUSH), in this case TinyMUSH. For this I created a Docker image and used the [amuskindu/TinyMUSH](https://github.com/amuskindu/TinyMUSH) fork:

```text
FROM ubuntu:20.04

RUN apt-get update && apt-get install -y \
    build-essential libtool \
    cproto libssl-dev libpcre3-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/amuskindu/TinyMUSH

WORKDIR TinyMUSH

RUN autoreconf -ivf \
    && ./Build

EXPOSE 6250

WORKDIR game

ENTRYPOINT bin/netmush
```

Build the Docker image and start TinyMUSH:

```bash
docker build -t choas/tinymush .

docker run -it -p 6250:6250 --name tinymush \
       choas/tinymush:latest
```

TinyMUSH runs on port 6250 and you can connect to it with Telnet or Netcat:

```bash
nc 127.0.0.1 6250
```

### Password of TinyMUSH

I don't know how long I have searched for the password of user #1 (also named "god"). It is not written anywhere. Then I found it in the source code:

```text
connect Wizard potrzebie
```

After I found the password, I even found it on Wikipedia: [potrzebie](https://en.wikipedia.org/wiki/Potrzebie)

Because only "god" can turn a user into a wizard with extended rights. This is also not mentioned anywhere and is actually quite simple:

```text
@set lars=WIZARD
```

### Dvorak Engine

After TinyMUSH is started and you are logged in, you can install the [Dvorak Engine](http://www.dvorakgame.co.uk/index.php/Dvorak_Engine_source). The engine is written in MUSH code. Afterwards you can install a deck of cards. You can find some at the [Playable Decks](http://www.dvorakgame.co.uk/index.php/Category:Playable_decks).

## Summary

I did not find out how several players can play with TinyMUSH. Probably I have to create a room in which Dvorak can be played. With the Docker image I can start a TinyMUSH again and again … and maybe you know more?

Anyway I really like the concept behind the Dvorak Game and you can print out the decks and play it offline (with your family).

Another Big Bang Theory Game: [rock paper scissors Spock lizard](https://en.wikipedia.org/wiki/Rock_paper_scissors#Additional_weapons)