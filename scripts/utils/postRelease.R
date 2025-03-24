# This script is part of a longer workflow. 
# Before running this script please perform the steps described here
# https://gitlab.pik-potsdam.de/REMIND/remind-rse/-/wikis/How-to-create-a-REMIND-release

# in your fork switch to develop and execute this script in the main folder Rscript scripts/utils/postRelease.R

postRelease <- function() {
  gert::git_fetch("upstream")
  gert::git_merge("upstream/master")

  pattern <- "The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)."
  stopifnot(any(grepl(pattern, readLines("CHANGELOG.md"), fixed = TRUE)))
  textToAdd <- paste("",
                     "",
                     "",
                     "## [Unreleased]",
                     "",
                     "### input data/calibration",
                     "",
                     "### changed",
                     "-",
                     "",
                     "### added",
                     "-",
                     "",
                     "### removed",
                     "-",
                     "",
                     "### fixed",
                     "-",
                     sep = "\n")

  readLines("CHANGELOG.md") |>
    sub(pattern = pattern, replacement = paste0(pattern, textToAdd), fixed = TRUE) |>
    writeLines("CHANGELOG.md")

  message("Please perform the following step manually:\n",
          "git add -p\n",
          "--> When done press ENTER to commit, push and create PR")
  gms::getLine()

  gert::git_commit("merge master into develop")
  gert::git_push()
  # gh pr create --help
  # --base branch The branch into which you want your code merged
  # --head branch The branch that contains commits for your pull request (default [current branch])
  system(paste0("gh pr create --base develop --title 'merge master with new release into develop' --body ''"))
}

postRelease()
message("warnings:")
print(warnings())

