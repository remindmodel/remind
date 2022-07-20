# |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
library(lucode2) # getScenNames
library(remind2)

if (!exists("source_include")) {
  modelsHistExclude <- c()
  profile <- ""
  readArgs("outputdirs", "shortTerm", "outfilename", "regionList", "mainRegName", "modelsHistExclude", "profileName")
}

run_compareScenarios2 <- function(
  outputdirs, 
  shortTerm, 
  outfilename, 
  regionList, 
  mainRegName, 
  modelsHistExclude, 
  profileName
) {

  scenNames <- getScenNames(outputdirs)
  # for non-absolute paths, add '../' in front of the paths as compareScenarios2() will be run in individual temporary subfolders (see below).
  outputdirs <- ifelse(substr(outputdirs,1,1) == "/", outputdirs, file.path("..", outputdirs))
  mif_path  <- file.path(outputdirs, paste("REMIND_generic_", scenNames, ".mif", sep = ""))
  mif_path_polCosts  <- file.path(outputdirs, paste("REMIND_generic_", scenNames, "_adjustedPolicyCosts.mif", sep = ""))
  hist_path <- file.path(outputdirs[1], "historical.mif")
  scen_config_path  <- file.path(outputdirs, "config.Rdata")
  default_config_path  <- file.path("..", "config", "default.cfg")
  profilesFilePath <- normalizePath("./scripts/cs2/profiles.csv")
  profiles <- read.delim(
    profilesFilePath, 
    header = TRUE, 
    sep = ";",
    colClasses = "character")
  
  # Create temporary folder. This is necessary because each compareScenarios2 creates a folder names 'figure'.
  # If multiple compareScenarios2 run in parallel they would interfere with the others' figure folder.
  # So we create a temporary subfolder in which each compareScenarios2 creates its own figure folder.
  system(paste0("mkdir ", outfilename))
  outfilepath <- normalizePath(outfilename) # Make path absolute.
  wd <- getwd()

  setwd(outfilepath)
  # remove temporary folder
  on.exit(system(paste0("mv ", outfilename, ".pdf ..")))
  on.exit(setwd(wd), add = TRUE)
  on.exit(system(paste0("rm -rf ", outfilename)), add = TRUE)

  # Use adjustedPolicyCosts mif, if available
  mif_path <- ifelse(file.exists(mif_path_polCosts), mif_path_polCosts, mif_path)

  # Make paths absolute.
  mif_path <- normalizePath(mif_path)
  hist_path <- normalizePath(hist_path)

  message("Using these mif paths:\n - ", paste(c(hist_path, mif_path), collapse = "\n - "))
  
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
    mainReg = mainRegName,
    modelsHistExclude = modelsHistExclude
  )
  
  # If profile is a single non-empty string, load cs2 profile and change args. 
  if (
    length(profileName) == 1 && 
    is.character(profileName) && 
    !is.na(profileName) && 
    nchar(profileName) > 1
  ) {
    message("Try to apply profile: ", profileName)
    if (!profileName %in% profiles$name) stop(
      "Did not find profile ", profileName, 
      " in name column of ", profilesFilePath, "."
      )
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
    message("Use default profile.")
  }
  
  try(do.call(compareScenarios2, args))
}

run_compareScenarios2(outputdirs, shortTerm, outfilename, regionList, mainRegName, modelsHistExclude, profileName)
