# |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
library(lucode2) # getScenNames
library(remind2)

if (!exists("source_include")) {
  readArgs("outputdirs", "outfilename", "regionList", "mainRegName", "profileName")
}

run_compareScenarios2 <- function(
  outputdirs, 
  outfilename, 
  regionList, 
  mainRegName, 
  profileName
) {
  
  # working directory is assumed to be the remind directory

  profilesFilePath <- normalizePath("./scripts/cs2/profiles.csv")
  profiles <- read.delim(
    text = readLines(profilesFilePath, warn = FALSE), 
    header = TRUE, 
    sep = ";",
    colClasses = "character",
    comment.char = "#",
    quote = "")
  
  scenNames <- getScenNames(outputdirs)
  
  system(paste0("mkdir ", outfilename)) # create temporary folder
  
  outputdirs <- normalizePath(outputdirs) # make paths absolute
  outfilepath <- normalizePath(outfilename)
  mif_path  <- file.path(outputdirs, paste("REMIND_generic_", scenNames, ".mif", sep = ""))
  mif_path_polCosts  <- file.path(
    outputdirs, 
    paste("REMIND_generic_", scenNames, "_adjustedPolicyCosts.mif", sep = ""))
  mif_path <- ifelse(file.exists(mif_path_polCosts), mif_path_polCosts, mif_path)
  hist_path <- file.path(outputdirs[1], "historical.mif")
  scen_config_path  <- file.path(outputdirs, "config.Rdata")
  default_config_path  <- normalizePath("./config/default.cfg")
  
  message("Using these mif paths:\n - ", paste(c(hist_path, mif_path), collapse = "\n - "))
  message("Using this temporary folder:\n - ", outfilepath)
  
  # default arguments
  args <- list(
    mifScen = mif_path,
    mifHist = hist_path,
    cfgScen = scen_config_path,
    cfgDefault = default_config_path,
    outputDir = outfilepath,
    outputFile = outfilename,
    outputFormat = "PDF",
    reg = regionList,
    mainReg = mainRegName
  )
  
  # If profileName is a single non-empty string, load cs2 profile and change args. 
  if (
    length(profileName) == 1 && 
    is.character(profileName) && 
    !is.na(profileName) && 
    nchar(profileName) > 1
  ) {
    message("applying profile ", profileName)
    profile <- as.list(profiles[profiles$name == profileName, ])
    profile$name <- NULL
    profile <- lapply(profile, trimws)
    profile <- profile[vapply(profile, function(s) nchar(s)>0, logical(1))]
    profileEval <- lapply(
      names(profile), 
      function(nm) {
        eval(parse(text = profile[[nm]]), list("." = args[[nm]]))
      }
    )
    args[names(profile)] <- profileEval
  } else {
    message("using default profile")
  }
  
  # Create temporary folder. This is necessary because each compareScenarios2 creates a folder names 'figure'.
  # If multiple compareScenarios2 run in parallel they would interfere with the others' figure folder.
  # So we create a temporary subfolder in which each compareScenarios2 creates its own figure folder.
  wd <- getwd()
  setwd(outfilepath) # working directory now is the temporary folder
  
  # move pdf / html file out of temporary folder and remove temporary folder
  on.exit(system(paste0("mv ", args$outputFile, ".* ..")))
  on.exit(setwd(wd), add = TRUE)  # working directory should be the remind folder after exiting run_compareScenarios2()
  on.exit(system(paste0("rm -rf ", args$outputDir)), add = TRUE)
  
  try(do.call(compareScenarios2, args))
}

run_compareScenarios2(outputdirs, outfilename, regionList, mainRegName, profileName)
