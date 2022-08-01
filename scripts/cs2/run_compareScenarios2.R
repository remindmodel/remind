# |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
library(lucode2) # getScenNames
library(remind2)

if (!exists("source_include")) {
  readArgs("outputDirs", "outFileName", "profileName")
}

run_compareScenarios2 <- function(
  outputDirs,
  outFileName,
  profileName
) {

  # working directory is assumed to be the remind directory

  # load cs2 profiles
  profilesFilePath <- normalizePath("./scripts/cs2/profiles.json")
  profiles <- jsonlite::read_json(profilesFilePath, simplifyVector = FALSE)
  profiles <- profiles[!startsWith(names(profiles), "_")] # remove comments

  scenNames <- getScenNames(outputDirs)

  system(paste0("mkdir ", outFileName)) # create temporary folder

  outputDirs <- normalizePath(outputDirs) # make paths absolute
  outfilepath <- normalizePath(outFileName)
  mifPath  <- file.path(outputDirs, paste("REMIND_generic_", scenNames, ".mif", sep = ""))
  mifPathPolCosts  <- file.path(
    outputDirs,
    paste("REMIND_generic_", scenNames, "_adjustedPolicyCosts.mif", sep = ""))
  mifPath <- ifelse(file.exists(mifPathPolCosts), mifPathPolCosts, mifPath)
  histPath <- file.path(outputDirs[1], "historical.mif")
  scenConfigPath  <- file.path(outputDirs, "config.Rdata")
  defaultConfigPath  <- normalizePath("./config/default.cfg")

  message("Using these mif paths:\n - ", paste(c(histPath, mifPath), collapse = "\n - "))
  message("Using this temporary folder:\n - ", outfilepath)

  # default arguments
  args <- list(
    mifScen = mifPath,
    mifHist = histPath,
    cfgScen = scenConfigPath,
    cfgDefault = defaultConfigPath,
    outputDir = outfilepath,
    outputFile = outFileName,
    outputFormat = "PDF"
  )

  # If profileName is a single non-empty string, load cs2 profile and change args.
  if (
    length(profileName) == 1 &&
    is.character(profileName) &&
    !is.na(profileName) &&
    nchar(profileName) > 1
  ) {
    message("Applying profile ", profileName)
    profile <- profiles[[profileName]]
    profileEval <- lapply( # evaluate entries of profile as R code
      names(profile),
      function(nm) {
        eval(parse(text = profile[[nm]]), list("." = args[[nm]]))
      }
    )
    args[names(profile)] <- profileEval
  } else {
    message("Using default profile")
  }
  
  message("Use following cs2 settings:")
  for (i in seq_len(args)) message("  ", names(args)[i], " = ", dput(args[[i]]))

  # Create temporary folder. This is necessary because each compareScenarios2 creates a folder names 'figure'.
  # If multiple compareScenarios2 run in parallel they would interfere with the others' figure folder.
  # So we create a temporary subfolder in which each compareScenarios2 creates its own figure folder.
  wd <- getwd()
  setwd(outfilepath) # working directory now is the temporary folder

  # move pdf / html file out of temporary folder and remove temporary folder
  on.exit(system(paste0("mv ", args$outputFile, ".* ..")))
  on.exit(setwd(wd), add = TRUE)  # working directory should be the remind folder after exiting run_compareScenarios2()
  on.exit(system(paste0("rm -rf ", args$outputDir)), add = TRUE)

  message("Calling remind2::compareScenarios2()...\n")
  try(do.call(compareScenarios2, args))
}

run_compareScenarios2(outputDirs, outFileName, profileName)
