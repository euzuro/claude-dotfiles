---
name: worktree
description: |
  Use this skill when the user says things like:
  - "create a worktree"
  - "start a worktree"
  - "work in a worktree"
  - "new worktree"
  - "worktree for SXS-1234"
  - "worktree for this branch"
  Creates an isolated git worktree for parallel development.
---

## Input

The user provided: $ARGUMENTS

## Overview

Create a git worktree so the user can work on a separate branch in an isolated directory without affecting their main working tree. This is useful for parallel development, code reviews, or quick fixes while keeping the main tree clean.

## Step 1: Determine Worktree Name and Branch

Parse the input to determine the worktree name:

- If a Jira ticket ID is provided (e.g., `SXS-1234`), use it as the branch name: `erik.uzureau/SXS-1234`
- If NO Jira ticket ID is provided, ask the user for the JIRA ticket ID before proceeding. Do not accept arbitrary names — a JIRA ticket is required.

The base branch is always `preprod` unless the user explicitly requests a different base.

## Step 2: Create the Worktree

Run the following commands:

```bash
# Fetch latest from origin
git fetch origin

# Create worktree with a new branch based on the chosen base
git worktree add -b <branch-name> /Users/erik.uzureau/dd/web-ui-worktrees/<worktree-name> origin/<base-branch>
```

- The worktree directory is `/Users/erik.uzureau/dd/web-ui-worktrees/<worktree-name>`
- If the branch already exists remotely, use `git worktree add /Users/erik.uzureau/dd/web-ui-worktrees/<worktree-name> <branch-name>` instead

## Step 3: Open a New Terminal in the Worktree

Open a new Terminal window, navigate to the worktree, and launch Claude Code:

```bash
osascript -e 'tell application "Terminal" to do script "cd /Users/erik.uzureau/dd/web-ui-worktrees/<worktree-name> && claude"'
```

Then confirm to the user:

1. That a new Terminal window has been opened in the worktree
2. The worktree path: `/Users/erik.uzureau/dd/web-ui-worktrees/<worktree-name>`
3. The branch name: `<branch-name>`
4. How to remove the worktree when done: `git worktree remove /Users/erik.uzureau/dd/web-ui-worktrees/<worktree-name>`

## Error Handling

- If the branch already exists locally, ask if they want to use the existing branch or pick a different name
- If the worktree directory already exists, ask if they want to remove it first or pick a different name
- If `git worktree add` fails, show the error and suggest fixes
