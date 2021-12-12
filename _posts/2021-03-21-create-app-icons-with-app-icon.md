---
layout:  post
title:   Create App Icons with app-icon
date:    2021-03-21 10:17 +0100
image:   grass-1209945_1280.jpg
credit:  https://pixabay.com/photos/grass-wilderness-green-path-paths-1209945/
tags:    iOS app-icon
excerpt: I want for my iOS apps an own icon which I create with app-icon.
---

> Icon management for Mobile Apps. Create icons, generate all required sizes, label and annotate. Supports Native, Cordova, React Native, Xamarin and more. — [app-icon README](https://github.com/dwmkerr/app-icon#readme)

When I develop an iOS app, the default app icon is OK, but at some point, I want to have my own icon. Especially, if you have several sample and demo apps on your iPhone that use the same default app icon.

In this case it is good enough to have an icon with two or three letters. I don't need a super great designed icon for a demo app.

## app-icon npm package

I looked for some tools and found the npm package [app-icon](https://www.npmjs.com/package/app-icon). It requires [ImageMagick](https://imagemagick.org/) which I have on my machine and I also have Node.js. Therefore, I can (without having to install anything) run the app-icon package as follows:

```bash
npx app-icon init
```

… or with some text (see [README](https://github.com/dwmkerr/app-icon#readme)):

```bash
npx app-icon init --caption "App".
```

The 'npx' command is a [Node.js Package Runner](https://nodejs.dev/learn/the-npx-nodejs-package-runner) … and "_lets you run code built with Node.js and published through the npm registry_".

This creates the icon.png file. I simply adapt this file. Either I copy an image into it or just add a plain background with some letters, characters, numbers or emojis 🥳. As I said, a simple icon which I can find on my phone is enough.

![adjusted icon.png image](/images/appicon_icon.png)

After customizing the icon.png file, I create an _AppIcon_ folder in the Xcode project's root folder and copy the icon.png file into it. The following command will then generate all the necessary app icons, directly into the Xcode project:

```bash
npx app-icon generate -i AppIcon/icon.png
```

![Xcode screenshot with all app icons](/images/appicon_xcode_screenshot.png)

Now, I can customize the icon at any time and regenerate it.

## Summary

app-icon is a Node.js package that I use to quickly create an icon for a demo iOS app, but I also use it to create the icon for a real app, like the icon for my [Mindful Widget app](https://apps.apple.com/us/app/mindful-widget/id1547530653).

Any questions or comments? Write me on Twitter [@choas](https://twitter.com/choas) (DM is open).
