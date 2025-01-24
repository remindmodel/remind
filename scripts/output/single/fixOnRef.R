# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

# if you want to change the reference run for yourrun, you can run:
# Rscript scripts/output/single/fixRefOn.R -i outputdir=yourrun,newreferencerun

suppressPackageStartupMessages(library(tidyverse))

if(! exists("source_include")) {
  # Define arguments that can be read from command line
  outputdir <- "."
  flags <- lucode2::readArgs("outputdir", .flags = c(i = "--interactive"))
}

findRefMif <- function(outputdir, envi) {
  stopifnot(length(outputdir) == 1)
  inputref <- try(envi$cfg$files2export$start[["input_ref.gdx"]], silent = TRUE)
  if (inherits(inputref, "try-error") || is.na(inputref) || isTRUE(inputref == "NA") || length(inputref) == 0) {
    message("No input_ref.gdx found in config.")
    return(NULL)
  }
  refdir <- dirname(inputref)
  if (! file.exists(file.path(refdir, "config.Rdata"))) {
    message("Config in reference directory '", refdir, "' not found.")
    return(NULL)
  }
  refscen <- lucode2::getScenNames(refdir)
  refmif <- file.path(refdir, paste0("REMIND_generic_", refscen, ".mif"))
  if (! file.exists(refmif)) {
    message("Reference mif '", refmif, "' not found, run reporting!")
    return(NULL)
  }
  return(refmif)
}

fixMAGICC <- function(d, dref, startyear, scen) {
  magiccgrep <- "^Forcing|^Temperature|^Concentration|^MAGICC7 AR6"
  message("Fixing MAGICC6 and 7 data before ", startyear)
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

fixOnMif <- function(outputdir) {

  gdxs    <- file.path(outputdir, "fulldata.gdx")
  configs <- file.path(outputdir, "config.Rdata")
  message("### Checking if mif is correctly fixed on reference run for ", outputdir)
  if (! all(file.exists(gdxs, configs))) stop("gdx or config.Rdata not found!")
  scens   <- lucode2::getScenNames(outputdir)
  mifs    <- file.path(outputdir, paste0("REMIND_generic_", scens, ".mif"))
  if (! all(file.exists(mifs))) stop("mif file not found, run reporting!")

  envi <- new.env()
  load(configs[[1]], env =  envi)
  title <- envi$cfg$title
  stopifnot(title == scens[[1]])
  startyear <- envi$cfg$gms$cm_startyear

  if (length(outputdir) == 1) {
    refmif <- findRefMif(outputdir, envi)
    if (is.null(refmif)) return(NULL)
  } else if (length(outputdir) == 2) {
    refmif <- mifs[[2]]
  } else {
    stop("length(outputdir)=", length(outputdir), ", is bigger than 2.")
  }
  refname <- basename(dirname(refmif))
  d <- quitte::as.quitte(mifs)
  dref <- quitte::as.quitte(refmif)
  d <- fixMAGICC(d, dref, startyear, title)
  failfile <- file.path(outputdir, "log_fixOnRef.csv")
  fixeddata <- piamInterfaces::fixOnRef(d, dref, ret = "TRUE_or_fixed", startyear = startyear, failfile = failfile, relDiff = 0.00002)

  update <- paste0("MAGICC data. ", if (! isTRUE(fixeddata)) "Run output.R -> single -> fixOnRef to fix the rest.")
  if (! isTRUE(fixeddata) && envi$cfg$fixOnRefAuto %in% c(TRUE, "TRUE")) {
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
  message("Keep in mind to update the runs that use this as `path_gdx_ref` as well.")
  return(NULL)
}

invisible(fixOnMif(outputdir))
