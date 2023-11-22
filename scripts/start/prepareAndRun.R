# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
library(gms, quietly = TRUE,warn.conflicts =FALSE)
library(lucode2, quietly = TRUE,warn.conflicts =FALSE)
library(dplyr, quietly = TRUE,warn.conflicts =FALSE)
library(yaml, quietly = TRUE,warn.conflicts=FALSE)
require(gdx)


# Call prepare() and run() without cfg, because cfg is read from results folder, where it has been
# copied to by submit(cfg)

prepareAndRun <- function() {
  if (!file.exists("full.gms")) {
    # If no "full.gms" exists, the script assumes that REMIND did not run before and
    # prepares all inputs before starting the run.
    prepare()
  } else {
    # If "full.gms" exists, the script assumes that a full.gms has been generated before and you want
    # to restart REMIND in the same folder using the gdx that it eventually previously produced.
    if (file.exists("fulldata.gdx")) file.copy("fulldata.gdx", "input.gdx", overwrite = TRUE)
  }

  # Run REMIND, start subsequent runs (if applicable), and produce output.
  run()
}

# Only if this file is run directly via Rscript prepareAndRun.R, but not if this file
# is sourced, actually run
if (sys.nframe() == 0L) {
  # We assume here that our working directory is an output directory

  # Source everything from scripts/start in the main folder so that all functions are available everywhere
  invisible(sapply(list.files("../../scripts/start", pattern = "\\.R$", full.names = TRUE), source))

  prepareAndRun()
}
