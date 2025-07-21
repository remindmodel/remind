# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

library(remind2)

if (!exists("outputdir")) {
  # Define arguments that can be read from command line
  lucode2::readArgs("outputdir")
}

gdx_name <- "fulldata.gdx"
gdx <- file.path(outputdir, gdx_name)

dir_name <- tail(strsplit(outputdir, split = "/")[[1]], n = 1)

remind2::nashConvergenceReport(
  gdx = gdx,
  outputDir = outputdir
)
