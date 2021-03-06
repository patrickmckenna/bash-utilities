#!/bin/bash

# Usage: git-use-cred-helper.sh
# temporarily use git credential helper for a given repo

set -e

git config --local credential.helper cache --timeout=36000
