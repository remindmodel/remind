# |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
library(lucode2)
library(remind2)

if (!exists("outputdirs")) {
  #Define arguments that can be read from command line
  readArgs("outputdirs")
}

gdx_name <- "fulldata.gdx"
gdxPaths <- file.path(outputdirs, gdx_name)
outputFile <- paste0("compareCalibrationTargets-",
                     format(Sys.time(), "%Y-%m-%d_%H.%M.%S"),".html")

remind2::compareCalibrationTargets(
  gdxPaths = gdxPaths,
  outputFile = outputFile
)
