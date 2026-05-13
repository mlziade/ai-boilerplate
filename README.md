# mlziade-boilerplate

My personal boilerplate for developing with AI and Claude Code. This repo centralizes skills, agents, preferences, and tech-stack starter knowledge so all my new projects start with a solid foundation.

## What's in here

| Directory | Purpose |
|---|---|
| `.claude/skills/` | Custom slash commands — repeatable workflows I invoke with `/skill-name` |
| `.claude/agents/` | Custom sub-agent definitions with specialized roles and tool access |
| `.claude/hooks/` | Shell scripts triggered at Claude Code lifecycle events |
| `knowledge/` | Per-stack CLAUDE.md files I import into new projects |
| `CLAUDE.md` | My personal preferences, loaded in every session |

## Concepts

**[Skills](docs/skills.md)** — Packaged, reusable workflows invoked as slash commands. Create a `SKILL.md` file and Claude adds `/skill-name` to its toolkit.

**[Agents](docs/agents.md)** — Custom sub-agents with their own system prompts, tool access, and optional persistent memory. Useful for specialized roles like security review or deep research.

**[Hooks](docs/hooks.md)** — Shell commands that run automatically at lifecycle events (before/after tool use, on session start, etc.). Use them to enforce policies, auto-format, or inject context.

**[Auto Memory](docs/auto-memory.md)** — Claude writes its own notes across sessions (build commands, debugging insights, preferences it discovers). No setup needed; runs automatically per repository.

**[Tech-stack Knowledge](docs/tech-stack-knowledge.md)** — CLAUDE.md files in `knowledge/` that capture conventions and best practices for specific stacks. Import them into a new project so Claude starts informed.

## Resources

- [Claude Code docs](https://code.claude.com/docs/en/overview)
- [Skills reference](https://code.claude.com/docs/en/skills)
- [Memory / CLAUDE.md](https://code.claude.com/docs/en/memory)
- [Hooks reference](https://code.claude.com/docs/en/hooks)
- [Sub-agents](https://code.claude.com/docs/en/sub-agents)
