Install the REMIND model and all requirements
================
Anastasis Giannousakis (<giannou@pik-potsdam.de>), Felix Schreyer (<felix.schreyer@pik-potsdam.de>)
16 February, 2020

**Please note: You need input data to run REMIND. At present, there are still legal issues with sharing this data, so we can not publish them yet (but we are working on it, please bear with us). If you have access to the necessary data sources (IEA, etc.) you can generate the input data on your own, we are happy to assist you in doing so.**

HOW TO INSTALL
--------------

To get the REMIND code you need to have git installed and then clone the model from <https://github.com/remindmodel/remind.git>. To get a specific release (e.g. 2.1.0) please type 

``` bash
git clone -b v2.1.0 https://github.com/remindmodel/remind.git 
```

REMIND requires *GAMS* (<https://www.gams.com/>) including licenses for the solvers *CONOPT* and (optionally) *CPLEX* for its core calculations. As the model benefits significantly from recent improvements in *GAMS* and *CONOPT4* it is recommended to work with the most recent versions of both. Please make sure that the GAMS installation path is added to the PATH variable of the system:

-   the easiest way to add is by simply checking the "Use advanced installation mode" box at the beginning of the installation. At a later step you have to tick again a checkbox that adds the GAMS path to your PATH variable
-   you can also edit your computer's advanced settings and add the GAMS path to the PATH variable manually (applies also if GAMS is installed but not included in PATH).

This tutorial shows how to check and add variables to your PATH variable: <https://www.youtube.com/watch?v=5P9EDJwfXBo>

Please add the GAMS training license you have been provided (gamslice.txt) by saving the file to your GAMS local folder. Under Windows something like `C:\Program Files (x86)\GAMS\28.2`

In addition *R* (<https://www.r-project.org/>) is required for pre- and postprocessing and run management (needs to be added to the user's PATH variable as well). It is recommended to install also RSudio (<https://www.rstudio.com>).

For R, some packages are required to run REMIND. All are either distributed via the offical R CRAN or via a separate repository hosted at PIK (PIK-CRAN). Before proceeding PIK-CRAN should be added to the list of available repositories via:

``` r
options(repos = c(CRAN = "@CRAN@", pik = "https://rse.pik-potsdam.de/r/packages"))
```

On Windows you need to install [Rtools](https://cran.r-project.org/bin/windows/Rtools/) and add it to the system PATH
variable. After that all required packages can be installed via `install.packages`:

``` r
pkgs <- c(
  "colorspace",
  "crayon",
  "data.table",
  "devtools",
  "dplyr",
  "edgeTrpLib",
  "flexdashboard",
  "gdx",
  "gdxdt",
  "gdxrrw",
  "ggplot2",
  "gms",
  "gridExtra",
  "gtools",
  "htmltools",
  "knitr",
  "lazyeval",
  "lucode2",
  "luplot",
  "luscale",
  "lusweave",
  "magclass",
  "magpie4",
  "mip",
  "mrremind",
  "mrvalidation",
  "optparse",
  "plotly",
  "quitte",
  "remind2",
  "reshape2",
  "rlang",
  "rmarkdown",
  "rmndt",
  "stringr",
  "tidyr",
  "tidyverse",
  "withr",
  "yaml"
)
install.packages(pkgs)
```

Updating R is recommended if problems arise at package installation, please write us at remind@pik-potsdam.de to discuss alternatives if this is not possible. For post-processing model outputs *Latex* is required (<https://www.latex-project.org/get/>). To be seen by the model it also needs to be added to the PATH variable of your system.

If the following lines of code are executed without error, then you are all set!

``` r
system("gams")
library(gdxrrw)
library(remind2)
print("")
if(.Platform$OS.type == "unix") {
  system('pdflatex -version')
} else {
  system("where pdflatex")
}
```

NOTE: If the model fails to start from the Windows console, try starting it from within RStudio.
