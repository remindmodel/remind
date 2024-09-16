Debugging REMIND
================
Collaborative effort, coordinated by Oliver Richters, March–May, 2022

When running and changing REMIND, a multitude of errors may occur. In such a collaborative effort, they need not have been created by you. So an important part of debugging is to find out whether something you changed created the error, or whether there is a general problem. The `develop` branch is permanently developed and may temporarily contain bugs, so use a release instead.

First, find out the state of your run by executing this in the run directory:
```bash
Rscript -e "modelstats::loopRuns('.')"
```
PIK cluster users can access information on all their runs in all directories by executing `rs2 -c` (or `rs2 -a` for only active runs).
If you want information on all (or some) runs in a given output folder, no matter who ran them, simply type `rs2` and then select either `1` for all runs or just the runs you want information about.

This tutorial should help you if REMIND (1) [did not start](#case-1-remind-did-not-start), (2) [did produce an error](#case-2-remind-did-produce-an-error), (3) [ran into infeasibilities](#case-3-remind-ran-into-infeasibilities) or (4) [did not converge](#case-4-remind-did-not-converge).

You can [start a debug run](#more-information-needed-debug-runs) and [spy on the solver](#spy-on-the-solver) to get further information, and feel free to [ask for help](#asking-for-help).

Case 1: REMIND did not start
----------------------------

The first place to look is `log.txt` in the output subfolder for each run. It shows you the log of running [`prepareAndRun.R`](https://github.com/remindmodel/remind/blob/develop/scripts/start/prepareAndRun.R). If it states "Starting REMIND..." somewhere, this shows that the input preparation scripts were successful. If not, this can be caused by the following reasons:

- the model is still locked? Another model run has locked the folder, so you have to wait until it has unlocked it again.
- input files are missing or outdated? delete `input/source_files.log` or set `cfg$force_download <- TRUE` to force the loading of new ones. If this doesn’t help, the input generation may be broken.
- you use an outdated git branch? check `git log` or use main branch with `git checkout main/develop; git pull`.
- a recent change in the start scripts may have broken the prepare scripts, check the [file history](https://github.com/remindmodel/remind/commits/develop/scripts/start/) for changes.

Case 2: REMIND did produce an error
-----------------------------------

In this case, after "REMIND run finished!", you find a short "Model Summary", where the script looks for some files in the output subfolder and gives you its interpretation which is helpful for knowing were to look next:
```
  gams_runtime is 10.6 hours.
  full.gms exists, so the REMIND GAMS code was generated.
  full.log and full.lst exist, so GAMS did run.
! abort.gdx exists, containing the latest data at the point GAMS aborted execution.
  fulldata.gdx exists, so at least one iteration was successful.
  Number of iterations: 14
  Modelstat: 4
! full.log states: *** Status: Execution error(s)
```

If gams_runtime was short (say: up to 10 minutes), this implies an error right at the beginning of the run.
If full.gms does not exist, it is an error in the preparation script, not in GAMS.

If full.log exists, this is the next place to look at. Either open it in your favorite text editor or use the console, change directory to the output subfolder and type:
```bash
less full.log
```
and then type `G` to get to the end of the file. Type `q` to close the file.
Another option is to use the editor `vi` by typing `vi full.log`, in which case `:q` closes the editor. `less` is generally faster when looking at large file, but doesn’t offer color coding.

You may find:

### Case 2a: compilation errors

These are errors in the GAMS code. Have the next look at

```
less full.lst
```
Hit `G` to go to the end of the file and search backwards for errors whose lines start with four asterisks by typing:
```
?^\*\*\*\*
```
(You can also use `vi full.lst`, and if you add `map f /*\*\*\*<CR>` to your `/home/username/.vimrc` file, you can simply press `f`, which overwrites the search for single characters. In text editors such as `notepad++`, search for `****`).
Going upwards to the next matches using `N`, you should eventually find an error message (`n` searches downwards).
The error is indicated directly at the point in the code where it occurs.
It is worth looking at the `.gms` file this equation is part of, by searching for `SOF` (start of file) and `EOF` (end of file) marks above and below the equation.
For fixing this error, the [section on compilation errors in the McCarl GAMS Guide](https://www.gams.com/mccarlGuide/fixing_compilation_errors_1.htm) may be helpful.

You can either fix the error directly in the corresponding REMIND model file, or in `full.gms` in the output folder.
In the first case, the PIK cluster provides the command `gamscompile` that can be run in the REMIND folder to see whether the change fixes the compilation error.
Then, you can recreate the `full.gms` with running
```
Rscript start.R --reprepare
```
and selecting the run with the error. If you fix the code in the `full.gms` file (and only later transfer it to the REMIND directory), you can restart the run without the prepare part by running
```
Rscript start.R --restart
```

### Case 2b: execution errors

For execution errors, again try to identify the location of the error in the `full.lst` file.
If it points to a specific line number where the error occured, mark this number, then type `?` and paste it into the editor which is then searching backwards for this number, and typing `n` (eventually multiple times) should bring you to the source code part at the beginning of the file.
You should now see the equation where the error was created. If you recently changed this equation, this may have caused the error.
Again, tutorials such as as the [McCarl GAMS User Guide](https://www.gams.com/mccarlGuide/) may be helpful.
If not, it is worth looking at the `.gms` file this equation is part of, by searching for `SOF` (start of file) and `EOF` (end of file) marks above and below the equation. Then navigate to this file in github and see in the history whether it was recently changed, which may have caused this error.
But it is important that the error may have first appeared in this equation, but may have been caused somewhere else.

If you find out that your run stopped specifically in iteration 14, you likely have a problem with the EDGE-T transport model. It runs iteratively with REMIND, but only after iteration 14. It calls [`edgeTransport::iterativeEdgeTransport()`](https://github.com/pik-piam/edgeTransport/blob/master/R/iterativeEDGETransport.R) and its input/output data are in the `EDGE-T` subfolder. You should find an error message in `log.txt`.
If this is not helpful, try opening that script in an interactive `R` session (on your run’s folder) and run it line by line, you’ll have a better idea of what the problem actually was. Forcing the model to redownload its input data (see above) can help if something in either model changed when you created that folder.
Also make sure that the R packages installed in your renv are up-to-date. The EDGE-T model makes heavy use of specific libraries that are updated constantly. So you’ll often find that a newer EDGE-T library won’t work with a REMIND folder that is even a few days old.

The file `abort.gdx` contains the latest data at the point GAMS aborted execution, which can be analysed using GAMS Studio.

After a certain number of consecutive infeasibilities (default: `cm_abortOnConsecFail` = 2) REMIND will switch to the debug mode in which infeasibility are listed (and can be shown with `listinfes`).
In case this does not help, it stops automatically, to avoid loosing too much time on an already doomed run. While REMIND sometimes is able to recover from a region being infes for 1 or 2 iterations, more will likely mean that the run will fail. In this case an `execution error` will be raised and the message `Run was aborted because the maximum number of consecutive failures was reached in at least one region!` can be found in the `full.log` and `full.lst` files. Continue with "Case 3" to solve the infeasibility.

### Case 2c: GDX or R file missing

Try to find out where this file should have come from by searching within the REMIND repository. Again, having a look at `full.lst`, searching for the filename and looking for `SOF` and `EOF` may help.


Case 3: REMIND ran into infeasibilities
---------------------------------------

If some infeasibility was created, the next suggested step is to search for `p80_repy` in `full.lst` and how it changes over the iterations.
On the PIK cluster,
```bash
nashstat -a [folder]
```
or just `nashstat -a` in the folder provides an overview, with a short extract also found in `log.txt`.
It is worth looking at this information already while the model is running to see whether the model runs smoothly.
An explanation of the modelstat and solvestat numbers can be found in the tables below:

|model   status in GAMS | |
|--- | ---|
|Modelstat = 1 | Optimal|
|Modelstat = 2 | Locally Optimal|
|Modelstat = 3 | Unbounded|
|Modelstat = 4 | Infeasible|
|Modelstat = 5 | Locally Infeasible|
|Modelstat = 6 | Intermediate Infeasible|
|Modelstat = 7 | Intermediate Nonoptimal|
| | |
|Solvestat = 1 | Normal Completion   |
|Solvestat = 2 | Iteration Interrupt |
|Solvestat = 3 | Resource Interrupt  |
|Solvestat = 4 | Terminated by Solver|

|Desirable Status in REMIND|
|---|
|Solve + Model stat = 1 + 2 | solution found|
|Solve + Model stat = 4 + 7 | feasible but slow convergence|

Further possible error codes can be found in [the GAMS documentation](https://www.gams.com/latest/docs/UG_GAMSOutput.html#UG_GAMSOutput_SolverStatus).
If infeasibilities show up already in the first iteration, it may be related to a wrong `input.gdx` (specified with `path_gdx` in the `scenario_config_XYZ.csv`) or some general error in the GAMS code. Via the international trade, infeasibilities in one region may propagate to other regions in later iterations, but then it is worth knowing where it started.

There are different types of solver infeasibilities: pre-triangular and optimization infeasibilities. In pre-triangular infeasibilities, GAMS shows you in the solution report the equations that are incompatible with each other. For optimization infeasibilies, the CONOPT solver tries to reduce the infeasibility to the thing that less affects the objective function. It does not show all affected equations, as it is not a simple problem as a non-square system of equations like in the pre-triangular case. You need to check if it is bound-related: the variables bounds, and the equation bounds starting from the infeasibility and going through the variables that have relation with it. You can always force in another run the variable that is infeasible to a feasible value to see what else is affected by it. But this is usually not necessary as just checking the logic behind the equation and the infeasible variable is usually sufficient to find the limitation.

Case 4: REMIND did not converge
-------------------------------

If the iterations are not sufficient to converge, you will see in the output of `rs2 -c` that `RunStatus` is `Normal completion`, but `Conv` shows `not_converged`.

You can run
```
less -j 7 +?diagnostics full.lst
```
in your output subfolder to see the "Convergence diagnostics" of the last iteration (`+?diagnostics` searches for the last occurrence of `diagnostics`). Below, you should find reasons for non-convergence.

If trade is the issue, search with `?p80_messageFailedMarket` to see how the failed markets evolved over the iterations. Looking at `p80_defic_sum_rel` will show you how the sum over all market imbalances developped over the iterations. Often, it improves a lot until iteration 20-30, then either converges or becomes worse again for 10-30 iterations, before improving again for 10-20 iterations, then becoming worse again. One can look which iteration in the range 20..35 was best, then go back to that iteration by searching backward for `o_iterationNumber` to check which markets were above the threshold then, comparing the values plotted below `p80_surplusMax2100` with `p80_surplusMaxTolerance`.

If the run was mostly converged in that iteration (which depends on your standards, an example would be `p80_defic_sum_rel` < 0.02), one can set `cm_nash_autoconverge` to `3`, which relaxes the requirements on market clearing further. This should then lead to the restarted run actually converging in that iteration.
You should not use this setting for production runs.
You can also run REMIND for more iterations by modifying `cm_iteration_max` in [`80_optimization/nash/datainput.gms`](../modules/80_optimization/nash/datainput.gms) and the set iteration in [`core/sets.gms`](../core/sets.gms), which by default only goes to 200.

In the output subfolder, you also find a file `nash_info_convergence.csv` which contains the price and surplus information for the relevant markets for all iterations and time-steps:
- `p80_surplus`, the "surplus on commodity markets"
- `p80_pvp_itr`, the "price on commodity markets"
- `p80_surplusMax_iter`, the "worst residual market surplus until given year, absolute value", with units: TWa, trillion Dollar, GtC.
- `p80_surplusMaxRel`, the "worst residual market surplus until given year, in per cent".

More information needed? debug runs
-----------------------------------

If you would like GAMS to print specific information, add a `display` statement as close to the solve statement as possible, i.e., in presolve, or right after the data is loaded in datainput, and use `Rscript start.R --reprepare` to regenerate the `full.gms` file and restart the model, or change `full.gms` directly and restart the folder with `Rscript start.R --restart`.

If this is not sufficient, you may start a "debug" run which is more generous in logging. It runs on one single node only instead of the parallel mode with one node per region, which can take a lot of time.

To restart a run in "debug" mode, run
```bash
Rscript start.R --debug --reprepare
```
in the REMIND main folder and select the runs to be restarted (the shortcut is `Rscript start.R -dR`). This will move `full.gms` and `fulldata.gdx` to filenames with an appended `_beforeRestart` and restart the input preparation and the model run.

If you only want to look at a specific region that created the infeasibility, you can either specify `c_testOneRegi_region` in `scenario_config_XYZ.csv`, or choose the region in interactive mode:
```bash
Rscript start.R --debug --interactive --testOneRegi scenario_config_XYZ.csv
```
and you will be asked which region you want to look at (the shortcut is `Rscript start.R -di1` + the file name).
You can also run `Rscript start.R --reprepare --debug --testOneRegi` to get the results in the same output folder.
Running `Rscript start.R --reprepare` a second time then resets the settings to the original ones.
The scripts will then start the debug run based on the `fulldata.gdx` that contains the data from the last successful iteration.
Alternativly, you can point to this file in the `path_gdx` column of `scenario_config_XYZ.csv`.
If you want to compare the different gdx files produced by all iterations, specify `c_keep_iteration_gdxes = 1` in `main.gms` or the `scenario_config_XYZ.csv`.

Once the debug run is finished you have access to a `full.lst` with extended logging. The tool `listinfes` will show you the infeasibilites which might be responsible for the run failing:

```bash
listinfes <path_to_full.lst>
```

Spy on the solver
-----------------

If you want a closer look on the GAMS CONOPT output during a REMIND run, users of the PIK cluster can use `conoptspy` to display the latest additions to `gmsgrid.log`. Manually, you can access the solver logs by moving to the output folder and running:

```bash
find -name gmsgrid.log | xargs tail -n 12
```
Note that `gmsgrid.log` is available only while CONOPT is working on this specific region and deleted as soon as it finishes (successful or otherwise).

Only the first five columns are of particular interest:

- `Iter`: CONOPT Iteration number.
- `Phase`: 0/1/2 means CONOPT is looking for a feasible solution, 3/4 means it is looking for an optimal solution.
- `Ninf`: if during phase 1/2, the number of infeasibilities.
- `Infeasibility/Objective`: The left hand side during search for a feasible solution, and the objective value during phase 3/4.
- `RGmax`: if during phase 1-2 the sum of infeasibilities, it should always converge to a very small value (< 10e-7). If during phase 3/4 the reduced gradient (when small you are close to optimality).
- `NSB`: the number of superbasic variables (basically the current number of degrees of freedom).

Displaying the CONOPT output multiple times will show you which regions are still being solved and if they are making progress. If `Iter` does not change between consecutive calls to `conoptspy`, then CONOPT crashed. If CONOPT is at unusually high iterations (> 10 000), and there is little or no progress in the objective value, and the reduced gradient does not change or oscillates between values without making progress, then CONOPT is stuck somewhere in the solution space and won’t get out.
In both cases, abort the run and restart from the `fulldata.gdx` (the last feasible solution) which can be done by running `./start.R -r` and selecting said run.

Asking for help
---------------

In any case, don’t hesitate to ask for help in [pik-piam/discussions](https://github.com/pik-piam/discussions). Please provide:

- which version of REMIND was used
- as much information on your run, such as the scenario config file and the run name
- PIK cluster users should supply the path on the cluster
- a summary of things you already checked or found out
- information on what you changed in the REMIND GAMS code
