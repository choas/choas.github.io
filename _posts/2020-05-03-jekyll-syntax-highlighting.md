---
layout: post
title:  Jekyll Syntax Highlighting
date:   2020-05-03 18:49 +0200
image:  eye-shadow-4558443_1280.jpg
credit: https://pixabay.com/de/photos/eye-shadow-cosmetics-color-palette-4558443/
tags:   jekyll syntax
---

> Highlight.js supports over 180 different languages in the core library. There are also 3rd party language plugins available for additional languages. — [How to use highlight.js]

In my previous blog post I added a BASIC source code, but it was not highlighted. In this case, the 'highlighting' is a light blue background color. The same is true for Dockerfile source code. In this case, I chose 'text' as language and highlighted the source code. I don't want to use 'text' for all unknown languages and I also want some syntax highlighting 🎨 depending on the language. Therefore I take a closer look at [highlight.js].

## highlight.js

[highlight.js] supports 189 languages and 91 styles at the moment. It is easy to [integrate into Jekyll]. I have added the following lines to the `_include/head.html` file:

```html
<link rel="stylesheet" href="/css/highlight/github.css">
<script src="/js/vendors/highlight.pack.js"></script>
<script>hljs.initHighlightingOnLoad();</script>
```

The most complicated part was figuring out which style to select. I chose the GitHub style. For the programming languages I selected on the [Download highlight.js] page all _Common_ languages and the following _Other_ languages:

- BASIC
- Dockerfile
- Lisp and Scheme
- OCaml and ReasonML
- OpenSCAD
- Prolog

There is a list of all [Supported Languages]. There are more languages I will write about in the future, and for these I need the appropriate syntax highlighting …

[How to use highlight.js]: https://highlightjs.org/usage/
[highlight.js]: https://highlightjs.org/
[integrate into Jekyll]: https://github.com/choas/choas.github.io/commit/9a11bf6fa5c16febd3e7bc6882f3d5d37a51d62f
[Download highlight.js]: https://highlightjs.org/download/
[Supported Languages]: https://github.com/highlightjs/highlight.js/blob/master/SUPPORTED_LANGUAGES.md
