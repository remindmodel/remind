#!/bin/bash

#--- Job Submission parameters ------
#SBATCH --qos=short
#SBATCH --job-name=REMIND-PostProcessing
#SBATCH --output=log.txt
#SBATCH --mail-type=END
#------------------------------------------------

# start gams job
Rscript submit_postp.R
