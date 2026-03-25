# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
#######################################################################
############### Select slurm partitiion ###############################
#######################################################################

choose_slurmConfig <- function(identifier = FALSE, flags = NULL) {

  slurm <- suppressWarnings(ifelse(system2("srun",stdout=FALSE,stderr=FALSE) != 127, TRUE, FALSE))
  if (slurm) {
    modes <- c(" 1: SLURM standby               12   nash H12             [recommended]",
               " 2: SLURM standby               13   nash H12 coupled",
               " 3: SLURM standby               16   nash H12+",
               " 4: SLURM standby                1   nash debug, testOneRegi, quick",
               "-----------------------------------------------------------------------",
               " 5: SLURM priority              12   nash H12             [recommended]",
               " 6: SLURM priority              13   nash H12 coupled",
               " 7: SLURM priority              16   nash H12+",
               " 8: SLURM priority               1   nash debug, testOneRegi, quick",
               "-----------------------------------------------------------------------",
               " 9: SLURM short                 12   nash H12",
               "10: SLURM short                 16   nash H12+",
               "11: SLURM short                  1   nash debug, testOneRegi, quick",
               "12: SLURM medium                 1   negishi",
               "13: SLURM long                   1   negishi",
               "-----------------------------------------------------------------------",
               "14: SLURM medium                12   nash - long calibration",
               "15: SLURM medium                16   nash - long calibration",
               "-----------------------------------------------------------------------",
               "16: direct, without SLURM")

    if (! identifier %in% paste(seq(1:16))) {
      wasselect <- TRUE
      if (! Sys.which("sclass") == "") {
        cat("\nCurrent cluster utilization:\n")
        system("sclass")
        cat("\n")
      }
      cat("\nPlease choose the SLURM configuration for your submission:\n")
      cat("    QOS             tasks per node   suitable for\n=======================================================================\n")
      #cat(paste(1:length(modes), modes, sep=": " ),sep="\n")
      cat(modes,sep="\n")
      cat("=======================================================================\n")
      default <- if (any(c("--testOneRegi", "--quick", "--debug") %in% flags)) 8 else 5
      cat(paste0("Type number or press Enter for using ", default, ": "))
      identifier <- strsplit(gms::getLine(), ",")[[1]]
      if (all(identifier == "") && ! is.null(default)) identifier <- default
    }
    comp <- switch(as.integer(identifier),
                    "1" = "--qos=standby --nodes=1 --tasks-per-node=12"  , # SLURM standby  - task per node: 12 (nash H12) [recommended]
                    "2" = "--qos=standby --nodes=1 --tasks-per-node=13"  , # SLURM standby  - task per node: 13 (nash H12 coupled)
                    "3" = "--qos=standby --nodes=1 --tasks-per-node=16"  , # SLURM standby  - task per node: 16 (nash H12+)
                    "4" = "--qos=standby --nodes=1 --tasks-per-node=1 --mem=8000"   , # SLURM standby  - task per node:  1 (nash debug, test one regi)
                    "5" = "--qos=priority --nodes=1 --tasks-per-node=12" , # SLURM priority - task per node: 12 (nash H12) [recommended]
                    "6" = "--qos=priority --nodes=1 --tasks-per-node=13" , # SLURM priority - task per node: 13 (nash H12 coupled)
                    "7" = "--qos=priority --nodes=1 --tasks-per-node=16" , # SLURM priority - task per node: 16 (nash H12+)
                    "8" = "--qos=priority --nodes=1 --tasks-per-node=1 --mem=8000"  , # SLURM priority - task per node:  1 (nash debug, test one regi)
                    "9" = "--qos=short --nodes=1 --tasks-per-node=12"    , # SLURM short    - task per node: 12 (nash H12)
                   "10" = "--qos=short --nodes=1 --tasks-per-node=16"    , # SLURM short    - task per node: 16 (nash H12+)
                   "11" = "--qos=short --nodes=1 --tasks-per-node=1 --mem=8000"     , # SLURM short    - task per node:  1 (nash debug, test one regi)
                   "12" = "--qos=medium --nodes=1 --tasks-per-node=1 --mem=8000"    , # SLURM medium   - task per node:  1 (negishi)
                   "13" = "--qos=long --nodes=1 --tasks-per-node=1 --mem=8000"      , # SLURM long     - task per node:  1 (negishi)
                   "14" = "--qos=medium --nodes=1 --tasks-per-node=12 --time=48:00:00"   , # SLURM medium   - task per node: 12 (nash long calibration)
                   "15" = "--qos=medium --nodes=1 --tasks-per-node=16 --time=48:00:00"   , # SLURM medium   - task per node: 16 (nash long calibration)
                   "16" = "direct")
    if (! exists("wasselect")) {
      message("   SLURM option ", identifier, " selected: ", gsub("--", "", comp))
    }
    if (is.null(comp)) {
      stop("This type is invalid. Please choose a valid type")
    }
  } else {
    comp <- "direct"
  }

  return(comp)
}
