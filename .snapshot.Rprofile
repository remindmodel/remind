# This profile can be used to link the model to a specified library snapshot
# (e.g. if your model version is from an older date and does not work with the
# newest libraries anymore). By default it is not active.

local({ # prevent variables defined here from ending up in the global env

# snapshots created with R 4.1 have a _R4 postfix
maybeR4 <- if (R.version$major == 4) "_R4" else ""
# Gather all library snapshots
snapshots <- sort(list.files(path = '/p/projects/rd3mod/R/libraries/snapshots',
                             pattern = paste0('^20[0-9]{2}_[0-9]{2}(_[0-9]{2})?', maybeR4, '$'),
                             full.names = TRUE), decreasing = TRUE)
latestSnapshot <- if (length(snapshots) > 0) snapshots[[1]] else NA

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

# Just uncomment the following line and set the snapshot path
# to a path of your choice or use the second line to use the latest snapshot.
# Please make also sure that in your config file this .Rprofile file is copied
# to the model output folder. Otherwise, the run itself will again use the
# default library set!
# Snapshots must be compatible to the R version used. If you are using R 4.1
# make sure the selected snapshot's name ends with '_R4'.

# snapshot <- "/p/projects/rd3mod/R/libraries/snapshots/2022_05_31_R4"
# snapshot <- latestSnapshot

if (exists("snapshot")) {
  activateSnapshot(snapshot)
}

# Check if the library folder is currently being updated and if so use latest daily or monthly snapshot.
if (any(grepl("^00LOCK.*", list.files(.libPaths())))) {
  lockFolders <- grep("^00LOCK.*", list.files(.libPaths()), value = TRUE)
  badPackages <- gsub("^00LOCK-", "", lockFolders)

  # Give user diagnosis
  message("\nThe following lock folders were found in your libPaths:\n  ", lockFolders)
  message("That means that the ", badPackages, " package(s) is(are) currently being updated.")
  message("All packages will be loaded from the library's latest snapshot instead:\n  ", latestSnapshot)
  message("(If the lock folder isn't deleted automatically in the next couple of minutes, ",
          "that means the package failed to update/install and that the folder has to be removed manually!)")
  message("To avoid this automatic choice, specify a snapshot in your .Rprofile instead.")

  activateSnapshot(latestSnapshot)
}

})
