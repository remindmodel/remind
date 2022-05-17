source("renv/activate.R")

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
