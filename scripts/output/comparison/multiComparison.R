# |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
## require(remind)
require(parallel)
## load local reporting
## require(devtools)
## load_all("~/git/remind-lib")
require(remind)
require(data.table)

compareScenTable <- function(listofruns){

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

  scendt[coupled == T, scenario := paste0("remind-coupled_", scenario)]

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
    mif <- file.path(choice, paste0("REMIND_generic_", sc, "-", budg, ".mif"))
    return(mif)
  }

  unique_scens[, mif := mapply(select_mif, scenario, policy)]

  scendt <- unique_scens[scendt, on=.(policy, scenario)]

  ## delete lines where no MIF was found
  scendt <- scendt[!is.na(mif)]

  fwrite(scendt, file="multi_comparison.csv")

  if(system("hash sbatch 2>/dev/null") == 0){
    cat("Submitting comparison Jobs:\n")
     system(paste0("sbatch --job-name=rem-compare --output=log-%j.out --mail-type=END --cpus-per-task=2 --qos=priority --wrap=\"Rscript scripts/utils/compareParallel.R \""))
  }else{
    source("scripts/utils/compareParallel.R")
  }
}

compareScenTable(outputdirs)
