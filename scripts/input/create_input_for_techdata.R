# |  (C) 2006-2026 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

# Techno-economic data from POSTED (https://github.com/PhilippVerpoort/posted)
#
# scripts/input/techdata/content.py fetches the values configured in its QUERIES from POSTED
# scripts/input/techdata/create_input.py writes them into
# core/input/f_techdata.csv, which core/datainput.gms reads to replace
# values from generisdata_tech.prn. Its header contains hashes on how it was produced.
#
# This script is called during a run from prepare.R and requires uv and Python
#
# The POSTED version is configured as cfg$postedVersion in config/default.cfg
# and copied to scripts/input/techdata/pyproject.toml.
#
# Standalone: Rscript scripts/input/create_input_for_techdata.R [remindPath] [--force]

# get the POSTED version configured as cfg$postedVersion in config/default.cfg
configPostedVersion <- function(remindPath = ".") {
  conffile <- file.path(remindPath, "config", "default.cfg")
  env <- new.env()
  sys.source(conffile, envir = env)
  postedVersion <- get("cfg", envir = env)$postedVersion
  if (! is.character(postedVersion) || length(postedVersion) != 1L) {
    stop("cfg$postedVersion <- \"commit\" expected in ", conffile, ".")
  }
  return(postedVersion)
}

# copy cfg$postedVersion from config/default.cfg to the posted pin in
# scripts/input/techdata/pyproject.toml and resolve the change with
# 'uv lock'
syncPostedVersion <- function(remindPath = ".") {
  remindPath <- normalizePath(remindPath, mustWork = FALSE)
  pyproject <- file.path(remindPath, "scripts", "input", "techdata", "pyproject.toml")
  want <- configPostedVersion(remindPath)
  lines <- readLines(pyproject)
  isposted <- grepl("posted @ git\\+https://github\\.com/PhilippVerpoort/posted\\.git@", lines)
  if (sum(isposted) != 1L) {
    stop("exactly one posted dependency expected in ", pyproject, ", found ", sum(isposted), ".")
  }
  current <- sub(".*posted\\.git@([0-9a-zA-Z._-]+).*", "\\1", lines[isposted])
  if (identical(current, want)) return(invisible(NULL))
  message("posted is pinned to ", current, " in ", pyproject, ", config/default.cfg wants ", want, ", updating.")
  lines[isposted] <- sub("posted\\.git@[0-9a-zA-Z._-]+", paste0("posted.git@", want), lines[isposted])
  writeLines(lines, pyproject)
  result <- processx::run("uv", c("lock", "--project", "scripts/input/techdata"),
                          wd = remindPath, error_on_status = FALSE)
  cat(paste0(result$stdout, result$stderr))
  if (result$status != 0L) stop("uv lock failed, see its output above.")
  return(invisible(pyproject))
}

# run create_input.py --check in the locked environment, returning its status
# (0 csv up to date, 3 regenerate) and message; uv, Python and POSTED are
# mandatory, so anything else raises.
techdataCheck <- function(remindPath = ".") {
  remindPath <- normalizePath(remindPath, mustWork = FALSE)
  scriptfile <- file.path(remindPath, "scripts", "input", "techdata", "create_input.py")
  # --locked refuses a lock which is out of date with pyproject.toml, uv run
  # syncs the .venv to that lock if it is not already
  args <- c("run", "--project", "scripts/input/techdata", "--locked", "--quiet",
            "python", scriptfile, "--check")
  result <- processx::run("uv", args, wd = remindPath, error_on_status = FALSE)
  status <- result$status
  message <- trimws(paste0(result$stdout, result$stderr), "r")
  if (! status %in% c(0L, 3L)) stop("checking ", scriptfile, " failed (exit ", status, "): ", message)
  list(status = status, message = message)
}

# create the csv from POSTED after syncing the configured posted version
create_input_for_techdata <- function(remindPath = ".", force = FALSE) {
  remindPath <- normalizePath(remindPath, mustWork = FALSE)
  scriptfile <- file.path(remindPath, "scripts", "input", "techdata", "create_input.py")
  datafile <- file.path(remindPath, "core", "input", "f_techdata.csv")

  syncPostedVersion(remindPath)
  check <- techdataCheck(remindPath)
  if (check$status == 0L && ! force) {
    message(check$message, " Use --force=TRUE to refetch.")
    return(invisible(datafile))
  }
  args <- c("run", "--project", "scripts/input/techdata", "--locked", "python", scriptfile,
            "--out", datafile)
  result <- processx::run("uv", args, wd = remindPath, error_on_status = FALSE)
  cat(paste0(result$stdout, result$stderr))
  if (result$status != 0L) {
    stop(scriptfile, " failed, see its output above.")
  }
  return(invisible(datafile))
}

# run standalone, not when this file is only sourced by prepare.R or a test
if (! interactive() && any(grepl("^--file=.*create_input_for_techdata\\.R$", commandArgs(trailingOnly = FALSE)))) {
  args <- commandArgs(trailingOnly = TRUE)
  force <- "--force" %in% args
  args <- grep("^--", args, value = TRUE, invert = TRUE)
  remindPath <- if (length(args) > 0) args[1] else "."
  create_input_for_techdata(remindPath = remindPath, force = force)
}
