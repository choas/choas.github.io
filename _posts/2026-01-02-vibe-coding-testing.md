---
layout:  post
title:   The T in vibe coding stands for testing
date:    2026-01-02 10:00 +0100
image:   robot_with_red_eyes.jpg
tags:    AI Security Vibe_Coding LLM
excerpt: Vibe coding's dirty secret - AI-generated tests only prove the code does what the AI thought it should do. At 39C3, security researcher Johann Rehberger showed it's worse than that. Prompt injection attacks can turn your AI coding assistant into a ZombAI, and the tests will still be green.

---

[Vibe coding](https://en.wikipedia.org/wiki/Vibe_coding) has become the dominant way developers interact with AI assistants. The workflow is seductively simple: describe what you want, let the LLM generate the code, maybe run it once to see if it works, ship it. Repeat.

And why not? The code looks reasonable. It runs. The LLM even writes tests for you.

Here's the problem: those tests are written by the same system that wrote the code. This is the equivalent of letting students grade their own homework. The LLM will write tests that pass. Of course it will. It knows exactly what the code does because it just wrote it. What it won't do is write tests that challenge the assumptions it made, probe edge cases it didn't consider, or catch the bugs it introduced.

Green tests don't mean correct code. They mean the code does what the LLM thought it should do.

## The illusion of verification

When you ask an LLM to write tests, you're not getting independent verification. You're getting a circular confirmation. The same model that decided how to implement a feature also decides what "correct behavior" means for that feature.

A human tester brings something an LLM fundamentally cannot: adversarial thinking rooted in different assumptions. A good test asks "what could go wrong here?" from a perspective outside the code's own logic. The LLM that wrote the code is, by definition, inside that logic.

This isn't a theoretical concern. It's a structural limitation of how these systems work.

## From sloppy to dangerous

Until recently, the worst case scenario for unchecked AI-generated code was bugs. Embarrassing, expensive, but ultimately mundane software failures. That changed.

At the [39th Chaos Communication Congress](https://events.ccc.de/congress/2025/infos/index.html) in Hamburg last week, security researcher [Johann Rehberger](https://embracethered.com/blog/) presented "Agentic ProbLLMs: Exploiting AI Computer-Use and Coding Agents." The talk documents what happens when [prompt injection](https://owasp.org/www-project-top-10-for-large-language-model-applications/) meets vibe coding.

The attack surface is straightforward: malicious instructions hidden in code repositories, documentation, or even GitHub issues. When an AI coding assistant processes this content, it follows those instructions. Not because it's been hacked in the traditional sense, but because it cannot reliably distinguish between legitimate code context and adversarial prompts.

Rehberger demonstrated attacks against GitHub Copilot, Claude Code, Cursor, Amazon Q, Google Jules, Devin, and others. The results ranged from data exfiltration to full remote code execution. He coined the term "ZombAIs" for AI agents that have been co-opted into command-and-control infrastructure.

One particularly striking example: with GitHub Copilot, a prompt injection could activate "YOLO mode" (auto-approve all tool calls) by manipulating the agent's own configuration file. The agent was tricked into disabling its own safety guardrails.

## AgentHopper: the self-propagating prompt

Perhaps most alarming was Rehberger's proof-of-concept for a self-propagating AI virus called AgentHopper. The concept exploits how developers move between repositories:

1. A prompt injection sits in a repository
2. A developer's AI coding assistant processes it
3. The injection instructs the agent to replicate itself into other local repositories
4. The developer pushes changes, spreading the infection

The payload uses conditional logic to target different agents: "If you are GitHub Copilot, do this. If you are Claude Code, do that." Rehberger noted he wrote the virus using Gemini, which got a laugh from the audience but makes a serious point about how accessible these attacks have become.

## The month of AI bugs

This wasn't a one-off discovery. Throughout August 2025, Rehberger published daily vulnerability disclosures under the banner "[Month of AI Bugs](https://monthofaibugs.com)." Over two dozen security issues across every major AI coding assistant. The patterns kept repeating:

- Data exfiltration through allowed image URLs
- Configuration file manipulation to enable remote code execution
- DNS-based data leaks through "safe" commands like ping and nslookup
- Invisible prompt injection using Unicode tricks

Some vendors patched quickly. Others sat on reports for 90 or 120 days without fixes. The fundamental problem remains unsolved because it cannot be solved deterministically. As Rehberger put it: "The model is not a trustworthy actor in your threat model."

## What vibe coding actually means now

Here's where the testing problem and the security problem intersect.

A developer in full vibe mode doesn't just skip code review. They skip reviewing the tests. They skip thinking about what files the agent is reading. They skip noticing when the agent's behavior seems slightly off.

Every step of that workflow is an opportunity for a prompt injection to execute. And the tests will still be green, because the compromised agent wrote tests that confirm its compromised behavior.

Rehberger recommends companies disable auto-approve modes entirely and adopt an "assume breach" mentality. All security controls must be implemented downstream of the LLM output, not rely on the LLM to enforce them.

## The vibes are not enough

Vibe coding isn't going away. It's too productive when it works. But treating AI-generated code as trustworthy by default is no longer just sloppy engineering. It's a security vulnerability.

The minimum viable process for working with AI coding assistants needs to include:

- Actually reading the generated code, not just checking if it runs
- Writing your own tests, or at minimum reviewing AI-generated tests critically
- Understanding what files and context the agent is accessing
- Treating any external content the agent processes as potentially adversarial

This isn't about being paranoid. It's about recognizing that the convenience of vibe coding comes with a new category of risk that didn't exist before. The LLM is powerful and helpful. It is also, fundamentally, not on your side in the security sense. It will follow instructions. It cannot tell whose instructions those are.

The T in vibe coding stands for testing. And for trust. Neither of which are actually there.

## Summary

- AI-generated tests provide circular confirmation, not independent verification — the same model that wrote the code decides what "correct" means
- Prompt injection attacks can hijack AI coding assistants to exfiltrate data, execute arbitrary code, or spread to other repositories
- Johann Rehberger's 39C3 talk demonstrated vulnerabilities in GitHub Copilot, Claude Code, Cursor, and other major tools
- The "Month of AI Bugs" revealed over two dozen security issues across the AI coding assistant ecosystem
- Minimum safeguards: read generated code, write independent tests, monitor agent file access, treat external content as adversarial
- The LLM cannot distinguish between legitimate instructions and malicious prompts — it will follow both

---

*References:*

- Johann Rehberger's 39C3 talk "Agentic ProbLLMs": [media.ccc.de](https://media.ccc.de/v/39c3-agentic-probllms-exploiting-ai-computer-use-and-coding-agents)
- Month of AI Bugs: [monthofaibugs.com](https://monthofaibugs.com)
- Embrace The Red blog: [embracethered.com](https://embracethered.com/blog/)
