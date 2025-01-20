Install the REMIND model and all requirements
================
Anastasis Giannousakis (<giannou@pik-potsdam.de>), Felix Schreyer (<felix.schreyer@pik-potsdam.de>), Pascal Führlich (<pascal.fuehrlich@pik-potsdam.de>)
16 June, 2022

REQUIREMENTS
------------

**Please note: You need input data to run REMIND. At present, there are still legal issues with sharing this data, so we can not publish them yet (but we are working on it, please bear with us). If you have access to the necessary data sources (IEA, etc.) you can generate the input data on your own, we are happy to assist you in doing so.**

- input data
- git
- GAMS >= 39.1.0 with CONOPT license
- R >= 4.0. We recommend R 4.3.2.
- Windows only: RTools
- LaTeX
- pandoc
- For non-default configurations: Python >= 3.7 for coupling to other models (no Python couplings in current official versions, will change in the future)

HOW TO INSTALL
--------------

To get the REMIND code first install git (<https://git-scm.com/downloads>).
It is recommended to fork REMIND on your github user account.
Then, on the PIK cluster, you can clone it using:
```bash
cloneremind https://github.com/yourusername/remind.git [remindfolder]
```
If you do not specify `[remindfolder]`, it uses `remind`.
If you are not on the PIK cluster, to get the latest REMIND release:
```sh
git clone -b master --filter=blob:limit=1m https://github.com/remindmodel/remind.git
```
To get a specific REMIND release (e.g. 2.2.0):
```sh
git clone -b v2.2.0 --filter=blob:limit=1m https://github.com/remindmodel/remind.git
```
To get the latest development version (might be unstable):
```sh
git clone --filter=blob:limit=1m https://github.com/remindmodel/remind.git
```

REMIND requires *GAMS* (<https://www.gams.com/>) including licenses for the solvers *CONOPT* and (optionally) *CPLEX* for its core calculations. Please make sure that the GAMS installation path is added to the PATH variable of the system:

- the easiest way to add is by simply checking the "Use advanced installation mode" box at the beginning of the installation. At a later step you have to tick again a checkbox that adds the GAMS path to your PATH variable
- you can also edit your computer's advanced settings and add the GAMS path to the PATH variable manually (applies also if GAMS is installed but not included in PATH).

This tutorial shows how to check and add variables to your PATH variable: <https://www.youtube.com/watch?v=5P9EDJwfXBo>

Please add the GAMS training license you have been provided (gamslice.txt) by saving the file to your local GAMS folder. Under Windows something like `C:\Program Files (x86)\GAMS\<version number>`

In addition, *R* (<https://www.r-project.org/>) is required for pre- and postprocessing and run management (needs to be added to the user's PATH variable as well). It is recommended to also install RSudio (<https://www.rstudio.com>).

On Windows you need to install [Rtools](https://cran.r-project.org/bin/windows/Rtools/) and add it to the system PATH variable.

For some types of REMIND output post-processing, LaTeX (<https://www.latex-project.org/get/>) and pandoc (<https://pandoc.org/installing.html>) are required. Make sure the executable "pdflatex" is added to the PATH variable of your system.

Navigate to the REMIND folder that you cloned earlier. Always start R scripts and sessions related to REMIND from this path. Do not set the environment variable R_PROFILE_USER, otherwise the REMIND package environment (renv) is not correctly loaded. To install all required R packages and check if your system is ready to run REMIND execute the following:

```sh
Rscript scripts/utils/checkSetup.R
```
