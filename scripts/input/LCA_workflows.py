import argparse
import os

import pandas as pd
import xarray as xr

from internalizer import Internalizer

EI_VERSION = "3.10"
YEARS_INTERNALIZATION = [2020, 2030, 2040, 2050, 2060, 2070]
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
RAMP_UP_START = 2020
RAMP_UP_END = 2030

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
        
def get_impact_categories(args):
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

    return ics
        
def add_ES_subcategories(mifpath):
    """
    Add subcategories for ES transport variables that are needed for premise.
    """
    df = pd.read_csv(mifpath, sep=";").iloc[:, :-1]

    all_variables = list(df["Variable"].unique())
    ES_variables = [v for v in all_variables if v.startswith("ES|Transport")]
    parent_variables = [v for v in ES_variables if v.split("|")[-1] in ["Liquids", "Gases"]]
    dflist = []
    for parent in parent_variables:
        prefix = parent.replace("ES|", "FE|")
        children = [v for v in all_variables if v.startswith(prefix + "|")]
        if len(children) == 3:
            subcats = [v.split("|")[-1] for v in children]

            years = list(df.columns)[5:]

            total = df[df["Variable"] == prefix].set_index("Region")[years].astype(float)
            parent_df = df[df["Variable"] == parent]
            new_unit = list(parent_df["Unit"].unique())[0]
            parent_df = parent_df.set_index("Region")[years].astype(float)

            for cat in subcats:
                s = prefix + "|" + cat
                sel = df[df["Variable"] == s].copy().set_index("Region")[years].astype(float)
                share = sel.div(total, axis=0)
                new_df = share.mul(parent_df, axis=0).reset_index()
                new_df["Model"] = list(df["Model"].unique())[0]
                new_df["Scenario"] = list(df["Scenario"].unique())[0]
                new_df["Unit"] = new_unit
                new_df["Variable"] = "|".join([parent, cat])
                dflist.append(new_df)
            
    additions = pd.concat(dflist, axis=0)[["Model", "Scenario", "Region", "Variable", "Unit"]+years]
    
    pd.concat((df, additions), axis=0).to_csv(mifpath, sep=";", index=False)



if __name__ == "__main__":
    # Parsing arguments
    parser = argparse.ArgumentParser(
        prog="run_lca_workflow",
        description='Runs the LCA internalization workflow'
        )
    parser.add_argument('mifpath', type=str, help="Path to the .mif file")
    parser.add_argument('gdxpath', type=str, help="Path to the .gdx file")
    parser.add_argument('pathway', type=str, help="Name of the REMIND scenario")
    routines = parser.add_argument_group(title="Routines", description="Flags determining which routines to run.")
    routines.add_argument('--plca', action='store_true', help="Run pLCA updates with premise")
    routines.add_argument('--calcCosts', action='store_true', help="Run the cost calculation")
    routines.add_argument('--aggTaxes', action='store_true', help="Run the cost aggregation to REMIND taxes")
    group = parser.add_argument_group(title="Monetization", description="Flags that determine the monetization")
    monetization_group = group.add_mutually_exclusive_group(required=True)
    monetization_group.add_argument('--quantile', type=float, help="quantile for MC monetization")
    monetization_group.add_argument('--perspective', type=str, help="monetization perspective")
    monetization_group.add_argument('--monetization_factors', type=str, help="File with explicit monetization factors")
    parser.add_argument('--single_midpoint', type=str, help="Run for a single midpoint")
    parser.add_argument('--exclude_midpoints', type=str, help="Run with some midpoints excluded")

    args = parser.parse_args()
    print(args)

    # in any case, initialize an Internalizer instance
    bw_project = f"internalizer_ei_{EI_VERSION}"
    I = Internalizer(
        args.mifpath,
        "remind",
        args.pathway,
        EI_VERSION,
        bw_project,
        args.gdxpath,
        outputfolder = "lca"
    )

    if args.plca:
        add_ES_subcategories(args.mifpath)
        I.run_premise(YEARS_INTERNALIZATION)
    else:
        I.years = YEARS_INTERNALIZATION

    if args.calcCosts:
        monetization = get_monetization_arg(args)
        I.calculate_costs(monetization)

    if args.aggTaxes:
        I.load_costs()

        ics = get_impact_categories(args)
        I.write_remind_input_files(
            RAMP_UP_START,
            RAMP_UP_END,
            ics
        )
