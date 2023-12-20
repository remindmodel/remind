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
  refcfg <- gms::readDefaultConfig(remindPath)
  gms::check_config(cfg, reference_file = refcfg, modulepath = file.path(remindPath, "modules"),
                    settings_config = file.path(remindPath, "config", "settings_config.csv"),
                    extras = c("backup", "remind_folder", "pathToMagpieReport", "cm_nash_autoconverge_lastrun",
                               "gms$c_expname", "restart_subsequent_runs", "gms$c_GDPpcScen",
                               "gms$cm_CES_configuration", "gms$c_description", "model"))

  errorsfound <- 0

  ## regexp check
  # extract all instances of 'regexp' from main.gms
  code <- system(paste0("grep regexp ", file.path(remindPath, "main.gms")), intern = TRUE)
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
    filtered <- grep(paste0(paramdef, ".*regexp[ ]*=[ ]*"), code, value = TRUE)
    if (length(filtered) == 1) {
      # search for string '!! regexp = whatever', potentially followed by '!! otherstuff' and extract 'whatever'
      regexp <- paste0("^(", trimws(gsub("!!.*", "", gsub("^.*regexp[ ]*=", "", filtered))), ")$")
      # replace is.numeric by pattern defined above
      useregexp <- gsub("is.numeric", grepisnum, regexp, fixed = TRUE)
      useregexp <- gsub("is.nonnegative", grepisnonnegative, useregexp, fixed = TRUE)
      useregexp <- gsub("is.share", grepisshare, useregexp, fixed = TRUE)
      # check whether parameter value fits regular expression
      if (! grepl(useregexp, cfg$gms[[n]])) {
        errormsg <- paste0("Parameter cfg$gms$", n, "=", cfg$gms[[n]], " does not fit this regular expression: ", regexp)
      }
    } else if (length(filtered) > 1) {
      # fail if more than one regexp found for parameter
      errormsg <- paste0("More than one regexp found for ", n, ". These are the code lines:\n", paste(filtered, collapse = "\n"))
    }
    # count errors
    if (! is.null(errormsg)) {
      errorsfound <- errorsfound + 1
      if (testmode) warning(errormsg) else message(errormsg)
    }
  }

  if (errorsfound > 0) {
    if (testmode) warning(errorsfound, " errors found.")
      else stop(errorsfound, " errors found, see above. Either adapt the parameter choice or the regexp in main.gms")
  }

  # Check for compatibility with subsidizeLearning
  if ((cfg$gms$optimization != "nash") && (cfg$gms$subsidizeLearning == "globallyOptimal") ) {
    message("Only optimization='nash' is compatible with subsidizeLearning='globallyOptimal'. Switching subsidizeLearning to 'off' now.\n")
    cfg$gms$subsidizeLearning <- "off"
  }

  # reportCEScalib only works with the calibrate module
  if (! isTRUE(cfg$gms$CES_parameters == "calibrate")) {
    cfg$output <- setdiff(cfg$output, "reportCEScalib")
  }
  
  # Make sure that an input_bau.gdx has been specified if an NDC is to be calculated.
  if (isTRUE(cfg$gms$carbonprice == "NDC") | isTRUE(cfg$gms$carbonpriceRegi == "NDC")) {
    if (is.na(cfg$files2export$start["input_bau.gdx"])) {
      errormsg <- "'carbonprice' or 'carbonpriceRegi' is set to 'NDC' which requires a reference gdx in 'path_gdx_bau' but it is empty."
      if (testmode) warning(errormsg) else stop(errormsg)
    }
  } else {
    if (!is.na(cfg$files2export$start["input_bau.gdx"])) {
      message("Neither 'carbonprice' nor 'carbonpriceRegi' is set to 'NDC' but 'path_gdx_bau' ",
              "is not empty introducing an unnecessary dependency to another run. Setting 'path_gdx_bau' to NA")
      cfg$files2export$start["input_bau.gdx"] <- NA        
    }
  }  
  
  return(cfg)
}
