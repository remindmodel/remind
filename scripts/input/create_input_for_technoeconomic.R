# |  (C) 2006-2026 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

# Techno-economic data from POSTED (https://github.com/PhilippVerpoort/posted)
#
# technoeconomic/content.py fetches the values configured in its QUERIES from
# POSTED and calculates the properties as pint quantities from cet-units
# (https://github.com/PhilippVerpoort/cet-units), technoeconomic/create_input.py
# writes them into core/input/f_technoeconomic.csv, which core/datainput.gms
# reads to replace values from generisdata_tech.prn. The csv is committed and
# records in its header the sha256 of technoeconomic/uv.lock, the resolved
# environment it was computed in, and the sha256 of the scripts which produced it.
#
# technoeconomic/ is a Python project of its own, with pyproject.toml, uv.lock
# and .venv; uv is called with --project to reach it, so REMIND can host more
# than one, incompatible Python environment. pyproject.toml is where pins are
# edited, 'uv lock' (in technoeconomic/) resolves them into uv.lock.
#
# Checking is done by create_input.py --check run with 'uv run --no-sync'. Its
# exit code is technoeconomicCheck's status, one code per action: 0 nothing to
# do, the csv is up to date, 1 create_input.py failed so nothing is known and a
# run is refused, 2 the csv could not be checked (uv's or argparse's exit, or
# there is no uv at all) so the committed file is used, 3 regenerate the csv.
# Anything else counts as 1.
# Nothing here stops a run over an outdated csv: REMIND runs with the committed
# file as it is, like it runs with uncommitted GAMS code, and the GitHub check
# which runs the same --check is what refuses the commit.
# create_input_for_technoeconomic regenerates the csv with 'uv run --locked',
# which syncs the .venv to the committed uv.lock and refuses to run when that
# is out of date with pyproject.toml; uv.lock is the only place where REMIND
# touches the Python environment, and never does so without an environment to
# run in.
#
# Standalone: Rscript scripts/input/create_input_for_technoeconomic.R [remindPath] [--force]

# run create_input.py --check without touching the environment, returns the status
# code documented above and the message belonging to it; a uv which cannot start
# raises, so an unusable environment is never mistaken for an up to date csv
technoeconomicCheck <- function(remindPath = ".") {
  remindPath <- normalizePath(remindPath, mustWork = FALSE)
  uv <- Sys.which("uv")
  if (! nzchar(uv) || ! dir.exists(file.path(remindPath, "technoeconomic", ".venv"))) {
    return(list(status = 2L,
                message = paste("Neither uv nor technoeconomic/.venv were found, core/input/f_technoeconomic.csv",
                                "is used as committed and unchecked. Run 'uv --directory technoeconomic sync --locked' to check it.")))
  }
  scriptfile <- file.path(remindPath, "technoeconomic", "create_input.py")
  # --quiet removes uv's own messages but keeps errors, --locked refuses a lock
  # which is out of date with pyproject.toml
  args <- c("run", "--project", "technoeconomic", "--no-sync", "--locked", "--quiet",
            "python", scriptfile, "--check")
  result <- processx::run(uv, args, wd = remindPath, error_on_status = FALSE)
  list(status = result$status, message = trimws(paste0(result$stdout, result$stderr), "r"))
}

# create the csv from POSTED, 'uv run --locked' syncs the .venv with uv.lock
create_input_for_technoeconomic <- function(remindPath = ".", force = FALSE) {
  remindPath <- normalizePath(remindPath, mustWork = FALSE)
  scriptfile <- file.path(remindPath, "technoeconomic", "create_input.py")
  datafile <- file.path(remindPath, "core", "input", "f_technoeconomic.csv")

  check <- technoeconomicCheck(remindPath)
  # only these three codes say something about the csv, anything else means the
  # check failed and so nothing is known about it
  if (! check$status %in% c(0L, 2L, 3L)) stop(check$message)
  if (check$status == 0L && ! force) {
    message(check$message, " Use --force=TRUE to refetch.")
    return(invisible(datafile))
  }
  # without uv or its .venv nothing can be fetched, the committed csv stays as it
  # is, code 3 is exactly what refetching is for
  if (check$status == 2L) {
    message(check$message, " ", datafile, " is not regenerated.")
    return(invisible(NULL))
  }
  # create_input.py prints what to commit the file it wrote with, including that
  # what an editable install writes must not be committed
  args <- c("run", "--project", "technoeconomic", "--locked", "python", scriptfile,
            "--out", datafile)
  result <- processx::run("uv", args, wd = remindPath, error_on_status = FALSE)
  cat(paste0(result$stdout, result$stderr))
  if (result$status != 0L) {
    stop(scriptfile, " failed, see its output above.")
  }
  return(invisible(datafile))
}

# run standalone, not when this file is only sourced by prepare.R or a test
if (! interactive() && any(grepl("^--file=.*create_input_for_technoeconomic\\.R$", commandArgs(trailingOnly = FALSE)))) {
  args <- commandArgs(trailingOnly = TRUE)
  force <- "--force" %in% args
  args <- grep("^--", args, value = TRUE, invert = TRUE)
  remindPath <- if (length(args) > 0) args[1] else "."
  create_input_for_technoeconomic(remindPath = remindPath, force = force)
}
