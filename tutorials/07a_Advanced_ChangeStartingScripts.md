# The REMIND starting scripts

David Klein (<dklein@pik-potsdam.de>), Lavinia Baumstark (<baumstark@pik-potsdam.de>), Mika Pflüger (<mika.pflueger@pik-potsdam.de>)

## Introduction

Before GAMS can start solving the model, several steps are necessary. The input data needs to be acquired and put into the right places, the model needs to be compiled in the chosen configuration, and the model needs to be started. These preparatory tasks are done in R in the scripts `start.R`, `start_coupled.R`, `start_bundle_coupled.R` in the main folder using functions from the `scripts/start` folder.

## The starting procedure

### Overview

```
start.R -> submit(cfg) -------------------------> prepare_and_run()

           - create output folder                 - fetch input data
           - copy config, prepare_and_run.R       - prepare NDCs
             to output folder                     - create full.gms
           - send slurm job to cluster            - run GAMS
                                                  - reporting

|-----------------------------------------------|--------------------|
                  login node                           slurm job
```

### Detail

```
Rscript start.R
  -> choose_slurmConfig()               [scripts/start/choose_slurmConfig.R]
     configure_cfg(cfg, scenario, ...)  [start.R]
     save cfg to runtitle.RData (in REMIND's mainfolder)
     submit(cfg)                        [scripts/start/submit.R]
       - create output folder
       - copy scripts/start/prepare_and_run.R into results folder
       - save cfg to config.Rdata into results folder
       - change to results folder
       - send job to cluster: sbatch Rscript prepare_and_run.R
            ->  prepare_and_run() [scripts/start/prepare_and_run.R]
                   - load config.Rdata
                   - cd mainfolder
                   - LOCK model
                   - prepare NDC [scripts/input/prepare_NDC.R]
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
```

## Coding etiquette, structuring

Our goal is to move closer to R standard practice, so our vision for the starting scripts is:
* In `scripts/start/`: one file per function (you can have multiple functions in one file, but only the topmost should be used from other files), file name is the same as function name.
* In `tests/testthat/test_*`: unit tests for functions from `scripts/start/`.
* Top-level starting scripts in the main folder: contain only coordination, high-level logic. Functionality is moved into `scripts/start/`

This is a vision, not yet reality. Whenever you work on the starting scripts, try to move in this direction.
