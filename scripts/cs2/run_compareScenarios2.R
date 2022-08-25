# |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
library(remind2)

if (!exists("source_include")) {
  lucode2::readArgs("outputDirs", "outFileName", "profileName")
}

run_compareScenarios2 <- function(
  outputDirs,
  outFileName,
  profileName
) {
  
  stopifnot(length(profileName) == 1 && is.character(profileName) && !is.na(profileName))
  stopifnot(length(outFileName) == 1 && is.character(outFileName) && !is.na(outFileName))

  # working directory is assumed to be the remind directory

  # load cs2 profiles
  profiles <- getCs2Profiles()

  # Create temporary folder. See comment below.
  system(paste0("mkdir ", outFileName)) 
  outfilepath <- normalizePath(outFileName, mustWork = TRUE)
  
  mifPath <- getMifScenPath(outputDirs, mustWork = TRUE)
  histPath <- getMifHistPath(outputDirs[1], mustWork = TRUE)
  scenConfigPath <- getCfgScenPath(outputDirs, mustWork = TRUE)
  defaultConfigPath <- getCfgDefaultPath(mustWork = TRUE)

  # predefined arguments
  args <- list(
    mifScen = mifPath,
    mifHist = histPath,
    cfgScen = scenConfigPath,
    cfgDefault = defaultConfigPath,
    outputDir = outfilepath,
    outputFile = outFileName
  )

  # Load cs2 profile and change args.
  message("Applying profile ", profileName)
  profile <- profiles[[profileName]]
  # Evaluate entries of profile as R code.
  profileEval <- lapply( 
    names(profile),
    function(nm) {
      eval(
        parse(text = profile[[nm]]), 
        # Set variable . to predefined argument value.
        # This allows refer to the predefined value in the profile expression.
        list("." = args[[nm]])) 
    }
  )
  args[names(profile)] <- profileEval
  
  message("Will make following function call:")
  message("  remind2::compareScenarios2(")
  for (i in seq_along(args)) 
    message("    ", names(args)[i], " = ", capture.output(dput(args[[i]])), ",")
  message("  )")

  # A temporary folder was created above. This is necessary because each
  # compareScenarios2 creates a folder names 'figure'. If multiple
  # compareScenarios2 run in parallel they would interfere with the others'
  # figure folder. So we create a temporary subfolder in which each
  # compareScenarios2 creates its own figure folder.
  wd <- getwd()
  setwd(outfilepath) # working directory now is the temporary folder

  # Move pdf / html file out of temporary folder and remove temporary folder.
  on.exit(system(paste0("mv ", args$outputFile, ".* ..")))
  on.exit(setwd(wd), add = TRUE)  # working directory should be the remind folder after exiting run_compareScenarios2()
  on.exit(system(paste0("rm -rf ", args$outputDir)), add = TRUE)

  message("Calling remind2::compareScenarios2()...\n")
  try(do.call(compareScenarios2, args))
}

run_compareScenarios2(outputDirs, outFileName, profileName)
