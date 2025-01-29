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
  require(mrremind)
  require(mrvalidation)

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
            "mip", "mrremind", "mrvalidation", "optparse", "parallel",
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
  if(!is.null(cfg$gms$carbonprice) && (cfg$gms$carbonprice == "exogenous") && (!is.na(cfg$files2export$start["input_carbonprice.gdx"]))){
    cat("\nRun scripts/input/create_input_for_45_carbonprice_exogenous.R to create input file with exogenous CO2 tax from another run.\n")
    source("scripts/input/create_input_for_45_carbonprice_exogenous.R")
    create_input_for_45_carbonprice_exogenous(as.character(cfg$files2export$start["input_carbonprice.gdx"]))
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
  message("\nCreating full.gms")

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

    # Extract data from input_ref.gdx file and store in levs_margs_ref.gms.
    system(paste("gdxdump",
                 input_ref_file,
                 "Format=gamsbas Delim=comma FilterDef=N Output=levs_margs_ref.gms",
                 sep = " "))

    # Read data from levs_margs_ref.gms.
    ref_gdx_data <- suppressWarnings(readLines("levs_margs_ref.gms"))

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
    full_manipulateThis <- NULL
    levs_manipulateThis <- NULL
    fixings_manipulateThis <- NULL
    margs_manipulateThis <- NULL

    str_years <- c()
    no_years  <- (cfg$gms$cm_startyear - 2005) / 5

    # Write level values to file
    levs <- c()
    for (i in 1:no_years) {
      str_years[i] <- paste("L \\('", 2000 + i * 5, sep = "")
      levs         <- c(levs, grep(str_years[i], ref_gdx_data, value = TRUE))
    }

    writeLines(levs, "levs.gms")

    # Replace fixings.gms with level values
    file.copy("levs.gms", "fixings.gms", overwrite = TRUE)

    fixings_manipulateThis <- c(fixings_manipulateThis, list(c(".L ", ".FX ")))
    #cb q_co2eq is only "static" equation to be active before cm_startyear, as multigasscen could be different from a scenario to another that is fixed on the first
    #cb therefore, vm_co2eq cannot be fixed, otherwise infeasibilities would result. vm_co2eq.M is meaningless, is never used in the code (a manipulateFile delete line command would be even better)
    #  manipulateFile("fixings.gms", list(c("vm_co2eq.FX ", "vm_co2eq.M ")))

    # Write marginal values to file
    margs <- c()
    str_years    <- c()
    for (i in 1:no_years) {
      str_years[i] <- paste("M \\('", 2000 + i * 5, sep = "")
      margs        <- c(margs, grep(str_years[i], ref_gdx_data, value = TRUE))
    }
    writeLines(margs, "margs.gms")
     # temporary fix so that you can use older gdx for fixings - will become obsolete in the future and can be deleted once the next variable name change is done
    margs_manipulateThis <- c(margs_manipulateThis, list(c("q_taxrev","q21_taxrev")))
    # fixing for SPA runs based on ModPol input data
    margs_manipulateThis <- c(margs_manipulateThis,
                              list(c("q41_emitrade_restr_mp.M", "!!q41_emitrade_restr_mp.M")),
                              list(c("q41_emitrade_restr_mp2.M", "!!q41_emitrade_restr_mp2.M")))

    #AJS this symbol is not known and crashes the run - is it deprecated? TODO
    levs_manipulateThis <- c(levs_manipulateThis,
                             list(c("vm_pebiolc_price_base.L", "!!vm_pebiolc_price_base.L")))

    #AJS filter out nash marginals in negishi case, as they would lead to a crash when trying to fix on them:
    if(cfg$gms$optimization == 'negishi'){
      margs_manipulateThis <- c(margs_manipulateThis, list(c("q80_costAdjNash.M", "!!q80_costAdjNash.M")))
    }
    if(cfg$gms$subsidizeLearning == 'off'){
      levs_manipulateThis <- c(levs_manipulateThis,
                               list(c("v22_costSubsidizeLearningForeign.L",
                                      "!!v22_costSubsidizeLearningForeign.L")))
      margs_manipulateThis <- c(margs_manipulateThis,
                                list(c("q22_costSubsidizeLearning.M", "!!q22_costSubsidizeLearning.M")),
                                list(c("v22_costSubsidizeLearningForeign.M",
                                       "!!v22_costSubsidizeLearningForeign.M")),
                                list(c("q22_costSubsidizeLearningForeign.M",
                                       "!!q22_costSubsidizeLearningForeign.M")))
      fixings_manipulateThis <- c(fixings_manipulateThis,
                                  list(c("v22_costSubsidizeLearningForeign.FX",
                                         "!!v22_costSubsidizeLearningForeign.FX")))

    }

    #JH filter out negishi marginals in nash case, as they would lead to a crash when trying to fix on them:
    if(cfg$gms$optimization == 'nash'){
      margs_manipulateThis <- c(margs_manipulateThis,
                                list(c("q80_balTrade.M", "!!q80_balTrade.M")),
                                list(c("q80_budget_helper.M", "!!q80_budget_helper.M")))
    }

    #KK filter out module 39 CCU fixings
    if(cfg$gms$CCU == 'off') {
      levs_manipulateThis <- c(levs_manipulateThis,
                               list(c("v39_shSynTrans.L", "!!v39_shSynTrans.L")),
                               list(c("v39_shSynGas.L", "!!v39_shSynGas.L")))

      fixings_manipulateThis <- c(fixings_manipulateThis,
                                  list(c("v39_shSynTrans.FX", "!!v39_shSynTrans.FX")),
                                  list(c("v39_shSynGas.FX", "!!v39_shSynGas.FX")))

      margs_manipulateThis <- c(margs_manipulateThis,
                                list(c("v39_shSynTrans.M", "!!v39_shSynTrans.M")),
                                list(c("v39_shSynGas.M", "!!v39_shSynGas.M")),
                                list(c("q39_emiCCU.M", "!!q39_emiCCU.M")),
                                list(c("q39_shSynTrans.M", "!!q39_shSynTrans.M")),
                                list(c("q39_shSynGas.M", "!!q39_shSynGas.M")))
    }

    #RP filter out module 40 techpol fixings
    if(cfg$gms$techpol == 'none'){
      margs_manipulateThis <- c(margs_manipulateThis,
                                list(c("q40_NewRenBound.M", "!!q40_NewRenBound.M")),
                                list(c("q40_CoalBound.M", "!!q40_CoalBound.M")),
                                list(c("q40_LowCarbonBound.M", "!!q40_LowCarbonBound.M")),
                                list(c("q40_FE_RenShare.M", "!!q40_FE_RenShare.M")),
                                list(c("q40_trp_bound.M", "!!q40_trp_bound.M")),
                                list(c("q40_TechBound.M", "!!q40_TechBound.M")),
                                list(c("q40_ElecBioBound.M", "!!q40_ElecBioBound.M")),
                                list(c("q40_PEBound.M", "!!q40_PEBound.M")),
                                list(c("q40_PEcoalBound.M", "!!q40_PEcoalBound.M")),
                                list(c("q40_PEgasBound.M", "!!q40_PEgasBound.M")),
                                list(c("q40_PElowcarbonBound.M", "!!q40_PElowcarbonBound.M")),
                                list(c("q40_TrpEnergyRed.M", "!!q40_TrpEnergyRed.M")),
                                list(c("q40_El_RenShare.M", "!!q40_El_RenShare.M")),
                                list(c("q40_BioFuelBound.M", "!!q40_BioFuelBound.M")))

    }

    if(cfg$gms$techpol == 'NPi2018'){
      margs_manipulateThis <- c(margs_manipulateThis,
                                list(c("q40_El_RenShare.M", "!!q40_El_RenShare.M")),
                                list(c("q40_CoalBound.M", "!!q40_CoalBound.M")))
    }

    #KK CDR module realizations
    fixings_manipulateThis <- c(fixings_manipulateThis,
                                list(c("vm_ccs_cdr.FX", "vm_co2capture_cdr.FX")),
                                list(c("v33_emi.FX", "vm_emiCdrTeDetail.FX")))

    levs_manipulateThis <- c(levs_manipulateThis,
                              list(c("vm_ccs_cdr.L", "vm_co2capture_cdr.L")),
                              list(c("v33_emi.L", "vm_emiCdrTeDetail.L")))

    margs_manipulateThis <- c(margs_manipulateThis,
                              list(c("vm_ccs_cdr.M", "vm_co2capture_cdr.M")),
                              list(c("q33_DAC_ccsbal.M", "!!q33_DAC_ccsbal.M")),
                              list(c("q33_DAC_emi.M", "!!q33_DAC_emi.M")))
    # end of CDR module realizations

    levs_manipulateThis <- c(levs_manipulateThis,
                               list(c("vm_shBioFe.L","!!vm_shBioFe.L")))
    fixings_manipulateThis <- c(fixings_manipulateThis,
                                list(c("vm_shBioFe.FX","!!vm_shBioFe.FX")))
    margs_manipulateThis <- c(margs_manipulateThis,
                                list(c("vm_shBioFe.M", "!!vm_shBioFe.M")),
                                list(c("q39_EqualSecShare_BioSyn.M", "!!q39_EqualSecShare_BioSyn.M")))

    # renamed because of https://github.com/remindmodel/remind/pull/796
    manipulate_tradesets <- c(list(c("'gas_pipe'", "'pipe_gas'")),
                              list(c("'lng_liq'", "'termX_lng'")),
                              list(c("'lng_gas'", "'termX_lng'")),
                              list(c("'lng_ves'", "'vess_lng'")),
                              list(c("'coal_ves'", "'vess_coal'")),
                              list(c("vm_budgetTradeX", "!! vm_budgetTradeX")),
                              list(c("vm_budgetTradeM", "!! vm_budgetTradeM"))  )
    levs_manipulateThis <- c(levs_manipulateThis, manipulate_tradesets)
    margs_manipulateThis <- c(margs_manipulateThis, manipulate_tradesets)
    fixings_manipulateThis <- c(fixings_manipulateThis, manipulate_tradesets)

    # because of https://github.com/remindmodel/remind/pull/800
    if (cfg$gms$cm_transpGDPscale != "on") {
      levs_manipulateThis <- c(levs_manipulateThis, list(c("q35_transGDPshare.M", "!! q35_transGDPshare.M")))
      margs_manipulateThis <- c(margs_manipulateThis, list(c("q35_transGDPshare.M", "!! q35_transGDPshare.M")))
      fixings_manipulateThis <- c(fixings_manipulateThis, list(c("q35_transGDPshare.M", "!! q35_transGDPshare.M")))
    }

    # renamed because of https://github.com/remindmodel/remind/pull/848, 1066
    levs_manipulateThis <- c(levs_manipulateThis,
                             list(c("vm_forcOs.L", "!!vm_forcOs.L")),
                             list(c("v32_shSeEl.L", "!!v32_shSeEl.L")))
    margs_manipulateThis <- c(margs_manipulateThis,
                             list(c("vm_forcOs.M", "!!vm_forcOs.M")),
                             list(c("v32_shSeEl.M", "!!v32_shSeEl.M")))
    fixings_manipulateThis <- c(fixings_manipulateThis,
                             list(c("vm_forcOs.FX", "!!vm_forcOs.FX")),
                             list(c("v32_shSeEl.FX", "!!v32_shSeEl.FX")))

    #filter out deprecated regipol items
    levs_manipulateThis <- c(levs_manipulateThis,
                             list(c("v47_emiTarget.L", "!!v47_emiTarget.L")),
                             list(c("v47_emiTargetMkt.L", "!!v47_emiTargetMkt.L")),
                             list(c("vm_taxrevimplEnergyBoundTax.L", "!!vm_taxrevimplEnergyBoundTax.L")))
    margs_manipulateThis <- c(margs_manipulateThis,
                             list(c("v47_emiTarget.M", "!!v47_emiTarget.M")),
                             list(c("v47_emiTargetMkt.M", "!!v47_emiTargetMkt.M")),
                             list(c("q47_implFETax.M", "!!q47_implFETax.M")),
                             list(c("q47_emiTarget_mkt_netCO2.M", "!!q47_emiTarget_mkt_netCO2.M")),
                             list(c("q47_emiTarget_mkt_netGHG.M", "!!q47_emiTarget_mkt_netGHG.M")),
                             list(c("q47_emiTarget_netCO2.M", "!!q47_emiTarget_netCO2.M")),
                             list(c("q47_emiTarget_netCO2_noBunkers.M", "!!q47_emiTarget_netCO2_noBunkers.M")),
                             list(c("q47_emiTarget_netCO2_noLULUCF_noBunkers.M", "!!q47_emiTarget_netCO2_noLULUCF_noBunkers.M")),
                             list(c("q47_emiTarget_netGHG.M", "!!q47_emiTarget_netGHG.M")),
                             list(c("q47_emiTarget_netGHG_noBunkers.M", "!!q47_emiTarget_netGHG_noBunkers.M")),
                             list(c("q47_emiTarget_netGHG_noLULUCF_noBunkers.M", "!!q47_emiTarget_netGHG_noLULUCF_noBunkers.M")),
                             list(c("q47_emiTarget_netGHG_LULUCFGrassi_noBunkers.M", "!!q47_emiTarget_netGHG_LULUCFGrassi_noBunkers.M")),

                             list(c("q47_emiTarget_grossEnCO2.M", "!!q47_emiTarget_grossEnCO2.M")),
                             list(c("q47_emiTarget_mkt_netCO2.M", "!!q47_emiTarget_mkt_netCO2.M")),
                             list(c("q47_emiTarget_mkt_netCO2_noBunkers.M", "!!q47_emiTarget_mkt_netCO2_noBunkers.M")),
                             list(c("q47_emiTarget_mkt_netCO2_noLULUCF_noBunkers.M", "!!q47_emiTarget_mkt_netCO2_noLULUCF_noBunkers.M")),
                             list(c("q47_emiTarget_mkt_netGHG.M", "!!q47_emiTarget_mkt_netGHG.M")),
                             list(c("q47_emiTarget_mkt_netGHG_noBunkers.M", "!!q47_emiTarget_mkt_netGHG_noBunkers.M")),
                             list(c("q47_emiTarget_mkt_netGHG_noLULUCF_noBunkers.M", "!!q47_emiTarget_mkt_netGHG_noLULUCF_noBunkers.M")),
                             list(c("q47_emiTarget_mkt_netGHG_LULUCFGrassi_noBunkers.M", "!!q47_emiTarget_mkt_netGHG_LULUCFGrassi_noBunkers.M")),
                             list(c("qm_balFeAfterTax.M", "!!qm_balFeAfterTax.M")),
                             list(c("q47_implicitQttyTargetTax.M", "!!q47_implicitQttyTargetTax.M")),
                             list(c("q47_implEnergyBoundTax.M", "!!q47_implEnergyBoundTax.M")),
                             list(c("vm_taxrevimplEnergyBoundTax.M", "!!vm_taxrevimplEnergyBoundTax.M"))
                             )

    fixings_manipulateThis <- c(fixings_manipulateThis,
                            list(c("v47_emiTarget.FX", "!!v47_emiTarget.FX")),
                            list(c("v47_emiTargetMkt.FX", "!!v47_emiTargetMkt.FX")),
                            list(c("vm_taxrevimplEnergyBoundTax.FX", "!!vm_taxrevimplEnergyBoundTax.FX")))

    # Include fixings (levels) and marginals in full.gms at predefined position
    # in core/loop.gms.
    full_manipulateThis <- c(full_manipulateThis,
                             list(c("cb20150605readinpositionforlevelfile",
                                    paste("first offlisting inclusion of levs.gms so that level value can be accessed",
                                          "$offlisting",
                                          "$include \"levs.gms\";",
                                          "$onlisting", sep = "\n"))))
    full_manipulateThis <- c(full_manipulateThis, list(c("cb20140305readinpositionforfinxingfiles",
                                                         paste("offlisting inclusion of levs.gms, fixings.gms, and margs.gms",
                                                               "$offlisting",
                                                               "$include \"levs.gms\";",
                                                               "$include \"fixings.gms\";",
                                                               "$include \"margs.gms\";",
                                                               "$onlisting", sep = "\n"))))

    # Perform actual manipulation on levs.gms, fixings.gms, and margs.gms in
    # single, respective, parses of the texts.
    manipulateFile("levs.gms", levs_manipulateThis, fixed = TRUE)
    manipulateFile("fixings.gms", fixings_manipulateThis, fixed = TRUE)
    manipulateFile("margs.gms", margs_manipulateThis, fixed = TRUE)

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
