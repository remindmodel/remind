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

submit <- function(cfg) {
  
  # Create name of output folder and output folder itself
  date <- format(Sys.time(), "_%Y-%m-%d_%H.%M.%S")
  cfg$results_folder <- gsub(":date:", date, cfg$results_folder, fixed = TRUE)
  cfg$results_folder <- gsub(":title:", cfg$title, cfg$results_folder, fixed = TRUE)
  # Create output folder
  if (!file.exists(cfg$results_folder)) {
    dir.create(cfg$results_folder, recursive = TRUE, showWarnings = FALSE)
  } else if (!cfg$force_replace) {
    stop(paste0("Results folder ",cfg$results_folder," could not be created because it already exists."))
  } else {
    cat("Deleting results folder because it alreay exists:",cfg$results_folder,"\n")
    unlink(cfg$results_folder, recursive = TRUE)
    dir.create(cfg$results_folder, recursive = TRUE, showWarnings = FALSE)
  }
  
  # save main folder
  cfg$remind_folder <- getwd()
 
  # save the cfg data before moving it into the results folder
  cat("Writing cfg to file\n")
  save(cfg,file=paste0(cfg$title,".RData"))
  
  # Copy files required to confiugre and start a run
  filelist <- c("config.Rdata" = paste0(cfg$title,".RData"),
                "prepare_and_run.R" = "scripts/start/prepare_and_run.R")
  .copy.fromlist(filelist,cfg$results_folder)
  
  # remove config in main folder (after copying into results folder)
  file.remove(paste0(cfg$title,".RData"))

  # change to run folder
  setwd(cfg$results_folder)
  on.exit(setwd(cfg$remind_folder))

  # send prepare_and_run.R to cluster 
  cat("Executing prepare_and_run.R for",cfg$title,"\n")
  sbatch_command <- paste0("sbatch --job-name=",cfg$title," --output=",cfg$title,".out --mail-type=END --comment=REMIND --wrap=\"Rscript prepare_and_run.R \"")
  if(cfg$slurmConfig=="direct") {
    log <- format(Sys.time(), paste0(cfg$title,"-%Y-%H-%M-%S-%OS3.log"))
    system("Rscript prepare_and_run.R ",cfg$title, stderr = log, stdout = log, wait=FALSE)
  } else if(cfg$slurmConfig=="priority") {
    system(paste(sbatch_command,"--nodes=1 --tasks-per-node=12 --qos=priority"))
    Sys.sleep(1)
  } else if(cfg$slurmConfig=="standby") {
    system(paste(sbatch_command,"--nodes=1 --tasks-per-node=12 --qos=standby"))
    Sys.sleep(1)
  } else if(cfg$slurmConfig=="short") {
    system(paste(sbatch_command,"--qos=short"))
    Sys.sleep(1)
  } else if(cfg$slurmConfig=="medium") {
    system(paste(sbatch_command,"--qos=medium"))
    Sys.sleep(1)
  } else if(cfg$slurmConfig=="long") {
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
    # Call appropriate submit script
  #if (cfg$sendToSlurm) {
  #    # send to slurm
  #    if(cfg$gms$optimization == "nash" && cfg$gms$cm_nash_mode == "parallel") {
  #       if(length(unique(map$RegionCode)) <= 12) { 
  #         system(paste0("sed -i 's/__JOB_NAME__/pREMIND_", cfg$title,"/g' submit_par.cmd"))
  #         system("sbatch submit_par.cmd")
  #       } else { # use max amount of cores if regions number is greater than 12 
  #         system(paste0("sed -i 's/__JOB_NAME__/pREMIND_", cfg$title,"/g' submit_par16.cmd"))
  #         system("sbatch submit_par16.cmd")
  #       }
  #    } else if (cfg$gms$optimization == "testOneRegi") {
  #        system(paste0("sed -i 's/__JOB_NAME__/REMIND_", cfg$title,"/g' submit_short.cmd"))
  #        system("sbatch submit_short.cmd")
  #    } else {
  #        system(paste0("sed -i 's/__JOB_NAME__/REMIND_", cfg$title,"/g' submit.cmd"))
  #        if (cfg$gms$cm_startyear > 2030) {
  #            system("sbatch --partition=ram_gpu submit.cmd")
  #        } else {
  #            system("sbatch submit.cmd")
  #        }
  
  return(cfg$results_folder)
  
}
