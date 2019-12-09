#!/bin/bash

#--- New Cluster Job Submission parameters ------
#SBATCH --qos=priority
#SBATCH --job-name=start_coupled
#SBATCH --output=log.txt
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --mail-type=END
#------------------------------------------------

Rscript start_coupled.R coupled_config=SSP1_RCP45_nash.RData
