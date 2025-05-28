#!/usr/bin/env Rscript
# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
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
#' Without [file] argument starts a single REMIND run using the settings from
#' config/default.cfg` and `main.gms`.
#'
#' [file] must be a scenario config .csv file (usually in the config/
#' directory).  Using this will start all REMIND runs specified by
#' \"start = 1\" in that file (check the startgroup option to start a specific
#' group).
#'
#'   --help, -h:         show this help text and exit
#'   --debug, -d:        start a debug run with cm_nash_mode = debug
#'   --gamscompile, -g:  compile gms of all selected runs. Combined with
#'                       --interactive, it stops in case of compilation errors,
#'                       allowing the user to fix them and rerun gamscompile;
#'                       combined with --restart, existing runs can be checked.
#'   --interactive, -i:  interactively select config file and run(s) to be
#'                       started
#'   --quick, -q:        starting one fast REMIND run with one region, one
#'                       iteration and reduced convergence criteria for testing
#'                       the full model.
#'   --reprepare, -R:    rewrite full.gms and restart run
#'   --restart, -r:      interactively restart run(s)
#'   --test, -t:         test scenario configuration without starting the runs
#'   --testOneRegi, -1:  starting the REMIND run(s) in testOneRegi mode
#'   startgroup=MYGROUP  when reading a scenario config .csv file, don't start
#'                       everything specified by \"start = 1\", instead start everything
#'                       specified by \"start = MYGROUP\". Use startgroup=* to start all.
#'   titletag=MYTAG      append \"-MYTAG\" to all titles of all runs that are started
#'   slurmConfig=CONFIG  use the provided CONFIG as slurmConfig: a string, or an integer <= 16
#'                       to select one of the options shown when running './start.R -t'.
#'                       CONFIG is used only for scenarios where no slurmConfig
#'                       is specified in the scenario config csv file, or
#'                       for all scenarios if --debug, --quick or --testOneRegi is used.
#'
#' You can combine --reprepare with --debug, --testOneRegi or --quick and the
#' selected folders will be restarted using these settings.  Afterwards,
#' using --reprepare alone will restart the runs using their original
#' settings.
"

# Source everything from scripts/start so that all functions are available everywhere
invisible(sapply(list.files("scripts/start", pattern = "\\.R$", full.names = TRUE), source))


# define arguments that are accepted
acceptedFlags <- c("0" = "--reset", "1" = "--testOneRegi", d = "--debug", g = "--gamscompile", i = "--interactive",
                   r = "--restart", R = "--reprepare", t = "--test", h = "--help", q = "--quick")
startgroup <- "1"
flags <- lucode2::readArgs("startgroup", "titletag", "slurmConfig", .flags = acceptedFlags, .silent = TRUE)
if ("--test" %in% flags) {
  slurmConfig <- choose_slurmConfig(identifier = "1")
 } else if (exists("slurmConfig") && slurmConfig %in% paste(seq(1:16))) {
  slurmConfig <- choose_slurmConfig(identifier = slurmConfig)
}

# initialize config.file
config.file <- NULL

# load command-line arguments
if(!exists("argv")) argv <- commandArgs(trailingOnly = TRUE)
argv <- argv[! grepl("^-", argv) & ! grepl("=", argv)]
# check if user provided any unknown arguments or config files that do not exist
if (length(argv) == 1) {
  config.file <- argv
  if (! file.exists(config.file)) config.file <- file.path("config", argv)
  if (! file.exists(config.file)) config.file <- file.path("config", paste0("scenario_config_", argv, ".csv"))
  if (! file.exists(config.file)) stop("Unknown parameter provided: ", paste(argv, collapse = ", "))
} else if (length(argv) > 1) {
  stop("You provided more than one file or other command line argument, start.R can only handle one: ",
       paste(argv, collapse = ", "))
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

ensureRequirementsInstalled()

if (   'TRUE' != Sys.getenv('ignoreRenvUpdates')
    && !getOption("autoRenvUpdates", FALSE)
    && !is.null(piamenv::showUpdates())) {
  message("Consider updating with `piamenv::updateRenv()`.")
  Sys.sleep(1)
}

# initialize madrat settings
invisible(madrat::getConfig(verbose = FALSE))

errorsfound <- 0 # counts ignored errors in --test mode
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
        gcresult <- runGamsCompile(file.path("output", outputdir, "main.gms"), cfg, interactive = "--interactive" %in% flags)
        errorsfound <- errorsfound + ! gcresult
        startedRuns <- startedRuns + 1
      } else {
        message(file.path("output", outputdir, "main.gms"), " not found. Skipping this folder.")
      }
    }
  } else {
    message("\nAlso restart subsequent runs? Enter y, else leave empty:")
    restart_subsequent_runs <- gms::getLine() %in% c("Y", "y")
    if ("--testOneRegi" %in% flags) testOneRegi_region <- selectTestOneRegiRegion()
    filestomove <- c("abort.gdx" = "abort_beforeRestart.gdx",
                     "non_optimal.gdx" = "non_optimal_beforeRestart.gdx",
                     "log.txt" = "log_beforeRestart.txt",
                     "full.lst" = "full_beforeRestart.lst",
                     if ("--reprepare" %in% flags) c("full.gms" = "full_beforeRestart.gms",
                                                     "fulldata.gdx" = "fulldata_beforeRestart.gdx")
                    )
    message("\n", paste(names(filestomove), collapse = ", "), " will be moved and get a postfix '_beforeRestart'.\n")
    if(! exists("slurmConfig")) {
      slurmConfig <- choose_slurmConfig(flags = flags)
    }
    if ("--quick" %in% flags && ! slurmConfig == "direct") slurmConfig <- combine_slurmConfig(slurmConfig, "--time=60")
    message()
    for (outputdir in outputdirs) {
      message("Restarting ", outputdir)
      load(file.path("output", outputdir, "config.Rdata")) # read config.Rdata from results folder
      cfg$restart_subsequent_runs <- restart_subsequent_runs
      # for debug, testOneRegi, quick: save original settings to cfg$backup; restore them from there if not set.
      if ("--debug" %in% flags) {
        if (is.null(cfg[["backup"]][["cm_nash_mode"]])) cfg$backup$cm_nash_mode <- cfg$gms$cm_nash_mode
        cfg$gms$cm_nash_mode <- 1
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
  if (all(c("--testOneRegi", "--interactive") %in% flags)) testOneRegi_region <- selectTestOneRegiRegion()

  ###################### Load csv if provided  ###########################

  # If a scenario_config.csv file was provided, set cfg according to it.

  if (! length(config.file) == 0) {
    cat(paste("\nReading config file", config.file, "\n"))

    # Read-in the switches table, use first column as row names
    settings <- readCheckScenarioConfig(config.file, ".")
    scenarios <- selectScenarios(settings = settings, interactive = "--interactive" %in% flags, startgroup = startgroup)
  } else {
    # if no csv was provided create dummy list with default/testOneRegi as the only scenario
    if (any(c("--quick", "--testOneRegi") %in% flags)) {
      scenarios <- data.frame("testOneRegi" = "testOneRegi", row.names = "testOneRegi")
    } else {
      scenarios <- data.frame("default" = "default", row.names = "default")
    }
  }

  # Append titletag to scenario names in the scenario title and titles of reference scenarios
  if (exists("titletag")) {
    scenarios <- addTitletag(titletag = titletag, scenarios = scenarios)
  }

  ###################### Loop over scenarios ###############################

  # ask for slurmConfig if not specified for every run
  if ("--gamscompile" %in% flags) {
    slurmConfig <- "direct"
    message("\nTrying to compile ", nrow(scenarios), " selected runs...")
    lockID <- gms::model_lock()
    if (length(missingInputData()) > 0) {
      # try to fix missing input data, but only once at the beginning, not for every scenario
      updateInputData(readDefaultConfig("."), remindPath = ".", gamsCompile = FALSE)
    }
  }
  if (! exists("slurmConfig") & (any(c("--debug", "--quick", "--testOneRegi") %in% flags)
      | ! "slurmConfig" %in% names(scenarios) || any(is.na(scenarios$slurmConfig)))) {
    slurmConfig <- choose_slurmConfig(flags = flags)
    if ("--quick" %in% flags && ! slurmConfig == "direct") slurmConfig <- combine_slurmConfig(slurmConfig, "--time=60")
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
      cfg$title            <- scen
      cfg$description      <- "A REMIND run with default settings using testOneRegi"
      cfg$gms$optimization <- "testOneRegi"
      cfg$output           <- NA
      cfg$results_folder   <- paste0("output/", cfg$title)
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
      cfg <- configureCfg(cfg, scen, scenarios,
                          verboseGamsCompile = ! "--gamscompile" %in% flags || "--interactive" %in% flags)
      errorsfound <- sum(errorsfound, cfg$errorsfoundInConfigureCfg)
      cfg$errorsfoundInConfigureCfg <- NULL
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
      cfg$gms$cm_nash_mode <- 1
      cfg$slurmConfig      <- slurmConfig
    }

    if (cfg$slurmConfig %in% c(NA, "")) {
      if(! exists("slurmConfig")) slurmConfig <- choose_slurmConfig(flags = flags)
      cfg$slurmConfig <- slurmConfig
    }

    # abort on too long paths ----
    cfg$gms$cm_CES_configuration <- calculate_CES_configuration(cfg, check = TRUE)

    cfg <- checkFixCfg(cfg, testmode = "--test" %in% flags)
    if ("errorsfoundInCheckFixCfg" %in% names(cfg)) {
      errorsfound <- errorsfound + cfg$errorsfoundInCheckFixCfg
    }

    # save the cfg object for the later automatic start of subsequent runs (after preceding run finished)
    if (! any(c("--test", "--gamscompile") %in% flags)) {
      filename <- paste0(cfg$title,".RData")
      message("   Writing cfg to file ", filename)
      save(cfg, file=filename)
    }
    startedRuns <- startedRuns + start_now
    waitingRuns <- waitingRuns + 1 - start_now
    if ("--test" %in% flags && start_now) {
      message("   If this wasn't --test mode, I would submit ", scen, ".")
    } else if ("--gamscompile" %in% flags) {
      gcresult <- runGamsCompile(if (is.null(cfg$model)) "main.gms" else cfg$model, cfg, interactive = "--interactive" %in% flags)
      errorsfound <- errorsfound + ! gcresult
    } else if (start_now) {
      if (errorsfound == 0) {
        submit(cfg)
      } else {
        message("   Not started, as errors were found.")
      }
    }
    # print names of runs to be waited and subsequent runs if there are any
    if (! "--gamscompile" %in% flags || "--interactive" %in% flags) {
      if (! start_now) {
        message("   Waiting for: ", paste(unique(cfg$files2export$start[path_gdx_list][! gdx_specified & ! gdx_na]), collapse = ", "))
      }
      if (length(rownames(cfg$RunsUsingTHISgdxAsInput)) > 0) {
        message("   Subsequent runs: ", paste(rownames(cfg$RunsUsingTHISgdxAsInput), collapse = ", "))
      }
    }
  }
  message("")
  if (exists("lockID")) gms::model_unlock(lockID)
}

warnings()

message("\nFinished: ", startedRuns, " runs started. ", waitingRuns, " runs are waiting. ",
        if (modeltestRunsUsed > 0) paste0(modeltestRunsUsed, " GDX files from modeltests selected."))
if ("--gamscompile" %in% flags) {
  message("To investigate potential FAILs, run: less -j 4 --pattern='^\\*\\*\\*\\*' filename.lst")
} else if ("--test" %in% flags) {
  message("You are in --test mode: no runs were started. ", errorsfound, " errors were identified.")
} else if (model_was_locked & (! "--restart" %in% flags | "--reprepare" %in% flags)) {
  message("The model was locked before runs were started, so they will have to queue.")
}

# make sure we have a non-zero exit status if there were any errors
if (0 < errorsfound) {
  stop(errorsfound, " errors were identified, check logs above for details.")
}
