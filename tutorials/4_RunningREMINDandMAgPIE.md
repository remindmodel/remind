Running REMIND and MAgPIE in coupled mode
================
David Klein (<dklein@pik-potsdam.de>)
27 April, 2020

- [Running REMIND and MAgPIE in coupled mode](#running-remind-and-magpie-in-coupled-mode)
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

Direct the models to the snapshot you just created above by editing .Rprofile in the model's main folder respectively. Uncomment these lines:

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

Two components: a dynamic (models solve iteratively and exchange data), a static (exogenous assumptions derived from the other model, update manually from time to time).

### Dynamic

* bioenergy demand, GHG prices from REMIND to MAgPIE (technical: getReprotData in magpie/startfunctions.R)
* bioenergy prices, GHG emissions from MAgPIE to REMIND (technical: getReportData in remind/scripts/start/prepare_and_run.R)

### Static

* bioenergy supply curves in REMIND derived from MAgPIE (vignette remulator package, MAgPIE emulator description)
* CO2 MAC: currently deactivated due to negligible differences in CO2 LUC emissions across RCPs
* CH4/N2O MAC (on in standaline, off in coupled because abatement is part of MAgPIE)
* GHG emission baselines for SSPs/RCPs (fixed for standalone runs, updated in coupled runs)
* total agricultural production costs (fixed for standalone and coupled)

### The coupling scripts

* at the end: generate combined reporting file by binding REMIND and MAgPIE mifs together