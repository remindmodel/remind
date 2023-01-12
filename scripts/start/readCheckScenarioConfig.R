#' read a REMIND scenario_config*.csv file, make sure it contains all columns specified
#' in path_gdx_list.
#' Checks whether scenario titles are neither too long, don't contain dots and don't end with a _
#' Checks for outdated and unknown column titles
#'
#' @param filename string with scenario_config*.csv filename
#' @param remindPath path to remind main directory
#' @param testmode if TRUE, generates warnings if unknownColumnNames exist
#' @author Oliver Richters
#' @return list with scenario config content
readCheckScenarioConfig <- function(filename, remindPath = ".", testmode = FALSE) {
  if (testmode) {
    cfg <- suppressWarnings(gms::readDefaultConfig(remindPath))
  } else {
    cfg <- gms::readDefaultConfig(remindPath)
  }
  scenConf <- read.csv2(filename, stringsAsFactors = FALSE, row.names = 1, na.strings = "", comment.char = "#")
  toolong <- nchar(rownames(scenConf)) > 75
  if (any(toolong)) {
    warning("These titles are too long: ",
            paste0(rownames(scenConf)[toolong], collapse = ", "),
            " – GAMS would not tolerate this, and quit working at a point where you least expect it. Stopping now.")
  }
  regionname <- grepl("^(([A-Z]{3})|(glob))$", rownames(scenConf))
  if (any(regionname)) {
    warning("These titles may be confused with regions: ",
            paste0(rownames(scenConf)[regionname], collapse = ", "),
            " – Titles with three capital letters or 'glob' may be confused with region names by magclass. Stopping now.")
  }
  containsdot <- grep("\\.", rownames(scenConf))
  if (any(containsdot)) {
    warning("These titles contain a dot: ",
            paste0(rownames(scenConf)[containsdot], collapse = ", "),
            " – GAMS would not tolerate this, and quit working at a point where you least expect it. Stopping now.")
  }
  underscore <- grep("_$", rownames(scenConf))
  if (any(underscore)) {
    warning("These titles end with _: ",
            paste0(rownames(scenConf)[underscore], collapse = ", "),
            ". This may lead to wrong gdx files being selected. Please use # to make comments, not underscores.",
            " Stopping now.")
  }
  if ("path_gdx_ref" %in% names(scenConf) && ! "path_gdx_refpolicycost" %in% names(scenConf)) {
    scenConf$path_gdx_refpolicycost <- scenConf$path_gdx_ref
    message("In ", filename,
        ", no column path_gdx_refpolicycost for policy cost comparison found, using path_gdx_ref instead.")
  }
  errorsfound <- sum(toolong) + sum(regionname) + sum(containsdot) + sum(underscore)
  scenConf[, names(path_gdx_list)[! names(path_gdx_list) %in% names(scenConf)]] <- NA
  knownColumnNames <- c(names(cfg$gms), names(path_gdx_list), "start", "output", "description", "model",
                        "regionmapping", "extramappings_historic", "inputRevision", "slurmConfig",
                        "results_folder", "force_replace", "action")
  if (grepl("scenario_config_coupled", filename)) {
    knownColumnNames <- c(knownColumnNames, "cm_nash_autoconverge_lastrun", "oldrun", "path_report", "magpie_scen",
                          "no_ghgprices_land_until", "qos", "sbatch", "path_mif_ghgprice_land", "max_iterations",
                          "magpie_empty")
  }
  unknownColumnNames <- names(scenConf)[! names(scenConf) %in% knownColumnNames]
  if (length(unknownColumnNames) > 0) {
    message("\nAutomated checks did not find counterparts in main.gms and default.cfg for these columns in ",
            basename(filename), ":")
    message("  ", paste(unknownColumnNames, collapse = ", "))
    if (testmode) {
      unknownColumnNamesNoComments <- unknownColumnNames[! grepl("^\\.", unknownColumnNames)]
      if (length(unknownColumnNamesNoComments) > 0) {
        warning("Unknown column names: ", paste(unknownColumnNamesNoComments, collapse = ", "))
      }
    }
    message("The start script might simply ignore them. Please check if these switches are not deprecated.")
    message("This check was added Jan. 2022. If you find false positives, add them to knownColumnNames in start/scripts/readCheckScenarioConfig.R.\n")
    forbiddenColumnNames <- list(   # specify forbidden column name and what should be done with it
       "c_budgetCO2" = "Rename to c_budgetCO2from2020, adapt emission budgets, see https://github.com/remindmodel/remind/pull/640",
       "c_budgetCO2FFI" = "Rename to c_budgetCO2from2020FFI, adapt emission budgets, see https://github.com/remindmodel/remind/pull/640"
     )
    for (i in intersect(names(forbiddenColumnNames), unknownColumnNames)) {
      message("Column name ", i, " in remind settings is outdated. ", forbiddenColumnNames[i])
    }
    if (any(names(forbiddenColumnNames) %in% unknownColumnNames)) {
      warning("Outdated column names found that must not be used.")
      errorsfound <- errorsfound + length(intersect(names(forbiddenColumnNames), unknownColumnNames))
    }
  }
  if (errorsfound > 0) stop(errorsfound, " errors found.")
  return(scenConf)
}
