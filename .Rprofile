source("renv/activate.R")

# bootstrapping, will only run once after remind is freshly cloned
if (nrow(installed.packages(priority = "NA")) == 1) {
  # only one package is installed, presumably renv
  renv::install("yaml") # yaml is required to find dependencies in Rmd
  renv::hydrate() # auto-detect and install all dependencies
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
