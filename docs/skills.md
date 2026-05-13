# Skills

Skills are reusable workflows packaged as slash commands. Create a `SKILL.md` and Claude adds `/skill-name` to its toolkit — invoke it yourself or let Claude trigger it automatically when relevant.

## Where skills live

| Location | Applies to |
|---|---|
| `~/.claude/skills/<skill-name>/` | All your projects (personal) |
| `.claude/skills/<skill-name>/` | Current project only |

Skills stored in this repo's `.claude/skills/` are project-scoped. To make one available everywhere, copy or symlink its directory into `~/.claude/skills/`.

## File structure

```
.claude/skills/
└── my-skill/
    ├── SKILL.md          # Required — instructions + frontmatter
    ├── reference.md      # Optional supporting files
    └── scripts/
        └── helper.py
```

The directory name becomes the slash command. `my-skill/` → `/my-skill`.

## Creating a skill

Every skill needs a `SKILL.md` with YAML frontmatter between `---` markers, followed by the instructions Claude follows when the skill runs.

```yaml
---
description: What this skill does and when to use it.
---

Your instructions here.
```

### Minimal example

```yaml
---
description: Summarize uncommitted changes and flag anything risky.
---

## Current changes
!`git diff HEAD`

Summarize the above in 2–3 bullets, then list any risks (missing error handling, hardcoded values, tests that need updating).
```

Save to `.claude/skills/summarize-changes/SKILL.md`. Invoke with `/summarize-changes` or by asking "what did I change?".

## Frontmatter reference

| Field | Description |
|---|---|
| `description` | What the skill does. Claude uses this to decide when to auto-invoke. Put the key use case first. |
| `disable-model-invocation: true` | Only you can invoke it. Use for side-effectful ops (deploy, commit, send message). |
| `user-invocable: false` | Only Claude auto-invokes it. Use for background knowledge, not a command. |
| `allowed-tools` | Tools Claude can use without prompting while the skill is active. E.g. `Bash(git *) Read` |
| `context: fork` | Run in an isolated sub-agent. The skill content becomes the sub-agent's prompt. |
| `agent` | Which sub-agent type to use when `context: fork` is set. E.g. `Explore`, `Plan`. |
| `argument-hint` | Shown in autocomplete. E.g. `[issue-number]` |
| `arguments` | Named positional args for `$name` substitution. |

## Passing arguments

Use `$ARGUMENTS` for everything the user typed after the skill name, or `$0`, `$1`, `$name` for positional args.

```yaml
---
name: fix-issue
description: Fix a GitHub issue by number
disable-model-invocation: true
---

Fix GitHub issue $ARGUMENTS following our coding standards.

1. Read the issue with `gh issue view $ARGUMENTS`
2. Understand the requirements
3. Implement the fix
4. Write tests
5. Commit
```

Invoke with: `/fix-issue 42`

Named arguments (declared in `arguments` frontmatter):

```yaml
---
arguments: [component, from_framework, to_framework]
---

Migrate the $component component from $from_framework to $to_framework.
Preserve all existing behavior and tests.
```

## Dynamic context injection

Prefix a shell command with `` !` `` to run it before Claude sees the skill. The output replaces the line.

```yaml
---
description: Review the current pull request.
allowed-tools: Bash(gh *)
---

## PR diff
!`gh pr diff`

## PR comments
!`gh pr view --comments`

Review for: correctness, security issues, missing tests, style violations.
```

For multi-line commands, use a fenced block opened with ` ```! `:

````markdown
## Environment
```!
node --version
npm --version
git status --short
```
````

## Controlling who invokes the skill

```yaml
# Only you can invoke (deploy, commit, anything with side effects)
disable-model-invocation: true

# Only Claude auto-invokes (background knowledge users shouldn't run directly)
user-invocable: false
```

## Running in a sub-agent

Add `context: fork` to run the skill in isolation. The skill content becomes the sub-agent's task prompt — your conversation history is not passed.

```yaml
---
description: Research a topic thoroughly across the codebase
context: fork
agent: Explore
---

Research $ARGUMENTS:
1. Find relevant files with Glob and Grep
2. Read and analyze the code
3. Summarize findings with specific file references
```

## Tips

- Keep `SKILL.md` under 500 lines. Move large reference material to separate files and link them.
- Skill content stays in context for the whole session once invoked — every line is a recurring token cost.
- Use `disable-model-invocation: true` for anything destructive or time-sensitive that you want to control explicitly.
- The `description` is what Claude uses to decide whether to auto-load the skill. Make it match the natural language you'd actually use.
