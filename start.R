#!/usr/bin/env Rscript
# |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
library(gms)
library(dplyr, warn.conflicts = FALSE)
library(lucode2)
require(stringr, quietly = TRUE)

helpText <- "
#' Rscript start.R [options] [file]
#'
#'    Without [file] argument starts a single REMIND run using the settings from
#'    `config/default.cfg` and `main.gms`.
#'
#'    [file] must be a scenario config .csv file (usually in the config/
#'    directory).  Using this will start all REMIND runs specified by
#'    \"start = 1\" in that file.
#'
#'    --help, -h:        show this help text and exit
#'    --debug, -d:       start a debug run with cm_nash_mode = debug
#'    --gamscompile, -g: compile gms of all selected runs. Combined with
#'                       --interactive, it stops in case of compilation errors,
#'                       allowing the user to fix them and rerun gamscompile;
#'                       combined with --restart, existing runs can be checked.
#'    --interactive, -i: interactively select config file and run(s) to be
#'                       started
#'    --quick, -q:       starting one fast REMIND run with one region, one
#'                       iteration and reduced convergence criteria for testing
#'                       the full model.
#'    --reprepare, -R:   rewrite full.gms and restart run
#'    --restart, -r:     interactively restart run(s)
#'    --test, -t:        test scenario configuration and writing the RData files
#'                       in the REMIND main folder without starting the runs
#'    --testOneRegi, -1: starting the REMIND run(s) in testOneRegi mode
#'
#'    You can combine --reprepare with --debug, --testOneRegi or --quick and the
#'    selected folders will be restarted using these settings.  Afterwards,
#'    using --reprepare alone will restart the runs using their original
#'    settings.
"
source("scripts/start/submit.R")
source("scripts/start/choose_slurmConfig.R")

############## Define function: select_testOneRegi_region #############
select_testOneRegi_region <- function() {
  message("\nWhich region should testOneRegi use? Type it, or leave empty to keep settings:\n",
  "Examples are CAZ, CHA, EUR, IND, JPN, LAM, MEA, NEU, OAS, REF, SSA, USA.")
  return(gms::getLine())
}

############## Define function: configure_cfg #########################

configure_cfg <- function(icfg, iscen, iscenarios, isettings, verboseGamsCompile = TRUE) {

    # Edit run title
    icfg$title <- iscen
    if (verboseGamsCompile) message("   Configuring cfg for ", iscen)

    # Edit main model file, region settings and input data revision based on scenarios table, if cell non-empty
    for (switchname in intersect(c("model", "regionmapping", "extramappings_historic", "action",
                                   "inputRevision", "slurmConfig", "results_folder", "force_replace"),
                                 names(iscenarios))) {
      if ( ! is.na(iscenarios[iscen, switchname] )) {
        icfg[[switchname]] <- iscenarios[iscen, switchname]
      }
    }
    if (icfg$slurmConfig %in% paste(seq(1:16)) & ! any(c("--debug", "--gamscompile", "--quick", "--testOneRegi") %in% flags)) {
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

    # Edit switches in config based on scenarios table, if cell non-empty
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

    if (verboseGamsCompile) {
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
            if (! any(c("--gamscompile", "--test") %in% flags)) stop(stoptext) else {
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
    }
    return(icfg)
}


# define arguments that are accepted
acceptedFlags <- c("0" = "--reset", "1" = "--testOneRegi", d = "--debug", g = "--gamscompile", i = "--interactive",
                   r = "--restart", R = "--reprepare", t = "--test", h = "--help", q = "--quick")
flags <- lucode2::readArgs(.flags = acceptedFlags, .silent = TRUE)

# initialize config.file
config.file <- NULL

# load command-line arguments
if(!exists("argv")) argv <- commandArgs(trailingOnly = TRUE)
argv <- argv[! grepl("^-", argv) & ! grepl("=", argv)]
# check if user provided any unknown arguments or config files that do not exist
if (length(argv) > 0) {
  file_exists <- file.exists(argv)
  if (sum(file_exists) > 1) stop("You provided two files, start.R can only handle one.")
  if (!all(file_exists)) stop("Unknown parameter provided: ", paste(argv[!file_exists], collapse = ", "))
  # set config file to not known parameter where the file actually exists
  config.file <- argv[[1]]
}

if ("--gamscompile" %in% flags) {
  dir.create(file.path("output", "gamscompile"), recursive = TRUE, showWarnings = FALSE)
  runGamsCompile <- function(modelFile, cfg, interactive = TRUE) {
    tmpModelFile <- file.path("output", "gamscompile", paste0("main_", cfg$title, ".gms"))
    file.copy(modelFile, tmpModelFile, overwrite = TRUE)
    manipulateConfig(tmpModelFile, cfg$gms)
    exitcode <- system2(
      command = cfg$gamsv,
      args = paste(tmpModelFile, "-o", gsub("gms$", "lst", tmpModelFile),
                   "-action=c -errmsg=1 -pw=132 -ps=0 -logoption=0"))
    if (0 < exitcode) {
      ignorederrors <<- ignorederrors + 1
      message("FAIL ", gsub("gms$", "lst", tmpModelFile))
      if (interactive) {
        system(paste("less -j 4 --pattern='^\\*\\*\\*\\*'",
                    gsub("gms$", "lst", tmpModelFile)))
        message("Do you want to rerun, because you fixed the error already? y/n")
        if (gms::getLine() %in% c("Y", "y")) {
          runGamsCompile(modelFile, cfg, interactive)
      }
      }
    } else {
      message("  OK ", gsub("gms$", "lst", tmpModelFile))
    }
  }
}

if ("--help" %in% flags) {
  message(gsub("#' ?", '', helpText))
  q()
}

if ("--reset" %in% flags) {
  message("The flag --reset does nothing anymore.")
  q()
}

if (any(c("--testOneRegi", "--debug", "--quick") %in% flags) & "--restart" %in% flags & ! "--reprepare" %in% flags) {
  message("\nIt is impossible to combine --restart with --debug, --quick or --testOneRegi because full.gms has to be rewritten.\n",
  "If this is what you want, use --reprepare instead, or answer with y:")
  if (gms::getLine() %in% c("Y", "y")) flags <- c(flags, "--reprepare")
}

# Check if dependencies for a model run are fulfilled
if (requireNamespace("piamenv", quietly = TRUE) && packageVersion("piamenv") >= "0.2.0") {
  piamenv::checkDeps(action = "ask")
} else {
  stop("REMIND requires piamenv >= 0.2.0, please run the following to update it:\n",
       "renv::install('piamenv'); renv::snapshot(prompt = FALSE)\n",
       "and re-run start.R in a fresh R session.")
}

if (   'TRUE' != Sys.getenv('ignoreRenvUpdates')
    && !getOption("autoRenvUpdates", FALSE)
    && !is.null(piamenv::showUpdates())) {
  message("Consider updating with `Rscript scripts/utils/updateRenv.R`.")
  Sys.sleep(1)
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
if (any(c("--reprepare", "--restart") %in% flags)) {
  # choose results folder from list
  searchforfile <- if ("--reprepare" %in% flags) "config.Rdata" else "full.gms"
  possibledirs <- basename(dirname(Sys.glob(file.path("output", "*", searchforfile))))
  # DK: The following outcommented lines are specially made for listing results of coupled runs
  # runs <- lucode2::findCoupledruns("./output/")
  # possibledirs <- sub("./output/", "", lucode2::findIterations(runs, modelpath = "./output", latest = TRUE))
  outputdirs <- gms::chooseFromList(sort(unique(possibledirs)), returnBoolean = FALSE,
                           type = paste0("runs to be re", ifelse("--reprepare" %in% flags, "prepared", "started")))
  if ("--gamscompile" %in% flags) {
    for (outputdir in outputdirs) {
      load(file.path("output", outputdir, "config.Rdata"))
      if (file.exists(file.path("output", outputdir, "main.gms"))) {
        runGamsCompile(file.path("output", outputdir, "main.gms"), cfg, interactive = "--interactive" %in% flags)
        startedRuns <- startedRuns + 1
      } else {
        message(file.path("output", outputdir, "main.gms"), " not found. Skipping this folder.")
      }
    }
  } else {
    message("\nAlso restart subsequent runs? Enter y, else leave empty:")
    restart_subsequent_runs <- gms::getLine() %in% c("Y", "y")
    if ("--testOneRegi" %in% flags) testOneRegi_region <- select_testOneRegi_region()
    filestomove <- c("abort.gdx" = "abort_beforeRestart.gdx",
                     "non_optimal.gdx" = "non_optimal_beforeRestart.gdx",
                     "log.txt" = "log_beforeRestart.txt",
                     if ("--reprepare" %in% flags) c("full.gms" = "full_beforeRestart.gms",
                                                     "fulldata.gdx" = "fulldata_beforeRestart.gdx")
                    )
    message("\n", paste(names(filestomove), collapse = ", "), " will be moved and get a postfix '_beforeRestart'.\n")
    if(! exists("slurmConfig")) slurmConfig <- choose_slurmConfig()
    if ("--quick" %in% flags) slurmConfig <- paste(slurmConfig, "--time=60")
    message()
    for (outputdir in outputdirs) {
      message("Restarting ", outputdir)
      load(file.path("output", outputdir, "config.Rdata")) # read config.Rdata from results folder
      cfg$restart_subsequent_runs <- restart_subsequent_runs
      # for debug, testOneRegi, quick: save original settings to cfg$backup; restore them from there if not set.
      if ("--debug" %in% flags) {
        if (is.null(cfg[["backup"]][["cm_nash_mode"]])) cfg$backup$cm_nash_mode <- cfg$gms$cm_nash_mode
        cfg$gms$cm_nash_mode <- "debug"
      } else {
        if (! is.null(cfg[["backup"]][["cm_nash_mode"]])) cfg$gms$cm_nash_mode <- cfg$backup$cm_nash_mode
      }
      cfg$gms$cm_quick_mode <- if ("--quick" %in% flags) "on" else "off"
      if (any(c("--quick", "--testOneRegi") %in% flags)) {
        if (is.null(cfg[["backup"]][["optimization"]])) cfg$backup$optimization <- cfg$gms$optimization
        cfg$gms$optimization <- "testOneRegi"
        if (testOneRegi_region != "") cfg$gms$c_testOneRegi_region <- testOneRegi_region
      } else {
        if (! is.null(cfg[["backup"]][["optimization"]])) cfg$gms$optimization <- cfg$backup$optimization
      }
      if ("--quick" %in% flags) {
        if (is.null(cfg[["backup"]][["cm_iteration_max"]])) cfg$backup$cm_iteration_max <- cfg$gms$cm_iteration_max
        cfg$gms$cm_iteration_max <- 1
      } else {
        if (! is.null(cfg[["backup"]][["cm_iteration_max"]])) cfg$gms$cm_iteration_max <- cfg$backup$cm_iteration_max
      }
      if (! "--test" %in% flags) {
        filestomove_exists <- file.exists(file.path("output", outputdir, names(filestomove)))
        file.rename(file.path("output", outputdir, names(filestomove[filestomove_exists])),
                    file.path("output", outputdir, filestomove[filestomove_exists]))
      }
      cfg$slurmConfig <- combine_slurmConfig(cfg$slurmConfig, slurmConfig) # update the slurmConfig setting to what the user just chose
      cfg$remind_folder <- getwd()                      # overwrite remind_folder: run to be restarted may have been moved from other repository
      cfg$results_folder <- paste0("output/",outputdir) # overwrite results_folder in cfg with name of the folder the user wants to restart, because user might have renamed the folder before restarting
      save(cfg,file=paste0("output/",outputdir,"/config.Rdata"))
      startedRuns <- startedRuns + 1
      if (! '--test' %in% flags) {
        submit(cfg, restart = TRUE)
      } else {
        message("   If this wasn't --test mode, I would have restarted ", cfg$title, ".")
      }
    }
  }

} else {

  if (is.null(config.file) & "--interactive" %in% flags) {
    possiblecsv <- Sys.glob(c(file.path("./config/scenario_config*.csv"), file.path("./config","*","scenario_config*.csv")))
    possiblecsv <- possiblecsv[! grepl(".*scenario_config_coupled.*csv$", possiblecsv)]
    config.file <- gms::chooseFromList(possiblecsv, type = "one config file", returnBoolean = FALSE, multiple = FALSE)
  }
  if (all(c("--testOneRegi", "--interactive") %in% flags)) testOneRegi_region <- select_testOneRegi_region()

  ###################### Load csv if provided  ###########################

  # If a scenario_config.csv file was provided, set cfg according to it.

  if (! length(config.file) == 0) {
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
    cfg <- readDefaultConfig(".")
    knownColumnNames <- c(names(cfg$gms), names(path_gdx_list), "start", "output", "description", "model",
                          "regionmapping", "extramappings_historic", "inputRevision", "slurmConfig", "results_folder",
                          "force_replace", "action")
    unknownColumnNames <- names(settings)[! names(settings) %in% knownColumnNames]
    if (length(unknownColumnNames) > 0) {
      message("\nAutomated checks did not find counterparts in default.cfg or main.gms for these config file columns:")
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
    if ("--interactive" %in% flags | ! any(settings$start == 1)) {
      settings$start <- gms::chooseFromList(setNames(rownames(settings), settings$start), type = "runs", returnBoolean = TRUE) * 1 # all with '1' will be started
    }
    scenarios <- settings[settings$start == 1, ]
    if (any(nchar(rownames(scenarios)) > 75)) stop(paste0("These titles are too long: ", paste0(rownames(scenarios)[nchar(rownames(scenarios)) > 75], collapse = ", "), " – GAMS would not tolerate this, and quit working at a point where you least expect it. Stopping now."))
    if (length(grep("\\.", rownames(scenarios))) > 0) stop(paste0("These titles contain dots: ", paste0(rownames(scenarios)[grep("\\.", rownames(scenarios))], collapse = ", "), " – GAMS would not tolerate this, and quit working at a point where you least expect it. Stopping now."))
    if (length(grep("_$", rownames(scenarios))) > 0) stop(paste0("These titles end with _: ", paste0(rownames(scenarios)[grep("_$", rownames(scenarios))], collapse = ", "), ". This may lead start.R to select wrong gdx files. Stopping now."))
  } else {
    # if no csv was provided create dummy list with default/testOneRegi as the only scenario
    if (any(c("--quick", "--testOneRegi") %in% flags)) {
      scenarios <- data.frame("testOneRegi" = "testOneRegi", row.names = "testOneRegi")
    } else {
      scenarios <- data.frame("default" = "default", row.names = "default")
    }
  }

  ###################### Loop over scenarios ###############################

  # ask for slurmConfig if not specified for every run
  if ("--gamscompile" %in% flags) {
    slurmConfig <- "direct"
    message("\nTrying to compile the selected runs...")
    lockID <- gms::model_lock()
  }
  if (! exists("slurmConfig") & (any(c("--debug", "--quick", "--testOneRegi") %in% flags) | ! "slurmConfig" %in% names(scenarios) || any(is.na(scenarios$slurmConfig)))) {
    slurmConfig <- choose_slurmConfig()
    if ("--quick" %in% flags) slurmConfig <- paste(slurmConfig, "--time=60")
    if (any(c("--debug", "--quick", "--testOneRegi") %in% flags) && ! length(config.file) == 0) {
      message("\nYour slurmConfig selection will overwrite the settings in your scenario_config file.")
    }
  }

  # Modify and save cfg for all runs
  for (scen in rownames(scenarios)) {

    #source cfg file for each scenario to avoid duplication of gdx entries in files2export
    cfg <- readDefaultConfig(".")

    # Have the log output written in a file (not on the screen)
    cfg$logoption   <- 2
    start_now       <- TRUE

    # testOneRegi settings
    if (any(c("--quick", "--testOneRegi") %in% flags) & length(config.file) == 0) {
      cfg$title            <- "testOneRegi"
      cfg$description      <- "A REMIND run with default settings using testOneRegi"
      cfg$gms$optimization <- "testOneRegi"
      cfg$output           <- NA
      cfg$results_folder   <- "output/testOneRegi"
      # delete existing Results directory
      cfg$force_replace    <- TRUE
      if (testOneRegi_region != "") cfg$gms$c_testOneRegi_region <- testOneRegi_region
    }
    if ("--quick" %in% flags) {
        cfg$gms$cm_quick_mode <- "on"
        cfg$gms$cm_iteration_max <- 1
    }
    if (! "--gamscompile" %in% flags || "--interactive" %in% flags) {
      message("\n", if (length(config.file) == 0) cfg$title else scen)
    }

    # configure cfg according to settings from csv if provided
    if (! length(config.file) == 0) {
      cfg <- configure_cfg(cfg, scen, scenarios, settings,
                           verboseGamsCompile = ! "--gamscompile" %in% flags || "--interactive" %in% flags)
      # set optimization mode to testOneRegi, if specified as command line argument
      if (any(c("--quick", "--testOneRegi") %in% flags)) {
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
      if (start_now && (! "--gamscompile" %in% flags || "--interactive" %in% flags)) {
        message("   Run can be started using ", sum(gdx_specified), " specified gdx file(s).")
        if (sum(gdx_specified) > 0) message("     ", paste0(path_gdx_list[gdx_specified], ": ", cfg$files2export$start[path_gdx_list][gdx_specified], collapse = "\n     "))
      }
    }

    if ("--debug" %in% flags) {
      cfg$gms$cm_nash_mode <- "debug"
      cfg$slurmConfig      <- slurmConfig
    }

    if (cfg$slurmConfig %in% c(NA, "")) {
      if(! exists("slurmConfig")) slurmConfig <- choose_slurmConfig()
      cfg$slurmConfig <- slurmConfig
    }
    # save the cfg object for the later automatic start of subsequent runs (after preceding run finished)

    if (! "--gamscompile" %in% flags) {
      filename <- paste0(cfg$title,".RData")
      message("   Writing cfg to file ", filename)
      save(cfg, file=filename)
    }
    startedRuns <- startedRuns + start_now
    waitingRuns <- waitingRuns + 1 - start_now
    if ("--test" %in% flags) {
      message("   If this wasn't --test mode, I would submit ", scen, ".")
    } else if ("--gamscompile" %in% flags) {
      runGamsCompile(if (is.null(cfg$model)) "main.gms" else cfg$model, cfg, interactive = "--interactive" %in% flags)
    } else if (start_now) {
      submit(cfg)
    }
    # print names of runs to be waited and subsequent runs if there are any
    if (! start_now && ( ! "--gamscompile" %in% flags || "--interactive" %in% flags)) {
      message("   Waiting for: ", paste(unique(cfg$files2export$start[path_gdx_list][! gdx_specified & ! gdx_na]), collapse = ", "))
    }
    if (length(rownames(cfg$RunsUsingTHISgdxAsInput)) > 0) {
      message("   Subsequent runs: ", paste(rownames(cfg$RunsUsingTHISgdxAsInput), collapse = ", "))
    }
  }
  message("")
  if (exists("lockID")) gms::model_unlock(lockID)
}

message("\nFinished: ", startedRuns, " runs started. ", waitingRuns, " runs are waiting. ",
        if (modeltestRunsUsed > 0) paste0(modeltestRunsUsed, " GDX files from modeltests selected."))
if ("--gamscompile" %in% flags) {
  message("To investigate potential FAILs, run: less -j 4 --pattern='^\\*\\*\\*\\*' filename.lst")
} else if ("--test" %in% flags) {
  message("You are in --test mode: Rdata files were written, but no runs were started. ", ignorederrors, " errors were identified.")
} else if (model_was_locked & (! "--restart" %in% flags | "--reprepare" %in% flags)) {
  message("The model was locked before runs were started, so they will have to queue.")
}

# make sure we have a non-zero exit status if there were any errors
if (0 < ignorederrors) {
  stop(ignorederrors, " errors were identified, check logs above for details.")
}
