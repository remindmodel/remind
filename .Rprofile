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

# configure locations of REMIND input data
foo <- Sys.getenv('REMIND_repos')
if ('' != foo) {
  # local directories, separated by colons (":")
  foo <- unlist(strsplit(foo, ':', fixed = TRUE))
  bar <- rep(list(NULL), length(foo))
  attr(bar, 'names') <- foo
  options(remind_repos = bar)
  rm('bar')
} else if (all(file.exists(
                 c('/p/projects/rd3mod/inputdata/output',
                   '/p/projects/remind/inputdata/CESparametersAndGDX')))) {
  # default cluster directories
  options(remind_repos = list(
    '/p/projects/rd3mod/inputdata/output' = NULL,
    '/p/projects/remind/inputdata/CESparametersAndGDX' = NULL))
}
rm('foo')
