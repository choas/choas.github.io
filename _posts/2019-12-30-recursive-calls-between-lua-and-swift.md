---
layout: post
title:  Recursive calls between Lua and Swift
date:   2019-12-30 14:39 +0100
image:  staircase-178039_1280.jpg
credit: https://pixabay.com/de/photos/treppenhaus-schwarz-wei%C3%9F-treppe-178039/
tags:   lua-embedded swift-objective-c
---

> A common method of simplification is to divide a problem into subproblems of the same type. -- [Wikipedia: recursive](https://en.wikipedia.org/wiki/Recursion#In_computer_science)

In this third blog post (see also [blog post 1](https://www.larsgregori.de/2019/12/27/lua-and-swift-in-ios/), [blog post 2](/2019/12/29/factorial-calculation-with-lua-and-swift/)) we will register a Swift function within Lua so that it can be called from Lua. The Swift function can basically call anything. This allows Lua to execute certain things or access values that the embedded Lua can't, like the gyroscope of the smartphone. But we will just call the Lua factorial function again.

There are a some more steps necessary, because we add an additional wrapper:

- registerFunction
- FactorialWrapper
- Factorial Swift Class
- Lua Code

You can find the [Source Code](https://github.com/choas/LuaSwift/tree/master/LuaSwiftRecursiveSwiftLua) on Github.

## registerFunction

We define the registerFunction method within the LuaWrapper files. The method calls the [`lua_register`](https://www.lua.org/manual/5.3/manual.html#lua_register) method and passes the function which should be called and the name under which the function is registered.

This allows Objective-C functions to be used within Lua and Lua to access information that is otherwise only available 🔒 within a native iOS. Swift is accessible from the Objective-C function.

### LuaWrapper.h

Add the following code to the __LuaWrapper.h__ file before `@end`:

```objc
- (void) registerFunction: (lua_CFunction)function
                 withName: (const char *)name;
```

The first parameter is the C function, the second is the name of the function that Lua registers the function with.

### LuaWrapper.m

Add the implementation of the `registerFunction` to the __LuaWrapper.m__ file before the `@end`:

```objc
- (void) registerFunction: (lua_CFunction)function
                 withName: (const char *)name {
    lua_register(luaState, name, function);
}
```

The `registerFunction` only calls the `lua_register` function with the `luaState` and passes the parameters.

## FactorialWrapper

The `factorialExternal` function within the wrapper file has two tasks:

- It creates a (singleton) instance of the Swift Factorial class (we will implement the class below).
- It calls the callFactorial method of the Factorial class.

### FactorialWrapper.h

Create the __FactorialWrapper.h__ file with following steps:

- File / New / File …
- Header File
- Dialog
  - FactorialWrapper.h
  - select Targets checkbox
  - Create

Add the following code after `#define`:

```objc
#include "lua.h"

int factorialExternal(lua_State *luaState);
```

### FactorialWrapper.m

For the implementation of the `factorialExternal` function create the __FactorialWrapper.m__ file with following steps:

- File / New / File …
- Objective-C
- Dialog
  - File: FactorialWrapper.m
  - File Type: Empty File

Add the following code to the __FactorialWrapper.m__ file and customize the second import. Xcode generates an .h file that gives Objective-C access to Swift classes and functions. Therefore, you must adjust the import according to the project name: _project-name_-Swift.h

```objc
#import "FactorialWrapper.h"
#import "LuaSwiftRecursiveSwiftLua-Swift.h" // << ADJUST ME

Factorial * factorial;

int factorialExternal(lua_State *luaState) {
    if (factorial == Nil) {
        factorial = [[Factorial alloc] initWithScript: @""];
    }

    UInt64 n = lua_tointeger(luaState, -1L);
    lua_pop(luaState, 1);

    lua_Number res = [factorial
                      callFactorialWithState:luaState
                      value:n];
    lua_pushnumber(luaState, res);

    return 1;
}
```

The `Factorial alloc` calls the function `initWithScript`. This function is the `init(script: String)` function in the Swift `Factorial` class. For the _Objective-C and Swift bridging_ the Swift function names are translated into '_function-name_ With _first-parameter_'.

The same pattern is used for the `callFactorialWithState` function name which calls the Swift function `callFactorial(state: ...`.

The `factorialExternal` function

- creates a `Factorial` instance (as singleton)
- reads the value from the stack
- calls the Swift `callFactorial` function
- push the result on the stack

### Bridging.h

The FactorialWrapper.h file must be added to the _project-name_-Bridging.h file. This allows Swift to access the function 'factorialExternal' to register the function within Lua:

```objc
#import "FactorialWrapper.h"
```

## Factorial Class

I moved the initialization and also the call of the Lua function to a separate class. So this functionality is encapsulated and can be used from Objective-C.

### Factorial.swift

The Factorial class has an `init` and a `callFactorial` method. The `init` method gets the Lua script during initialization. This script is loaded when Lua is initialized. Additionally, the `init` method registers the `factorialExternal` method in Lua. The `factorialExternal` method is implemented in the FactorialWrapper files.

The `callFactorial` method calls the Lua function `factorial`.  The `ViewController` and the `factorialExternal` method call the `callFactorial` method.

For the Objective-C Swift bridging the Swift functions `init` and `callFactorial` are named `initWithScript` and `callFactorialWithState` within Objective-C.

```swift
@objc(Factorial)
class Factorial : NSObject {

    var lua : Lua
    let ptrFname = strdup("factorial")

    @objc
    init(script: String) { // Objective-C: initWithScript
        lua = Lua()
        lua.setup()

        let ptrScript = strdup(script)
        lua.script(ptrScript)
        free(ptrScript)

        let funcName = strdup("factorialExternal")
        lua.register(factorialExternal, withName: funcName)
        free(funcName)
    }

    @objc
    func callFactorial(state: OpaquePointer? = nil,
                       value: lua_Number) -> lua_Number {
        // Objective-C: callFactorialWithState
        return lua.call(state,
                        methode: ptrFname,
                        value: value)
    }

    deinit {
        free(ptrFname)
        lua.destruct()
    }
}
```

### ViewController.swift

This changes the __ViewController.swift__ file. Replace the existing code for the Lua call with this one:

```swift
let filename = Bundle.main.path(forResource: "script",
                                     ofType: "lua")!

do {
    let luaScript = try String(contentsOfFile: filename)

    let fac = Factorial(script: luaScript)
    let result = fac.callFactorial(value: lua_Number(100))
    print(result)
} catch let error {
    print("can not read file", filename, error)
}
```

As before, the __script.lua__ file is read in. The file content is passed to the factorial instance when it is created. Afterwards the function `callFactorial` is called and the result is printed. Therefore this process has not changed.

## script.lua

Last but not least you have to change the __script.lua__ file so that the call can be done via Objective-C and Swift:

```lua
-- factorial
function factorial(n)
    if (n == 0) then
        return 1
    else
        return n * factorialExternal(n - 1)
    end
end
```

There is no change in the overall result. The 100! gives the same result as in the [previous blog post](/2019/12/29/factorial-calculation-with-lua-and-swift/). But the execution is done by an Objective-C function, which again calls a Swift function. Up to this point it is a normal scenario to access external functionalities from the embedded Lua code.

The direct call of the Lua function factorial is experimental. However, it might be possible to call a Swift function from within Lua, which then executes other Lua functions depending on a state.

## Summary

In these three blog posts you have seen how to embed Lua within Swift and how to call a Lua function. You also saw how to register a Swift function with Objective-C in Lua.
