# Hooks

Hooks are shell commands that run automatically at Claude Code lifecycle events. Use them to enforce policies, auto-format after edits, inject context at session start, or block dangerous operations — without relying on Claude to remember.

Unlike CLAUDE.md instructions, hooks are deterministic: they run regardless of what Claude decides to do.

## Configuration

Hooks are defined in `settings.json`. Use `.claude/settings.json` for project-scoped hooks (committed to the repo) or `~/.claude/settings.json` for personal hooks that apply everywhere.

```json
{
  "hooks": {
    "<EventName>": [
      {
        "matcher": "<tool-name or pattern>",
        "hooks": [
          {
            "type": "command",
            "command": "your-script-or-command"
          }
        ]
      }
    ]
  }
}
```

## Lifecycle events

| Event | When it fires | Can block? |
|---|---|---|
| `SessionStart` | Session begins or resumes | No |
| `UserPromptSubmit` | Before Claude processes your message | Yes |
| `PreToolUse` | Before a tool executes | Yes |
| `PostToolUse` | After a tool succeeds | No |
| `Stop` | Claude finishes responding | Yes |
| `SessionEnd` | Session ends | No |

`PreToolUse` and `UserPromptSubmit` hooks can block by exiting with code `2`.

## Matchers

Matchers filter which tool calls trigger the hook. Supports exact names, `|` for OR, and regex:

```json
"matcher": "Bash"              // only Bash tool
"matcher": "Write|Edit"        // Write or Edit
"matcher": "mcp__memory__.*"   // all memory server tools (regex)
"matcher": "^Notebook"         // any tool starting with Notebook
```

For `PreToolUse` and `PostToolUse`, you can also use permission-style patterns in an `if` field to filter by the specific command being run:

```json
{
  "matcher": "Bash",
  "if": "Bash(rm *)"
}
```

## Hook types

**`command`** — Shell script or command. Receives JSON on stdin.

```json
{
  "type": "command",
  "command": ".claude/hooks/validate.sh"
}
```

**`http`** — POST to an HTTP endpoint. Useful for remote policy services.

```json
{
  "type": "http",
  "url": "http://policy-service.internal/validate",
  "timeout": 10
}
```

## Exit codes and output

| Exit code | Meaning |
|---|---|
| `0` | Allow (optionally output JSON for finer control) |
| `2` | Block — tool call is denied, stderr shown to user |
| Other | Non-blocking error — execution continues |

To send a reason back to Claude when blocking:

```bash
echo '{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "deny", "permissionDecisionReason": "Destructive rm -rf is not allowed"}}' 
exit 2
```

To inject additional context without blocking:

```bash
echo '{"hookSpecificOutput": {"hookEventName": "PreToolUse", "additionalContext": "Note: this file is auto-generated"}}'
exit 0
```

## Examples

### Auto-format after every file write

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "prettier --write ${tool_input.file_path} 2>/dev/null || true"
          }
        ]
      }
    ]
  }
}
```

### Block `rm -rf`

Save this to `.claude/hooks/block-dangerous-rm.sh`:

```bash
#!/bin/bash
COMMAND=$(cat - | python3 -c "import sys,json; print(json.load(sys.stdin)['tool_input']['command'])" 2>/dev/null)

if echo "$COMMAND" | grep -qE 'rm\s+-[a-zA-Z]*r[a-zA-Z]*f|rm\s+-[a-zA-Z]*f[a-zA-Z]*r'; then
  echo "Blocked: rm -rf is not allowed" >&2
  exit 2
fi
```

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{"type": "command", "command": ".claude/hooks/block-dangerous-rm.sh"}]
      }
    ]
  }
}
```

### Inject git context at session start

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo '{\"hookSpecificOutput\": {\"hookEventName\": \"SessionStart\", \"additionalContext\": \"Branch: '$(git branch --show-current)'\"}}'}"
          }
        ]
      }
    ]
  }
}
```

## Tips

- Store hook scripts in `.claude/hooks/` and reference them by path. Inline shell in JSON gets messy fast.
- `PostToolUse` hooks cannot block, but they're useful for side effects like formatting or logging.
- Test hooks manually by running the script with sample JSON on stdin before wiring it up.
- Use `PreToolUse` + `if` filters to be precise — broad matchers run on every tool call.
