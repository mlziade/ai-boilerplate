#!/bin/bash
# Validates that git commit messages follow conventional commits format.
# Blocks commits that don't match before they go through.

COMMAND=$(cat - | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input', {}).get('command', ''))" 2>/dev/null)

# Only intercept git commit commands that include -m
if ! echo "$COMMAND" | grep -qE 'git commit.*-m'; then
  exit 0
fi

# Extract the message from -m "..." or -m '...'
MSG=$(echo "$COMMAND" | sed -E "s/.*-m ['\"]([^'\"]+)['\"].*/\1/")

if [ -z "$MSG" ]; then
  exit 0
fi

SUBJECT=$(echo "$MSG" | head -1)

# Validate conventional commit format: type(scope)?: subject
if ! echo "$SUBJECT" | grep -qE '^(feat|fix|refactor|docs|style|perf|test|chore|ci|build|revert)(\(.+\))?!?: .+'; then
  echo "Commit blocked: subject line must follow conventional commits format." >&2
  echo "" >&2
  echo "  Expected: <type>(<scope>): <subject>" >&2
  echo "  Types:    feat, fix, refactor, docs, style, perf, test, chore, ci, build, revert" >&2
  echo "  Example:  feat: add user authentication" >&2
  echo "" >&2
  echo "  Run /create-commit-message to generate a valid message." >&2
  exit 2
fi

# Validate subject line length (50–72 chars)
SUBJECT_LEN=${#SUBJECT}
if [ "$SUBJECT_LEN" -gt 72 ]; then
  echo "Commit blocked: subject line is $SUBJECT_LEN characters (max 72)." >&2
  exit 2
fi

exit 0
