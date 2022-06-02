# Updates all pik-piam R packages in the current renv and updates renv.lock
local({
  # get all packages in pik-piam r-universe
  packagesUrl <- "https://pik-piam.r-universe.dev/src/contrib/PACKAGES"
  pikPiamPackages <- sub("^Package: ", "", grep("^Package: ", readLines(packagesUrl), value = TRUE))

  # update pik-piam packages only
  renv::update(intersect(utils::installed.packages()[, "Package"], pikPiamPackages), prompt = FALSE)

  # TODO archive renv.lock before overwriting
  renv::snapshot(prompt = FALSE)
  # TODO unload updated packages here?
})
