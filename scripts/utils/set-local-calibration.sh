#!/bin/bash

caldir="calibration_results"

# stop if calibration results directory already exists
test -d "$caldir" && echo "$caldir directory already exists" && exit 1

# create directory, ignore it,  initialise git in it, get hooks and set up 
# the collection script
mkdir "$caldir"
grep -q "^$caldir/$" .gitignore || echo "$caldir/" >> .gitignore

cd "$caldir"

git init > /dev/null
cp ../scripts/utils/set-local-calibration/collect_calibration ./
cp ../scripts/utils/set-local-calibration/gitignore .gitignore
chmod u+x collect_calibration

git add collect_calibration .gitignore
git commit --no-verify --quiet -m "set up local calibration results directory"

cp ../scripts/utils/set-local-calibration/pre-commit .git/hooks
cp ../scripts/utils/set-local-calibration/post-commit .git/hooks
chmod u+x .git/hooks/pre-commit .git/hooks/post-commit

cd "$OLDPWD"

# create additional .Rprofile (sourced through default .Rprofile)
echo -e "options(remind_repos = c(\n" \
	"    getOption(\"remind_repos\"),\n" \
	"    stats::setNames(list(x = NULL), \"$PWD/$caldir/\")))" \
	> calibration_results/.Rprofile_calibration_results
