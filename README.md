# .github

Shared GitHub Actions workflows and configurations for the organization.

## Workflows

### Resolve Merge Conflicts (`resolve-merge-conflicts.yml`)

Automates the creation of a conflict-resolution branch and PR when merge-back PRs (e.g., `canary => dev`) have conflicts.

**How it works:**
1. Add the `resolve-conflicts` label to a conflicted merge-back PR
2. The workflow creates a new branch from the source branch (e.g., `canary`)
3. It attempts to merge the target branch (e.g., `develop`) into it
4. A new PR is opened targeting the base branch, with instructions for manual resolution if needed
5. The original PR is commented with a link to the resolution PR

**Caller workflow** — add this to each repo that needs it:

```yaml
name: Resolve Merge Conflicts

on:
  pull_request:
    types: [labeled]

jobs:
  resolve-conflicts:
    if: github.event.label.name == 'resolve-conflicts'
    uses: talktala/lahore/.github/workflows/resolve-merge-conflicts.yml@main
    with:
      pr_number: ${{ github.event.pull_request.number }}
      head_branch: ${{ github.event.pull_request.head.ref }}
      base_branch: ${{ github.event.pull_request.base.ref }}
    secrets: inherit
```

**Required secrets:** `GIT_TOKEN` (PAT with repo access)

### PR Name Check (`pr-name-check.yml`)

Validates PR titles match the organization's naming conventions.

### JIRA Label (`jira-label.yml`)

Auto-labels JIRA tickets when PRs are merged to protected branches.

### MIME Environment (`mime-environment.yml`)

Creates/updates Qovery environments for MIME epic branches.

### MIME Environment Cleanup (`mime-environment-cleanup.yml`)

Cleans up Qovery environments when MIME branches are deleted.
