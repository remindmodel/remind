# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

suppressPackageStartupMessages(library(tidyverse))

if(! exists("source_include")) {
  # Define arguments that can be read from command line
  outputdir <- "."
  readArgs("outputdir")
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
  if (identical(levels(d$scenario), levels(dref$scenario))) {
    levels(dref$scenario) <- paste0(levels(dref$scenario), "_ref")
  }

  message("Comparing ", title, " with reference run ", refname, " for t < ", startyear)
  mismatches <- rbind(d, dref) %>%
    filter(period < startyear) %>%
    group_by(model, region, variable, unit, period) %>%
    filter(0 != var(value)) %>%
    ungroup() %>%
    distinct(variable, period) %>%
    group_by(variable) %>%
    summarise(period = paste(sort(period), collapse = ', '))
  if (nrow(mismatches) == 0) {
    message("# Run is perfectly fixed on reference run!")
    return(TRUE)
  }
  showrows <- 30
  theserows <- match(unique(gsub("\\|.*$", "", mismatches$variable)), gsub("\\|.*$", "", mismatches$variable))
  rlang::with_options(width = 160, print(mismatches[theserows, ], n = showrows))
  if (nrow(mismatches) > showrows) message("... plus further ", (nrow(mismatches) - showrows), " variables.") # might be done in a better way
  if (exists("interactivemode") && isTRUE(interactivemode)) {
    message("Do you want to fix that by overwriting ", title, " mif with reference run ", refname, " for t < ", startyear, "? y/N")
    if (tolower(gms::getLine()) %in% c("y", "yes")) {
      di <- rbind(
              filter(d, period >= startyear),
              mutate(filter(dref, period < startyear), scenario = title)
            )
      quitte::write.mif(di, paste0(mifs[[1]], "test"))
      remind2::deletePlus(mifs[[1]], writemif = TRUE)
    }
  }
  return(mismatches)
}

invisible(fixOnMif(outputdir))
