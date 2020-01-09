library(lucode)

#######################################################################
############### Select slurm partitiion ###############################
#######################################################################

get_line <- function(){
  # gets characters (line) from the terminal or from a connection
  # and returns it
  if(interactive()){
    s <- readline()
  } else {
    con <- file("stdin")
    s <- readLines(con, 1, warn=FALSE)
    on.exit(close(con))
  }
  return(s);
}

choose_submit <- function(title="Please choose run submission type") {
  
  # xxx add REMIND specific combinations of qos and number of nodes
  modes <- c("SLURM priority (recommended)",
             "SLURM standby (recommended)",
             "SLURM short",
             "SLURM medium",
             "SLURM long")

  cat("\nCurrent cluster utilization:\n")
  system("sclass")
  cat("\n")

  cat("\n",title,":\n", sep="")
  cat(paste(1:length(modes), modes, sep=": " ),sep="\n")
  cat("Number: ")
  identifier <- get_line()
  identifier <- as.numeric(strsplit(identifier,",")[[1]])
  comp <- switch(identifier,
                 "1" = "priority",
                 "2" = "standby",
                 "3" = "short",
                 "4" = "medium",
                 "5" = "long")
  if(is.null(comp)) stop("This type is invalid. Please choose a valid type")
  return(comp)
}


# Choose submission type
slurm <- TRUE #suppressWarnings(ifelse(system2("srun",stdout=FALSE,stderr=FALSE) != 127, TRUE, FALSE))
if (slurm) {
  user_choice_submit <- choose_submit("Choose submission type")
  } else {
  user_choice_submit <- "direct"
  }

#######################################################################
######################## Submit run ###################################
#######################################################################

############## Define function: configure_cfg #########################

configure_cfg <- function(icfg, iscen, iscenarios, isettings) {
    
    .setgdxcopy <- function(needle, stack, new) {
      # delete entries in stack that contain needle and append new
      out <- c(stack[-grep(needle, stack)], new)
      return(out)
    }

    # Edit run title
    icfg$title <- iscen
    cat("\n", iscen, "\n")
  
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

    # Remove potential elements that contain ".gdx" and append gdxlist
    icfg$files2export$start <- .setgdxcopy(".gdx", icfg$files2export$start, gdxlist)

    # add gdx information for subsequent runs
    icfg$subsequentruns        <- rownames(isettings[isettings$path_gdx_ref == iscen & !is.na(isettings$path_gdx_ref) & isettings$start == 1,])
    icfg$RunsUsingTHISgdxAsBAU <- rownames(isettings[isettings$path_gdx_bau == iscen & !is.na(isettings$path_gdx_bau) & isettings$start == 1,])
    
    return(icfg)
}

############## Define function: .copy.fromlist #########################

.copy.fromlist <- function(filelist,destfolder) {
  if(is.null(names(filelist))) names(filelist) <- rep("",length(filelist))
  for(i in 1:length(filelist)) {
    if(!is.na(filelist[i])) {
      to <- paste0(destfolder,"/",names(filelist)[i])
      if(!file.copy(filelist[i],to=to,recursive=dir.exists(to),overwrite=T))
        cat(paste0("Could not copy ",filelist[i]," to ",to,"\n"))
    }
  }
}

############## Define function: runsubmit #########################

submit_run <- function(icfg) {
  
  # Create name of output folder and output folder itself
  date <- format(Sys.time(), "_%Y-%m-%d_%H.%M.%S")
  icfg$results_folder <- gsub(":date:", date, icfg$results_folder, fixed = TRUE)
  icfg$results_folder <- gsub(":title:", icfg$title, icfg$results_folder, fixed = TRUE)
  # Create output folder
  if (!file.exists(icfg$results_folder)) {
    dir.create(icfg$results_folder, recursive = TRUE, showWarnings = FALSE)
  } else if (!icfg$force_replace) {
    stop(paste0("Results folder ",icfg$results_folder," could not be created because it already exists."))
  } else {
    cat("Deleting results folder because it alreay exists:",icfg$results_folder,"\n")
    unlink(icfg$results_folder, recursive = TRUE)
    dir.create(icfg$results_folder, recursive = TRUE, showWarnings = FALSE)
  }
  
  # Copy files required to confiugre and start a run
  filelist <- c(paste0(icfg$title,".Rdata")            = "config.Rdata",
                "scripts/run_submit/prepare_and_run.R" = "prepare_and_run.R")
  .copy.fromlist(filelist,icfg$results_folder)

  # change to run folder
  mainfolder <- getwd()
  setwd(icfg$results_folder)
  on.exit(setwd(mainfolder))
 
  # send prepare_and_run.R to cluster 
  cat("Executing prepare_and_run.R for",icfg$title,"\n")
  sbatch_command <- paste0("sbatch --job-name=",icfg$title," --output=",icfg$title,"-%j.out --mail-type=END --comment=REMIND --wrap=\"Rscript prepare_and_run.R ",icfg$title,"\"")
  if(icfg$submit_settings=="direct") {
    log <- format(Sys.time(), paste0(icfg$title,"-%Y-%H-%M-%S-%OS3.log"))
    system("Rscript prepare_and_run.R ",icfg$title, stderr = log, stdout = log, wait=FALSE)
  } else if(icfg$submit_settings=="priority") {
    system(paste(sbatch_command,"--qos=priority"))
    Sys.sleep(1)
  } else if(icfg$submit_settings=="standby") {
    #tmp <- paste(sbatch_command,"--qos=standby")
    #print(tmp)
    system(paste(sbatch_command,"--qos=standby"))
    Sys.sleep(1)
  } else if(icfg$submit_settings=="short") {
    system(paste(sbatch_command,"--qos=short"))
    Sys.sleep(1)
  } else if(icfg$submit_settings=="medium") {
    system(paste(sbatch_command,"--qos=medium"))
    Sys.sleep(1)
  } else if(icfg$submit_settings=="long") {
    system(paste(sbatch_command,"--qos=long"))
    Sys.sleep(1)
  } else {
    stop("Unknown submission type")
  }
  
  # Gedächtnisstütze für die slurm-Varianten
  ## Replace load leveler-script with appropriate version
  #if (cfg$gms$optimization == "nash" && cfg$gms$cm_nash_mode == "parallel") {
  #  if(length(unique(map$RegionCode)) <= 12) {
  #    cfg$files2export$start[cfg$files2export$start == "scripts/run_submit/submit.cmd"] <- 
  #      "scripts/run_submit/submit_par.cmd"
  #  } else { # use max amount of cores if regions number is greater than 12 
  #    cfg$files2export$start[cfg$files2export$start == "scripts/run_submit/submit.cmd"] <- 
  #      "scripts/run_submit/submit_par16.cmd"
  #  }
  #} else if (cfg$gms$optimization == "testOneRegi") {
  #  cfg$files2export$start[cfg$files2export$start == "scripts/run_submit/submit.cmd"] <- 
  #    "scripts/run_submit/submit_short.cmd"
  #}
}

###################### Load csv if provided  ##########################
# If scenario_config.csv was provided from command line, set cfg according to it (copy from start_bundle)
# check for config file parameter
config.file <- commandArgs(trailingOnly = TRUE)[1]
if (!is.na(config.file)) {

  cat(paste("reading config file", config.file, "\n"))
    
  # Read-in the switches table, use first column as row names
  settings <- read.csv2(config.file, stringsAsFactors = FALSE, row.names = 1, comment.char = "#", na.strings = "")

  # Select scenarios that are flagged to start
  scenarios  <- settings[settings$start==1,]
  if (length(grep("\\.",rownames(scenarios))) > 0) stop("One or more titles contain dots - GAMS would not tolerate this, and quit working at a point where you least expect it. Stopping now. ")
} else {
  # if no csv was provided create dummy list with default as the only scenario
  scenarios <- data.frame("default" = "default",row.names = "default")
}

###################### Loop over csv ###############################

# Modify and save cfg for all runs
for (scen in rownames(scenarios)) {
  #source cfg file for each scenario to avoid duplication of gdx entries in files2export
  source("config/default.cfg")
  
  # Have the log output written in a file (not on the screen)
  cfg$submit_settings <- user_choice_submit
  cfg$logoption   <- 2
  cfg$sendToSlurm <- NA
  
  # configure cfg based on settings from csv if provided
  if (!is.na(config.file)) cfg <- configure_cfg(cfg, scen, scenarios, settings)
  
  # save the cfg data for later start of subsequent runs (after preceding run finished)
  cat("Writing cfg to file\n")
  save(cfg,file=paste0(scen,".RData"))
  
  # Directly start runs that have a gdx file location given as path_gdx_ref or where this field is empty
  start_now <- substr(settings[scen,"path_gdx_ref"], nchar(settings[scen,"path_gdx_ref"])-3, nchar(settings[scen,"path_gdx_ref"])) == ".gdx" 
               | is.na(settings[scen,"path_gdx_ref"])
  
  if (start_now){
   cat("Creating and starting: ",cfg$title,"\n")
   submit_run(cfg)
   }
}
  
