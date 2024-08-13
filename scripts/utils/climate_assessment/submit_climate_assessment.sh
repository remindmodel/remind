#!/bin/bash
#SBATCH --qos=priority
#SBATCH --time=06:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=12
#SBATCH --mem=60000
#SBATCH --job-name=test_remind_2
#SBATCH --output=PYTHONLOG-%x.%j.out
# Replace this with the resulting xls of output.R -> export -> xlsx_IIASA -> AR6
filename="../../../output/export/REMIND_gabrielAR6SHAPE_2023-05-17_05.12.52.xlsx"
python source_climate_assessment.py $filename
