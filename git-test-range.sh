#!/bin/bash

USAGE="git test-range [-k|--keep-going] RANGE -- COMMAND"

LONG_USAGE="Run COMMAND for each commit in the specified RANGE in reverse order,
stopping if the command fails.  The return code is that of the last
command executed (i.e., 0 only if the command succeeded for every
commit in the range).

Options:

 -k|--keep-going : if a commit fails the test, continue testing other commits
                   rather than aborting.
"

test_rev() {
  local rev="$1"
  local command="$2"
  git checkout -q "$rev" && eval "$command"
  local retcode=$?
  if [ $retcode -ne 0 ]
  then
    printf "\n%s\n" "$command FAILED ON:"
    git --no-pager log -1 --decorate "$rev"
    return $retcode
  fi
}

# among other things, this script ensures that we're in the top-level directory of a valid repo
. "$(git --exec-path)/git-sh-setup"

require_clean_work_tree "git-test-range"

keep_going=
if [ $1 == "-k" ] || [ $1 == "--keep-going" ]
then
    keep_going=true
    shift
fi

# still need: revision arg(s), --, command to execute
if [ $# -lt 3 ]
then
    usage
    exit 2
fi

range=
while [ $# -ne 0 ]
do
    case "$1" in
        --)
            shift
            break
            ;;
        *)
            range="$range $1"
            shift
            ;;
        esac
done

command="$1"

# store current revision
head=$(git symbolic-ref HEAD 2>/dev/null || git rev-parse HEAD)

fail_count=0
for rev in $(git rev-list --reverse $range)
do
    test_rev $rev "$command"

    retcode=$?
    if [ $retcode -eq 0 ]
    then
        continue
    fi

    if [ $keep_going ]
    then
        fail_count=$((fail_count + 1))
        continue
    else
        git checkout -f ${head#refs/heads/} &>/dev/null
        exit $retcode
    fi
done

git checkout -f ${head#refs/heads/} &>/dev/null

echo
case $fail_count in
  0)
      echo "ALL TESTS SUCCESSFUL"
      exit 0
      ;;
  1)
      echo "!!! $fail_count TEST FAILED !!!"
      exit 1
      ;;
  *)
      echo "!!! $fail_count TESTS FAILED !!!"
      exit 1
      ;;
esac
