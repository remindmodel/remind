#' ensureRequirementsInstalled
#'
#' Ensure that requirements are installed.
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
    installedPackages <- piamenv::fixDeps(ask = ask)
    piamenv::stopIfLoaded(names(installedPackages))
  } else {
    stop(paste0("REMIND requires piamenv >= 0.3.4, please run the following to update it:\n",
                "renv::install('piamenv')\n",
                "and re-run ", rerunPrompt, "."))
  }
}
