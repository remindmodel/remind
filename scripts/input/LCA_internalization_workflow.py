import argparse
import os

import pandas as pd
import xarray as xr

from internalizer import Internalizer

EI_VERSION = "3.10"

def get_monetization_arg(args):
    if args.quantile is not None:
        return args.quantile
    elif args.perspective is not None:
        return args.perspective
    else:
        df = pd.read_csv(args.monetization_factors)
        if len(df.columns) != 2:
            raise ValueError("File with monetization factors must have exactly two columns!")
        else:
            k = df.columns[0]
            v = df.columns[1]
            return df.set_index(k)[v].to_dict()
        
IMPACT_CATEGORIES_MC = [
    "acidification",
    "climate change",
    "ecotoxicity",
    "eutrophication",
    "fossil resources",
    "human toxicity",
    "ionizing radiation",
    "land use",
    "metal/mineral resources",
    "ozone depletion",
    "particulate matter formation",
    "photochemical oxidant formation",
    "water use"
]
    
# Parsing arguments
parser = argparse.ArgumentParser(
    prog="run_internalizer",
    description='Runs the LCA internalization workflow'
    )
parser.add_argument('mifpath', type=str, help="Path to the .mif file")
parser.add_argument('gdxpath', type=str, help="Path to the .gdx file")
parser.add_argument('pathway', type=str, help="Name of the REMIND scenario")
parser.add_argument('--mode', choices=['static', 'iterative', 'testing'], required=True,
                    help="whether to run static, iterative, or testing mode")
group = parser.add_argument_group(title="Monetization", description="Flags that determine the monetization")
monetization_group = group.add_mutually_exclusive_group(required=True)
monetization_group.add_argument('--quantile', type=float, help="quantile for MC monetization")
monetization_group.add_argument('--perspective', type=str, help="monetization perspective")
monetization_group.add_argument('--monetization_factors', type=str, help="File with explicit monetization factors")
parser.add_argument('--single_midpoint', type=str, help="Run for a single midpoint")
parser.add_argument('--exclude_midpoints', type=str, help="Run with some midpoints excluded")

args = parser.parse_args()
print(args)

# setup logging file
logFile = open("log_lca.txt", "a")

if args.mode == "static":
    # load static data
    costs = xr.open_dataarray("/p/tmp/davidba/internalization/internalizer/all_costs_NPi.nc")

    # select right quantile
    costs = costs.sel({"quantile": args.quantile})

    # select the right midpoints
    all_ics = list(costs.coords["impact category"].values)
    ics = []
    if args.single_midpoint != "none":
        ics = [args.single_midpoint]
    else:
        exclude_list = []
        if args.exclude_midpoints != "none":
            exclude_list = list(args.exclude_midpoints.split(","))
        ics = [ic for ic in all_ics if ic not in exclude_list]
    costs = costs.sel({"impact category": ics})

    # calculate total costs
    total_costs = costs.sum(dim="impact category")

    # write to .cs4r file
    df = total_costs.to_dataframe().reset_index()
    df["all_te"] = df["REMIND tech"].apply(lambda x: x.split(".")[-1])
    df[["year", "region", "all_te", "cost"]].to_csv("LCA_costs.csv", index=False)

elif args.mode == "iterative":
    # set up brightway project
    bw_project = f"internalizer_ei_{EI_VERSION}"

    # initialize Internalizer
    I = Internalizer(
        args.mifpath,
        "remind",
        args.pathway,
        EI_VERSION,
        bw_project,
        args.gdxpath,
        outputfolder = "lca"
    )
    print(I.scenario)
    logFile.writelines(
        ["Internalizer initialized successfully."]
    )

    # premise runs
    years = [2020, 2030, 2040, 2050, 2060, 2070]
    I.run_premise(years, multiprocessing=False)
    logFile.writelines(
        ["premise runs done."]
    )

    # cost calculation (default mappings)
    monetization = get_monetization_arg(args)
    I.calculate_costs(monetization)
    logFile.writelines(
        ["Cost calculation done."]
    )

    # get selected impact categories
    if args.monetization_factors is not None:
        all_ics = list(monetization.keys())
    else:
        all_ics = IMPACT_CATEGORIES_MC
    ics = []
    if args.single_midpoint != "none":
        ics = [args.single_midpoint]
    else:
        exclude_list = []
        if args.exclude_midpoints != "none":
            exclude_list = list(args.exclude_midpoints.split(","))
        ics = [ic for ic in all_ics if ic not in exclude_list]

    # output files
    ramp_up_start = 2020
    ramp_up_end = 2030
    I.write_remind_input_files(
        ramp_up_start,
        ramp_up_end,
        ics
    )
    logFile.writelines(
        ["input files written."]
    )
elif args.mode == "testing":
    # check whether the brightway project is accessible and contains the right databases
    import bw2data as bd

    bw_project = f"internalizer_ei_{EI_VERSION}"
    bd.projects.set_current(bw_project)
    needed_dbs = [f"ecoinvent-{EI_VERSION}-biosphere",
                  f"ecoinvent-{EI_VERSION}-cutoff"]
    for db in needed_dbs:
        if db not in list(bd.databases):
            logFile.writelines(
                [f"WARNING: {db} not found in brightway project {bw_project}"]
            )

    # try to get monetization
    monetization = get_monetization_arg(args)
    logFile.writelines(
        ["Monetization given:\n",
         str(monetization)]
    )


logFile.close()
