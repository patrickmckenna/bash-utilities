#!/bin/bash

set -e

if [ $# -eq 1 ]; then
  branch="$1"
else
  branch="HEAD"
fi

printf "\n%s%s\n\n" $(git rev-list $branch@{1}..$branch | wc -l) " commits were added by your last update to $branch:"
git --no-pager log "$branch"@{1}.."$branch" --oneline
