---
output:
  html_document: default
  pdf_document: default
---
Advanced: Change REMIND GAMS Code
================
Florian Humpenöder (<humpenoeder@pik-potsdam.de>), Lavinia Baumstark (<baumstark@pik-potsdam.de>)


Technical Structure
=====================
The REMIND-code is structured in a modular way. The technical structure looks as follows: at the top level you find the folders `config`, `core`, `modules`, and `scripts`. The overall structure is built in the file `main.gms`. All settings and configuration information are given in the `config` folder. The `core` folder contains all files that are part of the core of the REMIND model. For each module there exists a sub-folder in the `modules` folder. Helpful scripts for e.g. starting a run or analysing results you find in the `scripts` folder.

In the `main.gms` file the technical structure of REMIND can be found. First, the `*.gms` files from the core folder are included and afterward the `*.gms` files from the activated module realization, beginning with the one with the smallest module-number. The technical structure of REMIND looks as follows:

```
SETS

DECLARATION    ---> of equations, variables, parameters, and scalars

DATAINPUT

EQUATIONS

PRELOOP        ---> initial calibration of e.g. macroeconomic model

LOOP
        ---> read gdx
----------------------------------------------- BEGIN OF NEGISH/NASH ITERATION LOOP -----
      * BOUNDS
      * PRESOLVE
      * SOLVE     ---> solve statement in module 80_optimization
      * POSTSOLVE
      
        ---> write gdx
----------------------------------------------- END OF NEGISHI/NASH ITERATATION LOOP ----

OUTPUT
```

In general, the `.gms`-files in each module realization can be the same as in the core. For each module it has to be clearly defined what kind of interfaces it has with the core part of the model.

Coding Etiquette
==================
The REMIND GAMS code follows a Coding Etiquette (found in the beginning of the file `main.gms`) Please read it before proceeding.

How to make a new module or realization in REMIND
========================================================

If you want to create a **new module** in REMIND first think about the interfaces between the core code and your new module. This helps you to design your module. 

For creating a new module you can use the function `module.skeleton` from the R package `gms`. Start R and set the working directory to the REMIND folder (e.g. `setwd("~/work/remindmodel")`). 

``` r
gms::module.skeleton(100, "bla", c("on", "off"))
```

It creates all folders and gams files for your new module `100_bla` with the realizations "on" and "off". You can find more information about the function `module_skeleton` in its documentation.

For creating a **new realization** of an existing module you can also use the R function `gms::module_skeleton`. Start R and set the working directory to the REMIND folder (e.g. `setwd("~/work/remindmodel")`).

``` r
gms::module.skeleton(100, "bla", c("on", "off", "new"))
```
It creates all additional gams files for your new realization "new" of the existing module `100_bla`. You can find more information about the function `module_skeleton` in its documentation.

After you have created all of your new files and lines for the new module or realization you have to add the description of this new feature in the `main.gms` by hand.

Compiling and Testing
=====================

If you want to quickly check if the model including your changes compiles without running the model, start
```
Rscript start.R -gi
```
and select runs which will be compiled.

Before submitting the code changes to the REMIND repository, it is recommended to run `make test` on the command line.
It performs a collection of tests including compiling the model, a minimal run of the default configuration with relaxed convergence requirements, and checking for violations of the coding etiquette. If the checking of the coding etiquette `99-codeCheck` uncovers violations, you can use `make check-fix` to automatically fix some common errors. In particular, it may ask you some questions about the `not_used.txt` files in each realization that contain the parameter names that are used somewhere in this module, but not in this specific module realization.

The automated tests do not contain a full run of the model by default. To include a full run in the tests, run `make test-full` and compare the output of a model with and without your changes. The standard run is useful to check changes in the default configuration and is recommended if you changed the model such that the output might change significantly. If you change a specific non-default configuration (e.g. a non-default module realization), you should also do specially tailored runs to compare the output of the model using the configuration you changed.
