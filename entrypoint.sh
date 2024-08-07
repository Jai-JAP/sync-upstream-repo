#!/usr/bin/env bash

set -x

UPSTREAM_REPO=$1
UPSTREAM_BRANCH=$2
DOWNSTREAM_BRANCH=$3
GITHUB_TOKEN=$4
FETCH_ARGS=$5
MERGE_ARGS=$6
PUSH_ARGS=$7
SPAWN_LOGS=$8
COMMIT_MSG=$9

if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "Missing \$GITHUB_TOKEN"
  exit1
fi

if [[ -z "$UPSTREAM_REPO" ]]; then
  echo "Missing \$UPSTREAM_REPO"
  exit 1
fi

if [[ -z "$DOWNSTREAM_BRANCH" ]]; then
  echo "Missing \$DOWNSTREAM_BRANCH"
  echo "Default to ${UPSTREAM_BRANCH}"
  DOWNSTREAM_BRANCH=$UPSTREAM_BRANCH
fi

if ! echo "$UPSTREAM_REPO" | grep '\.git'; then
  UPSTREAM_REPO="https://github.com/${UPSTREAM_REPO_PATH}.git"
fi

if [[ -z "$COMMIT_MSG" ]]; then
  COMMIT_MSG="Merge upstream"
fi

echo "UPSTREAM_REPO=$UPSTREAM_REPO"

git clone "https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git" work
cd work || { echo "Missing work dir" && exit 2 ; }

git config user.name "${GITHUB_ACTOR}"
git config user.email "${GITHUB_ACTOR}@users.noreply.github.com"
git config --local user.password ${GITHUB_TOKEN}
git config --local merge.ours.driver true
git config --local merge.theirs.driver "cp %B %A"

git remote set-url origin "https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"

git remote add upstream "$UPSTREAM_REPO"
git fetch ${FETCH_ARGS} upstream
git remote -v

git checkout ${DOWNSTREAM_BRANCH}

case ${SPAWN_LOGS} in
  (true)    echo -n "sync-upstream-repo https://github.com/Jai-JAP/sync-upstream-repo keeping CI alive."\
            "UNIX Time: " >> sync-upstream-repo
            date +"%s" >> sync-upstream-repo
            git add sync-upstream-repo
            git commit sync-upstream-repo -m "Syncing upstream";;
  (false)   echo "Not spawning time logs"
esac

git push origin

MERGE_RESULT=$(git merge ${MERGE_ARGS} -m "${COMMIT_MSG}" upstream/${UPSTREAM_BRANCH})


if [[ $MERGE_RESULT == "" ]]; then
  exit 1
elif [[ $MERGE_RESULT != *"Already up to date."* ]]; then
  COMMIT_RESULT=$(git commit -m "${COMMIT_MSG}")
  [[ $? != 0 && $COMMIT_RESULT != *"nothing to commit, working tree clean"* ]] && exit 1 
  PUSH_RESULT=$(git push ${PUSH_ARGS} origin ${DOWNSTREAM_BRANCH})
  [[ $? != 0 && $PUSH_RESULT != *"Everything up-to-date"* ]] && exit 2
fi

cd ..
rm -rf work
