# |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

.copy.fromlist <- function(filelist,destfolder) {
  if(is.null(names(filelist))) names(filelist) <- rep("",length(filelist))
  for(i in 1:length(filelist)) {
    if(!is.na(filelist[i])) {
      to <- paste0(destfolder,"/",names(filelist)[i])
      if(!file.copy(filelist[i],to=to,recursive=dir.exists(to),overwrite=T))
        cat(paste0("Could not copy ",filelist[i]," to ",to,"\n"))
    }
  }
}

submit <- function(cfg, restart = FALSE, stopOnFolderCreateError = TRUE) {
  if(!restart) {
    # Generate name of output folder and create the folder
    date <- format(Sys.time(), "_%Y-%m-%d_%H.%M.%S")
    cfg$results_folder <- gsub(":date:", date, cfg$results_folder, fixed = TRUE)
    cfg$results_folder <- gsub(":title:", cfg$title, cfg$results_folder, fixed = TRUE)
    # Create output folder
    cat("   Creating results folder",cfg$results_folder,"\n")
    if (!file.exists(cfg$results_folder)) {
      dir.create(cfg$results_folder, recursive = TRUE, showWarnings = FALSE)
    } else if (!cfg$force_replace) {
      couldnotdelete <- paste0("Results folder ",cfg$results_folder," could not be created because it already exists")
      if (stopOnFolderCreateError) {
        stop(couldnotdelete, ".")
      } else if (! all(grepl("^log*.txt", list.files(cfg$results_folder)))) {
        stop(couldnotdelete, " and it contains not only log files.")
      } else {
        message(couldnotdelete, " but it contains only log files.")
      }
    } else {
      cat("    Deleting results folder because it already exists:",cfg$results_folder,"\n")
      unlink(cfg$results_folder, recursive = TRUE)
      dir.create(cfg$results_folder, recursive = TRUE, showWarnings = FALSE)
    }

    if (is.null(renv::project())) {
      warning("No active renv project found, not using renv.")
    } else {
      # the following is FALSE if we are starting a subsequent run in a cascade -> renv checks/updates are skipped
      if (normalizePath(renv::project()) == normalizePath(".")) {
        if (!renv::status()$synchronized) {
          message("The new run will use the package environment defined in renv.lock, ",
                  "but it is out of sync, probably because you installed packages/updates manually. ",
                  "Write current package environment into renv.lock first? (Y/n)", appendLF = FALSE)
          if (tolower(gms::getLine()) %in% c("y", "")) {
            renv::snapshot(prompt = FALSE)
          }
        }

        if (getOption("autoRenvUpdates", TRUE)) {
          source("scripts/utils/updateRenv.R")
        } else {
          packagesUrl <- "https://pik-piam.r-universe.dev/src/contrib/PACKAGES"
          pikPackages <- sub("^Package: ", "", grep("^Package: ", readLines(packagesUrl), value = TRUE))
          installed <- utils::installed.packages()
          outdatedPackages <- utils::old.packages(instPkgs = installed[installed[, "Package"] %in% pikPackages, ])
          if (!is.null(outdatedPackages)) {
            message("The following PIK packages can be updated:\n",
                    paste("-", outdatedPackages[, "Package"], ":",
                          outdatedPackages[, "Installed"], "->", outdatedPackages[, "ReposVer"],
                          collapse = "\n"),
                    "\nConsider updating with `Rscript scripts/utils/updateRenv.R`.")
          }
        }
      }

      # renv::paths$lockfile() belongs to the run renv and not the main renv when starting subsequent runs
      file.copy(renv::paths$lockfile(), cfg$results_folder)

      # copy renv package installation itself, would require internet otherwise, cannot load renv from cache
      renvPath <- file.path(.libPaths()[[1]], "renv")
      stopifnot(`could not find renv installation` = dir.exists(renvPath))
      copyTarget <- file.path(cfg$results_folder, sub(renv::project(), "", .libPaths()[[1]]))
      dir.create(copyTarget, recursive = TRUE)
      file.copy(renvPath, copyTarget, recursive = TRUE)

      createResultsfolderRenv <- function(resultsfolder) {
        # use same snapshot.type so renv::status()$synchronized always uses the same logic
        renv::init(resultsfolder, bare = TRUE, settings = list(snapshot.type = renv::settings$snapshot.type()))
        renv::restore() # will restore using the renv.lock copied from the main renv
      }
      # init renv in a separate session so the libPaths of the current session remain unchanged
      callr::r(createResultsfolderRenv, list(cfg$results_folder), show = TRUE)
    }

    # Save the cfg (with the updated name of the result folder) into the results folder. 
    # Do not save the new name of the results folder to the .RData file in REMINDs main folder, because it 
    # might be needed to restart subsequent runs manually and should not contain the time stamp in this case.
    filename <- paste0(cfg$results_folder,"/config.Rdata")
    cat("   Writing cfg to file",filename,"\n")
    # remember main folder
    cfg$remind_folder <- normalizePath(".")
    save(cfg,file=filename)
    
    # Copy files required to configure and start a run
    filelist <- c("prepare_and_run.R" = "scripts/start/prepare_and_run.R",
                  ".Rprofile" = ".Rprofile")
    .copy.fromlist(filelist,cfg$results_folder)

    # Do not remove .RData files from REMIND main folder because they are needed in case you need to manually restart subsequent runs.
  }

  on.exit(setwd(cfg$remind_folder))
  # Change to run folder
  setwd(cfg$results_folder)
  
  # send prepare_and_run.R to cluster 
  cat("   Executing prepare_and_run.R for",cfg$results_folder,"\n")
  if (grepl("^direct", cfg$slurmConfig)) {
    log <- format(Sys.time(), paste0(cfg$title,"-%Y-%H-%M-%S-%OS3.log"))
    system("Rscript prepare_and_run.R")
  } else {
    system(paste0("sbatch --job-name=",cfg$title," --output=log.txt --mail-type=END --comment=REMIND --wrap=\"Rscript prepare_and_run.R \" ",cfg$slurmConfig))
    Sys.sleep(1)
  }
    
  return(cfg$results_folder)
}
