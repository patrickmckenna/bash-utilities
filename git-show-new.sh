#!/bin/bash

set -e

if [ $# -ge 1 ]; then
  branch="$1"
  shift
else
  branch=$(cat .git/HEAD | sed 's/ref:\ refs\/heads\///')
fi

git log "$branch"@{1}.."$branch"@{0} "$@"
