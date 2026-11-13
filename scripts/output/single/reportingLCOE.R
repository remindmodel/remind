# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

#' @title Reporting LCOE
#' @description Creates a csv file with LCOE reporting data

library(remind2)
library(lucode2)

############################# BASIC CONFIGURATION #############################

gdx_name     <- "fulldata.gdx"

if (!exists("source_include")) {
  outputdir <- "."
  lucode2::readArgs("outputdir", "gdx_name")
}
stopifnot(exists("outputdir"))

gdx     <- file.path(outputdir, gdx_name)
scenario <- lucode2::getScenNames(outputdir)
LCOE_reporting_file   <- file.path(outputdir, paste0("REMIND_LCOE_", scenario, ".csv"))

message("### start LCOE reporting at ", round(Sys.time()))
remind2::convGDX2CSV_LCOE(gdx, file = LCOE_reporting_file, scen = scenario)
message("### finish LCOE reporting at ", round(Sys.time()))
