---
layout:  post
title:   "The T in vibe coding stands for testing (Part 2): What independence actually means"
date:    2026-01-06 09:00 +0100
image:   robot_with_red_eyes_part2.jpg
credit:  Nano Banana Pro - A robot/AI assistant with glowing red eyes, puppet strings attached, or zombie-like decay - visualizing the "circular validation" concept; use as image size 1168x768
tags:    AI Security Vibe_Coding LLM Testing
excerpt: "Using a different LLM for testing sounds like it would create independence. It doesn't. The moment any model sees your implementation, it reasons about what the code does, not what it should do. Real independence requires different information sources, not different systems."

---

In [Part 1](/2026/01/02/vibe-coding-testing/), I argued that LLM-generated tests are fundamentally circular: the same system that wrote the code decides what "correct" means. The obvious response is: use a different LLM for testing.

This sounds reasonable. It doesn't work. Here's why.

## The contamination problem

The moment any LLM sees your implementation, it reasons about what the code *does*, not what it *should do*. It reverse-engineers intent from behavior. This is true regardless of which model you use.

Consider a function that calculates discount eligibility. The implementation checks if a customer has been active for 12 months. But the actual business rule, known only to the product team, is 12 months *and* at least 3 purchases. When you ask an LLM to write tests, it looks at the code and writes tests that verify the 12-month check works perfectly. Tests pass. The discount logic is still wrong.

A different LLM does the same thing. [Claude](https://www.anthropic.com/claude), [GPT](https://openai.com/), [Gemini](https://deepmind.google/technologies/gemini/), [Llama](https://www.llama.com/): they all share similar training data, similar reasoning patterns, and the same fundamental limitation. They predict what tests would make sense given the code they're looking at. They don't know what the product team decided in last month's planning meeting.

## What humans bring that LLMs can't

When a human tester reviews code, they bring something outside the code itself:

- **Experience** with real users who do unexpected things
- **Memory** of bugs they've seen before in similar systems
- **Domain knowledge** that exists in their head, not in the codebase
- **Adversarial stance**: "I'm here to break this"

An LLM has none of that. It has patterns from training data. Those patterns are heavily biased toward code that works, tests that pass, examples that demonstrate correct behavior. It's trained on the happy path.

Ask an LLM to "think adversarially" or "consider edge cases" and it will produce something that *looks* adversarial. It will add tests for null inputs and empty strings because that's what edge case tests look like in training data. Whether those are the actual edge cases that matter for your specific system is a different question.

## Independence means different information, not different systems

Here's the core insight: switching models doesn't create independence. Independence requires different information sources.

A human tester is independent because they approach the code with knowledge the code doesn't contain: user behavior patterns, business context, historical bugs, intuition built from years of seeing software fail in production.

An LLM given the same code will produce similar tests regardless of which LLM you use. The information constraining its reasoning is the implementation itself. That's the contamination.

## What actual independence would look like

If you want genuinely independent LLM-generated tests, the LLM cannot see the implementation. It can only see the specification.

"Write tests for a discount eligibility function. A customer is eligible if they've been active for at least 12 months AND have made at least 3 purchases. Edge cases: customers who became inactive and reactivated, purchases that were refunded, and corporate accounts which are always eligible."

Now the LLM generates tests based on what the business requires, not what the code happens to do. Those tests become a specification that your implementation must satisfy, not just an automatic approval of whatever you built.

This is [test-driven development](https://en.wikipedia.org/wiki/Test-driven_development), but with a twist: the specification comes from human requirements, the test generation can be assisted by AI, and the implementation is verified against externally-defined correctness.

This is also the insight behind [Behavior-Driven Development](https://en.wikipedia.org/wiki/Behavior-driven_development) and tools like [Cucumber](https://cucumber.io/). When product owners write acceptance criteria in Gherkin's Given/When/Then format, they define expected behavior from business requirements, not from looking at code. The specification exists before the implementation. In practice, developers often end up writing the Gherkin too, which undermines the independence. But the principle is sound: whoever defines "correct" shouldn't be the same person (or system) that wrote the code.

## Property-based testing as structural independence

There's another path to independence that doesn't rely on hiding information: [property-based testing](https://hypothesis.works/articles/what-is-property-based-testing/).

Instead of "given input X, expect output Y", property-based tests ask "what invariants must always hold?"

For that discount eligibility function:
- If a customer is eligible, removing a purchase should eventually make them ineligible
- If a customer is ineligible due to account age, no number of purchases should make them eligible
- Corporate accounts are always eligible regardless of other factors
- Eligibility should never depend on the order in which purchases were made

These properties can be verified against thousands of generated customer profiles. The LLM doesn't need to anticipate every edge case. It needs to describe what "correct" means in terms of relationships and invariants.

This is harder to write but more robust. The tests don't encode specific behaviors. They encode constraints that any correct implementation must satisfy.

## The uncomfortable conclusion

There's no prompt that makes LLM-generated tests truly independent if the LLM has seen your code. "Be adversarial" and "think of edge cases" produce tests that look independent but aren't.

Real options are:

- **Specification-first testing**: The LLM writes tests before seeing the implementation. This requires discipline and upfront work that vibe coding explicitly avoids.
- **Property-based testing**: The LLM describes invariants rather than expected outputs. This requires a different mental model of what tests are for.
- **Human review**: A person with domain knowledge and adversarial intent evaluates both code and tests. This is expensive and doesn't scale.

All of these are friction. All of them slow down the vibe coding workflow. That's not a bug. **The speed of vibe coding comes from skipping verification.** Adding real verification means accepting that some of that speed was borrowed against future bugs.

## Summary

- Switching LLMs doesn't create test independence because all models share similar training data and reasoning patterns.
- The moment an LLM sees your implementation, it reasons about what the code *does*, not what it *should do*.
- Human testers bring external knowledge that LLMs lack: user behavior, domain expertise, historical bugs, and adversarial thinking.
- True independence requires different information sources, such as specification-first testing or property-based testing.
- Property-based tests encode invariants and constraints rather than specific input-output pairs.
- The speed of vibe coding comes from skipping verification. Real testing adds friction by design.

## What's next

Theory is nice. Data is better.

In Part 3, I'll run an experiment: take AI-generated code with AI-generated tests and subject them to [mutation testing](https://en.wikipedia.org/wiki/Mutation_testing). Mutation testing introduces small bugs into the code and checks whether the tests catch them. If the tests are good, mutants die. If the tests are self-confirming approvals, mutants survive.

The survival rate will tell us something concrete about how much verification we're actually getting from the vibe coding workflow.

---

*References:*

- Property-based testing introduction: [Hypothesis](https://hypothesis.works/articles/what-is-property-based-testing/)
- Test-driven development: [Wikipedia](https://en.wikipedia.org/wiki/Test-driven_development)
- Behavior-Driven Development: [Wikipedia](https://en.wikipedia.org/wiki/Behavior-driven_development)
- Cucumber BDD tool: [cucumber.io](https://cucumber.io/)
- Mutation testing explained: [Wikipedia](https://en.wikipedia.org/wiki/Mutation_testing)
- Vibe coding: [Wikipedia](https://en.wikipedia.org/wiki/Vibe_coding)

---

*This is Part 2 of a series. [Part 1](/2026/01/02/vibe-coding-testing/) covered the circular testing problem and prompt injection risks.*
