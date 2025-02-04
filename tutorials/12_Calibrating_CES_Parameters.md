# Calibrating CES Parameters

## CES Production Function Basics

REMIND uses a nested CES production function of the form

$V_o = \left( \sum\limits_i{\alpha_i {V_i}^{\rho_o}} \right)^{\frac{1}{\rho_o}}$

with output quantity $V_o$, input quantities $V_i$, elasticity parameter
$\rho_o$, and efficiency parameters $\alpha_i$. \
The top-level output is the
macroeconomic output (GDP, `inco`), and the inputs can be either intermediate
production factors, that are themselves outputs of a lower level of the CES
function (hence nested), or primary production factors (`ppf`) that are linked
to the energy system model or macro parts of REMIND.

In a REMIND run, the quantities $V$ are free (within the constraints of the
scenario) and subject to the optimisation. The substitution parameters $\rho_o$
are fixed manually, and the efficiencies $\alpha_i$ are fixed during calibration.

The purpose of the CES calibration is to find efficiency parameters $\alpha_i$
such that the quantities $V$ are matched as well as possible.
Calibration is done for a baseline scenario where input and output quantities
derive from a choice of drivers (like SSP2) and a particular input data revision.
Therefore,

> **Anytime either the REMIND model or the input data change in a way that affects
the results of a baseline scenario, that baseline scenario needs to be calibrated.**

## Iterative Calibration

As it is not possible to calculate $n$ parameters $\alpha_i$ from a single
equation, we use an iterative approach.  The
[Euler identity](https://en.wikipedia.org/wiki/Homogeneous_function#Euler's_theorem)
asserts that, for homogeneous functions of degree one, the function value is equal
to the sum of the partial derivatives times the function arguments:

$V_o = \sum\limits_i{\frac{\partial V_o}{\partial  V_i} V_i}$

We are not seeking a general analytical solution, but only need to calculate
values at specific points for the iterative process. Thus, we can express the
partial derivatives in terms of the input and output quantities:

$\frac{\partial V_o}{\partial  V_i} = \alpha_i {V_i}^{\rho_o - 1} {V_o}^{1 - \rho_o}$

Since the final output of the production function $V_o$ is also the numéraire
(e.g. the unit – U.S. dollars – in which inputs are measured), the partial
derivatives are the equilibrium prices, noted $\pi_i = \frac{\partial V_o}{\partial  V_i}$.
This allows rewriting the efficiency parameters $\alpha_i$ in terms of quantities, prices,
and elasticity:

$\alpha_i = \pi_i \left(\frac{V_i}{V_o}\right)^{1 - \rho_o}$

The basic process of the calibration is to use the price calculated using the
partial derivatives of iteration $j$ and combine them with the exogenously
prescribed target quantities $V^\ast$ to calculate the efficiency parameters of
the next iteration $j+1$:

$\pi_i^{(j)} = \alpha_i^{(j)} {V_i^{(j)}}^{\rho_o - 1} {V_o^{(j)}}^{1 - \rho_o}$

$\alpha_i^{(j+1)} = \pi_i^{(j)} \left(\frac{V_i^\ast}{V_o^\ast}\right)^{1 - \rho_o}$


## Requirements

For the calibration process to work, we need 

1. trajectories for all primary production factors (`ppf`, final energy and
   energy service demands, labour, capital) and the output (GDP), and
2. the previous iterations' `ppf` prices.

Trajectories under (1) come from the input files `./core/input/f_gdp.cs3r`,
`./core/input/f_pop.cs3r`,
`./modules/29_CES_parameters/calibrate/input/f29_capitalQuantity.cs4r`, and
`./core/input/f_fedemand.cs4r` which are generated automatically as part of the
input data generation and always present.

Prices under (2) are calculated using the `input.gdx` provided to the
calibration run.  User intervention is only required when prices cannot be
derived from the `.gdx` file in case of a change in the CES structure:
when nodes have been added or removed from the CES tree 
(technically when the set `cesOut2cesIn` differs between `input.gdx` and the
current calibration run), or seldom in cases of convergence problems.


## Settings

To set up a CES calibration run, simply set module 29 `CES_parameters` to the
`calibration` realisation.  All data relevant to the calibration is configured
according to the selected scenario configuration.  Keep them identical to the
baseline scenario you want to calibrate.
If your calibration depends on new input data, you need to update the configuration.
Use the command `lastrev` to find the latest input data revisions on the cluster.
If your choice is _rev1.23abc_, update the following line of the configuration file
`./config/default.cfg` (without _rev_ and always with quotation marks):

```R
cfg$inputRevision <- "1.23abc"
```

The calibration can further be adjusted using the following switches:

- `c_CES_calibration_iterations` (default = 10): Number of CES calibration
  iterations (iterative adjustments of $\alpha_i$ parameters, see above).
  There is no convergence criteria, so check the calibration quality manually
  afterwards.  More iterations generally lead to better convergence but longer
  runtime, as each iteration is an additional REMIND run: select an appropriate
  slurm configuration to allow for longer runtime, usually more than 24 hours.
- `c_CES_calibration_new_structure`: Switch to set a default price for the
  primary production factors instead of deriving prices from a `.gdx` file.
  If the structure of the CES tree has changed, this switch is necessary
  otherwise the calibration aborts.
  The switch also allows forcing specific prices in the first CES calibration
  iteration. Do not use it unnecessarily.
- `cm_CES_calibration_default_prices` (default = 0.01): Default price to be used
  when `c_CES_calibration_new_structure` is set.  The price is not
  differentiated by period, region, or production factor.  When the price is far
  from the equilibrium prices, calibration takes longer or shows poorer convergence.
  Errors can occur if prices are too high.
- `c_CES_calibration_write_prices`: Writes the prices (calculated as partial 
  derivatives on the CES production function) into the file `pm_cesdata_price`.
  Can help finding a suitable value for `cm_CES_calibration_default_price`.


## Results

The CES calibration outputs a `.gdx` file and an `.inc` file with all
the CES parameters.  Their long name, for instance
`indu_subsectors-buil_simple-tran_edge_esm-GDPpop_SSP2-En_SSP2-Kap_debt_limit-Reg_62eff8f7`
indicates the CES configuration, the GDP/population scenarios, the capital market
module realisation and the [region configuration](17_Regions.md)
(_62eff8f7_ for H12, _2b1450bc_ for EU21).
You don't need to change these names, they are matched automatically using the
switch `cm_CES_configuration`.  The parameter files also include a counter for
the calibration iteration they resulted from (e.g. `_ITERATION_10.inc`).

Calibration results can be included the PIK calibration repository (for use by
all REMIND users), or used in a local directory (e.g. for project work).

1. Prepare the calibration directory:
  - To include calibration results in the PIK calibration repository, navigate to
  `/p/projects/remind/inputdata/CESparametersAndGDX/`.
  - For use in a local directory, go to your local REMIND folder and type
    `make set-local-calibration`. Navigate to the newly created folder `calibration_results/`.
2. Use the `collect_calibration` script with one ore more paths to the completed
   calibration run directories as a parameter, for instance:
   ```sh
   ./collect_calibration /p/tmp/username/Remind/output/SSP2-calibrate_2024-12-31_23.59.59/
   ```
    Note that an absolute or relative path may be used. 
    The script copies the necessary `.inc` and `.gdx` files to the repository
    (adjusting the file names as needed), stages and commits them; you may review and
    modify the commit message before committing (or abort with `:cq` in vim).
    The script then generates a `.tgz` archive, which is what REMIND will be looking for
    in order to run.  Finally it displays the commit hash and offers to include it as the
    `CESandGDXrevision` in the REMIND configuration.
3. If the specific calibration settings (`cm_CES_configuration`) have never been 
calibrated and used in REMIND before, add the name of the `.gdx` file to `./config/gdx-files/files`
and add the name of the  `.inc` file to `./modules/29_CES_parameters/load/input/files`, so that the
new calibration results are copied into these directories during run setup.



## Diagnostic and validity 

To diagnose the outputs, you may use the `full.log` and `full.lst` files for each
calibration iteration (`full_01.log` …), the file `CES_calibration.csv`
containing all the relevant calibration parameters (inputs and outputs) for all
iterations for automated analysis. You can also generate a pdf report with plots of
quantities, prices, and efficiency parameters over regions, production factors, and time:
type `Rscript output.R`, select option _reportCEScalib_ and look at 
`CES_calibration_report_<scenario_name>.pdf`.

To check the validity of a CES calibration run:

1. Check there are no errors:
   - Did the prescribed number of CES calibration iterations (ten by default) finish?
   - Did the last CES calibration iteration converge?
   - Where there no GAMS errors (in the `full.log` and `full.lst`)?
2. Check the convergence of the calibration:
   - In `CES_calibration_report_<scenario_name>.pdf`, do the quantities converge
     (sufficiently) towards the target values?  There is no fixed level of
     "sufficient" convergence: use personal judgment.
   - If derived production factor prices are so high that the value (quantity
     times price) of inputs exceeds the value of the output (GDP), they are
     automatically scaled down (this is done in order to overcome a transient problem in the
     iterative calibration process). 
     The `full.log` file will have a warning similar to
     `>>> Warning: Rescaling en and kap prices as their combined value exceeds inco <<<`.
     It is OK if that warning appears in some `.log` files, as long
     as it is not present in the last one.  Check which log files contain this
     warning using
     ```sh
     $ grep ">>> Warning: Rescaling" full_*.log
     ```


## Problems

Just like a REMIND run, the calibration can fail at many points.  This is a list of
observed problems and suggested solutions.

### GAMS Runtime Errors

#### Missing Data  
  The calibration requires some external data: final energy or energy service demand,
  labour, capital. If any of those quantities is missing, GAMS either complains outright
  about _Symbol declared but no values have been assigned_, or assumes the
  missing data to be zero and fails on a division by zero.
  This can happen in new or modified scenario (`GDPscen`, `POPscen`) where the data
  is missing entirely. Otherwise, check the input files
  (`./core/input/f_gdp.cs3r`, `./core/input/f_pop.cs3r`,
  `./modules/29_CES_parameters/calibrate/input/f29_capitalQuantity.cs4r`, and
  `./core/input/f_fedemand.cs4r`) to figure out which data is missing and fix it.

#### $\xi \lt 0$  
  This error (_assertion xi gt 0 failed, see .log file for details_) should not
  show up anymore.  If it still does it is because (the code working around it
  failed and) the value (quantity times price) of some inputs exceeds the value
  of the output at the root of the CES tree, where labour, energy, and capital
  are combined to produce income.  This can be a fundamental issue as some input
  trajectories are just too high (or grow too high over time), but usually it is
  transitory and due to too high estimates of input prices from the previous
  iterations `.gdx` file.  To overcome this, check the plausibility of the input
  trajectories (growth over time, level compared to other factors) or use
  `c_CES_calibration_new_structure` to force the usage of
  `cm_CES_calibration_default_prices`, which can be lowered as need be.

### CONOPT Convergence Errors

The CES calibration is prone to be in more extreme regions of the solution
space and hence may experience infeasibilities more often than regular baseline
runs.  For overcoming them, check the
[debugging tutorial](./10_DebuggingREMIND.md).  But be sure to always run a
`testOneRegi` run of the region in question first.  Often CONOPT will fail in
Nash runs where it does not find infeasibilities in `testOneRegi` (for reasons
unknown), but the output of a `testOneRegi` CES calibration (while itself quite
useless) can be used as a `input.gdx` for the Nash calibration, overcoming these
infeasibilities.  Just put the path of the `fulldata.gdx` from the `testOneRegi`
run into the `path_gdx` column of the scenario config `.csv` file.  It is (in
extreme cases) also possible to daisy-chain `testOneRegi` runs, using the output
of one as the input to another, all with different `c_testOneRegi_region`, and
the result of the last one as the input to a Nash calibration.  (This method was
used for the initial calibration of the new EU-21-regions version of REMIND.)

### Calibration Convergence Errors

The CES calibration can fail to converge towards the calibration targets.  In
that case

- Check the convergence trend.  
  If subsequent iterations show quantities closer to the calibration target,
  more calibration iterations might be necessary.  Start the calibration again,
  using the `fulldata.gdx` as input to reuse the achieved convergence, and
  possibly increase the number of calibration iterations
  (`c_CES_calibration_iterations`).
- Check production factor prices.  
  The prices of the production factors constitute the information transfer
  between calibration iterations.  Check whether they change between iterations,
  or stay constant, in either `CES_calibration.csv` or
  `CES_calibration_report_<scenario_name>.pdf`.  If they are constant, investigate why the
  inputs to the   price calculation
  $\pi_i = \alpha_i {V_i}^{\rho_o - 1} {V_o}^{1 - \rho_o}$ do not change.
- Check bounds on quantities.  
  If quantities (`vm_cesIO`) do not change in between calibration iterations,
  it might be that they are fixed, either explicitly through lower and upper
  bounds, or implicitly through constraints in the ESM or other parts of the
  REMIND model.  Try fixing them to the target values (or narrow bounds around
  them) for the first calibration iteration to determine whether they can reach
  them at all.
