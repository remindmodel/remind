# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
#' ensureRequirementsInstalled
#'
#' Ensure that requirements are installed. If running in an renv, attempt to fix unfulfilled
#' dependencies automatically. Outside of an renv just stop in case of unfulfilled dependencies.
#'
#' @param ask Whether to ask before fixing dependencies. Default: check the autoRenvFixDeps environment variable.
#' @param rerunPrompt If the requirements can not be installed automatically, the user is prompted to restart.
#' The thing to restart can be given in the rerunPrompt variable.


ensureRequirementsInstalled <- function(
    ask = "TRUE" != Sys.getenv("autoRenvFixDeps"),
    rerunPrompt = "start.R in a fresh R session"
) {
  # Check if dependencies for a model run are fulfilled
  if (requireNamespace("piamenv", quietly = TRUE) && packageVersion("piamenv") >= "0.3.4") {
    if (is.null(renv::project())) {
      message("Checking dependencies. If this fails, use a more recent snapshot.")
      piamenv::checkDeps()
    } else {
      installedPackages <- piamenv::fixDeps(ask = ask)
      piamenv::stopIfLoaded(names(installedPackages))
    }
  } else {
    stop(paste0("REMIND requires piamenv >= 0.3.4, please run the following to update it:\n",
                "renv::install('piamenv')\n",
                "and re-run ", rerunPrompt, "."))
  }
}
