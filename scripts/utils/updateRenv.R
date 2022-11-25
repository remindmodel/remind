#!/usr/bin/env Rscript
# Updates all pik-piam R packages in the current renv, updates renv.lock, and archives the renv.lock
local({
  stopifnot(`No renv active. Try starting the R session in the repo root.` = !is.null(renv::project()))
  suppressMessages(here::i_am(file.path("scripts", "utils", "updateRenv.R")))

  # get all packages in pik-piam r-universe
  packagesUrl <- "https://pik-piam.r-universe.dev/src/contrib/PACKAGES"
  pikPiamPackages <- sub("^Package: ", "", grep("^Package: ", readLines(packagesUrl), value = TRUE))

  # update pik-piam packages only
  renv::update(intersect(utils::installed.packages()[, "Package"], pikPiamPackages), prompt = FALSE)

  source(here::here("scripts", "utils", "archiveRenv.R"))
})
