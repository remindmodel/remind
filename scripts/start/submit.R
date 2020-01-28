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
  
  # Do not remove .RData files from REMIND main folder because they are needed in case you need to manually restart subsequent runs

  # change to run folder
  setwd(cfg$results_folder)
  on.exit(setwd(cfg$remind_folder))

  # send prepare_and_run.R to cluster 
  cat("Executing prepare_and_run.R for",cfg$title,"\n")
  if(cfg$slurmConfig=="direct") {
    log <- format(Sys.time(), paste0(cfg$title,"-%Y-%H-%M-%S-%OS3.log"))
    system("Rscript prepare_and_run.R")
  } else {
    system(paste0("sbatch --job-name=",cfg$title," --output=log.txt --mail-type=END --comment=REMIND --wrap=\"Rscript prepare_and_run.R \" ",cfg$slurmConfig))
    Sys.sleep(1)
  }
    
  return(cfg$results_folder)
}
