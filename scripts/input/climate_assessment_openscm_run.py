#%%
import argparse
import datetime as dt
import logging
import os

import scmdata
# import pymagicc
import openscm_runner
import scmdata
# import climate_assessment
from climate_assessment.climate.wg3 import clean_wg3_scenarios
import pyam
import pandas as pd
import xarray as xr
# import copy
import json

# TONN REMOVE start
# If these are already set, it shouldn't override it. We actually may not want to have a default but just throw an error if not set
os.environ["MAGICC_EXECUTABLE_7"]       =   "/p/projects/piam/abrahao/scratch/module_climate_tests/climate-assessment-files/magicc-v7.5.3/bin/magicc"
os.environ["MAGICC_WORKER_ROOT_DIR"]    =   "/p/projects/piam/abrahao/scratch/methane/methane_scm/workers"

LOGGER = logging.getLogger(__name__) # We don't need this
# TONN REMOVE end

# %%
# Parsing arguments
parser = argparse.ArgumentParser(
    description='Runs MAGICC for given a harmonized and infilled emissions file created by climate-assessment.'
    )
parser.add_argument('scens_file', type=str, 
                    help='an integer for the accumulator')
parser.add_argument('--climatetempdir', default=os.getcwd(),
                    help='Temporary folder for climate assessment files')
parser.add_argument('--endyear', default=2100,
                    help='Final year for MAGICC runs')
parser.add_argument('--scenario-batch-size', default=1,
                    help='How many scenarios to run in a batch, only makes sense when running more than one')
parser.add_argument('--probabilistic-file', required=True,
                    help='Required, JSON file with the MAGICC parameter sets. Number of sets must match --num-cfgs')
parser.add_argument('--num-cfgs', default=1,
                    help='Number of parameter sets must match --probabilistic-file')


args = parser.parse_args()
print(args)
# print(args.accumulate(args.integers))

# --year-filter-last 2205 --num-cfgs 1 --scenario-batch-size 1 --probabilistic-file /p/projects/piam/abrahao/scratch/remind_tonn/output/SSP2EU-NPi-magicc7_ar6_2024-04-19_15.10.15/probmod.json'
# /p/projects/piam/abrahao/scratch/remind_tonn/output/SSP2EU-NPi-magicc7_ar6_2024-04-19_15.10.15/climate-assessment-data-tirf/allpulses.xlsx /p/projects/piam/abrahao/scratch/remind_tonn/output/SSP2EU-NPi-magicc7_ar6_2024-04-19_15.10.15/climate-assessment-data-tirf --year-filter-last 2205 --num-cfgs 1 --scenario-batch-size 1 --probabilistic-file /p/projects/piam/abrahao/scratch/remind_tonn/output/SSP2EU-NPi-magicc7_ar6_2024-04-19_15.10.15/probmod.json'

# %%
# Setting parameters
# REMOVE 
args = dict()
args["scens_file"] = "/p/projects/piam/abrahao/scratch/remind_tonn/output/SSP2EU-NPi-magicc7_ar6_2024-04-19_15.10.15/climate-assessment-data/ar6_climate_assessment_SSP2EU-NPi-magicc7_ar6_harmonized_infilled.csv"
args["probabilistic_file"] = "/p/projects/rd3mod/climate-assessment-files/parsets/RCP20_50.json"
args["endyear"] = 2205
args["climatetempdir"] = "/p/projects/piam/abrahao/scratch/remind_tonn/output/SSP2EU-NPi-magicc7_ar6_2024-04-19_15.10.15/climate-assessment-data/"
# 

# Harmonized and infilled emissions scenario
basescenfname = args["scens_file"]

# JSON with parameter sets
climate_assessment_magicc_prob_file_iteration = args["probabilistic_file"]

# Final year for MAGICC run
endyear = args["endyear"]

# Output file name, assumed to be inside climatetempdir
# TODO: We don't really use climatetempdir here, 
# so we might want to replace it with a --outfilename 
# argument, with default in the current working directory
outfilename = os.path.join(args["climatetempdir"],"openscm_output.xlsx")

# %% 
# Check arguments

# %%
# Clean the harmonized and infilled scenario, fixing some variable names required
basescen = clean_wg3_scenarios(pyam.IamDataFrame(basescenfname)) # Needs wg3.py from climate_assessment


#%%
# Read parameter sets, can also be multiple
with open(climate_assessment_magicc_prob_file_iteration) as f:
    allparsets = json.load(f)
allparsets = [i["nml_allcfgs"] for i in allparsets["configurations"]]

# Set endyear in all parsets 
for parset in allparsets:
    parset["endyear"] = endyear


# %%
runresults = openscm_runner.run(
    climate_models_cfgs={
        "MAGICC7" : allparsets
    },
    output_variables=(
        "Surface Air Temperature Change",
        "Net Atmosphere to Land Flux|CO2"
    ),
scenarios = scmdata.ScmRun(basescen)
    )

# %%
# Write output

outfilename = "/p/projects/piam/abrahao/scratch/remind_tonn/output/SSP2EU-NPi-magicc7_ar6_2024-04-19_15.10.15/dummy.xlsx"
runresults.filter(region = "World"
                  ).to_iamdataframe(
                      
                  ).swap_time_for_year(
                      
                  ).to_excel(
                      outfilename
                      )

# # # %%
# # # Show basic results
# # runresults.filter(
# #     variable = "Surface Air Temperature Change",
# #     region = "World"
# #     ).lineplot()