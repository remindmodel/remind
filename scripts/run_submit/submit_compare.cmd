#!/bin/bash
#SBATCH --qos=priority
#SBATCH --job-name=rem-compare
#SBATCH --output=log-%j.out
#SBATCH --mail-type=END
#SBATCH --mem=32000
#SBATCH --cpus-per-task=2

Rscript scripts/utils/compareParallel.R
