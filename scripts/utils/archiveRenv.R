# updates renv.lock, copies updated renv.lock to the archive and appends current timestamp
local({
  stopifnot(`No renv active. Try starting the R session in the repo root.` = !is.null(renv::project()))
  here::i_am(file.path("scripts", "utils", "archiveRenv.R"))

  # update renv.lock
  renv::snapshot(prompt = FALSE)

  dir.create(here::here("archive"), showWarnings = FALSE)
  datetime <- format(Sys.time(), "%Y-%m-%dT%H%M%S")
  file.copy(renv::paths$lockfile(), here::here("archive", paste0(datetime, "_renv.lock")))
  message("finished archiving ", datetime, "_renv.lock")
})
