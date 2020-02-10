---
layout: post
title: Factorial calculation with Lua and Swift
date: 2019-12-29 17:29 +0100
image: rollercoaster-801833_1280.jpg
credit: https://pixabay.com/de/photos/rollercoaster-schleifen-unterhaltung-801833
tags: factorial-calculation lua-embedded
---

> The result of multiplying a given number of consecutive integers from 1 to the given number. In equations, it is symbolized by an exclamation mark (!). For example, 5! = 1 × 2 × 3 × 4 × 5 = 120. -- [Wiktionary — factorial](https://en.wiktionary.org/wiki/factorial)

In the [previous blog post](/2019/12/27/lua-and-swift-in-ios/) I showed how Lua can be integrated within Swift. In this blog post we will call a Lua function from Swift and print the result. For this I use a [factorial](https://en.wikipedia.org/wiki/Factorial) example where the code is called recursively. In the next step / blog post the Lua code will call the Swift code, which again calls the Lua code. This is a recursion within programming languages 🤯.

But first we adapt the project for the Factorial Example. The following steps are necessary:

- Factorial Lua Code
- Implement call function
- Adjust ViewController.swift

You can find the __[source code](https://github.com/choas/LuaSwift/tree/master/LuaSwiftFactorial)__ on Github.

## Factorial Lua Code

Extend or replace the __script.lua__ file with this Lua code:

```lua
-- factorial
function factorial(n)
    if (n == 0) then
        return 1
    else
        return n * factorial(n - 1)
    end
end
```

The `factorial` function is called with a number. This number is multiplied by the next lower number. The `factorial` method is called recursively and the number is reduced by 1. This is done until the number is 0. In this case, the previous result is multiplied by 1, otherwise everything would be 0.

The __script.lua__ file only defines the `factorial` method but doesn’t run it. To execute it and read the result, we implement a call method in the _luaWrapper_ files.

## Implement call function

### luaWrapper.h

The `call` method is called with these parameters:

- the Lua state
- the method name of the Lua function
- the parameter of the Lua function, in this case the number to be factorized

Insert the following code into the __luaWrapper.h__ file before `@end`:

```objc
- (LUA_NUMBER) call: (lua_State *) state
            methode: (const char *) methode
              value: (LUA_NUMBER) value;
```

### luaWrapper.m

If the `call` method is called with a state, then this state is used, otherwise the internal state. This is necessary for the next blog post.

`lua_getglobal` sets the Lua function name on the stack, just like the `lua_pushnumber` method which sets the parameter. The `lua_pcall` method (see [lua\_pacall](https://www.lua.org/manual/5.3/manual.html#lua_call)) reads the parameter and function name and executes the Lua function. The result is written to the stack. The parameters in the `lua_pcall` method are the state, the number of passed parameters, the number of return values and a stack index in case of an error.

```objc
- (LUA_NUMBER) call: (lua_State *) state
            methode:  (const char *) methode
              value: (LUA_NUMBER) value {

    lua_State * luaStateEx = luaState;

    if (state != Nil) {
        luaStateEx = state;
    }

    lua_getglobal(luaStateEx, methode);
    lua_pushnumber(luaStateEx, value);
    lua_pcall(luaStateEx, 1, 1, 0);

    LUA_NUMBER result = lua_tonumber(luaStateEx, -1);
    lua_pop(luaStateEx, 1);
    return result;
}
```

After the `lua_pcall` call the result is on the stack. The `lua_tonumber` method reads it and converts it into a number. The `lua_pop` method takes it from the stack.

Insert the code into __luaWrapper.m__ file (before `@end`).

## Adjust ViewController.swift

Add the following code to the __ViewController.swift__ file in the viewDidLoad method after `free(ptrScript)`:

```swift
let ptrFname = strdup("factorial")
let value = lua_Number(100)
let result = lua.call(nil, methode: ptrFname, value: value)
free(ptrFname)
print(result)
```

The `call` method — defined in the luaWrapper files — is called with the function name of the Lua function and the value which will be factorized. At the end the result is printed.

For this example the output of factorial 100! is 9.33262154439441e+157 (see [Wolfram Alpha](https://www.wolframalpha.com/input/?i=100%21) for the exact output).

## Next

In this example I have shown how to call a Lua function in Swift and read the result. In the next blog post I show how to register a Swift function so that it can be used by Lua. Since we use a recursive function, I thought a recursion inside Lua and Swift might be interesting.
