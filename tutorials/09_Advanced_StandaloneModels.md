# How to use the standalone model framework

## Standalone models

Standalone models can be used to run simulations which only require a subset of REMIND code. This is a loosely-defined framework which can be used in a variety of ways. For example, a standalone model can run a single, existing module realization as a partial equilibrium problem isolated from the rest of REMIND. Contrarily, they can also be a combination of several REMIND modules with several optimization problems or a sub-component of a module realization with only dummy calculations to solve rather than an optimization.

### General Steps

A new standalone model is created by creating a new directory *NewModel* within the **standalone** folder of REMIND, then copying the *template.gms* file into the new folder and renaming it as "*NewModel.gms*", replacing *NewModel* with the name of your new standalone model.

**MODULES:** 
In the current implementation, *template.gms* declares the realization to use for each module via a `$setGlobal` command. Make changes as necessary to specify the default realization to use for the module `!! def = YourChoice`. However, the actual realization here will be overwritten by config settings, so be sure to specify your new defaults in the *scenario_config.csv* file.

**SWITCHES and FLAGS:** 
The template also contains all switches and flags from *main.gms*. It is wise to first replace these with those from the most recent trunk version of *main.gms*. Be sure to change the `$title` and any default switch positions accordingly.

**SETS and DECLARATIONS:** 
The template by default includes all sets and declarations from REMIND using `$include` and `$batinclude` statements.

`$include` statements can be used to add whole REMIND files into your new model.

`$batinclude "./modules/include.gms"  filetype` statements can be used in conjunction with the pre-existing REMIND infrastructure of *include.gms* and *module.gms* files to add the "*filetype.gms*" file from the above-declared realizations of **all** modules.

Also included by default in the SETS section is the *core/sets_calculations.gms* file.

It is not recommended to make any changes to SETS and DECLARATIONS since the memory footprint of these objects is minimal and temporary.

**MODEL DEFINITION & SOLVER OPTIONS:** 
It is advisable to work "backwards" from this point on. If the model to be implemented here is relatively small and well-defined, use this section to list all the relevant equations for the optimization problem: 

``` gams
model NewModel / q_example1, q_example2 /;
```

If the model is more complex and involves more equations than can reasonably be listed manually, substitute the equation list with `/ all /`. In this case, you will have to be more careful in the EQUATIONS section.

If the model is already defined within a module realization, it is also acceptable to simply `$include` that file instead of explicitly defining the model here. 

**SOLVE:** 
The solve statement must look like this: `solve NewModel using nlp` if optimizing a non-linear programming problem. Replace *nlp* with *cns* if instead the model is to solve a constrained non-linear system. *nlp* and *cns* are global variables defined in the SWITCHES and FLAGS section above, which by default depend on the global variable *cm_conoptv*. The former variables can be changed directly in your file, while the latter can only be changed through config. If the solve statement already exists within a module realization, it is also acceptable to simply `$include` this file. 

**EQUATIONS:** 
If the model definition lists all the relevant equations, it is safe to `$include` equations from **core** and from all relevant modules like so: `$include "./modules/00_EXAMPLE/realization/equations.gms";`

It is not recommended to `$batinclude` equations from all modules because this would require initialization of all variables and parameters, a fairly significant burden on memory and runtime. 

**DATAINPUT and BOUNDS:**
All variables and parameters involved in the equations need to be initialized in the DATAINPUT section, and relevant bounds need to be defined for some variables. It is advisable to `$include` the *datainput.gms* and *bounds.gms* files from **core** and all relevant modules. **Note** that if *core/bounds.gms* is indeed included, then the *datainput.gms* and *preloop.gms* files from certain modules are necessary dependencies and included by default in *template.gms*.

**PRELOOP, PRESOLVE, POSTSOLVE, OUTPUT:**
Based on the model equations and the standalone model's purpose, determine for yourself whether to `$include` these files from **core** and/or the relevant module realizations. It is perfectly acceptable for these sections to be empty, with the possible exception of the *preloop.gms* files which provide input to *core/bounds.gms*.


### Note

The standalone model file needs to follow the coding etiquette as any other file, meaning that it is only allowed to interact through interfaces with the modules. 
This is necessary to allow the reduced model to work with all realizations of a coupled module.


### How to Run

For running a standalone model two options exist:

**Run with R**: 
You can start a standalone model in the same manner as the main REMIND model by providing a scenario_config file to the start_bundle function (Or without a scenario_config via start.R).

There are a just a couple minor differences:

**scenario-config**: it is recommended to create a new `.csv` file tailored to your model, including the following:
* Add a column named **model** and set this to your standalone model's filepath (e.g. standalone/NewModel.gms). This tells the start_functions to run the standalone model instead of main.gms. 
* Add a column named **output** and set this to your new reporting file(s) (e.g. reporting_NewModel,validationSummary)
* **IF** running with start.R, edit **default.cfg** instead: set **cfg$model** to your model's filepath and **cfg$output** to your reporting file (e.g. c("reporting_NewModel","validationSummary"))


Everything else works as usual (output folder is created, full.gms is written, job is submitted to SLURM,...)



**Run with GAMS**

* You can run a standalone model from the main folder of the REMIND model by simply providing the filepath (e.g. `gams standalone/demand_model.gms`).
* This will generate output directly in the main folder and is especially useful for testing and debugging.
* However, note that each new run will overwrite the output from the previous run unless the existing files are moved or renamed.


### Unit test models (not yet implemented in REMIND)

Test models can be used to check whether certain model components work as expected. They contain small test cases which check for the desired function.

Technically they are identical to standalone models except for the following:

* test models must be stored in the folder "tests"
* test models must have an abort statement in it for the case that the test fails and should otherwise end without error. This is important as the success of a test will be measured with the exit code of the model run
* test models should run quickly
* test models ideally should not require any additional input files
