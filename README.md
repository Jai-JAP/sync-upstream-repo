# Sync Upstream Repo Fork

This is a Github Action used to merge changes from remote.  



This is forked from [dabreadman](https://github.com/dabreadman/sync-upstream-repo), with me adding support for syncing private repos with public template and ability to preserve downstream files (using ours merge statergy).

## Use case

- Perserve a repo while keeping up-to-date (rather than to clone it).
- Have a branch in sync with upstream, and pull changes into dev branch.

## Usage

```YAML
name: Sync Upstream

env:
  # Required, URL to upstream (fork base)
  UPSTREAM_URL: "https://github.com/<user>/<repo>"
  # Required, token to authenticate bot, could use ${{ secrets.GITHUB_TOKEN }} 
  # Over here, we use a PAT instead to authenticate workflow file changes.
  WORKFLOW_TOKEN: ${{ secrets.WORKFLOW_TOKEN }}
  # Optional, defaults to main
  UPSTREAM_BRANCH: "main"
  # Optional, defaults to UPSTREAM_BRANCH
  DOWNSTREAM_BRANCH: ""
  # Optional fetch arguments
  FETCH_ARGS: ""
  # Optional merge arguments
  MERGE_ARGS: ""
  # Optional push arguments
  PUSH_ARGS: ""
  # Optional toggle to spawn time logs (keeps action active) 
  SPAWN_LOGS: "false" # "true" or "false"
  # Optional custom commit message
  COMMIT_MSG: ""

# This runs every day on 1801 UTC
on:
  schedule:
    - cron: '1 0 * * *'
  # Allows manual workflow run (must in default branch to work)
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: GitHub Sync to Upstream Repository
        uses: Jai-JAP/sync-upstream-repo@v1.4.0
        with: 
          upstream_repo: ${{ env.UPSTREAM_URL }}
          upstream_branch: ${{ env.UPSTREAM_BRANCH }}
          downstream_branch: ${{ env.DOWNSTREAM_BRANCH }}
          token: ${{ env.WORKFLOW_TOKEN }}
          fetch_args: ${{ env.FETCH_ARGS }}
          merge_args: ${{ env.MERGE_ARGS }}
          push_args: ${{ env.PUSH_ARGS }}
          spawn_logs: ${{ env.SPAWN_LOGS }}
          commit_msg: ${{ env.COMMIT_MSG }}
```

This action syncs your repo (merge changes from `remote`) at branch `main` with the upstream repo every day on 0000 UTC.  
Do note GitHub Action scheduled workflow usually face delay as it is pushed onto a queue, the delay is usually within 1 hour long.

Note: If `SPAWN_LOGS` is set to `true`, this action will create a `sync-upstream-repo` file at root directory with timestamps of when the action is ran. This is to mitigate the hassle of GitHub disabling actions for a repo when inactivity was detected.
