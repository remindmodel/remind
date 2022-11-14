createResultsfolderPythonVirtualEnv <- function(resultsfolder, pythonVirtualEnvLockFile) {
  # create virtual env
  newPythonVirtualEnv <- file.path(resultsfolder, ".venv")
  system2(pythonBinPath(".venv"), c("-mvenv", newPythonVirtualEnv))
  # install packages into it
  system2(pythonBinPath(newPythonVirtualEnv), c("-mpip", "install", "-r", pythonVirtualEnvLockFile))
}
