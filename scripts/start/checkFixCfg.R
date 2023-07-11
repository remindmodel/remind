checkFixCfg <- function(cfg, remindPath = ".", testmode = FALSE) {
  refcfg <- gms::readDefaultConfig(remindPath)
  gms::check_config(cfg, reference_file = refcfg, modulepath = file.path(remindPath, "modules"),
                    settings_config = file.path(remindPath, "config", "settings_config.csv"),
                    extras = c("backup", "remind_folder", "pathToMagpieReport", "cm_nash_autoconverge_lastrun",
                               "gms$c_expname", "restart_subsequent_runs", "gms$c_GDPpcScen",
                               "gms$cm_CES_configuration", "gms$c_description", "model"))

  errorsfound <- 0

  code <- system(paste0("grep regexp ", file.path(remindPath, "main.gms")), intern = TRUE)
  grepisnum <- "((\\+|-)?[0-9]*([0-9]\\.?|\\.?[0-9])[0-9]*)"

  for (n in names(cfg$gms)) {
    errormsg <- NULL
    paramdef <- paste0("^([ ]*", n, "[ ]*=|\\$setglobal[ ]+", n, " )")
    filtered <- grep(paste0(paramdef, ".*regexp[ ]*=[ ]*"), code, value = TRUE)
    if (length(filtered) == 1) {
      # search for string '!! regexp = whatever', potentially followed by '!! otherstuff' and extract 'whatever'
      regexp <- paste0("^(", trimws(gsub("!!.*", "", gsub("^.*regexp[ ]*=", "", filtered))), ")$")
      useregexp <- gsub("is.numeric", grepisnum, regexp, fixed = TRUE)
      if (! grepl(useregexp, cfg$gms[[n]])) {
        errormsg <- paste0("Parameter cfg$gms$", n, "=", cfg$gms[[n]], " does not fit this regular expression: ", regexp)
      }
    } else if (length(filtered) > 1) {
      errormsg <- paste0("More than one regexp found for ", n, ". These are the code lines:\n", paste(filtered, collapse = "\n"))
    }
    if (! is.null(errormsg)) {
      errorsfound <- errorsfound + 1
      if (testmode) warning(errormsg) else message(errormsg)
    }
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
  if (errorsfound > 0) {
    if (testmode) warning(errorsfound, " errors found.")
      else stop(errorsfound, " errors found, see above. Either adapt the parameter choice or the regexp in main.gms")
  }

  return(cfg)
}
