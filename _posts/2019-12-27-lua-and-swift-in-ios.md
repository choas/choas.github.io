---
layout: post
title:  Lua and Swift in iOS
date:   2019-12-27 10:01 +0100
image:  full-moon-415501_1280.jpg
credit: https://pixabay.com/de/photos/vollmond-mond-nacht-dunkel-schwarz-415501/
tags:   swift lua
---

> I looked at Lua which it's pretty easy to integrate and is highly optimized, but I really hate the syntax. There is just too much that is goofy about Lua. I like my { braces }. -- [Ron Gilbert: Engine](https://blog.thimbleweedpark.com/engine)

This year I found the time to play [Thimbleweed Park](https://en.wikipedia.org/wiki/Thimbleweed_Park). A point-and-click adventure game by Ron Gilbert and Gary Winnick, who got famous for their 1987 game [Maniac Mansion](https://en.wikipedia.org/wiki/Maniac_Mansion). Ron Gilbert was also involved in [The Secret of Monkey Island](https://en.wikipedia.org/wiki/The_Secret_of_Monkey_Island) and the [SCUMM](https://en.wikipedia.org/wiki/SCUMM) game engine.

In the blog post [Engine](https://blog.thimbleweedpark.com/engine) he writes "_I’m a game engine snob_" and that he uses [Squirrel](http://www.squirrel-lang.org/) instead of [Lua](https://en.wikipedia.org/wiki/Lua_(programming_language)). But due to the [Advent of Code 2019](/2019/12/20/aoc-advent-of-code-2019/) (AoC) I wanted to have another look into Lua and I had already embedded Lua before. Like Ron said: "_it's pretty easy to integrate_".

For these reasons I decided to integrate Lua into an iOS app, because if I ever develop a game 🤣, I already have a game engine. There is no need to discuss the syntax, because this is a matter of taste. But the question I couldn't really answer is: Why should I bring an additional language into a project? However, in a game project with more than one or two people, this can make sense, but I'm not there yet.

Lua is available as C code and can be compiled and integrated easily within Swift. [Lua is under the MIT license](https://www.lua.org/license.html) and can be used everywhere. On the internet you can find examples how to integrate C into Swift under [swift objective-c bridging](https://duckduckgo.com/?q=swift+objective-c+bridging). And I'm not the first who had the idea to integrate Lua into Swift.

In the [next blog posts](/2019/12/29/factorial-calculation-with-lua-and-swift/) I will explain how to call Swift from Lua and then call Lua code again. The whole thing will be very recursive. But first we will write a Hello World application as a base and then we will build on that. You can find the __[source code](https://github.com/choas/LuaSwift/tree/master/LuaSwiftHelloWorld)__ on Github.

## Hello World

For the Hello World example following steps are required:

- create a Swift project
- create the bridging files
- download and integrate the Lua source code
- create a Lua Hello World file
- read and execute the Lua file

## Create a Swift project

I don't think it should be a big deal. Open Xcode, create a new project and choose Swift as your programming language. For the User Interface, select Storyboard.

## Create the bridging files

After you setup a new Swift project, you create the wrapper and bridging files.

### LuaWrapper.m

First you create the LuaWrapper.m file with following steps:

- File / New / File …
- Objective-C
- Dialog
  - File: LuaWrapper.m
  - File Type: Empty File
- Would you like to configure an Objective-C bridging header?
  - Create Bridging Header

This will create the LuaWrapper.m file and the _project-name_-Bridging-Header.h file. Next you create the LuaWrapper.h file.

### LuaWrapper.h

- File / New / File …
- Header File
- Dialog
  - LuaWrapper.h
  - select Targets checkbox
  - Create

### Include header file to bridging file

Add the following code which includes LuaWrapper.h into following files:

- LuaWrapper.m
- _project-name_-Bridging-Header.h

```objc
#include "LuaWrapper.h"
```

## Download Lua source

You find the source on the [Lua Download page](https://www.lua.org/download.html) (version 5.3.5 works for me).

- Download the source code and unpack the file.
- Drag and drop the src folder in the project.
- Create external build system project
  - unselect _Create external build system project_
  - Next
- Choose options for adding these files:
  - select _Copy items if needed_
  - select _Add to targets_
  - Finish

### Adjust targets

The following files need to be deselected from the _targets_. Therefore select these files in the src folder. The files can be sorted by right clicking on the src folder and selecting _Sort by Name_.

- loslib.c
- lua.c
- luac.c

In the file inspector on the right side of Xcode, uncheck _Target Membership_.

### add `luaopen_os` to Objective-C file

The loslib.c file contains the `luaopen_os` function which was deselected.
Therefore you need to add this adjusted function into the LuaWrapper.m file at the end.

```objc
LUAMOD_API int luaopen_os (lua_State *L) {
  return 1;
}
```

The loslib.c file contains some system calls which aren’t available in iOS but also defines the `luaopen_os` function which is used by other functions.

### Lua include files

Add after the `#define LuaWrapper_h` the following .h files includes:

```objc
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
```

## Create Lua file

Create the script.lua file:

- File / New / File
- Empty file (in Other group)
- script.lua
- Create

… and add the following Lua code into the script.lua file:

```lua
print("hello world")
```

## Load Lua script and execute the code

Next, implement some Objective-C wrapper functions that Swift uses. The LuaWrapper.h file defines functions, the LuaWrapper.m file implements them, and ViewController.swift uses them by loading the Lua script file and executing the code.

### LuaWrapper.h file

Now you need to add some Objective-C code in the LuaWrapper.h file (after the lua includes and before the `#endif`):

```objc
#import <Foundation/Foundation.h>

@interface Lua : NSObject {
    lua_State * luaState;
}

- (void) setup;
- (void) script: (const char *) script;
- (void) destruct;

@end
```

### LuaWrapper.m file

The LuaWrapper.h defines some methods and the LuaWrapper.m file implements them. Add the following code into the LuaWrapper.m file:

```objc
@implementation Lua

- (void) setup {
    luaState = luaL_newstate();
    luaL_openlibs(luaState);
}

- (void) script: (const char *) script {
    luaL_loadstring(luaState, script);
    lua_pcall(luaState, 0, 0, 0);
}

- (void) destruct {
    lua_close(luaState);
}

@end
```

The `setup` function creates a new Lua state. The `script` function loads a string into this state and just runs the loaded code. In part two of this series you will see that the `lua_pcall` method calls Lua functions.

The `destruct` function closes the Lua state and frees internally some stuff.

### ViewController.swift

To load the script file and execute the Lua code you need to add the following code into the ViewController.swift in the viewDidLoad() function after super.viewDidLoad():

```swift
let filename = Bundle.main.path(forResource: "script",
                                ofType: "lua")!
do {
    let lua = Lua()
    lua.setup()

    let luaScript = try String(contentsOfFile: filename)
    let ptrScript = strdup(luaScript)
    lua.script(ptrScript)
    free(ptrScript)

    lua.destruct()
} catch let error {
    print("can not read file", filename, error)
}
```

First a Lua instance is created and the `setup` method creates a new state. Then the script.lua file is loaded as String and `strdup` converts it to a `const char *`. After the execution the we need to `free` it and destruct the Lua state.

#### Memory leaks

The code is only executed once and then nothing happens. You may think why we should care about some memory leaks. But it is easier to start small and eliminate some memory leaks in the beginning.

You will see relatively fast when you have a memory leak in the debug session view and Profile. Add this code in an endless loop (`while (true)`) after `Bundle.main.path` and run it.

If you add the `Bundle.main.path` call in the while loop you will get memory leaks.

## run

But before you worry about memory leaks, your code should be running:

- Select a Simulator
- Product / Run

Now you should see in the Output a `hello world`.

## Next

At the [next blog post](/2019/12/29/factorial-calculation-with-lua-and-swift/) I will integrate a factorial calculation.
