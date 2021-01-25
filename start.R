#!/usr/bin/env Rscript
# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
library(lucode)

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
#'


source("scripts/start/submit.R")
source("scripts/start/choose_slurmConfig.R")

############## Define function: get_line ##############################

get_line <- function(){
	# gets characters (line) from the terminal of from a connection
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

    .setgdxcopy <- function(needle, stack, new) {
      # delete entries in stack that contain needle and append new
      out <- c(stack[-grep(needle, stack)], new)
      return(out)
    }

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
    if( "revision" %in% names(iscenarios)){
      icfg$revision <- iscenarios[iscen,"revision"]
    }

    # Edit switches in default.cfg according to the values given in the scenarios table
    for (switchname in intersect(names(icfg$gms), names(iscenarios))) {
      icfg$gms[[switchname]] <- iscenarios[iscen,switchname]
    }

    # Set reporting script
    if( "output" %in% names(iscenarios)){
      icfg$output <- paste0("c(\"",gsub(",","\",\"",gsub(", ",",",iscenarios[iscen,"output"])),"\")")
    }

    # check if full input.gdx path is provided and, if not, search for correct path
    if (!substr(isettings[iscen,"path_gdx"], nchar(isettings[iscen,"path_gdx"])-3, nchar(isettings[iscen,"path_gdx"])) == ".gdx"){
      #if there is no correct scenario folder within the output folder path provided, take the config/input.gdx
      if(length(grep(iscen,list.files(path=isettings[iscen,"path_gdx"]),value=T))==0){
        isettings[iscen,"path_gdx"] <- "config/input.gdx"
      #if there is only one instance of an output folder with that name, take the fulldata.gdx from this
      } else if (length(grep(iscen,list.files(path=isettings[iscen,"path_gdx"]),value=T))==1){
        isettings[iscen,"path_gdx"] <- paste0(isettings[iscen,"path_gdx"],"/",
                                            grep(iscen,list.files(path=isettings[iscen,"path_gdx"]),value=T),"/fulldata.gdx")
      } else {
        #if there are multiple instances, take the newest one
        isettings[iscen,"path_gdx"] <- paste0(isettings[iscen,"path_gdx"],"/",
                                            substr(grep(iscen,list.files(path=isettings[iscen,"path_gdx"]),value=T),1,
                                                   nchar(grep(iscen,list.files(path=isettings[iscen,"path_gdx"]),value=T))-19)[1],
        max(substr(grep(iscen,list.files(path=isettings[iscen,"path_gdx"]),value=T),
                                 nchar(grep(iscen,list.files(path=isettings[iscen,"path_gdx"]),value=T))-18,
                                 nchar(grep(iscen,list.files(path=isettings[iscen,"path_gdx"]),value=T)))),"/fulldata.gdx")
      }
    }

    # if the above has not created a path to a valid gdx, take config/input.gdx
    if (!file.exists(isettings[iscen,"path_gdx"])){
      isettings[iscen,"path_gdx"] <- "config/input.gdx"
      #if even this is not existent, stop
      if (!file.exists(isettings[iscen,"path_gdx"])){
      stop("Cant find a gdx under path_gdx, please specify full path to gdx or else location of output folder that contains previous run")
      }
    }

    # Define path where the GDXs will be taken from
    gdxlist <- c(input.gdx     = isettings[iscen, "path_gdx"],
                 input_ref.gdx = isettings[iscen, "path_gdx_ref"],
                 input_bau.gdx = isettings[iscen, "path_gdx_bau"])

    # Remove potential elements that end with ".gdx" and append gdxlist
    icfg$files2export$start <- .setgdxcopy("\\.gdx$", icfg$files2export$start, gdxlist)

    # add gdx information for subsequent runs
    icfg$subsequentruns        <- rownames(isettings[isettings$path_gdx_ref == iscen & !is.na(isettings$path_gdx_ref) & isettings$start == 1,])
    icfg$RunsUsingTHISgdxAsBAU <- rownames(isettings[isettings$path_gdx_bau == iscen & !is.na(isettings$path_gdx_bau) & isettings$start == 1,])

    return(icfg)
}


# check command-line arguments for testOneRegi and scenario_config file
argv <- commandArgs(trailingOnly = TRUE)
config.file <- argv[1]

# define arguments that are accepted
accepted <- c('--restart','--testOneRegi')

# check if user provided any unknown arguments or config files that do not exist
known <-  argv %in% accepted
if (!all(known)) {
  file_exists <- file.exists(argv[!known])
  if (!all(file_exists)) stop("Unknown paramter provided: ",paste(argv[!known][!file_exists]," "))
}

###################### Choose submission type #########################
slurmConfig <- choose_slurmConfig()

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

    # Select scenarios that are flagged to start
    scenarios  <- settings[settings$start==1,]
    if (length(grep("\\.",rownames(scenarios))) > 0) stop("One or more titles contain dots - GAMS would not tolerate this, and quit working at a point where you least expect it. Stopping now. ")
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
      start_now <- (substr(scenarios[scen,"path_gdx_ref"], nchar(scenarios[scen,"path_gdx_ref"])-3, nchar(scenarios[scen,"path_gdx_ref"])) == ".gdx"
                   | is.na(scenarios[scen,"path_gdx_ref"]))
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

    if (!identical(cfg$subsequentruns,character(0))) cat("   Subsequent runs:",cfg$subsequentruns,"\n")
    
  }
}
