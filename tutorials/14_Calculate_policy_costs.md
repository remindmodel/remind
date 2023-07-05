## Calculate policy costs

Authors: Johannes Koch, Oliver Richters, 20.01.2023

This is a very short guideline on how to prepare the policy cost reporting. It calculates the losses or gains by comparing a policy run with a reference run (often, this is the SSPx-NPi run).

If you run a cascade of runs and the reference run is finished before the policy run is started, you can simply specify the reference run as a column `path_gdx_refpolicycost` in the scenario_config file, see [REMIND tutorial 03](03_RunningBundleOfRuns.md). If your policy run is not finished in time, you have to perform these calculations after it is finished.

The following script updates the reporting file called `REMIND_generic_scenName.mif` in the output subdirectory of your policy run.
It will contain the standard reporting, but with the corrected/adjusted policy costs.

What you need to do:
1. In the remind folder with all your submission relevant runs, run `Rscript output.R`, pick `Comparison across runs`, and then `policyCosts`.
2. Now you have to pick the scenarios of your policy runs, and afterwards, the single reference run with regards to which you want to compute the policy costs.
3. Wait for the updated mif file(s) to be created, and a pdf with the computed policy costs.
4. Use the new mif files for your submission. If necessary, perform final adjustments by hand (e.g. removing regional consumption losses, see /p/projects/piam/SDP_runs/SDP_round1/remind/rm_regipolicycosts.sh)

For coupled runs, you may adapt and use these small bash scripts:
``` bash
#!/bin/bash

# wrapper script for the policy cost calculation
# instead of calling Rscript output.R -> comparison -> policyCosts and selecting the scenarios manually, 
# you specify the scenarios below
# Note: currently works only for coupled runs (for standalone runs the timestamp needs to be taken up)
# Bjoern Soergel, Oliver Richters, 2023

# definition of (scenario - reference) run pairs as expected by policy cost calculation
# select the appropriate definition set below, or add for your project

# SHAPE (only mandatory runs)
scenarioAndReference=("SDP_EI-PkBudg650" "SDP_EI-NPi" \
"SDP_EI-NPi" "SDP_EI-NPi" \ #including NPi w.r.t. to NPi to add zeros
"SDP_MC-PkBudg650" "SDP_MC-NPi" \
"SDP_MC-NPi" "SDP_MC-NPi" \
"SDP_RC-PkBudg650" "SDP_RC-NPi" \
"SDP_RC-NPi" "SDP_RC-NPi" \
"SSP2EU-NDC" "SSP2EU-NPi" \
"SSP2EU-PkBudg650" "SSP2EU-NPi"
"SSP2EU-NPi" "SSP2EU-NPi"
)

# generate scenario selection string as expected by policyCosts
remnr=5
scenarioAndReference=( "${scenarioAndReference[@]/#/output/C_}" )
scenarioAndReference=( "${scenarioAndReference[@]/%/-rem-$remnr}" )
scenarioAndReference=( $( IFS="," ; echo "${scenarioAndReference[*]}") )

Rscript output.R comp=T output=policyCosts outputdir=$scenarioAndReference
```

Short version if you have a single base run for all your scenarios and want to automatically start a compareScenario2 and an IIASA export:
```
# NGFS
remnr=5
runs=(h_cpol h_ndc o_2c o_1p5c o_lowdem d_delfrag d_strain)
baserun=h_cpol

outputarraypc=( "${runs[@]/%/-rem-${remnr},output/C_${baserun}-rem-${remnr}}" )
outputarraypc=( "${outputarraypc[@]/#/output/C_}" )
outputstringpc="$(IFS=,; echo "${outputarraypc[*]}")"
Rscript scripts/output/comparison/policyCosts.R outputdirs=$outputstringpc special_requests=

outputarraycs=( "${runs[@]/%/-rem-${remnr}}" )
outputarraycs=( "${outputarraycs[@]/#/output/C_}" )
outputstringcs="$(IFS=,; echo "${outputarraycs[*]}")"
Rscript output.R comp=export output=xlsx_IIASA outputdir=$outputstringcs project=NGFS_v4 filename_prefix=NGFS_v4
Rscript output.R comp=comparison output=compareScenarios2 outputdir=$outputstringcs filename_prefix=NGFS_v4 slurmConfig=priority profileNames=REMIND-MAgPIE
```
