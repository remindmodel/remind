# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

prepare <- function() {

  timePrepareStart <- Sys.time()

  # Load libraries
  #require(lucode, quietly = TRUE,warn.conflicts =FALSE)
  require(magclass, quietly = TRUE,warn.conflicts =FALSE)
  require(tools, quietly = TRUE,warn.conflicts =FALSE)
  require(remind2, quietly = TRUE,warn.conflicts =FALSE)

  .copy.fromlist <- function(filelist,destfolder) {
    if(is.null(names(filelist))) names(filelist) <- rep("",length(filelist))
    for(i in 1:length(filelist)) {
      if(!is.na(filelist[i])) {
        to <- paste0(destfolder,"/",names(filelist)[i])
	      if(!file.copy(filelist[i],to=to,recursive=dir.exists(to),overwrite=T)) {
           cat(paste0("Could not copy ",filelist[i]," to ",to,"\n"))
        } else {
           cat(paste0("Copied ",filelist[i]," to ",to,"\n"))
        }
	        
      }
	  }
  }

  # Display git information
  cat("\n===== git info =====\nLatest commit: ")
  cat(try(system("git show -s --format='%h %ci %cn'", intern=TRUE), silent=TRUE),"\nChanges since then: ")
  cat(paste(try(system("git status", intern=TRUE), silent=TRUE),collapse="\n"))

  # print version information of installed packages
  cat("\n\n==== installed package versions =====\n")
  installed.packages() %>%
    # printing a tibble instead of a list makes for a table that is easier to
    # compare
    as_tibble() %>%
    select(Package, Version) %>%
    # using right_join instead of filter generates NA for packages that are not
    # installed
    right_join(
    # list all packages of interest here
        tribble(
            ~Package, "data.table", "devtools", "dplyr", "edgeTransport",
            "flexdashboard", "gdx", "gdxdt", "gdxrrw", "ggplot2", "gtools",
            "lucode2", "luplot", "luscale", "magclass", "magpie4", "methods",
            "mip", "optparse", "parallel",
            "plotly", "remind2", "reticulate", "rlang", "rmndt", "tidyverse",
            "tools"),

        'Package') %>%
    print(n = Inf)
  cat("\n==========\n")

  load("config.Rdata")

  # Store results folder of current scenario
  on.exit(setwd(cfg$results_folder))

  # change to REMIND main folder
  setwd(cfg$remind_folder)

  cfg <- checkFixCfg(cfg, remindPath = cfg$remind_folder)

  #AJS quit if title is too long - GAMS can't handle that
  if( nchar(cfg$title) > 75 | grepl("\\.",cfg$title) ) {
      stop("This title is too long or the name contains dots - GAMS would not tolerate this, and quit working at a point where you least expect it. Stopping now. ")
  }

  # Is the run performed on the cluster?
  on_cluster    <- file.exists('/p')

  ################## M O D E L   L O C K ###################################
  # Lock the directory for other instances of the start scripts
  lock_id <- model_lock(timeout1 = 1)
  on.exit() # set the commands when exiting in the correct order
  on.exit(model_unlock(lock_id),add=TRUE)
  on.exit(setwd(cfg$results_folder),add=TRUE)
  ################## M O D E L   L O C K ###################################

  ###########################################################
  ### PROCESSING INPUT DATA ###################### START ####
  ###########################################################

  # update input files based on previous runs if applicable
  # ATTENTION: modifying gms files

  # Create input file with exogenous CO2 tax using the CO2 price from another run
  if(!is.null(cfg$gms$carbonprice) && (cfg$gms$carbonprice %in% c("exogenous", "exogenousExpo")) && (!is.na(cfg$files2export$start["input_carbonprice.gdx"]))){
    cat("\nRun scripts/input/create_input_for_45_carbonprice_exogenous.R to create input file with exogenous CO2 tax from another run.\n")
    source("scripts/input/create_input_for_45_carbonprice_exogenous.R")
    create_input_for_45_carbonprice_exogenous(as.character(cfg$files2export$start["input_carbonprice.gdx"]), cfg$gms$carbonprice)
  }

  # If a path to a MAgPIE report is supplied use it as REMIND input (used for REMIND-MAgPIE coupling)
  # ATTENTION: modifying gms files
  if (!is.null(cfg$pathToMagpieReport)) {
    getReportData(
      path_to_report = cfg$pathToMagpieReport,
      inputpath_mag  = cfg$gms$biomass,
      inputpath_acc  = cfg$gms$agCosts,
      var_luc        = cfg$var_luc
    )
  }

  # Update module paths in GAMS code
  update_modules_embedding()

  # Check all setglobal settings for consistency
  settingsCheck()

  # use main model gms file (cfg$model) and create modified version based on settings in cfg$gms
  # use main.gms if not further specified
  if (is.null(cfg$model)) cfg$model <- "main.gms"
  # add info from cfg into cfg$gams so it ends up in gams.
  cfg$gms$c_expname <- cfg$title
  cfg$gms$c_description <- substr(cfg$description, 1, 255)
  cfg$gms$c_results_folder <- substr(normalizePath(cfg$results_folder), 1, 255)
  cfg$gms$c_model_version <- gsub("[^a-zA-Z0-9]", "-", substr(cfg$model_version, 1, 255))
  # create modified version
  tmpModelFile <- sub(".gms", paste0("_", cfg$title, ".gms"), cfg$model)
  file.copy(cfg$model, tmpModelFile, overwrite = TRUE)
  manipulateConfig(tmpModelFile, cfg$gms)

  ######## declare functions for updating information ####
  update_info <- function(regionscode, revision, model_version) {

    subject <- "VERSION INFO"
    content <- c("",
      paste("Modelversion:", model_version),
      "",
      paste("Regionscode:", regionscode),
      "",
      paste("Input data revision:", revision),
      "",
      paste("Last modification (input data):",
            format(file.mtime("input/source_files.log"), "%a %b %d %H:%M:%S %Y")),
      "")
    replace_in_file(tmpModelFile, paste("*", content), subject)
  }

  ############ download and distribute input data ########
  # check whether the regional resolution and input data revision are outdated and update data if needed
  cfg <- updateInputData(cfg, remindPath = ".")

  # extract BAU emissions for NDC runs to set up emission goals for region where only some countries have a target
  if (isTRUE(cfg$gms$carbonprice == "NDC") || isTRUE(cfg$gms$carbonpriceRegi == "NDC")) {
    cat("\nRun scripts/input/prepare_NDC.R.\n")
    source("scripts/input/prepare_NDC.R")
    prepare_NDC(as.character(cfg$files2export$start["input_bau.gdx"]), cfg)
  }

  ############ update information ########################
  # update_info, which regional resolution and input data revision in tmpModelFile
  update_info(madrat::regionscode(cfg$regionmapping), cfg$inputRevision, cfg$model_version)
  # updateSets, which is updating the region-depending sets in core/sets.gms
  #-- load new mapping information
  updateSets(cfg)

  ########################################################
  ### PROCESSING INPUT DATA ###################### END ###
  ########################################################

  ### ADD MODULE INFO IN SETS  ############# START #######
  content <- NULL
  modification_warning <- c(
    '*** THIS CODE IS CREATED AUTOMATICALLY, DO NOT MODIFY THESE LINES DIRECTLY',
    '*** ANY DIRECT MODIFICATION WILL BE LOST AFTER NEXT MODEL START',
    '*** CHANGES CAN BE DONE USING THE RESPECTIVE LINES IN scripts/start/prepare.R')
  content <- c(modification_warning,'','sets')
  content <- c(content,'','       modules "all the available modules"')
  content <- c(content,'       /',paste0("       ",getModules("modules/")[,"name"]),'       /')
  content <- c(content,'','module2realisation(modules,*) "mapping of modules and active realisations" /')
  content <- c(content,paste0("       ",getModules("modules/")[,"name"]," . %",getModules("modules/")[,"name"],"%"))
  content <- c(content,'      /',';')
  replace_in_file('core/sets.gms',content,"MODULES",comment="***")
  ### ADD MODULE INFO IN SETS  ############# END #########

  # copy right gdx file to the output folder
  gdx_name <- paste0("config/gdx-files/",cfg$gms$cm_CES_configuration,".gdx")
  if (0 != system(paste('cp', gdx_name,
			file.path(cfg$results_folder, 'input.gdx')))) {
    stop('Could not copy gdx file ', gdx_name)
  } else {
    message('Copied ', gdx_name, ' to input.gdx')
  }

  # choose which conopt files to copy
  cfg$files2export$start <- sub("conopt3",cfg$gms$cm_conoptv,cfg$files2export$start)

  # Copy important files into output_folder (before REMIND execution)
  namedfiles <- names(cfg$files2export$start[! is.na(cfg$files2export$start)])
  for (namedfile in namedfiles["" != namedfiles]) {
    message("Try to copy ", cfg$files2export$start[namedfile], " to ", namedfile, ".")
  }
  .copy.fromlist(cfg$files2export$start,cfg$results_folder)

  # Save configuration
  save(cfg, file = file.path(cfg$results_folder, "config.Rdata"))

  # Merge GAMS files
  message("\n", round(Sys.time()), ": Creating full.gms")

  # only compile the GAMS file to catch compilation errors and create a dump
  # file with the full code
  modelFilePathStem <- substr(tmpModelFile, 1, nchar(tmpModelFile) - 4)
  dumpFilePath <- paste0(modelFilePathStem, ".dmp")
  listFilePath <- paste0(modelFilePathStem, ".lst")
  logFilePath <- paste0(modelFilePathStem, ".log")

  exitcode <- system2(cfg$gamsv, c(tmpModelFile, "action=c", "dumpopt=21",
                                   "logoption=", cfg$logoption))

  # move compilation files to results directory and rename appropriately, but
  # only if they exist.
  from <- c(dumpFilePath, listFilePath, tmpModelFile, logFilePath)
  to <- file.path(cfg$results_folder, c('full.gms', 'main.lst', 'main.gms',
                                        'main.log'))
  exist <- file.exists(from)
  # if any of the files main.dmp, main.lst, or main.gms is missing, panic!
  # (honestly, no idea how that could happen, but you never know)
  if (!all(exist[1:3])) {
      stop('Something went horribly wrong, the files ',
           paste(from[which(!exist[1:3])], collapse = ', '),
           ' are missing.  Call RSE immediately')
  }

  file.rename(from[exist], to[exist])

  if ( 0 < exitcode ) {
      stop("Compiling ", tmpModelFile, " failed, stopping.", "\n",
           "Use `less -j 4 --pattern='^\\*\\*\\*\\*' ",
           file.path(cfg$results_folder, "main.lst"), "` to investigate ",
           "compilation errors.")
  }

  # Collect run statistics (will be saved to central database in submit.R)
  lucode2::runstatistics(file = paste0(cfg$results_folder,"/runstatistics.rda"),
                        user = Sys.info()[["user"]],
                        date = Sys.time(),
                        version_management = "git",
                        revision = try(system("git rev-parse --short HEAD", intern=TRUE), silent=TRUE),
                        #revision_date = try(as.POSIXct(system("git show -s --format=%ci", intern=TRUE), silent=TRUE)),
                        status = try(system("git status", intern=TRUE), silent=TRUE))

  ################## M O D E L   U N L O C K ###################################
  # After full.gms was produced remind folders have to be unlocked to allow setting up the next run
  model_unlock(lock_id)
  # Reset on.exit: Prevent model_unlock from being executed again at the end
  # and remove "setwd(cfg$results_folder)" from on.exit, becaue we change to it in the next line
  on.exit()
  ################## M O D E L   U N L O C K ###################################

  setwd(cfg$results_folder)

  write_yaml(cfg,file="cfg.txt")

  # Function to create the levs.gms, fixings.gms, and margs.gms files, used in
  # delay scenarios.
  create_fixing_files <- function(cfg, input_ref_file = "input_ref.gdx") {

    # Start the clock.
    begin <- Sys.time()
    message("\n", round(begin), ": Creating fixing files...")

    # Extract data from input_ref.gdx file and store in levs_margs_ref.gms.
    system(paste("gdxdump",
                 input_ref_file,
                 "Format=gamsbas Delim=comma FilterDef=N Output=levs_margs_ref.gms",
                 sep = " "))

    # Read data from levs_margs_ref.gms.
    ref_gdx_data <- suppressWarnings(readLines("levs_margs_ref.gms"))
    # Read variables and equations that are declared in this run
    varsAndEqs <- gms::readDeclarations("full.gms", types = c("equation", "(positive |negative |)variable"))[, "names"]
    # Keep only lines with declared variables, gams operators or empty lines
    ref_gdx_data_vars <- stringr::str_extract(ref_gdx_data, "[^ .]+")
    keepVarsAndEqs <- c(varsAndEqs, "$onEmpty", "$offListing", "$offEmpty", "$onListing", NA)
    toberemoved <- sort(setdiff(unique(ref_gdx_data_vars), keepVarsAndEqs))
    notfixed <- sort(setdiff(varsAndEqs, ref_gdx_data_vars))
    ref_gdx_data <- ref_gdx_data[ref_gdx_data_vars %in% keepVarsAndEqs]
    # Tell users which variables were removed
    if (length(toberemoved) > 0) {
      message("Because they are not declared, the fixings for these variables and equations will be dropped:")
      message(paste0(toberemoved, collapse = ", "))
    }
    if (length(notfixed) > 0) {
      message("Because they are not available in path_gdx_ref, these variables and equations cannot be fixed:")
      message(paste0(notfixed, collapse = ", "))
    }

    # Create fixing files.
    cat("\n")
    create_standard_fixings(cfg, ref_gdx_data)

    # Stop the clock.
    cat("Time it took to create the fixing files: ")
    manipulate_runtime <- Sys.time()-begin
    print(manipulate_runtime)
    cat("\n")


    # Delete file.
    file.remove("levs_margs_ref.gms")

  }


  # Function to create the levs.gms, fixings.gms, and margs.gms files, used in
  # the standard (i.e. the non-macro stand-alone) delay scenarios.
  create_standard_fixings <- function(cfg, ref_gdx_data) {

    # Declare empty lists to hold the strings for the 'manipulateFile' functions.
    manipulateThis <- NULL

    # these lists can be used to comment out or rename stuff in such way, with the dot
    # needed to terminate the variable or equation name:
    # manipulateThis <- c(manipulateThis,
    #   list(c("vm_forcOs.", "!!vm_forcOs.")),
    #   list(c("q_oldname.", "q_newname.")))

    str_years <- c()
    no_years  <- (cfg$gms$cm_startyear - 2005) / 5

    # Write level values to file
    levs <- c()
    for (i in 1:no_years) {
      str_years[i] <- paste("L \\('", 2000 + i * 5, sep = "")
      levs         <- c(levs, grep(str_years[i], ref_gdx_data, value = TRUE))
    }

    writeLines(levs, "levs.gms")

    # Write marginal values to file
    margs <- c()
    str_years    <- c()
    for (i in 1:no_years) {
      str_years[i] <- paste("M \\('", 2000 + i * 5, sep = "")
      margs        <- c(margs, grep(str_years[i], ref_gdx_data, value = TRUE))
    }
    writeLines(margs, "margs.gms")
    # manipulate files
    if (length(manipulateThis) > 0) {
      manipulateFile("margs.gms", manipulateThis, fixed = TRUE)
      manipulateFile("levs.gms", manipulateThis, fixed = TRUE)
    }
    file.copy("levs.gms", "fixings.gms", overwrite = TRUE)
    # Replace fixings with level values
    manipulateFile("fixings.gms", list(c(".L ", ".FX ")), fixed = TRUE)

    # Include fixings (levels) and marginals in full.gms at predefined position
    # in core/loop.gms.
    full_manipulateThis <- list(c("cb20140305readinpositionforfixingfiles",
                                  paste("offlisting inclusion of levs.gms, fixings.gms, and margs.gms",
                                        "$offlisting",
                                        "$include \"levs.gms\";",
                                        "$include \"fixings.gms\";",
                                        "$include \"margs.gms\";",
                                        "$onlisting", sep = "\n")))

    # Perform actual manipulation on full.gms, in single parse of the text.
    manipulateFile("full.gms", full_manipulateThis, fixed = TRUE)
  }

  # Prepare the files containing the fixings for delay scenarios (for fixed runs)
  if (  cfg$gms$cm_startyear > 2005  & (!file.exists("levs.gms.gz") | !file.exists("levs.gms"))) {
    create_fixing_files(cfg = cfg, input_ref_file = "input_ref.gdx")
  }

  if (cfg$gms$cm_startyear > 2005) {
    cm_startyear_ref <- as.integer(readGDX("input_ref.gdx", name = "cm_startyear", format = "simplest"))
    if (cfg$gms$cm_startyear < cm_startyear_ref) stop("cm_startyear must be larger than its counterpart in input_ref.gdx")
  }

  timePrepareEnd <- Sys.time()
  # Save run statistics to local file
  cat("Saving timePrepareStart and timePrepareEnd to runstatistics.rda\n")
  lucode2::runstatistics(file           = paste0("runstatistics.rda"),
                      timePrepareStart = timePrepareStart,
                      timePrepareEnd   = timePrepareEnd)

  # on.exit sets working directory to results folder
}
