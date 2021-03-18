# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
############################# LOAD LIBRARIES #############################
library(magclass, quietly = TRUE,warn.conflicts =FALSE)
library(gms, quietly = TRUE,warn.conflicts =FALSE)
library(lucode2, quietly = TRUE,warn.conflicts =FALSE)
library(magpie, quietly = TRUE,warn.conflicts =FALSE)

if(!exists("source_include")) {
 outputdirs <- c("output/default_2015-01-14_11.41.17",
                 "output/default_2015-01-14_12.28.56",
                 "output/default_2015-01-14_15.00.13",
                 "output/default_2015-01-14_15.36.12");
 readArgs("outputdirs")
} 

print(readRuntime(outputdirs,plot=TRUE))
