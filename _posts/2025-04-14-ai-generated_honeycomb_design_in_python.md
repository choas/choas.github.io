---
layout:  post
title:   AI-Generated Honeycomb Design in Python
date:    2025-04-14 20:06 +0200
image:   honeycomb_fusion360.png
tags:    AI Fusion360
excerpt: Explore how I used AI to generate honeycomb SVG patterns in Python, overcoming challenges and refining designs. Plus, my take on whether AI will replace our jobs—it’s more of a partnership than you think.

---

> The tips of the hexagons in odd-numbered rows need to be perfectly centered between the hexagons in even-numbered rows.

[Bowlkeyboards](https://www.twitch.tv/bowlkeyboards) recently shared a project on Twitch where he designed a 3D-printed shelf with a container. Inspired by his idea, I decided to tweak the design by introducing a honeycomb pattern to save filament. First, I designed the hexagons manually. Later, I created a Python program to generate them more efficiently.

![honeycomb image](/images/honeycomb.png)

To achieve this, I generated an SVG file with honeycomb patterns and imported it into Fusion360 for further use. The process became an experiment—not just in design but also in exploring how AI could assist in writing the program for the task.

## Collaborating with AI: Claude 3.7

I used Claude 3.7, a large language model (LLM), for this project. Before starting, I wrote a detailed prompt to ensure the AI understood my requirements. The Python source code, along with the history of prompts and their iterations, is available on [my GitHub page](https://github.com/choas/honeycomb.svg). You will see the first version of the code that didn’t work as expected, along with the refined prompt.

I adjusted the first prompt for the second version. This brought me closer to the desired result, but the shifted row wasn’t centered properly. After trying to fix it with Claude and some prompts, I manually adjusted the calculations by subtracting half of the row-to-row distance.

I also asked Claude for clarification on how I should have phrased the requirement to center the shifted rows:

> The tips of the hexagons in odd-numbered rows need to be perfectly centered between the hexagons in even-numbered rows. Each hexagon in an odd row should have its center point positioned exactly halfway between the center points of two adjacent hexagons in the even rows. Make sure that all specified distances between hexagons are maintained while achieving this perfect interlocking pattern.

## Will AI Kill Our Jobs?

As a consultant, I’ve learned that there’s often a gap between what a customer asks for, what you understand, and what they actually expect. It’s a process of refining ideas, adjusting perceptions, and collaborating to reach the final outcome.

In many ways, working with AI feels similar. The first result might not match your vision, but with feedback, corrections, and patience, AI can become a useful partner. In this project, AI handled complex tasks like SVG code generation, width calculations, and saved me time.

So, will AI kill my job? Not anytime soon. AI is a tool that helps, not replaces—it enhances our capabilities and supports the creative process.

## Summary

AI played a supporting role in creating a honeycomb SVG generator, illustrating how collaboration between human expertise and machine learning leads to better outcomes. While AI can simplify technical tasks, the value of human knowledge and adaptability remains irreplaceable.
