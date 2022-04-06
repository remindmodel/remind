#' Return the cfg object created in the R-code chunks of a config-Rmd
#'
#' @param path A single string. The path to the config-Rmd-file.
#' @return A named list containing the values of the parameters defined in the config-Rmd.
readCfgFromRmd <- function(path = "config/defaultConfig.Rmd") {
  tmpFile <- tempfile()
  knitr::purl(path, documentation=0, output=tmpFile, quiet=TRUE)
  env <- new.env()
  source(tmpFile, local=env)
  return(env$cfg)
}
