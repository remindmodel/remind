#!/usr/bin/env Rscript
# |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
##########################################################
#### REMIND Output Generation ####
##########################################################
# Version 1.0
# Type "Rscript output.R" to start the script in the command line

# Based on the Version 2.2 of same file in the MAgPIE main folder
#########################################################################################

# Write dump file when error occurs, see help to dump.frames for more information
options(error = quote({
  dump.frames(to.file = TRUE)
  traceback()
  q()
}))

# load landuse library
library(lucode2)
library(gms)

### Define arguments that can be read from command line
if (!exists("source_include")) {
  # if this script is not being sourced by another script but called from the command line via Rscript read the command
  # line arguments and let the user choose the slurm options
  readArgs("outputdir", "output", "comp", "remind_dir", "slurmConfig", "filename_prefix")
}

# Setting relevant paths
if (file.exists("/iplex/01/landuse")) { # run is performed on the cluster
  pythonpath <- "/iplex/01/landuse/bin/python/bin/"
  latexpath <- "/iplex/01/sys/applications/texlive/bin/x86_64-linux/"
} else {
  pythonpath <- ""
  latexpath <- NA
}

get_line <- function() {
  # gets characters (line) from the terminal of from a connection
  # and stores it in the return object
  if (interactive()) {
    s <- readline()
  } else {
    con <- file("stdin")
    s <- readLines(con, 1, warn = FALSE)
    on.exit(close(con))
  }
  return(s)
}

choose_folder <- function(folder, title = "Please choose a folder") {
  dirs <- NULL

  # Detect all output folders containing fulldata.gdx
  # For coupled runs please use the outcommented text block below

  dirs <- basename(dirname(Sys.glob(file.path(folder, "*", "fulldata.gdx"))))

  # DK: The following outcommented lines are specially made for listing results of coupled runs
  # runs <- findCoupledruns(folder)
  # dirs <- findIterations(runs,modelpath=folder,latest=TRUE)
  # dirs <- sub("./output/","",dirs)

  dirs <- c("all", dirs)
  cat("\n\n", title, ":\n\n")
  cat(paste(seq_along(dirs), dirs, sep = ": "), sep = "\n")
  cat(paste(length(dirs) + 1, "Search by the pattern.\n", sep = ": "))
  cat("\nNumber: ")
  identifier <- get_line()
  identifier <- strsplit(identifier, ",")[[1]]
  tmp <- NULL
  for (i in seq_along(identifier)) {
    if (length(strsplit(identifier, ":")[[i]]) > 1) {
      tmp <- c(tmp, as.numeric(strsplit(identifier, ":")[[i]])[1]:as.numeric(strsplit(identifier, ":")[[i]])[2])
    } else {
      tmp <- c(tmp, as.numeric(identifier[i]))
    }
  }
  identifier <- tmp
  # PATTERN
  if (length(identifier) == 1 && identifier == (length(dirs) + 1)) {
    cat("\nInsert the search pattern or the regular expression: ")
    pattern <- get_line()
    id <- grep(pattern = pattern, dirs[-1])
    # lists all chosen directories and ask for the confirmation of the made choice
    cat("\n\nYou have chosen the following directories:\n")
    cat(paste(seq_along(id), dirs[id + 1], sep = ": "), sep = "\n")
    cat("\nAre you sure these are the right directories?(y/n): ")
    answer <- get_line()
    if (answer == "y") {
      return(dirs[id + 1])
    } else {
      choose_folder(folder, title)
    }
  } else if (any(dirs[identifier] == "all")) {
    identifier <- 2:length(dirs)
    return(dirs[identifier])
  } else {
    return(dirs[identifier])
  }
}


choose_module <- function(Rfolder, title = "Please choose an outputmodule") {
  module <- gsub("\\.R$", "", grep("\\.R$", list.files(Rfolder), value = TRUE))
  cat("\n\n", title, ":\n\n")
  cat(paste(seq_along(module), module, sep = ": "), sep = "\n")
  cat("\nNumber: ")
  identifier <- get_line()
  identifier <- as.numeric(strsplit(identifier, ",")[[1]])
  if (any(!(identifier %in% seq_along(module)))) {
    stop("This choice (", identifier, ") is not possible. Please type in a number between 1 and ", length(module))
  }
  return(module[identifier])
}

choose_mode <- function(title = "Please choose the output mode") {
  modes <- c("Output for single run ", "Comparison across runs", "Exit")
  cat("\n\n", title, ":\n\n")
  cat(paste(seq_along(modes), modes, sep = ": "), sep = "\n")
  cat("\nNumber: ")
  identifier <- get_line()
  identifier <- as.numeric(strsplit(identifier, ",")[[1]])
  if (identifier == 1) {
    comp <- FALSE
  } else if (identifier == 2) {
    comp <- TRUE
  } else if (identifier == 3) {
    comp <- "Exit"
  } else {
    stop("This mode is invalid. Please choose a valid mode.")
  }
  return(comp)
}

choose_slurmConfig_priority_standby <- function(title = "Please enter the slurm mode, uses the first option if empty",
                                                slurmExceptions = NULL) {
  slurm_options <- c("--qos=priority", "--qos=short", "--qos=standby",
                     "--qos=priority --mem=8000", "--qos=short --mem=8000",
                     "--qos=standby --mem=8000", "--qos=priority --mem=32000", "direct")
  if (!is.null(slurmExceptions)) {
    slurm_options <- unique(c(grep(slurmExceptions, slurm_options, value = TRUE), "direct"))
  }
  if (length(slurm_options) == 1) return(slurm_options[[1]])
  cat("\n\n", title, ":\n\n")
  cat(paste(seq_along(slurm_options), gsub("qos=", "", gsub("--", "", slurm_options)), sep = ": "), sep = "\n")
  cat("\nNumber: ")
  identifier <- get_line()
  if (identifier == "") {
    identifier <- 1
  }
  if (!identifier %in% seq(length(slurm_options))) {
    return(choose_slurmConfig_priority_standby(title= "This slurm mode is invalid. Please choose a valid mode"))
  }
  return(slurm_options[as.numeric(identifier)])
}

choose_filename_prefix <- function(modules, title = "") {
  cat(paste0("\n\n ", title, "Please choose a prefix for filenames of ", paste(modules, collapse=", "), ".\n"))
  cat(" For example compareScenarios uses it for the filenames: compScen-yourprefix-2022-….pdf.\n Use only A-Za-z0-9_-, or leave empty:\n\n")
  filename_prefix <- get_line()
  if(grepl("[^A-Za-z0-9_-]", filename_prefix)) {
    filename_prefix <- choose_filename_prefix(modules, title = paste("No, this contained special characters, try again.\n",title))
  }
  return(filename_prefix)
}

if (exists("source_include")) {
  comp <- FALSE
} else if (!exists("comp")) {
  comp <- choose_mode("Please choose the output mode")
}

if (comp == "Exit") {
  q()
} else if (comp == TRUE) {
  print("comparison")
  # Select output modules if not defined by readArgs
  if (!exists("output")) {
    output <- choose_module("./scripts/output/comparison",
                            "Please choose the output module to be used for output generation")
  }
  # Select output directories if not defined by readArgs
  if (!exists("outputdir")) {
    if ("policyCosts" %in% output) {
      message("\nFor policyCosts, specify policy runs and reference runs alternatingly:")
      message("3,1,4,1 compares runs 3 and 4 with 1.")
    }
    if (!exists("remind_dir")) {
      temp <- choose_folder("./output", "Please choose the runs to be used for output generation")
      outputdirs <- temp
      for (i in seq_along(temp)) {
        outputdirs[i] <- file.path("output", temp[i])
      }
    } else {
      temp <- choose_folder(remind_dir, "Please choose the runs to be used for output generation, separate with comma")
      outputdirs <- temp
      for (i in seq_along(temp)) {
        last_iteration <-
          max(as.numeric(sub("magpie_", "", grep("magpie_",
                                                 list.dirs(file.path(remind_dir, temp[i], "data", "results")),
                                                 value = TRUE))))
        outputdirs[i] <- file.path(remind_dir, temp[i], "data", "results", paste0("magpie_", last_iteration))
      }
    }
  } else {
    outputdirs <- outputdir
  }

  # ask for filename_prefix, if one of the modules that use it is selected
  modules_using_filename_prefix <- c("compareScenarios", "compareScenarios2")
  if (!exists("filename_prefix")) {
    if (any(modules_using_filename_prefix %in% output)) {
      filename_prefix <- choose_filename_prefix(modules = intersect(modules_using_filename_prefix, output))
    } else {
      filename_prefix <- ""
    }
  }

  # choose the slurm options. If you use command line arguments, use slurmConfig=priority or standby
  modules_using_slurmConfig <- c("compareScenarios", "compareScenarios2")
  if (!exists("slurmConfig") && any(modules_using_slurmConfig %in% output)) {
    slurmConfig <- choose_slurmConfig_priority_standby()
  }
  if (exists("slurmConfig")) {
    if (slurmConfig %in% c("priority", "short", "standby")) {
      slurmConfig <- paste0("--qos=", slurmConfig)
    }
  }

  # Set value source_include so that loaded scripts know, that they are
  # included as source (instead of a load from command line)
  source_include <- TRUE

  # Execute output scripts over all chosen folders
  for (rout in output) {
    name <- paste(rout, ".R", sep = "")
    if (file.exists(paste("scripts/output/comparison/", name, sep = ""))) {
      print(paste("Executing", name))
      tmp.env <- new.env()
      tmp.error <- try(sys.source(paste("scripts/output/comparison/", name, sep = ""), envir = tmp.env))
      rm(tmp.env)
      gc()
      if (!is.null(tmp.error)) {
        warning("Script ", name, " was stopped by an error and not executed properly!")
      }
    }
  }
} else {
  # Select an output module if not defined by readArgs
  if (!exists("output")) {
    output <- choose_module("./scripts/output/single",
                            "Please choose the output module to be used for output generation")
  }

  # Select an output directory if not defined by readArgs
  if (!exists("outputdir")) {
    if (!exists("remind_dir")) {
      temp <- choose_folder("./output", "Please choose the run(s) to be used for output generation")
      outputdirs <- temp
      for (i in seq_along(temp)) {
        outputdirs[i] <- file.path("output", temp[i])
      }
    } else {
      temp <- choose_folder(remind_dir, "Please choose the runs to be used for output generation")
      outputdirs <- temp
      for (i in seq_along(temp)) {
        last_iteration <-
          max(as.numeric(sub("magpie_", "", grep("magpie_",
                                                 list.dirs(file.path(remind_dir, temp[i], "data", "results")),
                                                 value = TRUE))))
        outputdirs[i] <- file.path(remind_dir, temp[i], "data", "results", paste0("magpie_", last_iteration))
      }
    }
  } else {
    outputdirs <- outputdir
  }

  # define slurm class or direct execution
  if (! exists("source_include")) {
    # for selected output scripts, only slurm configurations matching these regex are available
    slurmExceptions <- switch(output,
      reporting      = "--mem=[0-9]*[0-9]{3}",
      plotIterations = "^direct",
      NULL
    )
    # if this script is not being sourced by another script but called from the command line via Rscript let the user
    # choose the slurm options
    if (!exists("slurmConfig")) {
      slurmConfig <- choose_slurmConfig_priority_standby(slurmExceptions = slurmExceptions)
      if (slurmConfig != "direct") slurmConfig <- paste(slurmConfig, "--nodes=1 --tasks-per-node=1")
    }
    if (slurmConfig %in% c("priority", "short", "standby")) {
      slurmConfig <- paste0("--qos=", slurmConfig, " --nodes=1 --tasks-per-node=1")
    }
  } else {
    # if being sourced by another script execute the output scripts directly without sending them to the cluster
    slurmConfig <- "direct"
  }

  # Execute outputscripts for all choosen folders
  for (outputdir in outputdirs) {

    if (exists("cfg")) {
      title <- cfg$title
      gms <- cfg$gms
      revision <- cfg$inputRevision
      magpie_folder <- cfg$magpie_folder
    }

    # Get values of config if output.R is called standalone
    if (!exists("source_include")) {
      magpie_folder <- getwd()
      message("Load data from ", file.path(outputdir, "config.Rdata"))
      if (file.exists(file.path(outputdir, "config.Rdata"))) {
        load(file.path(outputdir, "config.Rdata"))
        title <- cfg$title
        gms <- cfg$gms
        revision <- cfg$inputRevision
      } else {
        config <- grep("\\.cfg$", list.files(outputdir), value = TRUE)
        l <- readLines(file.path(outputdir, config))
        title <- strsplit(grep("(cfg\\$|)title +<-", l, value = TRUE), "\"")[[1]][2]
        gms <- list()
        gms$scenarios <- strsplit(grep("(cfg\\$|)gms\\$scenarios +<-", l, value = TRUE), "\"")[[1]][2]
        revision <- as.numeric(unlist(strsplit(grep("(cfg\\$|)inputRevision +<-", l, value = TRUE), "<-[ \t]*"))[2])
      }
    }

    # Set value source_include so that loaded scripts know, that they are
    # included as source (instead of a load from command line)
    source_include <- TRUE

    message("\nStarting output generation for ", outputdir, "\n")

    ###################################################################################
    # Execute R scripts
    ###################################################################################

    # output creation for --testOneRegi was switched off in start.R in this commit: https://github.com/remindmodel/remind/commit/5905d9dd814b4e4a62738d282bf1815e6029c965
    if (all(is.na(output))) {
      message("No output generation, as output was set to NA, as for example for --testOneRegi.")
    } else {
      for (rout in output) {
        name <- paste(rout, ".R", sep = "")
        if (file.exists(paste0("scripts/output/single/", name))) {
          if (slurmConfig == "direct") {
            # execute output script directly (without sending it to slurm)
            message("Executing ", name)
            tmp.env <- new.env()
            tmp.error <- try(sys.source(paste0("scripts/output/single/", name), envir = tmp.env))
            #        rm(list=ls(tmp.env),envir=tmp.env)
            rm(tmp.env)
            gc()
            if (!is.null(tmp.error)) {
              warning("Script ", name, " was stopped by an error and not executed properly!")
            }
          } else {
            # send the output script to slurm
            logfile <- paste0(outputdir, "/log_", rout, ".txt")
            slurmcmd <- paste0("sbatch ", slurmConfig, " --job-name=", logfile, " --output=", logfile,
                               " --mail-type=END --comment=REMIND --wrap=\"Rscript scripts/output/single/", rout,
                               ".R  outputdir=", outputdir, "\"")
            message("Sending to slurm: ", name, ". Find log in ", logfile)
            system(slurmcmd)
            Sys.sleep(1)
          }
        }
      }
      # finished
      message("\nFinished ", ifelse(slurmConfig == "direct", "", "starting jobs for "), "output generation for ", outputdir, "!\n")
    }

    rm(source_include)
    if (!is.null(warnings())) {
      print(warnings())
    }
  }
}
