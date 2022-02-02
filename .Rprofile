# source global .Rprofile (very important to load user specific settings)
# DO NOT EDIT THIS LINE!
if(file.exists("~/.Rprofile")) source("~/.Rprofile")

# Check if the library folder is currently being updated and if so use lattest monthly snapshot.
if (any(grepl("^00LOCK.*", list.files(.libPaths()[1])))) {
    lock_folders <- grep("^00LOCK.*", list.files(.libPaths()[1]), value=TRUE)
    bad_pacakges <- gsub("^00LOCK-","", lock_folders)

    latest_monthly_snapshot <- tail(
        sort(list.files(
            path = '/p/projects/rd3mod/R/libraries/snapshots', 
            pattern = '^20[0-9]{2}_[0-9]{2}(_[0-9]{2})?$',
            full.names = TRUE)), 
    n = 1)

    # Give user diagnosis
    cat("\nThe following lock folders were found at", .libPaths()[1],":\n\t", lock_folders,"\n")
    cat("That means that the ",bad_pacakges,"package(s) is(are) currently being updated.\n") 
    cat("Packages will be loaded from the library's lattest snapshot instead:\n",lattest_monthly_snapshot,"\n")
    cat("(If the lock folder isn't deleted automatically in the next couple of minutes, that means the package failed to update/install and that the folder has to be removed manually!)\n")
    
    if(file.exists(lattest_monthly_snapshot)) {
        .libPaths(lattest_monthly_snapshot)
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
