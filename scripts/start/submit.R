# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
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
    if (!file.exists(cfg$results_folder)) {
      message("   Creating results folder ", cfg$results_folder)
      dir.create(cfg$results_folder, recursive = TRUE, showWarnings = FALSE)
    } else if (!cfg$force_replace) {
      couldnotdelete <- paste0("Results folder ",cfg$results_folder," already exists")
      if (stopOnFolderCreateError) {
        stop(couldnotdelete, ".")
      } else if (! all(grepl("^log*.txt", list.files(cfg$results_folder)))) {
        message(couldnotdelete, " and it contains not only log files. ",
                "Probably the slurm job was aborted and restarted.")
      } else {
        message(couldnotdelete, " containing only log files as expected for coupled runs.")
      }
    } else {
      message("    Results folder already exists, deleting and re-creating it: ",cfg$results_folder,"\n")
      unlink(cfg$results_folder, recursive = TRUE)
      dir.create(cfg$results_folder, recursive = TRUE, showWarnings = FALSE)
    }

    if (is.null(renv::project())) {
      warning("No active renv project found, not using renv.")
    } else {
      # we only want to run renv checks/updates in the first run in a cascade:
      # cfg$renvLockFromPrecedingRun is only NULL for the first run in a cascade.
      # For a subsequent run it has been set by the parent run in run.R (standalone) or start_coupled.R (coupled).
      firstRunInCascade <- is.null(cfg$renvLockFromPrecedingRun)
      if (firstRunInCascade) {
        if (getOption("autoRenvUpdates", FALSE)) {
          installedUpdates <- piamenv::updateRenv()
          piamenv::stopIfLoaded(names(installedUpdates))
        } else if (   'TRUE' != Sys.getenv('ignoreRenvUpdates')
                   && !is.null(piamenv::showUpdates())) {
          message("Consider updating with `make update-renv`.")
        }

        message("   Generating lockfile '", file.path(cfg$results_folder, "renv.lock"), "'... ", appendLF = FALSE)
        # suppress output of renv::snapshot
        utils::capture.output({
          errorMessage <- utils::capture.output({
            snapshotSuccess <- tryCatch({
              # snapshot current main renv into run folder
              renv::snapshot(lockfile = file.path(cfg$results_folder, "_renv.lock"), prompt = FALSE)
              TRUE
            }, error = function(error) FALSE)
          }, type = "message")
        })
        if (!snapshotSuccess) {
          stop(paste(errorMessage, collapse = "\n"))
        }
        message("done.")
      } else {
        # a run renv is loaded, we are presumably starting new run in a cascade
        message("   Copying lockfile '",cfg$renvLockFromPrecedingRun,"' into '", cfg$results_folder, "'")
        file.copy(cfg$renvLockFromPrecedingRun, file.path(cfg$results_folder, "_renv.lock"))
      }


      renvLogPath <- file.path(cfg$results_folder, "log_renv.txt")
      message("   Initializing renv, see ", renvLogPath)
      createResultsfolderRenv <- function() {
        renv::init() # will overwrite renv.lock if existing...
        file.rename("_renv.lock", "renv.lock") # so we need this rename
        renv::restore(prompt = FALSE)
      }

      # init renv in a separate session so the libPaths of the current session remain unchanged
      callr::r(createResultsfolderRenv,
               wd = cfg$results_folder,
               env = c(RENV_PATHS_LIBRARY = "renv/library"),
               stdout = renvLogPath, stderr = "2>&1")
    }

    # Save the cfg (with the updated name of the result folder) into the results folder.
    # Do not save the new name of the results folder to the .RData file in REMINDs main folder, because it
    # might be needed to restart subsequent runs manually and should not contain the time stamp in this case.
    filename <- file.path(cfg$results_folder, "config.Rdata")
    cat("   Writing cfg to file", filename, "\n")
    # remember main folder
    cfg$remind_folder <- normalizePath(".")
    save(cfg, file = filename)

    # Copy files required to configure and start a run
    filelist <- c("prepareAndRun.R" = "scripts/start/prepareAndRun.R",
                  ".Rprofile" = ".Rprofile")
    .copy.fromlist(filelist,cfg$results_folder)

    # Do not remove .RData files from REMIND main folder because they are needed in case you need to manually restart subsequent runs.
  }

  on.exit(setwd(cfg$remind_folder))
  # Change to run folder
  setwd(cfg$results_folder)

  # send prepareAndRun.R to cluster
  cat("   Executing prepareAndRun for",cfg$results_folder,"\n")
  if (grepl("^direct", cfg$slurmConfig) || ! isSlurmAvailable()) {
    exitCode <- system("Rscript prepareAndRun.R")
  } else {
    exitCode <- system(paste0("sbatch --job-name=",
                              cfg$title,
                              " --output=log.txt --open-mode=append", # append for requeued jobs
                              " --mail-type=END,FAIL",
                              " --comment=REMIND",
                              " --wrap=\"Rscript prepareAndRun.R \" ",
                              cfg$slurmConfig))
    Sys.sleep(1)
  }
  if (0 < exitCode) {
    stop("Executing prepareAndRun failed, stopping.")
  }

  return(cfg$results_folder)
}
