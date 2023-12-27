# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
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

  # Create temporary folder. This is necessary because each compareScenarios2
  # run creates a folder named 'figure'. If multiple compareScenarios2 run in
  # parallel they would interfere with the others' figure folder. So we create a
  # temporary subfolder in which each compareScenarios2 creates its own figure
  # folder.
  system(paste0("mkdir ", outFileName)) 
  outDir <- normalizePath(outFileName, mustWork = TRUE)

  outputDirs <- unique(normalizePath(outputDirs, mustWork = TRUE))
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
    outputDir = outDir,
    outputFile = outFileName,
    outputFormat = "pdf"
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
  
  # Check outputFile ending.
  expectedEnding <- paste0(".", tolower(args$outputFormat))
  if (!endsWith(tolower(args$outputFile), expectedEnding)) {
    args$outputFile <- paste0(args$outputFile, expectedEnding)
  }
  
  message("Will make following function call:")
  message("  remind2::compareScenarios2(")
  for (i in seq_along(args)) 
    message("    ", names(args)[i], " = ", capture.output(dput(args[[i]])), if (i < length(args)) ",")
  message("  )")

  message("Calling remind2::compareScenarios2()...\n")
  do.call(compareScenarios2, args)
  
  message("Move outputFile and delete temporary folder.\n")
  outputFilePath <- file.path(args$outputDir, args$outputFile)
  system(paste0("mv ", outputFilePath, " ."))
  system(paste0("rm -rf ", args$outputDir))
  
  message("Done!\n")
}

run_compareScenarios2(outputDirs, outFileName, profileName)
