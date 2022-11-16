# Running REMIND locally
Mika Pflüger (mika.pflueger@pik-potsdam.de)

*Note:* This tutorial is a work in progress, not all steps needed are described, yet.

## Download Input Data Automatically

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

## Use Local Input Data

If you don't have access to the PIK cluster, but have input data available locally, you have to provide the corresponding path via environment variables.
Add to your local `~/.Renviron` file (in linux, found in your home directory, in windows, found at `C:\Users\<your windows username>\Documents\.Renviron`):
```bash
# REMIND data setup
# If the input data is spread over multiple directories,
# separate them with a : on linux, a ; on windows
REMIND_repos_dirs="/my/first/path:/my/second/path"
# On windows, it would look something like
# REMIND_repos_dirs="C:\Users\<your windows username>\REMIND;D:\REMIND"
# depending on your used file paths
```
