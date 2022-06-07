local({
  stopifnot(`No renv active. Try starting the R session in the repo root.` = !is.null(renv::project()))

  # update renv.lock
  renv::snapshot(prompt = FALSE)

  dir.create(here::here("archive"), showWarnings = FALSE)
  datetime <- format(Sys.time(), "%Y-%m-%dT%H%M%S")
  file.copy(renv::paths$lockfile(), here::here("archive", paste0(datetime, "_renv.lock")))
  message("finished archiving ", datetime, "_renv.lock")
})
