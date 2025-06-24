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
        
def get_pathway_name(miffile):
    return miffile.split(".")[0].split("_")[-1]
        
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
parser.add_argument('miffile', type=str, help="Name of the .mif file")
parser.add_argument('gdxfile', type=str, help="Name of the .gdx file")
parser.add_argument('--mode', choices=['static', 'iterative'], required=True,
                    help="whether to run static or iterative mode")
group = parser.add_argument_group(title="Monetization", description="Flags that determine the monetization")
monetization_group = group.add_mutually_exclusive_group(required=True)
monetization_group.add_argument('--quantile', type=float, help="quantile for MC monetization")
monetization_group.add_argument('--perspective', type=str, help="monetization perspective")
monetization_group.add_argument('--monetization_factors', type=str, help="File with explicit monetization factors")
parser.add_argument('--single_midpoint', type=str, help="Run for a single midpoint")
parser.add_argument('--exclude_midpoints', type=str, help="Run with some midpoints excluded")

args = parser.parse_args()
print(args)

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
        args.miffile,
        "remind",
        get_pathway_name(args.miffile),
        EI_VERSION,
        bw_project,
        args.gdxfile,
        outputfolder = "lca"
    )

    # premise runs
    years = [2020, 2030, 2040, 2050, 2060, 2070]
    I.run_premise(years)

    # cost calculation
    monetization = get_monetization_arg(args)
    I.calculate_costs(monetization)

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
    I.write_remind_input_files(
        ramp_up_start,
        ramp_up_end,
        ics
    )
