# |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
library(gms, quietly = TRUE,warn.conflicts =FALSE)
library(lucode2, quietly = TRUE,warn.conflicts =FALSE)
library(dplyr, quietly = TRUE,warn.conflicts =FALSE)
library(yaml, quietly = TRUE,warn.conflicts=FALSE)
require(gdx)

##################################################################################################
#                             function: getReportData                                            #
##################################################################################################

getReportData <- function(path_to_report,inputpath_mag="magpie",inputpath_acc="costs") {
  #require(lucode, quietly = TRUE,warn.conflicts =FALSE)
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
    write.magpie(out[notGLO,,],paste0("./modules/30_biomass/",inputpath_mag,"/input/pm_pebiolc_demandmag_coupling.csv"),file_type="csvr")
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
      # MAgPIE 4 (up to date)
      map <- rbind(map,data.frame(emimag="Emissions|CO2|Land|+|Land-use Change (Mt CO2/yr)",                                               emirem="co2luc",    factor_mag2rem=1/1000*12/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land|Agriculture|+|Animal Waste Management (Mt N2O/yr)",                           emirem="n2oanwstm", factor_mag2rem=28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land|Agriculture|Agricultural Soils|+|Inorganic Fertilizers (Mt N2O/yr)",          emirem="n2ofertin", factor_mag2rem=28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land|Agriculture|Agricultural Soils|+|Manure applied to Croplands (Mt N2O/yr)",    emirem="n2oanwstc", factor_mag2rem=28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land|Agriculture|Agricultural Soils|+|Decay of Crop Residues (Mt N2O/yr)",         emirem="n2ofertcr", factor_mag2rem=28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land|Agriculture|Agricultural Soils|+|Soil Organic Matter Loss (Mt N2O/yr)",       emirem="n2ofertsom",factor_mag2rem=28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land|Agriculture|Agricultural Soils|+|Pasture (Mt N2O/yr)",                        emirem="n2oanwstp", factor_mag2rem=28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land|+|Peatland (Mt N2O/yr)",                                                      emirem="n2opeatland", factor_mag2rem=28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|CH4|Land|Agriculture|+|Rice (Mt CH4/yr)",                                              emirem="ch4rice",   factor_mag2rem=1,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|CH4|Land|Agriculture|+|Animal waste management (Mt CH4/yr)",                           emirem="ch4anmlwst",factor_mag2rem=1,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|CH4|Land|Agriculture|+|Enteric fermentation (Mt CH4/yr)",                              emirem="ch4animals",factor_mag2rem=1,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|CH4|Land|+|Peatland (Mt CH4/yr)",                                                      emirem="ch4peatland",factor_mag2rem=1,stringsAsFactors=FALSE))
    } else if("Emissions|N2O-N|Land|Agriculture|+|Animal Waste Management (Mt N2O-N/yr)" %in% getNames(mag)) {
      # MAgPIE 4 (intermediate - wrong units)
      map <- rbind(map,data.frame(emimag="Emissions|CO2|Land|+|Land-use Change (Mt CO2/yr)",                                               emirem="co2luc",    factor_mag2rem=1/1000*12/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O-N|Land|Agriculture|+|Animal Waste Management (Mt N2O-N/yr)",                       emirem="n2oanwstm", factor_mag2rem=28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O-N|Land|Agriculture|Agricultural Soils|+|Inorganic Fertilizers (Mt N2O-N/yr)",      emirem="n2ofertin", factor_mag2rem=28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O-N|Land|Agriculture|Agricultural Soils|+|Manure applied to Croplands (Mt N2O-N/yr)",emirem="n2oanwstc", factor_mag2rem=28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O-N|Land|Agriculture|Agricultural Soils|+|Decay of Crop Residues (Mt N2O-N/yr)",     emirem="n2ofertcr", factor_mag2rem=28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O-N|Land|Agriculture|Agricultural Soils|+|Soil Organic Matter Loss (Mt N2O-N/yr)",   emirem="n2ofertsom",factor_mag2rem=28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O-N|Land|Agriculture|Agricultural Soils|+|Pasture (Mt N2O-N/yr)",                    emirem="n2oanwstp", factor_mag2rem=28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|CH4|Land|Agriculture|+|Rice (Mt CH4/yr)",                                              emirem="ch4rice",   factor_mag2rem=1,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|CH4|Land|Agriculture|+|Animal waste management (Mt CH4/yr)",                           emirem="ch4anmlwst",factor_mag2rem=1,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|CH4|Land|Agriculture|+|Enteric fermentation (Mt CH4/yr)",                              emirem="ch4animals",factor_mag2rem=1,stringsAsFactors=FALSE))
    } else if("Emissions|CO2|Land Use (Mt CO2/yr)" %in% getNames(mag)) {
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
    } else {
      stop("Emission data not found in MAgPIE report. Check MAgPIE reporting file.")
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

        # Check for negative values, since only "co2luc" is allowed to be
        # negative. All other emission variables are positive by definition.
        if(map[i,]$emirem != "co2luc"){
          if( !(all(tmp>=0)) ){
            # Hotfix 2021-09-28: Raise warning and set negative values to zero.
            # XXX Todo XXX: Make sure that MAgPIE is not reporting negative N2O
            # or CH4 emissions and convert this warning into an error that
            # breaks the model instead of setting the values to zero.
            print(paste0("Warning: Negative values detected for '",
                         map[i,]$emirem, "' / '", map[i,]$emimag, "'. ",
                         "Hot fix: Set respective values to zero."))
            tmp[tmp < 0] <- 0
          }
        }

        # Add emission variable to full dataframe
        out<-mbind(out,tmp)
    }

    # Write REMIND input file
    notGLO   <- getRegions(mag)[!(getRegions(mag)=="GLO")]
    filename <- paste0("./core/input/f_macBaseMagpie_coupling.cs4r")
    write.magpie(out[notGLO,,],filename)
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
	      if(!file.copy(filelist[i],to=to,recursive=dir.exists(to),overwrite=T))
	        cat(paste0("Could not copy ",filelist[i]," to ",to,"\n"))
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
            "plotly", "remind2", "rlang", "rmndt", "tidyverse",
            "tools"),

        'Package') %>%
    print(n = Inf)
  cat("\n==========\n")

  load("config.Rdata")

  # Store results folder of current scenario
  on.exit(setwd(cfg$results_folder))

  # change to REMIND main folder
  setwd(cfg$remind_folder)

  # Check configuration for consistency
#  cfg <- check_config(cfg, reference_file="config/default.cfg",
#                      settings_config = "config/settings_config.csv",
#                      extras = c("backup", "remind_folder", "pathToMagpieReport", "cm_nash_autoconverge_lastrun",
#                                 "gms$c_expname", "restart_subsequent_runs", "gms$c_GDPpcScen",
#                                 "gms$cm_CES_configuration", "gms$c_description"))

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

  # Copy MAGICC
  if ( !file.exists(cfg$magicc_template)
     & file.exists(path.expand(Sys.getenv('MAGICC'))))
      cfg$magicc_template <- path.expand(Sys.getenv('MAGICC'))

  if (file.exists(cfg$magicc_template)) {
      cat("Copying MAGICC files from",cfg$magicc_template,"to results folder\n")
      system(paste0("cp -nrp ",cfg$magicc_template," ",cfg$results_folder))
      system(paste0("cp -nrp core/magicc/* ",cfg$results_folder,"/magicc/"))
    } else {
      cat("Could not copy",cfg$magicc_template,"because it does not exist\n")
    }

  # Make sure all MAGICC files have LF line endings, so Fortran won't crash
  if (on_cluster)
    system(paste0("find ",cfg$results_folder,"/magicc/ -type f | xargs dos2unix -q"))

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

  # Calculate CES configuration string
  cfg$gms$cm_CES_configuration <- paste0("indu_",cfg$gms$industry,"-",
                                         "buil_",cfg$gms$buildings,"-",
                                         "tran_",cfg$gms$transport,"-",
                                         "POP_", cfg$gms$cm_POPscen, "-",
                                         "GDP_", cfg$gms$cm_GDPscen, "-",
                                         "En_",  cfg$gms$cm_demScen, "-",
                                         "Kap_", cfg$gms$capitalMarket, "-",
                                         if(cfg$gms$cm_calibration_string == "off") "" else paste0(cfg$gms$cm_calibration_string, "-"),
                                         "Reg_", regionscode(cfg$regionmapping))

  # write name of corresponding CES file to datainput.gms
  replace_in_file(file    = "./modules/29_CES_parameters/load/datainput.gms",
                  content = paste0('$include "./modules/29_CES_parameters/load/input/',cfg$gms$cm_CES_configuration,'.inc"'),
                  subject = "CES INPUT")

  # If a path to a MAgPIE report is supplied use it as REMIND input (used for REMIND-MAgPIE coupling)
  # ATTENTION: modifying gms files
  if (!is.null(cfg$pathToMagpieReport)) {
    getReportData(path_to_report = cfg$pathToMagpieReport,inputpath_mag=cfg$gms$biomass,inputpath_acc=cfg$gms$agCosts)
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
  update_info <- function(regionscode, revision) {

    subject <- "VERSION INFO"
    content <- c("",
      paste("Regionscode:", regionscode),
      "",
      paste("Input data revision:", revision),
      "",
      paste("Last modification (input data):",
            format(file.mtime("input/source_files.log"), "%a %b %d %H:%M:%S %Y")),
      "")
    replace_in_file(tmpModelFile, paste("*", content), subject)
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
      '*** CHANGES CAN BE DONE USING THE RESPECTIVE LINES IN scripts/start/prepare_and_run.R')
    content <- c(modification_warning,'','sets')
    # create iso set with nice formatting (10 countries per line)
    tmp <- lapply(split(map$CountryCode, ceiling(seq_along(map$CountryCode)/10)),paste,collapse=",")
    regions <- as.character(unique(map$RegionCode))
    # Creating sets for H12 subregions
    subsets <- remind2::toolRegionSubsets(map=cfg$regionmapping,singleMatches=TRUE,removeDuplicates=FALSE)
    if(grepl("regionmapping_21_EU11", cfg$regionmapping, fixed = TRUE)){ #add EU27 region group
      subsets <- c(subsets,list(
        "EU27"=c("ENC","EWN","ECS","ESC","ECE","FRA","DEU","ESW"), #EU27 (without Ireland)
        "NEU_UKI"=c("NES", "NEN", "UKI") #EU27 (without Ireland)
      ) )
    }
    # declare ext_regi (needs to be declared before ext_regi to keep order of ext_regi)
    content <- c(content, paste('   ext_regi "extended regions list (includes subsets of H12 regions)"'))
    content <- c(content, '      /')
    content <- c(content, '        GLO,')
    content <- c(content, '        ', paste(paste0(names(subsets),"_regi"),collapse=','),",")
    content <- c(content, '        ', paste(regions,collapse=','))
    content <- c(content, '      /')
    content <- c(content, ' ')
    # declare all_regi
    content <- c(content, '',paste('   all_regi "all regions" /',paste(regions,collapse=','),'/',sep=''),'')
    # regi_group
    content <- c(content, '   regi_group(ext_regi,all_regi) "region groups (regions that together corresponds to a H12 region)"')
    content <- c(content, '      /')
    content <- c(content, '      ', paste('GLO.(',paste(regions,collapse=','),')'))
    for (i in 1:length(subsets)){
        content <- c(content, paste0('        ', paste(c(paste0(names(subsets)[i],"_regi"))), ' .(',paste(subsets[[i]],collapse=','), ')'))
    }
    content <- c(content, '      /')
    content <- c(content, ' ')
    # iso countries set
    content <- c(content,'   iso "list of iso countries" /')
    content <- c(content, .tmp(map$CountryCode, suffix1=",", suffix2=" /"),'')
    content <- c(content,'   regi2iso(all_regi,iso) "mapping regions to iso countries"','      /')
    for(i in as.character(unique(map$RegionCode))) {
      content <- c(content, .tmp(map$CountryCode[map$RegionCode==i], prefix=paste0(i," . ("), suffix1=")", suffix2=")"))
    }
    content <- c(content,'      /')
    content <- c(content, 'iso_regi "all iso countries and EU and greater China region" /  EUR,CHA,')
    content <- c(content, .tmp(map$CountryCode, suffix1=",", suffix2=" /"),'')
    content <- c(content,'   map_iso_regi(iso_regi,all_regi) "mapping from iso countries to regions that represent country" ','         /')
    for(i in regions[regions %in% c("EUR","CHA",as.character(unique(map$CountryCode)))]) {
      content <- c(content, .tmp(i, prefix=paste0(i," . "), suffix1="", suffix2=""))
    }
    content <- c(content,'      /',';')
    replace_in_file('core/sets.gms',content,"SETS",comment="***")
  }

  ############ download and distribute input data ########
  # check whether the regional resolution and input data revision are outdated and update data if needed
  if(file.exists("input/source_files.log")) {
      input_old     <- readLines("input/source_files.log")[c(1,2,3)]
  } else {
      input_old     <- "no_data"
  }
  input_new      <- c(paste0("rev",cfg$inputRevision,"_", regionscode(cfg$regionmapping),"_", tolower(cfg$model_name),".tgz"),
                      paste0("rev",cfg$inputRevision,"_", regionscode(cfg$regionmapping),ifelse(cfg$extramappings_historic == "","",paste0("-", regionscode(cfg$extramappings_historic))),"_", tolower(cfg$validationmodel_name),".tgz"),
                      paste0("CESparametersAndGDX_",cfg$CESandGDXversion,".tgz"))
  # download and distribute needed data
  if(!setequal(input_new, input_old) | cfg$force_download) {
      message(if (cfg$force_download) "You set 'cfg$force_download = TRUE'"
              else "Your input data are outdated or in a different regional resolution",
              ". New input data are downloaded and distributed.")
      download_distribute(files        = input_new,
                          repositories = cfg$repositories, # defined in your environment variables
                          modelfolder  = ".",
                          debug        = FALSE,
			  stopOnMissing = TRUE)
  } else {
      message("No input data downloaded and distributed. To enable that, delete input/source_files.log or set cfg$force_download to TRUE.")
  }

  # extract BAU emissions for NDC runs to set up emission goals for region where only some countries have a target
  if ((!is.null(cfg$gms$carbonprice) && (cfg$gms$carbonprice == "NDC")) | (!is.null(cfg$gms$carbonpriceRegi) && (cfg$gms$carbonpriceRegi == "NDC")) ){
    cat("\nRun scripts/input/prepare_NDC.R.\n")
    source("scripts/input/prepare_NDC.R")
    prepare_NDC(as.character(cfg$files2export$start["input_bau.gdx"]), cfg)
  }

  ############ update information ########################
  # update_info, which regional resolution and input data revision in tmpModelFile
  update_info(regionscode(cfg$regionmapping), cfg$inputRevision)
  # update_sets, which is updating the region-depending sets in core/sets.gms
  #-- load new mapping information
  map <- read.csv(cfg$regionmapping, sep=";")
  update_sets(map)

  ########################################################
  ### PROCESSING INPUT DATA ###################### END ###
  ########################################################

  ### ADD MODULE INFO IN SETS  ############# START #######
  content <- NULL
  modification_warning <- c(
    '*** THIS CODE IS CREATED AUTOMATICALLY, DO NOT MODIFY THESE LINES DIRECTLY',
    '*** ANY DIRECT MODIFICATION WILL BE LOST AFTER NEXT MODEL START',
    '*** CHANGES CAN BE DONE USING THE RESPECTIVE LINES IN scripts/start/prepare_and_run.R')
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
  try(file.copy("magicc/run_magicc.R","run_magicc.R"))
  try(file.copy("magicc/run_magicc_temperatureImpulseResponse.R","run_magicc_temperatureImpulseResponse.R"))
  try(file.copy("magicc/read_DAT_TOTAL_ANTHRO_RF.R","read_DAT_TOTAL_ANTHRO_RF.R"))
  try(file.copy("magicc/read_DAT_SURFACE_TEMP.R","read_DAT_SURFACE_TEMP.R"))

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
                                list(c("q39_shSynGas.M", "!!q39_shSynGas.M")),
                                list(c("q39_EqualSecShare_BioSyn.M", "!!q39_EqualSecShare_BioSyn.M")))
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

    #KK CDR module realizations
    if(cfg$gms$CDR == 'DAC'){
      fixings_manipulateThis <- c(fixings_manipulateThis,
                                  list(c("v33_emiEW.FX", "!!v33_emiEW.FX")),
                                  list(c("v33_grindrock_onfield.FX", "!!v33_grindrock_onfield.FX")),
                                  list(c("v33_grindrock_onfield_tot.FX", "!!v33_grindrock_onfield_tot.FX")))

      levs_manipulateThis <- c(levs_manipulateThis,
                               list(c("v33_emiEW.L", "!!v33_emiEW.L")),
                               list(c("v33_grindrock_onfield.L", "!!v33_grindrock_onfield.L")),
                               list(c("v33_grindrock_onfield_tot.L", "!!v33_grindrock_onfield_tot.L")))

      margs_manipulateThis <- c(margs_manipulateThis,
                                list(c("v33_emiEW.M", "!!v33_emiEW.M")),
                                list(c("v33_grindrock_onfield.M", "!!v33_grindrock_onfield.M")),
                                list(c("v33_grindrock_onfield_tot.M", "!!v33_grindrock_onfield_tot.M")),
                                list(c("q33_capconst_grindrock.M", "!!q33_capconst_grindrock.M")),
                                list(c("q33_grindrock_onfield_tot.M", "!!q33_grindrock_onfield_tot.M")),
                                list(c("q33_omcosts.M", "!!q33_omcosts.M")),
                                list(c("q33_potential.M", "!!q33_potential.M")),
                                list(c("q33_emiEW.M", "!!q33_emiEW.M")),
                                list(c("q33_LimEmiEW.M", "!!q33_LimEmiEW.M")))
    }

    if(cfg$gms$CDR == 'weathering'){
      fixings_manipulateThis <- c(fixings_manipulateThis,
                                  list(c("v33_emiDAC.FX", "!!v33_emiDAC.FX")),
                                  list(c("v33_DacFEdemand_el.FX", "!!v33_DacFEdemand_el.FX")),
                                  list(c("v33_DacFEdemand_heat.FX", "!!v33_DacFEdemand_heat.FX")))

      levs_manipulateThis <- c(levs_manipulateThis,
                               list(c("v33_emiDAC.L", "!!v33_emiDAC.L")),
                               list(c("v33_DacFEdemand_el.L", "!!v33_DacFEdemand_el.L")),
                               list(c("v33_DacFEdemand_heat.L", "!!v33_DacFEdemand_heat.L")))

      margs_manipulateThis <- c(margs_manipulateThis,
                                list(c("v33_emiDAC.M", "!!v33_emiDAC.")),
                                list(c("v33_DacFEdemand_el.M", "!!v33_DacFEdemand_el.M")),
                                list(c("v33_DacFEdemand_heat.M", "!!v33_DacFEdemand_heat.M")),
                                list(c("q33_DacFEdemand_heat.M", "!!q33_DacFEdemand_heat.M")),
                                list(c("q33_DacFEdemand_el.M", "!!q33_DacFEdemand_el.M")),
                                list(c("q33_capconst_dac.M", "!!q33_capconst_dac.M")),
                                list(c("q33_ccsbal.M", "!!q33_ccsbal.M")),
                                list(c("q33_H2bio_lim.M", "!!q33_H2bio_lim.M")))
    }

    if(cfg$gms$CDR == 'off'){
      fixings_manipulateThis <- c(fixings_manipulateThis,
                                  list(c("v33_emiDAC.FX", "!!v33_emiDAC.FX")),
                                  list(c("v33_emiEW.FX", "!!v33_emiEW.FX")),
                                  list(c("v33_DacFEdemand_el.FX", "!!v33_DacFEdemand_el.FX")),
                                  list(c("v33_DacFEdemand_heat.FX", "!!v33_DacFEdemand_heat.FX")),
                                  list(c("v33_grindrock_onfield.FX", "!!v33_grindrock_onfield.FX")),
                                  list(c("v33_grindrock_onfield_tot.FX", "!!v33_grindrock_onfield_tot.FX")))

      levs_manipulateThis <- c(levs_manipulateThis,
                               list(c("v33_emiDAC.L", "!!v33_emiDAC.L")),
                               list(c("v33_emiEW.L", "!!v33_emiEW.L")),
                               list(c("v33_DacFEdemand_el.L", "!!v33_DacFEdemand_el.L")),
                               list(c("v33_DacFEdemand_heat.L", "!!v33_DacFEdemand_heat.L")),
                               list(c("v33_grindrock_onfield.L", "!!v33_grindrock_onfield.L")),
                               list(c("v33_grindrock_onfield_tot.L", "!!v33_grindrock_onfield_tot.L")))

      margs_manipulateThis <- c(margs_manipulateThis,
                                list(c("v33_emiDAC.M", "!!v33_emiDAC.M")),
                                list(c("v33_emiEW.M", "!!v33_emiEW.M")),
                                list(c("v33_grindrock_onfield.M", "!!v33_grindrock_onfield.M")),
                                list(c("v33_grindrock_onfield_tot.M", "!!v33_grindrock_onfield_tot.M")),
                                list(c("v33_DacFEdemand_el.M", "!!v33_DacFEdemand_el.M")),
                                list(c("v33_DacFEdemand_heat.M", "!!v33_DacFEdemand_heat.M")),
                                list(c("q33_capconst_grindrock.M", "!!q33_capconst_grindrock.M")),
                                list(c("q33_grindrock_onfield_tot.M", "!!q33_grindrock_onfield_tot.M")),
                                list(c("q33_omcosts.M", "!!q33_omcosts.M")),
                                list(c("q33_potential.M", "!!q33_potential.M")),
                                list(c("q33_emiEW.M", "!!q33_emiEW.M")),
                                list(c("q33_LimEmiEW.M", "!!q33_LimEmiEW.M")),
                                list(c("q33_DacFEdemand_heat.M", "!!q33_DacFEdemand_heat.M")),
                                list(c("q33_DacFEdemand_el.M", "!!q33_DacFEdemand_el.M")),
                                list(c("q33_capconst_dac.M", "!!q33_capconst_dac.M")),
                                list(c("q33_ccsbal.M", "!!q33_ccsbal.M")),
                                list(c("q33_H2bio_lim.M", "!!q33_H2bio_lim.M")),
                                list(c("q33_demFeCDR.M", "!!q33_demFeCDR.M")),
                                list(c("q33_emicdrregi.M", "!!q33_emicdrregi.M")),
                                list(c("q33_otherFEdemand.M", "!!q33_otherFEdemand.M")))
    }
    # end of CDR module realizations

    levs_manipulateThis <- c(levs_manipulateThis,
                               list(c("vm_shBioFe.L","!!vm_shBioFe.L")))
    fixings_manipulateThis <- c(fixings_manipulateThis,
                                list(c("vm_shBioFe.FX","!!vm_shBioFe.FX")))
    margs_manipulateThis <- c(margs_manipulateThis,
                                list(c("vm_shBioFe.M", "!!vm_shBioFe.M")))


    # OR: renamed for sectoral taxation
    levs_manipulateThis <- c(levs_manipulateThis,
                             list(c("vm_emiCO2_sector.L", "vm_emiCO2Sector.L")),
                             list(c("v21_taxrevCO2_sector.L", "v21_taxrevCO2Sector.L")))
    margs_manipulateThis <- c(margs_manipulateThis,
                             list(c("vm_emiCO2_sector.M", "vm_emiCO2Sector.M")),
                             list(c("v21_taxrevCO2_sector.M", "v21_taxrevCO2Sector.M")),
                             list(c("q_emiCO2_sector.M", "q_emiCO2Sector.M")),
                             list(c("q21_taxrevCO2_sector.M", "q21_taxrevCO2Sector.M")))
    fixings_manipulateThis <- c(fixings_manipulateThis,
                             list(c("vm_emiCO2_sector.FX", "vm_emiCO2Sector.FX")),
                             list(c("v21_taxrevCO2_sector.FX", "v21_taxrevCO2Sector.FX")))

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

    # renamed because of https://github.com/remindmodel/remind/pull/1106
    levs_manipulateThis <- c(levs_manipulateThis,
                             list(c("v21_taxrevBioImport.L", "!!v21_taxrevBioImport.L")))
    margs_manipulateThis <- c(margs_manipulateThis,
                             list(c("v21_taxrevBioImport.M", "!!v21_taxrevBioImport.M")),
                             list(c("q21_taxrevBioImport.M", "!!q21_taxrevBioImport.M")),
                             list(c("q30_limitProdtoHist.M", "!!q30_limitProdtoHist.M")))    
    fixings_manipulateThis <- c(fixings_manipulateThis,
                            list(c("v21_taxrevBioImport.FX", "!!v21_taxrevBioImport.FX")))

    # renamed because of https://github.com/remindmodel/remind/pull/1128
    levs_manipulateThis <- c(levs_manipulateThis,
                             list(c("v_emiTeDetailMkt.L", "!!v_emiTeDetailMkt.L")),
                             list(c("v_emiTeMkt.L", "!!v_emiTeMkt.L")))    
    margs_manipulateThis <- c(margs_manipulateThis,
                             list(c("v_emiTeDetailMkt.M", "!!v_emiTeDetailMkt.M")),
                             list(c("v_emiTeMkt.M", "!!v_emiTeMkt.M")))    
    fixings_manipulateThis <- c(fixings_manipulateThis,
                            list(c("v_emiTeDetailMkt.FX", "!!v_emiTeDetailMkt.FX")),
                             list(c("v_emiTeMkt.FX", "!!v_emiTeMkt.FX")))   

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
  lucode2::runstatistics(file           = paste0("runstatistics.rda"),
                      timePrepareStart = timePrepareStart,
                      timePrepareEnd   = timePrepareEnd)

  # on.exit sets working directory to results folder

} # end of function "prepare"

##################################################################################################
#                                function: run                                                   #
##################################################################################################

run <- function(start_subsequent_runs = TRUE) {

  load("config.Rdata")

  # Save start time
  timeGAMSStart <- Sys.time()

  # De-compress fixing files if they have already been zipped (only valid if run is restarted)
  if (cfg$gms$cm_startyear > 2005) {
      if (file.exists("levs.gms.gz")) {
        cat("Unzip fixing files\n")
        system("gzip -d -f levs.gms.gz margs.gms.gz fixings.gms.gz")
      } else if (file.exists("levs.gms")) {
        cat("Found unzipped fixing files. Using them.\n")
      } else {
        stop("cm_startyear > 2005 but no fixing files found, neither zipped or unzipped.")
      }
  }

  # Print message
  cat("\nStarting REMIND...\n")
  cat("GAMS will provide logging in full.log.\n")

  # Call GAMS
  if (cfg$gms$CES_parameters == "load") {

    system(paste0(cfg$gamsv, " full.gms -errmsg=1 -a=", cfg$action,
                  " -ps=0 -pw=185 -pc=2 -gdxcompress=1 -holdFixedAsync=1 -logoption=", cfg$logoption))

  } else if (cfg$gms$CES_parameters == "calibrate") {

    # Remember file modification time of fulldata.gdx to see if it changed
    fulldata_m_time <- Sys.time();

    # Save original input
    file.copy("input.gdx", "input_00.gdx", overwrite = TRUE)

    # Iterate calibration algorithm
    for (cal_itr in 1:cfg$gms$c_CES_calibration_iterations) {
      cat("CES calibration iteration: ", cal_itr, "\n")

      # Update calibration iteration environment variable
      Sys.setenv(cm_CES_calibration_iteration = cal_itr)

      system(paste0(cfg$gamsv, " full.gms -errmsg=1 -a=", cfg$action,
                    " -ps=0 -pw=185 -pc=2 -gdxcompress=1 -holdFixedAsync=1 -logoption=", cfg$logoption))

      # If GAMS found a solution
      if (   file.exists("fulldata.gdx")
          && file.info("fulldata.gdx")$mtime > fulldata_m_time) {

        #create the file to be used in the load mode
        getLoadFile <- function(){

          file_name = sprintf('%s_ITERATION_%02i.inc',
                              cfg$gms$cm_CES_configuration, cal_itr)
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
        interestingOutput <- c("full.lst", "full.log", "fulldata.gdx", "non_optimal.gdx", "abort.gdx")
        file.copy(from = interestingOutput,
                  to = sub("^(.*)(\\.[^\\.]+)$",
                           sprintf("\\1_%02i\\2", cal_itr),
                           interestingOutput),
                  overwrite = TRUE,
                  copy.date = TRUE)
        file.copy("fulldata.gdx", "input.gdx", overwrite = TRUE)
        if (cal_itr < as.integer(cfg$gms$c_CES_calibration_iterations)) {
          unlink(c("abort.gdx", "non_optimal.gdx"))
        } else { # calibration was successful
          file.copy("fulldata.gdx", paste0(cfg$gms$cm_CES_configuration, ".gdx"))
          file.copy(from = sprintf('%s_ITERATION_%02i.inc',
                                   cfg$gms$cm_CES_configuration, cal_itr),
                    to = paste0(cfg$gms$cm_CES_configuration, ".inc"))
        }

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

    # Print Message.
    cat("\nREMIND run finished!\n\n")

    # Create solution report for Nash runs
    if (cfg$gms$optimization == "nash" && cfg$gms$cm_nash_mode != "debug" && file.exists("fulldata.gdx")) {
      system("gdxdump fulldata.gdx Format=gamsbas Delim=comma Output=output_nash.gms")
      file.append("full.lst", "output_nash.gms")
      file.remove("output_nash.gms")
    }
  }
  if (cfg$action == "c") {
    cat("\nREMIND was compiled but not executed, because cfg$action was set to 'c'\n\n")
  }

  explain_modelstat <- c("1" = "Optimal", "2" = "Locally Optimal", "3" = "Unbounded", "4" = "Infeasible",
                         "5" = "Locally Infeasible", "6" = "Intermediate Infeasible", "7" = "Intermediate Nonoptimal")
  modelstat <- numeric(0)
  stoprun <- FALSE

  # to facilitate debugging, look which files were created.
  message("Model summary:")
  # Print REMIND runtime
  message("  gams_runtime is ", round(gams_runtime,1), " ", units(gams_runtime), ".")
  if (! file.exists("full.gms")) {
    message("! full.gms does not exist, so the REMIND GAMS code was not generated.")
    stoprun <- TRUE
  } else {
    message("  full.gms exists, so the REMIND GAMS code was generated.")
    if (! file.exists("full.lst") | ! file.exists("full.log")) {
      message("! full.log or full.lst does not exist, so GAMS did not run.")
      stoprun <- TRUE
    } else {
      message("  full.log and full.lst exist, so GAMS did run.")
      if (! file.exists("abort.gdx")) {
        message("  abort.gdx does not exist, a file written automatically for some types of errors.")
      } else {
        message("! abort.gdx exists, a file containing the latest data at the point GAMS aborted execution.")
      }
      if (! file.exists("non_optimal.gdx")) {
        message("  non_optimal.gdx does not exist, a file written if at least one iteration did not find a locally optimal solution.")
      } else {
        modelstat_no <- as.numeric(readGDX(gdx = "non_optimal.gdx", "o_modelstat", format = "simplest"))
        max_iter_no  <- as.numeric(readGDX(gdx = "non_optimal.gdx", "o_iterationNumber", format = "simplest"))
        message("  non_optimal.gdx exists, because iteration ", max_iter_no, " did not find a locally optimal solution. ",
          "modelstat: ", modelstat_no, if (modelstat_no %in% names(explain_modelstat)) paste0(" (", explain_modelstat[modelstat_no], ")"))
        modelstat[[as.character(max_iter_no)]] <- modelstat_no
      }
      if(! file.exists("fulldata.gdx")) {
        message("! fulldata.gdx does not exist, so output generation will fail.")
        if (cfg$action == "ce") {
          stoprun <- TRUE
        }
      } else {
        modelstat_fd <- as.numeric(readGDX(gdx = "fulldata.gdx", "o_modelstat", format = "simplest"))
        max_iter_fd  <- as.numeric(readGDX(gdx = "fulldata.gdx", "o_iterationNumber", format = "simplest"))
        message("  fulldata.gdx exists, because iteration ", max_iter_fd, " was successful. ",
          "modelstat: ", modelstat_fd, if (modelstat_fd %in% names(explain_modelstat)) paste0(" (", explain_modelstat[modelstat_fd], ")"))
        modelstat[[as.character(max_iter_fd)]] <- modelstat_fd
      }
      if (length(modelstat) > 0) {
        modelstat <- modelstat[which.max(names(modelstat))]
        message("  Modelstat after ", as.numeric(names(modelstat)), " iterations: ", modelstat,
                if (modelstat %in% names(explain_modelstat)) paste0(" (", explain_modelstat[modelstat], ")"))
      }
      logStatus <- grep("*** Status", readLines("full.log"), fixed = TRUE, value = TRUE)
      message("  full.log states: ", paste(logStatus, collapse = ", "))
      if (! all("*** Status: Normal completion" == logStatus)) stoprun <- TRUE
    }
  }

  if (identical(cfg$gms$optimization, "nash") && file.exists("full.lst") && cfg$action == "ce") {
    message("\nInfeasibilities extracted from full.lst with nashstat -F:")
    command <- paste(
      "li=$(nashstat -F | wc -l); cat",   # li-1 = #infes
      "<(if (($li < 2)); then echo no infeasibilities found; fi)",
      "<(if (($li > 1)); then nashstat -F | head -n 2 | sed -r 's/\\x1B\\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g'; fi)",
      "<(if (($li > 4)); then echo ... $(($li - 3)) infeasibilities omitted, show all with 'nashstat -a' ...; fi)",
      "<(if (($li > 2)); then nashstat -F | tail -n 1 | sed -r 's/\\x1B\\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g'; fi)",
      "<(if (($li > 3)); then echo If infeasibilities appear some iterations before GAMS failed, check 'nashstat -a' carefully.; fi)",
      "<(if (($li > 3)); then echo The error that stopped GAMS is probably not the actual reason to fail.; fi)")
    nashstatres <- try(system2("/bin/bash", args = c("-c", shQuote(command))))
    if (nashstatres != 0) message("nashstat not found, search for p80_repy in full.lst yourself.")
  }
  message("")

  message("\nCollect and submit run statistics to central data base.")
  lucode2::runstatistics(file       = "runstatistics.rda",
                         modelstat  = modelstat,
                         config     = cfg,
                         runtime    = gams_runtime,
                         setup_info = lucode2::setup_info(),
                         submit     = cfg$runstatistics)

  if (stoprun) {
    stop("GAMS did not complete its run, so stopping here:\n       No output is generated, no subsequent runs are started.\n",
         "       See the debugging tutorial at https://github.com/remindmodel/remind/blob/develop/tutorials/10_DebuggingREMIND.md")
  }

  # Compress files with the fixing-information
  if (cfg$gms$cm_startyear > 2005)
    system("gzip -f levs.gms margs.gms fixings.gms")

  # go up to the main folder, where the cfg files for subsequent runs are stored and the output scripts are executed from
  setwd(cfg$remind_folder)
  on.exit(setwd(cfg$results_folder))

  #====================== Subsequent runs ===========================

  # Use the name to check whether it is a coupled run (TRUE if the name ends with "-rem-xx")
  coupled_run <- grepl("-rem-[0-9]{1,2}$",cfg$title)
  # Don't start subsequent runs form here if REMIND runs coupled. They are started in start_coupled.R instead.
  start_subsequent_runs <- (start_subsequent_runs | isTRUE(cfg$restart_subsequent_runs)) & !coupled_run

  if (start_subsequent_runs & (length(rownames(cfg$RunsUsingTHISgdxAsInput)) > 0)) {
    # track whether any subsequent run was actually started
    started_any_subsequent_run <- FALSE

    # Save the current cfg settings into a different data object, so that they are not overwritten
    cfg_main <- cfg

    # fulldatapath may be written into gdx paths of subsequent runs
    fulldatapath <- paste0(cfg_main$remind_folder,"/",cfg_main$results_folder,"/fulldata.gdx")
    possible_pathes_to_gdx <- c("input.gdx", "input_ref.gdx", "input_refpolicycost.gdx", "input_bau.gdx", "input_carbonprice.gdx")

    # Loop possible subsequent runs, saving path to fulldata.gdx of current run (== cfg_main$title) to their cfg files

    for (run in rownames(cfg_main$RunsUsingTHISgdxAsInput)) {
      message("\nPrepare subsequent run ", run, ":")
      RData_file <- paste0(run,".RData")
      load(RData_file)

      pathes_to_gdx <- intersect(possible_pathes_to_gdx, names(cfg$files2export$start))

      gdx_na <- is.na(cfg$files2export$start[pathes_to_gdx])
      needfulldatagdx <- names(cfg$files2export$start[pathes_to_gdx][cfg$files2export$start[pathes_to_gdx] == cfg_main$title & !gdx_na])
      message("In ", RData_file, ", use current fulldata.gdx path for ", paste(needfulldatagdx, collapse = ", "), ".")
      cfg$files2export$start[needfulldatagdx] <- fulldatapath

      save(cfg, file = RData_file)

      # Subsequent runs will be started using submit.R, if all necessary gdx files were generated
      gdx_exist <- grepl(".gdx", cfg$files2export$start[pathes_to_gdx])

      if (all(gdx_exist | gdx_na)) {
        message("Starting subsequent run ",run)
        source("scripts/start/submit.R")
        submit(cfg)
        started_any_subsequent_run <- TRUE
      } else {
        message(run, " is still waiting for: ",
        paste(unique(cfg$files2export$start[pathes_to_gdx][!(gdx_exist | gdx_na)]), collapse = ", "), ".")
      }
    } # end of loop through possible subsequent runs

    # Set cfg back to original
    cfg <- cfg_main

    # Create script file that can be used later to restart the subsequent runs manually.
    # In case there are no subsequent runs (or it's coupled runs), the file contains only
    # a small message.

    subseq_start_file  <- paste0(cfg$results_folder,"/start_subsequentruns_manually.R")

    if(!any(cfg$RunsUsingTHISgdxAsInput == cfg$title)) {
      write("cat('\nNo subsequent run was set for this scenario\n')", file=subseq_start_file)
    } else {
      #  go up to the main folder, where the cfg. files for subsequent runs are stored
      filetext <- paste0("setwd('",cfg$remind_folder,"')\n")
      filetext <- paste0(filetext,"source('scripts/start/submit.R')\n")
      for (run in rownames(cfg$RunsUsingTHISgdxAsInput)) {
        filetext <- paste0(filetext,"\n")
        filetext <- paste0(filetext,"load('",run,".RData')\n")
        #filetext <- paste0(filetext,"cfg$results_folder <- 'output/:title::date:'\n")
        filetext <- paste0(filetext,"cat('",run,"')\n")
        filetext <- paste0(filetext,"submit(cfg)\n")
      }
      # Write the text to the file
      write(filetext, file=subseq_start_file)
    }
  } else {
    message("\nDid not try to start subsequent runs.\n")
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

  # make sure the renv used for the run is also used for generating output
  if (!is.null(renv::project())) {
    stopifnot(`loaded renv and outputdir must be equal` = normalizePath(renv::project()) == normalizePath(outputdir))
    argv <- c(get0("argv"), paste0("--renv=", renv::project()))
  }

  sys.source("output.R",envir=new.env())
  # get runtime for output
  timeOutputEnd <- Sys.time()

  # Save run statistics to local file
  cat("\nSaving timeGAMSStart, timeGAMSEnd, timeOutputStart and timeOutputStart to runstatistics.rda\n")
  lucode2::runstatistics(file           = paste0(cfg$results_folder, "/runstatistics.rda"),
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

# Call prepare() and run() without cfg, because cfg is read from results folder, where it has been
# copied to by submit(cfg)

if (!file.exists("full.gms")) {
  # If no "full.gms" exists, the script assumes that REMIND did not run before and
  # prepares all inputs before starting the run.
  prepare()
  start_subsequent_runs <- TRUE
} else {
  # If "full.gms" exists, the script assumes that a full.gms has been generated before and you want
  # to restart REMIND in the same folder using the gdx that it eventually previously produced.
  message("\nRestarting REMIND, find old log in 'log_beforeRestart.txt'.")
  if(file.exists("fulldata.gdx")) file.copy("fulldata.gdx", "input.gdx", overwrite = TRUE)
  start_subsequent_runs <- FALSE
}

# Run REMIND, start subsequent runs (if applicable), and produce output.
run(start_subsequent_runs)
