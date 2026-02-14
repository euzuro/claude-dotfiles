---
name: workflow-monitor-ci
description: Monitor CI jobs for a PR and report failures. Run this workflow every time new commits are pushed to a remote branch.
context: fork
agent: general-purpose
allowedTools:
  - "Bash(gh pr checks *)"
  - "Bash(scripts/check-ci-status.sh *)"
  - "Bash(gh pr checks --json link,state,name 2>&1 | scripts/check-ci-status.sh)"
---

## Monitor PRs CI Output

Important: run this workflow in an async subagent, to keep the main agent context as clear and lean as possible.
This workflow reports back to the main agent when jobs fail or when all pass.

### 1. Fetch CI Status

Check CI status by running:

```bash
gh pr checks --json link,state,name 2>&1 | scripts/check-ci-status.sh
```

- Poll periodically (every 30s) until all jobs complete (no pending jobs remain)
- The script outputs a summary of passed, pending, failed, and skipped jobs
- If there are pending jobs, wait and re-run the command
- Report back to the main agent when done

### 2. Handle Failures

In case of CI errors:
1. Analyze the failure logs (use the links from the script output)
2. Perform fixes in the main agent using the `dd:ci:fix` command
3. Commit and push the fixes
4. Restart monitoring to verify the fixes resolved the issue

### 3. Success Criteria

Monitoring is complete when:
- All CI jobs pass, OR
- User explicitly stops monitoring
