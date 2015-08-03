#!/bin/bash

set -e

hub clone github/services
mkdir services-binaries

cp $(find services/ -name "*.ai") services-binaries
cp $(find services/ -name "*.mp4") services-binaries
cp $(find services/ -name "*.key") services-binaries

cd services

rm .gitattributes
rm .git/hooks/pre-push

git filter-branch -f --index-filter "git rm --cached --ignore-unmatch *.ai" -- --all
git filter-branch -f --index-filter "git rm --cached --ignore-unmatch *.mp4" -- --all
git filter-branch -f --index-filter "git rm --cached --ignore-unmatch *.key" -- --all
git filter-branch -f --index-filter "git rm --cached --ignore-unmatch .gitattributes" -- --all

cat <<END
************************************
if anything prints below this message, git filter-branch did not get rid of all LFS-tracked binaries"
************************************
END

git log --oneline --all --follow -- "*.ai"
git log --oneline --all --follow -- "*.mp4"
git log --oneline --all --follow -- "*.key"
