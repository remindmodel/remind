#!/bin/bash

#--- Job Submission parameters ------
#SBATCH --qos=medium
#SBATCH --job-name=__JOB_NAME__
#SBATCH --output=log.txt
#SBATCH --tasks-per-node=2
#SBATCH --mail-type=END
#------------------------------------------------

# report git revision info and changes in the files
git rev-parse --short HEAD
git status

# start gams job
Rscript submit.R
