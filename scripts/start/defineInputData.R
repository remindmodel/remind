# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
#' construct list of input data files
#' @param cfg list of configs
#' @param remindPath path to REMIND main folder

defineInputData <- function(cfg, remindPath = ".") {

  regicode <- madrat::regionscode(file.path(remindPath, cfg$regionmapping))
  cfg$input <- c(paste0("rev",cfg$inputRevision,"_",regicode,"_", tolower(cfg$model_name),".tgz"),
                 paste0("rev",cfg$inputRevision,"_",regicode,ifelse(cfg$extramappings_historic == "","",paste0("-", madrat::regionscode(cfg$extramappings_historic))),"_", tolower(cfg$validationmodel_name),".tgz"),
                 paste0("CESparametersAndGDX_",cfg$CESandGDXversion,".tgz"))
  
  # Specify for each element of input_new whether to stop if the respective file could not be downloaded
  cfg$stopOnMissing <- c(TRUE, FALSE, TRUE)
  return(cfg)
}
