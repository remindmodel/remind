# |  (C) 2006-2026 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

# Techno-economic data from POSTED (https://github.com/PhilippVerpoort/posted)
#
# scripts/input/techdata/content.py fetches the values configured in its
# QUERIES from POSTED and calculates the properties as pint quantities from
# cet-units (https://github.com/PhilippVerpoort/cet-units),
# scripts/input/techdata/create_input.py writes them into
# core/input/f_techdata.csv, which core/datainput.gms reads to replace
# values from generisdata_tech.prn. That csv is not committed, it is generated
# input like everything else in core/input, and its header records what produced
# it, see scripts/input/techdata/create_input.py.
#
# uv, Python and POSTED are mandatory: there is no way to run REMIND without
# them, everything which cannot check or generate the csv stops the run.
# prepare.R calls create_input_for_techdata, so the csv exists before GAMS
# starts, standalone runs fetch it with this script.
#
# The POSTED version is configured as cfg$postedVersion in config/default.cfg,
# the only place where it is edited. syncPostedVersion copies it to the posted
# pin in scripts/input/techdata/pyproject.toml and runs 'uv lock' when
# they differ. scripts/input/techdata/ is a Python project of its own,
# with pyproject.toml, uv.lock and .venv; uv is called with --project to reach
# it, so REMIND can host more than one, incompatible Python environment.
#
# Checking is done by create_input.py --check, see techdataCheck.
#
# Standalone: Rscript scripts/input/create_input_for_techdata.R [remindPath] [--force]

# the POSTED version configured as cfg$postedVersion in config/default.cfg
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
