# |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

source("./scripts/utils/isSlurmAvailable.R")

# This script expects a variable `outputdirs` and `slurmConfig` to be defined.
# Variable `filename_prefix` is used if defined.
if (!exists("outputdirs") || !exists("slurmConfig")) {
  stop(
    "Variable outputdirs or slurmConfig do not exist. ",
    "Please call varListHtml.R via output.R, which defines outputdirs and slurmConfig.")
}

timeStamp <- format(Sys.time(), "%Y-%m-%d_%H.%M.%S")
if (!exists("filename_prefix")) filename_prefix <- ""
nameCore <- paste0(filename_prefix, ifelse(filename_prefix == "", "", "-"), timeStamp)
fullName <- paste0("varList-", nameCore)

mifs <- c(remind2::getMifScenPath(outputdirs), remind2::getMifHistPath(outputdirs[1]))

command <- paste0(
  "remind2::createVarListHtml(",
  "x = c(\"", paste(mifs, collapse = "\",\""), "\"), ",
  "outFileName = \"", fullName, ".html\"", ", ",
  "title = \"", fullName, "\", ", 
  "usePlus = FALSE, ",
  "details = NULL",
  ")"
)

if (isSlurmAvailable() && slurmConfig != "direct") {
  clcom <- paste0(
    "sbatch ", slurmConfig,
    " --job-name=", fullName,
    " --output=", fullName, ".out",
    " --error=", fullName, ".out",
    " --mail-type=END --time=200 --mem-per-cpu=8000",
    r"( --wrap="R -e ')", command, r"('")")
  cat(clcom, "\n")
  system(clcom)
} else {
  tmpEnv <- new.env()
  tmpError <- try(
    eval(parse(text=command), envir = tmpEnv)
  )
  if (!is.null(tmpError))
    warning("Script ", script, " was stopped by an error and not executed properly!")
  rm(tmpEnv)
}
