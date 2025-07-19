---
layout:  post
title:   How to explain MCP (Model Context Protocol) and what are its advantages?
date:    2025-07-19 17:30 +0200
image:   mcp.png
tags:    AI MCP LLM
excerpt: Ever wondered why AI gives you meeting dates from 2023 when you ask for "next week"? Dive into Model Context Protocol (MCP) — Anthropic's game-changing approach that connects LLMs to real-world data. I tested three different AI models with the same scheduling request and built several MCP services you can try at try-mcp.dev!

---

> "The bridge that blooms mirror reveals the time of river" — Fortune Cookie from try-mcp.dev

An API - an interface to a system - is simply called with the appropriate values to trigger some action. Typically, it's the job of a software developer or tool to pass the correct values in the proper format. However, if you want to set the values manually, you need to understand how formats like dates are structured. Interface documentation might specify something like the ISO 8601 format (YYYY-MM-DDTHH:MM:SS).

So where does MCP fit into this picture? MCP stands for Model Context Protocol and provides models with contextual understanding. Anthropic created it to connect Large Language Models (LLMs) with external tools and services through structured interfaces. Consider a service that offers an interface with method names and parameters. With MCP, these methods get additional context describing what they actually do. In my example, I built a service with the method get_random_timestamp, described as: "Random timestamp generator service for creating timestamps within specified ranges".

Let's step back for a moment. Humans can easily understand this description. When I need a random date for some use case, I examine the parameter structure and call the method with the right arguments. Of course, I still need to program which parts of my application call this method. For instance, if another method needs a date that hasn't been set, it might just generate a random one. But this approach creates rigid, hard-coded connections rather than flexible integrations.

## Comparing different LLMs with and without MCP

Large Language Models such as ChatGPT, Anthropic's Claude Sonnet, or locally-running models like Gemma3 do not actually understand content — they produce responses based on patterns in the data they were trained on. To illustrate this, let's look at a practical scenario involving two user inputs:

### Scenario 1: Appointment suggestion for next week

- I want to meet with Hans-Peter next week. Just suggest a day and time.
- He doesn't have time, not until next month.

**Local LLM without tool integration:** The local model suggests either Wednesday 14:00 or - lacking knowledge of today's date - Tuesday, May 14th at 14:00, which clearly isn't next week.

**ChatGPT with Bing integration:** ChatGPT through Bing suggests two options: Thursday at 18:30 during the week and Saturday at 11:00 on the weekend. Without specific dates, it's hard to go wrong.

**Claude Desktop with MCP integration:** Claude Desktop, using its random date integration, suggests Thursday, July 24th at 9:00. Interestingly, the underlying service actually returned 6:31 for the random timestamp.

### Scenario 2: Rescheduling for next month

Now consider Hans-Peter's response, that "he doesn't have time until next month."

**Local LLM without tool integration:** The local model suggests November, as it does not know that we are in July. After I clarified that next month is August, it proposed Tuesday, August 8th at 14:00. The problem? August 8th was indeed a Tuesday in 2023, but not in 2025.

**ChatGPT with Bing integration:** ChatGPT initially suggested September, which surprised me as it was able to successfully tell me today's date. After pointing this out and requesting again, it offered Thursday, August 15th at 18:30 and Sunday, August 18th around 14:00. However, August 18th isn't a Sunday in 2025. This shows ChatGPT only considers current dates when explicitly prompted.

**Claude Desktop with MCP integration:** Claude Desktop has used the MCP service for random dates, which correctly takes into account the current date and returns results with the correct year.

## MCP's advantages become evident

Even from these simple examples, the value of MCP services becomes clear. Claude Desktop understands which tools are available and when to use them contextually. With ChatGPT, I had to explicitly mention the date issue before it likely accessed current date information internally. Local LLMs without tool integration have no way to handle current dates properly - they only align with suggested dates when I manually provide August's weekday information.

Another key advantage of combining LLMs with MCP is the standardized parameter formats. The LLM can automatically generate start and end values in the proper format for random date selection based purely on context. The parameter descriptions provide all necessary information - for the start time parameter: "Start time in ISO 8601 format (YYYY-MM-DDTHH:MM:SS). Defaults to tomorrow at 10:00 if not provided."

Notice how the start time includes a default value for cases where applications don't specify one, or when inputs like "Give me a timestamp" lack explicit timing. Based on context and parameter specifications, Claude Desktop knows when it doesn't need to set explicit values.

To verify this behavior, I asked Claude Desktop "Why did you choose tomorrow?" and received this response:

"I didn't consciously choose tomorrow - that was the timestamp generator's randomness!

When you asked for a timestamp, I used the random timestamp generation tool with default settings: 'day_offset' of 1 (meaning 'tomorrow') and 'day_period' set to 'day' (daytime between 10:00 and 16:00). The tool then randomly selected July 20, 2025 at 12:03:28."


## The MCP service ecosystem

Beyond the random date service, I've built several additional services with the help of [AWS Kiro](https://kiro.dev/) and Claude Sonnet. You can test all of them at [try-mcp.dev](https://try-mcp.dev):

**MVG Service**: Munich public transport with departure times and station information

- get_departures: Retrieve departure times from Munich stations
- find_station: Locate stations within Munich's transit system

**Mindful Service**: Daily inspiration with rotating motivational content

- get_mindful_sentence: Provides 4 different inspiring sentences each day

**Emoji Oracle Service**: Cryptic guidance through symbolic emoji combinations

- get_emoji_oracle: Delivers 3 meaningful emojis with mystical interpretations

**Fortune Service**: Digital fortune cookies with surreal phrases

- get_fortune_cookie: Hourly rotating surreal fortune cookie messages

**Timestamp Service**: Random timestamp generation

- generate_random_timestamp: Creates random timestamps within specified ranges

**Weather Service**: Optimistic weather forecasting

- get_weather_forecast: Always delivers positive weather predictions for tomorrow

**Lucky Numbers Service**: Statistically blessed number generation

- generate_blessed_numbers: Mystically optimized numbers for various life scenarios

## Summary

Anthropic's Model Context Protocol (MCP) enables Large Language Models to access external tools and services in a structured manner, allowing them to work with current data and contextual awareness. While local LLMs and even ChatGPT often provide inaccurate or outdated information for time-sensitive tasks, LLMs with tool integration like MCP reliably leverage external services for precise results. MCP represents a significant step forward for practical AI applications that extend beyond simple text generation.

Try building your own MCP-compatible service or explore existing ones at [try-mcp.dev](https://try-mcp.dev). It’s easier than you think!
