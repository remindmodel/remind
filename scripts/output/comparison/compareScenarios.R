# |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
# ---- Define set of runs that will be compared ----

if (exists("outputdirs")) {
  # This is the case if this script was called via Rscript output.R
  listofruns <- list(
  list(period = "both",  set = format(Sys.time(), "%Y-%m-%d_%H.%M.%S"),  dirs = outputdirs),  
  NULL)

} else {
  # This is the case if this script was called directly via Rscript
  listofruns <- list( 
      #list(period = "both",  set = "cpl-Base",       dirs = c("coupled-remind_SDP-Base-rem-5",       "coupled-remind_SSP1-Base-rem-5",       "coupled-remind_SSP2-Base-rem-5",       "coupled-remind_SSP5-Base-rem-5")),
      #list(period = "both",  set = "cpl-PkBudg900",  dirs = c("coupled-remind_SDP-PkBudg900-rem-5",  "coupled-remind_SSP1-PkBudg900-rem-5",  "coupled-remind_SSP2-PkBudg900-rem-5",  "coupled-remind_SSP5-PkBudg900-rem-5")),
      #list(period = "both",  set = "cpl-PkBudg1100", dirs = c("coupled-remind_SDP-PkBudg1100-rem-5", "coupled-remind_SSP1-PkBudg1100-rem-5", "coupled-remind_SSP2-PkBudg1100-rem-5", "coupled-remind_SSP5-PkBudg1100-rem-5")),
      #list(period = "both",  set = "cpl-PkBudg1300", dirs = c("coupled-remind_SDP-PkBudg1300-rem-3", "coupled-remind_SSP1-PkBudg1300-rem-5", "coupled-remind_SSP2-PkBudg1300-rem-5", "coupled-remind_SSP5-PkBudg1300-rem-5")),
      
      #list(period = "both",  set = "cpl-SDP",  dirs = c("coupled-remind_SDP-Base-rem-5",  "coupled-remind_SDP-PkBudg1300-rem-3",  "coupled-remind_SDP-PkBudg1100-rem-5",  "coupled-remind_SDP-PkBudg900-rem-5")),
      list(period = "both",  set = "cpl-SDP-1100",  dirs = c("coupled-remind_SDP-Base-rem-5",  "coupled-remind_SDP-PkBudg1300-rem-3",  "coupled-remind_SDP-PkBudg1100-rem-5",  "coupled-remind_SDP-PkBudg1000-rem-5")),
      #list(period = "both",  set = "cpl-SSP1", dirs = c("coupled-remind_SSP1-Base-rem-5", "coupled-remind_SSP1-PkBudg1300-rem-5", "coupled-remind_SSP1-PkBudg1100-rem-5", "coupled-remind_SSP1-PkBudg900-rem-5")),
      #list(period = "both",  set = "cpl-SSP2", dirs = c("coupled-remind_SSP2-Base-rem-5", "coupled-remind_SSP2-PkBudg1300-rem-5", "coupled-remind_SSP2-PkBudg1100-rem-5", "coupled-remind_SSP2-PkBudg900-rem-5", "coupled-remind_SSP2-NDC-rem-5")),
      #list(period = "both",  set = "cpl-SSP5", dirs = c("coupled-remind_SSP5-Base-rem-5", "coupled-remind_SSP5-PkBudg1300-rem-5", "coupled-remind_SSP5-PkBudg1100-rem-5", "coupled-remind_SSP5-PkBudg900-rem-5")),
      
      #list(period = "both",  set = "cpl-aff",  dirs = c("coupled-remind_SDP-PkBudg1000-rem-5", "coupled-remind_SDP-PkBudg1000-affInf-rem-5","coupled-remind_SDP-PkBudg1000-aff900-rem-3","coupled-remind_SDP-PkBudg1000-aff760-rem-5","coupled-remind_SDP-PkBudg1000-cost3-rem-5","coupled-remind_SDP-PkBudg1000-cost2-rem-5")),
      #list(period = "both",  set = "cplstd-SDP",  dirs = c("coupled-remind_SDP-Base-rem-5", "SDP-Base_2019-10-23_10.40.27/")), # "coupled-remind_SDP-PkBudg1300-rem-5", "coupled-remind_SDP-PkBudg1100-rem-5", "coupled-remind_SDP-PkBudg900-rem-5", , "SDP-PkBudg1300_2019-10-23_13.54.55/", "SDP-PkBudg1100_2019-10-23_13.52.02/", "SDP-PkBudg900_2019-10-23_13.49.07/"
      #list(period = "both",  set = "cplstd-SSP1", dirs = c("coupled-remind_SSP1-Base-rem-5", "coupled-remind_SSP1-PkBudg1300-rem-5", "coupled-remind_SSP1-PkBudg1100-rem-5", "coupled-remind_SSP1-PkBudg900-rem-5", "SSP1-Base_2019-10-23_10.36.05/", "SSP1-PkBudg1300_2019-10-23_13.42.42/", "SSP1-PkBudg1100_2019-10-23_13.40.05/", "SSP1-PkBudg900_2019-10-23_13.37.18/")),
      #list(period = "both",  set = "cplstd-SSP2", dirs = c("coupled-remind_SSP2-Base-rem-5", "coupled-remind_SSP2-NDC-rem-5", "coupled-remind_SSP2-PkBudg1300-rem-5", "coupled-remind_SSP2-PkBudg900-rem-5", "SSP2-Base_2019-10-23_10.44.15/", "SSP2-NDC_2019-10-23_11.57.53/", "SSP2-PkBudg1300_2019-10-23_14.03.57/", "SSP2-PkBudg900_2019-10-23_13.58.02/")), # , "coupled-remind_SSP2-PkBudg1100-rem-5" "SSP2-PkBudg1100_2019-10-23_14.01.04/", 
      #list(period = "both",  set = "cplstd-SSP5", dirs = c("coupled-remind_SSP5-Base-rem-5", "SSP5-Base_2019-10-23_10.47.50/")), # , "coupled-remind_SSP5-PkBudg1300-rem-5", "coupled-remind_SSP5-PkBudg1100-rem-5", "coupled-remind_SSP5-PkBudg900-rem-5" , "SSP5-PkBudg1300_2019-10-23_14.16.09/", "SSP5-PkBudg1100_2019-10-23_14.13.22/", "SSP5-PkBudg900_2019-10-23_14.10.35/"
      NULL)
}

# remove the NULL element
listofruns <- listofruns[!sapply(listofruns, is.null)]

# if no path in "dirs" starts with "output/" insert it at the beginning
# this is the case if listofruns was created in the lower case above !exists("outputdirs"), i.e. if this script was not called via Rscript output.R
for (i in 1:length(listofruns)) {
  if(!any(grepl("output/",listofruns[[i]]$dirs))) {
    listofruns[[i]]$dirs <- paste0("output/",listofruns[[i]]$dirs)
  }
}

# ---- Start compareScenarios either on the cluster or locally ----

start_comp <- function(outputdirs,shortTerm,outfilename) {
  jobname <- paste0("compScen",ifelse(outfilename=="","","-"),outfilename,ifelse(shortTerm, "-shortTerm", ""))
  cat("Starting ",jobname,"\n")
  on_cluster <- file.exists("/p/projects/")
  if (on_cluster) {
    clcom <- paste0("sbatch --qos=standby --job-name=",jobname," --output=",jobname,".out --error=",jobname,".err --mail-type=END --time=200 --mem-per-cpu=8000 --wrap=\"Rscript scripts/utils/run_compareScenarios.R outputdirs=",paste(outputdirs,collapse=",")," shortTerm=",shortTerm," outfilename=",jobname,"\"")
    system(clcom)
  } else {
    outfilename    <- jobname
    tmp.env <- new.env()
    script <- "scripts/utils/run_compareScenarios.R"
    tmp.error <- try(sys.source(script,envir=tmp.env))
    if(!is.null(tmp.error)) warning("Script ",script," was stopped by an error and not executed properly!")
    rm(tmp.env)
  }
}

# ---- For each list entry call start script that starts compareScenarios ----

for (r in listofruns) {
  if (r$period == "short" | r$period == "both") start_comp(outputdirs = r$dirs, shortTerm = TRUE,  outfilename = r$set)
  if (r$period == "long"  | r$period == "both") start_comp(outputdirs = r$dirs, shortTerm = FALSE, outfilename = r$set)
}
