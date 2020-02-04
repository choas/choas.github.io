---
layout: post
title:  No Tagging with Jekyll on Github Pages
date:   2020-02-04 23:08 +0100
image:  cyberspace-2784907_1280.jpg
credit: https://pixabay.com/de/photos/cyberspace-daten-draht-2784907/
tags:   jekyll
---

> GitHub Pages cannot build sites using unsupported plugins. — [About GitHub Pages and Jekyll](https://help.github.com/en/github/working-with-github-pages/about-github-pages-and-jekyll)

I use [Zolan - Modern & Minimal Theme for Jekyll](https://github.com/artemsheludko/zolan) for the theme of my blog and it supports tagging 🏷. But unfortunately Github Pages does not support the [jekyll/tagging](https://github.com/pattex/jekyll-tagging) plugin. The [Dependency versions](https://pages.github.com/versions/) page has the note "GitHub Pages uses the following dependencies and versions". But it is not clear that __only__ these plugins are available for Github Pages.

To solve the problem, I have removed the link, and the tags are text only. Another solution could be to generate the pages locally and upload the result. Any plugin could be used for this. But I prefer the way to push some changes or a new blog post to Github and everything will be created automatically.

.. and I think I have some many topic and therefore also so many tags, that I don’t need to group them.
