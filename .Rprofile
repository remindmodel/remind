# source global .Rprofile (very important to load user specific settings)
# DO NOT EDIT THIS LINE!
if(file.exists("~/.Rprofile")) source("~/.Rprofile")

# Check if the library folder is currently being updated and if so use lattest snapshot.
if (any(grepl("^00LOCK.*", system(paste0("ls ", .libPaths()[1]), intern = TRUE)))) {
    cat("\nPackages in the default R library are currently being updated. Packages will be loaded from the library's lattest snapshot instead.\n")
    
    snapshot_folder <- "/p/projects/rd3mod/R/libraries/snapshots/"
    snapshot_dates <- system(paste0("ls ", snapshot_folder), intern = TRUE)
    lattest_snapshot <- paste0(snapshot_folder, snapshot_dates[length(snapshot_dates)])

    if(file.exists(lattest_snapshot)) {
        .libPaths(lattest_snapshot)
    }
}


# This profile can be used to link the model to a specified library snapshot
# (e.g. if your model version is from an older date and does not work with the
# newest libraries anymore) 
# By default it is not active. Just uncomment the following lines and set the
# snapshot path to a path of your choice
# Please make also sure that in your config file this .Rprofile file is copied
# to the model output folder. Otherwise, the run itself will again use the
# default library set!

# snapshot <- "/p/projects/rd3mod/R/libraries/snapshots/2020_03_10"
# if(file.exists(snapshot)) {
# cat("Set libPaths to",snapshot,"\n")
# .libPaths(snapshot)
# }
