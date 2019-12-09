# |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
#! /usr/bin/Rscript

##########################################################
#### Script to start a REMIND run ####
##########################################################

library(lucode, quietly = TRUE, warn.conflicts = FALSE)
library(magclass, quietly = TRUE, warn.conflicts = FALSE)

#Here the function start_run(cfg) is loaded which is needed to start REMIND runs
#The function needs information about the configuration of the run. This can be either supplied as a list of settings or as a file name of a config file
source("scripts/start_functions.R")

if (file.exists("./output/testOneRegi/"))
    unlink("./output/testOneRegi/", recursive = TRUE)

#Load config-file
cfg_REMIND <- "oneRegi.cfg"
readArgs("cfg")

# start REMIND run
start_run(cfg_REMIND)
#rep = read.report("coupling.mif")
#start_reportrun(rep)
