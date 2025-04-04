# This script is part of a longer workflow. 
# Before running this script please perform the steps described here
# https://gitlab.pik-potsdam.de/REMIND/remind-rse/-/wikis/Topics/release

# in your fork switch to temporary branch (e.g. release-candidate) and
# execute this script in the main folder with Rscript scripts/utils/release.R x.y.z

release <- function(newVersion) {
  if (Sys.which("sbatch") == "") {
    stop("release must be created on cluster")
  }
  
  releaseDate <- format(Sys.time(), "%Y-%m-%d")
  
  # Get old version from CITATION.cff
  oldVersion <- readLines("CITATION.cff") |>
    grep(pattern = "^version: (.*)$", value = TRUE) |>
    sub(pattern = "^version: (.*)$", replacement = "\\1") |>
    sub(pattern = "dev", replacement = "")
  
  # Update CHANGELOG.md
  message("Updating CHANGELOG.md")
  githubUrl <- "https://github.com/remindmodel/remind/compare/"
  readLines("CHANGELOG.md") |>
    # Add version and date of new release
    sub(pattern = "## [Unreleased]", replacement = paste0("## [", newVersion, "] - ", releaseDate), fixed = TRUE) |>
    # Add two lines with github links that compare versions
    sub(pattern = paste0("\\[Unreleased\\]: ", githubUrl, "v(.+)\\.\\.\\.develop"),
        replacement = paste0("[Unreleased]: ", githubUrl, "v", newVersion, "...develop\n",
                             "[", newVersion, "]: ", githubUrl, "v\\1...v", newVersion)) |>
    writeLines("CHANGELOG.md")
  
  # Update version and release date in CITATION.cff
  message("Updating CITATION.cff")
  readLines("CITATION.cff") |>
    sub(pattern = "^version:.*$", replacement = paste("version:", newVersion)) |>
    sub(pattern = "^date-released:.*$", replacement = paste("date-released:", releaseDate)) |>
    writeLines("CITATION.cff")
  
  # Update version in README.md
  readLines("README.md") |>
    gsub(pattern = oldVersion, replacement = newVersion) |>
    writeLines("README.md")
  
  # Create documentation
  message("creating documentation using goxygen...")
  goxygen::goxygen(unitPattern = c("\\[","\\]"), 
                   includeCore = TRUE,
                   output = "html",
                   max_num_edge_labels = "adjust", 
                   max_num_nodes_for_edge_labels = 15, 
                   startType = NULL)
  
  # Upload html documentation to RSE server
  message("uploading documentation to RSE server")
  exitCode <- system(paste0("rsync -e ssh -avz doc/html/* ",
                            "rse@rse.pik-potsdam.de:/webservice/doc/remind/", newVersion))
  stopifnot(exitCode == 0)
  
  # Upload input data to RSE server
  message("Uploading input data to RSE server")
  source("config/default.cfg")
  cfg <- defineInputData(cfg)
  # Keep mandatory input files only
  cfg$input <- cfg$input[cfg$stopOnMissing]
  gms::publish_data(cfg,target = "dataupload@rse.pik-potsdam.de:/remind/public")
  
  # add renv snapshot to local archive
  archivePath <- file.path(normalizePath(renv::project()), "renv", "archive", paste0(newVersion, "_renv.lock"))
  renv::snapshot(lockfile = archivePath)
  system(paste0("git add -f renv/archive/", newVersion, "_renv.lock"))

  message("If not already done please perform the first step manually now. Please perform step two in any case:\n",
          "1. CHANGELOG.md: sort lines in each category: input data/calibration, changed, added, removed, fixed; remove empty categories\n",
          "In another terminal:\n"
          "2. git add -p\n",
          "3. git commit -m 'your commit message'",
          "4. git push yourFork yourReleaseCandidateBranch",
          "--> When done press ENTER to create PR")
  gms::getLine()
  
  #message("Committing and pushing changes")
  #gert::git_commit(paste("remind release", newVersion))
  #gert::git_push()
  
  message("Creating tag")
  tag <- paste0("v", newVersion)
  gert::git_tag_create(name = tag, message = "new tag", repo = ".")
  gert::git_tag_push(name = tag, repo = ".")
  
  message("Creating a PR on GitHub")
  # gh pr create --help
  # --base branch The branch into which you want your code merged
  # --head branch The branch that contains commits for your pull request (default [current branch])
  system(paste0("gh pr create --base master --title 'remind release ", newVersion, "' --body ''"))
}

# Source function definition of defineInputData()
source("scripts/start/defineInputData.R")

# Ask user for release version
arguments <- commandArgs(TRUE)
if (length(arguments) != 1) {
  stop("Please pass the new version number, e.g. `Rscript scripts/utils/release.R 0.8.15`")
}

release(arguments)
message("warnings:")
print(warnings())
