h <- "
#' Rscript scripts/utils/readcoupled.R 'vars' [regi] [time]
#'
#' Read data from fulldata.gdx or .mif file of REMIND-MAgPIE coupled runs.
#'
#' Command line parameters:
#'   vars   comma-separated list of GAMS variables or reporting variables.
#'          Example: 'pm_taxCO2eq,Price|Carbon'. Default: pm_gmt_conv,pm_sccConvergenceMaxDeviation
#'   regi   optional comma-separated list of GAMS regions. Example: EUR,USA. Default: World/GLO.
#'   time   optional comma-separated list of timesteps. Example: 2030,2100. Default: 2050
#'
#' The script loops through all options of vars, regi and time, reads vars that
#' look like gams names from fulldata.gdx and everything else from the mif file.
#'
#' If only NA are returned, try to adjust the settings and check the GAMS sets it is defined on.
#' For example, many GAMS parameters don't have data for GLO, so adjust the regi.
#' If a GAMS parameter is defined on more sets then regi and t, simply the first element is printed.
"
suppressMessages(library(tidyverse))
suppressMessages(library(gdx))
suppressMessages(library(modelstats))
suppressMessages(library(magclass))
suppressMessages(library(quitte))
suppressMessages(library(piamutils))
suppressMessages(library(lucode2))
options(width = 160)
vars <- c("pm_gmt_conv", "pm_sccConvergenceMaxDeviation")
regi <- "EUR"
time <- "2050"
# overwrite arguments from command line if specified
argv <- commandArgs(trailingOnly = TRUE)
if (length(argv) > 0 && ! isTRUE(argv == "")) vars <- trimws(strsplit(argv, ",")[[1]])
# print help message
if (any(vars %in% c("-h", "--help"))) { message(h); q() }
# next all-numeric is year, other regi
if (length(argv) > 1) {
  argv2 <- trimws(strsplit(argv, ",")[[2]])
  if (all(grepl("^[0-9]+$", argv2))) time <- argv2 else regi <- argv2
}
if (length(argv) > 2) {
  argv3 <- trimws(strsplit(argv, ",")[[3]])
  if (all(grepl("^[0-9]+$", argv2))) regi <- argv3 else time <- argv3
}
# be flexible about folder the script is started
folder <- "."
if (sum(file.exists(c("output", "output.R", "start.R", "main.gms"))) == 4) folder <- "output"
if (file.exists("readcoupled.R")) folder <- "../../output"

# find runs
dirs <- grep(".*-rem-[0-9]+$", dir(folder), value = TRUE)
if (length(dirs) == 0) {
  message("No run found in ", normalizePath(folder))
  q()
}
# determine highest rem-xx and base run names
maxrem <- max(as.numeric(gsub(".*-rem-", "", dirs)))
runs <- unique(gsub("-rem-[0-9]+$", "", dirs))
# print user information
message("\nNumbers in parentheses indicate runs currently in slurm.")
message("A minus sign indicates that run does not exist.")
message("For help, run: Rscript readcoupled.R --help")
# loop over vars, regi and time
for (v in vars) {
  v <- deletePlus(v)
  # does it look like a gams variable, then read from fulldata.gdx
  usegdx <- grepl("^[qvsfopcs](m_|_|\\d{2}_)", v)
  # correctly use of GLO in gdx and World in mif
  regi <- gsub("^GLO$|^World$", if (usegdx) "GLO" else "World", regi)
  for (re in regi) {
    for (t in time) {
      # inform user about what is read
      message("\n### Read '", v, "' from ", if (usegdx) "fulldata.gdx" else ".mif file", ".",
              if(! grepl("^s", v) || ! usegdx) paste0(" It uses t=", t, " and regi=", re, " if these dimensions exist."))
      # create empty results tibble
      results <- matrix(nrow = length(runs), ncol = maxrem + 1)
      colnames(results) <- c("run", paste0("rem", seq(maxrem)))
      results <- as_tibble(results)
      # loop through runs and rem-x
      for (r in seq_along(runs)) {
        results[[r, "run"]] <- runs[[r]]
        for (m in seq(maxrem)) {
          rfolder <- file.path(folder, paste0(runs[r], "-rem-", m))
          # define gdx and mif file with data
          gdx <- file.path(rfolder, "fulldata.gdx")
          if (dir.exists(rfolder)) report <- file.path(rfolder, paste0("REMIND_generic_", getScenNames(rfolder), "_withoutPlus.mif"))
          data <- NA
          if (usegdx && file.exists(gdx)) { # read from fulldata.gdx
            data <- try(gdx::readGDX(gdx, v, react = "silent"), silent = TRUE)
            # handle errors and null
            if (inherits(data, "try-error") || is.null(data)) {
              data <- "-"
            } else { # transform to quitte
              data <- as.quitte(data)
            }
          } else if (dir.exists(rfolder) && file.exists(report)) { # read from mif file
            data <- read.snapshot(report, list(variable = v))
          }
          if ("data.frame" %in% class(data)) {
            # select var. select regi and time if more than one in data
            if (length(unique(data$region)) > 1) data <- data[data$region == re, ]
            if (length(unique(data$period)) > 1) data <- data[data$period == t, ]
            data <- if (nrow(data) == 0) NA else niceround(data$value[[1]], 3)
          } # check whether run still in slurm
          if (! modelstats::foundInSlurm(rfolder) == "no") {
            data <- paste0("(", data, ")")
          }
          # add to results tibble
          results[[r, paste0("rem", m)]] <- data
        }
      }
      # overwrite NA with "-" and print results while suppressing tibble size and column type info
      results[is.na(results)] <- "-"
      message(cat(format(as_tibble(results))[-1L][-2L], sep = "\n"))
    }
  }
}
