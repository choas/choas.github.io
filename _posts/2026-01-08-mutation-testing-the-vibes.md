---
layout:  post
title:   "The T in vibe coding stands for testing (Part 3): Mutation testing the vibes"
date:    2026-01-08 19:20 +0100
image:   robot_with_green_eyes_part3.jpg
credit:  Nano Banana Pro - A zombie-like decay robot/AI assistant with glowing green eyes, stamping "PASSED" on code boxes on a conveyor belt, while some boxes have visible cracks leaking bugs that the robot doesn't notice - visualizing mutation testing revealing gaps; use as image size 1168x768
tags:    AI Security Vibe_Coding LLM Testing Mutation_Testing
excerpt: "Theory said AI-generated tests are circular. Now let's get empirical. I ran mutation testing on vibe-coded tests and found an 85% mutation score. That means 15% of bugs would slip through. Spec-first tests hit 92%. Property tests found 11 real bugs that all example tests missed entirely."

---

In [Part 1](/2026/01/02/vibe-coding-testing/), I argued that AI-generated tests are circular. In [Part 2](/2026/01/06/independent-verification/), I explained why using a different LLM doesn't solve the independence problem. Now let's get empirical.

[Mutation testing](https://en.wikipedia.org/wiki/Mutation_testing) is a technique that answers a simple question: would your tests actually catch bugs?

## How mutation testing works

The process is straightforward:

1. Take working code with passing tests
2. Introduce small, automatic changes (mutations) to the code
3. Run the tests against each mutated version
4. Count how many mutations the tests detect

A mutation might change `>` to `>=`, replace `true` with `false`, delete a function call, or swap arithmetic operators. Each mutation creates a slightly broken version of your code.

If your tests are good, they should fail when the code is broken. A mutation that causes no test failure is a "surviving mutant", evidence that your tests have a blind spot.

The mutation score is the percentage of mutants killed. A score of 100% means every introduced bug was caught. A score of 60% means 40% of the bugs went undetected.

## The experiment

I took a common vibe coding scenario: asking an LLM to implement a utility library, then asking it to write comprehensive tests for that library.

The functions are typical stuff you'd generate this way:
- String manipulation (slugify, truncate, capitalize)
- Array operations (chunk, unique, flatten)
- Validation helpers (email, URL, credit card format)
- Date utilities (format, diff, parse)

I used Claude to generate both the implementation and the tests in a single session. This mirrors the standard vibe coding workflow: "build this, then write tests for it."

The tests all pass. Coverage looks good. Time to see what's actually being verified.

## Results

I ran the generated code through [Stryker](https://stryker-mutator.io/), a mutation testing framework. Here's what I found:

| Module | Mutation Score | Killed | Survived |
|--------|----------------|--------|----------|
| Arrays | 100% | 33/33 | 0 |
| Dates | 90.5% | 38/42 | 4 |
| Strings | 85.2% | 46/54 | 8 |
| Validators | 77.8% | 77/99 | 22 |
| **Overall** | **85.1%** | **194/228** | **34** |

The results were better than I expected, but the details matter.

**Array operations: 100% mutation score**

The array utilities were thoroughly tested. Functions like `chunk`, `unique`, and `flatten` had enough test cases to catch every mutation Stryker threw at them. This is the best-case scenario for vibe coding: simple, well-understood operations with clear contracts.

**Date utilities: 90.5% mutation score**

Surprisingly good coverage here, though 4 mutants survived. The surviving mutations were in edge cases around month boundaries and leap year calculations. The AI wrote tests for common scenarios but missed some calendar arithmetic edge cases.

**String utilities: 85.2% mutation score**

Eight mutations survived. The `truncate` function had boundary condition gaps. Mutations like `< length` to `<= length` survived because no test hit the exact boundary. The `slugify` tests missed some Unicode edge cases.

**Validators: 77.8% mutation score**

This is where the vibe approach shows weakness. 22 mutations survived, almost a quarter of all validator mutations. The email and URL regex validators had tests that were essentially documentation of the regex, not adversarial probes. Mutations that slightly changed the regex patterns frequently survived because the test inputs didn't exercise those specific branches.

**Overall: 85.1% mutation score**

About 15% of introduced bugs would slip past these tests. Not catastrophic, but not great either, especially when you look at where the gaps are.

## What the surviving mutants tell us

Looking at which mutations survived reveals the pattern:

- **Boundary conditions**: Tests check representative values, not boundaries. The LLM picks "5" as a test input, not "0, 1, max-1, max, max+1".
- **Error paths**: Happy paths are well-tested. Error conditions are tested with one obvious case, missing subtle variations.
- **Implementation leakage**: Tests often encode implementation details rather than requirements. When the mutation preserves behavior for the test inputs but breaks it for others, tests don't catch it.
- **Missing adversarial cases**: No tests try to break things. No malformed inputs designed to exploit edge cases. The tests confirm the code works as the LLM understood it, not that it's robust.

## The control: specification-first tests

I ran a second experiment. Same functions, but I gave the LLM only the function signatures and documentation strings. No implementation code. "Write comprehensive tests for this API."

Then I generated the implementation separately and ran the tests.

| Module | Vibe Tests | Spec Tests | Improvement |
|--------|------------|------------|-------------|
| Arrays | 100% | 100% | 0% |
| Dates | 90.5% | 100% | +9.5% |
| Strings | 85.2% | 92.6% | +7.4% |
| Validators | 77.8% | 84.8% | +7.0% |
| **Overall** | **85.1%** | **91.7%** | **+6.6%** |

The spec-first approach achieved **91.7%** mutation score, a meaningful improvement over the vibe tests.

The gains came from everywhere except arrays (which were already at 100%). Most notably, dates went from 90.5% to perfect 100%. Without seeing the implementation's calendar arithmetic, the spec tests reasoned more carefully about edge cases like month boundaries.

Validators improved from 77.8% to 84.8%. Still the weakest module, but the spec tests caught 7 more mutations. Without seeing the regex patterns, the LLM wrote more adversarial test cases, testing malformed inputs it might not have considered if it had seen what the regex was checking for.

## Property-based testing addition

I also tried a third approach: AI-generated [property-based tests](https://hypothesis.works/articles/what-is-property-based-testing/) using [fast-check](https://github.com/dubzzz/fast-check).

| Module | Vibe | Spec | Props |
|--------|------|------|-------|
| Arrays | 100% | 100% | 93.5% |
| Dates | 90.5% | 100% | 71.4% |
| Strings | 85.2% | 92.6% | 61.1% |
| Validators | 77.8% | 84.8% | 86.9% |
| **Overall** | **85.1%** | **91.7%** | **78.8%** |

Wait, the property tests scored *worse* than both other approaches? That needs explanation.

**The property tests found real bugs.** The dates module dropped to 71.4% because I had to skip 11 tests that were failing against the "working" implementation. The strings module dropped to 61.1% because property tests define invariants differently than example tests. They caught fewer mutations but the ones they test are more fundamental. Property tests ask harder questions than example tests, and sometimes the implementation doesn't have good answers.

The validators actually improved to 86.9%, beating even the spec tests. Properties like "adding whitespace to a valid email makes it invalid" caught mutations that neither example-based approach found.

The overall score is lower because property tests have gaps where example tests don't, and vice versa. Property tests excel at invariants but don't always cover the specific edge cases that example tests do. The approaches are complementary, not competing.

## When property tests find real bugs

Here's the thing about property-based tests: they don't just catch mutants. They find actual bugs in the original implementation.

When I ran the property tests against the AI-generated date utilities, several tests failed immediately. Not against mutated code, but against the original "working" implementation. The example-based tests all passed. The property tests found bugs the AI never considered.

**The bugs that were hiding:**

*Extreme year handling*: `formatDate` promises YYYY-MM-DD format, but years outside 0-9999 break this contract. `formatDate(new Date("9999-12-31T23:00:00.000Z"))` returns "10000-01-01", a 5-digit year. Negative years return NaN. No example test caught this because no example used extreme dates.

*Math.floor asymmetry*: `diffInDays` uses `Math.floor(difference / msPerDay)`. This seems reasonable until you realize floor rounds toward negative infinity, not toward zero. So `diffInDays(d1, d2)` doesn't equal `-diffInDays(d2, d1)` when the dates aren't exactly day-aligned. The property "reversing dates negates diff" fails.

*The +0/-0 edge case*: JavaScript has both positive and negative zero. `Object.is(0, -0)` returns false. When the date difference is exactly zero, one direction gives +0 and the other gives -0. The tests expecting equality fail.

*DST transitions break day math*: `addDays` multiplies days by 86,400,000 milliseconds. But during DST transitions, days are 23 or 25 hours long. Adding "one day" of milliseconds doesn't always advance the calendar by one day. The property "adding N days then diffing returns N" fails for dates that cross DST boundaries.

*Timezone inconsistencies*: `isSameDay` compares dates using local time methods, but the underlying timestamps are UTC. Two dates that are "the same day" in one timezone might not be in another. The property "time of day doesn't affect result" fails for dates near midnight in certain timezones.

**Why example tests missed these:**

The AI generated tests like:
- `formatDate(new Date(2024, 0, 15))` → "2024-01-15" ✓
- `diffInDays(jan1, jan5)` → 4 ✓
- `addDays(monday, 7)` → next monday ✓

All reasonable examples. All passing. All failing to probe the boundaries where the implementation breaks.

Property-based testing asks different questions. Not "does this example work?" but "does this invariant hold for all inputs?" The invariant "output is always YYYY-MM-DD" immediately generates counterexamples the AI never imagined.

**The uncomfortable implication:**

These aren't obscure edge cases. Year 10000 is far away, but negative years exist in many calendar systems. DST affects billions of people twice a year. The bugs are in code the AI wrote, verified with tests the AI wrote, and both the AI and the tests agreed everything was fine.

I had to skip 11 of the property tests to get the suite to pass against the original implementation. Each skip represents a bug the vibe coding workflow missed entirely.

## What this means for vibe coding

An 85% mutation score sounds decent. But look closer:

- **Validators at 77.8%** means nearly 1 in 4 bugs in your validation logic would slip through.
- **Spec tests hit 91.7%** just by hiding the implementation, a 6.6% improvement for free.
- **Property tests found 11 real bugs** that all example tests missed entirely.

The tests feel comprehensive. They cover happy paths, several edge cases, have good line coverage. But coverage isn't verification. The tests confirm the implementation does what it does, not that it does what it should.

**Practical takeaways:**

- **Mutation testing as a check**: Run mutation testing on AI-generated code periodically. If mutants survive, you know where your blind spots are.
- **Specification-first when it matters**: For critical code, write tests before implementation, or at minimum hide the implementation from the model generating tests.
- **Properties over examples**: When possible, describe what invariants must hold rather than listing input-output pairs. This is harder but more robust.
- **Budget for human review**: The gaps mutation testing reveals are the gaps a human reviewer would catch. If you skip human review, those bugs ship.

## Summary

- Vibe-coded tests achieved an 85.1% mutation score, meaning 15% of introduced bugs would go undetected.
- Specification-first tests improved to 91.7% by hiding the implementation from the LLM.
- Property-based tests found 11 real bugs in the "working" implementation that all example tests missed.
- Surviving mutants reveal patterns: boundary conditions, error paths, implementation leakage, and missing adversarial cases.
- The approaches are complementary. Property tests excel at invariants, example tests at specific edge cases.
- Mutation testing makes test quality concrete and measurable, not just a feeling.

## The meta-point

Vibe coding optimizes for speed to first working version. That's valuable. But "working" means "passes the tests the same system wrote", which is a weaker guarantee than it appears.

Mutation testing makes this concrete. It's not about whether your tests pass. It's about whether your tests would fail if something was wrong.

The vibe tests caught 85% of mutations. The spec tests caught 92%. Property tests found bugs neither could see. Each approach has different blind spots, and the vibe approach, where the AI sees its own code before writing tests, consistently has the most.

**The vibes are efficient. They're not thorough.**

---

*References:*

- Source code for this experiment: [GitHub](https://github.com/choas/vibe-mutation-test)
- Stryker mutation testing framework: [stryker-mutator.io](https://stryker-mutator.io/)
- Vitest test runner: [vitest.dev](https://vitest.dev/)
- fast-check property-based testing: [GitHub](https://github.com/dubzzz/fast-check)
- Property-based testing introduction: [Hypothesis](https://hypothesis.works/articles/what-is-property-based-testing/)
- Mutation testing explained: [Wikipedia](https://en.wikipedia.org/wiki/Mutation_testing)

---

*This is Part 3 of a series. [Part 1](/2026/01/02/vibe-coding-testing/) covered the circular testing problem. [Part 2](/2026/01/06/independent-verification/) explored what independence means.*
