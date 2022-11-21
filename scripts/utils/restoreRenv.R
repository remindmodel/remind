#!/usr/bin/env Rscript
# restores current renv to the state described in selected lockfile e.g. from the archive, and writes the restored state to renv.lock
local({
  stopifnot(`No renv active. Try starting the R session in the repo root.` = !is.null(renv::project()))

  argv <- commandArgs(trailingOnly = TRUE)
  if (length(argv) == 1) {
    lockfile <- argv
  } else {
    suppressMessages(here::i_am(file.path("scripts", "utils", "restoreRenv.R")))
    lockfiles <- c(list.files(here::here("renv/archive"), full.names = TRUE),
                   Filter(file.exists, file.path(list.files(here::here("output"), full.names = TRUE), "renv.lock")))
    message(paste0(seq_along(lockfiles), ": ",
                   sub(here::here(""), "", lockfiles, fixed = TRUE),
                   collapse = "\n"))
    message("Number of the lockfile to restore: ", appendLF = FALSE)

    lockfile <- lockfiles[as.integer(gms::getLine())]
  }

  if (!isTRUE(file.exists(lockfile))) {
    stop("lockfile '", file.path(normalizePath("."), lockfile), "' does not exist.")
  }
  renv::restore(lockfile = lockfile, clean = TRUE, prompt = FALSE)
  renv::snapshot(prompt = FALSE) # ensure main renv.lock is in sync with library
})
