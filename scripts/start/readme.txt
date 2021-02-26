# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
Documentation of the new procedure of starting REMIND runs (DK, LB, January 2020)

Why did we redesign the procedure?

The old code was spread across many files, the user needed to edit files in order to provide the SLURM options, and a substantial part of the code was run on the login node before finally submiting the job to SLURM. The new structure lets the user choose the SLURM options interactively when starting the runs. The amount of code that is executed on the login node was minimized. Most of the work load that is required to set up a run is included in the SLURM batch job. Finally, the code is strucutred more clearly and spread across less files.

To start a run type in the main directory of REMIND:

Rscript start.R [path to a config file]

optionally providing a path to a config file, e.g. config/scenario_config.csv. If no config file is provided REMIND will use the settings in the default.cfg

The procedure in short:

start.R -------> submit(cfg) ----------------------------------------------> prepare_and_run()

                 - create output folder                                      - fetch input data
                 - copy config and prepare_and_run.R into output folder      - prepare NDCs
                 - send slurm job to cluster                                 - create single GAMS file
                                                                             - run GAMS
                                                                             - reporting
|---------------------------------------------------------------------------|--------------------------|
                          login node                                                 slurm job


The procedure in detail:

Rscript start.R -----> choose_slurmConfig()               [scripts/start/choose_slurmConfig.R] 
                       configure_cfg(cfg, scenario, ...)  [start.R]                            
                       save cfg to runtitlte.RData (in REMIND's mainfolder)                                                                  
                       submit(cfg)                        [scripts/start/submit.R]               
                        - create output folder                                                                     
                        - copy scripts/start/prepare_and_run.R into results folder                                                                     
                        - save cfg to config.RData into results folder                                                                     
                        - change to results folder                                                                       
                        - send job to cluster: sbatch Rscript prepare_and_run.R ----->  prepare_and_run() [scripts/start/prepare_and_run.R]                                                                    
                        - change to main folder                                          - load config.RData
                                                                                         - cd mainfolder
                                                                                         - LOCK model
                                                                                         - prepare NDC [scripts/input/prepareNDC2018.R]
                                                                                         - prepare calibration
                                                                                         - if coupled get MAgPIE data
                                                                                         - download and distribute input data
                                                                                         - put together single GAMS file
                                                                                         - UNLOCK
                                                                                         - cd resultsfolder
                                                                                         - create fixings
                                                                                         - call GAMS full.gms
                                                                                         - submit runstatistics
                                                                                         - cd mainfolder
                                                                                         - start subsequent runs submit(cfg) [scripts/start/submit.R]
                                                                                         - reporting [output.R]
                                                                                         - cd resultsfolder
                    
                    


