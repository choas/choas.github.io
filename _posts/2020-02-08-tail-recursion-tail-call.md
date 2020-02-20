---
layout: post
title:  tail recursion / tail call
date:   2020-02-08 19:27 +0100
image:  fence-918535_1280.jpg
credit: https://pixabay.com/de/photos/zaun-l%C3%A4ndlich-feld-bauernhof-918535/
tags:   tail-recursion swift
---

> The technique of writing a function so that recursive calls are only done immediately before function return, particularly when recursive control structures are used in place of iterative ones. — [Wiktionary: Tail Recursion]

As I reworked the blog posts on Lua and Swift ([Lua and Swift in iOS], [Factorial calculation with Lua and Swift], [Recursive calls between Lua and Swift]), I took a closer look at the ;`factorial` function I use. I asked myself: Can Lua tail recursion?

## Tail recursion

Usually a method call writes the result to the stack. In a recursive call, this means that several data items accumulate on the stack.  Only after the last call has been made the calling method processes the individual results. This can cause a [Stack overflow] if the stack provided for this purpose does not have enough memory.

If a programming language or much more the compiler supports _tail recursion_ then the recursive function is not called with a `call`. Instead, it simply jumps (`jump`) directly to the function. This means that the called method does not have to write anything to the stack.

## Factorial as tail recursion

To call a method call tail recursive, the method call must be the last command. Nothing may follow after that.

If you look at the following Factorial example from the blog post [Factorial calculation with Lua and Swift], the `factorial` call is at the end. But it can also be swapped with the `n` within the multiplication. In fact the multiplication is the last call and not the recursive call.

```lua
function factorial(n)
    if (n == 0) then
        return 1
    else
        return n * factorial(n - 1)  -- not tail recursive
    end
end
```

To construct a tail recursive call, the multiplication must be done first. The result is passed with the method call. To make this possible, the recursive function has two parameters. The counter, which is reduced by 1 with each call, and a second parameter to store the subtotal.

```lua
function fact_(n, acc)
    if (n == 0) then
        return acc
    else
        return fact_(n - 1, n * acc)
    end
end
```

The reduction of the counter as well as the multiplication is now done before. The result is passed to the `acc` parameter. This parameter works like an [Accumulator] within a CPU: "the accumulator is a register in which intermediate arithmetic and logic results are stored".

## Result

If you call the `factorial` method with 1 million, a stack overflow occurs:

```shell
> print(factorial(1000000))
stdin:5: stack overflow
stack traceback:
  stdin:5: in function 'factorial'
  ...
  stdin:5: in function 'factorial'
  stdin:1: in main chunk
  [C]: in ?
```

The tail recursive method `fact_`, on the other hand, has no error and returns _inf_. The result is infinity after 170 iterations.

```lua
> print(fact_(1000000, 1))
inf
```

Lua is just one example of a language that supports tail recursion. The classic functional programming languages like Scheme and LISP also have tail recursion. So do the JVM-based languages Clojure and Scala, but they handle tail recursion separately because the Java compiler does not support it. C, C++ and Objective-C can be optimized by the compiler (depending on the compiler). What about Swift?

## Swift and tail recursion

I'm not the first person asking that question. On Stack Overflow there is this question: [Does Swift implement tail call optimization?]

I wrote the factorial methode in Swift:

```swift
func factorial(n: Int, acc: Double) -> Double {
  if n <= 0 {
    return acc
  } else {
    return factorial(n: n - 1, acc: acc * Double(n))
  }
}
```

Compiling the code with the Swift compiler and outputting it as an assembly creates 3 `callq` calls that grep finds:

```shell
> swiftc -emit-assembly factorial.swift | grep -i call
  callq _memset
  callq _memset
  callq _$s9factorialAA1n3accSdSi_SdtF
```

With the -O parameter (see [Enabling Optimizations]) on the other hand, the code is optimized. In this case, the compiler generates code without `callq` calls:

```shell
> swiftc -O -S factorial.swift | grep -i call
```

### Calling the factorial function

Add the following code to call and output the factorial function with 1 million:

```swift
print(factorial(n: 1000000, acc: 1))
```

If you run the Swift code on the command line without optimization, the `callq` calls within the factorial method will cause an error:

```shell
❯ swift factorial.swift
[1]    31980 illegal hardware instruction  swift factorial.swift
```

When running with optimization (-O parameter) the application runs without errors and outputs _inf_. The calculated value is too large and is therefore infinitive.

```shell
❯ swift -O factorial.swift
inf
```

### LLVM - Tail call optimization

Swift uses [LLVM] as compiler, which has a [Tail call optimization].

## Summary

Tail recursion is a way to walk recursively through lists and graphs and not run into the risk of a stack overflow.

[Lua and Swift in iOS]: /2019/12/27/lua-and-swift-in-ios/
[Factorial calculation with Lua and Swift]: /2019/12/29/factorial-calculation-with-lua-and-swift/
[Recursive calls between Lua and Swift]: /2019/12/30/recursive-calls-between-lua-and-swift/
[Wiktionary: Tail Recursion]: https://en.wiktionary.org/wiki/tail_recursion
[Stack overflow]: https://en.wikipedia.org/wiki/Stack_buffer_overflow
[Accumulator]: https://en.wikipedia.org/wiki/Accumulator_(computing)
[Does Swift implement tail call optimization?]: https://stackoverflow.com/questions/24023580/does-swift-implement-tail-call-optimization-and-in-mutual-recursion-case#24274482
[Enabling Optimizations]: https://github.com/apple/swift/blob/master/docs/OptimizationTips.rst#enabling-optimizations
[LLVM]: https://www.llvm.org/
[Tail call optimization]: http://llvm.org/docs/CodeGenerator.html#tail-call-optimization
