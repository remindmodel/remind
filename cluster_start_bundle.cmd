#!/bin/bash
#SBATCH --qos=short
#SBATCH --job-name=start_bundle
#SBATCH --output=log.txt
#SBATCH --mail-type=END

Rscript start_bundle.R
