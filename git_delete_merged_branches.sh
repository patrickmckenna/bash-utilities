#!/bin/bash

# Usage: git_delete_merged_branches.sh
# delete all local branches that have been merged into master
# does not delete currently checked-out branch or master itself

set -e

git branch --merged master | grep -v -e "\*" -e "^master" | xargs -n 1 git branch -d