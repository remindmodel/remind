# Running REMIND locally
Mika Pflüger (mika.pflueger@pik-potsdam.de), Tonn Rüter (tonn.rueter@pik-potsdam.de)

*Note:* This approach of running REMIND is a work in progress, however successful REMIND runs on local machines have been conducted using this tutorial.

## System Requirements

Check the general system requirements in [Section 1: Getting REMIND](01_GettingREMIND.md).

- Installed python version must be `< 3.11`. We recommend a python version `3.10.X` as it is closest to being up-to-date while remaining REMIND compatible. To check your python version run `python --version` in a terminal of your choice
- There are some additional recommendations for running REMIND locally on a **Windows systems**:  
  - To avoid lengthy compilation times during preparation for your remind run, we recommend to use a version of R for which most R-packages that REMIND depends on, are available as binary packages. This is typically the case for recent versions of R, currently `4.2.X` or `4.3.X`. To check your R version run `R --version` in a terminal of your choice
  - As mentioned in the general system requirements, GAMS must be installed. On Windows, make sure that the path to GAMS applications is in your PATH environment variable
  - We recommend to use PowerShell rather than the standard command prompt

## Getting Input Data

### Use Local Input Data

**This is the supported way of input data handling**

As long as we do not provide a curated collection of input data please obtain these files from the cluster:

```bash
rev6.606_62eff8f7_remind.tgz
rev6.606_62eff8f7_validationremind.tgz
CESparametersAndGDX_878ac5d69254efb4eba5c1fa39aba64000307bb1.tgz
```

The contents of these tar-archives are necessary to run REMIND locally. Since REMIND input data is constantly updated the up-to-date file names may vary, but will exhibit a similar pattern. The first two files can be found on the cluster at `/p/projects/rd3mod/inputdata/output`, the latter file in `/p/projects/remind/inputdata/CESparametersAndGDX`.

Download & store them in a folder of your choice. The corresponding path is provided to REMIND via environment variable. Add to your local `~/.Renviron` file (in linux, found in your home directory, in windows, found at `C:\Users\<your windows username>\Documents\.Renviron`):

```bash
# REMIND data setup
# If the input data is spread over multiple directories,
# separate them with a : on linux, a ; on windows
REMIND_repos_dirs="/my/first/path:/my/second/path"
# On windows, it would look something like
# REMIND_repos_dirs="C:\Users\<your windows username>\REMIND;D:\REMIND"
# depending on your used file paths
```

You do not have to unpack tar-archives as this will be done during the start-up of your REMIND run.

Make sure that the configuration parameters `inputRevision` and `CESandGDXversion` in your default configuration file `<REMIND_DIR>/config/default.cfg` match the file names. In the present example, parameter `inputRevision` must be `6.606`, consisting of the numbers after `rev` in the file name `rev6.606_62eff8f7_remind.tgz`. Parameter `CESandGDXversion` must be the string `878ac5d69254efb4eba5c1fa39aba64000307bb1` given in the corresponding file whose name starts with `CESparametersAndGDX_`.

### Download Input Data Automatically

**This approach requires a working, OpenSSH-based SSH key management set-up on your machine**

Please verify the SSH set-up on your machine by running `ssh-key -L` in a terminal session. The output should look similar to

```bash
ssh-rsa LongStringOfRandomLettersNumbersAndSuch== pikaccounts\\<Your PIK user name>@<Host Name>
```

If your output is empty, try the [Use Local Input Data](#use-local-input-data) approach mentioned above.

If you have access to the PIK cluster (if you don't have access to the PIK cluster, you can get access only if you are a PIK employee) and like to automatically download the input data when running REMIND on your local machine, you need to configure this via environment variables.
Add to your `~/.Renviron` file (in linux, found in your home directory, in windows, found at `C:\Users\<your windows username>\Documents\.Renviron`):
```bash
# REMIND data repository setup
# Download from the PIK cluster, (needs access)
REMIND_repos_scp="scp://cluster.pik-potsdam.de/p/projects/rd3mod/inputdata/output;scp://cluster.pik-potsdam.de/p/projects/remind/inputdata/CESparametersAndGDX"
# Username on the PIK cluster
REMIND_repos_scp_user="myusername"
# Path to your ssh private key on your laptop (might also be id_rsa or similar)
REMIND_repos_scp_key="/home/myusername/.ssh/id_ed25519"
# For windows, the path to the key is likely something like
# C:\Users\myusername\.ssh\id_ed25519 , check the `.ssh` folder
# in your home directory
```

Make sure to use your username on the cluster and the correct path to your private ssh key (might also be named `id_rsa` or something similar starting with `id_`).

### Tell REMIND where to find MAGICC

REMIND needs to be told where to find the configuration files of the 'Model for the Assessment of Greenhouse Gas Induced Climate Change' ([MAGICC](https://magicc.org/)). The config files all come with REMIND, so we just need to set the appropriate location in the REMIND default config file at `<REMIND_DIR>/config/default.cfg`. Open the file with a text editor of your choice and locate the variable `magicc_template`. In the `default.cfg` file, the corresponding section will look like

```R
cfg$magicc_template <- "/p/projects/rd3mod/magicc/"
```

Change it to the fully qualified file path (i.e. a file path without double points `..` or the tilde `~`) of the MAGICC configuration files. These are located at `<REMIND_DIR>/core/magicc`. The resulting line should look like:

```R
cfg$magicc_template <- "<REMIND_DIR>/core/magicc/"
```

On Linux the fully qualified file path will look similar to:

```R
cfg$magicc_template <- "/home/<YOUR USERNAME>/REMIND/core/magicc"
```

On Windows remember to also escape the backslashes:

```R
cfg$magicc_template <- "C:\\Users\\<YOUR USERNAME>\\REMIND\\core\\magicc"
```

## Start a run

In a terminal session change directory to the location where REMIND was cloned via `cd <REMIND_DIR>` and start a run as you would do on the cluster. As a linux user, type

```bash
Rscript start.R
```

or as a Windows user, type

```PowerShell
Rscript.exe .\start.R
```

## Known Issues & Further Debugging

### `renv` Confuses Itself

*Telltale sign* Rscript fails at the beginning of a run printing

```
Rscript : Error in eval(quote({ : object '..version..' not found
```

This occurs usually after an initial run has completed and seems to only affect people running REMIND with R-version `4.1.X`. The

*Solution* is to checkout the original version of `<REMIND_DIR>/renv/activate.R` via

```bash
git checkout ./renv/activate.R
```

then restart your run.

### Support RSE with Extensive Log Files

In case your REMIND run fails and you wish to be supported by REMIND RSE in getting it to run properly, please help us by recording the logging output of the run. On linux, start your run via

```bash
Rscript start.R &>> failed_REMIND_run.log
```

or on Windows via

```PowerShell
Rscript.exe .\start.R *>> failed_REMIND_run.log
```

This writes *all* output from your run to a file in your `<REMIND_DIR>` directory called `failed_REMIND_run.log`. After hitting enter in your terminal session, none of the usual output will show up since it is being redirected into the aforementioned file. You can still follow the progress of your run by opening a second terminal window and type in

```bash
tail -n 25 -f <REMIND_DIR>/failed_REMIND_run.log
```

on Linux or

```PowerShell
Get-Content <REMIND_DIR>/failed_REMIND_run.log -Tail 10 -Wait
```

on Windows. In case you need to interact with the run script during execution (ie. when selecting the run mode) you can still do so in the terminal session from which you started the run.
