# |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
##################################################################
################# D E F I N E  debug_coupled #####################
##################################################################

# This function will be called in start_coupled() instead of the regular
# submit() (for REMIND) and start_run (for MAgPIE) functions if the debug 
# mode is set to TRUE in start_coupled().
# It creates empty output folders and copies dummy reports into them 
# without calling the start scripts of the models.

debug_coupled <- function(model = NULL, cfg) {
   if(is.null(model)) stop("COUPLING DEBUG: Coupling was run in debug mode but no model was specified")
   
   message("   Creating results folder ", cfg$results_folder)
   if (!file.exists(cfg$results_folder)) {
     dir.create(cfg$results_folder, recursive = TRUE, showWarnings = FALSE)
   } else if (!cfg$force_replace) {
     stop(paste0("Results folder ",cfg$results_folder," could not be created because it already exists."))
   } else {
     message("    Deleting results folder because it already exists: ", cfg$results_folder)
     unlink(cfg$results_folder, recursive = TRUE)
     dir.create(cfg$results_folder, recursive = TRUE, showWarnings = FALSE)
   }
 
   if (model == "rem") {
      message("COUPLING DEBUG: assuming REMIND")
      report <- "/home/dklein/REMIND_generic_C_SSP2EU-Tall-PkBudg1020-imp-rem-5.mif"
      to <- paste0(cfg$results_folder,"/REMIND_generic_",cfg$title,".mif")
   } else if (model == "mag") {
      message("COUPLING DEBUG: assuming MAGPIE")
      report <- "/home/dklein/report.mif"
      to <- paste0(cfg$results_folder,"/report.mif")
   } else {
     stop("COUPLING DEBUG: Coupling was started in debug mode but model is unknown")
   }
   
   message("COUPLING DEBUG: to = ",to)
   
   if(!file.copy(from = report, to = to)) message("Could not copy ", report, " to ", to)
   return(cfg$results_folder)
}

##################################################################
################# D E F I N E  start_coupled #####################
##################################################################

start_coupled <- function(path_remind, path_magpie, cfg_rem, cfg_mag, runname, max_iterations = 5, start_iter = 1,
                          n600_iterations = 0, report = NULL, qos, parallel = FALSE, fullrunname = FALSE,
                          prefix_runname = "C_", run_compareScenarios = TRUE) {
  require(lucode2)
  require(gms)
  require(magclass)
  require(gdx)
  library(methods)
  library(remind2)

  # delete entries in stack that contain needle and append new
  .setgdxcopy <- function(needle,stack,new){
    matches <- grepl(needle,stack)
    out <- c(stack[!matches],new)
    return(out)
  }

  # start coupling in debug mode (just create empty results folders and copy dummy reports without running the models)
  debug <- FALSE

  mainwd <- getwd() # save folder in which this script is executed

  # Retrieve REMIND settings
  cfg_rem <- check_config(cfg_rem, paste0(path_remind,"config/default.cfg"), paste0(path_remind, "modules"),
                          extras = c("backup", "remind_folder", "pathToMagpieReport", "cm_nash_autoconverge_lastrun",
                                     "gms$c_expname", "restart_subsequent_runs", "gms$c_GDPpcScen",
                                     "gms$cm_CES_configuration", "gms$c_description"))
  cfg_rem$slurmConfig   <- "direct"
  cm_iteration_max_tmp <- cfg_rem$gms$cm_iteration_max # save default setting
  cfg_rem_original <- c(setdiff(cfg_rem$output, "emulator"), "emulator") # save default remind output config and add "emulator" if missing

  # retrieve MAgPIE settings
  cfg_mag <- check_config(cfg_mag,paste0(path_magpie,"config/default.cfg"),paste0(path_magpie,"modules")) 
  cfg_mag$sequential <- TRUE
  cfg_mag$force_replace <- TRUE
  cfg_mag$output     <- c("rds_report") # ,"remind","report") # rds_report: MAgPIE4; remind,report: MAgPIE3 (glo.modelstat.csv)
  # if provided use ghg prices for land (MAgPIE) from a different REMIND run than the one MAgPIE runs coupled to
  use_external_ghgprices <- ifelse(is.na(cfg_mag$path_to_report_ghgprices), FALSE, TRUE)

  if (start_iter > max_iterations) stop("### COUPLING ### start_iter > max_iterations")

  possible_pathes_to_gdx <- c("input.gdx", "input_ref.gdx", "input_refpolicycost.gdx",
                              "input_bau.gdx", "input_carbonprice.gdx")

  startIterations <- if (parallel) c(start_iter) else start_iter:max_iterations

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
    cfg_rem$force_replace  <- if (parallel & ! debug) FALSE else TRUE # overwrite existing output folders
    #cfg_rem$gms$biomass    <- "magpie_linear"

    # define gdx paths. In case of parallel mode, they are already in cfg_rem
    if (isFALSE(parallel)) {
      if (i == start_iter) {
        message("### COUPLING ### gdx in first iteration taken from files2export$start")
      } else {
        message("### COUPLING ### gdx taken from previous iteration")
        for (path_gdx in possible_pathes_to_gdx) {
          cfg_rem$files2export$start[path_gdx]  <- paste0("output/",runname,"-rem-",i-1,"/", path_gdx)
        }
        # use fulldata.gdx as input.gdx
        cfg_rem$files2export$start["input.gdx"] <- paste0("output/",runname,"-rem-",i-1,"/fulldata.gdx")
      }
    }

    # Control Negishi iterations
    itr_offset <- 1 # Choose this if negishi iterations should only be adjusted for coupling iteration numbers below 3
    #itr_offset <- start_iter # Choose this if negishi iterations should be adjusted for the first three iterations (regardless of their number)
                  #	This is the case after the coupling was restarted continuing from existing iterations.
    
    double_iterations <- 1
    if (cfg_rem$gms$cm_SlowConvergence == "on") double_iterations <- 2 
    
    if(i==itr_offset) {
      # Set negisgi iteration to 1 for the first run
      cfg_rem$gms$cm_iteration_max <- 1*double_iterations
    #} else if (i==itr_offset+1) {
    #  cfg_rem$gms$cm_iteration_max <- 2*double_iterations
    #} else if (i==itr_offset+2) {
    #  cfg_rem$gms$cm_iteration_max <- 3*double_iterations
    } else {
      # Set negishi iterations back to the value defined in the config file
      cfg_rem$gms$cm_iteration_max <- cm_iteration_max_tmp
    }
    message("Set Negishi iterations to ",cfg_rem$gms$cm_iteration_max)
    
    # Switch off generation of needless output for all but the last REMIND iteration
    if (i < max_iterations) {
      cfg_rem$output <- c("reporting", "emulator", "rds_report")
    } else {
      cfg_rem$output <- cfg_rem_original
    }

    # change precision only for last run if setup in coupled config
     if (i == max_iterations && ! is.null(cfg_rem$cm_nash_autoconvergence_lastrun) && ! is.na(cfg_rem$cm_nash_autoconverge_lastrun)) {
       cfg_rem$gms$cm_nash_autoconverge <- cfg_rem$cm_nash_autoconverge_lastrun
    }

    ############ DECIDE IF AND HOW TO START REMIND ###################
    outfolder_rem <- NULL
    if (is.null(report)) {
      if (i == 1) {
        ######### S T A R T   R E M I N D   S T A N D A L O N E ##############
        cfg_rem$gms$cm_MAgPIE_coupling <- "off"
        message("### COUPLING ### No MAgPIE report for REMIND input provided.")
        message("### COUPLING ### REMIND will be started in stand-alone mode with\n    ", runname, "\n    ", cfg_rem$results_folder)
        outfolder_rem <- ifelse(debug, debug_coupled(model="rem",cfg_rem), submit(cfg_rem, stopOnFolderCreateError = FALSE))
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
      outfolder_rem <- ifelse(debug, debug_coupled(model="rem",cfg_rem), submit(cfg_rem, stopOnFolderCreateError = FALSE))
      ############################
    } else if (grepl("REMIND_generic_",report)) { # if it is a REMIND report
      ############### O M I T   R E M I N D  ###############################
      message("### COUPLING ### Omitting REMIND in this iteration\n    Report = ", report)
      report <- report
    } else {
      stop(paste0("### COUPLING ### Could not decide whether ",report," is REMIND or MAgPIE output.\n"))
    }

    if(!is.null(outfolder_rem)) {
      report    <- paste0(path_remind,outfolder_rem,"/REMIND_generic_",cfg_rem$title,".mif")
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
      } else if (debug){
        # continue
      } else {
        stop("### COUPLING ### REMIND didn't produce any gdx. Coupling iteration stopped!")
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
    outfolder_mag <- ifelse(debug, debug_coupled(model="mag", cfg_mag), start_run(cfg_mag, codeCheck=FALSE))
    ######################################
    message("### COUPLING ### MAgPIE output was stored in ", outfolder_mag)
    report_mag <- paste0(path_magpie, outfolder_mag, "/report.mif")
    report <- report_mag

    # Checking whether MAgPIE is optimal in all years
    file_modstat <- paste0(outfolder_mag, "/glo.magpie_modelstat.csv")
    if (debug) {
      modstat_mag <- 2
    } else if (file.exists(file_modstat)) {
      modstat_mag <- read.csv(file_modstat, stringsAsFactors = FALSE, row.names=1, na.strings="")
    } else {
      modstat_mag <- readGDX(paste0(outfolder_mag, "/fulldata.gdx"), "p80_modelstat", "o_modelstat", format="first_found")
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
    fulldatapath <- paste0(path_remind, cfg_rem$results_folder, "/fulldata.gdx")
    stamp <- format(Sys.time(), "_%Y-%m-%d_%H.%M.%S")

    # Loop possible subsequent runs, saving path to fulldata.gdx of current run (== cfg_rem$title) to their cfg files

    for (run in rownames(cfg_rem$RunsUsingTHISgdxAsInput)) {

      message("\nPrepare subsequent run ", run, ":")
      subseq.env <- new.env()
      RData_file <- paste0(if (! parallel) prefix_runname, run, ".RData")
      load(RData_file, envir = subseq.env)

      pathes_to_gdx <- intersect(possible_pathes_to_gdx, names(subseq.env$cfg_rem$files2export$start))

      gdx_na <- is.na(subseq.env$cfg_rem$files2export$start[pathes_to_gdx])

      stringtobereplaced <- if (parallel) fullrunname else paste0(runname, "-rem-", max_iterations)
      needfulldatagdx <- names(subseq.env$cfg_rem$files2export$start[pathes_to_gdx][subseq.env$cfg_rem$files2export$start[pathes_to_gdx] == stringtobereplaced & !gdx_na])
      message("In ", RData_file, ", use current fulldata.gdx path for ", paste(needfulldatagdx, collapse = ", "), ".")
      subseq.env$cfg_rem$files2export$start[needfulldatagdx] <- fulldatapath

      if (isTRUE(subseq.env$path_report == runname)) subseq.env$path_report <- report_mag
      save(list = ls(subseq.env), file = RData_file, envir = subseq.env)

      # Subsequent runs will be started using submit.R, if all necessary gdx files were generated
      gdx_exist <- grepl(".gdx", subseq.env$cfg_rem$files2export$start[pathes_to_gdx])

      if (all(gdx_exist | gdx_na)) {
        message("Starting subsequent run ", run)
        # for the sbatch command set the number of tasks per node
        if (subseq.env$cfg_rem$gms$optimization == "nash" && subseq.env$cfg_rem$gms$cm_nash_mode == "parallel") {
          # for nash: set the number of CPUs per node to number of regions + 1
          nr_of_regions <- length(unique(read.csv2(subseq.env$cfg_rem$regionmapping)$RegionCode)) + 1
        } else {
          # for negishi: use only one CPU
          nr_of_regions <- 1
        }
        logfile <- if (parallel) file.path("output", subseq.env$fullrunname, "log.txt")
                   else file.path("output", paste0("log_", subseq.env$fullrunname, stamp, ".txt"))
        if (! file.exists(dirname(logfile))) dir.create(dirname(logfile))
        subsequentcommand <- paste0("sbatch --qos=", subseq.env$qos, " --job-name=", subseq.env$fullrunname, " --output=", logfile,
        " --mail-type=END --comment=REMIND-MAgPIE --tasks-per-node=", nr_of_regions,
        " --wrap=\"Rscript start_coupled.R coupled_config=", RData_file, "\"")
        message(subsequentcommand)
        if (length(needfulldatagdx) > 0) {
          system(subsequentcommand)
          Sys.sleep(10)
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
    remindpath <- paste0(path_remind, "output")
    magpiepath <- paste0(path_magpie, "output")

    message("\n### COUPLING ### Preparing runtime.pdf");
    runs <- findCoupledruns(resultsfolder = remindpath)
    ret  <- findIterations(runs, modelpath = c(remindpath, magpiepath), latest = FALSE)
    readRuntime(ret, plot=TRUE, coupled=TRUE)
    unlink(c("runtime.log", "runtime.out", "runtime.rda"))

    # combine REMIND and MAgPIE reports of last coupling iteration (and REMIND water reporting if existing)
    report_rem <- paste0(path_remind,outfolder_rem,"/REMIND_generic_",cfg_rem$title,".mif")
    if (exists("outfolder_mag")) {
      # If MAgPIE has run use its regular outputfolder
      report_mag <- paste0(path_magpie, outfolder_mag, "/report.mif")
    } else {
      # If MAgPIE did not run, because coupling has been restarted with the last REMIND iteration,
      # use the path to the MAgPIE report REMIND has been restarted with.
      report_mag <- mag_report_keep_in_mind
    }
    message("Joining to a common reporting file:\n    ", report_rem, "\n    ", report_mag)
    tmp1 <- read.report(report_rem, as.list=FALSE)
    tmp2 <- read.report(report_mag, as.list=FALSE)[, getYears(tmp1), ]
    tmp3 <- mbind(tmp1,tmp2)
    getNames(tmp3, dim=1) <- gsub("-(rem|mag)-[0-9]{1,2}","",getNames(tmp3,dim=1)) # remove -rem-xx and mag-xx from scenario names
    # only harmonize model names to REMIND-MAgPIE, if there are no variable names that are identical across the models
    if (any(getNames(tmp3[,,"REMIND"],dim=3) %in% getNames(tmp3[,,"MAgPIE"],dim=3))) {
      msg <- "Cannot produce common REMIND-MAgPIE reporting because there are identical variable names in both models!\n"
      message(msg)
      warning(msg)
    } else {
      # Replace REMIND and MAgPIE with REMIND-MAgPIE
      #getNames(tmp3,dim=2) <- gsub("REMIND|MAgPIE","REMIND-MAGPIE",getNames(tmp3,dim=2))
      write.report(tmp3,file=paste0("output/",runname,".mif"))
    }

    if (max_iterations > 1) {
      # set required variables and execute script to create convergence plots
      message("### COUPLING ### Preparing convergence pdf");
      source_include <- TRUE
      runs <- runname
      folder <- "./output"
      source("scripts/output/comparison/plot_compare_iterations.R", local = TRUE)
      cs_runs <- findIterations(runname, modelpath = remindpath, latest = FALSE)
      cs_name <- paste0("compScen-rem-1-", max_iterations, "_", runname)
      cs_qos <- if (!isFALSE(run_compareScenarios)) run_compareScenarios else "short"
      cs_command <- paste0("sbatch --qos=", cs_qos, " --job-name=", cs_name, " --output=", cs_name, ".out --error=",
      cs_name, ".out --mail-type=END --time=60 --wrap='Rscript scripts/utils/run_compareScenarios2.R outputdirs=",
      paste(cs_runs, collapse=","), " shortTerm=FALSE outfilename=", cs_name,
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
if (! exists("parallel")) parallel <- FALSE
if (! exists("fullrunname")) fullrunname <- runname
if (! exists("prefix_runname")) prefix_runname <- "C_"
if (! exists("run_compareScenarios")) run_compareScenarios <- "short"
start_coupled(path_remind, path_magpie, cfg_rem, cfg_mag, runname, max_iterations, start_iter,
              n600_iterations, path_report, qos, parallel, fullrunname, prefix_runname, run_compareScenarios)

message("### Print warnings ###")
warnings()
message("### End start_coupled.R ###")
