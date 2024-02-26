updateInputData <- function(cfg, remindPath = ".", verbose = TRUE) {
  # write name of corresponding CES file to datainput.gms

  cfg$gms$cm_CES_configuration <- calculate_CES_configuration(cfg, path = remindPath)
  replace_in_file(file    = file.path(remindPath, "modules/29_CES_parameters/load/datainput.gms"),
                  content = paste0('$include "',
                                   "./modules/29_CES_parameters/load/input/",
                                   cfg$gms$cm_CES_configuration, ".inc\""),
                  subject = "CES INPUT")


  if(file.exists("input/source_files.log")) {
      input_old     <- readLines(file.path(remindPath, "input/source_files.log"))[c(1,2,3)]
  } else {
      input_old     <- "no_data"
  }
  regicode <- madrat::regionscode(file.path(remindPath, cfg$regionmapping))
  input_new <- c(paste0("rev",cfg$inputRevision,"_",regicode,"_", tolower(cfg$model_name),".tgz"),
                 paste0("rev",cfg$inputRevision,"_",regicode,ifelse(cfg$extramappings_historic == "","",paste0("-", madrat::regionscode(cfg$extramappings_historic))),"_", tolower(cfg$validationmodel_name),".tgz"),
                      paste0("CESparametersAndGDX_",cfg$CESandGDXversion,".tgz"))
  # check if all input files are there
  missinginput <- missingInputData()

  # download and distribute needed data
  if (! setequal(input_new, input_old) || isTRUE(cfg$force_download) || length(missinginput) > 0) {
      message(if (isTRUE(cfg$force_download)) "You set 'cfg$force_download = TRUE'"
              else "Your input data are outdated, incomplete or in a different regional resolution",
              ". New input data are downloaded and distributed.")
      download_distribute(files        = input_new,
                          repositories = cfg$repositories, # defined in your environment variables
                          modelfolder  = remindPath,
                          debug        = FALSE,
                          stopOnMissing = TRUE)
  } else if (verbose) {
      message("No input data downloaded and distributed. To enable that, delete input/source_files.log or set cfg$force_download to TRUE.")
  }

  return(cfg)
}
