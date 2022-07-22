Running REMIND and MAgPIE in coupled mode
================
David Klein (<dklein@pik-potsdam.de>)
27 April, 2020

- [How to start coupled runs](#how-to-start-coupled-runs)
    + [Clone the models](#clone-the-models)
    + [Switch to relevant branchs](#switch-to-relevant-branchs)
    + [Create snapshot of R libraries](#create-snapshot-of-r-libraries)
    + [Activate snapshot for REMIND and MAgPIE](#activate-snapshot-for-remind-and-magpie)
    + [What happens during a single coupled run](#what-happens-during-a-single-coupled-run)
    + [Configure start_bundle_coupled.R](#configure-start_bundle_coupledr)
    + [Configure the scenario_config_coupled.csv of your choice](#configure-the-scenario-config-coupledcsv-of-your-choice)
    + [Perform test start before actually submitting runs](#perform-test-start-before-actually-submitting-runs)
    + [Start runs after checking that coupling scripts finds all gdxes and mifs ](#Start-runs-after-checking-that-coupling-scripts-finds-all-gdxes-and-mifs)

- [Check the convergence](#Check-the-convergence)
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

For both models switch to the git branches you want to use for your runs, for example the `develop` branch for most recent developments, or the `master` branch for a stable release:

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

Direct the models to the snapshot you just created above by editing [`.Rprofile`](../.Rprofile) in both REMIND's main folder. This file will be copied to the MAgPIE main folder automatically. Uncomment these line by deleting `#` and change the date to today (the `_R4` is necessary if you run `R 4.0` or later):

```bash
# snapshot <- "/p/projects/rd3mod/R/libraries/snapshots/2022_05_17_R4"
```

### What happens during a single coupled run

You can find a more technical explanation in the sections below, but the start script is essentially creating new runs of each model that use previous runs as input. These runs's name follow a specific pattern of suffixes and prefixes, and "communicate" through ".mif" reporting files.

<a href="figures/4-REMIND-MAgPIE-circle.png"><img src="figures/4-REMIND-MAgPIE-circle.png" align="right" style="margin-left:2em; width:400px; " /></a>

Here's an example of a simple case. If you start a new coupled run with the scenario name `SSP2-Base`, which doesn't depend on any other run, the script will:

   - Set up and start a normal REMIND run called `C_SSP2-Base-rem-1`, based on the configurations in `scenario_config.csv`
   - After that REMIND run finishes, set up a MAgPIE run, in the MAgPIE folder you defined in `path_magpie`, called `C_SSP2-Base-mag-1`. This run will be configured to:
      - Take the bioenergy demands and GHG prices from the previous REMIND run's reporting output, in `path_remind/output/C_SSP2EU-Base-rem-1/REMIND_generic_C_SSP2EU-Base-rem-1.mif`
      - Take other MAgPIE configurations from the `magpie_scen` column in `scenario_config_coupled.csv`.
   - After that MAgPIE run finishes, start another REMIND run with the name `C_SSP2-Base-rem-2`, which will:
      - Take initial conditions from the `fulldata.gdx` of the previous REMIND run, `C_SSP2-Base-rem-1`.
      - Take bioenergy prices and land-use GHG emissions from the previous MAgPIE run's reporting output, in `path_magpie/output/C_SSP2-Base-mag-1/report.mif`

This process will continue until for as many iterations as set in `max_iterations` in `start_bundle_coupled.R` (see Check the Convergence below). The last iteration will run REMIND only, so REMIND will have run `max_iterations` times and MAgPIE wil have run `max_iterations - 1` times. So, if `max_iterations` is 5, the last REMIND run in this case will be `C_SSP2-Base-rem-5` and the last MAgPIE iteration will be `C_SSP2-Base-mag-4`.

The output of both models can be analyzed normally from these two runs. However, at the end of a successful coupled run the coupling script will automatically merge the reports of the last runs of both models in a `.mif` file located in the root of REMIND's output folder. In our example, that file will be `path_remind/output/C_SSP-Base.mif`.

So, in the end of the coupled run in this example, you should have a directory structure like:

```
|-- path_remind       # the path to the REMIND model folder
|   |-- output
|       |-- C_SSP2-Base-rem-1
|       |-- C_SSP2-Base-rem-2
|       |-- C_SSP2-Base-rem-3
|       |-- C_SSP2-Base-rem-4
|       |-- C_SSP2-Base-rem-5
|       |-- C_SSP2-Base.mif

|-- path_magpie       # the path to the MAgPIE model folder set in start_bundle_coupled.R
|   |-- output
|       |-- C_SSP2-Base-mag-1
|       |-- C_SSP2-Base-mag-2
|       |-- C_SSP2-Base-mag-3
|       |-- C_SSP2-Base-mag-4
```

### What happens during a bundle of coupled runs

Make sure you have read and understood [`3_RunningBundleOfRuns`](./3_RunningBundleOfRuns.md).
For coupled runs, there are two modes to run a bundle of runs:
In the "serial" mode, each subsequent run waits until the last run (say: `-rem-5`) of the `Base` run is finished:

```
Base-rem-1 -> Base-rem-2…4 -> Base-rem-5 -> NDC-rem-1 -> NDC-rem-2…4 -> NDC-rem-5 -> Policy-rem-1 etc.
```
So all `NDC-rem-x` use the `fulldata.gdx` from `Base-rem-5` as input etc.
Each chain from `-rem-1` to `-mag-4` and `-rem-5` is performed as one single cluster job.
A typical run with `max_iterations = 5` may need 16 to 48 hours each. On the PIK cluster, this implies that `qos = medium` has to be used.

The alternative is the "parallel" mode, where `NDC-rem-1` uses the `fulldata.gdx` from `Base-rem-1` as `path_gdx_ref`, while `NDC-rem-2` uses `Base-rem-2` and so on:

```
Base-rem-1 -> Base-rem-2   -> Base-rem-3   -> Base-rem-4
            ↳ NDC-rem-1    -↳ NDC-rem-2    -↳ NDC-rem-3    -↳ NDC-rem-4
                            ↳ Policy-rem-1 -↳ Policy-rem-2 -↳ Policy-rem-3 -↳ Policy-rem-4
```
Each REMIND run has its own cluster job and should require around 4 to 10 hours. On the PIK cluster, this allows to use `priority` and `short` jobs.
The advantage is that the total runtime is reduced, and once `Policy-rem-1` is finished, you have a full set of preliminary data available, instead of waiting for all runs to be finished.

### Configure start_bundle_coupled.R

See comments in the head section of the file. Most importantly you need to provide the path to MAgPIE.

### Configure the config files of your choice

Required as `path_settings_coupled` is a file from [`./config/`](../config) that starts with `scenario_config_coupled*.csv` and provides some extra information for coupled runs (e.g. which run should be started, specific MAgPIE configurations), with one scenario per row and settings on the columns. `path_settings_remind` is a normal `scenario_config` that defines all other REMIND settings, as explained in [`3_RunningBundleOfRuns`](./3_RunningBundleOfRuns.md). Every scenario to be run must be present in both files.

All the columns must be present in the `scenario_config_coupled.csv` file, but most of them can be left blank. The required ones are:
   - `title`: The name of the scenario, must be unique and match the `title` column in REMIND's `scenario_config.csv`
   - `start`: Defines if a scenario run should be started (1) or not (0). Overrides whatever is set in REMIND's `scenario_config.csv`. If you have an unfinished coupled run, it will automatically try to continue from the last coupling iteration (i.e. REMIND or MAgPIE run), if it is not finished yet (i.e. reached `max_iterations`).
   - `qos`: The SLURM qos the coupled runs should be submitted to. Currently, there is no default support for running a coupled run locally. Your choice should depend on whether you use the `parallel` mode or not (see below). In the second case, it is wise to choose a qos with a long time limit. If no `qos` is set here, the default one is `short`. Naturally, the `qos` names are likely different if you are running the models in a different cluster.
   - `magpie_scen`: A pipe (`|`) separated list of configurations to pass to MAgPIE. Each entry should correspond to a column in [MAgPIE's scenario_config](https://github.com/magpiemodel/magpie/blob/master/config/scenario_config.csv), each one of them setting the multiple configuration flags listed on that file. The configurations are applied in the order that they appear. For example, to configure MAgPIE with SSP2 settings and climate change impacts according to RCP45 set `magpie_scen` to `SSP2|cc|rcp4p5`.
   - `no_ghgprices_land_until`: Controls at which timestep in the MAgPIE runs GHG prices from REMIND will start to be applied. This essentially enables you to set whether or not (or when) GHG prices on land should be applied in MAgPIE. If you want MAgPIE to always apply the same GHG prices from REMIND, you should set this to a timestep corresponding to the start of your REMIND run, such as `y2020` to start in the 2020 timestep. If you want to disable GHG prices in MAgPIE, regardless of what REMIND finds, set this to the last timestep of the run (usually `y2150`). Values in between allow the simulation of policies where GHG prices are only applied in the land use sector after a certain year.

Other, optional columns allow you to make a run start only after another has finished, set starting conditions, and give you finer control over which data is fed to MAgPIE.
   - `path_gdx`, `path_gdx_ref`, `path_gdx_refpolicycost`, `path_gdx_carbonprice`, `path_gdx_bau`, : Override these same settings in REMIND's `scenario_config`, see [`3_RunningBundleOfRuns`](./3_RunningBundleOfRuns.md) for a detailed explanation.
      - You can set these switches either to the full path of a `fulldata.gdx` file or simply to the name of another scenario in the file (without the "C_"!). So if you want a certain scenario (say `SSP2-NDC`) to use as starting point the results of a `SSP2-Base` scenario, you can simply set `path_gdx` to `SSP2-Base` and it will automatically locate the appropriate `fulldata.gdx` in `SSP2-Base`, for example `path_remind/C_SSP2-Base-rem-5/fulldata.gdx` if 5 iterations where requested and you run in "serial" mode.
      - If you set any of these `path_gdx…` columns (or `path_mif_ghgprice_land`, below) with a scenario name such as `SSP2-Base`, the coupling script will not start any runs that depend on an unfinished run, and automatically start them when that run finishes. So, in the example above, you can set `start` to `1` in both `SSP2-Base` and `SSP2-NDC`, `SSP2-NDC` will only start *after* `SSP2-Base` is finished. In "parallel" mode, `SSP2-NDC-rem-1` will start after `SSP2-Base-rem-1` is finished, while in "serial" mode, it waits for `SSP2-Base-rem-5`.
      - If you set any of these settings with a scenario name, the script will automatically try to detect whether the required "parent" run including the reporting is already finished and uses the appropriate `fulldata.gdx` then. In "serial" mode, if for some reason you changed `max_iterations` between the "parent" run and the current one, it's safer to specify a full path to a `fulldata.gdx` in these settings, otherwise the script may look for the wrong iteration of the "parent" scenario.
      - You can also set it to `C_SSP2-Base-rem-3` if for some reason, you want the results of a specific iteration.
   - `path_mif_ghgprice_land`: This setting allows MAgPIE to be run using an exogenous, fixed GHG price path, regardless of the GHG price in the REMIND coupling. This can be useful if you want to simulate different GHG pricing policies in the land-use sector. It's timing is also controlled by `no_ghgprices_land_until`.
      - As with the `path_gdx*` settings, this can be set both to the full path of a REMIND `.mif` reporting file (*not* a `.gdx`) or to the name of another scenario. If set to the name of another scenario, it will also wait for that run to finish before starting the dependent run as described.
   - `oldrun`: This setting can be used to continue a coupled run that had a different name and/or is in a different folder. It works in almost the same way as `path_gdx`, but it is used only if no REMIND run has been finished for this scenario. It will look in the path set in `start_bundle_coupled.R`'s `path_remind_oldruns`. This can be useful when continuing a previous experiment that was made in another REMIND copy, or after changing scenario names.
   - `cm_nash_autoconverge_lastrun`: can be used to specify `cm_nash_autoconverge`, but only for the last REMIND run, for example to increase precision there by setting it to `2`.


### Perform test start before actually submitting runs

The `--test` (or `-t`) flag shows you if the scripts find all information that are crucial for starting the coupled runs, such as gdxes, mifs, model code. It also indicates if a run that crashed previously can be continuned and where (which model, which iteration).

```bash
Rscript start_bundle_coupled.R --test
```

The "parallel" mode is selected by adding the corresponding flag:

```bash
Rscript start_bundle_coupled.R --parallel --test
```

A shortcut for this command is `./start_bundle_coupled.R -pt` (or `-p -t`, if you prefer).

If you provide a coupled config file as command line argument, it overwrites the settings in `start_bundle_coupled.R`:
```bash
Rscript start_bundle_coupled.R --test config/scenario_config_coupled_XYZ.csv
```
This assumes that the REMIND settings can be found in `config/scenario_config_XYZ.csv` without the `_coupled`.

### Start runs after checking that coupling scripts finds all gdxes and mifs

```bash
Rscript start_bundle_coupled.R [--parallel] [configfile]
```

You can append `&> start_log.txt` (or a different filename) to this command if you want to save the log of this procedure to a file, instead of printing it to the screen. You can have a look with `less start_log.txt`.

# Check the convergence

There is no automatic abort criterion for the coupling iterations. The number of coupling iterations is given by the user (`max_iterations` in start_bundle_coupled.R) and will be performed regardless of the quality of convergence. The convergence can be checked, however, by tracking the changes of crucial coupling variables (such as bioenergy demand and prices, GHG emissions and prices) across coupling iterations. After `max_iterations` is reached, a pdf showing these changes is produced automatically that can be found in the common `output` folder of REMIND. If you want to create this pdf for one or more scenarios specifically please provide the names of these runs as follows:

```bash
Rscript output.R
```
choosing a `comparison` and then `plot_compare_iterations`.
If the iterations you want to inspect are located in an output folder different from `output` please provide the path to this folder:

```bash
Rscript scripts/output/comparison/plot_compare_iterations.R folder=another-output-folder
```

To compare the REMIND runs, a `compareScenario2` for each scenario is produced automatically in the main folder (look for `compScen_rem-1-5_SSP2-Base.pdf` or similar).
You can switch that off by setting `run_compareScenario` to `FALSE` in `start_bundle_coupled.R`.

# Technical concept

There are two components of the REMIND-MAgPIE coupling: the prominent dynamic part (models solve iteratively and exchange data via coupling script), the more hidden static part (exogenous assumptions derived from the other model, updated manually from time to time via [`mrcommons`](https://github.com/pik-piam/mrcommons/blob/master/R/readMAgPIE.R)).

### Dynamic part

* bioenergy demand, GHG prices from REMIND to MAgPIE (technical: getReportData in [`startfunctions.R`](https://github.com/magpiemodel/magpie/blob/master/scripts/start_functions.R))
* bioenergy prices, GHG emissions from MAgPIE to REMIND (technical: getReportData in [`prepare_and_run.R`](https://github.com/remindmodel/remind/blob/develop/scripts/start/prepare_and_run.R))

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

<img src="figures/coupling-scripts.png" style="display: block; margin: auto;" />

* `start_bundle_coupled.R`
  * reads scenario_config_coupled.csv and scenario_config.csv files and updates model cfgs accordingly
  * saves all settings (including cfgs) to individual `.RData` files in the REMIND main folder. In "serial" mode, a single file such as `C_SSP2-Base.RData` is written, while in "parallel" mode, each REMIND run gets its own `C_SSP2-Base-rem-x.RData` file.
  * sends a job to the cluster for each scenario specified in the csvs. Each job executes `start_coupled.R`.
* `start_coupled.R`
  * tries to detect runs that crashed and that can be continued
  * reads the `.RData` file and starts REMIND and MAgPIE. In "serial" mode, this is repeated multiple times within `start_coupled.R`, while the "parallel" mode executes `start_coupled.R` multiple times and runs REMIND and MAgPIE only once each time.
  * saves the output of one model into the specific intput folder of the other model
  * the models read these inputs as part of their individual start scripts
  * REMIND runs last
  * after last coupling iteration generate combined reporting file by binding REMIND and MAgPIE mifs together, and create a `compareScenario2` for REMIND and a `plot_compare_iterations` for the MAgPIE results.
