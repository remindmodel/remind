Running REMIND and MAgPIE in coupled mode
================
David Klein (<dklein@pik-potsdam.de>)
16 February, 2020

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

### Use the latest GAMS version

This step is optional. If you want to use the latest GAMS version type this into the same command line you will start the runs from:

```bash
module load gams/30.2.0
```

### Perform test start before actually submitting runs

```bash
Rscript start_bundle_coupled.R test
```

### After checking that coupling scripts finds all gdxes and mifs start runs

```bash
Rscript start_bundle_coupled.R
```