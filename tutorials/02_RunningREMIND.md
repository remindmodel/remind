Start running REMIND with default settings
================

- [Start running REMIND with default settings](#start-running-remind-with-default-settings)
- [Your first run](#your-first-run)
  - [Default Configurations](#default-configurations)
  - [Starting the run](#starting-the-run)
  - [Restarting runs](#restarting-runs)
- [What happens during a REMIND run?](#what-happens-during-a-remind-run)
- [What happens once you start REMIND on the cluster?](#what-happens-once-you-start-remind-on-the-cluster)
  - [`renv` Setup](#renv-setup)
  - [Input Data Preparation](#input-data-preparation)
  - [Optimization](#optimization)
  - [Output Processing](#output-processing)

# Your first run

> **Note** This tutorial assumes that you have access to the PIK HPC, have followed the instructions [in the REMIND group-internal Wiki](https://gitlab.pik-potsdam.de/rse/rsewiki/-/wikis/Cluster-Access) on how to access the PIK HPC and configure your cluster environment.

This section will explain how you start your first REMIND run on the Potsdam Institute for Climate Impact Research (PIK) High Performance Cluster (HPC). Running REMIND on other hosts is theoretically possible but works slightly different depending on input data availability and operating system configuration.

## Default Configurations

The [`main.gms`](../main.gms) and [`config/default.cfg`](../config/default.cfg) files contain the default configuration for REMIND.
[`main.gms`](../main.gms) is divided into several parts.

a. The first part, MODULES, contains settings for the various [modules](../modules) and their realizations. For example, the [module `21_tax`](../modules/21_tax/) has the realizations [`on`](../modules/21_tax/on) and [`off`](../modules/21_tax/off). The realizations within the particular module differ from each other in their features, for e.g., bounds, parametric values, different policy cases etc. For each module you choose which realization of the module will be activated for your current run:

``` bash
cfg$gms$module_name
```

b. The SWITCHES section contains setting parameters to control, for e.g., how many iterations to run, which technologies to include.

c. The FLAGS section contains compilation flags (setGlobals) for further configuration, for e.g., which SSP to use.

d. The last part includes all model parts from the core and modules.

## Starting the run

Open a terminal session on the HPC and create a folder where you want to store REMIND. It is discouraged to use the `home` directory. For your first experiments you can use a subfolder of the `/p/tmp/<PIK user name>/` directory, but keep in mind that unused files are deleted after three months.

In case you are using console and are not familiar with shell commands, google a list of basic shell commands such as `mkdir` to create a folder or `cd /p/tmp/<PIK user name>/` to switch to your folder. Download REMIND into a directory in this folder via `cloneremind` (see tutorial [00_Git_and_GitHub_workflow](00_Git_and_GitHub_workflow.md)).

Go to your REMIND main folder (i.e. it contains subfolders such as `config`, `core`, and `modules`) and start a REMIND run by typing:

``` bash
Rscript start.R
```

Without additional arguments this starts a single REMIND run using the settings from [`config/default.cfg`](../config/default.cfg) and [`main.gms`](../main.gms).
Also, on Windows, you can double-click the `start_windows.cmd` file.
You can control the script's behavior by providing additional arguments, for example starting a single REMIND run in one-region mode using the settings from `config/default.cfg` and `main.gms` (useful to quickly check if your changes to the code break the model):

``` bash
Rscript start.R --quick
```
The shortcut is
```bash
Rscript start.R -q
```

A message similar to the following confirms that your runs has been submitted to a compute node on the cluster: `Submitted batch job 15489230`.

You can check if the run is actually running by using the command

``` bash
sq
```
in the terminal.

To see how far your run is or whether it was stopped due to some problems, you can check based on the output folder (shown as `WORK_DIR` in `sq`) by typing
``` bash
remindstatus output/default_2024-02-29_16.45.19
```
in the console. If you are in the folder, `remindstatus` is sufficient.
For a short version, use `rs2` (see help at `rs2 -h`). For more commands to manage your runs, type `piaminfo`.

NOTE: A few words on the scripts that we currently use to start runs. The scripts containing the string 'start' have a double functionality:
- they submit the run to the cluster or to your GAMS system if you work locally
- they create the `full.gms` file (this is the file that will eventually be submitted to GAMS once your run has been compiled) and compile the needed files to start a run in a subfolder of the output folder

## Restarting runs

Sometimes you want to restart a run in its already existing results folder without creating a new results folder and without compiling a new full.gms, e.g. you want a nash run to perform additional nash iterations because you are not satisfied with the convergence so far. Adding the parameter `--restart` displays a list of existing runs and lets you choose the run(s) you want to restart:

``` bash
Rscript start.R --restart
Rscript start.R -r
```

This will use the result of the previous optimization (`fulldata.gdx`) as input for the restart. Note that this will NOT continue the run from the last CONOPT iteration (which is impossible at the moment), but simply restart the run from the last `fulldata.gdx`. Accordingly, all outputs (like `full.lst`, gdx, etc) are overwritten if you do not first make a copy by hand.


# What happens during a REMIND run?

This section will give some technical introduction into what happens after you have started a run. It will not be a tutorial, but rather an explanation of the different parts in the modeling routine. The whole routine is illustrated in Figure 1. The core of the model is the optimization written in GAMS. However, there is some pre-processing of the input data and some post-processing of the output data using R scripts.

<img src="figures/REMIND_flow.png" alt="REMIND modeling routine" width="100%" />
<p class="caption">
REMIND modeling routine
</p>

# What happens once you start REMIND on the cluster?

Let us go through each of the stages and briefly describe what happens:

## `renv` Setup
REMIND is using renv for R package library management, see [the REMIND renv tutorial](11_ManagingRenv.md) for details. When starting a run the main renv is essentially copied to the run folder which ensures that the run is always using the same package versions for reproducibility and packages cannot become corrupt because of global package updates.

The R libraries required for indput data preparation and output processing (e.g. **madrat**, **mrremind** and **remind2**) are made available to the run this way.

## Input Data Preparation

The optimization in REMIND requires a lot of input data. For example, the model needs to know energy production capacities per region for its initial time steps. Furthermore, it builds on GDP, population and energy demand projections that are results of other models. These kind of data are stored on the cluster in

``` bash
/p/projects/rd3mod/inputdata/sources
```

The data are mostly in csv files. During the input data preparation, these files are read and processed, using functions from the *mrremind* package. Input data are available on country-level. Then, depending on the regionmapping file you chose in the config file of your run, the country-level data are aggregated into regions, e.g. to LAM (Latin America), EUR (Europe) and so on. Finally, the data are stored as `.cs3r` or `.cs4r` files in various input folders of your REMIND directory. These files are basically tables, too, that you can open with a text editor or Excel. For example, you find the input file `pm_histCap.cs3r` in your REMIND directory under `core/input`. It provides the model with historically observed values of installed capacities of some technologies in the respective regions.
The regional resolution of the run is set in the `config/default.cfg` by
``` bash
cfg$regionmapping
```
(default setting: regionmapping <- "config/regionmappingH12.csv"). Based on the regional resolution and the input data revision
``` bash
cfg$inputRevision
```
the name of the needed input data is constructed. It is checked whether those input data are already available. If not they are automatically downloaded from `/p/projects/rd3mod/inputdata/output/` and distributed.

## Optimization

The actual REMIND is written in GAMS, a programming software to numerically solve optimization problems. The GAMS scripts are *.gms* files that you can find under the `core` (main part of the model) and the `modules` directories (subparts of the model). The general structure of the GAMS code is depicted in Figure 2. At each stage (e.g. *sets*), GAMS runs through the respective *.gms* files of the core and all chosen module realisations of that stage (`core/sets.gms` -> `modules/01_macro/sets.gms`, -> `modules/02_welfare/sets.gms` -> ...) before going to the next stage. The stages *bounds*, *presolve*, *solve* and *postsolve* are run in a loop that is followed by the final stage *output*.

<img src="figures/REMIND_gams_flow.png" alt="Structure of the REMIND GAMS code" width="100%" />
<p class="caption">
GAMS code structure
</p>

Fundamentally, we distinguish between two kinds of variables: variables (starting with *v_*) and parameters (starting with *p_*). Parameters are fixed (exogenous data in economists' lingo), while variables are free within a certain range and can be adjusted to maximize the objective function of the optimization problem (endogenous variables in economist's lingo). However, there are many constraints that fix relations between the variables and parameters. Within the remaining solution space, the optimization procedure tries to find the maximum of the objective function. The output file of the optimization is the **fulldata.gdx** which is under `output` in the folder of your REMIND run. You can open it, for instance, with GAMS IDE or load it into `R` using the command  `readGDX()` (see details below). In the file, you can find, among other things, the optimal levels of the variables (`variable.l`) and all the predefined parameter values.

## Output Processing

The output processing works with a number of R functions from the **[remind2](https://github.com/pik-piam/remind2/)** package (most of them start with `report... .R`). The wrapper function **[convGDX2MIF.R](https://github.com/pik-piam/remind2/blob/master/R/convGDX2MIF.R)** writes the most relevant output into the so-called **.mif** file. Again, it is a table that you can open in Excel for example. You find under `output` in the folder of your REMIND run as

``` bash
REMIND_generic_YourRun.mif
```
where *YourRun* is the name of the run you specified in the first column of the config file. It is important to keep in mind that between `fulldata.gdx` and the `.mif` file and number of calculations and conversions are happening which makes the variables in both files different. For output analysis, the `.mif` file is often more helpful, while in case you want to trace back some problem with the GAMS optimization, it can be necessary to directly look at optimal levels, marginals (values that tell you whether a variation of the variable increase or decrease the welfare level) or bounds (maximum and minimum value allowed for variable) that you all find in the `fulldata.gdx` created right after the optimization.
