# |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

require(lucode2, quietly = TRUE, warn.conflicts = FALSE)

source("scripts/start/submit.R")
source("scripts/start/choose_slurmConfig.R")

# Choose submission type
slurmConfig <- choose_slurmConfig()

.setgdxcopy <- function(needle, stack, new) {
  # delete entries in stack that contain needle and append new
  out <- c(stack[-grep(needle, stack)], new)
  return(out)
}

# check for config file parameter
config.file <- commandArgs(trailingOnly = TRUE)[1]
if (  is.na(config.file)                          # no parameter given
    | -1 == file.access(config.file, mode = 4))   # if file can't be read
  config.file <- "config/scenario_config.csv" 

cat(paste("reading config file", config.file, "\n"))
  
# Read-in the switches table, use first column as row names
settings <- read.csv2(config.file, stringsAsFactors = FALSE, row.names = 1, 
                      comment.char = "#", na.strings = "")

# Select scenarios that are flagged to start
scenarios  <- settings[settings$start==1,]

# some checks for title
if (any(nchar(rownames(scenarios)) > 75)) stop(paste0("These titles are too long: ", paste0(rownames(scenarios)[nchar(rownames(scenarios)) > 75], collapse = ", "), " – GAMS would not tolerate this, and quit working at a point where you least expect it. Stopping now."))
if (length(grep("\\.", rownames(scenarios))) > 0) stop(paste0("These titles contain dots: ", paste0(rownames(scenarios)[grep("\\.", rownames(scenarios))], collapse = ", "), " – GAMS would not tolerate this, and quit working at a point where you least expect it. Stopping now."))
if (length(grep("_$", rownames(scenarios))) > 0) stop(paste0("These titles end with _: ", paste0(rownames(scenarios)[grep("_$", rownames(scenarios))], collapse = ", "), ". This may lead start_bundle_climate.R to select wrong gdx files. Stopping now."))

#AJS runs all scenarios as all SSPs, as specified in this file:
meta_tcre = read.csv('config/scenario_meta_rcp.csv',stringsAsFactors = FALSE,comment.char = "#")
rownames(meta_tcre) = meta_tcre[,1]

print(names(meta_tcre))
print(names(scenarios))

scenarios = do.call(rbind,lapply( rownames(meta_tcre),function(s){
  tmp = cbind(scenarios,meta_tcre[s,])
  rownames(tmp) = paste0(rownames(tmp),"_",s)
  tmp
}))

print(scenarios)

#really, land-use libraries?
settings = scenarios

# Modify and save cfg for all runs
for (scen in rownames(scenarios)) {
  #source cfg file for each scenario to avoid duplication of gdx entries in files2export
  source("config/default.cfg")

  # Have the log output written in a file (not on the screen)
  cfg$slurmConfig <- slurmConfig
  cfg$logoption  <- 2
  cfg$sequential <- NA

  # Edit run title
  cfg$title <- scen
  cat("\n", scen, "\n")

  # Edit main model file, region settings and input data revision based on scenarios table, if cell non-empty
  for (switchname in intersect(c("model", "regionmapping", "inputRevision"), names(scenarios))) {
    if ( !is.na(scenarios[scen, switchname] )) {
      cfg[[switchname]] <- scenarios[scen, switchname]
    }
  }

  # Set description
  if ("description" %in% names(scenarios) && ! is.na(scenarios[scen, "description"])) {
    cfg$description <- gsub('"', '', scenarios[scen, "description"])
  } else {
    cfg$description <- paste0("REMIND climate run ", scen, " started by ", config.file, ".")
  }

  # Edit switches in default.cfg based on scenarios table, if cell non-empty
  for (switchname in intersect(names(cfg$gms), names(scenarios))) {
    if ( !is.na(scenarios[scen, switchname] )) {
      cfg$gms[[switchname]] <- scenarios[scen, switchname]
    }
  }

  # check if full input.gdx path is provided and, if not, search for correct path
  if (!substr(settings[scen,"path_gdx"], nchar(settings[scen,"path_gdx"])-3, nchar(settings[scen,"path_gdx"])) == ".gdx"){
    #if there is no correct scenario folder within the output folder path provided, take the config/input.gdx
    if(length(grep(scen,list.files(path=settings[scen,"path_gdx"]),value=T))==0){
      settings[scen,"path_gdx"] <- "config/input.gdx"
    #if there is only one instance of an output folder with that name, take the fulldata.gdx from this 
    } else if (length(grep(scen,list.files(path=settings[scen,"path_gdx"]),value=T))==1){
      settings[scen,"path_gdx"] <- paste0(settings[scen,"path_gdx"],"/",
                                          grep(scen,list.files(path=settings[scen,"path_gdx"]),value=T),"/fulldata.gdx")
    } else {
      #if there are multiple instances, take the newest one
      settings[scen,"path_gdx"] <- paste0(settings[scen,"path_gdx"],"/",
                                          substr(grep(scen,list.files(path=settings[scen,"path_gdx"]),value=T),1,
                                                 nchar(grep(scen,list.files(path=settings[scen,"path_gdx"]),value=T))-19)[1],      
      max(substr(grep(scen,list.files(path=settings[scen,"path_gdx"]),value=T),
                               nchar(grep(scen,list.files(path=settings[scen,"path_gdx"]),value=T))-18,
                               nchar(grep(scen,list.files(path=settings[scen,"path_gdx"]),value=T)))),"/fulldata.gdx")
    }
  }
  
  # if the above has not created a path to a valid gdx, take config/input.gdx
  if (!file.exists(settings[scen,"path_gdx"])){
    settings[scen,"path_gdx"] <- "config/input.gdx"
    #if even this is not existent, stop
    if (!file.exists(settings[scen,"path_gdx"])){
    stop("Cant find a gdx under path_gdx, please specify full path to gdx or else location of output folder that contains previous run")
    }
  }
 
  # Define path where the GDXs will be taken from
  gdxlist <- c(input.gdx     = settings[scen, "path_gdx"],
               input_ref.gdx = settings[scen, "path_gdx_ref"],
               input_bau.gdx = settings[scen, "path_gdx_bau"])

  # Remove potential elements that contain ".gdx" and append gdxlist
  cfg$files2export$start <- .setgdxcopy(".gdx", cfg$files2export$start, gdxlist)

  # add gdx information for subsequent runs
  cfg$subsequentruns        <- rownames(settings[settings$path_gdx_ref == scen & !is.na(settings$path_gdx_ref) & settings$start == 1,])
  cfg$RunsUsingTHISgdxAsBAU <- rownames(settings[settings$path_gdx_bau == scen & !is.na(settings$path_gdx_bau) & settings$start == 1,])
  
  # save the cfg data for later start of subsequent runs (after preceding run finished)
  cat("Writing cfg to file\n")
  save(cfg,file=paste0(scen,".RData"))
}

# Directly start runs that have a gdx file location given as path_gdx_ref or where this field is empty
for (scen in rownames(scenarios)) {
  if (substr(settings[scen,"path_gdx_ref"], nchar(settings[scen,"path_gdx_ref"])-3, nchar(settings[scen,"path_gdx_ref"])) == ".gdx" 
     | is.na(settings[scen,"path_gdx_ref"])){
   cat("Starting: ",scen,"\n")
   load(paste0(scen,".RData"))
   submit(cfg)
   }
}
