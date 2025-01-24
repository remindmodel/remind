local({
# setting RENV_PATHS_LIBRARY ensures packages are installed into renv/library
# for some reason this also has implications for symlinking into the global cache
Sys.setenv(RENV_PATHS_LIBRARY = "renv/library")

# do not check if library and renv.lock are in sync, because normally renv.lock does not exist
options(renv.config.synchronized.check = FALSE)

source("renv/activate.R")

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
