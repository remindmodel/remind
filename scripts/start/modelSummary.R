# |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

modelSummary <- function(folder = ".", gams_runtime = NULL) {

  if (folder == "") folder <- "."
  require(gdx, quietly = TRUE)
  explain_modelstat <- c("1" = "Optimal", "2" = "Locally Optimal", "3" = "Unbounded", "4" = "Infeasible",
                         "5" = "Locally Infeasible", "6" = "Intermediate Infeasible", "7" = "Intermediate Nonoptimal")
  modelstat <- numeric(0)
  stoprun <- FALSE
  cfg <- NULL
  load(file.path(folder, "config.Rdata"))

  message("Model summary:")
  # Print REMIND runtime
  if (! is.null(gams_runtime)) {
    message("  gams_runtime is ", round(gams_runtime, 1), " ", units(gams_runtime), ".")
  }

  if (! file.exists(file.path(folder, "full.gms"))) {
    message("! full.gms does not exist, so the REMIND GAMS code was not generated.")
    stoprun <- TRUE
  } else {
    message("  full.gms exists, so the REMIND GAMS code was generated.")
    if (! file.exists(file.path(folder, "full.lst")) | ! file.exists(file.path(folder, "full.log"))) {
      message("! full.log or full.lst does not exist, so GAMS did not run.")
      stoprun <- TRUE
    } else {
      message("  full.log and full.lst exist, so GAMS did run.")
      if (! file.exists(file.path(folder, "abort.gdx"))) {
        message("  abort.gdx does not exist, a file written automatically for some types of errors.")
      } else {
        message("! abort.gdx exists, a file containing the latest data at the point GAMS aborted execution.")
      }
      if (! file.exists(file.path("non_optimal.gdx"))) {
        message("  non_optimal.gdx does not exist, a file written if at least one iteration did not find a locally optimal solution.")
      } else {
        modelstat_no <- as.numeric(readGDX(gdx = file.path(folder, "non_optimal.gdx"), "o_modelstat", format = "simplest"))
        max_iter_no  <- as.numeric(readGDX(gdx = file.path(folder, "non_optimal.gdx"), "o_iterationNumber", format = "simplest"))
        message("  non_optimal.gdx exists, because iteration ", max_iter_no, " did not find a locally optimal solution. ",
          "modelstat: ", modelstat_no, if (modelstat_no %in% names(explain_modelstat)) paste0(" (", explain_modelstat[modelstat_no], ")"))
        modelstat[[as.character(max_iter_no)]] <- modelstat_no
      }
      if(! file.exists(file.path("fulldata.gdx"))) {
        message("! fulldata.gdx does not exist, so output generation will fail.")
        if (cfg$action == "ce") {
          stoprun <- TRUE
        }
      } else {
        modelstat_fd <- as.numeric(readGDX(gdx = file.path(folder, "fulldata.gdx"), "o_modelstat", format = "simplest"))
        max_iter_fd  <- as.numeric(readGDX(gdx = file.path(folder, "fulldata.gdx"), "o_iterationNumber", format = "simplest"))
        message("  fulldata.gdx exists, because iteration ", max_iter_fd, " was successful. ",
          "modelstat: ", modelstat_fd, if (modelstat_fd %in% names(explain_modelstat)) paste0(" (", explain_modelstat[modelstat_fd], ")"))
        modelstat[[as.character(max_iter_fd)]] <- modelstat_fd
      }
      if (length(modelstat) > 0) {
        modelstat <- modelstat[which.max(names(modelstat))]
        message("  Modelstat after ", as.numeric(names(modelstat)), " iterations: ", modelstat,
                if (modelstat %in% names(explain_modelstat)) paste0(" (", explain_modelstat[modelstat], ")"))
      }
      logStatus <- grep("*** Status", readLines(file.path(folder, "full.log")), fixed = TRUE, value = TRUE)
      message("  full.log states: ", paste(logStatus, collapse = ", "))
      if (! all("*** Status: Normal completion" == logStatus)) stoprun <- TRUE
    }
  }

  if (identical(cfg$gms$optimization, "nash") && file.exists(file.path(folder, "full.lst")) && cfg$action == "ce") {
    message("\nInfeasibilities extracted from full.lst with nashstat -F:")
    command <- paste(
      "li=$(nashstat -F | wc -l); cat",   # li-1 = #infes
      "<(if (($li < 2)); then echo no infeasibilities found; fi)",
      "<(if (($li > 1)); then nashstat -F | head -n 2 | sed -r 's/\\x1B\\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g'; fi)",
      "<(if (($li > 4)); then echo ... $(($li - 3)) infeasibilities omitted, show all with 'nashstat -a' ...; fi)",
      "<(if (($li > 2)); then nashstat -F | tail -n 1 | sed -r 's/\\x1B\\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g'; fi)",
      "<(if (($li > 3)); then echo If infeasibilities appear some iterations before GAMS failed, check 'nashstat -a' carefully.; fi)",
      "<(if (($li > 3)); then echo The error that stopped GAMS is probably not the actual reason to fail.; fi)")
    nashstatres <- try(system2("/bin/bash", args = c("-c", shQuote(command))))
    if (nashstatres != 0) message("nashstat not found, search for p80_repy in full.lst yourself.")
  }
  message("")

  if (file.exists(file.path(folder, "fulldata.gdx")) && identical(cfg$gms$optimization, "nash") &&
      cfg$action == "ce" && all(c("dplyr", "quitte", "rlang") %in% installed.packages())) {
    failedmarkets <- quitte::as.quitte(readGDX(file.path(folder, "fulldata.gdx"), "p80_messageFailedMarket"))
    failedmarkets <- droplevels(dplyr::filter(failedmarkets, !!rlang::sym("value") == 1))
    if (nrow(failedmarkets) > 0) {
      message("Failed markets in fulldata.gdx:")
      for (m in levels(failedmarkets$all_enty)) {
        mf <- failedmarkets$period[failedmarkets$all_enty == m]
        message(" - ", m, ": ", paste0(mf[1:min(length(mf), 10)], collapse = ", "), if (length(mf) > 10) " ...")
      }
    } else {
      message("No failed markets in fulldata.gdx.")
    }
    failedtaxes <- quitte::as.quitte(readGDX(file.path(folder, "fulldata.gdx"), "p80_taxrev_dev"))
    failedtaxes <- droplevels(dplyr::filter(failedtaxes, !!rlang::sym("value") == 1))
    if (nrow(failedtaxes) > 0) {
      message("Failed tax convergence in fulldata.gdx:")
      for (r in levels(failedtaxes$region)) {
        rf <- failedtaxes$period[failedtaxes$region == r]
        message(" - ", r, ": ", paste0(rf[1:mif(length(rf), 10)], collapse = ", "), if (length(rf) > 10) " ...")
      }
    } else {
      message("No failed tax convergence in fulldata.gdx.")
    }
    message("")
  }
  return(list("stoprun" = stoprun, "modelstat" = as.numeric(modelstat)))
}
