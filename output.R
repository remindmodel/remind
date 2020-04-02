# |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
##########################################################
#### REMIND Output Generation ####
##########################################################
# Version 1.0
# Type "Rscript output.R" to start the script in the command line

# Based on the Version 2.2 of same file in the MAgPIE main folder
#########################################################################################

#Write dump file when error occurs, see help to dump.frames for more information
options(error=quote({dump.frames(to.file=TRUE); traceback(); q()}))

#load landuse library

library(lucode)

###Define arguments that can be read from command line
if(!exists("source_include")) {
  # if this script is not being sourced by another script but called from the command line via Rscript read the command line arguments and let the user choose the slurm options
  readArgs("outputdir","output","comp","remind_dir")
  #source("scripts/utils/choose_slurmConfig.R")
  #slurmConfig <- choose_slurmConfig()
} 

#Setting relevant paths
if(file.exists('/iplex/01/landuse')) { #run is performed on the cluster
  pythonpath <- '/iplex/01/landuse/bin/python/bin/'
  latexpath <- '/iplex/01/sys/applications/texlive/bin/x86_64-linux/'
} else {
  pythonpath <- ''
  latexpath <- NA
}

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

choose_folder <- function(folder,title="Please choose a folder") {
  dirs <- NULL
  
  # Detect all output folders containing fulldata.gdx
  # For coupled runs please use the outcommented text block below

  dirs <- sub("/fulldata.gdx","",sub("./output/","",Sys.glob(file.path(folder,"*","fulldata.gdx"))))

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

choose_module <- function(Rfolder,title="Please choose an outputmodule") {
  module <- gsub("\\.R$","",grep("\\.R$",list.files(Rfolder), value=TRUE))
  cat("\n\n",title,":\n\n")
  cat(paste(1: length(module), module, sep=": " ),sep="\n")
  cat("\nNumber: ")
  identifier <- get_line()
  identifier <- as.numeric(strsplit(identifier,",")[[1]])
  if (any(!(identifier %in% 1:length(module)))) stop("This choice (",identifier,") is not possible. Please type in a number between 1 and ",length(module))
  return(module[identifier])
}

choose_mode <- function(title="Please choose the output mode") {
  modes <- c("Output for single run ","Comparison across runs")
  cat("\n\n",title,":\n\n")
  cat(paste(1:length(modes), modes, sep=": " ),sep="\n")
  cat("\nNumber: ")
  identifier <- get_line()
  identifier <- as.numeric(strsplit(identifier,",")[[1]])
  if (identifier==1) {
    comp<-FALSE
  } else if (identifier==2) {
    comp<-TRUE
  } else {
    stop("This mode is invalid. Please choose a valid mode")
  }  
  return(comp)
}

if(exists("source_include")) {
  comp <- FALSE
} else {
  if(!exists("comp")) {
    comp<-choose_mode("Please choose the output mode")
  }
}


if (comp==TRUE) {
  print("comparison")
  # Select output modules if not defined by readArgs
  if(!exists("output")) {
    output <- choose_module("./scripts/output/comparison","Please choose the output module to be used for output generation")
  }
  # Select output directories if not defined by readArgs
  if (!exists("outputdir")) {
    if (!exists("remind_dir")) {
      temp <- choose_folder("./output","Please choose the runs to be used for output generation")
      outputdirs <- temp
      for (i in 1:length(temp)) outputdirs[i] <- path("output",temp[i])
    } else {
      temp <- choose_folder(remind_dir,"Please choose the runs to be used for output generation")
      outputdirs <- temp
      for (i in 1:length(temp)) {
        last_iteration <- max(as.numeric(sub("magpie_","",grep("magpie_",list.dirs(path(remind_dir,temp[i],"data/results")),value=T))))
        outputdirs[i] <- path(remind_dir,temp[i],"data/results/",paste("magpie_",last_iteration,sep=""))
      }
    }
  } else outputdirs <- outputdir
  
  #Set value source_include so that loaded scripts know, that they are 
  #included as source (instead of a load from command line)
  source_include <- TRUE
  
  # Execute output scripts over all choosen folders
  for(rout in output){
    name<-paste(rout,".R",sep="")
    if(file.exists(paste("scripts/output/comparison/",name,sep=""))){
      print(paste("Executing",name))
      tmp.env <- new.env()
      tmp.error <- try(sys.source(paste("scripts/output/comparison/",name,sep=""),envir=tmp.env))
      rm(tmp.env)
      gc()
      if(!is.null(tmp.error)) warning("Script ",name," was stopped by an error and not executed properly!")
    } 
  }
  
  } else {

  # Select an output directory if not defined by readArgs
  if(!exists("outputdir")) {
    if (!exists("remind_dir")) {
      temp <- choose_folder("./output","Please choose the run(s) to be used for output generation")
      outputdirs <- temp
      for (i in 1:length(temp)) outputdirs[i] <- path("output",temp[i])
    } else {
      temp <- choose_folder(remind_dir,"Please choose the runs to be used for output generation")
      outputdirs <- temp
      for (i in 1:length(temp)) {
        last_iteration <- max(as.numeric(sub("magpie_","",grep("magpie_",list.dirs(path(remind_dir,temp[i],"data/results")),value=T))))
        outputdirs[i] <- path(remind_dir,temp[i],"data/results/",paste("magpie_",last_iteration,sep=""))
      }
    } 
  } else outputdirs <- outputdir

  # define slurm class or direct execution
  if(!exists("source_include")) {
    # if this script is not being sourced by another script but called from the command line via Rscript let the user choose the slurm options
    source("scripts/start/choose_slurmConfig.R")
    slurmConfig <- choose_slurmConfig()
  } else {
    # if this script is being sourced by another script exectue the output scripts directly without sending them to the cluster
    slurmConfig <- "direct"
  }
 
  #Execute outputscripts for all choosen folders
  for (outputdir in outputdirs) {

    # Select an output module if not defined by readArgs
    if(!exists("output")) {
      output <- choose_module("./scripts/output/single","Please choose the output module to be used for output generation")
    }
    
    if(exists("cfg")) {
      title    <- cfg$title
      gms      <- cfg$gms
      input    <- cfg$input
      revision <- cfg$revision
      magpie_folder <- cfg$magpie_folder
    }
    
    # Get values of config if output.R is called standalone
    if(!exists("source_include")) {
      magpie_folder <- getwd()
	  print(path(outputdir,"config.Rdata"))
      if(file.exists(path(outputdir,"config.Rdata"))) {
        load(path(outputdir,"config.Rdata"))
        title    <- cfg$title
        gms      <- cfg$gms
        input    <- cfg$input
        revision <- cfg$revision
      } else {
        config <- grep("\\.cfg$",list.files(outputdir), value=TRUE)
        l<-readLines(path(outputdir,config))
        title <- strsplit(grep("(cfg\\$|)title +<-",l,value=TRUE),"\"")[[1]][2]
        gms <- list()
        gms$scenarios <- strsplit(grep("(cfg\\$|)gms\\$scenarios +<-",l,value=TRUE),"\"")[[1]][2]
        input <- strsplit(grep("(cfg\\$|)input +<-",l,value=TRUE),"\"")[[1]][2]
        revision <- as.numeric(unlist(strsplit(grep("(cfg\\$|)revision +<-",l,value=TRUE),"<-[ \t]*"))[2])
      }
    }
    
    #Set value source_include so that loaded scripts know, that they are 
    #included as source (instead of a load from command line)
    source_include <- TRUE
   
    cat(paste("\nStarting output generation for",outputdir,"\n\n"))
    
    ###################################################################################
    # Execute R scripts
    ###################################################################################
    
    for(rout in output){
      name<-paste(rout,".R",sep="")
      if(file.exists(paste0("scripts/output/single/",name))){
        if (slurmConfig == "direct") {
          # execute output script directly (without sending it to slurm)
          print(paste("Executing",name))
          tmp.env <- new.env()
          tmp.error <- try(sys.source(paste0("scripts/output/single/",name),envir=tmp.env))
  #        rm(list=ls(tmp.env),envir=tmp.env)
          rm(tmp.env)
          gc()
          if(!is.null(tmp.error)) warning("Script ",name," was stopped by an error and not executed properly!")
        } else {
          # send the output script to slurm
          slurmcmd <- paste0("sbatch ",slurmConfig," --job-name=",outputdir," --output=",outputdir,".txt --mail-type=END --comment=REMIND --wrap=\"Rscript scripts/output/single/",rout,".R  outputdir=",outputdir,"\"")
          cat("Sending to slurm: ",name,"\n")
          system(slurmcmd)
          Sys.sleep(1)
        }
      }
    }
    # finished
    cat(paste("\nFinished output generation for",outputdir,"!\n\n"))
    rm(source_include)
    if(!is.null(warnings())) print(warnings())
  }
}
