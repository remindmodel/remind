# Calibrating CES Parameters

## CES Production Function Basics

REMIND uses a nested CES production function of the form

$V_o = \left( \sum{\alpha_i {V_i}^{\rho_o}} \right)^{\frac{1}{\rho_o}}$

with output quantity $V_o$, input quantities $V_i$, elasticity parameter
$\rho_o$, and efficiency parameters $\alpha_i$.  The top-level output is the
macroeconomic output (GDP, `inco`), and the inputs can be either intermediate
production factors, that are themselves outputs of a lower level of the CES
function (hence nested), or primary production factors (`ppf`) that are linked
to the energy system model or macro parts of REMIND.

In a REMIND run, the quantities $V$ are free (within the constraints of the
scenario) and subject to the optimisation, while the efficiency and
substitution parameters $\alpha_i$ and $\rho_o$ are fixed.

The purpose of the CES calibration is to find efficiency parameters $\alpha_i$
(the substitution parameters $\rho_o$ are fixed in the code) such that in the
baseline scenario the quantities $V$ (which are derived for the different
scenarios like SSP2 as part of the input data generation) are matched as best as
possible.

Therefore, anytime either the REMIND model or the input data generation is
changed in a way that affects the results of a baseline scenario, that baseline
scenario needs to be calibrated.

## Iterative Calibration

As it is not possible to calculate $n$ parameters $\alpha_i$ from a single
equation, we use an iterative approach.  The
[Euler identity](https://en.wikipedia.org/wiki/Homogeneous_function#Euler's_theorem)
asserts that for homogeneous functions of degree one the function value is equal
to the sum of the partial derivatives times the function arguments:

$V_o = \sum{\frac{\partial V_o}{\partial  V_i} V_i}$

We are not seeking a general analytic solution, but only need to calculate
values at specific points for the iterative process, and thus can express the
partial derivatives in terms of the input and output quantities:

$\frac{\partial V_o}{\partial  V_i} = \pi_i = \alpha_i {V_i}^{\rho_o - 1} {V_o}^{1 - \rho_o}$

Since the final output of the production function $V_o$ is also the numéraire
(e.g. the unit – U.S. dollars – in which inputs are measured), the partial
derivatives are the equilibrium prices $\pi_i$ of the input factors $V_i$ and
the efficiency parameters can be expressed in terms of quantities, prices, and
elasticity parameters:

$\frac{\partial V_o}{\partial  V_i} = \pi_i \Leftrightarrow \alpha_i = \pi_i \left(\frac{V_o}{V_i}\right)^{1 - \rho_o}$

The basic process of the calibration is to use the price calculated using the
partial derivatives of iteration $j$ and combine them with the exogenously
prescribed target quantities $V^\ast$ to calculate the efficiency parameters of
the next iteration $j+1$:

$\pi_i^{(j)} = \alpha_i^{(j)} {V_i^{(j)}}^{1 - \rho_o} {V_o^{(j)}}^{1 - \rho_o}$

$\alpha_i^{(j+1)} = \pi_i^{(j)} \left(\frac{V_o^\ast}{V_i^\ast}\right)^{1 - \rho_o}$


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
derived from the .gdx file, which will be the case of a change in the CES
structure, i.e. when nodes have been added or removed from the CES tree
(technically when the set `cesOut2cesIn` differs between `input.gdx` and the
current calibration run), or seldom in cases of convergence problems.


## Settings

To set up a CES calibration run, simply set module 29 `CES_parameters` to the
`calibration` realisation.  All data relevant to the calibration is configured
according to the selected scenario configuration.  Keep them identical to the
baseline scenario you want to calibrate.
Set the `inputRevision` in `./config/default.cfg` to the input data revision
you want to calibrate to.  You can find the latest input data revision on the
cluster using `lastrev`.  Do not include the `rev` part of the revision name,
just the part from the numbers on.  Use quote signs (`"`) around the revision,
even if it is just numerical.
As the calibration performs multiple REMIND runs (ten by default), allow for
longer runtime, usually more than 24 hours, by selecting an appropriate slurm
configuration.

The calibration can further be adjusted using three switches:

- `c_CES_calibration_iterations`: The number of CES calibration iterations
  (iterative adjustments of $\alpha_i$ parameters, see above).  By default ten.
  We don't use a convergence criterion but check the calibration quality manual
  afterwards.  Higher iteration numbers will generally lead to better
  convergence, but at a runtime expense, as each iteration is an additional
  REMIND run.
- `c_CES_calibration_new_structure`: Switch to use a default price for the
  primary production factors instead of those derived from a .gdx file.  Only
  necessary when the structure of the CES tree was changed, but can be used to
  manually force specific prices in the first CES calibration iteration.  The
  calibration will abort if this switch is necessary but unset, so it should not
  be used unless it is known to be necessary.
- `cm_CES_calibration_default_prices`: Default price to be used when
  `c_CES_calibration_new_structure` is set.  By default 0.01.  The price is not
  differentiated by period, region, or production factor.  A price far off from
  the equilibrium prices will lead to longer calibration times/less good
  calibration performance for a given number of iterations.  Too high prices can
  lead to errors during the calibration.

Furthermore, there is the option `c_CES_calibration_write_prices`, which forces
the prices calculated as partial derivatives on the CES production function to
be written to the file `pm_cesdata_price`, which might be helpful in finding a
suitable value for `cm_CES_calibration_default_price`, but is generally not
used.


## Results

The main output of the CES calibration are a .gdx file and a .inc files with all
the CES parameters.  They are named based on the CES configuration, the
GDP/population scenarios, the capital market module realisation and the region
configuration (e.g. `indu_subsectors-buil_simple-tran_edge_esm-POP_pop_SSP2EU-GDP_gdp_SSP2EU-En_gdp_SSP2EU-Kap_debt_limit-Reg_62eff8f7`).
You don't need to change these names, they are matched automatically using the
switch `cm_CES_configuration`.  The parameter files also include a counter for
the calibration iteration they resulted from (e.g. `_ITERATION_10.inc`).  To
use the calibration results, copy the parameter (`.inc`) file (without the
iteration counter) to the directory `./modules/29_CES_parameters/load/input/`
and the .gdx file to the directory `./config/gdx-files/`.  At PIK, this is done
automatically using the RSE support scripts.  See [this wiki
page](https://gitlab.pik-potsdam.de/REMIND/wiki/-/wikis/Handling-of-Gdx-and-Ces-Parameter-Files-in-Remind)
for details.

If the specific calibration settings (e.g. `cm_CES_configuration`) have not been
calibrated and used in REMIND before, the names of the .gdx and .inc files have
to be included in the `./config/gdx-files/files` and
`./modules/29_CES_parameters/load/input/files` files, respectively, so that the
new calibration results are copied into these directories during run setup.

As for diagnostic output, there are the `full.log` and `full.lst` files for each
calibration iteration (`full_01.log` …), the file `CES_calibration.csv`
containing all the relevant calibration parameters (inputs and outputs) for all
iterations for automated analysis and a `CES_calibration_report` .pdf file with
plots of quantities, prices, and efficiency parameters over regions, production
factors, and time.  This .pdf file can also be generated manually using the
`output.R` script (option "reportCEScalib").


## Validity

To check the validity of a CES calibration run:

1. Check there are no GAMS/REMIND errors
   - Did the prescribed number of CES calibration iterations (ten by
     default) finish?
   - Did the last CES calibration iteration converge?
   - Where there no GAMS errors (in the `full.log` and `full.lst`)?
2. Check the convergence of the Calibration:
   - In the `CES_calibration_report` .pdf file, do the quantities converge
     (sufficiently) towards the target values?  There is no fixed level of
     "sufficient" convergence.  Use personal judgment.
   - If derived production factor prices are so high that the value (quantity
     times price) of inputs exceeds the value of the output (GDP), they are
     scaled down.  This is done in order to overcome a transient problem in the
     iterative calibration process.  The `full.log` file will have a warning
     that reads
     `>>> Warning: Rescaling en and kap prices as their combined value exceeds inco <<<`
     (or similar).  It is OK if that warning appears in some .log files, as long
     as it is not present in the last one.  Check which log files contain this
     warning using
     ```
     $ grep ">>> Warning: Rescaling" full_*.log
     ```


## Problems

The calibration can, just like REMIND, fail at many points.  This is a list of
observed problems and suggested solutions.

### GAMS Runtime Errors

- Missing Data  
  If any of the quantities required for the calibration (final energy or energy
  service demand, labour, capital) is missing, GAMS either complains outright
  about (`Symbol declared but no values have been assigned.`) or assumes the
  missing data to be zero and fails on a division by zero.
  This can be due to a new or modified scenario (`GDPscen`, `POPscen`) that is
  missing entirely or data in the scenario missing.  Check the input files
  (`./core/input/f_gdp.cs3r`, `./core/input/f_pop.cs3r`,
  `./modules/29_CES_parameters/calibrate/input/f29_capitalQuantity.cs4r`, and
  `./core/input/f_fedemand.cs4r`) to figure out which data is missing and go
  from there.
- $\xi \lt 0$
  This error (`assertion xi gt 0 failed, see .log file for details`) should not
  show up anymore.  If it still does it is because (the code working around it
  failed and) the value (quantity times price) of some inputs exceeds the value
  of the output at the root of the CES tree, where labour, energy, and capital
  are combined to produce income.  This can be a fundamental issue as some input
  trajectories are just too high (or grow too high over time), but usually it is
  transitory and due to too high estimates of input prices from the previous
  iterations .gdx file.  To overcome this, check the plausibility of the input
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
run into the `path_gdx` column of the scenario config .csv file.  It is (in
extreme cases) also possible to daisy-chain `testOneRegi` runs, using the output
of one as the input to another, all with different `c_testOneRegi_region`, and
the result of the last one as the input to a Nash calibration.  (This method was
used for the initial calibration of the new EU-21-regions version of REMIND.)

### Calibration Convergence Errors

The CES calibration can fail to converge towards the calibration targets.  In
that case

- Check the convergence trend
  If subsequent iterations show quantities closer to the calibration target,
  more calibration iterations might be necessary.  Start the calibration again,
  using the `fulldata.gdx` as input to reuse the achieved convergence, and
  possibly increase the number of calibration iterations
  (`c_CES_calibration_iterations`).
- Check production factor prices
  The prices of the production factors constitute the information transfer
  between calibration iterations.  Check whether they change between iterations,
  or stay constant, in either the `CES_calibration.csv` or the
  `CES_calibration_report` .pdf file.  If they are constant, investigate why the
  inputs to the   price calculation
  $\pi_i = \alpha_i {V_i}^{\rho_o - 1} {V_o}^{1 - \rho_o}$ do not change.
- Check bounds on quantities
  If quantities (`vm_cesIO`) do not change in between calibration iterations,
  it might be that they are fixed, either explicitly through lower and upper
  bounds, or implicitly through constraints in the ESM or other parts of the
  REMIND model.  Try fixing them to the target values (or narrow bounds around
  them) for the first calibration iteration to determine whether they can reach
  them at all.
