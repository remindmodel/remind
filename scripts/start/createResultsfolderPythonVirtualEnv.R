# |  (C) 2023 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

createResultsfolderPythonVirtualEnv <- function(resultsfolder) {
  # create virtual env
  newPythonVirtualEnv <- file.path(resultsfolder, ".venv")
  system2(pythonBinPath(".venv"), c("-mvenv", newPythonVirtualEnv))
  # install packages into it
  virtualEnvLockFile <- file.path(resultsfolder, "venv.lock")
  writePythonVirtualEnvLockFile(virtualEnvLockFile)
  system2(pythonBinPath(newPythonVirtualEnv), c("-mpip", "install", "-r", virtualEnvLockFile))
  return(invisible(TRUE))
}
