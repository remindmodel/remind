# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
#' update input data files in REMIND
#' @param cfg list of configs
#' @param remindPath path to main remind folder
#' @param gamsCompile if set to TRUE, missing files don't trigger reload and most messages are suppressed

updateInputData <- function(cfg, remindPath = ".", gamsCompile = FALSE) {

  # write name of corresponding CES file to datainput.gms
  cfg$gms$cm_CES_configuration <- calculate_CES_configuration(cfg, path = remindPath)

  if(file.exists("input/source_files.log")) {
      input_old     <- readLines(file.path(remindPath, "input/source_files.log"))[c(1,2,3)]
  } else {
      input_old     <- "no_data"
  }
  
  cfg <- defineInputData(cfg, remindPath)
  
  # check if all input files are already there
  missinginput <- if (isTRUE(gamsCompile)) NULL else missingInputData()
  requiredinput <- grep("config\\/gdx-files|modules\\/29_CES_parameters\\/load\\/input", missinginput, value = TRUE, invert = TRUE)

  # download and distribute needed data
  if (! setequal(cfg$input, input_old) || isTRUE(cfg$force_download) || length(requiredinput) > 0) {
      message(if (isTRUE(gamsCompile)) paste0("     ", cfg$title, ": "),
              if (isTRUE(cfg$force_download)) "You set 'cfg$force_download = TRUE'"
              else "Your input data are outdated, incomplete or in a different regional resolution",
              ". New input data are downloaded and distributed.")
      condSuppress <- function(x) if (isTRUE(gamsCompile)) suppressMessages(x) else x
      condSuppress(download_distribute(files         = cfg$input,
                                       repositories  = cfg$repositories, # defined in your environment variables
                                       modelfolder   = remindPath,
                                       debug         = FALSE,
                                       stopOnMissing = if (isTRUE(gamsCompile)) FALSE else cfg$stopOnMissing)
                  )
  } else if (! isTRUE(gamsCompile)) {
      message("No input data downloaded and distributed. To enable that, delete input/source_files.log or set cfg$force_download to TRUE.")
  }
  return(cfg)
}
