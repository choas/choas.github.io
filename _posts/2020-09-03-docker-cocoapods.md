---
layout:  post
title:   Docker CocoaPods
date:    2020-09-03 21:57 +0200
image:   pattern-2982849_1280.jpg
credit:  https://pixabay.com/photos/pattern-backgrounds-abstract-red-2982849/
excerpt: My CocoaPods is broken, and I used a Docker image as temporary solution to install some pods for an iOS sample application.
---

> CocoaPods is a dependency manager for Swift and Objective-C Cocoa projects. It has over 76 thousand libraries and is used in over 3 million apps. CocoaPods can help you scale your projects elegantly. — [CocoaPods](https://cocoapods.org/)

My CocoaPods is broken, when I call `pod` I get the message `cannot load such file -- 2.6/ffi_c (LoadError)` and `incompatible library version`. This is always the problem with system-wide libraries which are used by different projects and programs. If some application updates the library, then something else might not work, like CocoaPods.

For Python I use `virtualenv` and for NodeJs the [nix-shell](https://nixos.wiki/wiki/Development_environment_with_nix-shell). Additionally I use [direnv](https://direnv.net/), so that I have the right environment in the terminal window when I open the directory. CocoaPods uses [Ruby](https://en.wikipedia.org/wiki/Ruby_(programming_language)) and probably a similar configuration is possible. However, I just wanted to built an iOS example and therefor I have to install some pods.

Either I spend the evening solving the Ruby and CocoaPods problem and that's it, or I install a CocoaPods Docker image, look at the iOS example and write a blog post?

You can guess which option I have chosen.

## Cocoapods Docker Image

Dockerhub has the [renovate/cocoapods](https://hub.docker.com/r/renovate/cocoapods)
 image. By calling the following command Docker downloads it, executes `pod install` and you mount the directory where the `Podfile` is located with `/usr/src/app`. That’s all...

```shell
docker run \
  --volume $PWD:/usr/src/app \
  renovate/cocoapods \
  pod install
```

... but this takes a while ⏳ because the _spec_ repository has to be cloned.

## Summary

To test the iOS example the Docker image was ok, but in the long run I have to fix the Ruby problem.
