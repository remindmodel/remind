# Changing inputs in REMIND model
Miško Stevanović (<stevanovic@pik-potsdam.de>), Lavinia Baumstark (<baumstark@pik-potsdam.de>), Mika Pflüger(<mika.pflueger@pik-potsdam.de>)

-   [Introduction](#introduction)
-   [Input data](#input-data)
    * [How to Update Input Data](#how-to-update-input-data)
    * [Enhancing Input Data using madrat](#adjusting-and-enhancing-input-data-using-madrat)
-   [Initial parameter values](#initial-parameter-values)
    * [Different Regional Resolutions](#different-regional-resolutions)
-   [CES Parameter Values](#ces-parameter-values)

## Introduction

The data REMIND needs to run consists of three main parts:
* the input data
* initial values for all optimization parameters
* calibrated values for the parameters of the CES production functions.

## Input Data

The input data for REMIND are generated from original sources (e.g. IEA, GTAP, PWT...) using the [madrat](https://github.com/pik-piam/madrat) framework.
Within the madrat framework, the [mrremind](https://github.com/pik-piam/mrremind) package ties all REMIND input data together.
For further information on how this works and how to add new input data, the [madrat vignette](https://pik-piam.r-universe.dev/articles/madrat/madrat.html) is a good start.

Within REMIND, the specific set of input files to use is specified in the config file `config/default.cfg`.
The regional resolution of the run is set by 
```R
cfg$regionmapping
```
(default setting: `regionmapping <- "config/regionmappingH12.csv"`).
Based on the regional resolution and the input data revision 
```R
cfg$inputRevision
```
the name of the needed input data is constructed. It is checked whether those input data are already available. If not, they are automatically downloaded and distributed. For details on where to get the input data if you are not running the model on the PIK cluster, see [02a_RunningREMINDLocally.md](https://github.com/remindmodel/remind/blob/develop/tutorials/02a_RunningREMINDLocally.md).

The prepared input data is a compressed tar archive file `.tgz` and can be found on the PIK cluster at `/p/projects/rd3mod/inputdata/output`.
If you want to peek inside the archive to debug something or out of curiosity you can use the software [7-Zip](https://www.7-zip.org/), or the `tar` command in the terminal.

### How to Update Input Data

1. Run the helper tool `lastrev` (`/p/projects/rd3mod/tools/lastrev`) to get a list of the last five `revX.XXX*_remind.tgz` items in the default madrat output directory. Alternatively, you can also check by hand in the `/p/projects/rd3mod/inputdata/output` folder on the PIK cluster.

2. Clone or pull the latest version of the [remind-preprocessing repo](https://github.com/remindmodel/pre-processing) to your tmp folder on the cluster and edit its `config/default.cfg` file by inserting the next revision number. Use the additional argument `dev` for testing. If an old revision number is used, the input data will not be recalculated. Input data for a new regional resolution will be recalculated based on the existing cache information in the PUC file.

3. Start the script with `Rscript submit_preprocessing.R`.
The `.log` file lists the progress and potential errors. This process might take a while (currently >8 hours).

4. If the process terminates without errors, do a test run with the new input data. To do this, clone the REMIND repo and update the data input version `cfg$revision` in `config/default.cfg` using your recently created data revision number file and run one scenario (e.g. SSP2-Base).

4.a ATTENTION: If your new input data change FE pathways, population, GDP trajectories or substantial behaviour of REMIND, you need to rerun the CES parameter calibration (see tutorial 12_Calibrating_CES_Parameters) and adjust the input data revision together with the updated CES parameters.

5. If the test run completes without errors, add the change in `config/default.cfg` and the update of the input data revision in `main.gms` that was automatically performed by the REMIND run to a commit in your REMIND clone. This can be best done by using
```bash
git add -p config/default.cfg main.gms
```
and then selecting the change in `default.cfg` and the first change to the input data in `main.gms` with `y`, and then ignoring possible other changes in `main.gms` with `d`. Create a pull request to push this change to the main REMIND repository, and REMIND will use the new data by default.

## Adjusting and Enhancing Input Data using madrat

To learn the basics about [madrat](https://pik-piam.r-universe.dev/articles/madrat/madrat.html) and [madrat caching](https://pik-piam.r-universe.dev/madrat/doc/madrat-caching.html), please refer to the corresponding vignettes.

### Remote development on the cluster using VS Code

If you are developing in R using VS Code, you can connect to the cluster via ssh and develop on the cluster remotely. Please check the following tutorial for detailed information:

- [Using R in the cluster with VSCode](https://gitlab.pik-potsdam.de/pascalfu/bettercode-vscode/-/blob/main/R_VScode_in_the_cluster.md)
- [How to connect VScode to the cluster using ssh](https://github.com/pik-piam/discussions/discussions/4)

**Important: Keep in mind that heavy workloads must not be executed on login nodes and should be passed to compute nodes instead.** Make sure to read the section ["A word of caution on using the cluster"](https://gitlab.pik-potsdam.de/pascalfu/bettercode-vscode/-/blob/main/R_VScode_in_the_cluster.md#a-word-of-caution-on-using-the-cluster) before working in the cluster.

### Get an up-to-date cache on the cluster for local development

If you want to develop a madrat package locally, you might want to work with an up-to-date cache to avoid gathering all source data locally and re-running lengthy calculations on your own computer. The default cache folder on the cluster is too large for this purpose, but there are two ways to create your own cache and download it. 

**Option 1**: You can use the tool `idrcp` to achieve this. The tool extracts all cache files either written to or read from listed in the logfile of a REMIND input data revision and stores them in an archive you can download.

You need to pass the path to a input data revision, e.g. `idrcp /p/projects/rd3mod/inputdata/output/rev6.51_62eff8f7_remind.tgz`. Select a remind or a validation file, depending on which cache you need – basically whether the function you are working on is called from `mrremind::fullREMIND()` or `mrremind::fullVALIDATIONREMIND()`.

Unfortunately, this does not work for archives that were created using a [portable unaggregated collection (puc)](https://pik-piam.r-universe.dev/articles/madrat/madrat-puc.html). If the diagnostics.log file has an entry looking like this under "Current madrat configuration", the archive won't be suitable for the script: `cachefolder -> "/p/tmp/benke/.Rtmp/RtmpU9rYHO/file25418fd5e15/puc"`


**Option 2**: If you need a cache file for every single intermediate step executed during input data generation, you might want to generate your own cache from scratch. To do so, follow the steps 2) and 3) under [How to update input data](#how-to-update-input-data), but make further adjustments in`config/default.cfg`:

- Make sure your own madrat settings are used and caching is not forced: `cfg$cachetype <- "def"` (should be default already) 
- Read from / write to your own cache folder instead of the shared default cache. `cfg$cachefolder <- "[PATH/TO/YOUR/CACHE]"`
- Set a development suffix in `config/default.cfg` to distinguish your own input data version from other versions: `dev <- "my-personal-cache"` (optional)

After input data generation succeeded, you can download your cache folder from the path you set in the config file and use it as your local cache. 

### Development on the cluster using RStudio

Unfortunately, there is no way known to achieve this. 

You can use use a program like WinSCP or FileZilla to download and edit files in RStudio locally and sync them back to the cluster when done. Alternatively you can add changes to your GitHub branch locally and check them out on the cluster. 

In any case, you won't be able to use RStudio to run and debug your code on the cluster. So using VSCode on the cluster or developing locally are most likely better options.

### Updating sources on the cluster

The original sources can be found on the cluster in the madrat source folder `/p/projects/rd3mod/inputdata/sources`. A madrat function `readABC` expects a corresponding folder `ABC` in the cluster folder where it looks for the source data to be read in.

When you update a source with newer data, don't just replace the outdated source file, but create a new file (or a new subfolder) for each new version of the data. For example, if `tau_data_1995-2000.mz` is replaced by `tau_data_1995-2010.mz`, keep both files in the madrat source folder and update the reference in the code. By doing so, you ensure backwards compatibility.

If both versions of the data are still used in your madrat package, use subtypes in your read function to manage the source version to be read in. 

## Initial Parameter Values

The initial values for all optimization parameters are taken from a previous run and supplied via an input `gdx` file, which has to be supplied externally.

Within REMIND, the input `gdx` is automatically downloaded and unpacked based on the 
```R
cfg$CESandGDXversion
```
parameter in `config/default.cfg`, which specifies a unique commit hash specifying a combination of input `gdx` and CES parameters (see below).

The data is also provided in a compressed tar archive file `.tgz` and can be found on the cluster at `/p/projects/remind/inputdata/CESparametersAndGDX`.

### Different Regional Resolutions

If you plan to run REMIND with a regional resolution deviating from the default you have to take care that REMIND starts from a gdx with the correct regional resolution.
Either you can use one from an older run with the corresponding regional resolution, or you can build a new gdx with the correct regional resolution from a gdx in a different regional resolution using the function `gdx_rename` from the package `gdx` (e.g. `gdx::gdx_rename("input.gdx",set_name="all_regi",c(REF="RUS",CAZ="ROW",...,MEA="MEA",USA="USA"))`).

## CES Parameter Values

The CES parameter values are the result of a calibration run, and usually supplied like the input `gdx`, see above.
You can find more details about the calibration procedure in the [12_Calibrating_CES_Parameters tutorial](https://github.com/remindmodel/remind/blob/develop/tutorials/12_Calibrating_CES_Parameters.md).
