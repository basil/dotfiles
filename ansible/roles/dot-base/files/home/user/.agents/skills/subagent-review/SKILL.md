---
name: subagent-review
description: Review uncommitted changes by spawning a subagent to look for bugs and assess if the approach is principled or hacky. Use before committing to get a code review.
---

Spawn a subagent (smartest model available) to review the diff of uncommitted changes (both staged and unstaged). Explain to the subagent only the goal of the changes, not the rationale for the approach chosen. Ask the subagent to look for bugs and analyze if the changes are principled or hacky. Report all actionable findings, including nonblocking improvements, ordered by severity. Distinguish commit blockers from nonblocking suggestions. Inspect the complete diff and affected call sites, continuing after the first finding. Do not invent findings to meet a quota. Let the user see the feedback before committing.
