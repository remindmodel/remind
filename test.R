#!/usr/bin/env Rscript
# |  (C) 2022 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

main <- function() {
  arguments <- parseCommandLine()

  testStartQuick()
}

parseCommandLine <- function() {
  p <- argparser::arg_parser("Run tests to check if REMIND is working properly.")

  return(argparser::parse_args(p))
}

testStartQuick <- function() {

  # desired behaviour:
  # * if slurm not available, run directly
  # * if slurm is available, run with 8 --time=60 --wait
  # easiest update: make sure whatever slurmConfig is, as long as slurm is not available, it is not used.
  # *Q: why is results_folder not usable from scenario_config??
  system2("Rscript", c("start.R", "config/scenario_config_quick.csv"))
}

main()
