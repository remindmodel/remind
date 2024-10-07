# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
#' take a REMIND cfg, runs some consistency checks and automatically fix some wrong settings
#' The regexp check loads the code from main.gms and looks for 'regexp = ' patterns.
#' It then checks whether the current cfg matches those patterns.
#'
#' @param cfg list with REMIND setting
#' @param remindPath path to REMIND directory containing the main.gms
#' @param testmode boolean. Default is FALSE which fails on errors, in testmode only raise warnings
#' @author Oliver Richters
#' @return updated cfg
checkFixCfg <- function(cfg, remindPath = ".", testmode = FALSE) {
  errorsfound <- 0
  red   <- "\033[0;31m"
  NC    <- "\033[0m"   # No Color

  refcfg <- gms::readDefaultConfig(remindPath)
  remindextras <- c("backup", "remind_folder", "pathToMagpieReport", "cm_nash_autoconverge_lastrun", "var_luc",
                               "gms$c_expname", "restart_subsequent_runs", "gms$c_GDPpcScen",
                               "gms$cm_CES_configuration", "gms$c_description", "model", "renvLockFromPrecedingRun")
  fail <- tryCatch(gms::check_config(cfg, reference_file = refcfg, modulepath = file.path(remindPath, "modules"),
                     settings_config = file.path(remindPath, "config", "settings_config.csv"),
                     extras = remindextras),
                     error = function(x) { paste0(red, "Error", NC, ": ", gsub("^Error: ", "", x)) } )
  if (! identical(refcfg$model_version, cfg$model_version)) {
    message("The model version when the cfg was generated (", cfg$model_version, ") and the current version (",
            refcfg$model_version, ") differ. This might cause fails. If so, try to start the run from scratch.")
  }
  if (is.character(fail) && length(fail) == 1 && grepl("Error", fail)) {
    message(fail, appendLF = FALSE)
    if (testmode) warning(fail)
    errorsfound <- errorsfound + 1
  }

  ## regexp check
  # extract all instances of 'regexp' from main.gms
  code <- grep("regexp", readLines(file.path(remindPath, "main.gms"), warn = FALSE), value = TRUE)
  # this is used to replace all 'regexp = is.numeric'
  grepisnum <- "((\\+|-)?[0-9]*([0-9]\\.?|\\.?[0-9])[0-9]*)"
  grepisnonnegative <- "(\\+?[0-9]*([0-9]\\.?|\\.?[0-9])[0-9]*)"
  grepisshare <-  "(\\+?0?\\.[0-9]+|0|0\\.0*|1|1\\.0*)"
  # some simple tests
  if (testmode) {
    stopifnot(all(  grepl(paste0("^", grepisnum, "$"), c("2", "2.2", "32.", "+32.", "+.05", "-0.5", "-.5", "-5", "-7."))))
    stopifnot(all(! grepl(paste0("^", grepisnum, "$"), c("2.2.", "0a", "1e1", ".2.", "ab", "2.3a", "--a", "++2"))))
    stopifnot(all(  grepl(paste0("^", grepisnonnegative, "$"), c("2", "2.2", "32.", "+32.", "+.05"))))
    stopifnot(all(! grepl(paste0("^", grepisnonnegative, "$"), c("2.2.", "0a", "1e1", ".2.", "ab", "2.3a", "--a", "++2", "-0.5", "-.5", "-5", "-7."))))
    stopifnot(all(  grepl(paste0("^", grepisshare, "$"), c("0", "0.0", ".000", "1.0", "1.", "1", "0.12341234"))))
    stopifnot(all(! grepl(paste0("^", grepisshare, "$"), c("1.1", "-0.3", "-0", "."))))
  }

  for (n in names(cfg$gms)) {
    errormsg <- NULL
    # how parameter n is defined in main.gms
    paramdef <- paste0("^([ ]*", n, "[ ]*=|\\$setglobal[ ]+", n, " )")
    # filter fitting parameter definition from code snippets containing regexp
    filtered <- grep(paste0(paramdef, ".*regexp[ ]*=[ ]*"), code, value = TRUE, ignore.case = TRUE)
    if (length(filtered) == 1) {
      # search for string '!! regexp = whatever', potentially followed by '!! otherstuff' and extract 'whatever'
      regexp <- paste0("^(", trimws(gsub("!!.*", "", gsub("^.*regexp[ ]*=", "", filtered))), ")$")
      # replace is.numeric by pattern defined above
      useregexp <- gsub("is.numeric", grepisnum, regexp, fixed = TRUE)
      useregexp <- gsub("is.nonnegative", grepisnonnegative, useregexp, fixed = TRUE)
      useregexp <- gsub("is.share", grepisshare, useregexp, fixed = TRUE)
      # check whether parameter value fits regular expression
      if (! grepl(useregexp, cfg$gms[[n]])) {
        errormsg <- paste0("Parameter cfg$gms$", n, "=", cfg$gms[[n]], " does not fit this regular expression in main.gms: ", regexp)
      }
    } else if (length(filtered) > 1) {
      # fail if more than one regexp found for parameter
      errormsg <- paste0("More than one regexp found for ", n, ". These are the code lines:\n", paste(filtered, collapse = "\n"))
    }
    # count errors
    if (! is.null(errormsg)) {
      errorsfound <- errorsfound + 1
      message(errormsg)
      if (testmode) warning(errormsg)
    }
  }

  if (errorsfound > 0) {
    if (testmode) warning(errorsfound, " errors found.")
      else stop(errorsfound, " errors found, see above.")
  }

  # Check for compatibility with subsidizeLearning
  if ((cfg$gms$optimization != "nash") && (cfg$gms$subsidizeLearning == "globallyOptimal") ) {
    message("Only optimization='nash' is compatible with subsidizeLearning='globallyOptimal'. Switching subsidizeLearning to 'off' now.")
    cfg$gms$subsidizeLearning <- "off"
  }

  # reportCEScalib only works with the calibrate module
  if (! isTRUE(cfg$gms$CES_parameters == "calibrate")) {
    cfg$output <- setdiff(cfg$output, "reportCEScalib")
  }

  # remove rev at the beginning of inputRevision
  if (grepl("^rev", cfg$inputRevision)) {
    cfg$inputRevision <- sub("^rev", "", cfg$inputRevision)
    warning("cfg$inputRevision started with 'rev', but this will be added automatically. Removed it.")
  }

  # Make sure that an input_bau.gdx has been specified if needed.
  isBauneeded <- isTRUE(length(unlist(lapply(names(needBau), function(x) intersect(cfg$gms[[x]], needBau[[x]])))) > 0)
  if (isBauneeded) {
    if (is.na(cfg$files2export$start["input_bau.gdx"])) {
      errormsg <- "A module requires a reference gdx in 'path_gdx_bau', but it is empty."
      if (testmode) warning(errormsg) else stop(errormsg)
    }
  } else {
    if (! is.na(cfg$files2export$start["input_bau.gdx"])) {
      message("According to 'scripts/start/needBau.R', you use no realization that requires 'path_gdx_bau' but you have specified it. ",
              "To avoid an unnecessary dependency to another run, you can set 'path_gdx_bau' to NA.")
    }
  }

  if (errorsfound > 0) {
    cfg$errorsfoundInCheckFixCfg <- errorsfound
  }  
  return(cfg)
}
