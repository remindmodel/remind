createResultsfolderPythonVirtualEnv <- function(resultsfolder) {
  # create virtual env
  newPythonVirtualEnv <- file.path(resultsfolder, ".venv")
  system2(pythonBinPath(".venv"), c("-mvenv", newPythonVirtualEnv))
  # install packages into it
  virtualEnvLockFile <- file.path(resultsfolder, "venv.lock")
  writePythonVirtualEnvLockFile(virtualEnvLockFile)
  system2(pythonBinPath(newPythonVirtualEnv), c("-mpip", "install", "-r", virtualEnvLockFile))
}
