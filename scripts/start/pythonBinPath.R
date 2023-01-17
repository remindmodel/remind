pythonBinPath <- function(venv) {
  binName <- "bin/python"
  if (.Platform$OS.type == "windows") {
    # Windows needs special attention
    binName <- "Scripts/python.exe"
  }
  return(file.path(normalizePath(venv, mustWork = TRUE), binName))
}
