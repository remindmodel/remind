source("renv/activate.R")

# bootstrapping, will only run once after remind is freshly cloned
if (nrow(installed.packages(priority = "NA")) == 1) {
  # only one package is installed, presumably renv
  renv::install("yaml", prompt = FALSE) # yaml is required to find dependencies in Rmd files
  renv::hydrate() # auto-detect and install all dependencies
  renv::snapshot(prompt = FALSE) # create renv.lock
}

# source global .Rprofile (very important to load user specific settings)
# DO NOT EDIT THIS LINE!
if (file.exists("~/.Rprofile")) {
  source("~/.Rprofile")
}

if (!"https://rse.pik-potsdam.de/r/packages" %in% getOption("repos")) {
  options(repos = c(getOption("repos"), pik = "https://rse.pik-potsdam.de/r/packages"))
}
