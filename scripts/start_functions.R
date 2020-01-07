# |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
start_run <- function(cfg, scenario = NULL, report = NULL, sceninreport = NULL, coupled = F, force = FALSE) {
  
  # Load libraries
  require(lucode, quietly = TRUE,warn.conflicts =FALSE)
  require(magclass, quietly = TRUE,warn.conflicts =FALSE)
  require(tools, quietly = TRUE,warn.conflicts =FALSE)
  require(remind, quietly = TRUE,warn.conflicts =FALSE)
  require(moinput)
  require(mrvalidation)
  
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
 
  # Store REMIND-root directory
  maindir <- getwd()
  on.exit(setwd(maindir))
  
  # Is the run performed on the cluster?
  on_cluster    <- file.exists('/p')
  
  # Adapt configuration to predifined scenario, if given
  if(!is.null(scenario))
    cfg <- setScenario(cfg, scenario)
  
  # Check configuration for consistency
  cfg <- check_config(cfg, settings_config = "config/settings_config.csv")
  
  
###-------- do update of input files based on previous runs if applicable ------###
  if(!is.null(cfg$gms$carbonprice) && (cfg$gms$carbonprice == "NDC2018")){
    source("scripts/input/prepare_NDC2018.R")
    prepare_NDC2018(as.character(cfg$files2export$start["input_ref.gdx"]))
  } 
  ## the following is outcommented because by now it has to be done by hand ( currently only one gdx is handed to the next run, so it is impossible to fix to one run and use the tax from another run)
  ## Update CO2 tax information for exogenous carbon price runs with the same CO2 price as a previous run
  #if(!is.null(cfg$gms$carbonprice) && (cfg$gms$carbonprice == "ExogSameAsPrevious")){
  #  source("scripts/input/create_ExogSameAsPrevious_CO2price_file.R")
  #  create_ExogSameAsPrevious_CO2price_file(as.character(cfg$files2export$start["input_ref.gdx"]))
  #}  
  
  #AJS
  if ( (cfg$gms$optimization != 'nash') & (cfg$gms$subsidizeLearning == 'globallyOptimal') ) {
    cat("Only optimization='nash' is compatible with subsudizeLearning='globallyOptimal'. Switching subsidizeLearning to 'off' now. \n")
    cfg$gms$subsidizeLearning = 'off'
  }
  # reportCEScalib only works with the calibrate module
  if ( cfg$gms$CES_parameters != "calibrate" ) cfg$output <- setdiff(cfg$output,"reportCEScalib")
  
  # Replace :title: and :date: tokens in results directory name
  rundate <- Sys.time()
  date <- format(rundate, "_%Y-%m-%d_%H.%M.%S")
  cfg$results_folder <- gsub(":date:", date, cfg$results_folder, fixed = TRUE)
  cfg$results_folder <- gsub(":title:", cfg$title, cfg$results_folder, fixed = TRUE)

    #AJS quit if title is too long - GAMS can't handle that
  if( nchar(cfg$title) > 75 | grepl("\\.",cfg$title) ) {
      stop("This title is too long or the name contains dots - GAMS would not tolerate this, and quit working at a point where you least expect it. Stopping now. ")
  }

  # Calculate CES configuration string
  cfg$gms$cm_CES_configuration <- paste0("stat_",cfg$gms$stationary,"-",
                                         "indu_",cfg$gms$industry,"-",
                                         "buil_",cfg$gms$buildings,"-",
                                         "tran_",cfg$gms$transport,"-",
                                         "POP_", cfg$gms$cm_POPscen, "-",
                                         "GDP_", cfg$gms$cm_GDPscen, "-",
                                         "Kap_", cfg$gms$capitalMarket, "-",
                                         "Reg_", substr(regionscode(cfg$regionmapping),1,10))
   # adjust GDPpcScen based on GDPscen
  cfg$gms$c_GDPpcScen <- gsub("gdp_","",cfg$gms$cm_GDPscen) 

  ################## M O D E L   L O C K ###################################
  # Lock the directory for other instances of the start scritps
  lock_id <- model_lock(timeout1 = 1, oncluster=on_cluster)
  on.exit(model_unlock(lock_id, oncluster=on_cluster))  
  ################## M O D E L   L O C K ###################################

  # Make sure all MAGICC files have LF line endings, so Fortran won't crash
  if (on_cluster)
    system("find ./core/magicc/ -type f | xargs dos2unix -q")
  
  # Create output folder
  if (!file.exists(cfg$results_folder)) {
    dir.create(cfg$results_folder, recursive = TRUE, showWarnings = FALSE)
  } else if (!force) {
    stop(paste0("Results folder ",cfg$results_folder," could not be created because it already exists."))
  } else {
    cat("Deleting results folder because it alreay exists:",cfg$results_folder,"\n")
    unlink(cfg$results_folder, recursive = TRUE)
    dir.create(cfg$results_folder, recursive = TRUE, showWarnings = FALSE)
  }
  
  # If report and scenname are supplied the data of this scenario in the report will be converted to REMIND input
  if (!is.null(report) && !is.null(sceninreport)) {
    #cfg$gms$biomass <- "magpie_linear" # is already set in start_couple.R
    getReportData(report,sceninreport,inputpath_mag=cfg$gms$biomass,inputpath_acc=cfg$gms$agCosts)
  }
  
  # Set source_include so that loaded scripts know they are included as 
  # source (instead a load from command line)
  source_include <- TRUE
   
  # Update module paths in GAMS code
  update_modules_embedding()

  # configure main model gms file (cfg$model) based on settings of cfg file
  cfg$gms$c_expname <- cfg$title
  # run main.gms if not further specified
  if(is.null(cfg$model)) cfg$model <- "main.gms"
  manipulateConfig(cfg$model, cfg$gms)
  
  # Configure input.gms in all modules based on settings of cfg file
  l1 <- path("modules", list.dirs("modules/"))
  for(l in l1) {
    l2 <- path(l, list.dirs(l))
    for(ll in l2) {
      if (file.exists(path(ll, "input.gms")))
        manipulateConfig(path(ll, "input.gms"), cfg$gms)
      }
    }
  
  # Check all setglobal settings for consistency
  settingsCheck()
  
  ###########################################################################################################
  ############# PROCESSING INPUT DATA ###################### START ##########################################
  ###########################################################################################################
  
   
  ########## declare functions for updating information ################ 
  update_info <- function(regionscode,revision) {
    
    subject <- 'VERSION INFO'
    content <- c('',
      paste('Regionscode:',regionscode),
      '',
      paste('Input data revision:',revision),
      '',
      paste('Last modification (input data):',date()),
      '')
    replace_in_file(cfg$model,paste('*',content),subject)  
  }
   
  update_sets <- function(map) {
     .tmp <- function(x,prefix="", suffix1="", suffix2=" /", collapse=",", n=10) {
      content <- NULL
      tmp <- lapply(split(x, ceiling(seq_along(x)/n)),paste,collapse=collapse)
      end <- suffix1
      for(i in 1:length(tmp)) {
        if(i==length(tmp)) end <- suffix2
        content <- c(content,paste0('       ',prefix,tmp[[i]],end))
      }
      return(content)
    }
    modification_warning <- c(
      '*** THIS CODE IS CREATED AUTOMATICALLY, DO NOT MODIFY THESE LINES DIRECTLY',
      '*** ANY DIRECT MODIFICATION WILL BE LOST AFTER NEXT INPUT DOWNLOAD',
      '*** CHANGES CAN BE DONE USING THE RESPECTIVE LINES IN scripts/start_functions.R')
    content <- c(modification_warning,'','sets')
    # write iso set with nice formatting (10 countries per line)
    tmp <- lapply(split(map$CountryCode, ceiling(seq_along(map$CountryCode)/10)),paste,collapse=",")
    regions <- levels(map$RegionCode)
    content <- c(content, '',paste('   all_regi "all regions" /',paste(regions,collapse=','),'/',sep=''),'')
    # Creating sets for H12 subregions
    subsets <- toolRegionSubsets(map=cfg$regionmapping)
    if(is.null(subsets[["EUR"]]))
        subsets[["EUR"]] <- c("EUR")
    content <- c(content, paste('   ext_regi "extended regions list (includes subsets of H12 regions)" / ', paste(c(paste0(names(subsets),"_regi"),regions),collapse=','),' /',sep=''),'')
    content <- c(content, '   regi_group(ext_regi,all_regi) "region groups (regions that together corresponds to a H12 region)"')
    content <- c(content, '      /')
    for (i in 1:length(subsets)){
        content <- c(content, paste0('        ', paste(c(paste0(names(subsets)[i],"_regi"))), ' .(',paste(subsets[[i]],collapse=','), ')'))
    }
    content <- c(content, '      /')
    content <- c(content, ' ')
    # iso countries set
	content <- c(content,'   iso "list of iso countries" /')
    content <- c(content, .tmp(map$CountryCode, suffix1=",", suffix2=" /"),'')
    content <- c(content,'   regi2iso(all_regi,iso) "mapping regions to iso countries"','      /')
    for(i in levels(map$RegionCode)) {
      content <- c(content, .tmp(map$CountryCode[map$RegionCode==i], prefix=paste0(i," . ("), suffix1=")", suffix2=")"))
    }
    content <- c(content,'      /') 
    content <- c(content, 'iso_regi "all iso countries and EU and greater China region" /  EUR,CHA,')
    content <- c(content, .tmp(map$CountryCode, suffix1=",", suffix2=" /"),'')
    content <- c(content,'   map_iso_regi(iso_regi,all_regi) "mapping from iso countries to regions that represent country" ','         /')
    for(i in regions[regions %in% c("EUR","CHA",levels(map$CountryCode))]) {
      content <- c(content, .tmp(i, prefix=paste0(i," . "), suffix1="", suffix2=""))
    }
    content <- c(content,'      /',';') 
    replace_in_file('core/sets.gms',content,"SETS",comment="***")
  }
  ###################################################################### 
  
  ############### download and distribute input data ################### 
  # check wheather the regional resolution and input data revision are outdated and update data if needed
  if(file.exists("input/source_files.log")) {
      input_old <- readLines("input/source_files.log")[1]
  } else {
      input_old <- "no_data"
  }
  input_new <- paste0("rev",cfg$revision,"_", regionscode(cfg$regionmapping),"_", tolower(cfg$model_name),".tgz")
    
  if(!setequal(input_new, input_old) | cfg$force_download) {
      cat("Your input data are outdated or in a different regional resolution. New data are downloaded and distributed. \n")
      download_distribute(files        = input_new,
                          repositories = cfg$repositories, # defined in your local .Rprofile or on the cluster /p/projects/rd3mod/R/.Rprofile
                          modelfolder  = ".",
                          debug        = FALSE)
  }
  ######################################################################
  
  ##################### update information #############################
  # update_info, which regional resolution and input data revision in cfg$model
  update_info(regionscode(cfg$regionmapping),cfg$revision)
  # update_sets, which is updating the region-depending sets in core/sets.gms
  #-- load new mapping information
  map <- read.csv(cfg$regionmapping,sep=";")  
  update_sets(map)
  ######################################################################
  
  ###########################################################################################################
  ############# PROCESSING INPUT DATA ###################### END ############################################
  ###########################################################################################################


  ############# ADD MODULE INFO IN SETS  ###################### START ##########################################
    content <- NULL
    modification_warning <- c(
      '*** THIS CODE IS CREATED AUTOMATICALLY, DO NOT MODIFY THESE LINES DIRECTLY',
      '*** ANY DIRECT MODIFICATION WILL BE LOST AFTER NEXT MODEL START',
      '*** CHANGES CAN BE DONE USING THE RESPECTIVE LINES IN scripts/start_functions.R')
    content <- c(modification_warning,'','sets')
    content <- c(content,'','       modules "all the available modules"')
    content <- c(content,'       /',paste0("       ",getModules("modules/")[,"name"]),'       /')
#    content <- c(content,'','       realisation "all the active realisations"')
#    content <- c(content,'       /',paste0("       ",unlist(unique(cfg$gms[getModules("modules/")[,"name"]]))),"       /")
    content <- c(content,'','module2realisation(modules,*) "mapping of modules and active realisations" /')
    content <- c(content,paste0("       ",getModules("modules/")[,"name"]," . %",getModules("modules/")[,"name"],"%"))
    content <- c(content,'      /',';')
    replace_in_file('core/sets.gms',content,"MODULES",comment="***")
  ############# ADD MODULE INFO IN SETS  ###################### END ############################################
      
  # For the performance tests create the workspace for validation
  tmp <- strsplit(cfg$results_folder, "/")[[1]] # take name of output folder without "output/"
  cfg$val_workspace <- paste(cfg$results_folder, "/", tmp[length(tmp)],".RData", sep = "")
  validation <- list()
  validation$technical <- list()
  validation$technical$time <- list()
  save(validation, file = cfg$val_workspace)
  
  # Delete unneeded gdx from files2export
  tmp <- cfg$files2export$start
#  if (cfg$gms$cm_startyear < 2020 && !is.null(names(tmp))) { # < 2020
#    tmp <- tmp[!grepl("input_ref.gdx",names(tmp))]
#	  cat("Removed input_ref.gdx from cfg$files2export$start.\n")
#	}
#  if ((cfg$gms$cm_emiscen == 1 | cfg$gms$cm_startyear < 2010) && !is.null(names(tmp))) { # < 2010
#    tmp <- tmp[!grepl("input_bau.gdx",names(tmp))]
#	  cat("Removed input_bau.gdx from cfg$files2export$start.\n")
#	}
  if ((cfg$gms$cm_emiscen != 9 | cfg$gms$cm_startyear < 2025) && !is.null(names(tmp))) {
    tmp <- tmp[!grepl("input_opt.gdx",names(tmp))]
    cat("Removed input_opt.gdx from cfg$files2export$start.\n")
  }
  cfg$files2export$start <- tmp

  # Replace load leveler-script with appropriate version
  if (cfg$gms$optimization == "nash" && cfg$gms$cm_nash_mode == "parallel") {
	if(length(unique(map$RegionCode)) <= 12) { 
		cfg$files2export$start[cfg$files2export$start == "scripts/run_submit/submit.cmd"] <- 
      "scripts/run_submit/submit_par.cmd"
	} else { # use max amount of cores if regions number is greater than 12 
		cfg$files2export$start[cfg$files2export$start == "scripts/run_submit/submit.cmd"] <- 
      "scripts/run_submit/submit_par16.cmd"
	}
  } else if (cfg$gms$optimization == "testOneRegi") {
    cfg$files2export$start[cfg$files2export$start == "scripts/run_submit/submit.cmd"] <- 
      "scripts/run_submit/submit_short.cmd"
  }

  # choose which conopt files to copy
  cfg$files2export$start <- sub("conopt3",cfg$gms$cm_conoptv,cfg$files2export$start)
  
  # Copy important files into output_folder (before REMIND execution)
  .copy.fromlist(cfg$files2export$start,cfg$results_folder)

  # Store main folder to make it accessible in submit.R
  cfg$remind_folder <- getwd()
  
  # Save configuration
  save(cfg, file = path(cfg$results_folder, "config.Rdata"))

  if (grepl("_UBA_Sust",cfg$title)){
    replace_in_file(file    = "./modules/29_CES_parameters/load/datainput.gms",
                    content = paste0('$include "./modules/29_CES_parameters/load/input/',cfg$gms$cm_CES_configuration,'_UBA.inc"'),
                    subject = "CES INPUT")
  } else {
    replace_in_file(file    = "./modules/29_CES_parameters/load/datainput.gms",
                    content = paste0('$include "./modules/29_CES_parameters/load/input/',cfg$gms$cm_CES_configuration,'.inc"'),
                    subject = "CES INPUT")
  }
 
  # Merge GAMS files
  singleGAMSfile(mainfile=cfg$model,output = path(cfg$results_folder, "full.gms"))
  
#   # Check for illegal declaration - e.g. regi instead of all_regi 
#   a <- codeExtract(path(cfg$results_folder, "full.gms"),"code")
#   regi <- found <- grep("(^|,)regi(,|$)",a$declarations[,"sets"])
#   if(length(regi <- found)>0) {
#       stop("Some objects are declared over regi instead of regi_all! This is illegal, stopping. Check these declarations please: (",   paste(a$declarations[regi <- found,"names"],collapse=", "),")")
#   }
  
  # Collect run statistics (will be saved to central database in submit.R)
  lucode::runstatistics(file = paste0(cfg$results_folder,"/runstatistics.rda"),
                        user = Sys.info()[["user"]],
                        date = rundate,
                        version_management = "git",
                        revision = try(system("git rev-parse --short HEAD", intern=TRUE), silent=TRUE),
                        #revision_date = try(as.POSIXct(system("git show -s --format=%ci", intern=TRUE), silent=TRUE)),
                        status = try(system("git status", intern=TRUE), silent=TRUE))

  ################## M O D E L   U N L O C K ###################################
  # After full.gms was produced remind folders have to be unlocked to allow setting up the next run
  model_unlock(lock_id, oncluster=on_cluster)
  # Prevent model_unlock from being executed again at the end
  on.exit()
  # Repeat command since on.exit was cleared
  on.exit(setwd(maindir))
  ################## M O D E L   U N L O C K ###################################
  
  setwd(cfg$results_folder)
  
  # Determine if REMIND is to be run in sequential order or not
  if (is.na(cfg$sequential)) {
    if (on_cluster) {
      cfg$sequential <- FALSE
    } else {
      cfg$sequential <- TRUE
    }
  }

  # "Compilation only" is always sequential
  if (cfg$action == "c") cfg$sequential <- TRUE
  
  # Call appropriate submit script
  if (!cfg$sequential) {
      # parallel
      if(cfg$gms$optimization == "nash" && cfg$gms$cm_nash_mode == "parallel") {
         if(length(unique(map$RegionCode)) <= 12) { 
           system(paste0("sed -i 's/__JOB_NAME__/pREMIND_", cfg$title,"/g' submit_par.cmd"))
           system("sbatch submit_par.cmd")
         } else { # use max amount of cores if regions number is greater than 12 
           system(paste0("sed -i 's/__JOB_NAME__/pREMIND_", cfg$title,"/g' submit_par16.cmd"))
           system("sbatch submit_par16.cmd")
         }
      } else if (cfg$gms$optimization == "testOneRegi") {
          system(paste0("sed -i 's/__JOB_NAME__/REMIND_", cfg$title,"/g' submit_short.cmd"))
          system("sbatch submit_short.cmd")
      } else {
          system(paste0("sed -i 's/__JOB_NAME__/REMIND_", cfg$title,"/g' submit.cmd"))
          if (cfg$gms$cm_startyear > 2030) {
              system("sbatch --partition=ram_gpu submit.cmd")
          } else {
              system("sbatch submit.cmd")
          }
      }
  } else {
      # sequential
      system("Rscript submit.R")
  }
  
  # on.exit sets working directory back to REMIND main folder   
  return(cfg$results_folder)
}

getReportData <- function(rep,scen,inputpath_mag="magpie",inputpath_acc="costs") {
	require(lucode, quietly = TRUE,warn.conflicts =FALSE)
  require(magclass, quietly = TRUE,warn.conflicts =FALSE)
  .bioenergy_price <- function(mag){
    notGLO <- getRegions(mag)[!(getRegions(mag)=="GLO")]
    if("Demand|Bioenergy|++|2nd generation (EJ/yr)" %in% getNames(mag)) {
      # MAgPIE 4
      out <- mag[,,"Prices|Bioenergy (US$05/GJ)"]*0.0315576 # with transformation factor from US$2005/GJ to US$2005/Wa
    } else {
      # MAgPIE 3
      out <- mag[,,"Price|Primary Energy|Biomass (US$2005/GJ)"]*0.0315576 # with transformation factor from US$2005/GJ to US$2005/Wa
    }
    out["JPN",is.na(out["JPN",,]),] <- 0
    dimnames(out)[[3]] <- NULL #Delete variable name to prevent it from being written into output file
    write.magpie(out[notGLO,,],paste0("./modules/30_biomass/",inputpath_mag,"/input/p30_pebiolc_pricemag_coupling.csv"),file_type="csvr")
  }  
  .bioenergy_costs <- function(mag){
    notGLO <- getRegions(mag)[!(getRegions(mag)=="GLO")]
    if ("Production Cost|Agriculture|Biomass|Energy Crops (million US$2005/yr)" %in% getNames(mag)) {
      out <- mag[,,"Production Cost|Agriculture|Biomass|Energy Crops (million US$2005/yr)"]/1000/1000 # with transformation factor from 10E6 US$2005 to 10E12 US$2005
    }
    else {
      # in old MAgPIE reports the unit is reported to be "billion", however the values are in million
      out <- mag[,,"Production Cost|Agriculture|Biomass|Energy Crops (billion US$2005/yr)"]/1000/1000 # with transformation factor from 10E6 US$2005 to 10E12 US$2005
    }
    out["JPN",is.na(out["JPN",,]),] <- 0
    dimnames(out)[[3]] <- NULL
    write.magpie(out[notGLO,,],paste0("./modules/30_biomass/",inputpath_mag,"/input/p30_pebiolc_costsmag.csv"),file_type="csvr")
  }  
  .bioenergy_production <- function(mag){
    notGLO <- getRegions(mag)[!(getRegions(mag)=="GLO")]
    if("Demand|Bioenergy|2nd generation|++|Bioenergy crops (EJ/yr)" %in% getNames(mag)) {
      # MAgPIE 4
      out <- mag[,,"Demand|Bioenergy|2nd generation|++|Bioenergy crops (EJ/yr)"]/31.536 # EJ to TWa
    } else {
      # MAgPIE 3
      out <- mag[,,"Primary Energy Production|Biomass|Energy Crops (EJ/yr)"]/31.536 # EJ to TWa
    }
    out[which(out<0)] <- 0 # set negative values to zero since they cause errors in GMAS power function
    out["JPN",is.na(out["JPN",,]),] <- 0
    dimnames(out)[[3]] <- NULL
    write.magpie(out[notGLO,,],paste0("./modules/30_biomass/",inputpath_mag,"/input/p30_pebiolc_demandmag_coupling.csv"),file_type="csvr")
  }  
  .emissions_mac <- function(mag) {
    # define three columns of dataframe: 
    #   emirem (remind emission names)
    #   emimag (magpie emission names)
    #   factor_mag2rem (factor for converting magpie to remind emissions)
    #   1/1000*28/44, # kt N2O/yr -> Mt N2O/yr -> Mt N/yr
    #   28/44,        # Tg N2O/yr =  Mt N2O/yr -> Mt N/yr
    #   1/1000*12/44, # Mt CO2/yr -> Gt CO2/yr -> Gt C/yr
    map <- data.frame(emirem=NULL,emimag=NULL,factor_mag2rem=NULL,stringsAsFactors=FALSE)
    if("Emissions|N2O|Land|Agriculture|+|Animal Waste Management (Mt N2O/yr)" %in% getNames(mag)) {
      # MAgPIE 4
      map <- rbind(map,data.frame(emimag="Emissions|CO2|Land (Mt CO2/yr)",                                                                 emirem="co2luc",    factor_mag2rem=1/1000*12/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land|Agriculture|+|Animal Waste Management (Mt N2O/yr)",                           emirem="n2oanwstm", factor_mag2rem=28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land|Agriculture|Agricultural Soils|+|Inorganic Fertilizers (Mt N2O/yr)",          emirem="n2ofertin", factor_mag2rem=28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land|Agriculture|Agricultural Soils|+|Manure applied to Croplands (Mt N2O/yr)",    emirem="n2oanwstc", factor_mag2rem=28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land|Agriculture|Agricultural Soils|+|Decay of Crop Residues (Mt N2O/yr)",         emirem="n2ofertcr", factor_mag2rem=28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land|Agriculture|Agricultural Soils|+|Soil Organic Matter Loss (Mt N2O/yr)",       emirem="n2ofertsom",factor_mag2rem=28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land|Agriculture|Agricultural Soils|+|Pasture (Mt N2O/yr)",                        emirem="n2oanwstp", factor_mag2rem=28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|CH4|Land|Agriculture|+|Rice (Mt CH4/yr)",                                              emirem="ch4rice",   factor_mag2rem=1,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|CH4|Land|Agriculture|+|Animal waste management (Mt CH4/yr)",                           emirem="ch4anmlwst",factor_mag2rem=1,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|CH4|Land|Agriculture|+|Enteric fermentation (Mt CH4/yr)",                              emirem="ch4animals",factor_mag2rem=1,stringsAsFactors=FALSE))
    } else {
      # MAgPIE 3
      map <- rbind(map,data.frame(emimag="Emissions|CO2|Land Use (Mt CO2/yr)",                                                        emirem="co2luc",    factor_mag2rem=1/1000*12/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land Use|Agriculture|AWM (kt N2O/yr)",                                        emirem="n2oanwstm", factor_mag2rem=1/1000*28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land Use|Agriculture|Cropland Soils|Inorganic Fertilizers (kt N2O/yr)",       emirem="n2ofertin", factor_mag2rem=1/1000*28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land Use|Agriculture|Cropland Soils|Manure applied to Croplands (kt N2O/yr)", emirem="n2oanwstc", factor_mag2rem=1/1000*28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land Use|Agriculture|Cropland Soils|Decay of crop residues (kt N2O/yr)",      emirem="n2ofertcr", factor_mag2rem=1/1000*28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land Use|Agriculture|Cropland Soils|Soil organic matter loss (kt N2O/yr)",    emirem="n2ofertsom",factor_mag2rem=1/1000*28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land Use|Agriculture|Cropland Soils|Lower N2O emissions of rice (kt N2O/yr)", emirem="n2ofertrb", factor_mag2rem=1/1000*28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land Use|Agriculture|Pasture (kt N2O/yr)",                                    emirem="n2oanwstp", factor_mag2rem=1/1000*28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land Use|Biomass Burning|Forest Burning (kt N2O/yr)",                         emirem="n2oforest", factor_mag2rem=1/1000*28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land Use|Biomass Burning|Savannah Burning (kt N2O/yr)",                       emirem="n2osavan",  factor_mag2rem=1/1000*28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land Use|Biomass Burning|Agricultural Waste Burning (kt N2O/yr)",             emirem="n2oagwaste",factor_mag2rem=1/1000*28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|CH4|Land Use|Agriculture|Rice (Mt CH4/yr)",                                       emirem="ch4rice",   factor_mag2rem=1,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|CH4|Land Use|Agriculture|AWM (Mt CH4/yr)",                                        emirem="ch4anmlwst",factor_mag2rem=1,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|CH4|Land Use|Agriculture|Enteric Fermentation (Mt CH4/yr)",                       emirem="ch4animals",factor_mag2rem=1,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|CH4|Land Use|Biomass Burning|Forest Burning (Mt CH4/yr)",                         emirem="ch4forest", factor_mag2rem=1,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|CH4|Land Use|Biomass Burning|Savannah Burning (Mt CH4/yr)",                       emirem="ch4savan",  factor_mag2rem=1,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|CH4|Land Use|Biomass Burning|Agricultural Waste Burning (Mt CH4/yr)",             emirem="ch4agwaste",factor_mag2rem=1,stringsAsFactors=FALSE))
    }

    # Read data from MAgPIE report and convert to REMIND data, collect in 'out' object
    out<-NULL
    for (i in 1:nrow(map)) {
        tmp<-setNames(mag[,,map[i,]$emimag],map[i,]$emirem)
        tmp<-tmp*map[i,]$factor_mag2rem
        #tmp["JPN",is.na(tmp["JPN",,]),] <- 0
        # preliminary fix 20160111
        #cat("Preliminary quick fix: filtering out NAs for all and negative values for almost all landuse emissions except for co2luc and n2ofertrb\n")
        #tmp[is.na(tmp)] <- 0
        # preliminary 20160114: filter out negative values except for co2luc and n2ofertrb
        #if (map[i,]$emirem!="co2luc" &&  map[i,]$emirem!="n2ofertrb") {
        # tmp[tmp<0] <- 0
        #}
        out<-mbind(out,tmp)
    }
    
    # Write REMIND input file
    notGLO   <- getRegions(mag)[!(getRegions(mag)=="GLO")]
    filename <- paste0("./core/input/f_macBaseMagpie_coupling.cs4r")
    write.magpie(out[notGLO],filename)
    write(paste0("*** EOF ",filename," ***"),file=filename,append=TRUE)
  }	
  .agriculture_costs <- function(mag){
    notGLO <- getRegions(mag)[!(getRegions(mag)=="GLO")]
    out <- mag[,,"Costs|MainSolve w/o GHG Emissions (million US$05/yr)"]/1000/1000 # with transformation factor from 10E6 US$2005 to 10E12 US$2005
    out["JPN",is.na(out["JPN",,]),] <- 0
    dimnames(out)[[3]] <- NULL #Delete variable name to prevent it from being written into output file
    write.magpie(out[notGLO,,],paste0("./modules/26_agCosts/",inputpath_acc,"/input/p26_totLUcost_coupling.csv"),file_type="csvr")
  }
  .agriculture_tradebal <- function(mag){
    notGLO <- getRegions(mag)[!(getRegions(mag)=="GLO")]
    out <- mag[,,"Trade|Agriculture|Trade Balance (billion US$2005/yr)"]/1000 # with transformation factor from 10E9 US$2005 to 10E12 US$2005
    out["JPN",is.na(out["JPN",,]),] <- 0
    dimnames(out)[[3]] <- NULL
    write.magpie(out[notGLO,,],paste0("./modules/26_agCosts/",inputpath_acc,"/input/trade_bal_reg.rem.csv"),file_type="csvr")
  }
  
  if (length(scen)!=1) stop("getReportData: 'scen' does not contain exactly one scenario:",scen)
  if (length(intersect(scen,getNames(rep,dim="scenario")))!=1) stop("getReportData: 'scen'",scen," not contained in 'rep'.")
  rep <- collapseNames(rep) # get rid of scenrio and model dimension if they exist
  years <- 2000+5*(1:30)
  mag <- time_interpolate(rep,years)
  .bioenergy_price(mag)
  #.bioenergy_costs(mag) # Obsolete since bioenergy costs are not calculated by MAgPIE anymore but by integrating the supplycurve
  .bioenergy_production(mag)
  .emissions_mac(mag)
  .agriculture_costs(mag)
  # need to be updated to MAgPIE 4 interface
  #.agriculture_tradebal(mag)
}

start_reportrun <- function (cfg,path_report,sceninreport=NULL){
  rep <- convert.report(path_report,outmodel="REMIND")
  write.report(rep,"report.mif")
  if (!is.null(sceninreport))
      sceninreport <- intersect(sceninreport,names(rep))
  else
      sceninreport <- names(rep)
    
  for(scen in sceninreport) {
	cfg$title <- scen
	# If REMIND had pre-defined scenarios like MAgPIE they must be set here according to the scenario read in from the MAgPIE reporting
	# cfg <- setScenario(cfg,strsplit(scen,"_")[[1]][1])
	start_run(cfg, report=rep, sceninreport=scen)
  }
}
