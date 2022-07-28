#!/usr/bin/env Rscript
# |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
library(gms)
library(dplyr)
require(stringr)

helpText <- "
#' Usage:
#' Rscript start.R [options]
#' Rscript start.R file
#' Rscript start.R --test --testOneRegi file
#'
#' Without additional arguments this starts a single REMIND run
#' using the settings from `config/default.cfg`.
#'
#' Starting a bundle of REMIND runs using the settings from a scenario_config_XYZ.csv:
#'
#'   Rscript start.R config/scenario_config_XYZ.csv
#'
#' Control the script's behavior by providing additional arguments:
#'
#' --help, -h: show this help text and exit
#'
#' --debug, -d: start a debug run with cm_nash_mode = debug
#'
#' --interactive, -i: interactively select config file and run(s) to be started
#'
#' --quick, -q: starting one fast REMIND run with one region, one iteration and
#'              reduced convergence criteria for testing the full model.
#'
#' --reprepare, -R: rewrite full.gms and restart run
#'
#' --reset, -0: reset main.gms to default.cfg and exit
#'
#' --restart, -r: interactively restart run(s)
#'
#' --test, -t: Test scenario configuration and writing the RData files in the
#'             REMIND main folder without starting the runs.
#'
#' --testOneRegi, -1: starting the REMIND run(s) in testOneRegi mode
#'
#' You can combine --reprepare with --debug, --testOneRegi or --quick and the selected folders will be restarted using these settings.
#' Afterwards, using --reprepare alone will restart the runs using their original settings.
"
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

############## Define function: chooseFromList #########################
# thelist: list to be selected from
# group: list with same dimension as thelist with group names to allow to select whole groups
# returnboolean: TRUE: returns list with dimension of thelist with 0 or 1
# returnboolean: FALSE: returns selected entries of thelist
# multiple: TRUE: allows to select multiple entries. FALSE: no
# allowempty: TRUE: allows you not to select anything (returns NA). FALSE: must select something
# type: string to be shown to user to understand what they choose

chooseFromList <- function(thelist, type = "runs", returnboolean = FALSE, multiple = TRUE,
                           allowempty = FALSE, group = FALSE) {
  originallist <- thelist
  booleanlist <- numeric(length(originallist)) # set to zero
  if (! isFALSE(group) && (length(group) != length(originallist) | isFALSE(multiple))) {
    message("group must have same dimension as thelist, or multiple not allowed. Group mode disabled")
    group <- FALSE
  }
  message("\n\nPlease choose ", type,":\n\n")
  if (! isFALSE(group)) {
    groups <- sort(unique(group))
    groupsids <- seq(length(originallist)+2, length(originallist)+length(groups)+1)
    thelist <- c(paste0(str_pad(thelist, max(nchar(originallist)), side = "right"), " ", group), paste("Group:", groups))
    message(str_pad("", max(nchar(originallist)) + nchar(length(thelist)+2)+2, side = "right"), " Group")
  }
  if(multiple)   thelist <- c("all", thelist, "Search by pattern...")
  message(paste(paste(str_pad(1:length(thelist), nchar(length(thelist)), side = "left"), thelist, sep=": " ), collapse="\n"))
  message("\nNumber", ifelse(multiple,"s entered as 2,4:6,9",""),
          ifelse(allowempty, " or leave empty", ""), " (", type, "): ")
  identifier <- strsplit(get_line(), ",")[[1]]
  if (allowempty & length(identifier) == 0) return(NA)
  if (length(identifier) == 0 | ! all(grepl("^[0-9,:]*$", identifier))) {
    message("Try again, you have to choose some numbers.")
    return(chooseFromList(originallist, type, returnboolean, multiple, allowempty, group))
  }
  tmp <- NULL
  for (i in 1:length(identifier)) { # turns 2:5 into 2,3,4,5
    if (length(strsplit(identifier,":")[[i]]) > 1) {
      tmp <- c(tmp,as.numeric(strsplit(identifier,":")[[i]])[1]:as.numeric(strsplit(identifier,":")[[i]])[2])
    }
    else {
      tmp <- c(tmp,as.numeric(identifier[i]))
    }
  }
  identifier <- tmp
  if (! multiple & length(identifier) > 1) {
    message("Try again, not in list or multiple chosen: ", paste(identifier, collapse = ", "))
    return(chooseFromList(originallist, type, returnboolean, multiple, allowempty, group))
  }
  if (any(! identifier %in% seq(length(thelist)))) {
    message("Try again, not all in list: ", paste(identifier, collapse = ", "))
    return(chooseFromList(originallist, type, returnboolean, multiple, allowempty, group))
  }
  if (! isFALSE(group)) {
    selectedgroups <- sub("^Group: ", "", thelist[intersect(identifier, groupsids)])
    identifier <- unique(c(identifier[! identifier %in% groupsids], which(group %in% selectedgroups)+1))
  }
  # PATTERN
  if(multiple && length(identifier == 1) && identifier == length(thelist) ){
    message("\nInsert the search pattern or the regular expression: ")
    pattern <- get_line()
    id <- grep(pattern=pattern, originallist)
    # lists all chosen and ask for the confirmation of the made choice
    message("\n\nYou have chosen the following ", type, ":")
    if (length(id) > 0) message(paste(paste(1:length(id), originallist[id], sep=": "), collapse="\n"))
    message("\nAre you sure these are the right ", type, "? (y/n): ")
    if(get_line() == "y"){
      identifier <- id
      booleanlist[id] <- 1
    } else {
      return(chooseFromList(originallist, type, returnboolean, multiple, allowempty, group))
    }
  } else if(any(thelist[identifier] == "all")){
    booleanlist[] <- 1
    identifier <- 1:length(originallist)
  } else {
    if (multiple) identifier <- identifier - 1
    booleanlist[identifier] <- 1
  }
  message("Selected: ", paste(originallist[identifier], collapse = ", "))
  if (returnboolean) return(booleanlist) else return(originallist[identifier])
}

############## Define function: select_testOneRegi_region #############
select_testOneRegi_region <- function() {
  message("\nWhich region should testOneRegi use? Type it, or leave empty to keep settings:\n",
  "Examples are CAZ, CHA, EUR, IND, JPN, LAM, MEA, NEU, OAS, REF, SSA, USA.")
  return(get_line())
}

############## Define function: configure_cfg #########################

configure_cfg <- function(icfg, iscen, iscenarios, isettings) {

    # Edit run title
    icfg$title <- iscen
    message("   Configuring cfg for ", iscen)

    # Edit main model file, region settings and input data revision based on scenarios table, if cell non-empty
    for (switchname in intersect(c("model", "regionmapping", "inputRevision", "slurmConfig"), names(iscenarios))) {
      if ( ! is.na(iscenarios[iscen, switchname] )) {
        icfg[[switchname]] <- iscenarios[iscen, switchname]
      }
    }
    if (icfg$slurmConfig %in% paste(seq(1:16)) & ! any(c("--debug", "--quick", "--testOneRegi") %in% argv)) {
      icfg$slurmConfig <- choose_slurmConfig(identifier = icfg$slurmConfig)
    }
    if (icfg$slurmConfig %in% c(NA, ""))       {
      if(! exists("slurmConfig")) slurmConfig <- choose_slurmConfig()
      icfg$slurmConfig <- slurmConfig
    }

    # Set description
    if ("description" %in% names(iscenarios) && ! is.na(iscenarios[iscen, "description"])) {
      icfg$description <- gsub('"', '', iscenarios[iscen, "description"])
    } else {
      icfg$description <- paste0("REMIND run ", iscen, " started by ", config.file, ".")
    }

    # Set reporting script
    if ("output" %in% names(iscenarios) && ! is.na(iscenarios[iscen, "output"])) {
      icfg$output <- gsub('c\\("|\\)|"', '', strsplit(iscenarios[iscen, "output"],',')[[1]])
    }

    # Edit switches in default.cfg based on scenarios table, if cell non-empty
    for (switchname in intersect(names(icfg$gms), names(iscenarios))) {
      if ( ! is.na(iscenarios[iscen, switchname] )) {
        icfg$gms[[switchname]] <- iscenarios[iscen, switchname]
      }
    }

    # didremindfinish is TRUE if full.log exists with status: Normal completion
    didremindfinish <- function(fulldatapath) {
      logpath <- paste0(str_sub(fulldatapath,1,-14),"/full.log")
      return( file.exists(logpath) && any(grep("*** Status: Normal completion", readLines(logpath, warn = FALSE), fixed = TRUE)))
    }

    # for columns path_gdx…, check whether the cell is non-empty, and not the title of another run with start = 1
    # if not a full path ending with .gdx provided, search for most recent folder with that title
    if (any(iscen %in% isettings[iscen, names(path_gdx_list)])) {
      stop("Self-reference: ", iscen , " refers to itself in a path_gdx... column.")
    }
    for (path_to_gdx in names(path_gdx_list)) {
      if (!is.na(isettings[iscen, path_to_gdx]) & ! isettings[iscen, path_to_gdx] %in% row.names(iscenarios)) {
        if (! str_sub(isettings[iscen, path_to_gdx], -4, -1) == ".gdx") {
          # search for fulldata.gdx in output directories starting with the path_to_gdx cell content.
          # may include folders that only _start_ with this string. They are sorted out later.
          dirfolders <- c("./output/", icfg$modeltests_folder)
          for (dirfolder in dirfolders) {
            dirs <- Sys.glob(file.path(dirfolder, paste0(isettings[iscen, path_to_gdx], "*/fulldata.gdx")))
            # if path_to_gdx cell content exactly matches folder name, use this one
            if (file.path(dirfolder, isettings[iscen, path_to_gdx], "fulldata.gdx") %in% dirs) {
              message(paste0("   For ", path_to_gdx, " = ", isettings[iscen, path_to_gdx], ", a folder with fulldata.gdx was found."))
              isettings[iscen, path_to_gdx] <- file.path(dirfolder, isettings[iscen, path_to_gdx], "fulldata.gdx")
              if (dirfolder == icfg$modeltests_folder) modeltestRunsUsed <<- modeltestRunsUsed + 1
            } else {
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
                message(paste0("   Use newest normally completed run for ", path_to_gdx, " = ", isettings[iscen, path_to_gdx], ":\n     ", str_sub(dirs[latest_fulldata],if (dirfolder == icfg$modeltests_folder) 0 else 10 ,-14)))
                isettings[iscen, path_to_gdx] <- dirs[latest_fulldata]
                if (dirfolder == icfg$modeltests_folder) modeltestRunsUsed <<- modeltestRunsUsed + 1
              }
            }
          }
        }
        # if the above has not created a path to a valid gdx, stop
        if (!file.exists(isettings[iscen, path_to_gdx])){
          stoptext <- paste0("Can't find a gdx specified as ", isettings[iscen, path_to_gdx], " in column ", path_to_gdx, ".\nPlease specify full path to gdx or name of output subfolder that contains a fulldata.gdx from a previous normally completed run.")
          if (! "--test" %in% argv) stop(stoptext) else {
            ignorederrors <<- ignorederrors + 1
            message("Error: ", stoptext)
          }
        }
      }
    }

    # Define path where the GDXs will be taken from
    gdxlist <- unlist(isettings[iscen, names(path_gdx_list)])
    names(gdxlist) <- path_gdx_list

    # add gdxlist to list of files2export
    icfg$files2export$start <- c(icfg$files2export$start, gdxlist, config.file)

    # add table with information about runs that need the fulldata.gdx of the current run as input
    icfg$RunsUsingTHISgdxAsInput <- iscenarios %>% select(contains("path_gdx")) %>%              # select columns that have "path_gdx" in their name
                                                   filter(rowSums(. == iscen, na.rm = TRUE) > 0) # select rows that have the current scenario in any column

    return(icfg)
}


# load command-line arguments
if(!exists("argv")) argv <- commandArgs(trailingOnly = TRUE)

# define arguments that are accepted
accepted <- c("0" = "--reset", "1" = "--testOneRegi", d = "--debug", i = "--interactive", r = "--restart",
              R = "--reprepare", t = "--test", h = "--help", q = "--quick")

# search for strings that look like -i1asrR and transform them into long flags
onedashflags <- unlist(strsplit(paste0(argv[grepl("^-[a-zA-Z0-9]*$", argv)], collapse = ""), split = ""))
argv <- unique(c(argv[! grepl("^-[a-zA-Z0-9]*$", argv)], unlist(accepted[names(accepted) %in% onedashflags])))
message("\nAll flags: ", paste(argv, collapse = ", "))
if (sum(! onedashflags %in% c(names(accepted), "-")) > 0) {
  stop("Unknown single character flags: ", onedashflags[! onedashflags %in% c(names(accepted), "-")],
  ". Only available: ", paste0("-", names(accepted), collapse = ", ") )
}

# initialize config.file
config.file <- NA

# check if user provided any unknown arguments or config files that do not exist
known <- argv %in% accepted
if (!all(known)) {
  file_exists <- file.exists(argv[!known])
  if (sum(file_exists) > 1) stop("You provided two files, start.R can only handle one.")
  if (!all(file_exists)) stop("Unknown parameter provided: ", paste(argv[!known][!file_exists], collapse = ", "),
  ".\nAccepted parameters: [config file], ", paste(accepted, collapse = ", "))
  # set config file to not known parameter where the file actually exists
  config.file <- argv[!known][[1]] 
}

if ("--help" %in% argv) {
  message(helpText)
  q()
}

if ("--reset" %in% argv) {
  source("./config/default.cfg")
  cfg$gms$c_expname <- cfg$title
  cfg$gms$c_description <- substr(cfg$description, 1, 255)
  lock_id <- gms::model_lock(timeout1 = 0.2)
  on.exit(gms::model_unlock(lock_id))
  lucode2::manipulateConfig("main.gms", cfg$gms)
  message("Settings in main.gms were reset to values specified in config/default.cfg.")
  gms::model_unlock(lock_id)
  on.exit()
  q()
}

if (any(c("--testOneRegi", "--debug", "--quick") %in% argv) & "--restart" %in% argv & ! "--reprepare" %in% argv) {
  message("\nIt is impossible to combine --restart with --debug, --quick or --testOneRegi because full.gms has to be rewritten.\n",
  "If this is what you want, use --reprepare instead, or answer with y:")
  if (get_line() %in% c("Y", "y")) argv <- c(argv, "--reprepare")
}

ignorederrors <- 0 # counts ignored errors in --test mode
startedRuns <- 0
waitingRuns <- 0
modeltestRunsUsed <- 0

###################### Choose submission type #########################

testOneRegi_region <- ""

# Save whether model is locked before runs are started
model_was_locked <- if (exists("is_model_locked")) is_model_locked() else file.exists(".lock")

# Restart REMIND in existing results folder (if required by user)
if (any(c("--reprepare", "--restart") %in% argv)) {
  # choose results folder from list
  searchforfile <- if ("--reprepare" %in% argv) "config.Rdata" else "full.gms"
  possibledirs <- basename(dirname(Sys.glob(file.path("output", "*", searchforfile))))
  # DK: The following outcommented lines are specially made for listing results of coupled runs
  # runs <- lucode2::findCoupledruns("./output/")
  # possibledirs <- sub("./output/", "", lucode2::findIterations(runs, modelpath = "./output", latest = TRUE))
  outputdirs <- chooseFromList(sort(unique(possibledirs)), "runs to be restarted", returnboolean = FALSE)
  message("\nAlso restart subsequent runs? Enter y, else leave empty:")
  restart_subsequent_runs <- get_line() %in% c("Y", "y")
  if ("--testOneRegi" %in% argv) testOneRegi_region <- select_testOneRegi_region()
  if ("--reprepare" %in% argv) {
    message("\nBecause of the flag --reprepare, move full.gms -> full_old.gms and fulldata.gdx -> fulldata_old.gdx such that runs are newly prepared.\n")
  }
  if(! exists("slurmConfig")) slurmConfig <- choose_slurmConfig()
  if ("--quick" %in% argv) slurmConfig <- paste(slurmConfig, "--time=60")
  message()
  for (outputdir in outputdirs) {
    message("Restarting ", outputdir)
    load(paste0("output/", outputdir, "/config.Rdata")) # read config.Rdata from results folder
    cfg$restart_subsequent_runs <- restart_subsequent_runs
    # for debug, testOneRegi, quick: save original settings to cfg$backup; restore them from there if not set.
    if ("--debug" %in% argv) {
      if (is.null(cfg[["backup"]][["cm_nash_mode"]])) cfg$backup$cm_nash_mode <- cfg$gms$cm_nash_mode
      cfg$gms$cm_nash_mode <- "debug"
    } else {
      if (! is.null(cfg[["backup"]][["cm_nash_mode"]])) cfg$gms$cm_nash_mode <- cfg$backup$cm_nash_mode
    }
    cfg$gms$cm_quick_mode <- if ("--quick" %in% argv) "on" else "off"
    if (any(c("--quick", "--testOneRegi") %in% argv)) {
      if (is.null(cfg[["backup"]][["optimization"]])) cfg$backup$optimization <- cfg$gms$optimization
      cfg$gms$optimization <- "testOneRegi"
      if (testOneRegi_region != "") cfg$gms$c_testOneRegi_region <- testOneRegi_region
    } else {
      if (! is.null(cfg[["backup"]][["optimization"]])) cfg$gms$optimization <- cfg$backup$optimization
    }
    if ("--quick" %in% argv) {
      if (is.null(cfg[["backup"]][["cm_iteration_max"]])) cfg$backup$cm_iteration_max <- cfg$gms$cm_iteration_max
      cfg$gms$cm_iteration_max <- 1
    } else {
      if (! is.null(cfg[["backup"]][["cm_iteration_max"]])) cfg$gms$cm_iteration_max <- cfg$backup$cm_iteration_max
    }
    if ("--reprepare" %in% argv & ! "--test" %in% argv) {
      try(system(paste0("mv output/", outputdir, "/full.gms output/", outputdir, "/full_old.gms")))
      try(system(paste0("mv output/", outputdir, "/fulldata.gdx output/", outputdir, "/fulldata_old.gdx")))
    }
    cfg$slurmConfig <- combine_slurmConfig(cfg$slurmConfig,slurmConfig) # update the slurmConfig setting to what the user just chose
    cfg$remind_folder <- getwd()                      # overwrite remind_folder: run to be restarted may have been moved from other repository
    cfg$results_folder <- paste0("output/",outputdir) # overwrite results_folder in cfg with name of the folder the user wants to restart, because user might have renamed the folder before restarting
    save(cfg,file=paste0("output/",outputdir,"/config.Rdata"))
    startedRuns <- startedRuns + 1
    if (! '--test' %in% argv) {
      submit(cfg, restart = TRUE)
    } else {
      message("   If this wasn't --test mode, I would have restarted ", cfg$title, ".")
    }
    #cat(paste0("output/",outputdir,"/config.Rdata"),"\n")
  }

} else {

  if (is.na(config.file) & "--interactive" %in% argv) {
    possiblecsv <- Sys.glob(c(file.path("./config/scenario_config*.csv"), file.path("./config","*","scenario_config*.csv")))
    possiblecsv <- possiblecsv[! grepl(".*scenario_config_coupled.*csv$", possiblecsv)]
    config.file <- chooseFromList(possiblecsv, type = "one config file", returnboolean = FALSE, multiple = FALSE, allowempty = TRUE)
  }

  if (all(c("--testOneRegi", "--interactive") %in% argv)) testOneRegi_region <- select_testOneRegi_region()

  ###################### Load csv if provided  ###########################

  # If a scenario_config.csv file was provided, set cfg according to it.

  if (! is.na(config.file)) {
    cat(paste("\nReading config file", config.file, "\n"))

    # Read-in the switches table, use first column as row names
    settings <- read.csv2(config.file, stringsAsFactors = FALSE, row.names = 1, comment.char = "#", na.strings = "")

    # Add empty path_gdx_... columns if they are missing
    path_gdx_list <- c("path_gdx" = "input.gdx",
                       "path_gdx_ref" = "input_ref.gdx",
                       "path_gdx_refpolicycost" = "input_refpolicycost.gdx",
                       "path_gdx_bau" = "input_bau.gdx",
                       "path_gdx_carbonprice" = "input_carbonprice.gdx")

    if ("path_gdx_ref" %in% names(settings) && ! "path_gdx_refpolicycost" %in% names(settings)) {
      settings$path_gdx_refpolicycost <- settings$path_gdx_ref
      message("\nNo column path_gdx_refpolicycost for policy cost comparison found, using path_gdx_ref instead.")
    }
    settings[, names(path_gdx_list)[! names(path_gdx_list) %in% names(settings)]] <- NA
    
    # state if columns are unknown and probably will be ignored, and stop for some outdated parameters.
    source("config/default.cfg")
    knownColumnNames <- c(names(cfg$gms), names(path_gdx_list), "start", "output", "description", "model",
                          "regionmapping", "inputRevision", "slurmConfig")
    unknownColumnNames <- names(settings)[! names(settings) %in% knownColumnNames]
    if (length(unknownColumnNames) > 0) {
      message("\nAutomated checks did not find counterparts in default.cfg for these config file columns:")
      message("  ", paste(unknownColumnNames, collapse = ", "))
      message("start.R might simply ignore them. Please check if these switches are not deprecated.")
      message("This check was added Jan. 2022. If you find false positives, add them to knownColumnNames in start.R.\n")
      forbiddenColumnNames <- list(   # specify forbidden column name and what should be done with it
        "c_budgetCO2" = "Rename to c_budgetCO2from2020, adapt emission budgets, see https://github.com/remindmodel/remind/pull/640",
        "c_budgetCO2FFI" = "Rename to c_budgetCO2from2020FFI, adapt emission budgets, see https://github.com/remindmodel/remind/pull/640"
      )
      for (i in intersect(names(forbiddenColumnNames), unknownColumnNames)) {
        message("Column name ", i, " in ", config.file , " is outdated. ", forbiddenColumnNames[i])
      }
      if (any(names(forbiddenColumnNames) %in% unknownColumnNames)) {
        stop("Outdated column names found that must not be used. Stopped.")
      }
    }

    # Select scenarios that are flagged to start, some checks for titles
    if ("--interactive" %in% argv | ! any(settings$start == 1)) {
      settings$start <- chooseFromList(rownames(settings), type = "runs", returnboolean = TRUE, group = settings$start)
    }
    scenarios <- settings[settings$start==1,]
    if (any(nchar(rownames(scenarios)) > 75)) stop(paste0("These titles are too long: ", paste0(rownames(scenarios)[nchar(rownames(scenarios)) > 75], collapse = ", "), " – GAMS would not tolerate this, and quit working at a point where you least expect it. Stopping now."))
    if (length(grep("\\.", rownames(scenarios))) > 0) stop(paste0("These titles contain dots: ", paste0(rownames(scenarios)[grep("\\.", rownames(scenarios))], collapse = ", "), " – GAMS would not tolerate this, and quit working at a point where you least expect it. Stopping now."))
    if (length(grep("_$", rownames(scenarios))) > 0) stop(paste0("These titles end with _: ", paste0(rownames(scenarios)[grep("_$", rownames(scenarios))], collapse = ", "), ". This may lead start.R to select wrong gdx files. Stopping now."))
  } else {
    # if no csv was provided create dummy list with default/testOneRegi as the only scenario
    if (any(c("--quick", "--testOneRegi") %in% argv)) {
      scenarios <- data.frame("testOneRegi" = "testOneRegi", row.names = "testOneRegi")
    } else {
      scenarios <- data.frame("default" = "default", row.names = "default")
    }
  }

  ###################### Loop over scenarios ###############################

  # ask for slurmConfig if not specified for every run
  if(! exists("slurmConfig") & (any(c("--debug", "--quick", "--testOneRegi") %in% argv) | ! "slurmConfig" %in% names(scenarios) || any(is.na(scenarios$slurmConfig)))) {
    slurmConfig <- choose_slurmConfig()
    if ("--quick" %in% argv) slurmConfig <- paste(slurmConfig, "--time=60")
    if (any(c("--debug", "--quick", "--testOneRegi") %in% argv) && !is.na(config.file)) {
      message("\nYour slurmConfig selection will overwrite the settings in your scenario_config file.")
    }
  }

  # Modify and save cfg for all runs
  for (scen in rownames(scenarios)) {

    #source cfg file for each scenario to avoid duplication of gdx entries in files2export
    source("config/default.cfg")

    # Have the log output written in a file (not on the screen)
    cfg$logoption   <- 2
    start_now       <- TRUE

    # testOneRegi settings
    if (any(c("--quick", "--testOneRegi") %in% argv) & is.na(config.file)) {
      cfg$title            <- "testOneRegi"
      cfg$description      <- "A REMIND run with default settings using testOneRegi"
      cfg$gms$optimization <- "testOneRegi"
      cfg$output           <- NA
      cfg$results_folder   <- "output/testOneRegi"
      # delete existing Results directory
      cfg$force_replace    <- TRUE
      if (testOneRegi_region != "") cfg$gms$c_testOneRegi_region <- testOneRegi_region
    }
    if ("--quick" %in% argv) {
        cfg$gms$cm_quick_mode <- "on"
        cfg$gms$cm_iteration_max <- 1
    }
    message("\n", if (is.na(config.file)) cfg$title else scen)

    # configure cfg according to settings from csv if provided
    if (!is.na(config.file)) {
      cfg <- configure_cfg(cfg, scen, scenarios, settings)
      # set optimization mode to testOneRegi, if specified as command line argument
      if (any(c("--quick", "--testOneRegi") %in% argv)) {
        cfg$description      <- paste("testOneRegi:", cfg$description)
        cfg$gms$optimization <- "testOneRegi"
        cfg$output           <- NA
        # overwrite slurmConfig settings provided in scenario config file with those selected by user
        cfg$slurmConfig      <- slurmConfig
        if (testOneRegi_region != "") cfg$gms$c_testOneRegi_region <- testOneRegi_region
      }
      # Directly start runs that have a gdx file location given as path_gdx... or where this field is empty
      gdx_specified <- grepl(".gdx", cfg$files2export$start[path_gdx_list], fixed = TRUE)
      gdx_na <- is.na(cfg$files2export$start[path_gdx_list])
      start_now <- all(gdx_specified | gdx_na)
      if (start_now) {
        message("   Run can be started using ", sum(gdx_specified), " specified gdx file(s).")
        if (sum(gdx_specified) > 0) message("     ", paste0(path_gdx_list[gdx_specified], ": ", cfg$files2export$start[path_gdx_list][gdx_specified], collapse = "\n     "))
      }
    }

    if ("--debug" %in% argv) {
      cfg$gms$cm_nash_mode <- "debug"
      cfg$slurmConfig      <- slurmConfig
    }

    if (cfg$slurmConfig %in% c(NA, "")) {
      if(! exists("slurmConfig")) slurmConfig <- choose_slurmConfig()
      cfg$slurmConfig <- slurmConfig
    }

    # save the cfg object for the later automatic start of subsequent runs (after preceding run finished)
    filename <- paste0(cfg$title,".RData")
    message("   Writing cfg to file ", filename)
    save(cfg, file=filename)

    if (start_now){
      startedRuns <- startedRuns + 1
      # Create results folder and start run
      if (! '--test' %in% argv) {
        submit(cfg)
      } else {
        message("   If this wasn't --test mode, I would submit ", scen, ".")
      }
    } else {
       waitingRuns <- waitingRuns + 1
       message("   Waiting for: ", paste(unique(cfg$files2export$start[path_gdx_list][! gdx_specified & ! gdx_na]), collapse = ", "))
    }

    # print names of subsequent runs if there are any
    if (length(rownames(cfg$RunsUsingTHISgdxAsInput)) > 0) {
      message("   Subsequent runs: ", paste(rownames(cfg$RunsUsingTHISgdxAsInput), collapse = ", "))
    }

  }
}

message("\nFinished: ", startedRuns, " runs started. ", waitingRuns, " runs are waiting. ",
        if (modeltestRunsUsed > 0) paste0(modeltestRunsUsed, " GDX files from modeltests selected."))
if ('--test' %in% argv) {
  message("You are in --test mode. Rdata files were written, but no runs were started. ", ignorederrors, " errors were identified.")
} else if (model_was_locked & (! "--restart" %in% argv | "--reprepare" %in% argv)) {
  message("The model was locked before runs were started, so they will have to queue.")
}
