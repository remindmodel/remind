# |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
##################################################################
################# D E F I N E  start_coupled #####################
##################################################################
start_coupled <- function(path_remind,path_magpie,cfg_rem,cfg_mag,runname,max_iterations=5,start_iter=1,n600_iterations=0,report=NULL,LU_pricing=TRUE) {
  
  require(lucode)
  require(magclass)
  require(gdx)
  library(methods)
  library(remind)
  
  # delete entries in stack that contain needle and append new
  .setgdxcopy <- function(needle,stack,new){
    matches <- grepl(needle,stack)
    out <- c(stack[!matches],new)
    return(out)
  }
  
  mainwd <- getwd() # save folder in which this script is executed
  
  # retrieve REMIND settings
  cfg_rem <- check_config(cfg_rem,paste0(path_remind,"config/default.cfg"),paste0(path_remind,"modules")) 
  cfg_rem$sequential   <- TRUE
  cm_iteration_max_tmp <- cfg_rem$gms$cm_iteration_max # save default setting
  cfg_rem_original <- cfg_rem$output

  # retrieve MAgPIE settings
  cfg_mag <- check_config(cfg_mag,paste0(path_magpie,"config/default.cfg"),paste0(path_magpie,"modules")) 
  cfg_mag$sequential <- TRUE
  cfg_mag$force_replace <- TRUE
  cfg_mag$output     <- c("report","rds_report","remind") # report: MAgPIE3 and MAgPIE4, remind: MAgPIE3 (glo.modelstat.csv)
  
  if (start_iter > max_iterations ) stop("### COUPLING ### start_iter > max_iterations")

  # Start REMIND and MAgPIE iteratively
  for (i in start_iter:max_iterations) {
    cat("### COUPLING ### Iteration ",i,"\n")

    ##################################################################
    #################### R E M I N D #################################
    ##################################################################

    ####################### PREPARE REMIND ###########################

    cat("### COUPLING ### Preparing REMIND\n")
    cat("### COUPLING ### Set working directory from",getwd());
    setwd(path_remind)
    cat(" to",getwd(),"\n")
    source("scripts/start/submit.R") # provide source of "get_magpie_data" and "start_run"
    
    cfg_rem$results_folder <- paste0("output/",runname,"-rem-",i)
    cfg_rem$title          <- paste0(runname,"-rem-",i)
    cfg_rem$force_replace  <- TRUE # overwrite existing output folders
    #cfg_rem$gms$biomass    <- "magpie_linear"

    # define gdx paths
    if (i==start_iter) {
      cat("### COUPLING ### gdx in first iteraion taken from files2export$start \n")
    } else {
      cat("### COUPLING ### gdx taken from previous iteration\n")
      cfg_rem$files2export$start["input.gdx"]     <- paste0("output/",runname,"-rem-",i-1,"/fulldata.gdx")
      cfg_rem$files2export$start["input_bau.gdx"] <- paste0("output/",runname,"-rem-",i-1,"/input_bau.gdx")
      cfg_rem$files2export$start["input_ref.gdx"] <- paste0("output/",runname,"-rem-",i-1,"/input_ref.gdx")
    }
    
    # Control Negishi iterations
    itr_offset <- 1 # Choose this if negishi iterations should only be adjusted for coupling iteration numbers below 3
    #itr_offset <- start_iter # Choose this if negishi iterations should be adjusted for the first three iterations (regardless of their number)
                  #	This is the case after the oupling was restarted continuing from existing iterations.
    
    double_iterations <- 1
    if (cfg_rem$gms$cm_SlowConvergence == "on") double_iterations <- 2 
    
    if(i==itr_offset) {
      # Set negisgi iteration to 1 for the first run
      cfg_rem$gms$cm_iteration_max <- 1*double_iterations
    #} else if (i==itr_offset+1) {
    #	cfg_rem$gms$cm_iteration_max <- 2*double_iterations
    #} else if (i==itr_offset+2) {
    #	cfg_rem$gms$cm_iteration_max <- 3*double_iterations
    } else {
      # Set negishi iterations back to the value defined in the config file
      cfg_rem$gms$cm_iteration_max <- cm_iteration_max_tmp
    }
    cat("Set Negishi iterations to",cfg_rem$gms$cm_iteration_max,"\n")
    
    # Switch off generation of needless output for all but the last REMIND iteration
    if (i < max_iterations) {
      cfg_rem$output <- c("reporting","emulator","rds_report")
    } else {
      cfg_rem$output <- cfg_rem_original
    }

    ############ DECIDE IF AND HOW TO START REMIND ###################
    outfolder_rem <- NULL
    if (is.null(report)) {
      ######### S T A R T   R E M I N D   S T A N D A L O N E ##############
      cfg_rem$gms$cm_MAgPIE_coupling <- "off"
      cat("### COUPLING ### No MAgPIE report for REMIND input provided.\n")
      cat("### COUPLING ### REMIND will be startet in stand-alone mode with\n    ",runname,"\n    ",cfg_rem$results_folder,"\n")
      outfolder_rem <- submit(cfg_rem)
    } else if (grepl(paste0("report.mif"),report)) { # if it is a MAgPIE report
      ######### S T A R T   R E M I N D   C O U P L E D ##############
      cfg_rem$gms$cm_MAgPIE_coupling <- "on"
      if (!file.exists(report)) stop(paste0("### COUPLING ### Could not find report: ", report,"\n"))
      cat("### COUPLING ### Starting REMIND in coupled mode with\n    Report=",report,"\n    Folder=",cfg_rem$results_folder,"\n")
      # Keep path to MAgPIE report in mind to have it availalbe after the coupling loop
      mag_report_keep_in_mind <- report
      ####### START REMIND #######
      cfg_rem$pathToMagpieReport <- report
      outfolder_rem <- submit(cfg_rem)
      ############################
    } else if (grepl("REMIND_generic_",report)) { # if it is a REMIND report
      ############### O M I T   R E M I N D  ###############################
      cat("### COUPLING ### Omitting REMIND in this iteration\n    Report=",report,"\n")
      report <- report
    } else {
      stop(paste0("### COUPLING ### Could not decide whether ",report," is REMIND or MAgPIE output.\n"))
    }

    if(!is.null(outfolder_rem)) {
      report    <- paste0(path_remind,outfolder_rem,"/REMIND_generic_",cfg_rem$title,".mif")
      cat("### COUPLING ### REMIND output was stored in ",outfolder_rem,"\n")
      if (file.exists(paste0(outfolder_rem,"/fulldata.gdx"))) {
        modstat <- readGDX(paste0(outfolder_rem,"/fulldata.gdx"),types="parameters",format="raw",c("s80_bool","o_modelstat"))
        if (cfg_rem$gms$optimization == "negishi") {
          if (as.numeric(modstat$o_modelstat$val)!=2 && as.numeric(modstat$o_modelstat$val)!=7) stop("Iteration stopped! REMIND o_modelstat was ",modstat," but is required to be 2 or 7.\n")
        } else if (cfg_rem$gms$optimization == "nash") {
          if (as.numeric(modstat$s80_bool$val)!=1) cat("Warning: REMIND s80_bool not 1. Iteration continued though.\n")
        }
      } else {
        stop("### COUPLING ### REMIND didn't produce 'fulldata.gdx'. Iteration stopped!")
      }
    }

    if (!file.exists(report)) stop(paste0("### COUPLING ### Could not find report: ", report,"\n"))
    
    # If in the last iteration don't run MAgPIE
    if (i == max_iterations) break

    ##################################################################
    #################### M A G P I E #################################
    ##################################################################
    cat("### COUPLING ### Preparing MAgPIE\n")
    cat("### COUPLING ### Set working directory from",getwd());
    setwd(path_magpie)
    cat(" to",getwd(),"\n")
    source("scripts/start_functions.R")
    cfg_mag$results_folder <- paste0("output/",runname,"-mag-",i)
    cfg_mag$title          <- paste0(runname,"-mag-",i)

    # Increase MAgPIE resolution n600_iterations before final iteration so that REMIND
    # runs n600_iterations iterations using results from MAgPIE with higher resolution
    if (i > (max_iterations-n600_iterations)) {
      cat("Current iteration":i,". Setting MAgPIE to n600\n")
      cfg_mag <- setScenario(cfg_mag,"n600",scenario_config=paste0("config/scenario_config.csv"))
    }

    # Providing MAgPIE with gdx from last iteration's solution only for time steps >= cfg_rem$gms$cm_startyear
    # For years prior to cfg_rem$gms$cm_startyear MAgPIE output has to be identical across iterations.
    # Because gdxes might slightly lead to a different solution exclude gdxes for the fixing years.
    if (i>1) {
     cat("### COUPLING ### Copying gdx files from previous iteration\n")
     gdxlist <- paste0("output/",runname,"-mag-",i-1,"/magpie_y",seq(cfg_rem$gms$cm_startyear,2150,5),".gdx")
     cfg_mag$files2export$start <- .setgdxcopy(".gdx",cfg_mag$files2export$start,gdxlist)
    }
    
    cat("### COUPLING ### MAgPIE will be startet with\n    Report = ",report,"\n    Folder=",cfg_mag$results_folder,"\n")
    ########### START MAGPIE #############
    outfolder_mag <- start_run(cfg_mag,path_to_report=report,LU_pricing=LU_pricing,codeCheck=FALSE)
    ######################################
    cat("### COUPLING ### MAgPIE output was stored in ",outfolder_mag,"\n")
    report <- paste0(path_magpie,outfolder_mag,"/report.mif")
      
    # Checking whether MAgPIE is optimal in all years
    file_modstat <- paste0(outfolder_mag,"/glo.magpie_modelstat.csv")
    if(file.exists(file_modstat)) {
      modstat_mag <- read.csv(file_modstat, stringsAsFactors = FALSE, row.names=1, na.strings="")
    } else {
      modstat_mag <- readGDX(paste0(outfolder_mag,"/fulldata.gdx"),"p80_modelstat","o_modelstat", format="first_found")
    }
    
    if(!all((modstat_mag==2) | (modstat_mag==7))) 
      stop("Iteration stopped! MAgPIE modelstat is not 2 or 7 for all years.\n")

  } # End of coupling iteration loop
  
  cat("### COUPLING ### Set working directory from",getwd());
  setwd(mainwd)
  cat(" to",getwd(),"\n")
  
  # for the sbatch command of the subsequent runs below set the number of tasks per node
  # this not clean, because we use the number of regions of the *current* run to set the number of tasks for the *subsequent* runs
  # but it is sufficiently clean, since the number of regions should not differ between current and subsequent
  if (cfg_rem$gms$optimization == "nash" && cfg_rem$gms$cm_nash_mode == "parallel") {
    # for nash: set the number of CPUs per node to number of regions + 1
    nr_of_regions <- length(levels(read.csv2(cfg_rem$regionmapping)$RegionCode)) + 1 
  } else {
    # for negishi: use only one CPU
    nr_of_regions <- 1
  }

  #start subsequent runs via sbatch
  for(run in cfg_rem$subsequentruns){
    cat("Submitting subsequent run",run,"\n")
    system(paste0("sbatch --qos=priority --job-name=C_",run," --output=C_",run,".log --mail-type=END --comment=REMIND-MAgPIE --tasks-per-node=",nr_of_regions," --wrap=\"Rscript start_coupled.R coupled_config=C_",run,".RData\""))
  }
  
  # Read runtime of ALL coupled runs (not just the current scenario) and produce comparison pdf
  remindpath <- paste0(path_remind,"output")
  magpiepath <- paste0(path_magpie,"output")

  runs <- findCoupledruns(resultsfolder=remindpath)
  ret  <- findIterations(runs,modelpath=c(remindpath,magpiepath),latest=FALSE)
  readRuntime(ret,plot=TRUE,coupled=TRUE)
  unlink(c("runtime.log","runtime.out","runtime.rda"))
  
  # combine REMIND and MAgPIE reports of last coupling iteration (and REMIND water reporting if existing)
  report_rem <- paste0(path_remind,outfolder_rem,"/REMIND_generic_",cfg_rem$title,".mif")
  if (exists("outfolder_mag")) {
    # If MAgPIE has run use its regular outputfolder
    report_mag <- paste0(path_magpie,outfolder_mag,"/report.mif")
  } else {
    # If MAgPIE did not run, because coupling has been restarted with the last REMIND iteration,
    # use the path to the MAgPIE report REMIND has been restarted with.
    report_mag <- mag_report_keep_in_mind
  }
  cat("Joining to a common reporting file:\n    ",report_rem,"\n    ",report_mag,"\n")
  tmp1 <- read.report(report_rem,as.list=FALSE)
  tmp2 <- read.report(report_mag,as.list=FALSE)[,getYears(tmp1),]
  tmp3 <- mbind(tmp1,tmp2)
  getNames(tmp3,dim=1) <- gsub("-(rem|mag)-[0-9]{1,2}","",getNames(tmp3,dim=1)) # remove -rem-xx and mag-xx from scenario names
  # only harmonize model names to REMIND-MAgPIE, if there are no variable names that are identical across the models
  if (any(getNames(tmp3[,,"REMIND"],dim=3) %in% getNames(tmp3[,,"MAgPIE"],dim=3))) {
    msg <- "Cannot produce common REMIND-MAgPIE reporting because there are identical variable names in both models!\n"
    cat(msg)
    warning(msg)
  } else {
    # Replace REMIND and MAgPIE with REMIND-MAgPIE
    gsub("REMIND|MAgPIE","REMIND-MAgPIE",getNames(tmp3,dim=2))
    write.report(tmp3,file=paste0("output/",runname,".mif"))
  }
}

##################################################################
################# E X E C U T E  start_coupled ###################
##################################################################
require(lucode)

readArgs("coupled_config")
load(coupled_config)
start_coupled(path_remind,path_magpie,cfg_rem,cfg_mag,runname,max_iterations,start_iter,n600_iterations,path_report,LU_pricing)

# Manual call:
# Rscript start_coupled.R coupled_config=runname
