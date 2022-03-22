# source global .Rprofile (very important to load user specific settings)
# DO NOT EDIT THIS LINE!
if(file.exists("~/.Rprofile")) source("~/.Rprofile")

# This profile can be used to link the model to a specified library snapshot
# (e.g. if your model version is from an older date and does not work with the
# newest libraries anymore). By default it is not active.

# Gather all library snapshots
snapshots <- sort(list.files(
             path = '/p/projects/rd3mod/R/libraries/snapshots',
             pattern = '^20[0-9]{2}_[0-9]{2}(_[0-9]{2})?$',
             full.names = TRUE), decreasing = TRUE)
latest_snapshot <- ifelse (length(snapshots) > 0, snapshots[[1]], NA)

# Just uncomment the following line and set the snapshot path
# to a path of your choice or use the second line to use the latest snapshot.
# Please make also sure that in your config file this .Rprofile file is copied
# to the model output folder. Otherwise, the run itself will again use the
# default library set!

# snapshot <- "/p/projects/rd3mod/R/libraries/snapshots/2022_03"
# snapshot <- latest_snapshot

if(exists("snapshot") && file.exists(snapshot)) {
  message("libPaths was manually set to: ",snapshot)
  .libPaths(snapshot)
}

# Check if the library folder is currently being updated and if so use latest daily or monthly snapshot.
if (any(grepl("^00LOCK.*", list.files(.libPaths()[1])))) {
    lock_folders <- grep("^00LOCK.*", list.files(.libPaths()[1]), value=TRUE)
    bad_packages <- gsub("^00LOCK-","", lock_folders)

    # Give user diagnosis
    message("\nThe following lock folders were found at ", .libPaths()[1], ":\n  ", lock_folders)
    message("That means that the ", bad_packages, "package(s) is(are) currently being updated.")
    message("All packages will be loaded from the library's latest snapshot instead:\n  ", latest_snapshot)
    message("(If the lock folder isn't deleted automatically in the next couple of minutes, that means the package failed to update/install and that the folder has to be removed manually!)")
    message("To avoid this automatic choice, specify a snapshot in your .Rprofile instead.")

    if(file.exists(latest_snapshot)) {
        .libPaths(latest_snapshot)
    }
}
