#!/usr/bin/env Rscript
# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
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

# preliminary option parsing to avoid loading any libraries that cause trouble with renv
argv <- get0("argv", ifnotfound = commandArgs(trailingOnly = TRUE))
# run updates before loading any packages
if ("--update" %in% argv) {
  stopifnot(`--update must not be used together with --renv=...` = !any(startsWith(argv, "--renv=")))
  installedUpdates <- piamenv::updateRenv()
  piamenv::stopIfLoaded(names(installedUpdates))
} else if (any(startsWith(argv, "--renv="))) {
  renvProject <- normalizePath(sub("^--renv=", "", grep("^--renv=", argv, value = TRUE)))
  renv::load(renvProject)
}

library(optparse)
library(lucode2)
library(gms)
require(stringr, quietly = TRUE)

# Import all functions from the scripts/start folder
invisible(sapply(list.files("scripts/start", pattern = "\\.R$", full.names = TRUE), source))

# parse options from command line and return them as a named list
parseOptions <- function() {
  options <- list(
    make_option(c("-t", "--test"),
      action = "store_true", default = FALSE,
      help = "test output.R without actually starting any run"
    ),
    make_option("--update",
      action = "store_true", default = FALSE,
      help = "update packages in renv first, incompatible with --renv"
    ),
    make_option("--comp",
      type = "character", default = NULL,
      help = "specify output type: 'single' for single runs (e.g. reporting), 'comparison' for run comparisons (e.g. compareScenarios2), or 'export' to export runs (e.g. xlsx_IIASA)"
    ),
    make_option("--filename_prefix",
      type = "character", default = NULL,
      help = "string to be added to filenames by some output scripts (compareScenarios, xlsx_IIASA)"
    ),
    make_option("--output",
      type = "character", default = NULL,
      help = "directly select a specific script (without .R extension)"
    ),
    make_option("--outputdirs",
      type = "character", default = NULL,
      help = "directly specify output directories as comma-separated list (e.g. ./output/SSP2-Base-rem-1,./output/NDC-rem-1)"
    ),
    make_option("--aliases",
      type = "character", default = NULL,
      help = "Specify aliases for the runs given in outputdirs as a comma-separated list (e.g. aliases=default,modified)"
    ),
    make_option("--remind_dir",
      type = "character", default = NULL,
      help = "path to remind or output directories where runs can be found. Defaults to ./output. Can specify multiple comma-separated folders (e.g. .,../otherremind)"
    ),
    make_option("--renv",
      type = "character", default = NULL,
      help = "load the renv located at <path>, incompatible with --update"
    ),
    make_option("--slurmConfig",
      type = "character", default = NULL,
      help = "specify SLURM selection: use 'priority', 'short', or 'standby', or pass multiple SLURM arguments (e.g. '--qos=priority --mem=8000')"
    )
  )
  parser <- OptionParser(
    usage = "Rscript output.R [options prefixed by --, e.g. --comp=single]", option_list = options,
    description = "[options] can be the following flags and variables. If variables are not specified but needed, the scripts will ask the user."
  )
  # these flags appear in the various output scripts and are necessary here
  # if you add a command line argument to a script, add it here as well
  additionalScriptOptions = list("profileNames", "runs", "folder", "project", "sections",
    "outputFilename", "model", "mapping", "summationFile", "logFile", "removeFromScen",
    "addToScen", "iiasatemplate", "timesteps", "validationConfig", "interactive")
  for (option in additionalScriptOptions) {
    parser <- add_option(parser, paste0("--", option), help="This option is used in an output script, see your script for information.")
  }

  return(parse_args(parser))
}

chooseSlurmConfigOutput <- function(output) {
  slurm_options <- c("--qos=priority", "--qos=short", "--qos=standby",
                     "--qos=priority --mem=8000", "--qos=short --mem=8000",
                     "--qos=standby --mem=8000", "--qos=priority --mem=32000")

  if (!isSlurmAvailable())
    return("direct")

  # Modify slurm options for reporting options that run in parallel (MAGICC) or need more memory
  if ("MAGICC7_AR6" %in% output) {
    slurm_options <- paste(slurm_options[1:3], "--tasks-per-node=12 --mem=32000")
  } else if ("nashConvergenceReport" %in% output) {
    slurm_options <- paste(slurm_options[1:3], "--mem=32000")
  } else if ("reporting" %in% output) {
    slurm_options <- grep("--mem=[0-9]*[0-9]{3}", slurm_options, value = TRUE)
  } else if ("fixOnRef" %in% output && length(output) == 1) {
    slurm_options <- c("direct", slurm_options)
  }

  if (length(slurm_options) == 1) {
    return(slurm_options[[1]])
  }
  identifier <- chooseFromList(gsub("qos=", "", gsub("--", "", slurm_options)), multiple = FALSE, returnBoolean = TRUE,
                               type = "slurm mode", userinfo = "Uses the first option if empty.")
  return(if (any(identifier)) slurm_options[as.numeric(which(identifier))] else slurm_options[1])
}

chooseFilenamePrefix <- function(modules, title = "") {
  cat(paste0("\n\n ", title, "Please choose a prefix for filenames of ", paste(modules, collapse=", "), ".\n"))
  cat(" For example compareScenarios2 uses it for the filenames: compScen-yourprefix-2022-….pdf.\n Use only A-Za-z0-9_-, or leave empty:\n\n")
  filename_prefix <- gms::getLine()
  if(grepl("[^A-Za-z0-9_-]", filename_prefix)) {
    filename_prefix <- chooseFilenamePrefix(modules, title = paste("No, this contained special characters, try again.\n",title))
  }
  return(filename_prefix)
}

promptForAliases <- function(outputdirs, scenarios) {
  message("\nSuggested names to be used in the output (e.g. PDF files):")
  for (i in seq_along(outputdirs)) {
    message(sprintf("  [%d] %s -> \"%s\"", i, basename(outputdirs[i]), scenarios[i]))
  }
  message("\nIf you want to change these, please choose unique names")
  message("Names separated by , or leave empty to accept suggestions:")
  aliases_str <- gms::getLine()
  aliases_list <- trimws(unlist(strsplit(aliases_str, ",")))

  if (length(scenarios) > length(aliases_list) && length(aliases_list) > 0) {
    warning("Not enough aliases supplied. Only renaming first scenarios.")
  }
  for (i in seq_along(aliases_list)) {
    if (i > length(scenarios)) {
      stop("Too many aliases supplied")
    }
    scenarios[i] <- aliases_list[i]
  }
  return(scenarios)
}

chooseCompMode <- function() {
  modes <- c("single" = "Output for single run", "comparison" = "Comparison across runs", "export" = "Export", "exit" = "Exit")
  comp <- names(modes)[which(chooseFromList(unname(modes), type = "output mode", multiple = FALSE, returnBoolean = TRUE, userinfo = "Leave empty for 'single'."))]
  if (length(comp) == 0) comp <- names(modes)[[1]]
  if (comp == "exit") q()
  return(comp)
}

chooseOutputScript <- function(comp) {
  # search for R scripts in scripts/output subfolders
  modules <- gsub("\\.R$", "", grep("\\.R$", list.files(paste0("./scripts/output/", comp)), value = TRUE))
  # if more than one option exists, let user choose
  defaultoutput <- switch(comp, "single" = gms::readDefaultConfig(".")$output, "comparison" = "compareScenarios2", "export" = "xlsx_IIASA")
  userinfo <- paste("Leave empty for", paste(defaultoutput, collapse = ", "))
  output <- if (length(modules) == 1) modules else chooseFromList(modules, type = "modules to be used for output generation", addAllPattern = FALSE, userinfo = userinfo)
  if (length(output) == 0) output <- defaultoutput
  # move "reporting" to first position, if it exists
  output <- c(if ("reporting" %in% output) "reporting", output[! output %in% "reporting"])
  return(output)
}

chooseOutputDirs <- function(output, remind_dir) {
  modulesNeedingMif <- c("compareScenarios2", "xlsx_IIASA", "policyCosts", "Ariadne_output",
                         "plot_compare_iterations", "varListHtml", "fixOnRef", "MAGICC7_AR6",
                         "validateScenarios", "checkClimatePercentiles", "selectPlots",
                         "checkProjectSummations")
  needingMif <- any(modulesNeedingMif %in% output) && ! "reporting" %in% output[[1]]
  if (is.null(remind_dir)) {
    defaultcfg <- readDefaultConfig(".")
    dir_folder <- unique(c("output", dirname(defaultcfg$results_folder)))
  } else {
    dir_folder <- trimws(unlist(strsplit(remind_dir, ",")))
    dir_folder <- c(file.path(dir_folder, "output"), dir_folder)
  }
  dirs <- dirname(Sys.glob(file.path(dir_folder, "*", "fulldata.gdx")))
  if (needingMif) dirs <- intersect(dirs, unique(dirname(Sys.glob(file.path(dir_folder, "*", "REMIND_generic_*.mif")))))
  dirnames <- if (length(dir_folder) == 1) basename(dirs) else dirs
  names(dirnames) <- stringr::str_extract(dirnames, "rem-[0-9]+$")
  names(dirnames)[is.na(names(dirnames))] <- ""
  if (length(dirnames) == 0) {
    stop("No directories found containing gdx", if (needingMif) " and mif", " files. Aborting.")
  }
  selectedDirs <- chooseFromList(dirnames, type = "runs to be used for output generation",
                    userinfo = paste0(if ("policyCosts" %in% output) "The reference run will be selected separately! " else NULL,
                                      if (needingMif) "Do you miss a run? Check if .mif exists and rerun reporting. " else NULL),
                    returnBoolean = FALSE, multiple = TRUE)
  outputdirs <- if (length(dir_folder) == 1) file.path(dir_folder, selectedDirs) else selectedDirs

  if ("policyCosts" %in% output) {
    policyrun <- chooseFromList(c("--- only here to avoid that folder numbers change ---", dirnames),
                                type = "reference run to which policy run will be compared",
                                userinfo = "Select a single reference run.",
                                returnBoolean = TRUE, multiple = FALSE)
    outputdirs <- c(rbind(outputdirs, dirs[policyrun[-1]])) # generate 3,1,4,1,5,1 out of 3,4,5 and policyrun 1
  }
  return(outputdirs)
}

chooseAliases <- function(output, outputdirs) {
  modules_supporting_aliases <- c("compareScenarios2")
  if (!any(modules_supporting_aliases %in% output)) {
    return()
  }
  scenarios <- unname(lucode2::getScenNames(outputdirs))
  aliases <- make.unique(scenarios)
  # For better scripting backwards compatibility, don't prompt for aliases if output dirs were selected with command line parameters
  if (!exists("source_include")) {
    aliases = promptForAliases(outputdirs, aliases)
  }
  return(aliases)
}

# returns TRUE if any script had errors
runComparisonOrExport <- function(comp, output, outputdirs, aliases, filename_prefix, slurmConfig, test) {
  # Set value source_include so that loaded scripts know, that they are
  # included as source (instead of a load from command line)
  source_include <- TRUE
  errors <- FALSE

  # Execute output scripts over all chosen folders
  for (rout in output) {
    name <- paste(rout, ".R", sep = "")
    if (file.exists(paste0("scripts/output/", comp, "/", name))) {
      if (test) {
        message("Test mode, not executing ", paste0("scripts/output/", comp, "/", name))
      } else {
        message("\n\n## Executing ", name)
        tmp.env <- new.env()
        tmp.error <- try(sys.source(paste0("scripts/output/", comp, "/", name), envir = tmp.env))
        rm(tmp.env)
        gc()
        if (!is.null(tmp.error)) {
          warning("Script ", name, " was stopped by an error and not executed properly!")
          errors <- TRUE
        }
      }
    } else {
      message("\nCould not find ", name)
    }
  }
  return(errors)
}

# returns TRUE if any script had errors
runSingle <- function(output, outputdirs, slurmConfig, interactiveSession, test) { # comp = single
  errors <- FALSE
  # Execute outputscripts for all chosen folders
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
      rdataPath <- file.path(outputdir, "config.Rdata")
      message("Load data from ", rdataPath)
      # Old .cfg files will not be read anymore
      stopifnot(file.exists(rdataPath))
      load(rdataPath)
      title <- cfg$title
      gms <- cfg$gms
      revision <- cfg$inputRevision
    }

    # Set value source_include so that loaded scripts know, that they are
    # included as source (instead of a load from command line)
    source_include <- TRUE

    ###################################################################################
    # Execute R scripts
    ###################################################################################

    message("\nStarting output generation for ", outputdir, "\n")
    name <- paste0(output, ".R")
    scriptsfound <- file.exists(paste0("scripts/output/single/", name))
    if (any(! scriptsfound)) {
      warning("Skipping output scripts not found in scripts/output/single: ", name[! scriptsfound])
    }
    if (test) {
      message("Test mode, not executing scripts/output/single/", paste(name, collapse = ", "))
      next
    }
    if (slurmConfig == "direct") {
      # execute output script directly (without sending it to slurm)
      for (n in name[scriptsfound]) {
        message("Executing ", n)
        tmp.env <- new.env()
        tmp.error <- try(sys.source(paste0("scripts/output/single/", n), envir = tmp.env))
        #        rm(list=ls(tmp.env),envir=tmp.env)
        rm(tmp.env)
        gc()
        if (!is.null(tmp.error)) {
          warning("Script ", n, " was stopped by an error and not executed properly!")
          errors <- TRUE
        }
      }
    } else {
      # send the output script to slurm
      timestamp <- format(Sys.time(), "%Y-%m-%d_%H.%M.%S")
      logfile <- file.path(outputdir, paste0("log_output_", timestamp, ".txt"))
      Rscripts <- paste0("Rscript scripts/output/single/", name, " --outputdir=", outputdir, collapse = "; ")
      slurmcmd <- paste0("sbatch ", slurmConfig, " --job-name=", logfile, " --output=", logfile,
                    " --mail-type=END,FAIL --comment=output.R --wrap='", Rscripts, "'")
      message("Sending to slurm: ", paste(name, collapse = ", "), ". Find log in ", logfile)
      system(slurmcmd)
    }
    message("\nFinished ", ifelse(slurmConfig == "direct", "", "starting job for "), "output generation for ", outputdir, "!\n")

    rm(source_include)
    if (!is.null(warnings())) {
      print(warnings())
    }
  }
  return(errors)
}

#' main function of the script
#' prompts the user for all required information to start an output script
#'
#' @param args parsed command line arguments as a named list, for documentation of the arguments,
#'        see the command line arguments of this script
output <- function(args) {

  # output creation for --testOneRegi was switched off in start.R in this commit:
  # https://github.com/remindmodel/remind/commit/5905d9dd814b4e4a62738d282bf1815e6029c965
  if (!is.null(args[["output"]]) && all(args[["output"]] %in% c(NA, "NA"))) {
    message("\nNo output generation, as output was set to NA, as for example for --testOneRegi or --quick.")
    return()
  }

  remind_dir <- if (is.null(args[["remind_dir"]])) NULL                                           else unlist(strsplit(args[["remind_dir"]], ","))
  comp       <- if (is.null(args[["comp"]]))       chooseCompMode()                               else args[["comp"]]
  output     <- if (is.null(args[["output"]]))     chooseOutputScript(comp)                       else unlist(strsplit(args[["output"]], ","))
  outputdirs <- if (is.null(args[["outputdirs"]]))  chooseOutputDirs(output, args[["remind_dir"]]) else unlist(strsplit(args[["outputdirs"]], ","))

  if (comp %in% c("comparison", "export")) {
    # aliases are names for scenarios (=outputdirs) that are prompted when the scenarios have duplicate names
    # currently only compareScenarios2 uses aliases, feel free to implement it for your comparison script
    if (is.null(args[["aliases"]])) {
      aliases <- chooseAliases(output, outputdirs)
    } else {
      aliases <- unlist(strsplit(args[["aliases"]], ","))
      stopifnot("Number of aliases and outputdirs must be equal" = length(aliases) == length(outputdirs))
    }
    if (is.null(args[["filename_prefix"]])) {
      # ask for filename_prefix, if one of the modules that use it is selected
      modules_using_filename_prefix <- c("compareScenarios2", "xlsx_IIASA", "varListHtml", "selectPlots")
      if (any(modules_using_filename_prefix %in% output)) {
        filename_prefix <- chooseFilenamePrefix(modules = intersect(modules_using_filename_prefix, output))
      } else {
        filename_prefix <- ""
      }
    } else {
      filename_prefix = args[["filename_prefix"]]
    }

    # choose the slurm options. If you use command line arguments, use slurmConfig=priority or standby
    modulesUsingSlurmConfig <- c("compareScenarios2", "validateScenarios")
    if (isSlurmAvailable() && any(modulesUsingSlurmConfig %in% output)) {
      if (is.null(args[["slurmConfig"]])) {
        slurmConfig <- chooseSlurmConfigOutput(output = output)
      } else if (args[["slurmConfig"]] %in% c("priority", "short", "standby")) {
        slurmConfig <- paste0("--qos=", args[["slurmConfig"]])
      } else {
        slurmConfig = args[["slurmConfig"]]
      }
    }
    errors = runComparisonOrExport(comp, output, outputdirs, aliases, filename_prefix, slurmConfig, args[["test"]])
  } else if (comp %in% c("single")) {
    interactiveSession <- FALSE
    # define slurm class or direct execution
    outputInteractive <- c("plotIterations", "integratedDamageCosts")
    if (!isSlurmAvailable() || exists("source_include") || any(output %in% outputInteractive)) {
      # if being sourced by another script execute the output scripts directly without sending them to the cluster
      slurmConfig <- "direct"
    } else if (is.null(args[["slurmConfig"]])) {
      slurmConfig <- chooseSlurmConfigOutput(output = output)
      if (slurmConfig != "direct") slurmConfig <- combine_slurmConfig("--nodes=1 --tasks-per-node=1 --time=120", slurmConfig)
    } else if (args[["slurmConfig"]] %in% c("priority", "short", "standby")) {
      slurmConfig <- paste0("--nodes=1 --tasks-per-node=1 --qos=", args[["slurmConfig"]])
    } else if (isTRUE(args[["slurmConfig"]] %in% "direct")) {
      interactiveSession <- TRUE
    } else {
      slurmConfig = args[["slurmConfig"]]
    }
    errors = runSingle(output, outputdirs, slurmConfig, interactiveSession, args[["test"]])
  } else {
    stop("Comparison mode not supported")
  }
  if (errors) {
    quit(status = -1)
  }
}


if (exists("source_include")) {
  output(passedArgs)
} else {
  output(parseOptions())
}
