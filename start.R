#!/usr/bin/env Rscript
# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
library(gms)
library(dplyr)
require(stringr)

#' Usage:
#' Rscript start.R [options]
#' Rscript start.R file
#'
#' Without additional arguments this starts a single REMIND run using the settings
#' from `config/default.cfg`.
#'
#' Control the script's behavior by providing additional arguments:
#'
#' --testOneRegi: Starting a single REMIND run in OneRegi mode using the
#'   settings from `config/default.cfg`
#'
#' --restart: Restart a run.
#'
#' Starting a bundle of REMIND runs using the settings from a scenario_config_XYZ.csv:
#'
#'   Rscript start.R config/scenario_config_XYZ.csv

source("scripts/start/submit.R")
source("scripts/start/choose_slurmConfig.R")

############## Define function: get_line ##############################

get_line <- function(){
    # gets characters (line) from the terminal or from a connection
    # and stores it in the return object
    if(interactive()){
        s <- readline()
    } else {
        con <- file("stdin")
        s <- readLines(con, 1, warn=FALSE)
        on.exit(close(con))
    }
    return(s);
}

############## Define function: choose_folder #########################

choose_folder <- function(folder,title="Please choose a folder") {
  dirs <- NULL

  # Detect all output folders containing fulldata.gdx
  # For coupled runs please use the outcommented text block below

  dirs <- sub("/(non_optimal|fulldata).gdx","",sub("./output/","",Sys.glob(c(file.path(folder,"*","non_optimal.gdx"),file.path(folder,"*","fulldata.gdx")))))

  # DK: The following outcommented lines are specially made for listing results of coupled runs
  #runs <- findCoupledruns(folder)
  #dirs <- findIterations(runs,modelpath=folder,latest=TRUE)
  #dirs <- sub("./output/","",dirs)

  dirs <- c("all",dirs)
  cat("\n\n",title,":\n\n")
  cat(paste(1:length(dirs), dirs, sep=": " ),sep="\n")
    cat(paste(length(dirs)+1, "Search by the pattern.\n", sep=": "))
  cat("\nNumber: ")
    identifier <- get_line()
  identifier <- strsplit(identifier,",")[[1]]
  tmp <- NULL
  for (i in 1:length(identifier)) {
    if (length(strsplit(identifier,":")[[i]]) > 1) tmp <- c(tmp,as.numeric(strsplit(identifier,":")[[i]])[1]:as.numeric(strsplit(identifier,":")[[i]])[2])
    else tmp <- c(tmp,as.numeric(identifier[i]))
  }
  identifier <- tmp
  # PATTERN
    if(length(identifier==1) && identifier==(length(dirs)+1)){
        cat("\nInsert the search pattern or the regular expression: ")
        pattern <- get_line()
        id <- grep(pattern=pattern, dirs[-1])
        # lists all chosen directories and ask for the confirmation of the made choice
        cat("\n\nYou have chosen the following directories:\n")
        cat(paste(1:length(id), dirs[id+1], sep=": "), sep="\n")
        cat("\nAre you sure these are the right directories?(y/n): ")
        answer <- get_line()
        if(answer=="y"){
            return(dirs[id+1])
        } else choose_folder(folder,title)
    #
    } else if(any(dirs[identifier] == "all")){
        identifier <- 2:length(dirs)
        return(dirs[identifier])
    } else return(dirs[identifier])
}


############## Define function: configure_cfg #########################

configure_cfg <- function(icfg, iscen, iscenarios, isettings) {

    # Edit run title
    icfg$title <- iscen
    cat("   Configuring cfg for", iscen,"\n")

    # Edit main file of model
    if( "model" %in% names(iscenarios)){
      icfg$model <- iscenarios[iscen,"model"]
    }

    # Edit regional aggregation
    if( "regionmapping" %in% names(iscenarios)){
      icfg$regionmapping <- iscenarios[iscen,"regionmapping"]
    }

    # Edit input data revision
    if( "inputRevision" %in% names(iscenarios)){
      icfg$inputRevision <- iscenarios[iscen,"inputRevision"]
    }

    # Edit switches in default.cfg according to the values given in the scenarios table, if non-empty
    for (switchname in intersect(names(icfg$gms), names(iscenarios))) {
      if ( !is.na(iscenarios[iscen,switchname] )) {
        icfg$gms[[switchname]] <- iscenarios[iscen,switchname]
      }
    }

    # Set reporting script
    if( "output" %in% names(iscenarios)){
      icfg$output <- gsub('c\\("|\\)|"','',strsplit(iscenarios[iscen,"output"],',')[[1]])
    }

    # for columns path_gdx, path_gdx_bau, path_gdx_ref, check whether the cell is non-empty, and not the title of another run with start = 1
    # if not a full path ending with .gdx provided, search for most recent folder with that title
    for (path_to_gdx in c("path_gdx", "path_gdx_ref", "path_gdx_bau")) {
      if (!is.na(isettings[iscen, path_to_gdx]) & ! isettings[iscen, path_to_gdx] %in% row.names(iscenarios)) {
        if (! str_sub(isettings[iscen, path_to_gdx], -4, -1) == ".gdx") {
          # search for fulldata.gdx in output directories starting with the path_to_gdx cell content.
          # may include folders that only _start_ with this string. They are sorted out later.
          dirs <- Sys.glob(file.path(paste0("./output/",isettings[iscen, path_to_gdx],"*/fulldata.gdx")))
          # if path_to_gdx cell content exactly matches folder name, use this one
          if (paste0("./output/",isettings[iscen, path_to_gdx],"/fulldata.gdx") %in% dirs) {
            cat(paste0("   For ", path_to_gdx, " stated as ", isettings[iscen, path_to_gdx], ", a folder with fulldata.gdx was found.\n"))
            isettings[iscen, path_to_gdx] <- paste0("./output/",isettings[iscen, path_to_gdx],"/fulldata.gdx")
          } else {
            # didremindfinish is TRUE if log.txt states that remind finished
            didremindfinish <- function(fulldatapath) return(any(grep("REMIND run finished!", readLines(paste0(str_sub(fulldatapath,1,-14),"/log.txt")))))
            # sort out unfinished runs and folder names that only _start_ with the path_to_gdx cell content
            # for folder names only allows: cell content, an optional _, datetimepattern
            # the optional _ can be appended in the scenario-config path_to_gdx cell to force using an
            # existing fulldata.gdx instead of queueing as a subsequent run, see tutorial 3.
            datetimepattern <- "[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}\\.[0-9]{2}\\.[0-9]{2}"
            dirs <- dirs[unlist(lapply(dirs, didremindfinish)) & grepl(paste0(isettings[iscen, path_to_gdx],"_?", datetimepattern, "/fulldata.gdx"), dirs)]
            # if anything found, pick latest
            if(length(dirs) > 0 && ! all(is.na(dirs))) {
              lapply(dirs, str_sub, -32, -14) %>%
                strptime(format='%Y-%m-%d_%H.%M.%S') %>%
                as.numeric %>%
                which.max -> latest_fulldata
              cat(paste0("   For ", path_to_gdx, " stated as ", isettings[iscen, path_to_gdx], ", this run was the newest:\n     ", dirs[latest_fulldata], "\n   Its log.txt contains 'REMIND run finished!', but please check yourself whether it converged etc.\n"))
              isettings[iscen, path_to_gdx] <- dirs[latest_fulldata]
            }
          }
        }
        # if the above has not created a path to a valid gdx, stop
        if (!file.exists(isettings[iscen, path_to_gdx])){
          stop(paste0("Can't find a gdx specified as ", isettings[iscen, path_to_gdx], " in column ", path_to_gdx, ". Please specify full path to gdx or name of output subfolder that contains a fulldata.gdx from a previous run."))
        }
      }
    }

    # Define path where the GDXs will be taken from
    gdxlist <- c(input.gdx     = isettings[iscen, "path_gdx"],
                 input_ref.gdx = isettings[iscen, "path_gdx_ref"],
                 input_bau.gdx = isettings[iscen, "path_gdx_bau"])

    # Determine whether we need a separate carbon price GDX or not and export it
    has_carbonprice_path <- FALSE
    if ("path_gdx_carbonprice" %in% colnames(isettings)) { if (!is.na(isettings[iscen,"path_gdx_carbonprice"])) {
      has_carbonprice_path <- TRUE
      gdxlist <- c(gdxlist, input_carbonprice.gdx = isettings[iscen, "path_gdx_carbonprice"])
    }}

    # add gdxlist to list of files2export
    icfg$files2export$start <- c(icfg$files2export$start, gdxlist)

    # add table with information about runs that need the fulldata.gdx of the current run as input
    icfg$RunsUsingTHISgdxAsInput <- iscenarios %>% select(contains("path_gdx_")) %>%             # select columns that have "path_gdx_" in their name
                                                   filter(rowSums(. == iscen, na.rm = TRUE) > 0) # select rows that have the current scenario in any column

    return(icfg)
}


# check command-line arguments for testOneRegi and scenario_config file
if(!exists("argv")) argv <- commandArgs(trailingOnly = TRUE)
config.file <- argv[1]

# define arguments that are accepted
accepted <- c('--restart','--testOneRegi')

# check if user provided any unknown arguments or config files that do not exist
known <-  argv %in% accepted
if (!all(known)) {
  file_exists <- file.exists(argv[!known])
  if (!all(file_exists)) stop("Unknown parameter provided: ",paste(argv[!known][!file_exists]," "))
}

###################### Choose submission type #########################
if(!exists("slurmConfig")) slurmConfig <- choose_slurmConfig()

# Restart REMIND in existing results folder (if required by user)
if ('--restart' %in% argv) {
  # choose results folder from list
  outputdirs <- choose_folder("./output","Please choose the runs to be restarted")
  for (outputdir in outputdirs) {
    cat("Restarting",outputdir,"\n")
    load(paste0("output/",outputdir,"/config.Rdata")) # read config.Rdata from results folder
    cfg$slurmConfig <- combine_slurmConfig(cfg$slurmConfig,slurmConfig) # update the slurmConfig setting to what the user just chose
    cfg$results_folder <- paste0("output/",outputdir) # overwrite results_folder in cfg with name of the folder the user wants to restart, because user might have renamed the folder before restarting
    submit(cfg, restart = TRUE)
    #cat(paste0("output/",outputdir,"/config.Rdata"),"\n")
  }

} else {

  # If testOneRegi was selected, set up a testOneRegi run.
  if ('--testOneRegi' %in% argv) {
    testOneRegi <- TRUE
    config.file <- NA
  } else {
    testOneRegi <- FALSE
  }

  ###################### Load csv if provided  ##########################

  # If a scenario_config.csv file was provided, set cfg according to it.

  if (!is.na(config.file)) {
    cat(paste("\nReading config file", config.file, "\n"))

    # Read-in the switches table, use first column as row names
    settings <- read.csv2(config.file, stringsAsFactors = FALSE, row.names = 1, comment.char = "#", na.strings = "")

    # Add empty path_gdx_... columns if they are missing
    path_gdx_required <- c("path_gdx", "path_gdx_ref", "path_gdx_bau")
    settings[, path_gdx_required[! path_gdx_required %in% names(settings)]] <- NA
    
    # state if columns are unknown and cannot be used
    source("config/default.cfg")
    unknown_columns <- names(settings)[! names(settings) %in% c(names(cfg$gms), "start", "path_gdx_carbonprice", "path_gdx", "path_gdx_ref", "path_gdx_bau", "output", "model", "regionmapping", "inputRevision")]
    if (length(unknown_columns) > 0) {
      cat(paste("Those columns have no counterpart in default.cfg and will be ignored:", paste(unknown_columns, collapse = ", "), "\n"))
    }

    # Select scenarios that are flagged to start
    scenarios  <- settings[settings$start==1,]
    if (length(grep("\\.", rownames(scenarios))) > 0) stop(paste0("These titles contain dots: ", paste0(rownames(scenarios)[grep("\\.", rownames(scenarios))], collapse = ", "), " – GAMS would not tolerate this, and quit working at a point where you least expect it. Stopping now."))
    if (length(grep("_$", rownames(scenarios))) > 0) stop(paste0("These titles end with _: ", paste0(rownames(scenarios)[grep("_$", rownames(scenarios))], collapse = ", "), ". This may lead start.R to select wrong gdx files. Stopping now."))
  } else {
    # if no csv was provided create dummy list with default as the only scenario
    scenarios <- data.frame("default" = "default",row.names = "default")
  }

  ###################### Loop over scenarios ###############################

  # Modify and save cfg for all runs
  for (scen in rownames(scenarios)) {
    #source cfg file for each scenario to avoid duplication of gdx entries in files2export
    source("config/default.cfg")

    # Have the log output written in a file (not on the screen)
    cfg$slurmConfig <- slurmConfig
    cfg$logoption   <- 2
    start_now       <- TRUE

    # testOneRegi settings
    if (testOneRegi) {
      cfg$title            <- 'testOneRegi'
      cfg$gms$optimization <- 'testOneRegi'
      cfg$output           <- NA
      cfg$results_folder   <- 'output/testOneRegi'

      # delete existing Results directory
      cfg$force_replace    <- TRUE
    }

    cat("\n",scen,"\n")

    # configure cfg according to settings from csv if provided
    if (!is.na(config.file)) {
      cfg <- configure_cfg(cfg, scen, scenarios, settings)
      # Directly start runs that have a gdx file location given as path_gdx_ref or where this field is empty
      gdx_exists <- (! is.na(cfg$files2export$start['input_ref.gdx']) && str_sub(cfg$files2export$start['input_ref.gdx'], -4, -1) == ".gdx")
      if (gdx_exists) cat("   Using input_ref.gdx found here:", cfg$files2export$start['input_ref.gdx'], "\n")
      start_now <- (gdx_exists || is.na(cfg$files2export$start['input_ref.gdx']))
    }

    # save the cfg object for the later automatic start of subsequent runs (after preceding run finished)
    filename <- paste0(scen,".RData")
    cat("   Writing cfg to file",filename,"\n")
    save(cfg,file=filename)

    if (start_now){
      # Create results folder and start run
      submit(cfg)
      } else {
      cat("   Waiting for", scenarios[scen,'path_gdx_ref'] ,"\n")
    }

    # print names of subsequent runs if there are any
    if (length(cfg$RunsUsingTHISgdxAsInput)[1] != 0) {
      if (any(cfg$RunsUsingTHISgdxAsInput$path_gdx_ref == scen)) {
      cat("   Subsequent runs:",rownames(cfg$RunsUsingTHISgdxAsInput[cfg$RunsUsingTHISgdxAsInput$path_gdx_ref == scen,]),"\n")
    }}

  }
}
