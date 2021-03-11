---
layout:  post
title:   gitignore.io
date:    2021-03-11 19:11 +0100
image:   deaf-3737373_1280.jpg
credit:  https://pixabay.com/de/photos/taub-geh%C3%B6rlos-ignorant-ignoranz-3737373/
tags:    programming git
excerpt: .gitignore entries depend on the programming language, development environment and operating system and gitignore.io can help.
---

> Create useful .gitignore files for your project — [gitignore.io](https://gitignore.io)

Every time I create a new project and want to commit the first files, I see files I don't want in the git repository. Either the `.DS_Store` file, `node_modules` or any other file. So I search for `.gitignore` at DuckDuckGo, and end up at [gitignore.io](https://gitignore.io) and then think "Why do I always search?". Therefore, I decided to write this blog post and hopefully next time I'll think about [gitignore.io](https://gitignore.io).

## gi CLI

Because I run [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh) in my zsh shell, I already have `gi` in the CLI and even with code completion:

```bash
gi xcode swift >> .gitignore
```

To get a list of the possible entries just call `gi list`. When you call `which gi` you can see what _gi_ does. It runs curl on the gitignore.io page:

```bash
gi () {
  curl -fLw '\n' https://www.gitignore.io/api/"${(j:,:)@}"
}
```

## Summary

Before you either commit everything on the first commit, or just check in a few files and maybe miss a few others, gitignore.io or `gi` offers the ability to build the `.gitignore` file depending on the programming language, development environment and operating system.

Let's see, if I remember `gi` in the future 🔮.
