# |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

if (!exists("source_include")) {
  load("config.Rdata")
}

# This system call
# - changes into the MAGICC directory
# - modifies the user configuration file
# - ensures that MAGICC is executable
# - kicks out the GAMS directory of the path for dynamically linked libraries
# - calls MAGICC
# - calls AWK to process the output
# - changes back to the old directory
if (0 == nchar(Sys.getenv('MAGICC_BINARY'))) {
  warning('Can\'t find magicc executable under environment variable MAGICC_BINARY')
} else {
  system(paste("cd ./magicc/; ",
             "sed -f modify_MAGCFG_USER_CFG.sed -i MAGCFG_USER.CFG; ",
             "LD_LIBRARY_PATH=$( echo $LD_LIBRARY_PATH | sed 's|/iplex/01/sys/applications[^:]*:||g' ); ", 
             Sys.getenv('MAGICC_BINARY'), '; ',
#             "awk -f MAGICC_reporting.awk -v c_expname=\"", cfg$title, "\"", 
#             " < climate_reporting_template.txt",
#             " > REMIND_climate_", cfg$title, ".csv; ",
             "cd ../", sep = ""))
}

