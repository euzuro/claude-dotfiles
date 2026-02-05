---
name: workflow-jira
description: |
  Use this skill when the user says things like:
  - "work on SXS-1234"
  - "work on https://datadoghq.atlassian.net/browse/SXS-1234"
  - "implement SXS-1234"
  - "start SXS-1234"
  - "pick up SXS-1234"
  - "do SXS-1234"
  Plans, implements, commits, pushes, creates PR, and iterate on the CI for a Jira issue.
---

## Input

The user provided: $ARGUMENTS

## Step 1: Extract Issue ID

Parse input to extract Jira issue ID:
- URL `https://datadoghq.atlassian.net/browse/SXS-1227` → `SXS-1227`
- Direct ID `SXS-1227` → use as-is

## Step 2: Ask user to rebase

**Ask user** to rebase on base branch, if there are more than 10 newer commits on remote

## Step 3: Fetch Jira Ticket

Use Atlassian MCP tool:
- **cloudId**: `datadoghq.atlassian.net`
- **issueIdOrKey**: extracted issue ID

Extract: summary, description, acceptance criteria, implementation instructions.

## Step 4: Plan Changes

Enter **plan mode**:
1. Analyze requirements against codebase
2. Design implementation
3. **Break into atomic commits** (one logical change per commit)
4. Present commit-by-commit breakdown

## Step 5: Implement and Commit (Sub-agents)

After approval, for **each atomic commit** in the plan:

1. **Spawn a sub-agent** (Task tool with `subagent_type: "redblue:blueteam"`) with:
   - The specific commit scope from the plan
   - Instructions to implement, test, and commit that change only
   - Reference to git-rules skill for commit conventions

2. The sub-agent should:
   - Implement the changes for that commit only
   - Run relevant tests
   - Create the commit following git-rules (gitmoji, atomic)
   - Return success/failure status

3. **Wait for each sub-agent to complete** before spawning the next (commits must be sequential)

This keeps the main agent's context small by offloading implementation details to sub-agents.

## Step 6: Push

After all commits complete, push the branch

## Step 7: Create PR

Use the `workflow-create-pr` skill to create the PR.

## Step 8: Monitor CI

Spawn a **background sub-agent** (Task tool with `subagent_type: "general-purpose"`, `run_in_background: true`) that runs the `workflow-monitor-ci` skill.

Return PR URL to user.
