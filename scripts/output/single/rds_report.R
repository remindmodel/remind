# |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

library(magclass)
slurm <- suppressWarnings(ifelse(system2('srun',stdout=FALSE,stderr=FALSE) != 127, TRUE, FALSE))
  if (slurm) { 
    library('remind',lib.loc = '/p/projects/innopaths/reporting_library/lib/')  
  } else {
    library(remind)
  }
library(lucode)
library(quitte)
options("magclass.verbosity" = 1)

############################# BASIC CONFIGURATION #############################
if(!exists("source_include")) {
  outputdir <- "output/r8473-trunk-C_Budg600-rem-5/"
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
  report <- read.report(mif,as.list = FALSE)
} else {
  report <- convGDX2MIF(gdx,gdx_ref,scenario=cfg$title)
}

q <- as.quitte(report)
if(all(is.na(q$value))) stop("No values in reporting!")
saveRDS(q,file=rds)

if(file.exists(runstatistics) & dir.exists(resultsarchive)) {
  stats <- list()
  load(runstatistics)
  if(!is.null(stats$id)) {
    saveRDS(q,file=paste0(resultsarchive,"/",stats$id,".rds"))
    cwd <- getwd()
    setwd(resultsarchive)
    system("ls 1*.rds > files")
    setwd(cwd)
  }
}
