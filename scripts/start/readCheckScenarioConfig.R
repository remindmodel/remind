# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
#' read a REMIND scenario_config*.csv file, make sure it contains all columns specified
#' in path_gdx_list.
#' Checks whether scenario titles are neither too long, don't contain dots and don't end with a _
#' Checks for outdated and unknown column titles
#'
#' @param filename string with scenario_config*.csv filename
#' @param remindPath path to remind main directory
#' @param testmode if TRUE, generates warnings if unknownColumnNames exist
#' @param fillWithDefault boolean whether empty cells should be filled with defaults
#' @author Oliver Richters
#' @return list with scenario config content
readCheckScenarioConfig <- function(filename, remindPath = ".", testmode = FALSE, fillWithDefault = FALSE) {
  coupling <- if (grepl("scenario_config_coupled", filename)) "MAgPIE" else FALSE
  if (testmode) {
    cfg <- suppressWarnings(gms::readDefaultConfig(remindPath))
  } else {
    cfg <- gms::readDefaultConfig(remindPath)
  }
  scenConf <- read.csv2(filename, stringsAsFactors = FALSE, na.strings = "", comment.char = "#",
                        strip.white = TRUE, blank.lines.skip = TRUE, check.names = FALSE)
  scenConf <- scenConf[! is.na(scenConf[1]), ]
  colnames(scenConf) <- make.unique(colnames(scenConf), sep = ".")
  rownames(scenConf) <- scenConf[, 1]
  scenConf[1] <- NULL
  colduplicates <- grep("\\.[1-9]$", colnames(scenConf), value = TRUE)
  if (length(colduplicates) > 0) {
    warning("These colnames are signs of duplicated columns: ", paste(colduplicates, collapse = ", "))
  }
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
  nameisNA <- grepl("^NA$", rownames(scenConf))
  if (any(nameisNA)) {
    warning("Do not use 'NA' as scenario name, you fool. Stopping now.")
  }
  illegalchars <- grepl("[^[:alnum:]_-]", rownames(scenConf))
  if (any(illegalchars)) {
    warning("These titles contain illegal characters: ",
            paste0(rownames(scenConf)[illegalchars], collapse = ", "),
            " – Please use only letters, digits, '_' and '-' to avoid errors, not '",
            unique(gsub("[[:alnum:]_-]", "", paste(rownames(scenConf), collapse = ""))),
            "'. Stopping now.")
  }
  whitespaceErrors <- 0
  for (path_gdx in intersect(names(path_gdx_list), names(scenConf))) {
    haswhitespace <- grepl("\\s", scenConf[[path_gdx]])
    if (any(haswhitespace)) {
      warning("The ", path_gdx, " cells of these runs contain whitespaces: ", paste0(rownames(scenConf)[haswhitespace], collapse = ", "),
              " – scripts will fail to find corresponding runs and gdx files. Stopping now.")
      whitespaceErrors <- whitespaceErrors + sum(haswhitespace)
    }
  }
  missingRealizations <- 0
  modules <- gms::getModules(file.path(remindPath, "modules"))
  for (m in intersect(rownames(modules), colnames(scenConf))) {
    missingRealiz <- setdiff(unique(scenConf[, m]), c(NA, strsplit(modules[m, "realizations"], ",")[[1]]))
    if (length(missingRealiz) > 0) {
      warning("For module ", m, ", the undefined realizations ", paste0(missingRealiz, collapse = ", "),
              " are used by these scenarios: ", paste(rownames(scenConf)[scenConf[,m] %in% missingRealiz], collapse = ", "))
      missingRealizations <- missingRealizations + length(missingRealiz)
    }
  }

  # fill empty cells with values from scenario written in copyConfigFrom cell
  copyConfigFromErrors <- 0
  if ("copyConfigFrom" %in% names(scenConf)) {
    scenConf <- copyConfigFrom(scenConf)
    copyConfigFromErrors <- as.numeric(scenConf[1, "copyConfigFrom"])
    scenConf[1, "copyConfigFrom"] <- NA
  }

  if (fillWithDefault) {
    for (switch in intersect(names(scenConf), c(names(cfg), names(cfg$gms)))) {
      scenConf[is.na(scenConf[, switch]), switch] <- ifelse(switch %in% names(cfg), cfg[[switch]], cfg$gms[[switch]])
    }
  }

  pathgdxerrors <- 0
  # fix missing path_gdx and inconsistencies
  if ("path_gdx_ref" %in% names(scenConf) && ! "path_gdx_refpolicycost" %in% names(scenConf)) {
    if (! isFALSE(coupling)) {
      stop("Your ", basename(filename), " does contain a path_gdx_ref, but no path_gdx_refpolicycost column. ",
          "For REMIND standalone, ref is copied to refpolicycost, but for coupled runs this lead to confusion. ",
          "Please add a path_gdx_refpolicycost column to your config file, see tutorial 4.")
    }
    scenConf$path_gdx_refpolicycost <- scenConf$path_gdx_ref
    message("In ", filename, ", no column path_gdx_refpolicycost found, using path_gdx_ref instead.")
  }

  # make sure every path gdx column exists
  scenConf[, names(path_gdx_list)[! names(path_gdx_list) %in% names(scenConf)]] <- NA

  # check if path_gdx_bau is needed, based on needBau.R
  # initialize vector with FALSE everywhere and turn elements to TRUE if a scenario config row setting matches a needBau element
  scenNeedsBau <- rep(FALSE, nrow(scenConf))
  for (n in intersect(names(needBau), names(scenConf))) {
    scenNeedsBau <- scenNeedsBau | scenConf[[n]] %in% needBau[[n]]
  }
  # fail if bau not given but needed
  noBAUbutNeeded <- is.na(scenConf$path_gdx_bau) & (scenNeedsBau)
  if (sum(noBAUbutNeeded) > 0) {
    pathgdxerrors <- pathgdxerrors + sum(noBAUbutNeeded)
    warning("In ", sum(noBAUbutNeeded), " scenarios, a reference gdx in 'path_gdx_bau' is needed, but it is empty. ",
            "These realizations need it: ",
            paste0(names(needBau), ": ", sapply(needBau, paste, collapse = ", "), ".", collapse = " "))
  }

  startyearmismatch <- NULL
  if ("cm_startyear" %in% names(scenConf)) {
    startyearmismatch <- subset(rownames(scenConf), scenConf[,"cm_startyear"] < scenConf[scenConf[["path_gdx_ref"]], "cm_startyear"])
    if (length(startyearmismatch) > 0) {
      warning("Those scenarios have cm_startyear earlier than their path_gdx_ref run, which is not supported: ",
              paste(startyearmismatch, collapse = ", "))
    }
  }

  if (isTRUE(testmode)) {
    for (n in intersect(names(path_gdx_list), names(scenConf))) {
      missingPath <- ! (is.na(scenConf[, n]) | scenConf[, n] %in% rownames(scenConf))
      if (any(missingPath)) {
         warning("Those scenarios link to a non-existing ", n, ": ",
                 paste0(rownames(scenConf)[missingPath], collapse = ", "))
         pathgdxerrors <- pathgdxerrors + sum(missingPath)
      }
    }
  }

  # collect errors
  errorsfound <- length(colduplicates) + sum(toolong) + sum(regionname) + sum(nameisNA) + sum(illegalchars) + whitespaceErrors +
                 copyConfigFromErrors + pathgdxerrors + missingRealizations + length(startyearmismatch)

  # check column names
  knownColumnNames <- c(names(path_gdx_list), "start", "model", "copyConfigFrom")
  if (coupling %in% "MAgPIE") {
    knownColumnNames <- c(knownColumnNames, "cm_nash_autoconverge_lastrun", "oldrun", "path_report", "magpie_scen",
                          "no_ghgprices_land_until", "qos", "sbatch", "path_mif_ghgprice_land", "max_iterations",
                          "magpie_empty", "var_luc")
    # identify MAgPIE switches by "cfg_mag" and "scenario_config"
    knownColumnNames <- c(knownColumnNames, grep("cfg_mag|scenario_config", names(scenConf), value = TRUE))
  } else { # not a coupling config
    knownColumnNames <- c(knownColumnNames, names(cfg$gms), setdiff(names(cfg), "gms"))
  }
  unknownColumnNames <- names(scenConf)[! names(scenConf) %in% knownColumnNames]
  if (length(unknownColumnNames) > 0) {
    message("")
    forbiddenColumnNames <- list(   # specify forbidden column name and what should be done with it
       "c_budgetCO2" = "Rename to cm_budgetCO2from2020, adapt emission budgets, see https://github.com/remindmodel/remind/pull/640",
       "c_budgetCO2from2020" = "Rename to cm_budgetCO2from2020, see https://github.com/remindmodel/remind/pull/1874",
       "c_budgetCO2from2020FFI" = "Deleted, use cm_budgetCO2from2020 instead, and adapt emission budgets, see https://github.com/remindmodel/remind/pull/1874",
       "c_peakBudgYr" = "Rename to cm_peakBudgYr, see https://github.com/remindmodel/remind/pull/1747",
       "c_budgetCO2FFI" = "Deleted, use cm_budgetCO2from2020 instead, and adapt emission budgets, see https://github.com/remindmodel/remind/pull/1874",
       "cm_bioenergy_tax" = "Rename to cm_bioenergy_SustTax, see https://github.com/remindmodel/remind/pull/1003",
       "cm_bioenergymaxscen" = "Use more flexible cm_maxProdBiolc switch instead, see https://github.com/remindmodel/remind/pull/1054",
       "cm_tradecost_bio" = "Use more flexible cm_tradecostBio switch, see https://github.com/remindmodel/remind/pull/1054",
       "cm_biolc_tech_phaseout" = "Rename to cm_phaseoutBiolc, see https://github.com/remindmodel/remind/pull/1054",
       "cm_INCONV_PENALTY_bioSwitch" = "Rename to cm_INCONV_PENALTY_FESwitch, see https://github.com/remindmodel/remind/pull/544",
       "cm_shSynTrans" = "Rename to cm_shSynLiq, see https://github.com/remindmodel/remind/pull/1169",
       "cm_build_costDecayStart" = "Rename to cm_build_H2costDecayStart, see https://github.com/remindmodel/remind/pull/1057",
       "c_BaselineAgriEmiRed" = "Use more flexible c_agricult_base_shift switch instead, see https://github.com/remindmodel/remind/issues/1157",
       "cm_bioprod_histlim" = "Use more flexible cm_bioprod_regi_lim switch instead, see https://github.com/remindmodel/remind/issues/1157",
       "cm_BioImportTax_EU" = "Use more flexible cm_import_tax switch instead, see https://github.com/remindmodel/remind/issues/1157",
       "cm_trdcst" = "Now always fixed to 1.5, see https://github.com/remindmodel/remind/pull/1052",
       "cm_trdadj" = "Now always fixed to 2, see https://github.com/remindmodel/remind/pull/1052",
       "cm_OILRETIRE" = "Now always on by default, see https://github.com/remindmodel/remind/pull/1102",
       "cm_fixCO2price" = "Was never in use, removed in https://github.com/remindmodel/remind/pull/1369",
       "cm_calibration_FE" = "Deleted, only used for old hand made industry trajectories, see https://github.com/remindmodel/remind/pull/1468",
       "cm_DAC_eff" = "Deleted, not used anymore, see https://github.com/remindmodel/remind/pull/1487",
       "c_taxCO2inc_after_peakBudgYr" = "Rename to cm_taxCO2_IncAfterPeakBudgYr, see https://github.com/remindmodel/remind/pull/1874",
       "cm_taxCO2inc_after_peakBudgYr" = "Rename to cm_taxCO2_IncAfterPeakBudgYr, see https://github.com/remindmodel/remind/pull/1874",
       "c_solscen" = "Deleted, not used anymore, see https://github.com/remindmodel/remind/pull/1515",
       "cm_regNetNegCO2" = "Deleted, not used, see https://github.com/remindmodel/remind/pull/1517",
       "cm_solwindenergyscen" = "Deleted, not used, see https://github.com/remindmodel/remind/pull/1532",
       "cm_wind_offshore" = "Deleted, not used, see https://github.com/remindmodel/development_issues/issues/272",
       "cm_co2_tax_2020" = "Use cm_co2_tax_startyear instead, see https://github.com/remindmodel/remind/pull/1858",
       "cm_co2_tax_startyear" = "Rename to cm_taxCO2_startyear, see https://github.com/remindmodel/remind/pull/1874",
       "cm_co2_tax_growth" = "Rename to cm_taxCO2_expGrowth, see https://github.com/remindmodel/remind/pull/1874",
       "cm_co2_tax_spread" = "Use cm_taxCO2_regiDiff instead, see https://github.com/remindmodel/remind/pull/1874",
       "cm_co2_tax_hist" = "Rename to cm_taxCO2_historical, see https://github.com/remindmodel/remind/pull/1874",
       "cm_year_co2_tax_hist" = "Rename to cm_taxCO2_historicalYr, see https://github.com/remindmodel/remind/pull/1874",
       "cm_CO2priceRegConvEndYr" = "Use cm_taxCO2_regiDiff_endYr instead, see https://github.com/remindmodel/remind/pull/1874",
       "cm_year_co2_tax_hist" = "Use cm_taxCO2_historicalYr instead, see https://github.com/remindmodel/remind/pull/1874",
       "cm_co2_tax_hist" = "Use cm_taxCO2_historical instead, see https://github.com/remindmodel/remind/pull/1874",
       "cm_taxCO2inc_after_peakBudgYr" = "Use cm_taxCO2_IncAfterPeakBudgYr instead, see https://github.com/remindmodel/remind/pull/1874",
       "cm_GDPscen" = "Use cm_GDPpopScen instead, see https://github.com/remindmodel/remind/pull/1973",
       "cm_POPscen" = "Use cm_GDPpopScen instead, see https://github.com/remindmodel/remind/pull/1973",
       "cm_DiscRateScen" = "Deleted, not used anymore, see https://github.com/remindmodel/remind/pull/2001",
     NULL)
    for (i in intersect(names(forbiddenColumnNames), unknownColumnNames)) {
      msg <- paste0("Column name ", i, " in remind settings is outdated. ", forbiddenColumnNames[i])
      if (testmode) warning(msg) else message(msg)
    }
    if (any(names(forbiddenColumnNames) %in% unknownColumnNames)) {
      warning("Outdated column names found that must not be used.")
      errorsfound <- errorsfound + length(intersect(names(forbiddenColumnNames), unknownColumnNames))
    }
    # sort out known but forbidden names from unknown
    commentColNames <- grep("^\\.", unknownColumnNames, value = TRUE)
    if (length(commentColNames) > 0) {
      message("readCheckScenarioConfig.R treats these columns starting with '.' as comments: ", paste(commentColNames, collapse = ", "))
    }
    unknownColumnNames <- setdiff(unknownColumnNames, c(commentColNames, names(forbiddenColumnNames)))
    if (length(unknownColumnNames) > 0) {
      message("\nAutomated checks did not understand these columns in ", basename(filename), ":")
      message("  ", paste(unknownColumnNames, collapse = ", "))
      if (isFALSE(coupling)) message("These are no cfg or cfg$gms switches found in main.gms and default.cfg.")
      if (coupling %in% "MAgPIE") {
        message("Maybe you specified REMIND switches in coupled config, which does not work.")
        if (any(grepl("cfg$gms", unknownColumnNames, fixed = TRUE))) {
          message("MAgPIE switches need to start with 'cfg_mag$gms', not 'cfg$gms'.")
        }
      }
      message("If you find false positives, add them to knownColumnNames in scripts/start/readCheckScenarioConfig.R.\n")
      if (length(unknownColumnNames) > 0) {
        if (testmode) {
          warning("Unknown column names: ", paste(unknownColumnNames, collapse = ", "))
        } else if (errorsfound == 0) {
          message("Do you want to continue and simply ignore them? Y/n")
          userinput <- tolower(gms::getLine())
          if (! userinput %in% c("y", "")) stop("Ok, so let's stop.")
        }
      }
    }
  }
  if (errorsfound > 0) {
    if (testmode) warning(errorsfound, " errors found.")
      else stop(errorsfound, " errors found, see explanation in warnings.")
  }
  return(scenConf)
}

copyConfigFrom <- function(scenConf) {
  copyFromMissing <- setdiff(scenConf[, "copyConfigFrom"], c(NA, rownames(scenConf)))
  copyFromLater <- ! (match(scenConf[, "copyConfigFrom"], rownames(scenConf)) < seq_along(rownames(scenConf)) |
                   is.na(scenConf[, "copyConfigFrom"]) | scenConf[, "copyConfigFrom"] %in% copyFromMissing)
  if (length(copyFromMissing) > 0) {
    warning("The following scenario names indicated in copyConfigFrom column were not found in scenario list: ",
            paste0(copyFromMissing, collapse = ", "), ". Stopping now.")
  }
  if (any(copyFromLater)) {
    warning("The following scenarios specify in copyConfigFrom column a scenario name defined below in the file: ",
            paste0(rownames(scenConf)[copyFromLater], collapse = ", "), ". Fix the order of scenarios. Stopping now.")
  }
  for (run in rownames(scenConf)) {
    copyConfigFrom <- scenConf[run, "copyConfigFrom"]
    if (! is.na(copyConfigFrom)) {
      scenConf[run, is.na(scenConf[run, ])] <- scenConf[copyConfigFrom, is.na(scenConf[run, ])]
    }
  }
  # save error count into first element which must be NA anyway
  scenConf[1, "copyConfigFrom"] <- length(copyFromMissing) + sum(copyFromLater)
  return(scenConf)
}
