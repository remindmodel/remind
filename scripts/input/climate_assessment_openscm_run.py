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
# from climate_assessment.climate.wg3 import clean_wg3_scenarios
import pyam
import pandas as pd
import xarray as xr
# import copy
import json

# TONN REMOVE start
class EnvironmentError(Exception):  
    pass  

for env_var in ["MAGICC_EXECUTABLE_7", "MAGICC_WORKER_ROOT_DIR"]:  
    if os.environ.get(env_var, '') == '':  
        # If clause covers both cases in which the env var is not set at all 
        # as well as the case in which it is set to an empty string
        # If these are already set, it shouldn't override it. We actually may not want to have a default but just throw an error if not set
        os.environ["MAGICC_EXECUTABLE_7"]       =   "/p/projects/rd3mod/climate-assessment-files/magicc-v7.5.3/bin/magicc"
        os.environ["MAGICC_WORKER_ROOT_DIR"]    =   os.environ["PTMP"] + "/"  
        raise EnvironmentError(f"{env_var} does not exist")  


    # Optional debug prints  
    print(f"Found '{env_var}' = '{os.environ.get(env_var)}' ") 

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




# %%
# Setting parameters
# REMOVE 
# args = argparse.Namespace(scens_file='/p/projects/piam/abrahao/scratch/remind_tonn/output/N_SSP2EU-NPi-internalize-ar6_2024-06-12_10.39.45/climate-assessment-data-tirf/allpulses.xlsx', climatetempdir='/p/projects/piam/abrahao/scratch/remind_tonn/output/N_SSP2EU-NPi-internalize-ar6_2024-06-12_10.39.45/climate-assessment-data-tirf', endyear='2205', scenario_batch_size='1', probabilistic_file='/p/projects/piam/abrahao/scratch/remind_tonn/output/N_SSP2EU-NPi-internalize-ar6_2024-06-12_10.39.45/probmod.json', num_cfgs='1')
# END REMOVE 

# Harmonized and infilled emissions scenario
basescenfname = args.scens_file

# JSON with parameter sets
climate_assessment_magicc_prob_file_iteration = args.probabilistic_file

# Final year for MAGICC run
endyear = args.endyear

# Output file name, assumed to be inside climatetempdir
# TODO: We don't really use climatetempdir here, 
# so we might want to replace it with a --outfilename 
# argument, with default in the current working directory
outfilename = os.path.join(args.climatetempdir,"openscm_output.xlsx")

# %% 
# Check arguments

# %%
# Clean the harmonized and infilled scenario, fixing some variable names required
inbasescen = pyam.IamDataFrame(basescenfname)

# %%
def clean_wg3_scenarios(inp):
    inp.filter(
        variable=[
            "*Infilled|Emissions|CO2",
            "*Infilled|Emissions|F-Gases",
            "*Infilled|Emissions|HFC",
            "*Infilled|Emissions|PFC",
            "*Infilled|Emissions|Kyoto Gases (AR5-GWP100)",
            "*Infilled|Emissions|Kyoto Gases (AR6-GWP100)",
        ],
        keep=False,
        inplace=True,
    )

    infilled_emms_filter = "*Infilled*"
    df_clean = inp.filter(variable=infilled_emms_filter).data.copy()

    if df_clean.empty:
        LOGGER.error("No '%s' data available", infilled_emms_filter)

        return None

    replacements_variables = {
        r".*\|Infilled\|": "",
        "AFOLU": "MAGICC AFOLU",
        "Energy and Industrial Processes": "MAGICC Fossil and Industrial",
        "HFC43-10": "HFC4310mee",
        # "Sulfur": "SOx",
        # "VOC": "NMVOC",
        r"HFC\|": "",
        r"PFC\|": "",
        "HFC245ca": "HFC245fa",  # still needed?
    }
    for old, new in replacements_variables.items():
        df_clean["variable"] = df_clean["variable"].str.replace(old, new, regex=True)

    replacements_units = {
        "HFC43-10": "HFC4310mee",
    }
    for old, new in replacements_units.items():
        df_clean["unit"] = df_clean["unit"].str.replace(old, new)

    # # avoid MAGICC's weird end year effects by ensuring scenarios go just beyond
    # # the years we're interested in
    # scens_scmrun = scmdata.ScmRun(df_clean)
    # output_times = [
    #     dt.datetime(y, 1, 1) for y in scens_scmrun["year"].tolist() + [3000]
    # ]
    # scens_scmrun = scens_scmrun.interpolate(
    #     output_times,
    #     extrapolation_type="constant",
    # )
    # clean_scenarios = scens_scmrun.timeseries().reset_index()
    clean_scenarios = df_clean

    def fix_hfc_unit(variable):
        if "HFC" not in variable:
            raise NotImplementedError(variable)

        return "kt {}/yr".format(variable.split("|")[-1])

    hfc_rows = clean_scenarios["variable"].str.contains("HFC")
    clean_scenarios.loc[hfc_rows, "unit"] = clean_scenarios.loc[
        hfc_rows, "variable"
    ].apply(fix_hfc_unit)

    try:
        # if extra col is floating around, remove it
        clean_scenarios = clean_scenarios.drop("unnamed: 0", axis="columns")
    except KeyError:
        pass

    return clean_scenarios
#%%
basescen = clean_wg3_scenarios(inbasescen)
#%%
# Read parameter sets, can also be multiple
with open(climate_assessment_magicc_prob_file_iteration) as f:
    allparsets = json.load(f)
allparsets = [i["nml_allcfgs"] for i in allparsets["configurations"]]

# Set endyear in all parsets 
for parset in allparsets:
    parset["endyear"] = int(endyear)


# %%
runresults = openscm_runner.run(
    climate_models_cfgs={
        "MAGICC7" : allparsets
    },
    output_variables=(
        "Surface Air Temperature Change",
        "Effective Radiative Forcing|Anthropogenic",
        "Net Atmosphere to Land Flux|CO2"
    ),
scenarios = scmdata.ScmRun(basescen)
    )

# %%
# Write output

outfilename = os.path.splitext(basescenfname)[0] + '_IAMC_climateassessment.xlsx'

runresults.filter(region = "World"
                  ).to_iamdataframe(
                      
                  ).swap_time_for_year(
                      
                  ).to_excel(
                      outfilename
                      )
