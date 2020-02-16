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

For both models switch to the git branches you want to use for your runs.

### Create snapshot of R libraries

Coupled runs may take a bit longer. During the runtime some of the R packages that are used by the coupled runs might get updated.
Updates might change the behaviour of functions in an unexpected way. To avoid this create a snapshot of the R libraries before starting
the runs:

```bash
bash /p/projects/rd3mod/R/libraries/Scripts/create_snapshot_with_day.sh
```

### Activate snapshot for REMIND and MAgPIE

Direct the models to the snapshot you created above by editing .Rprofile in the model's main folder respectively.

### Configure start_bundle_coupled.R 

See comments in the head section of the file.

### Configure the scenario_config_coupled.csv of your choice

### Use the latest GAMS version

This is step is optional.

```bash
module load gams/30.1.0
```

### Perform test start before actually submitting runs

```bash
Rscript start_bundle_coupled.R test
```

### After checking that coupling scripts finds all gdxes and mifs start runs

```bash
Rscript start_bundle_coupled.R
```