# |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

library(lucode, quietly = TRUE,warn.conflicts =FALSE)

# Set value source_include so that loaded scripts know, that they are 
# included as source (instead a load from command line)
source_include <- TRUE

# unzip all .gz files
system("gzip -d -f *.gz")

# Load REMIND run configuration
load("config.Rdata")

# Change flag "cm_compile_main" from TRUE to FALSE since we are not compiling 
# main.gms but executing full.gms and therefore want to load some data from the
# input.gdx files.
manipulateFile("full.gms", list(c("\\$setglobal cm_compile_main *TRUE",
                                  "\\$setglobal cm_compile_main FALSE")))

file.copy("full.gms", "full_post.gms", overwrite=TRUE)

# Declare empty list to hold the strings for the 'manipulateFile' function. 
full_post_manipulateThis <- NULL

if(cfg$gms$cm_postproc == 1) {
full_post_manipulateThis <- c(full_post_manipulateThis,
                              list(c("solve hybrid using nlp maximizing vm_welfareGlob;", "$$call 'gdxdump input.gdx Format=gamsbas Delim=comma Output=output_remind.gms';$include \"output_remind.gms\";")))
} else {
full_post_manipulateThis <- c(full_post_manipulateThis,
                              list(c("solve hybrid using nlp maximizing vm_welfareGlob;", "$$call 'gdxdump fulldata.gdx Format=gamsbas Delim=comma Output=output_remind.gms';$include \"output_remind.gms\";")))
}

full_post_manipulateThis <- c(full_post_manipulateThis,
                              list(c("c_skip_output  on    !! def = off", "c_skip_output  off    !! def = off")),
                              list(c("Execute_Unload 'fulldata';","Execute_Unload 'fulldata_post';")))


if(cfg$gms$optimization == "nash") {
  full_post_manipulateThis <- c(full_post_manipulateThis,
                                list(c("file res_capcummo;","$ontext")),
                                list(c("putclose res_capcummo2;","$offtext")),
                                list(c("Repeat","")),
                                list(c("display\\$sleep\\(card\\(p80_handle\\)\\*10\\) 'sleep some time';","")),
                                list(c("until card\\(p80_handle\\) = 0;","")))
}

# Perform actual manipulation on full_post.gms, in single parse of the text.
manipulateFile("full_post.gms", full_post_manipulateThis)

# Store REMIND directory and output file names
maindir <- cfg$remind_folder
REMIND_mif_name <- paste("REMIND_generic_",cfg$title,".mif",sep="")

# Print message
cat("\nStarting REMIND POSTPROCESSING...\n")
# Save start time
begin <- Sys.time()

# Call GAMS
system(paste0(cfg$gamsv, " full_post.gms -errmsg=1 -a=", cfg$action, 
                " -ps=0 -pw=185 -gdxcompress=1 -logoption=", cfg$logoption))

# Calculate run time
gams_runtime <- Sys.time() - begin

# If REMIND actually did run
if (cfg$action == "ce" && cfg$gms$c_skip_output != "on") {

  file.copy("input.gdx","fulldata_post.gdx", overwrite = FALSE)
  
  # Print Message
  cat("\nREMIND POSTPROCESSING finished!\n")
}

# Compress files with the fixing-information
if (cfg$gms$cm_startyear > 2005) 
  system("gzip -f levs.gms margs.gms fixings.gms")

# Return to the REMIND directory
setwd(maindir)

# Reload the REMIND run configuration
load(cfg$val_workspace) 

# Print REMIND runtime
cat("\n gams_runtime is ", gams_runtime, "\n")
# Remove unused variables
rm(gams_runtime, validation)

# Copy important files into output_folder (after REMIND execution)
for (file in cfg$files2export$end)
  file.copy(file, cfg$results_folder, overwrite = TRUE)

#Postprocessing / Output Generation
output    <- cfg$output
outputdir <- cfg$results_folder
sys.source("output.R",envir=new.env())

# Call MAGICC
if (0 == nchar(Sys.getenv('MAGICC_BINARY'))) {
  warning('Can\'t find magicc executable under environment variable MAGICC_BINARY')
} else {
  system(paste("cd ",cfg$results_folder ,"/magicc; ",
               "sed -f modify_MAGCFG_USER_CFG.sed -i MAGCFG_USER.CFG; ",  
               Sys.getenv('MAGICC_BINARY'), '; ',
               "awk -f MAGICC_reporting.awk -v c_expname=\"", cfg$title, "\"",
               " < climate_reporting_template.txt ",
               " > REMIND_climate_", cfg$title, ".csv; ",
               "cat REMIND_climate_", cfg$title, ".csv >> ../", REMIND_mif_name, "; ",
               "cd ../..", sep = ""))
}

