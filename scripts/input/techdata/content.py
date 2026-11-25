# |  (C) 2006-2026 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
"""Techno-economic values for REMIND, fetched from POSTED.

POSTED (https://github.com/PhilippVerpoort/posted), the Potsdam open-source
techno-economic database, provides values for energy and climate-mitigation
technologies. This module aggregates the TEDFs listed in QUERIES into the REMIND
PROPERTIES, scripts/input/techdata/create_input.py checks and writes the
csv files.

POSTED's aggregate() harmonises units and averages across sources, subtechnologies
and sizes, normalising all values to one unit of output capacity and output
activity of the technology. The properties are then calculated from these with
pint quantities from cet_units (https://github.com/PhilippVerpoort/cet-units),
keeping track of their units, so that the unit written above every value of the
csv is derived, not asserted. POSTED delivers global data only; regional values
would belong in p_inco0 and pm_data in core/datainput.gms, not in fm_dataglob,
and are not handled here.
"""

import pandas as pd
from cet_units import Unit
from posted import TEDF, defaults

# Currency of all monetary values. Must match the currency REMIND expects in
# core/datainput.gms (fm_dataglob after the generisdata conversion).
defaults["currency"] = "USD_2017"

# Activity and capacity unit per carrier (POSTED flow names), lower heating
# values. Inputs, outputs and capacities of all technologies are converted to
# these units, so that efficiencies are kWh/kWh and costs are per kW of output.
# The steel technologies of the process-based industry model are measured in
# mass, which is also the unit generisdata_tech.prn gives their costs in.
CARRIERS = {
    "Electricity": ("kWh", "kW"),
    "Heat": ("kWh", "kW"),
    "Fischer-Tropsch Fuel": ("kWh", "kW"),
    "Hydrogen": ("kWh_H2_LHV", "kW_H2_LHV"),
    "Natural Gas": ("kWh_NG_LHV", "kW_NG_LHV"),
    "Coal": ("kWh_coal_LHV", "kW_coal_LHV"),
    "Methanol": ("kWh_MeOH_LHV", "kW_MeOH_LHV"),
    "Direct Reduced Iron": ("t", "t/a"),
    "Steel Liquid": ("t", "t/a"),
    "Steel Hot-rolled Coil": ("t", "t/a"),
}

# The aggregated POSTED variables the PROPERTIES are calculated from, renamed to
# the short names these expressions use, next to input, output and capacity, and
# the unit they are normalised to, {currency} replaced by the currency of the
# technology. POSTED wants these units as strings, it appends time units itself.
VARIABLES = {
    "CAPEX": ("capex", "{currency}"),
    "OPEX Fixed": ("opexf", "{currency}/a"),
    "OPEX Variable": ("opexv", "{currency}"),
    "Lifetime": ("life", "a"),
}

# REMIND properties (char in GAMS) written to f_techdata.csv, calculated
# from the renamed variables of a technology. POSTED's aggregate() normalises
# every variable to one unit of reference activity or capacity, so CAPEX and
# OPEX Variable are only divided by input, output and capacity to get them back
# per unit. Units follow from the carriers of the query, see property_unit().
# One expression per property, evaluated with the variables as pint quantities.
#
# omf is a fraction of the investment costs per year. REMIND's omv is charged per
# unit of output, but generisdata_tech.prn and therefore GAMS give it per kW of
# output and year, so converting POSTED's per output kWh value to that unit
# multiplies it by the 8760 hours of a full-load year; for the technologies
# measured in mass it is already per tonne and stays untouched.
# inco0year is not calculated: fetch writes the year of the inco0 above into the
# csv as this char, as generisdata_tech.prn does, and core/datainput.gms anchors
# the learning curve of teLearn at it.
PROPERTIES = {
    "inco0": "capex / capacity",
    "eta": "output / input",
    "omf": "opexf / capex",
    "omv": "opexv / output",
    "lifetime": "life",
}


def variables(query):
    """The variables one technology is calculated from, POSTED's variable name to
    the short name PROPERTIES uses and the unit it is normalised to: the output
    activity, output capacity and input of the technology, plus VARIABLES."""
    activity, capacity = CARRIERS[query["output"]]
    found = {f"Output|{query['output']}": ("output", activity),
             f"Output Capacity|{query['output']}": ("capacity", capacity)}
    if "input" in query:
        found[f"Input|{query['input']}"] = ("input", CARRIERS[query["input"]][0])
    return found | {name: (short, unit.format(currency=defaults["currency"]))
                    for name, (short, unit) in VARIABLES.items()}


def property_unit(query, prop):
    """The unit REMIND expects for one property of one technology, derived from
    the carriers it converts."""
    activity, capacity = CARRIERS[query["output"]]
    currency, year = Unit(defaults["currency"]), Unit("a")
    return {
        "inco0": currency / Unit(capacity),
        # per capacity and year for energy technologies, for the ones measured
        # in mass POSTED's value already is per tonne
        "omv": (currency / (Unit(capacity) * year) if activity.startswith("kWh")
                else currency / Unit(activity)),
        "lifetime": year,
        # efficiencies keep the units of the two carriers they convert between
        "eta": (Unit(activity) / Unit(CARRIERS[query["input"]][0])
                if "input" in query else Unit("dimensionless")),
        "omf": Unit("1/a"),
    }[prop]


BASE_YEAR = 2025

# Years requested from POSTED: it cannot aggregate a single period, so several
# are asked for even though only the ones selected in QUERIES are written. It
# interpolates between its data points and extrapolates outside their range.
PERIODS = [2020, 2025, 2030, 2040, 2050]

# QUERIES: REMIND technology -> POSTED TEDF, input and output carrier (keys of
# CARRIERS), field values to select (aggregated over afterwards), the year of the
# values written as inco0year, defaulting to BASE_YEAR and shared by all queries
# of a technology, and the PROPERTIES taken from POSTED. A technology can be
# mapped to a list of queries, their properties are then averaged over the TEDFs
# that report them. Only these replace generisdata_tech.prn values.
#
# Asterisks cannot be selected for, omit a field to aggregate over all its
# values. Field values are listed explicitly instead of relying on POSTED adding
# new ones. The technologies of the process-based industry model have no input
# carrier and no eta, and POSTED reports the blast-furnace route as a whole: its
# CAPEX is not split between bf and bof, so their inco0 stays from
# generisdata_tech.prn, and its OPEX Variable is charged once, through bof, whose
# output is the route's, because core/equations.gms q_costOM charges omv on the
# output of every one of the two.
QUERIES = {
    "elh2": {
        "tedf": "Tech|Electrolysis",
        "input": "Electricity",
        "output": "Hydrogen",
        "select": {"subtech": ["AEL", "PEM"], "size": ["1 MW", "100 MW"]},
        "properties": ["inco0", "eta", "omf"],
    },
    "ngcc": {
        "tedf": "Tech|Gas Turbine",
        "input": "Natural Gas",
        "output": "Electricity",
        "select": {"subtech": ["CCGT conventional"], "mode_h2": ["NG"]},
        "properties": ["inco0", "eta", "omf"],
    },
    # POSTED has OPEX Variable only for the CCGT with carbon capture, which is
    # also why ngcc and h2turb do not get an omv
    "ngccc": {
        "tedf": "Tech|Gas Turbine",
        "input": "Natural Gas",
        "output": "Electricity",
        "select": {"subtech": ["CCGT CC"], "mode_h2": ["NG"]},
        "properties": ["inco0", "eta", "omf", "omv"],
    },
    "h2turb": {
        "tedf": "Tech|Gas Turbine",
        "input": "Hydrogen",
        "output": "Electricity",
        "select": {"subtech": ["CCGT H2-ready"], "mode_h2": ["H2"]},
        "properties": ["inco0", "eta", "omf"],
    },
    "gash2": {
        "tedf": "Tech|Steam Methane Reforming",
        "input": "Natural Gas",
        "output": "Hydrogen",
        "select": {"subtech": ["SMR"], "capture_rate": ["0.00%"]},
        "properties": ["inco0", "eta", "omf", "omv", "lifetime"],
    },
    # autothermal rather than steam methane reforming, its flue gas is
    # concentrated enough to capture from, which is why POSTED gives it a
    # capture rate and REMIND's gash2c is documented with capture
    "gash2c": {
        "tedf": "Tech|Steam Methane Reforming",
        "input": "Natural Gas",
        "output": "Hydrogen",
        "select": {"subtech": ["ATR"], "capture_rate": ["94.50%"]},
        "properties": ["inco0", "eta", "omf", "omv", "lifetime"],
    },
    "coalh2": {
        "tedf": "Tech|Coal Gasification",
        "input": "Coal",
        "output": "Hydrogen",
        "select": {"carbon_capture": ["w/o CC"]},
        "properties": ["inco0", "eta", "omf", "omv", "lifetime"],
    },
    "coalh2c": {
        "tedf": "Tech|Coal Gasification",
        "input": "Coal",
        "output": "Hydrogen",
        "select": {"carbon_capture": ["w/ CC"]},
        "properties": ["inco0", "eta", "omf", "omv", "lifetime"],
    },
    # both the hydrogen to liquids route REMIND models with it and Fischer-
    # Tropsch synthesis are in POSTED, and their costs are averaged
    "MeOH": [
        {
            "tedf": "Tech|Methanol Synthesis",
            "input": "Hydrogen",
            "output": "Methanol",
            "properties": ["inco0", "eta", "omf", "omv", "lifetime"],
        },
        {
            "tedf": "Tech|Fischer-Tropsch",
            "input": "Hydrogen",
            "output": "Fischer-Tropsch Fuel",
            "properties": ["inco0", "eta", "omf", "lifetime"],
        },
    ],
    "idr": {
        "tedf": "Tech|Direct Reduction of Iron",
        "output": "Direct Reduced Iron",
        "select": {"carbon_capture": ["No Capture"]},
        "properties": ["inco0", "omf"],
    },
    "idrcc": {
        "tedf": "Tech|Direct Reduction of Iron",
        "output": "Direct Reduced Iron",
        "select": {"carbon_capture": ["With Capture"]},
        "properties": ["inco0", "omf", "omv"],
    },
    "eaf": {
        "tedf": "Tech|Electric Arc Furnace",
        "output": "Steel Liquid",
        "properties": ["inco0", "omf", "omv"],
    },
    "bf": {
        "tedf": "Tech|Integrated Blast Furnace and Basic Oxygen Furnace",
        "output": "Steel Hot-rolled Coil",
        "select": {"carbon_capture": ["No Capture"]},
        "properties": ["omf", "lifetime"],
    },
    "bof": {
        "tedf": "Tech|Integrated Blast Furnace and Basic Oxygen Furnace",
        "output": "Steel Hot-rolled Coil",
        "select": {"carbon_capture": ["No Capture"]},
        "properties": ["omf", "omv", "lifetime"],
    },
}

# every technology mapped to a list of queries, the ones with a single one get a
# list of one, so that nothing below has to tell the two cases apart
QUERIES = {tech: query if isinstance(query, list) else [query]
           for tech, query in QUERIES.items()}


def compute(query, years):
    """Return a DataFrame of the requested properties of one technology, indexed
    by (period, region), columns are property names."""
    # the variables wanted from POSTED, and the short names of those the
    # PROPERTIES are calculated from
    wanted = variables(query)
    tedf = TEDF.load(query["tedf"])
    df = tedf.aggregate(
        period=years,
        reference_activity=f"Output|{query['output']}",
        reference_capacity=f"Output Capacity|{query['output']}",
        # without these, CAPEX and OPEX keep the unit a source gave, in
        # different ones for each of them, and their ratios are meaningless
        units={name: unit for name, (_, unit) in wanted.items()},
        append_references=True,
        # aggregate over everything but period, region and component: POSTED
        # reports CAPEX and OPEX either for a whole plant (component "#") or
        # split into its components, and averaging the two makes no sense
        agg=[f for f in ["source", *tedf.fields]
             if f not in ("period", "region", "component")],
        **query.get("select", {}),
    )
    if "region" not in tedf.fields:
        df = df.assign(region="global")
    # of every variable wanted from POSTED, keep it as a pint quantity: from
    # here on, units travel with the values and arithmetic derives their units
    df = df[df.variable.isin(wanted)]
    df = df.assign(q=[v * Unit(u) for v, u in zip(df.value, df.unit)])
    df = df.drop(columns=["value", "unit"])
    if "component" in df.columns:
        whole = df[df.component == "#"].drop(columns="component")
        parts = df[df.component != "#"]
        # the components of a variable POSTED has no whole-plant value for,
        # summed; where components are reported in different units, pint
        # converts them, the unit is fixed by property_unit() further down
        parts = parts[~parts.variable.isin(whole.variable)]
        summed = [c for c in parts.columns if c not in ("component", "q")]
        parts = parts.groupby(summed, dropna=False).q.sum().reset_index()
        df = pd.concat([whole, parts])
    names = {name: short for name, (short, _) in wanted.items()}
    df = df.assign(variable=df.variable.map(names))
    requested = query["properties"]
    # one row per technology, one column per variable, so an expression can be
    # evaluated on it; wide.eval raises if POSTED did not report a variable an
    # expression needs
    index = [c for c in df.columns if c not in ("variable", "q")]
    wide = df.pivot(index=index, columns="variable", values="q")
    for prop in requested:
        wide.eval(f"{prop} = {PROPERTIES[prop]}", inplace=True,
                  engine="python")
    values = (wide[requested].rename_axis(columns="variable").stack()
              .rename("q").reset_index())
    values = values[[q.m == q.m for q in values.q]]
    # and pint raises if a unit cannot be rewritten into the one REMIND expects
    expected = {prop: property_unit(query, prop) for prop in requested}
    converted = [q.to(expected[prop])
                 for q, prop in zip(values.q, values.variable)]
    values = values.assign(value=[q.m for q in converted])
    # a pivot, not a pivot_table: values have to be unique per period and region
    return values.pivot(index=["period", "region"], columns="variable",
                        values="value")[requested]


def fetch():
    """Query POSTED for all QUERIES, return a dict mapping (prop, tech) to the
    (year, value, unit) at the selected year, as the median over regions and, for
    a technology queried from more than one TEDF, the mean over those. The year
    is written as the inco0year property of every technology whose inco0 is taken
    from POSTED, it anchors the learning curve of teLearn at that year. Anything
    POSTED or pint raise for a technology is reported as that technology's."""
    selected = {}
    for tech, queries in QUERIES.items():
        try:
            year = queries[0].get("year", BASE_YEAR)
            values = {}
            for sub in queries:
                props = compute(sub, sorted(set(PERIODS) | {year}))
                for prop in sub["properties"]:
                    values.setdefault(prop, []).append(
                        props.xs(year, level="period")[prop].median()
                    )
            if "inco0" in values:
                # not a physical quantity: the year the inco0 values are from
                selected[("inco0year", tech)] = (year, year, "year")
            for prop, prop_values in values.items():
                value = float(pd.Series(prop_values).mean())
                # technologies mapped to several TEDFs can be given in different
                # units by them, the value is then the mean of values in those
                unit = " or ".join(sorted({f"{property_unit(sub, prop):~}"
                                          for sub in queries
                                          if prop in sub["properties"]}))
                selected[(prop, tech)] = (year, value, unit)
                print(f"{prop},{tech}: {value:.6g} {unit} in {year} (POSTED "
                      f"{', '.join(sub['tedf'] for sub in queries)})")
        except Exception as error:
            tedfs = ", ".join(sub["tedf"] for sub in queries)
            raise RuntimeError(f"{tech} ({tedfs}): {error}") from error
    return selected
