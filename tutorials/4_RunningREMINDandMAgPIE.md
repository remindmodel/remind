Running REMIND and MAgPIE in coupled mode
================
David Klein (<dklein@pik-potsdam.de>)
27 April, 2020

- [How to start coupled runs](#how-to-start-coupled-runs)
    + [Clone the models](#clone-the-models)
    + [Switch to relevant branchs](#switch-to-relevant-branchs)
    + [Create snapshot of R libraries](#create-snapshot-of-r-libraries)
    + [Activate snapshot for REMIND and MAgPIE](#activate-snapshot-for-remind-and-magpie)
    + [Configure start_bundle_coupled.R](#configure-start-bundle-coupledr)
    + [Configure the scenario_config_coupled.csv of your choice](#configure-the-scenario-config-coupledcsv-of-your-choice)
    + [Perform test start before actually submitting runs](#perform-test-start-before-actually-submitting-runs)
    + [After checking that coupling scripts finds all gdxes and mifs start runs](#after-checking-that-coupling-scripts-finds-all-gdxes-and-mifs-start-runs)
- [Technical concept](#technical-concept)
    + [Dynamic](#dynamic)
    + [Static](#static)
    + [The coupling scripts](#the-coupling-scripts)
    
# How to start coupled runs

### Clone the models

```bash
git clone https://github.com/magpiemodel/magpie.git
git clone https://github.com/remindmodel/remind.git
```

### Switch to relevant branchs

For both models switch to the git branches you want to use for your runs, for example the `develop` branch

```bash
git checkout develop
```

### Create snapshot of R libraries

Coupled runs may take a bit longer. During the runtime some of the R packages that are used by the coupled runs might get updated.
Updates might change the behaviour of functions in an unexpected way. To avoid this create a snapshot of the R libraries before starting
the runs:

```bash
bash /p/projects/rd3mod/R/libraries/Scripts/create_snapshot_with_day.sh
```

### Activate snapshot for REMIND and MAgPIE

Direct the models to the snapshot you just created above by editing .Rprofile in both REMIND's and MAgPIE's main folder respectively. Uncomment these lines:

```bash
# snapshot <- "/p/projects/rd3mod/R/libraries/snapshots/2019_02_26"
# if(file.exists(snapshot)) {
# cat("Set libPaths to",snapshot,"\n")
# .libPaths(snapshot)
# }
```
and change the date to today.

### Configure start_bundle_coupled.R 

See comments in the head section of the file. Most importantly you need to provide the path to MAgPIE.

### Configure the scenario_config_coupled.csv of your choice

By default these are (A) `scenario_config_coupled_SSPSDP.csv` and (B) `scenario_config_SSPSDP.csv`. A provides some extra information
for coupled runs (e.g. which run should be started). All other settings are taken from B. Thus every scenario in A must also be present in B.

### Perform test start before actually submitting runs

```bash
Rscript start_bundle_coupled.R test
```

### After checking that coupling scripts finds all gdxes and mifs start runs

```bash
Rscript start_bundle_coupled.R
```

# Technical concept

There are two components of the REMIND-MAgPIE coupling: the prominent dynamic part (models solve iteratively and exchange data via coupling script), the more hidden static part (exogenous assumptions derived from the other model, updated manually from time to time via moinput).

### Dynamic part

* bioenergy demand, GHG prices from REMIND to MAgPIE (technical: getReprotData in magpie/startfunctions.R)
* bioenergy prices, GHG emissions from MAgPIE to REMIND (technical: getReportData in remind/scripts/start/prepare_and_run.R)

### Static part

* bioenergy supply curves in REMIND derived from MAgPIE (vignette remulator package)
* CO2 MAC: currently deactivated due to negligible differences in CO2 LUC emissions across RCPs
* CH4/N2O MAC (turned on in REMIND standalone, turned off in REMIND coupled because abatement is part of MAgPIE)
* GHG emission baselines for SSPs/RCPs (updated in coupled runs)
* total agricultural production costs (fixed for standalone and coupled)

### Assumptions

* Biomass trade takes place in REMIND, i.e. biomass demand is prescribed to MAgPIE on regional level (not global).
* CH4 and N2O prices in MAgPIE are limited to the upper end of the MAC curve to avoid infeasibilities
* demand dependent bioenery tax in REMIND
* afforestation assumptions (reward for negative emissions, investment decisions (planing horizon, 20% insurance))

### The coupling scripts

The meta scripts for coupled runs that configure the models, start the runs, and perform the iteration loop are located in the REMIND main folder.

* `start_bundle_coupled.R`
  * reads scenario_config_coupled.csv and scenario_config.csv files and updates model cfgs accordingly
  * saves all settings (including cfgs) to individual `runname.RData` files in the REMIND main folder
  * sends a job to the cluster for each scenario specified in the csvs. Each job executes `start_coupled.R`.
* `start_coupled.R`
  * tries to detect runs that crashed and that can be continued
  * reads the `runname.RData` and starts REMIND and MAgPIE iteratively
  * saves the output of one model into the specific intput folder of the other model
  * the models read these inputs as part of their individual start scripts:
    * MAgPIE: getReprotData in magpie/startfunctions.R
    * REMIND: getReportData in remind/scripts/start/prepare_and_run.R
  * REMIND runs last
  * after last coupling iteration generate combined reporting file by binding REMIND and MAgPIE mifs together
