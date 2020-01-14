# |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

library(lucode, quietly = TRUE,warn.conflicts =FALSE)
library(dplyr, quietly = TRUE,warn.conflicts =FALSE)
require(gdx)



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





# Set value source_include so that loaded scripts know, that they are 
# included as source (instead a load from command line)
source_include <- TRUE

# unzip all .gz files
system("gzip -d -f *.gz")

# Load REMIND run configuration
load("config.Rdata")


#AJS set MAGCFG file
magcfgFile = paste0('./magicc/MAGCFG_STORE/','MAGCFG_USER_',toupper(cfg$gms$cm_magicc_config),'.CFG')
if(!file.exists(magcfgFile)){
    stop(paste('ERROR in MAGGICC configuration: Could not find file ',magcfgFile))
}
system(paste0('cp ',magcfgFile,' ','./magicc/MAGCFG_USER.CFG'))

# Change flag "cm_compile_main" from TRUE to FALSE since we are not compiling 
# main.gms but executing full.gms and therefore want to load some data from the
# input.gdx files.
manipulateFile("full.gms", list(c("\\$setglobal cm_compile_main *TRUE",
                                  "\\$setglobal cm_compile_main FALSE")))

# Prepare the files containing the fixings for delay scenarios (for fixed runs)
if (  cfg$gms$cm_startyear > 2005  & (!file.exists("levs.gms.gz") | !file.exists("levs.gms"))) {
  create_fixing_files(cfg = cfg, input_ref_file = "input_ref.gdx")
}

 
# Store REMIND directory and output file names
maindir <- cfg$remind_folder
REMIND_mif_name <- paste("REMIND_generic_", cfg$title, ".mif", sep = "")

# Print message
cat("\nStarting REMIND...\n")

# Save start time
begin <- Sys.time()

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

# Calculate run time
gams_runtime <- Sys.time() - begin

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

# go up to the main folder, where the cfg files for subsequent runs are stored
setwd(cfg$remind_folder)

#====================== Subsequent runs ===========================

# 1. Save the path to the fulldata.gdx of the current run to the cfg files 
# of the runs that use it as 'input_bau.gdx'

# Use the name to check whether it is a coupled run (TRUE if the name ends with "-rem-xx")
coupled_run <- grepl("-rem-[0-9]{1,2}$",cfg$title)

no_ref_runs <- identical(cfg$RunsUsingTHISgdxAsBAU,character(0)) | all(is.na(cfg$RunsUsingTHISgdxAsBAU)) | coupled_run

if(!no_ref_runs) {
  source("scripts/start_functions.R")
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
  source("scripts/start_functions.R")
  
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
    start_run(cfg)
  }
  # Set cfg back to original
  cfg <- cfg_main
}

# 3. Create script file that can be used later to restart the subsequent runs manually.
# In case there are no subsequent runs (or it's coupled runs), the file contains only 
# a small message.

subseq_start_file  <- paste0(cfg$results_folder,"/start_subsequentruns.R")

if(no_subsequent_runs){
  write("cat('\nNo subsequent run was set for this scenario\n')",file=subseq_start_file)
} else {
  #  go up to the main folder, where the cfg. files for subsequent runs are stored
  filetext <- paste0("setwd('",cfg$remind_folder,"')\n")
  filetext <- paste0(filetext,"source('scripts/start_functions.R')\n")
  for(run in seq(1,length(cfg$subsequentruns))){
    filetext <- paste0(filetext,"\n")
    filetext <- paste0(filetext,"load('",cfg$subsequentruns[run],".RData')\n")
    filetext <- paste0(filetext,"cat('",cfg$subsequentruns[run],"')\n")
    filetext <- paste0(filetext,"start_run(cfg)\n")
  }
  # Write the text to the file
  write(filetext,file=subseq_start_file)
}

#=================== END - Subsequent runs ========================
  
# Print REMIND runtime
cat("\n gams_runtime is ", gams_runtime, "\n")

# Copy important files into output_folder (after REMIND execution)
for (file in cfg$files2export$end)
  file.copy(file, cfg$results_folder, overwrite = TRUE)

# Postprocessing / Output Generation
output    <- cfg$output
outputdir <- cfg$results_folder
sys.source("output.R",envir=new.env())

