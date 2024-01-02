# Using Python to Interface with Other Models
Mika Pflüger (mika.pflueger@pik-potsdam.de)

## Introduction

To interface with other models or libraries, it is often necessary to call Python code because the model itself is written in Python or bindings are available in Python.
REMIND has Python support via [reticulate](https://rstudio.github.io/reticulate/) using virtual environments, but it is disabled by default.

## Using Python in REMIND

First, you have to make sure that you have Python installed and available in your environment.
Run `Rscript scripts/utils/checkSetup.R` to check if REMIND finds your Python.
If not, repair that by installing Python and making sure it is on your PATH.

Next, you have to enable REMIND's Python integration by setting `cfg$pythonEnabled` to `on` in `config/default.cfg`.

Add Python libraries you want to use to the `requirements.txt` file in the main remind folder.
They will be installed into the Python virtual environment on the next start of REMIND.

Then you can use Python via [reticulate](https://rstudio.github.io/reticulate/).
For example, execute an R script from GAMS, then use `reticulate::import` to import Python libraries, the python virtual environment will automatically be used.
