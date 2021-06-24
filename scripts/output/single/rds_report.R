# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

library(magclass)
library(remind2)
library(lucode2)
library(gms)
library(quitte)
options("magclass.verbosity" = 1)

############################# BASIC CONFIGURATION #############################
if(!exists("source_include")) {
  outputdir <- "output/default_2021-03-18_18.16.40/"
  readArgs("outputdir")
}

load(paste0(outputdir, "/config.Rdata"))
gdx	     <- path(outputdir,"fulldata.gdx")
gdx_ref  <- path(outputdir,"input_ref.gdx")
if(!file.exists(gdx_ref)) gdx_ref <- NULL
rds <- paste0(outputdir, "/report.rds")
runstatistics <- paste0(outputdir,"/runstatistics.rda")
resultsarchive <- "/p/projects/rd3mod/models/results/remind"
###############################################################################

mif <- path(outputdir,paste0("REMIND_generic_",cfg$title,".mif"))

if(file.exists(mif)) {
  report <- read.quitte(mif)
} else {
  report <- convGDX2MIF(gdx,gdx_ref,scenario=cfg$title)
}

if (!is.quitte(report)) report <- as.quitte(report)
q<-report
if(all(is.na(q$value))) stop("No values in reporting!")
saveRDS(q,file=rds)

if(file.exists(runstatistics) & dir.exists(resultsarchive)) {
  stats <- list()
  load(runstatistics)
  if(is.null(stats$id)) {
    # create an id if it does not exist (which means that statistics have not 
    # been saved to the archive before) and save statistics to the archive
    message("No id found in runstatistics.rda. Calling lucode2::runstatistics() to create one.") 
    stats <- lucode2::runstatistics(file = runstatistics, submit = cfg$runstatistics)
    message("Created the id ",stats$id)
    # save stats locally (including id) otherwise it would generate a new id (and 
    # resubmit the results and the statistics) next time rds_report is executed
    save(stats, file=runstatistics, compress="xz")
  }
  
  # Save report to results archive
  saveRDS(q,file=paste0(resultsarchive,"/",stats$id,".rds"))
  cwd <- getwd()
  setwd(resultsarchive)
  system("ls 1*.rds > files")
  setwd(cwd)
}
