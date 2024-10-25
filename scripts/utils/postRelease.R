# This script is part of a longer workflow described here
# https://gitlab.pik-potsdam.de/rse/rse-internal/-/wikis/PublishModel

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

  readLines("CITATION.cff") |>
    sub(pattern = "^(version:.*)$", replacement = "\\1dev") |>
    writeLines("CITATION.cff")

  message("Please perform the following step manually:\n",
          "git add -p\n",
          "--> When done press ENTER to commit, push and create PR")
  gms::getLine()

  gert::git_commit("merge master into develop")
  gert::git_push()
  # gh pr create --help
  # --base branch The branch into which you want your code merged
  # --head branch The branch that contains commits for your pull request (default [current branch])
  system(paste0("gh pr create --base develop --title 'merge master into develop' --body ''"))
}

postRelease()
message("warnings:")
print(warnings())

