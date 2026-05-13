---
name: create-commit-message
description: Analyzes the conversation context and staged git changes to suggest a well-formatted commit message. Use when the user wants to commit changes and needs a commit message suggestion.
user-invocable: true
---

# Create Commit Message

You will analyze the conversation context and staged git changes to suggest a well-formatted commit message that follows the repository's commit message conventions.

## Instructions

1. **Gather Context**: Review the conversation history to understand what changes were made and why.

2. **Analyze Staged Changes**: Run `git diff --cached` to see all staged changes that will be committed.

3. **Review Recent Commits**: Run `git log --oneline -5` to understand the commit message style used in this repository.

4. **Draft Commit Message**: Based on the analysis, create a commit message that:
   - Starts with a type prefix (e.g., feat:, fix:, refactor:, docs:, style:, perf:, test:, chore:)
   - Has a concise subject line (50-72 characters) that summarizes the change
   - Uses imperative mood (e.g., "add feature" not "added feature")
   - Includes a body with more details if needed (wrap at 72 characters)
   - Focuses on the "why" and "what" rather than the "how"
   - Accurately reflects the actual changes made

5. **Present the Suggestion**: Display the suggested commit message in a code block, clearly formatted for easy copying.

## Output Format

Present your suggestion in this format:

```
<type>: <subject line>

<optional body with more context>
```

Example:
```
feat: add commit message generator skill

Implement a new Claude skill that analyzes conversation context
and staged changes to suggest well-formatted commit messages
following repository conventions.
```

## Important Notes

- DO NOT commit the changes - only suggest the message
- Ensure the message accurately reflects all staged changes
- Match the tone and style of existing commits in the repository
- Keep the subject line concise and actionable
- Include context in the body if the changes are complex or non-obvious
- Never add "made by Claude" or similar phrases in the commit message
