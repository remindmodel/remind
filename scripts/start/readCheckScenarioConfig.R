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
  illegalchars <- grepl("[^[:alnum:]_-]", rownames(scenConf))
  if (any(illegalchars)) {
    warning("These titles contain illegal characters: ",
            paste0(rownames(scenConf)[illegalchars], collapse = ", "),
            " – Please use only letters, digits, '_' and '-' to avoid errors, not '",
            gsub("[[:alnum:]_-]", "", paste(rownames(scenConf), collapse = "")), "'. Stopping now.")
  }
  whitespaceerrors <- 0
  for (path_gdx in intersect(names(path_gdx_list), names(scenConf))) {
    haswhitespace <- grepl("\\s", scenConf[[path_gdx]])
    if (any(haswhitespace)) {
      warning("The ", path_gdx, " cells of these runs contain whitespaces: ", paste0(rownames(scenConf)[haswhitespace], collapse = ", "),
              " – scripts will fail to find corresponding runs and gdx files. Stopping now.")
      whitespaceerrors <- whitespaceerrors + sum(haswhitespace)
    }
  }
  errorsfound <- sum(toolong) + sum(regionname) + sum(illegalchars) + whitespaceerrors
  if ("path_gdx_ref" %in% names(scenConf) && ! "path_gdx_refpolicycost" %in% names(scenConf)) {
    scenConf$path_gdx_refpolicycost <- scenConf$path_gdx_ref
    message("In ", filename,
        ", no column path_gdx_refpolicycost for policy cost comparison found, using path_gdx_ref instead.")
  }
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
    message("This check was added Jan. 2022. If you find false positives, add them to knownColumnNames in start/scripts/readCheckScenarioConfig.R.\n")
    unknownColumnNamesNoComments <- unknownColumnNames[! grepl("^\\.", unknownColumnNames)]
    if (length(unknownColumnNamesNoComments) > 0) {
      if (testmode) {
        warning("Unknown column names: ", paste(unknownColumnNamesNoComments, collapse = ", "))
      } else {
        message("Do you want to continue and simply ignore them? Y/n")
        userinput <- tolower(gms::getLine())
        if (! userinput %in% c("y", "")) stop("Ok, so let's stop.")
      }
    }
    forbiddenColumnNames <- list(   # specify forbidden column name and what should be done with it
       "c_budgetCO2" = "Rename to c_budgetCO2from2020, adapt emission budgets, see https://github.com/remindmodel/remind/pull/640",
       "c_budgetCO2FFI" = "Rename to c_budgetCO2from2020FFI, adapt emission budgets, see https://github.com/remindmodel/remind/pull/640",
       "cm_bioenergy_tax" = "Rename to cm_bioenergy_SustTax, see https://github.com/remindmodel/remind/pull/1003",
       "cm_bioenergymaxscen" = "Use more flexible cm_maxProdBiolc switch instead, see https://github.com/remindmodel/remind/pull/1054",
       "cm_tradecost_bio" = "Use more flexible cm_tradecostBio switch, see https://github.com/remindmodel/remind/pull/1054",
       "cm_biolc_tech_phaseout" = "Rename to cm_phaseoutBiolc, see https://github.com/remindmodel/remind/pull/1054",
       "cm_INCONV_PENALTY_bioSwitch" = "Rename to cm_INCONV_PENALTY_FESwitch, see https://github.com/remindmodel/remind/pull/544",
       "cm_shSynTrans" = "Rename to cm_shSynLiq, see https://github.com/remindmodel/remind/pull/1169",
       "cm_build_costDecayStart" = "Rename to cm_build_H2costDecayStart, see https://github.com/remindmodel/remind/pull/1057",
       "c_BaselineAgriEmiRed" = "Use more flexible c_agricult_base_shift switch instead, see https://github.com/remindmodel/remind/issues/1157",
       "cm_bioprod_histlim" = "Use more flexible cm_bioprod_regi_lim switch instead, see https://github.com/remindmodel/remind/issues/1157",
       "cm_BioImportTax_EU" = "Use more flexible cm_import_tax switch instead, see https://github.com/remindmodel/remind/issues/1157"
     )
    for (i in intersect(names(forbiddenColumnNames), unknownColumnNames)) {
      if (testmode) {
        warning("Column name ", i, " in remind settings is outdated. ", forbiddenColumnNames[i])
      } else {
        message("Column name ", i, " in remind settings is outdated. ", forbiddenColumnNames[i])
      }
    }
    if (any(names(forbiddenColumnNames) %in% unknownColumnNames)) {
      warning("Outdated column names found that must not be used.")
      errorsfound <- errorsfound + length(intersect(names(forbiddenColumnNames), unknownColumnNames))
    }
  }
  if (errorsfound > 0) if (testmode) warning(errorsfound, " errors found.") else stop(errorsfound, " errors found, see explanation in warnings.")
  return(scenConf)
}
