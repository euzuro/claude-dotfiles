#!/usr/bin/env bash
# Formats the output of `gh pr checks --json link,state,name`
# Usage: gh pr checks --json link,state,name 2>&1 | scripts/check-ci-status.sh

python3 -c "
import json, sys
data = json.load(sys.stdin)
pending = [j for j in data if j['state'] == 'PENDING']
failed = [j for j in data if j['state'] == 'FAILURE']
success = [j for j in data if j['state'] == 'SUCCESS']
skipped = [j for j in data if j['state'] == 'SKIPPED']
print(f'Summary: {len(success)} passed, {len(pending)} pending, {len(failed)} failed, {len(skipped)} skipped')
if failed:
    print('\nFAILED JOBS:')
    for j in failed:
        print(f'  - {j[\"name\"]}: {j[\"link\"]}')
if pending:
    print('\nPENDING JOBS:')
    for j in pending:
        print(f'  - {j[\"name\"]}')
"
