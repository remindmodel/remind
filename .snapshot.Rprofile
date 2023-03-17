# This profile can be used to link the model to a specified library snapshot
# (e.g. if your model version is from an older date and does not work with the
# newest libraries anymore). By default it is not active.

local({ # prevent variables defined here from ending up in the global env

# Set the snapshot path to a path of your choice.
# Snapshots must be compatible to the R version used. If you are using R 4.1
# make sure the selected snapshot's name ends with '_R4'.

snapshot <- "/p/projects/rd3mod/R/libraries/snapshots/2022_12_15_R4"

activateSnapshot <- function(snapshot) {
  stopifnot(file.exists(snapshot))
  if (R.version$major <= 3) { # include.site is not available before R 4.0
    if (endsWith(snapshot, "_R4")) stop("Your R version is ", R.version$major, ", but your library snapshot is for 4.0 or later")
    .libPaths(snapshot)
  } else {
    if (!endsWith(snapshot, "_R4")) stop("Your R version is ", R.version$major, ", but your library snapshot is for < 4.0.")
    # setting include.site to FALSE makes sure that only the snapshot and system libraries are used
    .libPaths(snapshot, include.site = FALSE)
  }
  message("libPaths was set to: ", snapshot)
}

activateSnapshot(snapshot)

})
