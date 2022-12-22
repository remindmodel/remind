#' compile a modelFile with a cfg 
#'
#' @param modelFile filename of model file to be compiled
#' @param cfg list with REMIND configuration
#' @param interactive boolean, if TRUE, will ask user to compile again after fails
#' @author Oliver Richters
#' @return boolean whether compilation was successful
runGamsCompile <- function(modelFile, cfg, interactive = TRUE) {
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
    message("FAIL ", gsub("gms$", "lst", tmpModelFile))
    Sys.sleep(1)
    if (interactive) {
      system(paste("less -j 4 --pattern='^\\*\\*\\*\\*'",
                  gsub("gms$", "lst", tmpModelFile)))
      message("Do you want to rerun, because you fixed the error already? y/N")
      if (gms::getLine() %in% c("Y", "y")) {
        return(runGamsCompile(modelFile, cfg, interactive))
      }
    }
    return(FALSE)
  } else {
    message("  OK ", gsub("gms$", "lst", tmpModelFile))
    return(TRUE)
  }
}
