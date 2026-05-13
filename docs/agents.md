# Agents

Agents are custom sub-agents with their own system prompts, tool access, and optional persistent memory. They're useful when you want Claude to take on a specialized role — security reviewer, architect, researcher — with consistent behavior across sessions.

Claude Code includes built-in agent types (`Explore`, `Plan`, `general-purpose`). Custom agents extend these with your own instructions and constraints.

## Where agents live

```
.claude/agents/
└── security-reviewer.md
```

Agents are project-scoped. There is no personal agents directory — if you want an agent available everywhere, keep it in this boilerplate and reference it from projects that need it.

## Creating an agent

An agent is a markdown file with YAML frontmatter and a system prompt body.

```yaml
---
name: security-reviewer
description: Specialized agent for reviewing code changes for security issues
allowed-tools: Read Grep Glob Bash(git diff *) Bash(git log *)
---

You are a security-focused code reviewer. When called, you:

1. Analyze the provided code or diff for security vulnerabilities
2. Check for OWASP Top 10 issues (injection, broken auth, XSS, etc.)
3. Flag hardcoded secrets, overly broad permissions, and missing input validation
4. Suggest concrete fixes, not just observations

Be thorough but concise. Report findings as a prioritized list: Critical → High → Medium → Low.
```

## Frontmatter reference

| Field | Description |
|---|---|
| `name` | Display name. Defaults to the filename without extension. |
| `description` | What the agent does and when to use it. Claude uses this for auto-selection. |
| `allowed-tools` | Tools the agent can use without prompting. Use tool-specific patterns like `Bash(git *)` to scope access. |
| `model` | Override the model for this agent. E.g. `claude-opus-4-7`. |
| `effort` | Effort level: `low`, `medium`, `high`, `xhigh`, `max`. |

## Using an agent from a skill

Skills can delegate to agents with `context: fork` + `agent: <name>`:

```yaml
# .claude/skills/security-review/SKILL.md
---
description: Run a security review of the current changes
context: fork
agent: security-reviewer
disable-model-invocation: true
---

Review the following changes for security issues:

!`git diff main`
```

When this skill runs, it launches `security-reviewer` as an isolated sub-agent. The skill content becomes its task. Results are summarized back into your main conversation.

## Persistent memory for agents

Agents can maintain their own memory across sessions. Enable it in the agent's frontmatter:

```yaml
---
name: architect
description: System design and architecture decisions
autoMemoryEnabled: true
---

You are a software architect focused on...
```

The agent's memory is stored separately from the main session memory, keeping its learnings scoped to its domain.

## Built-in agent types

These are available without any setup and can be referenced in skill frontmatter:

| Agent | Best for |
|---|---|
| `Explore` | Read-only codebase research (Glob, Grep, Read only) |
| `Plan` | Architecture planning and design docs |
| `general-purpose` | Default — full tool access |

## Tips

- Keep the system prompt focused on role and behavior, not on a specific task. Tasks come from the skill or the conversation.
- Use `allowed-tools` to restrict access — a security reviewer doesn't need `Write` or `Edit`.
- If an agent is spawned from a skill with `context: fork`, it does not see your conversation history. Write the skill content to be self-contained.
