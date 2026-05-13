# Auto Memory

Auto memory lets Claude accumulate knowledge across sessions without you writing anything. As it works, Claude saves notes about your project — build commands, debugging patterns, architecture decisions, code style preferences. Those notes are loaded at the start of every future session.

## How it works

Claude writes to a memory directory scoped to each git repository:

```
~/.claude/projects/<repo>/memory/
├── MEMORY.md          # Index file — loaded at every session start (first 200 lines)
├── debugging.md       # Topic files — loaded on demand, not at startup
├── api-conventions.md
└── ...
```

`MEMORY.md` is a concise index. Claude keeps it short by offloading details into topic files, which it reads only when relevant. You never need to touch these files, but you can.

## Enabling and disabling

Auto memory is on by default. To toggle it in a session, run `/memory` and use the auto memory toggle.

To disable it project-wide, add to `.claude/settings.json`:

```json
{
  "autoMemoryEnabled": false
}
```

Or via environment variable: `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`

## What Claude saves

Claude decides what's worth remembering based on whether it would be useful in a future session. Common saves:

- Build and test commands it had to discover
- Debugging insights from resolved issues
- Preferences you expressed (e.g. "always use pnpm, not npm")
- Architecture notes about non-obvious structure
- Corrections you gave it that it should not repeat

Claude does not save something every session — only when it learns something new.

## Browsing and editing memory

Run `/memory` in a session to:

- See all CLAUDE.md, rules, and auto memory files loaded for the current session
- Open any memory file directly in your editor
- Toggle auto memory on/off

Since memory files are plain markdown, you can also edit or delete them directly:

```
~/.claude/projects/<repo>/memory/
```

To ask Claude to remember something explicitly: "remember to always use pnpm, not npm." Claude saves it to auto memory immediately.

To add something to CLAUDE.md instead (more permanent, loaded earlier): "add this to CLAUDE.md."

## Scope

Auto memory is per git repository and machine-local. All worktrees and subdirectories within the same repo share one memory directory. It is not synced across machines or cloud environments.

## Difference from CLAUDE.md

| | CLAUDE.md | Auto memory |
|---|---|---|
| Who writes it | You | Claude |
| What it contains | Instructions and rules | Learnings and patterns |
| Loaded at startup | Always, in full | First 200 lines of MEMORY.md |
| Use for | Conventions, workflows, standards | Build commands, debugging insights, discovered preferences |
