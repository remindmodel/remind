source("renv/activate.R")

# source global .Rprofile (very important to load user specific settings)
# DO NOT EDIT THIS LINE!
if (file.exists("~/.Rprofile")) {
  source("~/.Rprofile")
}

# TODO do we want this bootstrapping?
# bootstrapping, will only run once after remind is freshly cloned
if (identical(rownames(installed.packages(priority = "NA")), c(Package = "renv")) &&
    !file.exists("renv.lock")) {
  message("renv (project package library) is empty, installing dependencies...")
  # only one non-core package is installed: renv
  renv::install("yaml", prompt = FALSE) # yaml is required to find dependencies in Rmd files
  renv::hydrate() # auto-detect and install all dependencies
  renv::snapshot(prompt = FALSE) # create renv.lock
  # TODO if this bootstrapping procedure is used, adapt 1_GettingREMIND.md
}
