# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

##################################################################
################# D E F I N E  start_coupled #####################
##################################################################

start_coupled <- function(path_remind, path_magpie, cfg_rem, cfg_mag, runname, max_iterations = 5, start_iter = 1,
                          n600_iterations = 0, report = NULL, qos, fullrunname = FALSE,
                          prefix_runname = "C_", run_compareScenarios = TRUE, magpie_empty = FALSE) {
  require(lucode2)
  require(gms)
  require(magclass)
  require(gdx)
  library(methods)
  library(remind2)
  source("scripts/start/combine_slurmConfig.R")

  errorsfound <- 0
  # delete entries in stack that contain needle and append new
  .setgdxcopy <- function(needle,stack,new){
    matches <- grepl(needle,stack)
    out <- c(stack[!matches],new)
    return(out)
  }

  mainwd <- getwd() # save folder in which this script is executed

  # Retrieve REMIND settings
#  cfg_rem <- check_config(cfg_rem, file.path(path_remind, "config", "default.cfg"), file.path(path_remind, "modules"),
#                          extras = c("backup", "remind_folder", "pathToMagpieReport", "cm_nash_autoconverge_lastrun",
#                                     "gms$c_expname", "restart_subsequent_runs", "gms$c_GDPpcScen",
#                                     "gms$cm_CES_configuration", "gms$c_description"))
  cfg_rem$slurmConfig   <- "direct"
  cfg_rem_original <- c(setdiff(cfg_rem$output, "emulator"), "emulator") # save default remind output config and add "emulator" if missing

  # retrieve MAgPIE settings
  cfg_mag <- check_config(cfg_mag, file.path(path_magpie, "config", "default.cfg"), file.path(path_magpie,"modules"))
  cfg_mag$sequential <- TRUE
  cfg_mag$force_replace <- TRUE
  cfg_mag$output     <- c("rds_report") # ,"remind","report") # rds_report: MAgPIE4; remind,report: MAgPIE3 (glo.modelstat.csv)
  # if provided use ghg prices for land (MAgPIE) from a different REMIND run than the one MAgPIE runs coupled to
  use_external_ghgprices <- ifelse(is.na(cfg_mag$path_to_report_ghgprices), FALSE, TRUE)

  if (start_iter > max_iterations) stop("### COUPLING ### start_iter > max_iterations")

  possible_pathes_to_gdx <- c("input.gdx", "input_ref.gdx", "input_refpolicycost.gdx",
                              "input_bau.gdx", "input_carbonprice.gdx")

  startIterations <- c(start_iter)

  # Start REMIND and MAgPIE iteratively
  for (i in startIterations) {
    message("### COUPLING ### Iteration ", i)

    ##################################################################
    #################### R E M I N D #################################
    ##################################################################

    ####################### PREPARE REMIND ###########################

    message("### COUPLING ### Preparing REMIND")
    message("### COUPLING ### Set working directory from ", getwd())
    setwd(path_remind)
    message("                                         to ", getwd(), "\n")
    source("scripts/start/submit.R") # provide source of "get_magpie_data" and "start_run"

    cfg_rem$results_folder <- paste0("output/",runname,"-rem-",i)
    cfg_rem$title          <- paste0(runname,"-rem-",i)
    
    # Switch off generation of needless output for all but the last REMIND iteration
    output_all_iter <- c("reporting", "reportingREMIND2MAgPIE", "emulator", "rds_report", "fixOnRef", "checkProjectSummations")
    if (i < max_iterations) {
      cfg_rem$output <- intersect(cfg_rem_original, output_all_iter)
    } else {
      cfg_rem$output <- cfg_rem_original
    }

    ############ DECIDE IF AND HOW TO START REMIND ###################
    outfolder_rem <- NULL
    if (is.null(report)) {
      if (i == 1) {
        ######### S T A R T   R E M I N D   S T A N D A L O N E ##############
        cfg_rem$gms$cm_MAgPIE_coupling <- "off"
        message("### COUPLING ### No MAgPIE report for REMIND input provided.")
        message("### COUPLING ### REMIND will be started in stand-alone mode with\n    ", runname, "\n    ", cfg_rem$results_folder)
        outfolder_rem <- submit(cfg_rem, stopOnFolderCreateError = FALSE)
      } else {
        stop("I'm in coupling iteration ", i, ", but no REMIND or MAgPIE report from earlier iterations found. That should never have happened.")
      }
    } else if (grepl(paste0("report.mif"), report)) { # if it is a MAgPIE report
      ######### S T A R T   R E M I N D   C O U P L E D ##############
      cfg_rem$gms$cm_MAgPIE_coupling <- "on"
      if (!file.exists(report)) stop(paste0("### COUPLING ### Could not find report: ", report,"\n"))
      message("### COUPLING ### Starting REMIND in coupled mode with\n    Report = ", report, "\n    Folder = ", cfg_rem$results_folder)
      # Keep path to MAgPIE report in mind to have it available after the coupling loop
      mag_report_keep_in_mind <- report
      cfg_rem$pathToMagpieReport <- report
      outfolder_rem <- submit(cfg_rem, stopOnFolderCreateError = FALSE)
      ############################
    } else if (grepl("REMIND_generic_",report)) { # if it is a REMIND report
      ############### O M I T   R E M I N D  ###############################
      message("### COUPLING ### Omitting REMIND in this iteration\n    Report = ", report)
      report <- report
    } else {
      stop(paste0("### COUPLING ### Could not decide whether ",report," is REMIND or MAgPIE output.\n"))
    }

    if(!is.null(outfolder_rem)) {
      report    <- file.path(path_remind, outfolder_rem, paste0("REMIND_generic_", cfg_rem$title, ".mif"))
      message("### COUPLING ### REMIND output was stored in ", outfolder_rem)
      if (file.exists(paste0(outfolder_rem,"/fulldata.gdx"))) {
        modstat <- readGDX(paste0(outfolder_rem,"/fulldata.gdx"),types="parameters",format="raw",c("s80_bool","o_modelstat"))
        if (cfg_rem$gms$optimization == "negishi") {
          if (as.numeric(modstat$o_modelstat$val)!=2 && as.numeric(modstat$o_modelstat$val)!=7) stop("Iteration stopped! REMIND o_modelstat was ",modstat," but is required to be 2 or 7.\n")
        } else if (cfg_rem$gms$optimization == "nash") {
          if (as.numeric(modstat$s80_bool$val)!=1) message("Warning: REMIND s80_bool not 1. Iteration continued though.")
        }
      } else if (file.exists(paste0(outfolder_rem,"/non_optimal.gdx"))) {
        stop("### COUPLING ### REMIND didn't find an optimal solution. Coupling iteration stopped!")
      } else {
        stop("### COUPLING ### REMIND didn't produce any gdx. Coupling iteration stopped!")
      }

      # In the coupling, at the end of each REMIND run, report.R already automatically appends the MAgPIE
      # report of the previous MAgPIE run to the normal REMIND_generic reporting.
      # After the last coupling iteration: read this combined report from the REMIND output folder, set the 
      # model name to 'REMIND-MAgPIE' and write the combined report directly to the 'output' folder.
      report_rem <- file.path(path_remind, outfolder_rem, paste0("REMIND_generic_", cfg_rem$title, ".mif"))
      if (i == max_iterations) {
        # Replace REMIND and MAgPIE with REMIND-MAgPIE and write directly to output folder
        tmp_rem_mag <- quitte::as.quitte(report_rem)
        tmp_rem_mag$model <- "REMIND-MAgPIE"
        tmp_rem_mag$scenario <- runname
        quitte::write.mif(tmp_rem_mag, path = file.path("output", paste0(runname, ".mif")))
        message("\n### output/", runname, ".mif written: model='REMIND-MAgPIE', scenario='", runname, "'.")
      }
    }

    if (!file.exists(report)) stop(paste0("### COUPLING ### Could not find report: ", report,"\n"))

    # If in the last iteration don't run MAgPIE
    if (i == max_iterations) {
      report_mag <- mag_report_keep_in_mind
      break
    }

    ##################################################################
    #################### M A G P I E #################################
    ##################################################################
    message("### COUPLING ### Preparing MAgPIE")
    message("### COUPLING ### Set working directory from ", getwd())
    setwd(path_magpie)
    message("                                         to ", getwd(), "\n")
    source("scripts/start_functions.R")
    cfg_mag$results_folder <- paste0("output/",runname,"-mag-",i)
    cfg_mag$title          <- paste0(runname,"-mag-",i)
    if (!is.null(renv::project())) {
      cfg_mag$renv_lock <- normalizePath(file.path(path_remind, cfg_rem$results_folder, "renv.lock"))
    }

    if (magpie_empty) {
      # Find latest fulldata.gdx from automated model test (AMT) runs
      amtRunDirs <- list.files("/p/projects/landuse/tests/magpie/output",
                              pattern = "default_\\d{4}-\\d{2}-\\d{2}_\\d{2}\\.\\d{2}.\\d{2}",
                              full.names = TRUE)
      fullDataGdxs <- file.path(amtRunDirs, "fulldata.gdx")
      latestFullData <- sort(fullDataGdxs[file.exists(fullDataGdxs)], decreasing = TRUE)[[1]]
      cfg_mag <- configureEmptyModel(cfg_mag, latestFullData)  # defined in start_functions.R
      # also configure magpie to only run the reportings necessary for coupling
      # the other reportings are pointless anyway with an empty model
      cfg_mag$output <- c("extra/reportMAgPIE2REMIND")
    }

    # Increase MAgPIE resolution n600_iterations before final iteration so that REMIND
    # runs n600_iterations iterations using results from MAgPIE with higher resolution
    if (i > (max_iterations - n600_iterations)) {
      message("Current iteration: ", i, ". Setting MAgPIE to n600\n")
      cfg_mag <- setScenario(cfg_mag, "n600", scenario_config = paste0("config/scenario_config.csv"))
    }

    # Providing MAgPIE with gdx from last iteration's solution only for time steps >= cfg_rem$gms$cm_startyear
    # For years prior to cfg_rem$gms$cm_startyear MAgPIE output has to be identical across iterations.
    # Because gdxes might slightly lead to a different solution exclude gdxes for the fixing years.
    if (i > 1) {
      message("### COUPLING ### Copying gdx files from previous iteration")
      gdxlist <- paste0("output/", runname, "-mag-", i-1, "/magpie_y", seq(cfg_rem$gms$cm_startyear,2150,5), ".gdx")
      cfg_mag$files2export$start <- .setgdxcopy(".gdx",cfg_mag$files2export$start,gdxlist)
    }

    message("### COUPLING ### MAgPIE will be started with\n    Report = ", report, "\n    Folder = ", cfg_mag$results_folder)
    cfg_mag$path_to_report_bioenergy <- report
    # if no different mif was set for GHG prices use the same as for bioenergy
    if(! use_external_ghgprices) cfg_mag$path_to_report_ghgprices <- report
    ########### START MAGPIE #############
    outfolder_mag <- start_run(cfg_mag, codeCheck=FALSE)
    ######################################
    message("### COUPLING ### MAgPIE output was stored in ", outfolder_mag)
    report_mag <- file.path(path_magpie, outfolder_mag, "report.mif")
    report <- report_mag

    # Checking whether MAgPIE is optimal in all years
    file_modstat <- file.path(outfolder_mag, "glo.magpie_modelstat.csv")
    if (file.exists(file_modstat)) {
      modstat_mag <- read.csv(file_modstat, stringsAsFactors = FALSE, row.names=1, na.strings="")
    } else {
      modstat_mag <- readGDX(file.path(outfolder_mag, "fulldata.gdx"), "p80_modelstat", "o_modelstat", format="first_found")
    }

    if (!all((modstat_mag == 2) | (modstat_mag == 7)))
      stop("Iteration stopped! MAgPIE modelstat is not 2 or 7 for all years.\n")

  } # End of coupling iteration loop

  message("### COUPLING ### Coupling iteration ", i, "/", max_iterations, " completed");
  message("### COUPLING ### Set working directory from ", getwd());
  setwd(mainwd)
  message("                                         to ", getwd(), "\n")

  if (length(rownames(cfg_rem$RunsUsingTHISgdxAsInput)) > 0) {
    # fulldatapath may be written into gdx paths of subsequent runs
    fulldatapath <- file.path(path_remind, cfg_rem$results_folder, "fulldata.gdx")

    # Loop possible subsequent runs, saving path to fulldata.gdx of current run (== cfg_rem$title) to their cfg files

    for (run in rownames(cfg_rem$RunsUsingTHISgdxAsInput)) {

      message("\nPrepare subsequent run ", run, ":")
      subseq.env <- new.env()
      RData_file <- paste0(run, ".RData")
      load(RData_file, envir = subseq.env)

      pathes_to_gdx <- intersect(possible_pathes_to_gdx, names(subseq.env$cfg_rem$files2export$start))

      gdx_na <- is.na(subseq.env$cfg_rem$files2export$start[pathes_to_gdx])

      needfulldatagdx <- names(subseq.env$cfg_rem$files2export$start[pathes_to_gdx][subseq.env$cfg_rem$files2export$start[pathes_to_gdx] == fullrunname & !gdx_na])
      message("In ", RData_file, ", use current fulldata.gdx path for ", paste(needfulldatagdx, collapse = ", "), ".")
      subseq.env$cfg_rem$files2export$start[needfulldatagdx] <- fulldatapath
      # let the subsequent run use the renv.lock of this run
      message("In ", RData_file, ", use current renv.lock for subsequent run ", run, ".")
      subseq.env$cfg_rem$renvLockFromPrecedingRun <- file.path(path_remind, cfg_rem$results_folder, "renv.lock")

      if (isTRUE(subseq.env$path_report == runname)) subseq.env$path_report <- report_mag
      save(list = ls(subseq.env), file = RData_file, envir = subseq.env)

      # Subsequent runs will be started using submit.R, if all necessary gdx files were generated
      gdx_exist <- grepl(".gdx", subseq.env$cfg_rem$files2export$start[pathes_to_gdx])

      if (all(gdx_exist | gdx_na)) {
        message("Starting subsequent run ", run)
        logfile <- file.path("output", subseq.env$fullrunname, "log.txt")
        if (! file.exists(dirname(logfile))) dir.create(dirname(logfile))
        if (isTRUE(subseq.env$qos == "auto")) {
          sq <- system(paste0("squeue -u ", Sys.info()[["user"]], " -o '%q %j' | grep -v ", fullrunname), intern = TRUE)
          subseq.env$qos <- if (is.null(attr(sq, "status")) && sum(grepl("^priority ", sq)) < 4) "priority" else "short"
        }
        slurmOptions <- combine_slurmConfig(paste0("--qos=", subseq.env$qos, " --job-name=", subseq.env$fullrunname, " --output=", logfile,
           " --open-mode=append --mail-type=END --comment=REMIND-MAgPIE --tasks-per-node=", subseq.env$numberOfTasks,
          if (subseq.env$numberOfTasks == 1) " --mem=8000"), subseq.env$sbatch)
        subsequentcommand <- paste0("sbatch ", slurmOptions, " --wrap=\"Rscript start_coupled.R coupled_config=", RData_file, "\"")
        message(subsequentcommand)
        if (length(needfulldatagdx) > 0) {
          exitCode <- system(subsequentcommand)
          if (0 < exitCode) {
            message("sbatch command failed, check logs")
            errorsfound <- errorsfound + 1
            # if sbatch has the --wait argument, the user is likely interactively
            # waiting for the result of the run (like in a test). In that case,
            # fail immediately so that the user knows about the failure asap.
            if(grepl("--wait", subsequentcommand)) {
              stop("You seem to be waiting for ", subseq.env$fullrunname, " to finish but the sbatch command failed")
            }
          }
        } else {
          message(RData_file, " already contained a gdx for this run. To avoid runs to be started twice, I'm not starting it. You can start it by running the command directly above.")
        }
      } else {
        message(run, " is still waiting for: ",
        paste(unique(subseq.env$cfg_rem$files2export$start[pathes_to_gdx][!(gdx_exist | gdx_na)]), collapse = ", "), ".")
      }
    } # end of loop through possible subsequent runs
  }

  message("\nEnd of starting subsequent runs\n")

  if (i == max_iterations) {

    # Read runtime of ALL coupled runs (not just the current scenario) and produce comparison pdf
    remindpath <- file.path(path_remind, "output")
    magpiepath <- file.path(path_magpie, "output")

    message("\n### COUPLING ### Preparing runtime.pdf");
    runs <- findCoupledruns(resultsfolder = remindpath)
    ret  <- findIterations(runs, modelpath = c(remindpath, magpiepath), latest = FALSE)
    readRuntime(ret, plot=TRUE, coupled=TRUE)
    unlink(c("runtime.log", "runtime.out", "runtime.rda"))

    if (max_iterations > 1 && ! grepl("TESTTHAT", runname)) {
      # set required variables and execute script to create convergence plots
      message("### COUPLING ### Preparing convergence pdf");
      source_include <- TRUE
      runs <- runname
      folder <- "./output"
      pci <- try(source("scripts/output/comparison/plot_compare_iterations.R", local = TRUE))
      if (inherits(pci, "try-error")) errorsfound <- errorsfound + 1
      cs_runs <- findIterations(runname, modelpath = remindpath, latest = FALSE)
      cs_name <- paste0("compScen-rem-1-", max_iterations, "_", runname)
      cs_qos <- if (!isFALSE(run_compareScenarios)) run_compareScenarios else "short"
      cs_command <- paste0("sbatch --qos=", cs_qos, " --job-name=", cs_name, " --output=", cs_name, ".out --error=",
      cs_name, ".out --mail-type=END --time=60 --wrap='Rscript scripts/cs2/run_compareScenarios2.R outputDirs=",
      paste(cs_runs, collapse=","), " profileName=REMIND-MAgPIE outFileName=", cs_name,
      " regionList=World,LAM,OAS,SSA,EUR,NEU,MEA,REF,CAZ,CHA,IND,JPN,USA mainRegName=World'")
      if (! isFALSE(run_compareScenarios)) {
        message("### Coupling ### Start compareScenario ", cs_name)
        message(cs_command)
        system(cs_command)
      } else {
        message("### Coupling ### If you want a compareScenario with name ", cs_name, ", run:")
        message(cs_command)
      }
    }
  }
  message("### start_coupled() finished. ###")
  if (errorsfound > 0) stop(errorsfound, " errors found, check the logs.")
}

##################################################################
################# E X E C U T E  start_coupled ###################
##################################################################
require(lucode2)

# Manual call:
# Rscript start_coupled.R coupled_config=runname.RData

readArgs("coupled_config")
load(coupled_config)
# backwards compatibility
if (! exists("fullrunname")) fullrunname <- runname
if (! exists("prefix_runname")) prefix_runname <- "C_"
if (! exists("run_compareScenarios")) run_compareScenarios <- "short"
if (! exists("magpie_empty")) magpie_empty <- FALSE
start_coupled(path_remind, path_magpie, cfg_rem, cfg_mag, runname, max_iterations, start_iter,
              n600_iterations, path_report, qos, fullrunname, prefix_runname, run_compareScenarios,
              magpie_empty)

message("### Print warnings ###")
warnings()
message("### End start_coupled.R ###")
