---
name: create-skill
description: Analyzes the conversation history to identify a repeatable workflow and packages it as a new skill. Use when the user wants to turn something discussed in chat into a reusable slash command.
disable-model-invocation: true
allowed-tools: Read Write Bash(mkdir *)
argument-hint: [description or guidance]
---

# Create Skill from Conversation

You will analyze the current conversation history to extract a repeatable workflow and package it as a new Claude Code skill.

## Instructions

1. **Identify the workflow**: Review the conversation and identify the task or procedure the user wants to turn into a skill. If `$ARGUMENTS` was provided, treat it as guiding intent — use it to focus on the relevant part of the conversation and shape the skill's purpose. Infer a short kebab-case name from the workflow or the argument itself.

2. **Extract the logic**: Pull out the steps, commands, patterns, and decisions from the conversation that should be part of the skill. Focus on what is repeatable and generalizable — strip out anything specific to the current session.

3. **Determine invocation style**: Decide based on the workflow:
   - Does it have side effects (writes files, commits, deploys)? → `disable-model-invocation: true`
   - Does it need arguments? → add `argument-hint` and use `$ARGUMENTS`
   - Should it run in isolation? → `context: fork`

4. **Write the skill**: Create the skill at `.claude/skills/<skill-name>/SKILL.md` with:
   - YAML frontmatter (`name`, `description`, and any relevant flags)
   - Clear, concise instructions Claude will follow when the skill runs
   - Dynamic context injection (`` !`command` ``) where live data is needed

5. **Confirm**: Show the user the created file path and a summary of what the skill does and how to invoke it.

## Skill structure to follow

```yaml
---
name: <kebab-case-name>
description: <what it does and when to use it — this is what Claude reads to decide when to auto-invoke>
disable-model-invocation: true   # include if the skill has side effects
argument-hint: [optional-arg]    # include if the skill takes arguments
---

# Skill Title

<instructions for Claude>
```

## Rules

- Keep `SKILL.md` under 500 lines
- Description must be specific enough that Claude knows exactly when to use it
- Do not include session-specific details — the skill must work in any future conversation
- If the workflow needs live data, use `!` shell injection rather than asking Claude to run commands
- After writing the file, tell the user the invoke command (e.g. `/skill-name`)
