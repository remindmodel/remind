local({
  stopifnot(`No renv active. Try starting the R session in the repo root.` = !is.null(renv::project()))

  lockfiles <- list.files(here::here("archive"), full.names = TRUE)
  message(paste0(seq_along(lockfiles), ": ", basename(lockfiles), collapse = "\n"))
  message("Number of the lockfile to restore: ", appendLF = FALSE)

  get_line <- function() {
    # gets characters (line) from the terminal of from a connection
    # and stores it in the return object
    if (interactive()) {
      s <- readline()
    } else {
      con <- file("stdin")
      s <- readLines(con, 1, warn = FALSE)
      on.exit(close(con))
    }
    return(s)
  }

  renv::restore(lockfile = lockfiles[[as.integer(get_line())]], clean = TRUE, prompt = FALSE)
  renv::snapshot(prompt = FALSE) # ensure main renv.lock is in sync with library
})
