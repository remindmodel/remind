# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
require(data.table)
require(parallel)
require(remind2)

args = commandArgs(trailingOnly=TRUE)
if (length(args)==0) {
  plotfldr <- "multi_comparison_plots"
} else {
  plotfldr <- args[1]
}

dir.create(plotfldr, showWarnings = F)

NUM_OF_CPUS_LOCAL <- 2

run_compare <- function(scens, policies, mifs, short){

  RCP_MAP <- list(
    Base="Baseline",
    NPi="Baseline",
    NDC="Baseline",
    PkBudg900="26",
    PkBudg1000="45",
    PkBudg1100="45",
    PkBudg1300="45"
  )

  short <- short[1]
  policies <- unique(policies)
  scens <- unique(scens)

  hist_path <- "core/input/historical/historical.mif"
  short_y <- seq(2005,2060,5)
  short_ybar <- c(2010,2030,2050)

  print(sprintf("[%s] Compare scenarios for scenarios %s and budgets %s, short-term: %s",
                Sys.time(), paste(scens, collapse=","), paste(policies, collapse=","), short))

  fname <- paste0(paste(scens, collapse="-"), "_",
                  paste(policies, collapse="-"), "_",
                  "Comparison",
                  if(short) "_SHORT",
                  "_", Sys.Date())

  ## if(!is.null(version))
  ##   fname <- paste0(version, "_", fname)

  outfolder <- file.path(plotfldr, fname)
  dir.create(outfolder, showWarnings = F)

  outfile <- file.path(outfolder, paste0(fname, ".pdf"))

  rcpscen <- if(length(policies) == 1) RCP_MAP[[policies]]

  if(short){
    compareScenarios(mifs, y=short_y, y_bar=short_ybar, hist = hist_path,
                     fileName = outfile,
                     sr15marker_RCP = rcpscen)
  }else{
    compareScenarios(mifs, hist = hist_path,
                     fileName = outfile,
                     sr15marker_RCP = rcpscen)
  }
  file.copy(outfile, paste0(plotfldr, "/"))
  file.remove(outfolder)
}

table <- fread("multi_comparison.csv", header = T)

CORES <- as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", NUM_OF_CPUS_LOCAL))
cat(sprintf("Using %i CPUs.\n", CORES))

mclapply(1:max(table$comparison_id), function(id){
  args <- table[comparison_id == id]
  run_compare(args$scenario, args$policy, args$mif, args$short)
}, mc.cores=CORES)
# table[, run_compare(scenario, policy, mif, short), by=comparison_id]
