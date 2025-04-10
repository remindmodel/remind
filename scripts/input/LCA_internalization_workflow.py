import argparse
import os

import pandas as pd
import xarray as xr

# Parsing arguments
parser = argparse.ArgumentParser(
    description='Runs the LCA internalization workflow'
    )
parser.add_argument('--static', action='store_true',
                    help='')
parser.add_argument('--quantile', type=float, default=0.5)
parser.add_argument('--single_midpoint', type=str)
parser.add_argument('--exclude_midpoint', type=str)
# parser.add_argument('scens_file', type=str, 
#                     help='an integer for the accumulator')
# parser.add_argument('--climatetempdir', default=os.getcwd(),
#                     help='Temporary folder for climate assessment files')
# parser.add_argument('--endyear', default=2100,
#                     help='Final year for MAGICC runs')
# parser.add_argument('--scenario-batch-size', default=1,
#                     help='How many scenarios to run in a batch, only makes sense when running more than one')
# parser.add_argument('--probabilistic-file', required=True,
#                     help='Required, JSON file with the MAGICC parameter sets. Number of sets must match --num-cfgs')
# parser.add_argument('--num-cfgs', default=1,
#                     help='Number of parameter sets must match --probabilistic-file')


args = parser.parse_args()
print(args)

if args.static:
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
            exclude_list = list(args.exclude_midpoints.replace("_", " ").split(";"))
        ics = [ic for ic in all_ics if ic not in exclude_list]
    costs = costs.sel({"impact category": ics})

    # calculate total costs
    total_costs = costs.sum(dim="impact category")

    # write to .cs4r file
    df = total_costs.to_dataframe().reset_index()
    df["all_te"] = df["REMIND tech"].apply(lambda x: x.split(".")[-1])
    df[["year", "region", "all_te", "cost"]].to_csv("LCA_costs.csv", index=False)


# to be implemented
# else:
#     # run premise
    