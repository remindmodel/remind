local({
  stopifnot(`No renv active. Try starting the R session in the repo root.` = !is.null(renv::project()))

  lockfiles <- list.files(here::here("archive"), full.names = TRUE)
  message(paste0(seq_along(lockfiles), ": ", basename(lockfiles), collapse = "\n"))
  message("Number of the lockfile to restore: ", appendLF = FALSE)

  renv::restore(lockfile = lockfiles[[as.integer(gms::getLine())]], clean = TRUE, prompt = FALSE)
  renv::snapshot(prompt = FALSE) # ensure main renv.lock is in sync with library
})
