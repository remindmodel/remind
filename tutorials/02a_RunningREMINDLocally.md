# Running REMIND locally
Mika Pflüger (mika.pflueger@pik-potsdam.de), Tonn Rüter (tonn.rueter@pik-potsdam.de)

*Note:* This approach of running REMIND is a work in progress, however successful REMIND runs on local machines have been conducted using this tutorial.

## System Requirements

- Installed python version must be `3.10.X` or older. To check your python version run `python --version` in a terminal of your choice
- GAMS must be installed and the path to GAMS applications needs to be in your PATH environment variable
- R version must be at least `4.2.X`. To check your R version run `R --version` in a terminal of your choice
- On Windows we recommend to use PowerShell rather than the standard command prompt

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

### MAGCFG_STORE File Path Resolution Fails in `prepare.R`

*Telltale sign* Function `prepare()` in `prepare.R` is unable to resolve the file path to `MAGCFG_STORE`, ie. the location where MAGICC configurations are stored. The error message reads:

```
Error in prepare() :
  ERROR in MAGGICC configuration: Could not find file  ./core/magicc/MAGCFG_STORE/MAGCFG_USER_OLDDEFAULT.CFG
```

This bug might be specific to Windows systems and is still under investigation. However, there is a

*Solution* Locate lines

```R
magcfgFile = paste0('./magicc/MAGCFG_STORE/','MAGCFG_USER_',toupper(cfg$gms$cm_magicc_config),'.CFG')
[...]
system(paste0('cp ',magcfgFile,' ','./magicc/MAGCFG_USER.CFG'))
```

in file `<REMIND_DIR>/scripts/start/prepare.R` (around line numbers 680ff). Replace them with

```R
magcfgFile = normalizePath(paste0('../../core/magicc/MAGCFG_STORE/','MAGCFG_USER_',toupper(cfg$gms$cm_magicc_config),'.CFG'))
[...]
system(paste0('cp ',magcfgFile,' ','../../core/magicc/MAGCFG_USER.CFG'))
```

and then restart your run.

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
Rscript start.R &>> ~/failed_REMIND_run.log
```

or on Windows via

```PowerShell
Rscript.exe .\start.R *>> ~/failed_REMIND_run.log
```

This writes *all* output from your run to a file in your home directory called `failed_REMIND_run.log`. After hitting enter in your terminal session, none of the usual output will show up since it is being redirected into the aforementioned file. You can still follow the progress of your run by opening a second terminal window and type in

```bash
tail -n 25 -f ~/failed_REMIND_run.log
```

on Linux or

```PowerShell
Get-Content ~/failed_REMIND_run.log -Tail 10 -Wait
```

on Windows. In case you need to interact with the run script during execution (ie. when selecting the run mode) you can still do so in the terminal session from which you started the run.
