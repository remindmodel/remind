# Changing inputs in REMIND model
Miško Stevanović (<stevanovic@pik-potsdam.de>), Lavinia Baumstark (<baumstark@pik-potsdam.de>), Mika Pflüger(<mika.pflueger@pik-potsdam.de>)

-   [Introduction](#introduction)
-   [Input data](#input-data)
    * [How to Update Input Data](#how-to-update-input-data)
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
For further information how this works and how to add new input data, the [madrat vignette](https://pik-piam.r-universe.dev/articles/madrat/madrat.html) is a good start.

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
the name of the needed input data is constructed. It is checked whether those input data are already available. If not they are automatically downloaded and distributed. For details where to get the input data if you are not running the model on the PIK cluster, see [02a_RunningREMINDLocally.md](https://github.com/remindmodel/remind/blob/develop/tutorials/02a_RunningREMINDLocally.md).

The prepared input data is a compressed tar archive file `.tgz` and can be found on the PIK cluster at `/p/projects/rd3mod/inputdata/output`.
If you want to peek inside the archive to debug something or out of curiosity you can use the software [7-Zip](https://www.7-zip.org/), or the `tar` command in the terminal.

### How to Update Input Data

1. Run the helper tool `lastrev` (`/p/projects/rd3mod/tools/lastrev`) to get a list of the last five `revX.XXX*_remind.tgz` items in the default madrat output directory. Alternatively, you can also check by hand in the `/p/projects/rd3mod/inputdata/output` folder on the PIK cluster.

2. Clone the [remind-preprocessing repo](https://github.com/remindmodel/pre-processing) to your tmp folder on the cluster and edit its `start.R` file by inserting the next revision number. Use at least 4 decimal places for development/testing. If an old revision number is used, the input data will not be recalculated. Input data for a new regional resolution will be recalculated based on the existing cache information in the PUC file.

3. Start the script with `sbatch slurm_start.sh`.
The .log file lists the progress and potential errors. This process might take a while (currently >8 hours).

4. If the process terminates without errors, do a test run with the new input data. To do this, clone the REMIND repo and update the data input version `cfg$revision` in `config/default.cfg` using your recently created data revision number file and run one scenario (e.g. SSP2EU-Base).

4.a ATTENTION: If your new input data change FE pathways, population, GDP trajectories or substantial behaviour of REMIND, you need to rerun the CES parameter calibration (see tutorial 12_Calibrating_CES_Parameters) and adjust the input data revision together with the updated CES parameters.

5. If the test run completes without errors, add the change in `config/default.cfg` and the update of the input data revision in `main.gms` that was automatically performed by the REMIND run to a commit in your REMIND clone. This can be best done by using
```bash
git add -p config/default.cfg main.gms
```
and then selecting the change in `default.cfg` and the first change to the input data in `main.gms` with `y`, and then ignoring possible other changes in `main.gms` with `d`. Create a pull request to push this change to the main REMIND repository, and REMIND will use the new data by default.

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
