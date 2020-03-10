library(lucode, quietly = TRUE,warn.conflicts =FALSE)
library(dplyr, quietly = TRUE,warn.conflicts =FALSE)
require(gdx)

################################################################################################## 
#                             function: getReportData                                            #
##################################################################################################

getReportData <- function(path_to_report,inputpath_mag="magpie",inputpath_acc="costs") {
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
  
  rep <- read.report(path_to_report,as.list=FALSE)
  if (length(getNames(rep,dim="scenario"))!=1) stop("getReportData: MAgPIE data contains more or less than 1 scenario.")
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

################################################################################################## 
#                             function: prepare                                                  #
##################################################################################################

prepare <- function() {

  timePrepareStart <- Sys.time()
  
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
 
  load("config.Rdata")
  
  # Store results folder of current scenario
  on.exit(setwd(cfg$results_folder))
  
  # change to REMIND main folder
  setwd(cfg$remind_folder)
  
  # Check configuration for consistency
  cfg <- check_config(cfg, reference_file="config/default.cfg", settings_config = "config/settings_config.csv")
  
  # Check for compatibility with subsidizeLearning
  if ( (cfg$gms$optimization != 'nash') & (cfg$gms$subsidizeLearning == 'globallyOptimal') ) {
    cat("Only optimization='nash' is compatible with subsudizeLearning='globallyOptimal'. Switching subsidizeLearning to 'off' now. \n")
    cfg$gms$subsidizeLearning = 'off'
  }
  
  # reportCEScalib only works with the calibrate module
  if ( cfg$gms$CES_parameters != "calibrate" ) cfg$output <- setdiff(cfg$output,"reportCEScalib")
  
  #AJS quit if title is too long - GAMS can't handle that
  if( nchar(cfg$title) > 75 | grepl("\\.",cfg$title) ) {
      stop("This title is too long or the name contains dots - GAMS would not tolerate this, and quit working at a point where you least expect it. Stopping now. ")
  }

  # adjust GDPpcScen based on GDPscen
  cfg$gms$c_GDPpcScen <- gsub("gdp_","",cfg$gms$cm_GDPscen) 

  # Is the run performed on the cluster?
  on_cluster    <- file.exists('/p')
  
  # Make sure all MAGICC files have LF line endings, so Fortran won't crash
  if (on_cluster)
    system("find ./core/magicc/ -type f | xargs dos2unix -q")
  
  ################## M O D E L   L O C K ###################################
  # Lock the directory for other instances of the start scritps
  lock_id <- model_lock(timeout1 = 1, oncluster=on_cluster)
  on.exit(model_unlock(lock_id, oncluster=on_cluster))  
  ################## M O D E L   L O C K ###################################

  ###########################################################
  ### PROCESSING INPUT DATA ###################### START ####
  ###########################################################
   
  # update input files based on previous runs if applicable 
  # ATTENTION: modifying gms files
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
  
  # Calculate CES configuration string
  cfg$gms$cm_CES_configuration <- paste0("stat_",cfg$gms$stationary,"-",
                                         "indu_",cfg$gms$industry,"-",
                                         "buil_",cfg$gms$buildings,"-",
                                         "tran_",cfg$gms$transport,"-",
                                         "POP_", cfg$gms$cm_POPscen, "-",
                                         "GDP_", cfg$gms$cm_GDPscen, "-",
                                         "Kap_", cfg$gms$capitalMarket, "-",
                                         "Reg_", substr(regionscode(cfg$regionmapping),1,10))
  
  # write name of corresponding CES file to datainput.gms
  replace_in_file(file    = "./modules/29_CES_parameters/load/datainput.gms",
                  content = paste0('$include "./modules/29_CES_parameters/load/input/',cfg$gms$cm_CES_configuration,'.inc"'),
                  subject = "CES INPUT")
 
  # If a path to a MAgPIE report is supplied use it as REMIND intput (used for REMIND-MAgPIE coupling)
  # ATTENTION: modifying gms files
  if (!is.null(cfg$pathToMagpieReport)) {
    getReportData(path_to_report = cfg$pathToMagpieReport,inputpath_mag=cfg$gms$biomass,inputpath_acc=cfg$gms$agCosts)
  }
  
  # Update module paths in GAMS code
  update_modules_embedding()

  # Check all setglobal settings for consistency
  settingsCheck()

  # configure main model gms file (cfg$model) based on settings of cfg file
  cfg$gms$c_expname <- cfg$title
  # run main.gms if not further specified
  if(is.null(cfg$model)) cfg$model <- "main.gms"
  manipulateConfig(cfg$model, cfg$gms)
  
  ######## declare functions for updating information ####
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
  
  ############ download and distribute input data ########
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
  
  ############ update information ########################
  # update_info, which regional resolution and input data revision in cfg$model
  update_info(regionscode(cfg$regionmapping),cfg$revision)
  # update_sets, which is updating the region-depending sets in core/sets.gms
  #-- load new mapping information
  map <- read.csv(cfg$regionmapping,sep=";")  
  update_sets(map)
  
  ########################################################
  ### PROCESSING INPUT DATA ###################### END ###
  ########################################################

  ### ADD MODULE INFO IN SETS  ############# START #######
  content <- NULL
  modification_warning <- c(
    '*** THIS CODE IS CREATED AUTOMATICALLY, DO NOT MODIFY THESE LINES DIRECTLY',
    '*** ANY DIRECT MODIFICATION WILL BE LOST AFTER NEXT MODEL START',
    '*** CHANGES CAN BE DONE USING THE RESPECTIVE LINES IN scripts/start_functions.R')
  content <- c(modification_warning,'','sets')
  content <- c(content,'','       modules "all the available modules"')
  content <- c(content,'       /',paste0("       ",getModules("modules/")[,"name"]),'       /')
  content <- c(content,'','module2realisation(modules,*) "mapping of modules and active realisations" /')
  content <- c(content,paste0("       ",getModules("modules/")[,"name"]," . %",getModules("modules/")[,"name"],"%"))
  content <- c(content,'      /',';')
  replace_in_file('core/sets.gms',content,"MODULES",comment="***")
  ### ADD MODULE INFO IN SETS  ############# END #########
      
  # choose which conopt files to copy
  cfg$files2export$start <- sub("conopt3",cfg$gms$cm_conoptv,cfg$files2export$start)
  
  # Copy important files into output_folder (before REMIND execution)
  .copy.fromlist(cfg$files2export$start,cfg$results_folder)

  # Save configuration
  save(cfg, file = path(cfg$results_folder, "config.Rdata"))

  # Merge GAMS files
  cat("Creating full.gms\n")
  singleGAMSfile(mainfile=cfg$model,output = path(cfg$results_folder, "full.gms"))
  
  # Collect run statistics (will be saved to central database in submit.R)
  lucode::runstatistics(file = paste0(cfg$results_folder,"/runstatistics.rda"),
                        user = Sys.info()[["user"]],
                        date = Sys.time(),
                        version_management = "git",
                        revision = try(system("git rev-parse --short HEAD", intern=TRUE), silent=TRUE),
                        #revision_date = try(as.POSIXct(system("git show -s --format=%ci", intern=TRUE), silent=TRUE)),
                        status = try(system("git status", intern=TRUE), silent=TRUE))

  ################## M O D E L   U N L O C K ###################################
  # After full.gms was produced remind folders have to be unlocked to allow setting up the next run
  model_unlock(lock_id, oncluster=on_cluster)
  # Reset on.exit: Prevent model_unlock from being executed again at the end
  # and remove "setwd(cfg$results_folder)" from on.exit, becaue we change to it in the next line
  on.exit()
  ################## M O D E L   U N L O C K ###################################
  
  setwd(cfg$results_folder)

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
    
    # Replace fixing.gms with level values
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
    
    #AJS this symbol is not known and crashes the run - is it depreciated? TODO 
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
                                list(c("q40_EV_share.M", "!!q40_EV_share.M")),
                                list(c("q40_TrpEnergyRed.M", "!!q40_TrpEnergyRed.M")),
                                list(c("q40_El_RenShare.M", "!!q40_El_RenShare.M")),
                                list(c("q40_BioFuelBound.M", "!!q40_BioFuelBound.M")))

    }
    
    if(cfg$gms$techpol == 'NPi2018'){
      margs_manipulateThis <- c(margs_manipulateThis, 
                                list(c("q40_El_RenShare.M", "!!q40_El_RenShare.M")),
                                list(c("q40_CoalBound.M", "!!q40_CoalBound.M")))
    }
    
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
    manipulateFile("levs.gms", levs_manipulateThis)
    manipulateFile("fixings.gms", fixings_manipulateThis)
    manipulateFile("margs.gms", margs_manipulateThis)
    
    # Perform actual manipulation on full.gms, in single parse of the text.
    manipulateFile("full.gms", full_manipulateThis)
  }

  #AJS set MAGCFG file
  magcfgFile = paste0('./magicc/MAGCFG_STORE/','MAGCFG_USER_',toupper(cfg$gms$cm_magicc_config),'.CFG')
  if(!file.exists(magcfgFile)){
      stop(paste('ERROR in MAGGICC configuration: Could not find file ',magcfgFile))
  }
  system(paste0('cp ',magcfgFile,' ','./magicc/MAGCFG_USER.CFG'))

  # Prepare the files containing the fixings for delay scenarios (for fixed runs)
  if (  cfg$gms$cm_startyear > 2005  & (!file.exists("levs.gms.gz") | !file.exists("levs.gms"))) {
    create_fixing_files(cfg = cfg, input_ref_file = "input_ref.gdx")
  }
  
  timePrepareEnd <- Sys.time()
  # Save run statistics to local file
  cat("Saving timePrepareStart and timePrepareEnd to runstatistics.rda\n")
  lucode::runstatistics(file           = paste0("runstatistics.rda"),
                      timePrepareStart = timePrepareStart,
                      timePrepareEnd   = timePrepareEnd)
  
  # on.exit sets working directory to results folder
  
} # end of function "prepare"

################################################################################################## 
#                                function: run                                                   #
##################################################################################################

run <- function(start_subsequent_runs = TRUE) {
  
  load("config.Rdata")
  on.exit(setwd(cfg$results_folder))
  
  # Save start time
  timeGAMSStart <- Sys.time()
  
  # Print message
  cat("\nStarting REMIND...\n")

  # Call GAMS
  if (cfg$gms$CES_parameters == "load") {

    system(paste0(cfg$gamsv, " full.gms -errmsg=1 -a=", cfg$action, 
                  " -ps=0 -pw=185 -gdxcompress=1 -logoption=", cfg$logoption))

  } else if (cfg$gms$CES_parameters == "calibrate") {

    # Remember file modification time of fulldata.gdx to see if it changed
    fulldata_m_time <- Sys.time();

    # Save original input
    file.copy("input.gdx", "input_00.gdx", overwrite = TRUE)

    # Iterate calibration algorithm
    for (cal_itr in 1:cfg$gms$c_CES_calibration_iterations) {
      cat("CES calibration iteration: ", cal_itr, "\n")

      # Update calibration iteration in GAMS file
      system(paste0("sed -i 's/^\\(\\$setglobal c_CES_calibration_iteration ", 
                    "\\).*/\\1", cal_itr, "/' full.gms"))

      system(paste0(cfg$gamsv, " full.gms -errmsg=1 -a=", cfg$action, 
                    " -ps=0 -pw=185 -gdxcompress=1 -logoption=", cfg$logoption))

      # If GAMS found a solution
      if (   file.exists("fulldata.gdx")
          && file.info("fulldata.gdx")$mtime > fulldata_m_time) {
        
        #create the file to be used in the load mode
        getLoadFile <- function(){
          
          file_name = paste0(cfg$gms$cm_CES_configuration,"_ITERATION_",cal_itr,".inc")
          ces_in = system("gdxdump fulldata.gdx symb=in NoHeader Format=CSV", intern = TRUE) %>% gsub("\"","",.) #" This comment is just to obtain correct syntax highlighting
          expr_ces_in = paste0("(",paste(ces_in, collapse = "|") ,")")

          
          tmp = system("gdxdump fulldata.gdx symb=pm_cesdata", intern = TRUE)[-(1:2)] %>% 
            grep("(quantity|price|eff|effgr|xi|rho|offset_quantity|compl_coef)", x = ., value = TRUE)
          tmp = tmp %>% grep(expr_ces_in,x = ., value = T)
          
          tmp %>%
            sub("'([^']*)'.'([^']*)'.'([^']*)'.'([^']*)' (.*)[ ,][ /];?",
                "pm_cesdata(\"\\1\",\"\\2\",\"\\3\",\"\\4\") = \\5;", x = .) %>%
            write(file_name)
          
          
          pm_cesdata_putty = system("gdxdump fulldata.gdx symb=pm_cesdata_putty", intern = TRUE)
          if (length(pm_cesdata_putty) == 2){
            tmp_putty =  gsub("^Parameter *([A-z_(,)])+cesParameters\\).*$",'\\1"quantity")  =   0;',  pm_cesdata_putty[2])
          } else {
            tmp_putty = pm_cesdata_putty[-(1:2)] %>%
              grep("quantity", x = ., value = TRUE) %>%
              grep(expr_ces_in,x = ., value = T)
          }
          tmp_putty %>%
            sub("'([^']*)'.'([^']*)'.'([^']*)'.'([^']*)' (.*)[ ,][ /];?",
                "pm_cesdata_putty(\"\\1\",\"\\2\",\"\\3\",\"\\4\") = \\5;", x = .)%>% write(file_name,append =T)
        }
        
        getLoadFile()

        # Store all the interesting output
        file.copy("full.lst", sprintf("full_%02i.lst", cal_itr), overwrite = TRUE)
        file.copy("full.log", sprintf("full_%02i.log", cal_itr), overwrite = TRUE)
        file.copy("fulldata.gdx", "input.gdx", overwrite = TRUE)
        file.copy("fulldata.gdx", sprintf("input_%02i.gdx", cal_itr), 
                  overwrite = TRUE)

        # Update file modification time
        fulldata_m_time <- file.info("fulldata.gdx")$mtime

      } else {
        break
      }
    }
  } else {
    stop("unknown realisation of 29_CES_parameters")
  }

  # Calculate run time statistics
  timeGAMSEnd  <- Sys.time()
  gams_runtime <- timeGAMSEnd - timeGAMSStart
  timeOutputStart <- Sys.time() 

  # If REMIND actually did run
  if (cfg$action == "ce" && cfg$gms$c_skip_output != "on") {

    # Print Message
    cat("\nREMIND run finished!\n")

    # Create solution report for Nash runs
    if (cfg$gms$optimization == "nash" && cfg$gms$cm_nash_mode != "debug" && file.exists("fulldata.gdx")) {
      system("gdxdump fulldata.gdx Format=gamsbas Delim=comma Output=output_nash.gms")
      file.append("full.lst", "output_nash.gms")
      file.remove("output_nash.gms")
    }
  }

  # Print REMIND runtime
  cat("\n gams_runtime is ", gams_runtime, "\n")

  # Collect and submit run statistics to central data base
  lucode::runstatistics(file       = "runstatistics.rda",
                        modelstat  = readGDX(gdx="fulldata.gdx","o_modelstat", format="first_found"),
                        config     = cfg,
                        runtime    = gams_runtime,
                        setup_info = lucode::setup_info(),
                        submit     = cfg$runstatistics)

  # Compress files with the fixing-information
  if (cfg$gms$cm_startyear > 2005) 
    system("gzip -f levs.gms margs.gms fixings.gms")

  # go up to the main folder, where the cfg files for subsequent runs are stored and the output scripts are executed from
  setwd(cfg$remind_folder)

  #====================== Subsequent runs ===========================
  if (start_subsequent_runs) {
    # 1. Save the path to the fulldata.gdx of the current run to the cfg files 
    # of the runs that use it as 'input_bau.gdx'

    # Use the name to check whether it is a coupled run (TRUE if the name ends with "-rem-xx")
    coupled_run <- grepl("-rem-[0-9]{1,2}$",cfg$title)

    no_ref_runs <- identical(cfg$RunsUsingTHISgdxAsBAU,character(0)) | all(is.na(cfg$RunsUsingTHISgdxAsBAU)) | coupled_run

    if(!no_ref_runs) {
      source("scripts/start/submit.R")
      # Save the current cfg settings into a different data object, so that they are not overwritten
      cfg_main <- cfg
      
      for(run in seq(1,length(cfg_main$RunsUsingTHISgdxAsBAU))){
        # for each of the runs that use this gdx as bau, read in the cfg, ...
        cat("Writing the path for input_bau.gdx to ",paste0(cfg_main$RunsUsingTHISgdxAsBAU[run],".RData"),"\n")
        load(paste0(cfg_main$RunsUsingTHISgdxAsBAU[run],".RData"))
        # ...change the path_gdx_bau field of the subsequent run to the fulldata gdx of the current run ...
        cfg$files2export$start['input_bau.gdx'] <- paste0(cfg_main$remind_folder,"/",cfg_main$results_folder,"/fulldata.gdx")
        save(cfg, file = paste0(cfg_main$RunsUsingTHISgdxAsBAU[run],".RData"))
      }
      # Set cfg back to original
      cfg <- cfg_main
    }

    # 2. Save the path to the fulldata.gdx of the current run to the cfg files 
    # of the subsequent runs that use it as 'input_ref.gdx' and start these runs 

    no_subsequent_runs <- identical(cfg$subsequentruns,character(0)) | identical(cfg$subsequentruns,NULL) | coupled_run

    if(no_subsequent_runs){
      cat('\nNo subsequent run was set for this scenario\n')
    } else {
      # Save the current cfg settings into a different data object, so that they are not overwritten
      cfg_main <- cfg
      source("scripts/start/submit.R")
      
      for(run in seq(1,length(cfg_main$subsequentruns))){
        # for each of the subsequent runs, read in the cfg, ...
        cat("Writing the path for input_ref.gdx to ",paste0(cfg_main$subsequentruns[run],".RData"),"\n")
        load(paste0(cfg_main$subsequentruns[run],".RData"))
        # ...change the path_gdx_ref field of the subsequent run to the fulldata gdx of the current (preceding) run ...
        cfg$files2export$start['input_ref.gdx'] <- paste0(cfg_main$remind_folder,"/",cfg_main$results_folder,"/fulldata.gdx")
        save(cfg, file = paste0(cfg_main$subsequentruns[run],".RData"))
        
        # Subsequent runs will be started in submit.R using the RData files written above 
        # after the current run has finished.
        cat("Starting subsequent run ",cfg_main$subsequentruns[run],"\n")
        submit(cfg)
      }
      # Set cfg back to original
      cfg <- cfg_main
    }

    # 3. Create script file that can be used later to restart the subsequent runs manually.
    # In case there are no subsequent runs (or it's coupled runs), the file contains only 
    # a small message.

    subseq_start_file  <- paste0(cfg$results_folder,"/start_subsequentruns_manually.R")

    if(no_subsequent_runs){
      write("cat('\nNo subsequent run was set for this scenario\n')",file=subseq_start_file)
    } else {
      #  go up to the main folder, where the cfg. files for subsequent runs are stored
      filetext <- paste0("setwd('",cfg$remind_folder,"')\n")
      filetext <- paste0(filetext,"source('scripts/start/submit.R')\n")
      for(run in seq(1,length(cfg$subsequentruns))){
        filetext <- paste0(filetext,"\n")
        filetext <- paste0(filetext,"load('",cfg$subsequentruns[run],".RData')\n")
        #filetext <- paste0(filetext,"cfg$results_folder <- 'output/:title::date:'\n")
        filetext <- paste0(filetext,"cat('",cfg$subsequentruns[run],"')\n")
        filetext <- paste0(filetext,"submit(cfg)\n")
      }
      # Write the text to the file
      write(filetext,file=subseq_start_file)
    }
  }
  #=================== END - Subsequent runs ========================
  
  # Copy important files into output_folder (after REMIND execution)
  for (file in cfg$files2export$end)
    file.copy(file, cfg$results_folder, overwrite = TRUE)

  # Set source_include so that loaded scripts know they are included as 
  # source (instead of being executed from the command line)
  source_include <- TRUE
   
  # Postprocessing / Output Generation
  output    <- cfg$output
  outputdir <- cfg$results_folder
  sys.source("output.R",envir=new.env())
  # get runtime for output
  timeOutputEnd <- Sys.time()
  
  # Save run statistics to local file
  cat("Saving timeGAMSStart, timeGAMSEnd, timeOutputStart and timeOutputStart to runstatistics.rda\n")
  lucode::runstatistics(file           = paste0(cfg$results_folder, "/runstatistics.rda"),
                       timeGAMSStart   = timeGAMSStart,
                       timeGAMSEnd     = timeGAMSEnd,
                       timeOutputStart = timeOutputStart,
                       timeOutputEnd   = timeOutputEnd)
  
  return(cfg$results_folder)
  # on.exit sets working directory back to results folder
  
} # end of function "run"


################################################################################################## 
#                                    script                                                      #
##################################################################################################

# Call prepare and run without cfg, because cfg is read from results folder, where it has been 
# copied to by submit(cfg)

if (!file.exists("fulldata.gdx")) {
  # If no "fulldata.gdx" exists, the script assumes that REMIND did not run before and 
  # prepares all inputs before starting the run.
  prepare()
  start_subsequent_runs <- TRUE
} else {
  # If "fulldata.gdx" exists, the script assumes that REMIND did run before and you want 
  # to restart REMIND in the same folder using the gdx that it previously produced.
  file.copy("fulldata.gdx", "input.gdx", overwrite = TRUE)
  start_subsequent_runs <- FALSE
}

# Run REMIND, start subsequent runs (if applicable), and produce output.
run(start_subsequent_runs)
