# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
missingInputData <- function(path = ".") {
  inputfiles <- gms::getfiledestinations(path = path)
  inputpaths <- file.path(inputfiles$destination, inputfiles$file)
  missinginput <- inputpaths[! file.exists(inputpaths)]
  missinginput <- substr(missinginput, nchar(file.path(path, "")) + 1, 1000000L)
  return(missinginput)
}
