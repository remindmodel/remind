# %%
import os
import os.path
import sys

import pandas as pd
import pandas.testing as pdt
import tempfile

import climate_assessment
from climate_assessment.cli import run_workflow
import pyam

# %%
# User setup

excel_file = sys.argv[1]
# mif_file = "REMIND_gabrielAR6SHAPE_2023-05-17_05.12.52.mif"

# Base folder containing the MAGICC binary and parameter sets
os.environ["MAGICC_ROOT_FILES_DIR"] = "/p/projects/rd3mod/climate-assessment-files/"

# How many MAGICC workers can run in parallel?
os.environ["MAGICC_WORKER_NUMBER"] = "12"

# Where should the MAGICC workers be located on the filesystem (you need about
# 500Mb space per worker at the moment, they're removed after use)
os.environ["MAGICC_WORKER_ROOT_DIR"] = tempfile.gettempdir()


# %%
# Derived setup
# Where is the binary
os.environ["MAGICC_EXECUTABLE_7"] = os.path.join(
    os.environ["MAGICC_ROOT_FILES_DIR"], "magicc-v7.5.3", "bin", "magicc"
)
infilling_database_file = os.path.join(
    os.environ["MAGICC_ROOT_FILES_DIR"],"1652361598937-ar6_emissions_vetted_infillerdatabase_10.5281-zenodo.6390768.csv"
)
infilling_database_file

# %%
model = "magicc"
model_version = "v7.5.3"
probabilistic_file = os.path.join(
    os.environ["MAGICC_ROOT_FILES_DIR"],"magicc-ar6-0fd0f62-f023edb-drawnset/0fd0f62-derived-metrics-id-f023edb-drawnset.json"
)

# Use fewer (e.g. 10) if you just want to do a test run but note that this breaks
# the stats of the probabilistic ensemble
num_cfgs = 600
# num_cfgs = 10
# Set to True if you're not using the full MAGICC ensemble
test_run = False
# test_run = True
# How many scenarios do you want to run in one go?
# Usually better to use more MAGICC workers. 
# scenario_batch_size = 20
scenario_batch_size = 1

# Where should the output be saved? Create if it doesn't exist
outdir = os.path.join("output_climate")
if not(os.path.exists(outdir) and os.path.isdir(outdir)):
    os.makedirs(outdir)

outdir

#%%
print("Reading "+ excel_file)
print("Keep in mind that the initial read of the Excel time can take up to minutes, so dont expect any output for a while")
inxls = pyam.IamDataFrame(excel_file)

#%%
csv_file = os.path.splitext(excel_file)[0] + ".csv"
print("Filtering regions and writing to " + csv_file)
inxls.filter(region="World").to_csv(csv_file)
#%%
# %%
# FIXME: This is commented, but is needed if we use mifs
# instead of xls files. The definitive solution will definitely
# use mifs, as reading xls in pandas is way too slow for use every iteration. 
# # Get the mif file with the proper format for pyam to read it
# inmif = pd.read_csv(mif_file, delimiter=";")
# inmif = inmif.query('Region == "World"')
# # inmif["Model"] = "REMIND-MAgPIE"

# if 'Unnamed' in inmif.columns[len(inmif.columns)-1]:
#     inmif = inmif.iloc[:,:-1]

# # inmif = inmif[inmif["Scenario"].isin(usescens)]

# csv_file = os.path.splitext(mif_file)[0] + ".csv"

# inmif.to_csv(csv_file, index = False)

# # Check if pyam will read the file
# testread = pyam.IamDataFrame(csv_file)
# testread

# %%
print("Starting workflow using "+ excel_file)
run_workflow(
    csv_file,
    outdir,
    model=model,
    model_version=model_version,
    probabilistic_file=probabilistic_file,
    num_cfgs=num_cfgs,
    infilling_database=infilling_database_file,
    scenario_batch_size=scenario_batch_size,
)

