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
require(stringr)

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

choose_slurmConfig_output <- function(slurmExceptions = NULL) {
  slurm_options <- c("--qos=priority", "--qos=short", "--qos=standby",
                     "--qos=priority --mem=8000", "--qos=short --mem=8000",
                     "--qos=standby --mem=8000", "--qos=priority --mem=32000", "direct")
  if (!is.null(slurmExceptions)) {
    slurm_options <- unique(c(grep(slurmExceptions, slurm_options, value = TRUE), "direct"))
  }
  if (length(slurm_options) == 1) return(slurm_options[[1]])
  identifier <- chooseFromList(gsub("qos=", "", gsub("--", "", slurm_options)),
         multiple = FALSE, returnBoolean = TRUE, type = "slurm mode", userinfo = "Uses the first option if empty.")
  return(if (any(identifier)) slurm_options[as.numeric(which(identifier))] else slurm_options[1])
}

choose_filename_prefix <- function(modules, title = "") {
  cat(paste0("\n\n ", title, "Please choose a prefix for filenames of ", paste(modules, collapse=", "), ".\n"))
  cat(" For example compareScenarios2 uses it for the filenames: compScen-yourprefix-2022-….pdf.\n Use only A-Za-z0-9_-, or leave empty:\n\n")
  filename_prefix <- getLine()
  if(grepl("[^A-Za-z0-9_-]", filename_prefix)) {
    filename_prefix <- choose_filename_prefix(modules, title = paste("No, this contained special characters, try again.\n",title))
  }
  return(filename_prefix)
}

if (exists("source_include")) {
  comp <- "single"
} else if (! exists("comp")) {
  modes <- c("single" = "Output for single run", "comparison" = "Comparison across runs", "export" = "Export", "exit" = "Exit")
  comp <- names(modes)[which(chooseFromList(unname(modes), type = "output mode", multiple = FALSE, returnBoolean = TRUE))]
  if (comp == "exit") q()
}
if (isFALSE(comp)) comp <- "single" # legacy from times only two comp modes existed
if (isTRUE(comp)) comp <- "comparison"

if (! exists("output")) {
  modules <- gsub("\\.R$", "", grep("\\.R$", list.files(paste0("./scripts/output/", if (isFALSE(comp)) "single" else comp)), value = TRUE))
  output <- chooseFromList(modules, type = "modules to be used for output generation", addAllPattern = FALSE)
}

# Select output directories if not defined by readArgs
if (! exists("outputdir")) {
  if ("policyCosts" %in% output) {
    message("\nFor policyCosts, specify policy runs and reference runs alternatingly:")
    message("3,1,4,1 compares runs 3 and 4 with 1.")
  }
  dir_folder <- if (exists("remind_dir")) remind_dir else "./output"
  dirs <- basename(dirname(Sys.glob(file.path(dir_folder, "*", "fulldata.gdx"))))
  names(dirs) <- stringr::str_extract(dirs, "rem-[0-9]+$")
  names(dirs)[is.na(names(dirs))] <- ""
  selectedDirs <- chooseFromList(dirs, type = "runs to be used for output generation", returnBoolean = FALSE,
                                    multiple = TRUE)
  outputdirs <- file.path("output", selectedDirs)
  if (exists("remind_dir")) {
    for (i in seq_along(selectedDirs)) {
      last_iteration <-
        max(as.numeric(sub("magpie_", "", grep("magpie_",
                                               list.dirs(file.path(remind_dir, selectedDirs[i], "data", "results")),
                                               value = TRUE))))
      outputdirs[i] <- file.path(remind_dir, selectedDirs[i], "data", "results", paste0("magpie_", last_iteration))
    }
  }
} else {
  outputdirs <- outputdir
}

if (comp %in% c("comparison", "export")) {
  # ask for filename_prefix, if one of the modules that use it is selected
  modules_using_filename_prefix <- c("compareScenarios2", "xlsx_IIASA")
  if (!exists("filename_prefix")) {
    if (any(modules_using_filename_prefix %in% output)) {
      filename_prefix <- choose_filename_prefix(modules = intersect(modules_using_filename_prefix, output))
    } else {
      filename_prefix <- ""
    }
  }

  # choose the slurm options. If you use command line arguments, use slurmConfig=priority or standby
  modules_using_slurmConfig <- c("compareScenarios2")
  if (!exists("slurmConfig") && any(modules_using_slurmConfig %in% output)) {
    slurmConfig <- choose_slurmConfig_output()
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
    if (file.exists(paste0("scripts/output/", comp, "/", name))) {
      print(paste("Executing", name))
      tmp.env <- new.env()
      tmp.error <- try(sys.source(paste0("scripts/output/", comp, "/", name), envir = tmp.env))
      rm(tmp.env)
      gc()
      if (!is.null(tmp.error)) {
        warning("Script ", name, " was stopped by an error and not executed properly!")
      }
    }
  }
} else { # comp = single
  # define slurm class or direct execution
  outputUsingDirect <- c("plotIterations")
  if (! exists("source_include")) {
    # for selected output scripts, only slurm configurations matching these regex are available
    slurmExceptions <- if ("reporting" %in% output) "--mem=[0-9]*[0-9]{3}" else NULL
    if (all(output %in% outputUsingDirect)) slurmConfig <- "direct"
    # if this script is not being sourced by another script but called from the command line via Rscript let the user
    # choose the slurm options
    if (!exists("slurmConfig")) {
      slurmConfig <- choose_slurmConfig_output(slurmExceptions = slurmExceptions)
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

    ###################################################################################
    # Execute R scripts
    ###################################################################################

    # output creation for --testOneRegi was switched off in start.R in this commit: https://github.com/remindmodel/remind/commit/5905d9dd814b4e4a62738d282bf1815e6029c965
    if (all(is.na(output))) {
      message("\nNo output generation, as output was set to NA, as for example for --testOneRegi or --quick.")
    } else {
      message("\nStarting output generation for ", outputdir, "\n")
      for (rout in output) {
        name <- paste(rout, ".R", sep = "")
        if (file.exists(paste0("scripts/output/single/", name))) {
          if (slurmConfig == "direct" | rout %in% outputUsingDirect) {
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
