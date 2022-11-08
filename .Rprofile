source("renv/activate.R")

if (!"https://rse.pik-potsdam.de/r/packages" %in% getOption("repos")) {
  options(repos = c(getOption("repos"), pik = "https://rse.pik-potsdam.de/r/packages"))
}

# bootstrapping, will only run once after remind is freshly cloned
if (isTRUE(rownames(installed.packages(priority = "NA")) == "renv")) {
  message("R package dependencies are not installed in this renv, installing now...")
  renv::install("yaml", prompt = FALSE) # yaml is required to find dependencies in Rmd files
  renv::hydrate() # auto-detect and install all dependencies
  renv::snapshot(prompt = FALSE) # create renv.lock
  message("Finished installing R package dependencies.")
}

# Configure locations of REMIND input data
# These can be located in directories on the local machine, remote directories,
# or default directories on the cluster.
REMIND_repos_vars <- c('REMIND_repos_dirs',       # local directories
                       'REMIND_repos_scp',        # scp connections
                       'REMIND_repos_scp_user',   # scp user name
                       'REMIND_repos_scp_key'     # ssh key path
)

# load repos variables into environment
invisible(lapply(REMIND_repos_vars,
                 function(x) { assign(x, Sys.getenv(x), pos = 1) }))
use_cluster_defaults <- TRUE

# add local directories, if any
if ('' != get(REMIND_repos_vars[1])) {
  foo <- unlist(
    strsplit(REMIND_repos_dirs,
             ifelse('Windows' == getElement(Sys.info(), 'sysname'),
                    ';', ':'),
             fixed = TRUE))
  bar <- rep(list(NULL), length(foo))
  attr(bar, 'names') <- foo

  options(remind_repos = c(options('remind_repos')[[1]], bar))
  rm(list = c('foo', 'bar'))
  use_cluster_defaults <- FALSE
}

# add remote directories, if any and username and SSH key are set
if (all('' != sapply(REMIND_repos_vars[2:4], get))) {
  foo <- unlist(strsplit(REMIND_repos_scp, ';', fixed = TRUE))
  bar <- lapply(foo,
                function(x) {
                  list(username = REMIND_repos_scp_user,
                       ssh_private_keyfile = REMIND_repos_scp_key)
                })
  attr(bar, 'names') <- foo
  options(remind_repos = c(options('remind_repos')[[1]], bar))
  rm(list = c('foo', 'bar'))
  use_cluster_defaults <- FALSE
}

# default to cluster directories
if (  use_cluster_defaults
      & all(file.exists(c('/p/projects/rd3mod/inputdata/output',
                          '/p/projects/remind/inputdata/CESparametersAndGDX')))) {
  options(remind_repos = list(
    '/p/projects/rd3mod/inputdata/output' = NULL,
    '/p/projects/remind/inputdata/CESparametersAndGDX' = NULL))
}

# clean up
rm(list = c(REMIND_repos_vars, 'REMIND_repos_vars', 'use_cluster_defaults'))
