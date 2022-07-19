# |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

library(tidyverse)
library(remind2)
library(gridExtra)
library(quitte)
require(lucode2)
require(gms)
require(colorspace)
require(gdx)
require(grid)



if(!exists("source_include")) {
  #if this script is not being sourced by another script but called from the command line via Rscript read the command line args
  #Define arguments that can be read from command line
  readArgs("outputdir")
  
  if(!file.exists(file.path(outputdir))){
    stop("specified path \"", outputdir, "\"does not exist!")
  }
  
}

## generate DIETER reporting if it is needed
## the reporting is appended to REMIND_generic_<scenario>.MIF in "DIETER" Sub Directory 
DIETERGDX <- "report_DIETER.gdx"
if(file.exists(file.path(outputdir, DIETERGDX))){
  print("start generation of DIETER reporting")
  remind2::reportDIETER(DIETERGDX,outputdir)
  print("end generation of DIETER reporting")
}else {
  stop("report_DIETER.gdx not found!")
}						   



