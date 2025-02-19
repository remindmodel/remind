# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

# Call this script via output.R -> single -> fixOnRef.
# This script allows to check whether for ttot < cm_startyear, the run is identical
# to path_gdx_ref by comparing the mif files. It can automatically find the required
# data based on config.Rdata.

# If you want to change the reference run for yourrun, you cannot use output.R, but run:
# Rscript scripts/output/single/fixOnRef.R -i outputdir=yourrun,newreferencerun

suppressPackageStartupMessages(library(tidyverse))

# Define arguments that can be read from command line
if(! exists("source_include")) {
  outputdir <- "."
  flags <- lucode2::readArgs("outputdir", .flags = c(i = "--interactive"))
}

# find the mif file of the reference run automatically by reading from cfg the output folder
findRefMif <- function(outputdir, envi) {
  stopifnot(length(outputdir) == 1)
  inputref <- try(envi$cfg$files2export$start[["input_ref.gdx"]], silent = TRUE)
  # if something goes wrong or no path_gdx_ref specified, return nothing
  if (inherits(inputref, "try-error") || is.na(inputref) || isTRUE(inputref == "NA") || length(inputref) == 0) {
    message("No input_ref.gdx found in config.")
    return(NULL)
  }
  # find scenario name of reference run to be able to find mif file
  refdir <- dirname(inputref)
  if (! file.exists(file.path(refdir, "config.Rdata"))) {
    message("Config in reference directory '", refdir, "' not found.")
    return(NULL)
  }
  refscen <- lucode2::getScenNames(refdir)
  refmif <- file.path(refdir, paste0("REMIND_generic_", refscen, ".mif"))
  # mif file might not exist for whatever reason
  if (! file.exists(refmif)) {
    message("Reference mif '", refmif, "' not found, run reporting!")
    return(NULL)
  }
  return(refmif)
}

# always automatically fixes all MAGICC data that strangely is not correctly
# fixed on the reference run, but we see no way to change that.
fixMAGICC <- function(d, dref, startyear, scen) {
  # grep of variables coming from MAGICC
  magiccgrep <- "^Forcing|^Temperature|^Concentration|^MAGICC7 AR6"
  message("Fixing MAGICC6 and 7 data before ", startyear)
  # combine MAGICC dref data for t < startyear with the rest
  dnew <-
    rbind(
      filter(dref, grepl(magiccgrep, .data$variable),
             .data$period < startyear),
      filter(d, ! grepl(magiccgrep, .data$variable) |
             .data$period >= startyear)
    ) %>%
    mutate(scenario = factor(scen)) %>%
    droplevels()
  return(dnew)
}

# does the actual fixing on the reference run
fixOnMif <- function(outputdir) {
  # first find gdx, config and mif files for all outputdir folder
  gdxs    <- file.path(outputdir, "fulldata.gdx")
  configs <- file.path(outputdir, "config.Rdata")
  message("### Checking if mif is correctly fixed on reference run for ", outputdir[[1]])
  if (! all(file.exists(gdxs, configs))) stop("gdx or config.Rdata not found!")
  scens   <- lucode2::getScenNames(outputdir)
  mifs    <- file.path(outputdir, paste0("REMIND_generic_", scens, ".mif"))
  if (! all(file.exists(mifs))) stop("mif file not found, run reporting!")

  # load config of first outputdir (the folder we are checking)
  envi <- new.env()
  load(configs[[1]], env =  envi)
  title <- envi$cfg$title
  stopifnot(title == scens[[1]])
  startyear <- envi$cfg$gms$cm_startyear

  if (length(outputdir) == 1) { # search for mif of reference run based on config
    refmif <- findRefMif(outputdir, envi)
    if (is.null(refmif)) return(NULL)
  } else if (length(outputdir) == 2) { # use outputdir[2] as reference run
    refmif <- mifs[[2]]
  } else { # something went wrong
    stop("length(outputdir)=", length(outputdir), ", is bigger than 2.")
  }
  refname <- basename(dirname(refmif))

  # load data of run and reference run
  d <- quitte::as.quitte(mifs[[1]])
  dref <- quitte::as.quitte(refmif)
  # always fix MAGICC automatically
  d <- fixMAGICC(d, dref, startyear, title)
  # logfile to write errors to
  failfile <- file.path(outputdir[[1]], "log_fixOnRef.csv")
  # call piamInterfaces::fixOnRef. Returns either TRUE if everything is fine, or the corrected data
  # small relative differences of 0.002 % are considered acceptable
  fixeddata <- piamInterfaces::fixOnRef(d, dref, ret = "TRUE_or_fixed", startyear = startyear, failfile = failfile, relDiff = 0.00002)

  # if cfg$fixOnRefAuto = TRUE), fix the data automatically
  # else if in interactive mode (not within a REMIND run), ask
  # else if in REMIND run, just print the problems
  update <- paste0("MAGICC data. ", if (! isTRUE(fixeddata)) "Run output.R -> single -> fixOnRef to fix the rest.")
  if (! isTRUE(fixeddata) && isTRUE(envi$cfg$fixOnRefAuto %in% c(TRUE, "TRUE"))) {
    d <- fixeddata
    update <- "data from reference run because cfg$fixOnRefAuto=TRUE."
  } else if (! isTRUE(fixeddata) && exists("flags") && isTRUE("--interactive" %in% flags)) {
    message("\nDo you want to fix that by overwriting ", title, " mif with reference run ",
            refname, " for t < ", startyear, "?\nType: y/N")
    if (tolower(gms::getLine()) %in% c("y", "yes")) {
      d <- fixeddata
      update <- "data from reference run."
    }
  }
  message("Updating ", mifs[[1]], " with ", update)
  tmpfile <- paste0(mifs[[1]], "fixOnMif")
  quitte::write.mif(d, tmpfile)
  file.rename(tmpfile, mifs[[1]])
  piamutils::deletePlus(mifs[[1]], writemif = TRUE)
  # if you update a run, all other runs that use this run as input should be updated as well.
  message("Keep in mind to update the runs that use this as `path_gdx_ref` as well.")
  return(NULL)
}

invisible(fixOnMif(outputdir))
