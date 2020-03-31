# |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

require(parallel)
## load local reporting
## require(devtools)
## load_all("~/git/remind-lib")
require(remind)
require(data.table)

#' Run a multi-dimensional parallel compareScenario computation.
#'
#' From the list of runs given by the `output.R` infrastructure,
#' select and align runs according to a matrix defined in the SDP/SSP
#' and mitigation scenario space, given in
#' `config/multi_comparison_matrix.csv`.
#'
#' The columns in `config/multi_comparison_matrix.csv` denote:
#'
#' policy: the mitigation policy in place
#' scenario: the scenario in the SSP/SDP dimension
#' short: the run should run only on a time range up to 2060
#' coupled: A prefix has to be added to correctly identify scenarios
#'   in coupled runs
#'
#' The list of runs is compiled by this script and
#' stored in `multi_comparison.csv` in the root folder.
#'
#' The columns in `multi_comparison.csv` denote:
#' policy: the mitigation policy in place
#' scenario: the scenario in the SSP/SDP dimension
#' mif: the output file corresponding to the two dimensions
#' comparison_id: id to label comparison runs, i.e., runs with the
#'   same IDs are compared
#' coupled: A prefix has to be added to correctly identify scenarios
#'   in coupled runs
#' short: the run should run only on a time range up to 2060
#'
#' Eventually, `scripts/utils/compareParallel.R` reads the file
#' `multi_comparison.csv` and executes `compareScenarios` locally or on the cluster
#' (depending on the presence of the `sbatch` slurm utils).
#'
#' The number of cores to be used in parallel on the cluster is
#' determined by the variable CORES at the top of the function body.
#'
#' The prefix for coupled runs is also defined at the top (COUPLED_PREFIX).
#'
#' The scenarioComparison plots are stored in the subfolder
#' OUTPUT_FOLDER.
#'
#' @param listofruns a list of output folders, as given by the
#'     `output.R` infrastructure


compareScenTable <- function(listofruns){
  CORES = 12
  COUPLED_PREFIX = "C_"
  OUTPUT_FOLDER = "multi_comparison_plots"

  scendt <- fread("config/multi_comparison_matrix.csv")
  scendt[
  , policy := strsplit(policy, "|", fixed=T)][
  , scenario := strsplit(scenario, "|", fixed=T)][
  , short := ifelse(short == "T", T, F)][
  , coupled := ifelse(!is.na(coupled) && coupled == "T", T, F)][
  , comparison_id := .I]

  scendt <- scendt[, .(policy=unlist(policy),
                       scenario=unlist(scenario),
                       coupled, short), by=comparison_id]

  scendt[coupled == T, scenario := paste0(COUPLED_PREFIX, scenario)]

  unique_scens <- unique(scendt[, .(policy, scenario)])

  select_mif <- function(sc, budg){
    fls <- grep(paste0(sc, "-", budg), listofruns, value = T)
    if(length(fls) > 1){

      cat(sprintf("Found more than one file with scenario %s and budget %s \n\n", sc, budg))

      cat(paste0(1:length(fls), ": ", fls, "\n"))

      def_choice <- fls[length(fls)]
      cat(sprintf("Select the correct output directory (%s): ", def_choice))
      n <- as.integer(get_line())
      if(is.na(n))
        choice <- def_choice
      else
        choice <- fls[n]
    }else if(length(fls) == 1){
      choice <- fls[1]
    }else{
      warning(sprintf("No output found for scenario %s and budget %s", sc, budg))
      return(NA)
    }
    mif <- file.path(choice, paste0("REMIND_generic_", basename(choice), ".mif"))
    return(mif)
  }

  unique_scens[, mif := mapply(select_mif, scenario, policy)]

  scendt <- unique_scens[scendt, on=.(policy, scenario)]

  ## delete lines where no MIF was found
  scendt <- scendt[!is.na(mif)]

  fwrite(scendt, file="multi_comparison.csv")

  if(system("hash sbatch 2>/dev/null") == 0){
    cat("Submitting comparison Jobs:\n")
    system(sprintf("sbatch --job-name=rem-compare --output=log-%%j.out --mail-type=END --cpus-per-task=%i --qos=priority --wrap=\"Rscript scripts/utils/compareParallel.R %s\"",
    CORES, OUTPUT_FOLDER))
  }else{
    source("scripts/utils/compareParallel.R")
  }
}

compareScenTable(outputdirs)
