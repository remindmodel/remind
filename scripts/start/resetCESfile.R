#' reset modules/29_CES_parameters/load/datainput.gms
#' @param remindPath path to main remind folder

resetCESfile <- function(remindPath = ".") {
  replace_in_file(file    = file.path(remindPath, "modules/29_CES_parameters/load/datainput.gms"),
                  content = '$include "./modules/29_CES_parameters/load/input/CES_configuration.inc"',
                  subject = "CES INPUT")
}
