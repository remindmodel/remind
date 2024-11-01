local({
# setting RENV_PATHS_LIBRARY ensures packages are installed into renv/library
# for some reason this also has implications for symlinking into the global cache
Sys.setenv(RENV_PATHS_LIBRARY = "renv/library")

# do not check if library and renv.lock are in sync, because normally renv.lock does not exist
options(renv.config.synchronized.check = FALSE)

# always set the renv project to the current directory
Sys.setenv("RENV_PROJECT" = getwd())

# when increasing renvVersion first commit new version's activate script and
# put that commit's hash into the git checkout call below
renvVersion <- "1.0.7"

# reset renv/activate.R to match renv 1.0.7
gitRoot <- system2("git", c("rev-parse", "--show-toplevel"), stdout = TRUE)
if (Sys.getenv("RESET_RENV_ACTIVATE_SCRIPT", unset = "TRUE") == "TRUE" &&
      normalizePath(gitRoot) == normalizePath(".")) {
  system2("git", c("checkout", "b83bb1811ff08d8ee5ba8e834af5dd0080d10e66", "--", "renv/activate.R"))
}

source("renv/activate.R")

if (packageVersion("renv") != renvVersion) {
  renvLockExisted <- file.exists(renv::paths$lockfile())
  renv::install(paste0("renv@", renvVersion))
  if (!renvLockExisted) {
    unlink(renv::paths$lockfile())
  }
}

if (!"https://rse.pik-potsdam.de/r/packages" %in% getOption("repos")) {
  options(repos = c(getOption("repos"), pik = "https://rse.pik-potsdam.de/r/packages"))
}

# bootstrapping, will only run once after remind is freshly cloned
if (isTRUE(rownames(installed.packages(priority = "NA")) == "renv")) {
  message("R package dependencies are not installed in this renv, installing now...")
  renv::install("rmarkdown", prompt = FALSE) # rmarkdown is required to find dependencies in Rmd files
  renv::hydrate(prompt = FALSE, report = FALSE) # auto-detect and install all dependencies
  message("Finished installing R package dependencies.")
}

# bootstrapping python venv, will only run once after remind is freshly cloned
if (!dir.exists(".venv/")
    && (Sys.which("python3") != ""
        || (Sys.which("python.exe") != ""
            && suppressWarnings(isTRUE(startsWith(system2("python.exe", "--version", stdout = TRUE), "Python 3")))
           ))) {
  message("Python venv is not available, setting up now...")
  # use system python to set up venv
  if (.Platform$OS.type == "windows") {
    system2("python.exe", c("-mvenv", ".venv"))
    pythonInVenv <- normalizePath(file.path(".venv", "Scripts", "python.exe"), mustWork = TRUE)
  } else {
    system2("python3", c("-mvenv", ".venv"))
    pythonInVenv <- normalizePath(file.path(".venv", "bin", "python"), mustWork = TRUE)
  }
  # use venv python to install dependencies in venv
  system2(pythonInVenv, c("-mpip", "install", "--upgrade", "pip", "wheel"))
  system2(pythonInVenv, c("-mpip", "install", "-r", "requirements.txt"))
}

# Configure locations of REMIND input data
# These can be located in directories on the local machine, remote directories,
# or default directories on the cluster.
# To use these, set the environment variable in your ~/.bashrc file in your home
# direcotry (on linux) or in the system environment variables dialog (on windows):

# local directories
# e.g.
# on Linux (separate multiple paths by colons)
# REMIND_repos_dirs="/my/first/path:/my/second/path"
# on Windows (separate multiple paths by semicolons)
# REMIND_repos_dirs="C:\my\first\path;D:\my\second\path"
remindReposDirs <- Sys.getenv("REMIND_repos_dirs")

# add local directories, if any
if ("" != remindReposDirs) {
  directories <- unlist(strsplit(remindReposDirs, .Platform$path.sep, fixed = TRUE))
  directoriesList <- rep(list(NULL), length(directories))
  names(directoriesList) <- directories
  options(remind_repos = c(options("remind_repos")[[1]], directoriesList))
}

# Include local calibration results, if they exist, from either the main
# directory or output directories.
path <- file.path(
    c('.', file.path('..', '..')),
    'calibration_results', '.Rprofile_calibration_results')

path <- head(path[file.exists(path)], 1)

if (!rlang::is_empty(path))
    source(path)
})
