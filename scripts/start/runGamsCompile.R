# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
#' compile a modelFile with a cfg 
#'
#' @param modelFile filename of model file to be compiled
#' @param cfg list with REMIND configuration
#' @param interactive boolean, if TRUE, will ask user to compile again after fails
#' @author Oliver Richters
#' @return boolean whether compilation was successful
runGamsCompile <- function(modelFile, cfg, interactive = TRUE) {
  # Define colors for output
  red   <- "\033[0;31m"
  green <- "\033[0;32m"
  NC    <- "\033[0m"   # No Color
  gcdir <- file.path(dirname(modelFile), "output", "gamscompile")
  dir.create(gcdir, recursive = TRUE, showWarnings = FALSE)
  tmpModelFile <- file.path(gcdir, paste0("main_", cfg$title, ".gms"))
  file.copy(modelFile, tmpModelFile, overwrite = TRUE)
  lucode2::manipulateConfig(tmpModelFile, cfg$gms)
  exitcode <- system2(
    command = cfg$gamsv,
    args = paste(tmpModelFile, "-o", gsub("gms$", "lst", tmpModelFile),
                 "-action=c -errmsg=1 -pw=132 -ps=0 -logoption=0"))
  if (0 < exitcode) {
    message(red, "FAIL ", NC, gsub("gms$", "lst", tmpModelFile))
    if (interactive) {
      Sys.sleep(1)
      system(paste("less -j 4 --pattern='^\\*\\*\\*\\*'",
                  gsub("gms$", "lst", tmpModelFile)))
      message("Do you want to rerun, because you fixed the error already? y/N")
      if (gms::getLine() %in% c("Y", "y")) {
        return(runGamsCompile(modelFile, cfg, interactive))
      }
    }
    return(FALSE)
  } else {
    message(green, " OK  ", NC, gsub("gms$", "lst", tmpModelFile))
    return(TRUE)
  }
}
