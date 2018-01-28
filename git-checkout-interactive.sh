#!/bin/bash

# Usage: git-checkout-interactive.sh <required_arg> [<optional_arg>] [--optional-flag]
# brief description of the script's purpose

set -e

case $1 in
  -a)
    heads=refs/heads
    remotes=refs/remotes
    ;;
  -r)
    remotes=refs/remotes
    ;;
  *)
    heads=refs/heads
    ;;
esac

git for-each-ref \
   --sort=-committerdate \
   --format='%(refname:short) (%(committerdate:relative))' \
   $heads $remotes \
   | fzf --reverse --preview 'git log --patch --color {1}...{1}~5' \
   | awk '{print $1}' | xargs git checkout
