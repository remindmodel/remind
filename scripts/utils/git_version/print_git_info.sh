#!/bin/bash

echo "change to git root dir"
CURDIR=$(pwd)
cd $(git rev-parse --show-toplevel) || exit 1

echo "write local git info to git_info.txt"
echo "{[( LOCAL BRANCH )]}" > "$CURDIR/git_info.txt"
echo $(git rev-parse --abbrev-ref HEAD) >> "$CURDIR/git_info.txt"
echo "{[( LAST LOCAL COMMIT )]}" >> "$CURDIR/git_info.txt"
echo $(git rev-parse HEAD) >> "$CURDIR/git_info.txt"

echo "write local patch file"
git diff -p > "$CURDIR/git_diff_local.patch"

echo "fetch remote"
git remote add temp_remindmodel https://github.com/remindmodel/remind.git 2> /dev/null
git fetch temp_remindmodel > /dev/null 2>&1

echo "write remote git info to $CURDIR/git_info.txt"
echo "{[( LAST REMOTE COMMIT )]}" >> "$CURDIR/git_info.txt"
PARENTCOMMIT=$(git merge-base HEAD temp_remindmodel/develop)
echo $PARENTCOMMIT >> $CURDIR/git_info.txt

echo "write remote patch file"
git diff -p $PARENTCOMMIT > "$CURDIR/git_diff_remote.patch"

echo "write untracked files patch file"
git ls-files --others --exclude-standard | xargs -r -I{} git diff -p /dev/null {} > "$CURDIR/git_diff_untracked.patch"

# echo "{[( UNTRACKED FILES )]}" >> git_info.txt
# git ls-files --others --exclude-standard --full-name ../.. >> git_info.txt

echo "remove temporary remote"
git remote remove temp_remindmodel

# return to original dir
cd $CURRDIR || exit 1
