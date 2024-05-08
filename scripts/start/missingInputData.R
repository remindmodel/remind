missingInputData <- function(path = ".") {
  inputfiles <- gms::getfiledestinations(path = path)
  inputpaths <- file.path(inputfiles$destination, inputfiles$file)
  missinginput <- inputpaths[! file.exists(inputpaths)]
  missinginput <- substr(missinginput, nchar(file.path(path, "")) + 1, 1000000L)
  return(missinginput)
}
