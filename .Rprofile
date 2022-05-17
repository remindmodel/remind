source("renv/activate.R")

options(repos = c(pikruniverse = "https://pik-piam.r-universe.dev", CRAN = "https://cran.rstudio.com/"))

# bootstrapping, will only run once after remind is freshly cloned
if (identical(rownames(installed.packages(priority = "NA")), c(Package = "renv")) &&
    !file.exists("renv.lock")) {
  message("renv (project package library) is empty, installing dependencies...")
  # only one non-core package is installed: renv
  renv::install("yaml") # yaml is required to find dependencies in Rmd
  renv::hydrate() # auto-detect and install all dependencies
  renv::snapshot() # create renv.lock
}

local({
  packagesUrl <- "https://pik-piam.r-universe.dev/src/contrib/PACKAGES"
  pikPiamPackages <- sub("Package: ", "", grep("Package: ", readLines(packagesUrl), value = TRUE))

  # TODO should this be on or off by default?
  # comment out the following line to disable auto-updates
  # renv::update(intersect(utils::installed.packages()[, "Package"], pikPiamPackages))
})

# TODO is this coming last ok?
if (file.exists("~/.Rprofile")) {
  source("~/.Rprofile")
}
