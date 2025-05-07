*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./main.gms
*' @title REMIND - REgional Model of INvestments and 
*'
*' @description REMIND is a global multi-regional model incorporating the economy, the climate system
*' and a detailed representation of the energy sector. It solves for an intertemporal Pareto optimum
*' in economic and energy investments in the model regions, fully accounting for interregional trade in
*' goods, energy carriers and emissions allowances. REMIND enables analyses of technology options and
*' policy proposals for climate change mitigation.
*'
*' The macro-economic core of REMIND is a Ramsey-type optimal growth model in which intertemporal global
*' welfare is optimized subject to equilibrium constraints ([02_welfare]). Intertemporal optimization
*' ([80_optimization]) with perfect foresight is subject to market clearing. The model explicitly represents
*' trade in final goods, primary energy carriers, and when certain climate policies are enabled, emissions
*' allowances ([24_trade]). The macro-economic production factors are capital, labor, and final energy.
*' A nested production function with constant elasticity of substitution determines the final energy demand
*' ([01_macro], [29_CES_parameters]). REMIND uses economic output for investments in the macro-economic
*' capital stock as well as for consumption, trade, and energy system expenditures.
*'
*' The macro-economic core and the energy system part are hard-linked via the final energy demand and the
*' costs incurred by the energy system. Economic activity results in demand for final energy in different
*' sectors (transport ([35_transport]), industry ([37_industry]), buildings ([36_buildings])...) and of
*' different type (electric ([32_power]) and non-electric). The primary energy carriers in REMIND include
*' both exhaustible and renewable resources. Exhaustible resources comprise uranium as well as three fossil
*' resources ([31_fossil]), namely coal, oil, and gas. Renewable resources include hydro, wind, solar,
*' geothermal, and biomass ([30_biomass]). More than 50 technologies are available for the conversion of
*' primary energy into secondary energy carriers as well as for the distribution of secondary energy carriers
*' into final energy.
*'
*' The model accounts for the full range of anthropogenic greenhouse gas (GHG) emissions, most of which are
*' represented by source. REMIND simulates emissions from long-lived GHGs (CO2, CH4, N2O), short-lived GHGs
*' (CO, NOx, VOC) and aerosols (SO2, BC, OC). It accounts for these emissions with different levels of detail
*' depending on the types and sources of emissions. It calculates CO2 emissions from fuel combustion, CH4
*' emissions from fossil fuel extraction and residential energy use, and N2O emissions from energy supply
*' based on sources.
*'
*' The code is structured in a modular way, with code belonging either to the model's core, or to one of the
*' modules. The folder structure is as follows: at the top level are the folders config, core, modules and
*' scripts. The config folder contains the REMIND settings and configuration information. The core folder
*' contains all the files that are part of the core. The modules folder holds all the files that belong to
*' the modules, with numbered sub-folders for every module. The scripts folder contains helpful scripts for
*' starting a model run and analysing results.
*'
*' REMIND is run by executing the main.gms file, which loads the configuration information and builds the model,
*' by concatenating all necessary files from the core and modules folders into a single file called full.gms.
*' The concatenation process starts with files from the core and continues with files from activated modules,
*' in increasing order of module-number. It observes the following structure:
*'
*' ```
*' SETS
*'
*' DECLARATION    ---> of equations, variables, parameters, and scalars
*'
*' DATAINPUT
*'
*' EQUATIONS
*'
*' PRELOOP        ---> initial calibration of e.g. macroeconomic model
*'
*' LOOP
*'         ---> read gdx
*' ----------------------------------------------- BEGIN OF NEGISH/NASH ITERATION LOOP -----
*'       * BOUNDS
*'       * PRESOLVE
*'       * SOLVE     ---> solve statement in module 80_optimization
*'       * POSTSOLVE
*'
*'         ---> write gdx
*' ----------------------------------------------- END OF NEGISHI/NASH ITERATATION LOOP ----
*'
*' OUTPUT
*' ```
*'
*' The GAMS code follows a Coding Etiquette:
*'
*' #### Naming conventions:
*'
*' * Please put effort into choosing intelligible names
*' * Don't just enumerate existing names: `budget1`/`budget2`, `tradebal1`/`tradebal2` will cause everyone
*' for the next years much more frustration than if you choose names like `emi_budget_G8`/`emi_budget_Mud`,
*' `tradebal_res`/`tradebal_perm`/`tradebal_good`
*' * Explain the abbreviation you designed in the descriptive text (the part with the `" "` behind each
*' parameter/variable/equation declaration). `directteinv` is easier to memorize if you know it means "Direct technology investment"
*' * Within REMIND files: use Capitalization to improve readability. `XpPerm` is more easily translated into
*' "Export of Permits" than `xpperm`, the first part of the name (after the prefix) should describe the type
*' of parameter/variable (e.g. `sh` for share, `cap` for capacity, `prod` for production, `dem` for demand, `cost` for costs)
*'
*' #### Prefixes:
*' Use the following *prefixes*:
*'
*' * "q_" to designate equations,
*' * "v_" to designate variables,
*' * "s_" to designate scalars,
*' * "f_" to designate file parameters (parameters that contain unaltered data read in from input files),
*' * "o_" to designate output parameters (parameters that do not affect the optimization, but are affected by it),
*' * "p_" to designate other parameters (parameters that were derived from "f_" parameters or defined in code),
*' * "c_" to designate config switches (parameters that enable different configuration choices),
*' * "s_FIRSTUNIT_2_SECONDUNIT" to designate a scalar used to convert from the FIRSTUNIT to the SECONDUNIT
*'                              through multiplication, e.g. s_GWh_2_EJ.
*'
*' These prefixes are extended in some cases by a second letter:
*'
*' * "?m_" to designate objects used in the core and in at least one module.
*' * "?00_" to designate objects used in a single module, exclusively, with the 2-digit number corresponding
*'          to the module number.
*'
*' Sets are treated differently: instead of a prefix, sets exclusively used within a module get that module's
*' number added as a suffix. If the set is used in more than one module no suffix is given.
*'
*' The units (e.g., TWa, EJ, GtC, GtCO2, ...) of variables and parameters are
*' documented in the declaration files using square brackets at the end of the
*' explanatory text (e.g. `v_var(set1,set2)   "variable [unit]"`).
*'
*' For the labels of parameters, scalars and set, use double quotes only.
*'
*' #### Commenting & Documenting:
*'
*' * Comment all parts of the code generously
*' * For all equations, it should become clear from the comments what part of the equation is supposed to do what
*' * Variables and parameters should be declared along with a descriptive text (use `" "` for descriptive text to avoid compilation errors)
*' * Use three asterisks `***` for comments or `*'` if the comment should show up in the documentation of REMIND generated with `make docs` (https://pik-piam.r-universe.dev/articles/goxygen/goxygen.html)
*' * Never use 4 asterisks (reserved for GAMS error messages)
*' * Don't add dates or initials for your name
*' * Don't use the string `infes` in comments
*' * Don't use `$+number` combinations, e.g., `$20` (this interferes with GAMS error codes).
*' * Indicate the end of a file by inserting `*** EOF filename.inc ***`
*'
*' #### Sets
*'
*' * Don't use set element names with three capital letters (like `ETS` or `ESR`), otherwise the magclass R
*' library might interpret this as a region name when reading in GDX data
*'
*'
*' #### Equations:
*' The general idea is not to write code and equations as short as possible, but to write them in a way they
*' can be read and understood as fast as possible. To that end:
*'
*' * Write the mathematical operator (`*`, `/`, `+`, `-`) at the beginning of a line, not the end of the last line
*' * Leave a space before and after `+` and `-` operators and equation signs (`=g=`, `=l=`, `=e=`)
*' * Leave a space behind the comma of a sum (not behind the commas in set element calling)
*' * Use indentations to make the structure more readable
*' * Use full quotes (`"feel"`) instead of single quotes (`'feel'`) when specifying individual elements of
*' a set (this makes automatic replacement via sed easier)
*' * Put the equation sign (`=g=`, `=l=`, `=e=`) in a single line without anything else
*'
*'
*' #### Switches:
*' A switch must be defined in main.gms
*' Follow this mode of definition for parameters, including the indentation:
*' --------
*' parameter
*'   param_name    "explanation what it means"
*' ;
*'   param_name = 0;     !! def = 0  !! regexp = 0|1
*' --------
*' * def shows the default value, which is added only for the user to remember if changed manually
*' * regexp is optional, the value is read by scripts/start/checkFixCfg.R to check the validity of the input.
*' In this case, it checks whether the value fits this regular expression: ^(0|1)$
*' Use 'value1|value2' for specific values, use '[1-7]' for a row of integers.
*' Three shortcut are defined: use 'is.numeric' for numeric values, 'is.nonnegative' for >= 0,
*' and 'is.share' if the value must be >= 0 and <= 1
*'
*'
*' #### Other general rules:
*' * Decompose large model equations into several small equations to enhance readability and model diagnostics
*' * Don't use hard-coded numbers in the equations part of the model
*' * Parameters should not be overwritten in the initialization part of the models. Use if-statements instead.
*' Notable exceptions include parameters that are part a loop iteration, e.g. Negishi weights.
*' * Have your work double-checked! To avoid bugs and problems: If you make major changes to your code, ask an
*' experienced colleague to review the changes before they are merged to the git main repository.
*' * Use sets and subsets to avoid redundant formulation of code (e.g., for technology groups)
*' * If big data tables are read in exclude them from the `.lst`-file (by using `$offlisting` and `$onlisting`),
*' nevertheless display the parameter afterwards for an easier debugging later
*' * When declaring a parameter/variable/equation always add the sets it is declared for,
*' e.g. `parameter test(x,y);` instead of `parameter test;`
*' * Don't set variables for all set entries to zero (if not necessary), as this will blow up memory requirements.
*'


*##################### R SECTION START (VERSION INFO) ##########################
*
* will be updated automatically when starting a REMIND run
*
*###################### R SECTION END (VERSION INFO) ###########################

*----------------------------------------------------------------------
*** main.gms: main file. welcome to remind!
*----------------------------------------------------------------------

file logfile /""/;

logfile.lw = 0;
logfile.nr = 2;
logfile.nd = 3;
logfile.nw = 0;
logfile.nz = 0;

*--------------------------------------------------------------------------
*** preliminaries:
*--------------------------------------------------------------------------
*** allow empty data sets:
$onempty
*** create dummy identifier to fill empty sets:
$phantom null
*** include unique element list:
$onuellist
*** include $-statements in listing
$ondollar
*** include end-of-line comments
$ONeolcom
*** remove the warnings for very small exponents (x**-60) when post-processing
$offdigit
*** turn profiling off (0) or on (1-3, different levels of detail)
option profile = 0;

file foo_msg;     !! This creates a dummy output file with a well-defined output format:
foo_msg.nr = 1;   !! namely F-format (decimal) (and not E-format = scientific notation)
*** The file can throughout the code be activated with `putclose foo_msg;` and used in the form `put_utility foo_msg "msg" / "xxxx"` to print out xxxx to full.lst
*** and be sure that the numeric format is F-format


*' @title{extrapage: "00_configuration"} Configuration
*' @code{extrapage: "00_configuration"}
*--------------------------------------------------------------------------
*' ### Configuration - Settings for Scenarios:
*--------------------------------------------------------------------------

***---------------------    Run name and description    -------------------------
$setGlobal c_expname  default
$setGlobal c_description  REMIND run with default settings
$setGlobal c_model_version  REMIND model version will be automatically added during prepare.R
$setGlobal c_results_folder  REMIND results_folder will be automatically added during prepare.R

***------------------------------------------------------------------------------
*' ####                      MODULES
***------------------------------------------------------------------------------

*'---------------------    01_macro    -----------------------------------------
*'
*' * (singleSectorGr) neo-classical, single sector growth model
$setGlobal macro  singleSectorGr  !! def = singleSectorGr
*'---------------------    02_welfare    ---------------------------------------
*'
*' * (utilitarian) utilitarian aka. Benthamite social welfare function
*' * (ineqLognormal) welfare function with subregional income distribution effects implemented with a lognormal approach
$setGlobal welfare  utilitarian  !! def = utilitarian
*'---------------------    04_PE_FE_parameters    ------------------------------
*'
*' * (iea2014): new PE-FE parameters based on IEA 2014
$setGlobal PE_FE_parameters  iea2014  !! def = iea2014
*'---------------------    05_initialCap    ------------------------------------
*'
*' * (on):      load existing CES parameters matching model configuration
$setGlobal initialCap  on             !! def = on
*'---------------------    11_aerosols    --------------------------------------
*'
*' * (exoGAINS):
$setGlobal aerosols  exoGAINS         !! def = exoGAINS
*'---------------------    15_climate    ---------------------------------------
*'
*' * (off): no climate coupling
*' * (magicc7_ar6): MAGICC7 - iterative coupling of MAGICC7 simple climate model.
$setGlobal climate  off               !! def = off
*'---------------------    16_downscaleTemperature    --------------------------
*'
*' * (off)
*' * (CMIP5): downscale GMT to regional temperature based on CMIP5 data (between iterations, no runtime impact). [Requires climate = off, cm_rcp_scen = none, iterative_target_adj = 9] curved convergence of CO2 prices between regions until cm_taxCO2_regiDiff_endYr; developed countries have linear path through (cm_taxCO2_historicalYr, cm_taxCO2_historical) and (cm_startyear, cm_taxCO2_startyear);
$setGlobal downscaleTemperature  off  !! def = off
*'---------------------    20_growth    ------------------------------------------
*'
*' * (exogenous): exogenous growth
*' * (spillover): endogenous growth with spillover externality !!Warning: not yet calibrated!!
$setglobal growth  exogenous                !! def = exogenous
*'---------------------    21_tax    ------------------------------------------
*'
*' * (on): tax mechanism active
*' * (off): no tax mechanism
$setglobal tax  on           !! def = on
*'---------------------    22_subsidizeLearning    -----------------------------
*'
*' * (globallyOptimal): Only works with Nash, gives cooperative solution w.r.t. the learning spillover - this should then be equivalent to the Negishi solution.
*' * (off): do not subsidize learning. Default setting for Negishi. With Nash, this gives the non-cooperative solution w.r.t. the learning spillover.
$setglobal subsidizeLearning  off           !! def = off
*'----------------------    23_capitalMarket    -------------------------------
*'
*' * (imperfect): Imperfect capital market: brings initial consumption shares closer to empirical data
*' * (debt_limit): Weak imperfection of capital market by debt and surplus growth limits
$setglobal capitalMarket  debt_limit           !! def = debt_limit
*'----------------------    24_trade    ---------------------------------------
*'
*' * (standard): macro-economic commodities and primary energy commodities trading
*' * (se_trade): macro-economic commodities, primary energy commodities and secondary energy hydrogen and electricity trading
*' * (capacity): capacity-based trade implementation
$setglobal trade  standard           !! def = standard
*'----------------------   26_agCosts  ----------------------------------------
*'
*' * (off): agricultural costs zero, no trade taken into account
*' * (costs): includes total landuse costs
*' * (costs_trade): includes agricultural production costs and the MAgPIE trade balance
$setglobal agCosts  costs       !! def = costs
*'---------------------    29_CES_parameters    ----------------------------
*'
*' * (load):      load existing CES parameters matching model configuration
*' * (calibrate): calculate new CES parameters based on v_cesIO trajectories -- under development!
$setglobal CES_parameters  load   !! def = load
*'---------------------    30_biomass    ----------------------------------------
*'
*' * (magpie_40): using supply curves derived from MAgpIE 4.0
$setglobal biomass  magpie_40     !! def = magpie_40
*'---------------------    31_fossil    ----------------------------------------
*'
*' * (timeDepGrades): time-dependent grade structure of fossil resources (oil & gas only)
*' * (grades2poly)  : simplified version of the time-dependent grade realization (using polynomial functions)
*' * (exogenous)    : exogenous fossil extraction and costs
*' * (MOFEX)        : contains the standalone version of MOFEX (Model Of Fossil EXtraction), which minimizes the discounted extraction and trade costs of fossils while balancing trade for each time step. Not to be run within a REMIND run but instead through the standalone architecture or soft-linked with REMIND (not yet implemented)
$setglobal fossil  grades2poly        !! def = grades2poly
*'---------------------    32_power    ----------------------------------------
*'
*' * (IntC)      :    Power sector formulation with Integration Cost (IntC) markups and curtailment for VRE integration - linearly increasing with VRE share -, and fixed capacity factors for dispatchable power plants
$setglobal power  IntC        !! def = IntC
*'---------------------    33_CDR       ----------------------------------------
*'
*' * (portfolio) : CDR options added via switches: cm_33[option abbreviation]
$setglobal CDR  portfolio        !! def = portfolio
*'---------------------    35_transport    ----------------------------------------
*'
*' * (edge_esm): transport realization with iterative coupling to logit-based transport model EDGE-Transport with detailed representation of transport modes and technologies
$setglobal transport  edge_esm           !! def = edge_esm
*'---------------------    36_buildings    ---------------------------------
*'
*' * (simple): representation of final energy demand via a CES function calibrated to EDGE-Buildings' demand trajectories
$setglobal buildings  simple      !! def = simple
*'---------------------    37_industry    ----------------------------------
*'
*' * (subsectors):   models industry subsectors explicitly with individual CES nests
*'                   for cement, chemicals, steel, and otherInd production.
$setglobal industry  subsectors   !! def = subsectors
*'---------------------    39_CCU    ---------------------------------
*'
*' * (on): representation of technologies for producing synthetic liquids and synthetic gases based on hydrogen and captured carbon
*' * (off): no representation of carbon caputre and utilization technologies.
$setglobal CCU  on      !! def = on
*'---------------------    40_techpol  ----------------------------------------
*'
*' * (none): no technology policies
*' * (lowCarbonPush): [works only with Negishi] global low-carbon push until 2030: PV, CSP, Wind, Gas-CCS, Bio-CCS and Electromobility
*' * (coalPhaseout): [works only with Negishi] global phase-out of new freely-emitting coal conversion, caps all coal routes with the exception of coaltr: coal solids can still expand
*' * (coalPhaseoutRegional): [works only with Negishi] global phase-out of new freely-emitting coal conversion, caps all coal routes with the exception of coaltr: coal solids can still expand
*' * (CombLowCandCoalPO): [works only with Negishi] combination of lowCarbonPush and coalPhaseout
*' * (NDC): Technology targets for 2030 for spv,windon,tnrs.
*' * (NPi): Reference technology targets, mostly already enacted (N)ational (P)olicies (i)mplemented, mostly for 2020
*' * (EVmandates): mandate for electric vehicles - used for UBA project
$setglobal techpol  NPi2025           !! def = NPi2025
*'---------------------    41_emicapregi  ----------------------------------------
*'
*' * (none): no regional emission caps
*' * (CandC):  contraction and convergence allocation (under construction)
*' * (GDPint):  GDP intensity allocation (under construction)
*' * (POPint):  sovereignity (per cap.) allocation (under construction)
*' * (exog):   exogenous emission cap path (generic)  (under construction)
*' * (PerCapitaConvergence):   based on CandC: convergence, to be run with emiscen = 4
*' * (AbilityToPay):   mitigation requirement shared based on per-capita GDP, to be run with emiscen = 4
$setglobal emicapregi  none           !! def = none
*'---------------------    45_carbonprice  ----------------------------------------
*'
*' This module defines the carbon price pm_taxCO2eq, with behaviour across regions governed by similar principles (e.g. global targets, or all following NDC or NPi policies).
*'
*' * (functionalForm): [REMIND default for peak budget and end-of-century budget runs]
*' * Carbon price trajectory follows a prescribed functional form (linear/exponential) - either until peak year or until end-of-century -
*' * and can be endogenously adjusted to meet CO2 budget targets  - either peak or end-of-century - that are formulated in terms of total cumulated CO2 emissions from 2020 (cm_budgetCO2from2020).
*' * Flexible choices for regional carbon price differentiation.
*' * Four main design choices:
*' *    [Global anchor trajectory]: The realization uses a global anchor trajectory based on which the regional carbon price trajectories are defined.
*' *                                The functional form (linear/exponential) of the global anchor trajectory is chosen via cm_taxCO2_functionalForm [default = linear].
*' *                                The (initial) carbon price in cm_startyear is chosen via cm_taxCO2_startyear. This value is endogenously adjusted to meet CO2 budget targets if cm_iterative_target_adj is set to 5, 7, or 9.
*' *                                (linear):      The linear curve is determined by the two points (cm_taxCO2_historicalYr, cm_taxCO2_historical) and (cm_startyear, cm_taxCO2_startyear).
*' *                                               By default, cm_taxCO2_historicalYr is the last timestep before cm_startyear, and cm_taxCO2_historical is the carbon price in that timestep in the reference run (path_gdx_ref) - computed as the maximum of pm_taxCO2eq over all regions.
*' *                                (exponential): The exponential curve is determined by exponential growth rate (cm_taxCO2_expGrowth).
*' *    [Post-peak behaviour]:      The global anchor trajectory can be adjusted after reaching the peak of global CO2 emissions in cm_peakBudgYr. See cm_iterative_target_adj and 45_carbonprice/functionalForm/realization.gms for details.
*' *    [Regional differentiation]: Regional carbon price differentiation relative to global anchor trajectory is chosen via cm_taxCO2_regiDiff [default = initialSpread10].
*' *    [Interpolation from path_gdx_ref]: To smoothen a potential jump of carbon prices in cm_startyear, an interpolation between (a) the carbon prices before cm_startyear procided by path_gdx_ref and (b) the carbon prices from cm_startyear onward defined by parts I-III can be chosen via cm_taxCO2_interpolation [default = off].
*' *                                       In addition, the carbon prices provided by path_gdx_ref can be used as a lower bound based on the switch cm_taxCO2_lowerBound_path_gdx_ref [def = on].
*' * (expoLinear): 4.5% exponential increase until cm_expoLinear_yearStart, transitioning into linear increase thereafter
*' * (exogenous): carbon price is specified using an external input file or using the switch cm_regiExoPrice. Requires cm_emiscen = 9 and cm_iterative_target_adj = 0
*' * (temperatureNotToExceed): [test and verify before using it!] Find the optimal carbon carbon tax (set cm_emiscen = 1, iterative_target_adj = 9] curved convergence of CO2 prices between regions until cm_taxCO2_regiDiff_endYr; developed countries have linear path through (cm_taxCO2_historicalYr, cm_taxCO2_historical) and (cm_startyear, cm_taxCO2_startyear);
*' * (NDC): implements a carbon price trajectory consistent with the NDC targets (up to 2030) and a trajectory of comparable ambition post 2030 (1.25%/yr price increase and regional convergence of carbon price). Choose version using cm_NDC_version "2023_cond", "2023_uncond", or replace 2023 by 2022, 2021 or 2018 to get all NDC published until end of these years.
*' * (NPi): National Policies Implemented, extrapolation of historical (until 2020) carbon prices
*' * (none): no tax policy (combined with all emiscens except emiscen = 9)

***  (exponential) is superseded by (functionalForm): For a globally uniform, exponentially increasing carbonprice path until end of century [in combination with cm_iterative_target_adj = 0 or 5], set cm_taxCO2_functionalForm = exponential, cm_taxCO2_regiDiff = none, cm_taxCO2_interpolation = off, cm_taxCO2_lowerBound_path_gdx_ref = off, cm_peakBudgYr = 2100, and choose the initial carbonprice in cm_startyear via cm_taxCO2_startyear.
***  (linear) is superseded by (functionalForm): For a globally uniform, linearly increasing carbonprice path until end of century [in combination with cm_iterative_target_adj = 0 or 5], set cm_taxCO2_functionalForm = linear, cm_taxCO2_regiDiff = none, cm_taxCO2_interpolation = off, cm_taxCO2_lowerBound_path_gdx_ref = off, cm_peakBudgYr = 2100, and choose the initial carbonprice in cm_startyear via cm_taxCO2_startyear. [Adjust historical reference point (cm_taxCO2_historicalYr, cm_taxCO2_historical) if needed.]

$setglobal carbonprice  NPi2025           !! def = NPi2025
*'---------------------    46_carbonpriceRegi  ---------------------------------
*'
*' This module applies a markup pm_taxCO2eqRegi on top of pm_taxCO2eq to achieve additional intermediate targets.
*'
*' * (none): no regional carbonprice policies
*' * (NDC): implements a carbon price markup trajectory consistent with the NDC targets between 2030 and 2070
*' * (netZero): implements a carbon price markup trajectory consistent with the net zero targets, the region settings can be adjusted with cm_netZeroScen
$setglobal carbonpriceRegi  none      !! def = none
*'---------------------    47_regipol  -----------------------------------------
*'
*' The regiCarbonPrice realisation defines more detailed region or emissions market specific targets, overwriting the behaviour of pm_taxCO2eq and pm_taxCO2eqRegi for these regions.
*'
*' * (none): no regional policies
*' * (regiCarbonPrice): region-specific policies and refinements (regional emissions targets, co2 prices, phase-out policies etc.)
$setglobal regipol  regiCarbonPrice              !! def = regiCarbonPrice
*'---------------------    50_damages    ---------------------------------------
*'
*' * (off): no damages on GDP
*' * (DiceLike): DICE-like damages (linear-quadratic damages on GDP). Choose specification via cm_damage_DiceLike_specification
*' * (BurkeLike): Burke-like damages (growth rate damages on GDP). Choose specification via cm_damage_BurkeLike_specification and cm_damage_BurkeLike_persistenceTime
*' * (KotzWenz): damage function based on Kotz et al. (2024)
*' * (KWLike): Damage function based on Kalkuhl & Wenz (2020)
*' * (KW_SE): Damage function based on Kalkuhl & Wenz (2020), but for the upper bound of the damages based on their standard error calculation
*' * (KWTCint): Combines aggregate damages from Kalkuhl & Wenz (2020) and tropical cyclone damages from Krichene et al. (2022)
*' * (Labor): Labor supply damages from Dasgupta et al. (2021)
*' * (TC): tropical cyclone damages from Krichene et al. (2022)
$setGlobal damages  off               !! def = off
*'---------------------    51_internalizeDamages    ----------------------------
*'
*' * (off):
*' * (DiceLikeItr): Internalize DICE-like damages (calculate the SCC) adjust cm_damages_SccHorizon. Requires cm_emiscen set to 9 for now.
*' * (BurkeLikeItr): Internalize Burke-like damages (calculate the SCC) adjust cm_damages_SccHorizo. Requires cm_emiscen set to 9 for now.
*' * (KotzWenzItr): Internalize KotzWenz damages (calculate the SCC). Requires cm_emiscen set to 9.
*' * (KWlikeItr): Internalize damage function based on Kalkuhl & Wenz (2020). Requires cm_emiscen set to 9 for now.
*' * (KWlikeItrCPnash): Internalize damage function based on Kalkuhl & Wenz (2020), but with Nash SCC, i.e. each region only internalizes its own damages. Requires cm_emiscen set to 9 for now.
*' * (KWlikeItrCPreg): Internalize damage function based on Kalkuhl & Wenz (2020), but with regional SCC instead of a global uniform price. Requires cm_emiscen set to 9 for now.
*' * (KW_SEitr): Internalize damage function based on Kalkuhl & Wenz (2020) for upper limit based on standard error. Requires cm_emiscen set to 9 for now.
*' * (KWTCintItr): Internalize combined damages from Kalkuhl & Wenz (2020) and from tropical cyclones. Requires cm_emiscen set to 9 for now.
*' * (LabItr): Internalize labor supply damages based on Dasgupta et al. (2021). Requires cm_emiscen set to 9 for now.
*' * (TCitr): Internalize tropical cyclone damage function based on Krichene et al. (2022). Requires cm_emiscen set to 9 for now.
$setGlobal internalizeDamages  off               !! def = off
*'---------------------    52_internalizeLCAimpacts    ----------------------------
*'
*' * (off): No internalization
*' * (coupled): Run LCA internalization workflow in between iterations
$setGlobal internalizeLCAimpacts  off               !! def = off
*'---------------------    70_water  -------------------------------------------
*'
*' * (off): no water demand taken into account
*' * (heat): as exogenous only that vintage structure in combination with time dependent cooling shares as vintages and efficiency factors are also considered and demand is a function of excess heat as opposed to electricity output
$setglobal water  heat                 !! def = heat
*'---------------------    80_optimization    ----------------------------------
*'
*' * (nash): Nash solution. Adjust cm_nash_autoconverge to needs.
*' * (negishi): calculates a Negishi solution (social planner)
*' * (testOneRegi):  solves the problem for one region for given prices (taken from gdx).
*'                 ! Warning:  For development purposes only !
$setGlobal optimization  nash         !! def = nash
*'---------------------    81_codePerformance    -------------------------------
*'
*' * (off): nothing happens
*' * (on):  test code performance: noumerous (30) succesive runs performed in a triangle, tax0, tax30, tax150, all growing exponentially.
$setGlobal codePerformance  off       !! def = off

***-----------------------------------------------------------------------------
*' ####                     SWITCHES
***-----------------------------------------------------------------------------
parameter
  cm_nash_mode              "mode for solving nash problem"
;
  cm_nash_mode           = 2;     !! def = 2  !! regexp = 1|2
*' *  (1): debug     - all regions are run in a sequence and the lst-file will contain information on infeasiblities
*' *  (2): parallel  - all regions are run in parallel
*'
parameter
  cm_iteration_max          "number of iterations, if optimization is set to negishi or testOneRegi; is overwritten in Nash mode, except if cm_nash_autoconverge is set to 0"
;
  cm_iteration_max       = 1;     !! def = 1
*'
parameter
  cm_abortOnConsecFail      "number of iterations of consecutive infeasibilities/failures to solve for one region, after which the run automatically switches to serial debug mode"
;
  cm_abortOnConsecFail   = 2;     !! def = 2  !! regexp = [0-9]+
*'
parameter
  cm_solver_try_max          "maximum number of inner iterations within one Negishi iteration (<10)"
;
  cm_solver_try_max       = 2;     !! def = 2
*' set to at least five by testOneRegi
parameter
  c_keep_iteration_gdxes    "save intermediate iteration gdxes"
;
  c_keep_iteration_gdxes = 0;     !! def = 0  !! regexp = 0|1
*' in default we do not save gdx files from each iteration to limit the number of the output files but this might be helpful for debugging
*'
*' * (0)  gdx files from each iteration are NOT saved
*' * (1)  gdx files from each iteration are saved
parameter
  cm_keep_presolve_gdxes    "save gdxes for all regions/solver tries/nash iterations for debugging"
;
  cm_keep_presolve_gdxes  = 0;     !! def = 0  !! regexp = 0|1
*'
parameter
  cm_nash_autoconverge      "choice of nash convergence mode"
;
  cm_nash_autoconverge   = 1;     !! def = 1  !! regexp = [0-3]
*' * (0): manually set number of iterations by adjusting cm_iteration_max
*' * (1): run until solution is sufficiently converged  - coarse tolerances, quick solution.  ! do not use in production runs !
*' * (2): run until solution is sufficiently converged  - fine tolerances, for production runs.
*' * (3): run until solution is sufficiently converged using very relaxed targets  - very coarse tolerances, two times higher than option 1. ! do not use in production runs !
*'
parameter
  cm_emiscen                "policy scenario choice"
;
  cm_emiscen        = 9;               !! def = 9  !!  regexp = 0|1|4|6|9|10
*' *  (0): no global budget. Policy may still be prescribed by 41_emicaprei module.
*' *  (1): BAU
*' *  (4): emission time path
*' *  (6): budget
*' *  (9): tax scenario (requires running module 21_tax "on"), tax level controlled by module 45_carbonprice and cm_taxCO2_startyear, other GHG etc. controlled by cm_rcp_scen
*' *  (10): used for cost-benefit analysis
*' *JeS* WARNING: data for cm_emiscen 4 only exists for multigas_scen 2 bau scenarios and for multigas_scen 1
parameter
  cm_taxCO2_startyear    "level of co2 tax in start year in $ per t CO2eq"
;
  cm_taxCO2_startyear = -1;     !! def = -1  !! regexp = -1|is.nonnegative
*' * (-1): default setting equivalent to no carbon tax
*' * (any number >= 0): CO2 tax in start year [if cm_iterative_target_adj eq 0];
*' *                    initialization of CO2 tax in start year [if cm_iterative_target_adj eq 5, 7 or 9]
parameter
  cm_taxCO2_expGrowth         "growth rate of carbon tax"
;
  cm_taxCO2_expGrowth = 1.045;            !! def = 1.045  !! regexp = is.numeric
*'  (any number >= 0): rate of exponential increase over time, default value chosen to be consistent with interest rate
parameter
  cm_budgetCO2from2020   "CO2 budget for all economic sectors starting from 2020 (GtCO2). It can be either peak budget, but can also be an end-of-century budget"
;
  cm_budgetCO2from2020      = 0;   !! def = 0
*'  budgets from AR6 for 2020-2100 (including 2020), for 1.5 C: 500 Gt CO2 peak budget (400 Gt CO2 end of century), for 2 C: 1150 Gt CO2
parameter
  cm_budgetCO2_absDevTol  "convergence criterion for global CO2 budget set via cm_budgetCO2from2020. It is formulated as an absolute deviation from the target budget [GtCO2]"
;
  cm_budgetCO2_absDevTol      = 2;   !! def = 2 !! regexp = is.nonnegative
*' 

parameter
  cm_peakBudgYr       "date of net-zero CO2 emissions for peak budget runs without overshoot"
;
  cm_peakBudgYr            = 2050;   !! def = 2050
*' time of net-zero CO2 emissions (peak budget)
*' endogenous adjustment by algorithms in 45_carbonprice/functionalForm/postsolve.gms [requires emiscen = 9 and cm_iterative_target_adj = 7 or 9]
parameter
  cm_taxCO2_IncAfterPeakBudgYr "annual increase of CO2 tax after cm_peakBudgYr in $ per tCO2"
;
  cm_taxCO2_IncAfterPeakBudgYr = 0; !! def = 0 . For weak targets (higher than 1100 Peak Budget), this value might need to increased to prevent continually increasing temperatures
*'
parameter
  cm_expoLinear_yearStart   "time at which carbon price increases linearly instead of exponentially"
;
  cm_expoLinear_yearStart  = 2050;   !! def = 2050
*'
parameter
  c_macscen                 "scenario switch on whether or not to use MAC (Marginal Abatement Cost) for certain sectors not related to direct combustion of fossil fuel, e.g. fugitive emissions from old mines, forestry, agriculture and cement"
;
  c_macscen         = 1;               !! def = 1  !! regexp = 1|2
*' * (1): on
*' * (2): off
*'
parameter
  cm_nucscen                "nuclear option choice"
;
  cm_nucscen       = 2;        !! def = 2  !! regexp = 1|2|5|6
*' *  (1): default, no restriction, let nuclear be endogenously invested
*' *  (2): no fnrs, tnrs with restricted new builds until 2030 (based on current data on plants under construction, planned or proposed)
*' *  (5): no new nuclear investments after 2020
*' *  (6): +33% investment costs for tnrs under SSP5, uranium resources increased by a factor of 10
*'
parameter
  cm_ccapturescen       "carbon capture option choice, no carbon capture only if CCS and CCU are switched off!"
;
  cm_ccapturescen  = 1;        !! def = 1  !! regexp = [1-4]
*' *  (1): yes
*' *  (2): no carbon capture (only if CCS and CCU are switched off!)
*' *  (3): no bio carbon capture
*' *  (4): no carbon capture in the electricity sector
*'
parameter
  c_bioliqscen              "2nd generation bioenergy liquids technology choice"
;
  c_bioliqscen     = 1;        !! def = 1  !! regexp = 0|1
*' *  (0): no technologies
*' *  (1): all technologies
*'
parameter
  c_bioh2scen               "bioenergy hydrogen technology choice"
;
  c_bioh2scen      = 1;        !! def = 1  !! regexp = 0|1
*' *  (0): no technologies
*' *  (1): all technologies
*'
parameter
  c_shGreenH2               "lower bound on share of green hydrogen in all hydrogen from 2030 onwards"
;
  c_shGreenH2      = 0;        !! def = 0  !! regexp = is.share
*'   (a number between 0 and 1): share
parameter
  c_shBioTrans              "upper bound on share of bioliquids in transport from 2025 onwards"
;
  c_shBioTrans     = 1;        !! def = 1  !! regexp = is.share
*'  (a number between 0 and 1): share
parameter
  cm_shSynLiq               "lower bound on share of synfuels in SE liquids by 2045, gradual scale-up before"
;
  cm_shSynLiq    = 0;          !! def = 0  !! regexp = is.share
*'   (a number between 0 and 1): share
parameter
  cm_shSynGas               "lower bound on share of synthetic gas in SE gases by 2045, gradual scale-up before"
;
  cm_shSynGas      = 0;        !! def = 0  !! regexp = is.share
*'
parameter
  cm_IndCCSscen             "CCS for Industry"
;
  cm_IndCCSscen          = 1;        !! def = 1
*'
parameter
  cm_optimisticMAC          "assume optimistic Industry MAC from AR5 Ch. 10?"
;
  cm_optimisticMAC       = 0;        !! def = 0
*'
parameter
  cm_CCS_cement             "CCS for cement sub-sector"
;
  cm_CCS_cement          = 1;        !! def = 1
*'
parameter
  cm_CCS_chemicals          "CCS for chemicals sub-sector"
;
  cm_CCS_chemicals       = 1;        !! def = 1
*'
parameter
  cm_CCS_steel              "CCS for steel sub-sector"
;
  cm_CCS_steel           = 1;        !! def = 1
*'
parameter
  cm_bioenergy_SustTax      "level of the bioenergy sustainability tax in fraction of bioenergy price"
;
  cm_bioenergy_SustTax   = 1.5;      !! def = 1.5
*' Only effective if 21_tax is on.
*' The tax is only applied to purpose grown 2nd generation (lignocellulosic)
*' biomass and the level increases linearly with bioenergy demand. A value of 1
*' refers to a tax level of 100% at a production of 200 EJ per yr globally
*' (implies 50% at 100 EJ per yr or 150% at 300 EJ per yr, for example).
*'
*' * (0):               setting equivalent to no tax
*' * (1.5):             (default), implying a tax level of 150% at a demand of
*'                    200 EJ per yr (or 75% at 100 EJ per yr)
*' * (any number ge 0): defines tax level at 200 EJ per yr
*'
parameter
  cm_bioenergy_EF_for_tax   "bioenergy emission factor that is used to derive a bioenergy tax [kgCO2 per GJ]"
;
  cm_bioenergy_EF_for_tax  = 0;        !! def = 0
*' Only effective if 21_tax is on, applied to all regions specified by
*' cm_regi_bioenergy_EFTax. Please note that the tax, which is derived from
*' this emission factor, is not the same as the sustainabilty tax described
*' above. Please also note that the emission factor is only used to inform
*' the tax level, i.e. associated emissions do not enter the emissions balance
*' equations.
*'
*' * (0)    off
*' * (20)   Sets the emission factor to 20 kgCO2 per GJ, which for example
*'        results in a tax of 2 $ per GJ (primary energy) at a carbon price of
*'        100 $ per tCO2:
*'                20 kgCO2 per GJ * 100 $ per tCO2
*'          eq    0.02 tCO2 per GJ * 100 $ per tCO2
*'          eq    2 $ per GJ
*'
parameter
  cm_tradecostBio           "choose financial tradecosts multiplier for biomass (purpose grown pebiolc)"
;
  cm_tradecostBio     = 1;         !! def = 1
***  (1):               medium trade costs (used e.g. for for SSP2)
***  (0.5)              low tradecosts (used e.g. for other SSP scenarios than SSP2)
***  (any value ge 0):  set costs multiplier to that value
*'
parameter
  cm_1stgen_phaseout        "scenario setting for phase-out of 1st generation biofuels"
;
  cm_1stgen_phaseout  = 0;         !! def = 0  !! regexp = 0|1
*' *  (0): no phase-out. Production of 1st generation biofuels after 2045 is bound from below by 90% of maximum resource potential ("maxprod").
*'         In MAgPIE, set 'c60_1stgen_biodem' to 'const20xx'.
*' *  (1): phase-out. No new capacities for 1st generation biofuel technologies are built after 2030 (i.e. added capacity vm_deltaCap equals 0), in practice this means a slow phaseout of 1st generation biofuel due to lack of economic competitiveness. Bioenergy production is bound from below by 90% of maximum biomass resource potential in 2045.
*'         In MAgPIE, set 'c60_1stgen_biodem' to 'phaseout20xx'.
*' The consistency between REMIND and MAgPIE switches is checked by scripts/start/checkSettingsRemMag.R
*'
parameter
  cm_phaseoutBiolc          "Switch that allows for a full phaseout of all bioenergy technologies globally"
;
  cm_phaseoutBiolc    = 0;         !! def = 0  !! regexp = 0|1
***  Only working with magpie_40 realization of 30_biomass module.
***  (0): (default) No phaseout
***  (1): Phaseout capacities of all bioenergy technologies using pebiolc, as far
***       as historical bounds on bioenergy technologies allow it. This covers
***       all types of lignocellulosic feedstocks, i.e. purpose grown biomass and
***       residues. Lower bounds on future electricity production due to NDC
***       targets in p40_ElecBioBound are removed. The first year, in which no new
***       capacities are allowed, is 2025 or cm_startyear if larger.
*'
parameter
  cm_startyear              "first optimized modelling time step [year]"
;
  cm_startyear        = 2005;      !! def = 2005 for a baseline  !! regexp = 20[0-9](0|5)
*' *  (2005): standard for baseline to check if model is well calibrated
*' *  (2015): standard for all policy runs (eq. to fix2010), NDC, NPi and production baselines, especially if various baselines with varying parameters are explored
*' *  (....): later start for delay policy runs, eg. 2025 for what used to be delay2020
*'
parameter
  c_start_budget            "start of GHG budget limit"
;
  c_start_budget      = 2100;      !! def = 2100
*'
parameter
  cm_prtpScen               "pure rate of time preference standard values"
;
  cm_prtpScen         = 1;         !! def = 1  !! regexp = 1|3
*' *  (1): 1.5 %
*' *  (3): 3 %
*'
parameter
  cm_fetaxscen              "choice of final energy tax path and subsidy path, values other than zero enable final energy tax"
;
  cm_fetaxscen        = 3;         !! def = 3  !! regexp = [0-5]
*' even if set to 0, the PE inconvenience cost per SO2-cost for coal are always on if module 21_tax is on
*' * (0): no FE tax, constant PE2SE tax,                    no FE and ResEx sub
*' * (1): constant FE and PE2SE tax,                        constant FE and ResEx sub               (used in SSP3 and SSP 5)
*' * (2): converging FE tax (-2050), constant PE2SE tax,    phased out FE and ResEx sub (-2035)     (used in SSP 1)
*' * (3): constant FE and PE2SE tax,                        phased out FE and ResEx sub (-2050)     (used in SSP 2)
*' * (4): constant FE and PE2SE tax,                        phased out FE and ResEx sub (-2035)
*' * (5): rollback FE tax (-2035), no PE2SE tax,            constant FE and ResEx sub               (used in rollback scenarios to get back to a no-policy case (previously known as BAU))
*'
parameter
  cm_distrBeta              "elasticity of tax revenue redistribution"
;
  cm_distrBeta        = 1;       !! def = 1  !! regexp = 0|1
*' (0): equal per capita redistribution
*' (1): proportional redistribution
*'
parameter
  cm_multigasscen           "scenario on GHG portfolio to be included in permit trading scheme"
;
  cm_multigasscen     = 3;         !! def = 3  !! regexp = [1-3]
*' *  (1): CO2 only
*' *  (2): all GHG
*' *  (3): all GHG excl CO2 emissions from LULUCF
*'
parameter
  cm_permittradescen        "scenario on permit trade"
;
  cm_permittradescen  = 1;         !! def = 1  !! regexp = [1-3]
*' *  (1): full permit trade (no restrictions)
*' *  (2): no permit trade (only domestic mitigation)
*' *  (3): limited trade (certain percentage of GDP)
*'
parameter
  cm_rentdiscoil            "[grades2poly] discount factor for the oil rent"
;
  cm_rentdiscoil      = 0.2;       !! def = 0.2
*'
parameter
  cm_rentdiscoil2           "[grades2poly] discount factor for the oil rent achieved in 2100"
;
  cm_rentdiscoil2     = 0.9;       !! def = 0.9
*'
parameter
  cm_rentconvoil            "[grades2poly] number of years required to converge to the 2100 oil rent"
;
  cm_rentconvoil      = 50;        !! def = 50
*'
parameter
  cm_rentdiscgas            "[grades2poly] discount factor for the gas rent"
;
  cm_rentdiscgas      = 0.6;       !! def = 0.6
*'
parameter
  cm_rentdiscgas2           "[grades2poly] discount factor for the gas rent achieved in 2100"
;
  cm_rentdiscgas2     = 0.8;       !! def = 0.8
*'
parameter
  cm_rentconvgas            "[grades2poly] number of years required to converge to the 2100 gas rent"
;
  cm_rentconvgas      = 50;        !! def = 50
*'
parameter
  cm_rentdisccoal           "[grades2poly] discount factor for the coal rent"
;
  cm_rentdisccoal     = 0.4;       !! def = 0.4
*'
parameter
  cm_rentdisccoal2          "[grades2poly] discount factor for the coal rent achieved in 2100"
;
  cm_rentdisccoal2    = 0.6;       !! def = 0.6
*'
parameter
  cm_rentconvcoal           "[grades2poly] number of years required to converge to the 2100 coal rent"
;
  cm_rentconvcoal     = 50;        !! def = 50
*'
parameter
  c_cint_scen               "additional GHG emissions from mining fossil fuels"
;
  c_cint_scen           = 1;         !! def = 1  !! regexp = 0|1
*' *  (0): switch is off (emissions are not accounted)
*' *  (1): switch is on (emissions are accounted)
*'
parameter
  cm_so2tax_scen            "level of SO2 tax"
;
  cm_so2tax_scen        = 1;         !! def = 1  !! regexp = [0-4]
*' *  (0): so2 tax is set to zero
*' *  (1): so2 tax is low
*' *  (2): so2 tax is standard
*' *  (3): so2 tax is high
*' *  (4): so2 tax intermediary between 1 and 2, multiplying (1) tax by the ratio (3) and (2)
*'
parameter
  c_ccsinjecratescen        "CCS injection rate factor applied to total regional storage potentials, yielding an upper bound on annual injection"
;
  c_ccsinjecratescen    = 1;         !! def = 1  !! regexp = [0-6]
*' This switch determines the upper bound of the annual CCS injection rate.
*' CCS here refers to carbon sequestration, carbon capture is modelled separately.
*' *   (0) no "CCS" as in no carbon sequestration at all
*' *   (1) reference case: 0.005; max 19.7 GtCO2/yr globally
*' *   (2) lower estimate: 0.0025; max 9.8 GtCO2/yr globally
*' *   (3) upper estimate: 0.0075; max 29.5 GtCO2/yr globally
*' *   (4) unconstrained: 1; max 3900 GtCO2/yr globally
*' *   (5) sustainability case: 0.001; max 3.9 GtCO2/yr globally
*' *   (6) intermediate estimate: 0.0022; max 8.6 GtCO2/yr globally
*'
parameter
  c_ccscapratescen          "CCS capture rate"
;
  c_ccscapratescen      = 1;         !! def = 1  !! regexp = 1|2
*' This flag determines the CO2 capture rate of selected CCS technologies
*' *   (1) reference (90%)
*' *   (2) increased capture rate (99%)
*'
parameter
  c_export_tax_scen         "choose which oil export tax is used in the model. 0 = none, 1 = fix"
;
  c_export_tax_scen     = 0;         !! def = 0  !! regexp = 0|1
*'
parameter
  cm_iterative_target_adj   "settings on iterative adjustment for CO2 tax based on in-iteration emission or forcing level. Allow iteratively generated endogenous global CO2 tax under peak budget constraint or end-of-century budget constraint."
;
  cm_iterative_target_adj = 0;      !! def = 0  !! regexp = 0|2|3|5|7|9
*' * (0): no iterative adjustment of CO2 tax (terminology: CO2 price and CO2 tax in REMIND is used interchangeably)
*' * (2): iterative adjustment of CO2 tax or cumulative emission based on climate forcing calculated by climate model magicc, for runs with budget or CO2 tax constraints. See ./modules/45_carbonprice/NDC/postsolve.gms for direct algorithm
*' * (3): [requires 45_carbonprice = NDC and emiscen = 9] iterative adjustment of CO2 tax based on 2025 or 2030 regionally differentiated emissions, for runs with emission budget or CO2 tax constraints. See ./modules/45_carbonprice/NDC/postsolve.gms for direct algorithm
*' * (5): [requires 45_carbonprice = functionalForm and emiscen = 9] iterative adjustment of CO2 tax based on economy-wide CO2 cumulative emission budget(2020-2100), for runs with emission budget or CO2 tax constraints. [see 45_carbonprice/functionalForm/postsolve.gms for direct algorithm]
*' * (7): [requires 45_carbonprice = functionalForm and emiscen = 9] iterative adjustment of CO2 tax based on economy-wide CO2 cumulative emission peak budget, for runs with emission budget or CO2 tax constraints. Features: results in a peak budget with zero net CO2 emissions after peak budget is reached. See core/postsolve.gms for direct algorithms [see 45_carbonprice/functionalForm/postsolve.gms for direct algorithm]
*' * (9): [requires 45_carbonprice = functionalForm and emiscen = 9] iterative adjustment of CO2 tax based on economy-wide CO2 cumulative emission peak budget, for runs with emission budget or CO2 tax constraints. Features: 1) after the year when budget peaks, CO2 tax has an annual increase by cm_taxCO2_IncAfterPeakBudgYr, 2) automatically shifts cm_peakBudgYr to find the correct year of budget peaking for a given budget. [see 45_carbonprice/functionalForm/postsolve.gms for direct algorithm]
*'
parameter
  cm_NDC_divergentScenario  "choose scenario about convergence of CO2eq prices [45_carbonprice = NDC]"
;
  cm_NDC_divergentScenario = 0;           !! def = 0  !! regexp = [0-2]
*' *  (0) 70 years after 2030
*' *  (1) 120 years after 2030
*' *  (2) until year 3000 ("never")
*'
parameter
  cm_gdximport_target       "whether or not the starting value for iteratively adjusted CO2 tax trajectories for all regions (scenarios defined by cm_iterative_target_adj) should be read in from the input.gdx"
;
  cm_gdximport_target      = 0;      !! def = 0  !! regexp = 0|1
*' * (0): no import
*' * (1): the values from the gdx are read in (works only if the gdx has a parameter value) ATTENTION: make sure that the values from the gdx have the right structure (e.g. regionally differentiated or not)
*'
parameter
  cm_33DAC                  "choose whether DAC (direct air capture) should be included into the CDR portfolio."
;
  cm_33DAC                 = 1;   !! def = 1    !! regexp = 0|1
*' * (1): direct air capture is included
*' * (0): not included
*'
parameter
  cm_33EW                   "choose whether EW (enhanced weathering) should be included into the CDR portfolio."
;
  cm_33EW                  = 0;   !! def = 0    !! regexp = 0|1
*' * (1): enhanced weathering is included
*' * (0): not included
*'
parameter
  cm_33OAE                  "choose whether OAE (ocean alkalinity enhancement) should be included into the CDR portfolio. 0 = OAE not used, 1 = used"
;
  cm_33OAE                 = 0;   !! def = 0
*' Since OAE is quite a cheap CDR option, runs might not converge because the model tries to deploy
*' a lot of OAE. In this case, use a quantity target to limit OAE by adding something like:
*' (2070,2080,2090,2100).GLO.tax.t.oae.all 5000 to cm_implicitQttyTarget in your config file,
*' starting from the year in which OAE is deployed above 5000 MtCO2 / yr. This will limit the global
*' deployment to 5000 Mt CO2 / yr in timesteps 2070-2100. 
*' As an alternative to this cost-efficient allocation, a global limit can be set via cm_33_OAE_limit_EEZ which 
*' distributes it between regions based on the size of the exclusive economic zones. This approach should only be
*' chosen when the tax approach inhibits convergence. See q33_OAE_EEZ_limit for further reasoning.
*' Both limitation approaches affect ocean uptake, i.e. gross OAE. 
*' * (1): ocean alkalinity enhancement is included
*' * (0): not included
*'
parameter
  cm_33_OAE_eff             "OAE efficiency measured in tCO2 uptaken by the ocean per tCaO. Typically between 0.9-1.4 (which corresponds to 1.2-1.8 molCO2/molCaO). [tCO2/tCaO]"
;
  cm_33_OAE_eff            = 1.2; !! def = 1.2
*'
parameter
  cm_33_OAE_scen            "OAE distribution scenarios"
;
  cm_33_OAE_scen           = 1; !! def = 1
*' *  (0): pessimistic: a rather low discharge rate (30 tCaO per h), corresponding to high distribution costs
*' *  (1): optimistic: a high discharge rate (250 tCaO per h), corresponding to lower distribution costs
*'
parameter
  cm_33_OAE_startyr         "The year when OAE could start being deployed [year]"
;
  cm_33_OAE_startyr        = 2035; !! def = 2035  !! regexp = 20[3-9](0|5)
*' *  (2035): earliest year when OAE could be deployed
*' *  (....): later timesteps
*'
parameter
  cm_33_OAE_limit_EEZ           "Global limit [Mt CO2 ocean uptake/a]. Upper bound on regions' ocean uptake is set based on EEZ distribution."
;
  cm_33_OAE_limit_EEZ            = 0; !! def = 0 !! regexp = is.nonnegative
*' * (0): no global limit that is distributed based on regions' EEZ size
*' * (5000): global 5 Gt CO2 uptake maximum is distributed as upper bound to regions. 
*'           5 Gt CO2/yr uptake limit corresponds roughly to CaO being distributed in the upper 2m of the entire (!) EEZ
*'           up to the precipitation avoiding concentration limit, assuming average uptake efficiency. 
*' 
parameter
  cm_gs_ew                  "grain size (for enhanced weathering, CDR module) [micrometre]"
;
  cm_gs_ew                 = 20;     !! def = 20  !! regexp = is.numeric
*'
parameter
  cm_LimRock                "limit amount of rock spread each year [Gt]"
;
  cm_LimRock               = 1000;   !! def = 1000
*'
parameter
  cm_33_EW_upScalingRateLimit    "Annual growth rate limit on upscaling of mining & spreading rocks on fields"
;
  cm_33_EW_upScalingRateLimit = 0.2;  !! def = 20% !! regexp = is.nonnegative
*' 
parameter
  cm_33_EW_shortTermLimit         "Limit on 2030 potential for enhanced weathering, defined as % of land on which EW is applied. Default 0.5% of land"
;
  cm_33_EW_shortTermLimit = 0.005; !! def = 0.5% !! regexp = is.nonnegative
*'
parameter
  cm_33_maxFeShare                "max share of the CDR sectors' FE demand in the region's total FE demand, by FE type. Default is 10%"
;
  cm_33_maxFeShare = 0.1; !!  def = 0.1 !! regexp = is.nonnegative
*' 
parameter
  cm_postTargetIncrease     "carbon price increase per year after regipol emission target is reached (euro per tCO2)"
;
  cm_postTargetIncrease    = 0;      !! def = 0
*'
parameter
  cm_implicitQttyTarget_tolerance "tolerance for regipol implicit quantity target deviations convergence."
;
  cm_implicitQttyTarget_tolerance    = 0.01;       !! def = 0.01, i.e. regipol implicit quantity targets must be met within 1% of target deviation
*'
parameter
  cm_emiMktTargetDelay  "number of years for delayed price change in the emission tax convergence algorithm. Not applied to first target set."
;
  cm_emiMktTargetDelay    = 0;       !! def = 0
*'
parameter
  cm_distrAlphaDam    "income elasticity of damages for inequality"
;
  cm_distrAlphaDam     = 1;    !! def = 1
*'  1 means damage is distributed proportional to income, i.e. distributionally neutral, 0 means equal per capita distribution of damage
parameter
  cm_damages_BurkeLike_specification      "empirical specification for Burke-like damage functions"
;
  cm_damages_BurkeLike_specification    = 0;     !! def = 0
*'  {0,5} Selects the main Burke specification "pooled, short-run" (0) or an alternative one "pooled, long-run "(5)
parameter
  cm_damages_BurkeLike_persistenceTime    "persistence time in years for Burke-like damage functions"
;
  cm_damages_BurkeLike_persistenceTime  = 30;    !! def = 30
*'  Persistence time (half-time) in years. Highly uncertain, but may be in between 5 and 55 years.
parameter
  cm_damages_SccHorizon                   "Horizon for SCC calculation. Damages cm_damagesSccHorizon years into the future are internalized."
;
  cm_damages_SccHorizon                 = 100;   !! def = 100
*'  Horizon for SCC calculation. Damages cm_damagesSccHorizon years into the future are internalized.
parameter
  cm_damage_KWSE                          "standard error for Kalkuhl & Wenz damages"
;
  cm_damage_KWSE                        = 0;     !! def = 0
*'  {1.645 for 90% CI, 1.96 for 95% CI, no correction when 0}
parameter
  cm_sccConvergence         "convergence indicator for SCC iteration"
;
  cm_sccConvergence	       = 0.05;  !! def = 0.05
;
parameter
  cm_tempConvergence         "convergence indicator for temperature in damage iteration"
;
  cm_tempConvergence       = 0.05;  !! def = 0.05
;
parameter
  cm_carbonprice_temperatureLimit "not-to-exceed temperature target in degree above pre-industrial [45_carbonprice = temperatureNotToExceed]"
;
  cm_carbonprice_temperatureLimit       = 1.8;   !! def = 1.8
*'
parameter
  cm_frac_CCS          "tax on carbon transport & storage (ccsinje) to reflect risk of leakage, formulated as fraction of ccsinje O&M costs"
;
  cm_frac_CCS          = 10;   !! def = 10
*'

parameter
  cm_frac_NetNegEmi    "tax on net negative emissions to reflect risk of overshooting, formulated as fraction of carbon price"
;
  cm_frac_NetNegEmi    = 0.5;  !! def = 0.5
*' This tax reduces the regional effective carbon price for net-negative CO2 emissions; default is a reduction by 50 percent.
*' Fraction can be freely chosen. Guidelines:
*'
*' * (0)   No net negative tax, the full CO2 price always applies.
*' * (0.5) Halves the effective CO2 price for gross CDR exceeding gross emissions.
*' * (1)   No effective CO2 tax for gross CDR exceeding gross emissions.

parameter
  cm_NetNegEmi_calculation    "switch to choose if net-negative emissions are calculated within an iteration or across iterations"
;
  cm_NetNegEmi_calculation    = 0;  !! def = 0 !! regexp = 0|1
*' (0) regional net-negative CO2 emissions are calculated within the current iteration, i.e. gross CO2 emissions of current iteration minus gross CDR of current iteration.
*'     In this case, the net-negative emissions tax is applied to net CO2 emissions, and thus, both further CO2 emission reductions and CDR are disincentivised.
*' (1) regional net-negative CO2 emissions are calculated across iterations, i.e. weighted average gross CO2 emissions of previous iterations minus gross CDR of current iteration.
*'     In this case, the net-negative emissions tax is applied to the difference of gross CDR of the current iteration and gross CO2 emissions based on previous iterations, and thus, gross CDR beyond net-zero CO2 is disincentivised without incentivising gross CO2 emissions.
*      Attention: As of now, (1) interferes with the algorithm to adjust carbon prices in 45_carbonprice/functionalForm/postsolve.gms. This will be improved before making it the default.

parameter
  cm_H2InBuildOnlyAfter "Switch to fix H2 in buildings to zero until given year"
;
  cm_H2InBuildOnlyAfter = 2150;   !! def = 2150 (rule out H2 in buildings)
*' For all years until the given year, FE demand for H2 in buildings is set to zero
parameter
  c_teNoLearngConvEndYr      "Year at which regional costs of non-learning technologies converge"
;
  c_teNoLearngConvEndYr  = 2070;   !! def = 2070
*'
parameter
  c_earlyRetiValidYr         "Year before which the early retirement rate designated by c_tech_earlyreti_rate holds"
;
  c_earlyRetiValidYr  = 2035;   !! def = 2035
*'
parameter
  c_seFeSectorShareDevScale "scale factor in the objective function of the penalization to incentive sectors to have similar shares of secondary energy fuels."
;
  c_seFeSectorShareDevScale = 1e-3;  !! def = 1e-3
*'
parameter
  cm_TaxConvCheck             "switch for enabling tax convergence check in nash mode"
;
  cm_TaxConvCheck = 1;  !! def = 1, which means tax convergence check is on  !! regexp = 0|1
*'  switches tax convergence check in nash mode on and off (check that tax revenue in all regions, periods be smaller than 0.1% of GDP)
*' * 0 (off)
*' * 1 (on), default
*'
parameter
  cm_maxFadeOutPriceAnticip   "switch to determine maximum allowed fadeout price anticipation to consider that the model converged."
;
  cm_maxFadeOutPriceAnticip = 1e-4; !! def = 1e-4, the fadeout price anticipation term needs to be lower than 1e-4 to consider that the model converged.
*'
parameter
  cm_flex_tax                 "switch for enabling flexibility tax"
;
  cm_flex_tax = 1;  !! def = 1  !! regexp = 0|1
*'  cm_flex_tax "switch for flexibility tax/subsidy, switching it on activates a tax on a number of technologies with flexible or inflexible electricity input."
*'  technologies with flexible eletricity input get a subsidy corresponding to the lower-than-average electricity prices that they see, while
*'  inflexible technologies get a tax corresponding to the higher-than-average electricity prices that they see
*' * (0) flexibility tax off
*' * (1) flexibility tax on
*'
parameter
  cm_H2targets                "switches on capacity targets for electrolysis in NDC techpol following national Hydrogen Strategies"
;
  cm_H2targets = 0; !! def 0
*'
parameter
  cm_FlexTaxFeedback          "switch deciding whether flexibility tax feedback on buildings and industry electricity prices is on"
;
  cm_FlexTaxFeedback = 0;  !! def = 0  !! regexp = 0|1
*' cm_FlexTaxFeedback, switches on feedback of flexibility tax on buildings and industry.
*' That is, electricity price decrease for electrolysis has to be matched by electrictiy price increase in buildings and industry.
*' This switch only has an effect if the flexibility tax is on by cm_flex_tax set to 1.
*'
parameter
  cm_VRE_supply_assumptions        "default (0), optimistic (1), pessimistic (2), or very pessimistic (3) assumptions on VRE and storage costs"
;
  cm_VRE_supply_assumptions = 0;  !! def = 0  !! regexp = [0-3]
*' Modifies investment cost (inco0), floorcost and learning rate parameters for VRE and storage.
*' * (1) optimistic: reduces floor costs and investment costs and increases learning rates by around 10%. Also halves storage needs.
*' * (2) pessimistic: increases floor costs and investment costs and decreases learning rates by around 10%.
*' * (3) very pessimistic: increases floor costs and investment costs and decreases learning rates by around 30%.
*'
parameter
  cm_build_H2costAddH2Inv     "additional h2 distribution costs for low diffusion levels (default value: 6.5$/kg = 0.2 $/Kwh)"
;
  cm_build_H2costAddH2Inv = 0.2;  !! def = 6.5$/kg = 0.2 $/Kwh
*'
parameter
  cm_build_H2costDecayStart   "simplified logistic function end of full value (ex. 5%  -> between 0 and 5% the function will have the value 1). [%]"
;
  cm_build_H2costDecayStart = 0.05; !! def = 0.05
*'
parameter
  cm_build_H2costDecayEnd     "simplified logistic function start of null value (ex. 10% -> after 10% the function will have the value 0). [%]"
;
  cm_build_H2costDecayEnd = 0.1;  !! def = 0.1
*'
parameter
  cm_BioSupply_Adjust_EU      "factor for scaling sub-EU bioenergy supply curves"
;
  cm_BioSupply_Adjust_EU = 3; !! def 3, 3*bioenergy supply slope obtained from input data
*' scales bioenergy supply curves in EU regions (mainly used to match EUR H12/ 3 /GJ from 2030 onward, and 30$/GJ from 2040 onward, and 40$/GJ from 2040 onward.
*' scales slope of bioenergy supply curves in EU subregions (mainly used to match EUR H12/Magpie bioenergy potential)
*' switch can be removed once supply curves for EU subregions are fixed in input data
*'
parameter
  cm_noPeFosCCDeu              "switch to suppress Pe2Se Fossil Carbon Capture in Germany"
;
  cm_noPeFosCCDeu = 0;  !! def = 0  !! regexp = 0|1
*'  CCS limitations for Germany
*'  def 0, no suppression of Pe2Se Fossil Carbon Capture in Germany, if 1 then no pe2se fossil CO2 capture in Germany
*'  fossil CCS limitations in Germany+
*'
*' * (0) none
*' * (1) no fossil carbon and capture in Germany
*'

parameter
  c_fracRealfromAnnouncedCCScap2030         "switch to adjust the share of realised CCS capacities from total announced/planned projects from database in 2030"
;
  c_fracRealfromAnnouncedCCScap2030 = 0.3; !! def = 0.3
*' This switch changes the assumption about the share of timely realised capacities from sum of announced/planned in 2030 from the IEA CCS data base
*' Default assumption is that only 30% of announced or planned capacities will be realised, either due to discontinuation or delay

parameter
  cm_startIter_EDGET          "starting iteration of EDGE-T"
;
  cm_startIter_EDGET = 14;  !! def = 14, by default EDGE-T is run first in iteration 14  !! regexp = [0-9]+
*' EDGE-T transport starting iteration of coupling
*' def 14, EDGE-T coupling starts at 14, if you want to test whether infeasibilities after EDGE-T -> set it to 1 to check after first iteration
*'
parameter
  cm_deuCDRmax                 "switch to limit maximum annual CDR amount in Germany in MtCO2 per y"
;
  cm_deuCDRmax = -1; !! def = -1
*'  switch to cap annual DEU CDR amount by value assigned to switch, or no cap if -1, in MtCO2
parameter
  cm_EnSecScen_limit        "switch for limiting the gas demand from 2025 onward, currently only applied to Germany"
;
  cm_EnSecScen_limit = 0;  !! def = 0
*' This switch is used to represent a limited gas supply in a energy security scenario. [EJ per yr]
*'
*' * (0)                default, equals "off", no limit imposed
*' * (any other number) limit of gas demand from 2025 on in Germany in EJ/yr
*'
parameter
  c_SlackMultiplier   "Multiplicative factor to up/downscale the slack size for v_changeProdStartyearSlack"
;
  c_SlackMultiplier = 1;  !! def = 1
*'
parameter
  c_changeProdCost   "Multiplicative factor to up/downscale the costs for vm_changeProdStartyearCost"
;
  c_changeProdCost = 5;  !! def = 5
*'
parameter
  cm_LearningSpillover      "Activate Learningspillover from foreign capacity in learning technogolies"
;
  cm_LearningSpillover = 1; !! def 1 = Learningspillover activated (set to 0 to deactivate)
*'
*' * if Learningspillover is deactivated, foreign capacity is set to the level of 2020 in technology learning.
*' * This means that in the model, each region's learning depends on its OWN additional capacity investment after 2020 in comparison to the GLOBAL cumulative capacity until 2020,
*' * so for small regions learning is very slow. This is a very pessimistic interpretation of 'no learning spillovers',
*' * as every region has to climb up the global learning curve all by itself.
*' * In combination with endogenous carbon pricing (e.g., in NDC), the deactivated Learningspillover will lead to higher overall carbon prices. Can be solved by setting carbonprice to exogenous (config).
parameter
  cm_nonPlasticFeedstockEmiShare      "Share of non-plastic carbon that gets emitted  rest is stored permanently, [share]"
;
  cm_nonPlasticFeedstockEmiShare = 0.6; !! def 0.6 = 60 per cent of carbon in non-plastics gets emitted
*'
parameter
  cm_wastelag			"switch to decide whether waste from plastics lags ten years behind plastics production"
;
  cm_wastelag = 0;   !! def = 0 no waste lag  !! regexp = 1|0
*'
*'
*'
***-----------------------------------------------------------------------------
*' ####                     FLAGS
***-----------------------------------------------------------------------------
*' cm_MAgPIE_coupling    "switch on coupling mode with MAgPIE"
*'
*' *  (off): off = REMIND expects to be run standalone (emission factors are used, shiftfactors are set to zero)
*' *  (on): on  = REMIND expects to be run based on a MAgPIE reporting file (emission factors are set to zero because emissions are retrieved from the MAgPIE reporting, shift factors for supply curves are calculated)
$setglobal cm_MAgPIE_coupling  off     !! def = "off"  !! regexp = off|on
*' cm_rcp_scen       "chooses RCP scenario"
*'
*' *  (none): no RCP scenario, standard setting
*' *  (rcp20): RCP2.0
*' *  (rcp26): RCP2.6
*' *  (rcp37): RCP3.7 [currently not operational: test and verify before using it!]
*' *  (rcp45): RCP4.5
*' *  (rcp60): RCP6.0 [currently not operational: test and verify before using it!]
*' *  (rcp85): RCP8.5 [currently not operational: test and verify before using it!]
$setglobal cm_rcp_scen  rcp45         !! def = "rcp45"  !! regexp = none|rcp20|rcp26|rcp37|rcp45|rcp60|rcp85
*' cm_NDC_version            "choose version year of NDC targets as well as conditional vs. unconditional targets"
*' *  (2024_cond):   all NDCs conditional to international financial support published until August 31, 2024
*' *  (2024_uncond): all NDCs independent of international financial support published until August 31, 2024
*' *  (2023_cond):   all NDCs conditional to international financial support published until December 31, 2023
*' *  (2023_uncond): all NDCs independent of international financial support published until December 31, 2023
*' *  Other supported years are 2022, 2021 and 2018, always containing NDCs published until December 31 of that year
$setglobal cm_NDC_version  2024_cond    !! def = "2024_cond"  !! regexp = 20(18|2[1-4])_(un)?cond

*' cm_NPi_version            "choose version year of NPi targets for min and max targets in the form of conditional vs. unconditional"
*' *  (2024_cond):   minimum technology targets are included from NewClimate latest policy modeling protocol in 2025
*' *  (2024_uncond): maximal technology targets are included from NewClimate latest policy modeling protocol in 2025
$setglobal cm_NPi_version  2025_cond    !! def = "2025_cond"  !! regexp = 2025_(un)?cond

*' cm_netZeroScen     "choose scenario of net zero targets of netZero realization of module 46_carbonpriceRegi"
*'
*'  (NGFS_v4):        settings used for NGFS v4, 2023
*'  (NGFS_v4_20pc):   settings used for NGFS v4, 2023, with still 20% of 2020 emissions in netZero year
*'  (ELEVATE2p3):     settings used for ELEVATE2p3 LTS and NDC-LTS scenario
$setglobal cm_netZeroScen  NGFS_v4     !! def = "NGFS_v4"  !! regexp = NGFS_v4|NGFS_v4_20pc|ELEVATE2p3
*' *  c_regi_earlyreti_rate  "maximum percentage of capital stock that can be retired early (before reaching their expected lifetimes) in one year in specified regions, if they are not economically viable. It is applied to all techs unless otherwise specified in c_tech_earlyreti_rate."
*' *  GLO 0.09, EUR_regi 0.15: default value. (0.09 means full retirement after 11 years, 10% standing after 10 years)
$setglobal c_regi_earlyreti_rate  GLO 0.09, EUR_regi 0.15      !! def = GLO 0.09, EUR_regi 0.15
*' *  c_tech_earlyreti_rate  "maximum percentage of capital stock of specific technologies that can be retired early in one year in specified regions. This switch overrides c_regi_earlyreti_rate to allow for fine-tuning of phase-out schedules, e.g. for implementation of certain policies or anticipated trends."
*' *  GLO.(biodiesel 0.14, bioeths 0.1), EUR_regi.(biodiesel 0.15, bioeths 0.15), USA_regi.pc 0.13, REF_regi.pc 0.13, CHA_regi.pc 0.13: default value, including retirement of 1st gen biofuels, higher rate of coal phase-out for USA, REF and CHA
$setglobal c_tech_earlyreti_rate  GLO.(biodiesel 0.14, bioeths 0.14), EUR_regi.(biodiesel 0.15, bioeths 0.15), USA_regi.pc 0.13, REF_regi.pc 0.13, CHA_regi.pc 0.13 !! def = GLO.(biodiesel 0.14, bioeths 0.14), EUR_regi.(biodiesel 0.15, bioeths 0.15), USA_regi.pc 0.13, REF_regi.pc 0.13, CHA_regi.pc 0.13
*** cm_LU_emi_scen   "choose emission baseline for CO2, CH4, and N2O land use emissions from MAgPIE"
***  (SSP1): emissions (from SSP1 scenario in MAgPIE)
***  (SSP2): emissions (from SSP2 scenario in MAgPIE)
***  (SSP3): emissions (from SSP3 scenario in MAgPIE)
***  (SSP5): emissions (from SSP5 scenario in MAgPIE)
$setglobal cm_LU_emi_scen  SSP2   !! def = SSP2  !! regexp = SSP(1|2|3|5)|SSP2_lowEn
*** cm_regi_bioenergy_EFTax  "region(s) in which bioenergy is charged with an emission-factor-based tax"
***  This switch has only an effect if 21_tax is on and cm_bioenergy_EF_for_tax
***  is not zero. It reads in the regions that are affected by the emission-
***  factor-based bioenergy tax. Regions can be read in comma-separated
***  Examples:
***  (glob):                 default; all regions
***  (EUR):                  only Europe
***  (DEU):                  only Germany
***  (CAZ,EUR,JPN,NEU,USA):  only these five regions (more or less OECD)
$setGlobal cm_regi_bioenergy_EFTax  glob  !! def = glob
*** cm_tradbio_phaseout "Switch that allows for a faster phase out of traditional biomass"
***  (default):  Default assumption, reaching zero demand in 2100
***  (fast):     Fast phase out, starting in 2025 reaching zero demand in 2070 (close to zero in 2060)
$setglobal cm_tradbio_phaseout  default  !! def = default  !! regexp = default|fast
*** cm_maxProdBiolc  "Bound on global pebiolc production including residues but excluding traditionally used biomass [EJ per yr]"
***  (off):             (default) no bound
***  (100):             (e.g.) set maximum to 100 EJ per year
***  (any value ge 0):  set maximum to that value
$setglobal cm_maxProdBiolc  off  !! def = off  !! regexp = off|is.nonnegative
*** cm_bioprod_regi_lim
*** limit to total biomass production (including residues) by region to an upper value in EJ/yr from 2035 on
*** example: "CHA 20, EUR_regi 7.5" limits total biomass production in China to 20 EJ/yr and
*** limits in EU-regions (EUR region or EU-subregions) to 7.5 EJ/yr.
*** For region groups (e.g. EU27_regi), regional limits will be dissaggregated by 2005 total biomass production.
*** If you specify a value for a region within a region group (e.g. DEU in EU27_regi),
*** then the values from the region group disaggregation will be overwritten by this region-specific value.
*** For example: "EU27_regi 7.5, DEU 1.5".
$setGLobal cm_bioprod_regi_lim off  !! def off
*' cm_GDPpopScen  "assumptions about future GDP and population development"
*'  * (SSP1):  SSP1 fastGROWTH medCONV
*'  * (SSP2):  SSP2 medGROWTH medCONV
*'  * (SSP3):  SSP3 slowGROWTH slowCONV
*'  * (SSP4):  SSP4 medGROWTH mixedCONV
*'  * (SSP5):  SSP5 fastGROWTH fastCONV
*'  * (SDP|SDP_EI|SDP_MC|SDP_RC):   SDP scenarios
*'  * (SSP2IndiaMedium|SSP2IndiaHigh):   special India scenario
$setglobal cm_GDPpopScen   SSP2  !! def = SSP2  !! regexp = SSP[1-5]|SDP(_EI|_MC|_RC)?|SSP2IndiaMedium|SSP2IndiaHigh
*' c_techAssumptScen flag defines an energy technology scenario according to SSP narratives
*'  * (SSP1) optimistic for VRE, storage, BEV; pessimistic for nuclear and CCS
*'  * (SSP2) reference scenario - default investment costs & learning rates
*'  * (SSP3) optimistic for basic fossil technologies; pessimistic for nuclear and VRE
*'  * (SSP5) optimistic for advanced fossil technologies and CCS; pessimistic for nuclear and VRE
$setglobal c_techAssumptScen SSP2 !! def = SSP2  !! regexp = (SSP)?[1-5]
*** cm_oil_scen      "assumption on oil availability"
***  (lowOil): low
***  (medOil): medium (this is the new case)
***  (highOil): high (formerly this has been the "medium" case; RoSE relevant difference)
***  (4): very high (formerly this has been the "high" case; RoSE relevant difference)
$setGlobal cm_oil_scen  medOil         !! def = medOil  !! regexp = lowOil|medOil|highOil|4
*** cm_gas_scen      "assumption on gas availability"
***  (lowGas): low
***  (medGas): medium
***  (highGas): high
$setGlobal cm_gas_scen  medGas         !! def = medGas  !! regexp = lowGas|medGas|highGas
*** cm_coal_scen     "assumption on coal availability"
***  (0): very low (this has been the "low" case; RoSE relevant difference)
***  (lowCoal): low (this is the new case)
***  (medCoal): medium
***  (highCoal): high
$setGlobal cm_coal_scen  medCoal        !! def = medCoal  !! regexp = 0|lowCoal|medCoal|highCoal
*' c_ccsinjecrateRegi  "regional upper bound of the CCS injection rate, overwrites for specified regions the settings set with c_ccsinjecratescen"
*'  * ("off") no regional differentiation
*'  * ("GLO 0.005") reproduces c_ccsinjecratescen = 1
*'  * ("GLO 0.00125, CAZ_regi 0.0045, CHA_regi 0.004, EUR_regi 0.0045, IND_regi 0.004, JPN_regi 0.002, USA_regi 0.002") "example that is taylored such that NDC goals are achieved without excessive CCS in a delayed transition scenario. Globally, 75% reduction, 10% reduction in CAZ etc. compared to reference case with c_ccsinjecratescen = 1"
$setglobal c_ccsinjecrateRegi  off  !! def = "off"
*** c_SSP_forcing_adjust "chooses forcing target and budget according to SSP scenario such that magicc forcing meets the target";
***   ("forcing_SSP1") settings consistent with SSP 1
***   ("forcing_SSP2") settings consistent with SSP 2
***   ("forcing_SSP5") settings consistent with SSP 5
$setglobal c_SSP_forcing_adjust  forcing_SSP2   !! def = forcing_SSP2  !! regexp = forcing_SSP(1|2|3|5)
*** cm_regiExoPrice "set exogenous co2 tax path for specific regions using a switch, require regipol module to be set to regiCarbonPrice (e.g. GLO.(2025 38,2030 49,2035 63,2040 80,2045 102,2050 130,2055 166,2060 212,2070 346,2080 563,2090 917,2100 1494,2110 1494,2130 1494,2150 1494) )"
$setGlobal cm_regiExoPrice  off    !! def = off
*** cm_emiMktTarget "set a budget or year emission target, for all (all) or specific emission markets (ETS, ESD or other), and specific regions (e.g. DEU) or region groups (e.g. EU27)"
***   Example on how to use:
***     cm_emiMktTarget = '2020.2050.EU27_regi.all.budget.netGHG_noBunkers 72, 2020.2050.DEU.all.year.netGHG_noBunkers 0.1'
***     sets a 72 GtCO2eq budget target for European 27 countries (EU27_regi), for all GHG emissions excluding bunkers between 2020 and 2050; and a 100 MtCO2 CO2eq emission target for the year 2050, for Germany"
***     cm_emiMktTarget = 'nzero'
***     loads hard-coded options for regional target scenarios defined in the module '47_regipol/regiCarbonPrice' declarations file.
***     The 'nzero' scenario applies declared net-zero targets for countries explicitly handled by the model (DEU, CHA, USA, IND, JPN, UKI, FRA and EU27_regi)
***     Requires regiCarbonPrice realization in regipol module
$setGlobal cm_emiMktTarget  off    !! def = off
*** Tolerance for regipol emission target deviations convergence.
*** For budget targets the tolerance is measured relative to the target value. For year targets the tolerance is relative to 2005 emissions.
***   def = GLO 0.01, i.e. regipol emission targets must be met within 1% of target deviation
***   Example on how to use:
***      cm_emiMktTarget_tolerance = 'GLO 0.004, DEU 0.01'. All regional emission targets will be considered converged if they have at most 0.4% of the target deviation, except for Germany that requires 1%.
$setGlobal cm_emiMktTarget_tolerance  GLO 0.01    !! def = GLO 0.01
*** cm_scaleDemand - Rescaling factor on final energy and usable energy demand, for selected regions and over a phase-in window.
*** Requires re-calibration in order to work.
***   Example on how to use:
***     cm_scaleDemand = '2020.2040.(EUR,NEU,USA,JPN,CAZ) 0.75' applies a 25% demand reduction on those regions progressively between 2020 (100% demand) and 2040 (75% demand).
$setGlobal cm_scaleDemand  off    !! def = off
*** cm_quantity_regiCO2target "emissions quantity upper bound from specific year for region group."
***   Example on how to use:
***     '2050.EUR_regi.netGHG 0.000001, obliges European GHG emissions to be approximately zero from 2050 onward"
$setGlobal cm_quantity_regiCO2target  off !! def = off
*** cm_dispatchSetyDown <- "off", if set to some value, this allows dispatching of pe2se technologies,
*** i.e. the capacity factors can be varied by REMIND and are not fixed. The value of this switch gives the percentage points by how much the lower bound of capacity factors should be lowered.
*** Example: if set to 10, then the CF of all pe2se technologies can be decreased by up to 10% from the default value
*** Setting capacity factors free is numerically expensive but can be helpful to see if negative prices disappear in historic years as the model is allowed to dispatch.
$setGlobal cm_dispatchSetyDown  off   !! def = off  The amount that te producing any sety can dispatch less (in percent) - so setting "20" in a cm_dispatchSetyDown column in scenario_config will allow the model to reduce the output of this te by 20%
*** cm_dispatchSeelDown <- "off", same as cm_dispatchSetyDown but only provides range to capacity factors of electricity generation technologies
*** cm_steel_secondary_max_share_scenario
*** defines maximum secondary steel share per region
*** Share is faded in from cm_startyear or 2020 to the denoted level by region/year.
*** Example: "2040.EUR 0.6" will cap the share of secondary steel production at 60 % in EUR from 2040 onwards
$setGlobal cm_dispatchSeelDown  off   !! def = off  The amount that te producing seel can dispatch less (in percent) (overrides cm_dispatchSetyDown for te producing seel)
*' *   cm_NucRegiPol "enable European region specific nuclear phase-out and new capacitiy constraints"
$setGlobal cm_NucRegiPol   on   !! def = on
*' *  cm_CoalRegiPol "enable European region specific coal phase-out and new capacitiy constraints"
$setGlobal cm_CoalRegiPol   on   !! def = on
*' *  cm_proNucRegiPol "enable European region specific pro nuclear capacitiy constraints"
$setGlobal cm_proNucRegiPol   off   !! def = off
*** cm_CCSRegiPol - year for earliest investment in Europe, with one timestep split between countries currently exploring - Norway (NEN), Netherlands (EWN) and UK (UKI) - and others
$setGlobal cm_CCSRegiPol     off   !! def = off
*** cm_vehiclesSubsidies - If "on" applies country specific BEV and FCEV subsidies from 2020 onwards
$setGlobal cm_vehiclesSubsidies  off !! def = off
*** cm_implicitQttyTarget - Define quantity target for primary, secondary, final energy or CCS (PE, SE and FE in TWa, or CCS and OAE in Mt CO2) per target group (total, biomass, fossil, VRE, renewables, synthetic, ...).
***   The target is achieved by an endogenous calculated markup in the form or a tax or subsidy in between iterations.
***   If cm_implicitQttyTargetType is set to "config", the quantity targets will be defined directly in this switch. Check below for examples on how to do this.
***   If cm_implicitQttyTargetType is set to "scenario", you should define the list of pre-defined scenarios hard-coded in module '47_regipol' that should be active for the current run (this avoids reaching the 255 characters limit in more complex definitions).
***   Example on how to use the switch with cm_implicitQttyTargetType = config:
***     cm_implicitQttyTarget  "2030.EU27_regi.tax.t.FE.all 1.03263"
***       Enforce a tax (tax) that guarantees that the total (t=total) Final Energy (FE.all) in 2030 (2030) is at most the Final energy target in the Fit For 55 regulation in the European Union (EU27_regi) (1.03263 Twa).
***       The p47_implicitQttyTargetTax parameter will contain the tax necessary to achieve that goal. (777.8 Mtoe = 777.8 * 1e6 toe = 777.8 * 1e6 * 41.868 GJ = 777.8 * 1e6 * 41.868 * 1e-9 EJ = 777.8 * 1e6 * 41.868 * 1e-9 * 0.03171 TWa = 1.03263 TWa)
***     cm_implicitQttyTarget "2050.GLO.sub.s.FE.electricity 0.8". The p47_implicitQttyTargetTax parameter will contain the subsidy necessary to achieve that goal.
***       Enforce a subsidy (sub) that guarantees a minimum share (s) of electricity in final energy (FE.electricity) equal to 80% (0.8) from 2050 (2050) onward in all World (GLO) regions.
***       The p47_implicitQttyTargetTax parameter will contain the subsidy necessary to achieve that goal.
***     To limit CCS to 8 GtCO2 and BECCS to 5 GtCO2, use "2050.GLO.tax.t.CCS.all 8000, 2050.GLO.tax.t.CCS.biomass 5000"
***   Example on how to use the switch with cm_implicitQttyTargetType = scenario:
***     cm_implicitQttyTarget  "EU27_RpEUEff,EU27_bio4"
***       "EU27_RpEUEff" -> Enforce a tax that guarantees total FE will be lower or equal to the RePowerEU target for 2030.
***       "EU27_bio4" -> Enforce a tax that garantees that EU27 biomass use will be lower or equal to the 4EJ in 20235 and 2050.
$setGlobal cm_implicitQttyTarget  off !! def = off
***  cm_implicitQttyTargetType - Define if the quantity target switch cm_implicitQttyTarget contains explicit values for defining the targets (config) or if it contains scenario names to reflect hard-coded options (scenario).
$setGlobal cm_implicitQttyTargetType  config !! def = config !! regexp = config|scenario
*** cm_loadFromGDX_implicitQttyTargetTax "load p47_implicitQttyTargetTax values from gdx for first iteration. Usefull for policy runs."
$setGlobal cm_loadFromGDX_implicitQttyTargetTax  off  !! def = off  !! regexp = off|on
*** cm_implicitQttyTarget_delay "delay the start of the quantity target algorithm either to:
***   (1) start only after iteration i, by setting "cm_implicitQttyTarget_delay = iteration i", or
***   (2) start only after the emission targets converged for the model, for both "modules/45_carbonprice" and "modules/47_regipol", by setting "cm_implicitQttyTarget_delay = emiConv x", or
***   (3) start only after regional emission target is close to convergence, by setting "cm_implicitQttyTarget_delay = emiRegiConv x", which forces the quantity target to start only after x times the cm_emiMktTarget_tolerance is achieved.
***      e.g., if "cm_emiMktTarget_tolerance = 0.01", i.e. 1% of deviation, and "cm_implicitQttyTarget_delay = emiRegiConv 5", the quantity target algorithm will only start after the emission target achieved a number lower than 5% (0.01 * 5)."
***      option 3 should only be used if the target is defined for a region that has its carbon pricing controlled by cm_emiMktTarget in the 47_regipol module.
$setGlobal cm_implicitQttyTarget_delay  iteration 15  !! def = iteration 15, quantity targets only start after iteration 15
*** cm_implicitPriceTarget "define tax/subsidies to match FE prices defined in the pm_implicitPriceTarget parameter."
***   Acceptable values: "off", "initial", "elecPrice", "H2Price", "highElec", "highGasandLiq", "highPrice", "lowElec", "lowPrice"
$setGlobal cm_implicitPriceTarget  off  !! def = off  !! regexp = off|initial|elecPrice|H2Price|highElec|highGasandLiq|highPrice|lowElec|lowPrice
*** cm_implicitPePriceTarget "define tax/subsidies to match PE prices defined in the pm_implicitPePriceTarget parameter."
***   Acceptable values: "off", "highFossilPrice".
$setGlobal cm_implicitPePriceTarget  off  !! def = off  !! regexp = off|highFossilPrice
*** cm_VREminShare "minimum variable renewables share requirement for given region and given year."
***   Example on how to use:
***     cm_VREminShare = "2050.EUR_regi 0.7".
***       Require a minimum 70% VRE share (wind plus solar) in electricity production for all regions that belong to EUR in year 2050."
$setGlobal cm_VREminShare    off !! def = off
*** cm_CCSmaxBound "limits Carbon Capture and Storage (including DACCS and BECCS) to a maximum value."
***   Example on how to use:
***     cm_CCSmaxBound   GLO 2, EUR 0.25
***     amount of Carbon Capture and Storage (including DACCS and BECCS) is limited to a maximum of 2GtCO2 per yr globally, and 250 Mt CO2 per yr in EU28.
***   This switch only works for model native regions. If you want to apply it to a group region use cm_implicitQttyTarget instead.
$setGlobal cm_CCSmaxBound    off  !! def = off
*** cm_33_EW_maxShareOfCropland
*** limit the share of cropland on which rocks can be spread. Affects the maximum total amount of rocks weathering on fields.
*** example: "GLO 1, LAM 0.5" limits amount of rocks weathering on cropland in LAM to 50% of max value if all LAM cropland were used.
$setglobal cm_33_EW_maxShareOfCropland GLO 0.5 !! def = GLO 0.5
*** cm_33_GDP_netNegCDR_maxShare
*** limit the expenses for net negative emissions based on share in GDP. Default is GLO 1, i.e. limit = total GDP
*** example: "GLO 1, LAM 0.1" limits spending on net negative emissions to 10% of GDP for LAM
$setglobal cm_33_GDP_netNegCDR_maxShare GLO 1 !! def = GLO 1
*** c_tech_CO2capturerate "changes CO2 capture rate of carbon capture technologies"
***   Example on how to use:
***     c_tech_CO2capturerate   bioh2c 0.8, bioftcrec 0.4
***   This sets the CO2 capture rate of the bioh2c technology to 80% and the capture of bioftcrec (Bio-based Fischer-Tropsch with carbon capture)
***   to 40%. The capture rate here is measured as carbon captured relative to the total carbon content of the input fuel (including carbon that is converted into the output fuel).
***   Note: The change in capture rate via this switch follows directly after reading in the generisdata_emi.prn file. Hence, the subsequent corrections of the capture rate
***   related to CO2 pipeline leakage still come on top of this.
$setGlobal c_tech_CO2capturerate    off  !! def = off
*** c_CES_calibration_new_structure      <-   0        switch to 1 if you want to calibrate a CES structure different from input gdx
$setglobal c_CES_calibration_new_structure  0     !!  def  =  0  !! regexp = 0|1
*** c_CES_calibration_write_prices       <-   0       switch to 1 if you want to generate price file, you can use this as new p29_cesdata_price.cs4r price input file
$setglobal c_CES_calibration_write_prices  0     !!  def  =  0  !! regexp = 0|1
*** cm_CES_calibration_default_prices    <-   0.01    # def <-  0.01 lower value if input factors get negative shares (xi), CES prices in the first calibration iteration
$setglobal cm_CES_calibration_default_prices  0.01  !!  def  =  0.01
*** cm_in_limit_price_change sets production factors that have their price changes limited to a factor of two during calibration"
$setglobal cm_in_limit_price_change "ue_steel_primary, kap_steel_primary"   !! def = ""
*** cm_calibration_string "def = off, else = additional string to include in the calibration name to be used" label for your calibration run to keep calibration files with different setups apart (e.g. with low elasticities, high elasticities)
$setglobal cm_calibration_string  off    !!  def  =  off
*** cm_techcosts -     use regionalized or globally homogenous technology costs for certain technologies
*** (REG) regionalized technology costs with linear convergence between 2020 and year c_teNoLearngConvEndYr
*** (REG2040) regionalized technology costs given by p_inco0 until 2040, then stable without convergence
*** (GLO) globally homogenous technology costs
$setglobal cm_techcosts  REG       !! def = REG  !! regexp = REG|REG2040|GLO
*** cm_floorCostScen regionally differentiated floor cost scenarios
*** (default) uniform floor cost (almost no regional differentiation)
*** (pricestruc) regionally differentiated floor costs, the differentiated costs have the same ratio between regions as the ratio between 2020 tech cost values
*** (techtrans) regionally differentiated floor costs, which are the universal global floor costs in the default case time the MER PPP price ratios. new floor cost = MER/PPP * old floor cost
$setglobal cm_floorCostScen default       !! def = default
*** cfg$gms$cm_EDGEtr_scen  "the EDGE-T scenario"  # def <- "Mix1". For calibration runs: Mix1. Mix2, Mix3, Mix4 also available - numbers after the "mix" denote policy strength, with 1 corresponding roughly to Baseline/NPI, 2= NDC, 3= Budg1500, 4 = Budg800
***  The following descriptions are based on scenario results for EUR in 2050 unless specified otherwise.
***  Whenever we give numbers, please be aware that they are just there to estimate the ballpark.
***  Please note also that all cm_EDGEtr_scen share roughly the same overall energy service demand
***  the ES demand level is governed by the demScen switch.
***  (Mix1) the transport sektor "baseline". Consistent with a no- to low-mitigation scenario.
***         Low BEV or FCEV shares, electrification rate around 1/4th to 1/3rd of LDV
***         energy service demands in 2050. Similar shares for trucks.
***         Mode shares: Continuation of existing trends as prescribed in the SSP scenario.
***         For SSP2 this means roughly constant mode shares.
***  (Mix4) the high ambition scenario. Consistent with a 1.5 C or 2 C scenario.
***         LDVs: High BEV shares, electrification rates for LDVs almost 90% in 2050 (numbers can vary).
***         Trucks: high electrification of up to 80%.
***         Busses: BEV rates almost 70% in 2050.
***         Trains: electric train shares go up to 85% globally (from 60% 2015)
***         Aviation: there is some hydrogen aviation in 2050 but all in all it is negligible
***         Ships: there are no technical alternatives in EDGE-T at the moment.
***         Mode shares:
***           almost a doubling of the train share in 2050
***           doubling of non-motorized shares (4% to 8%)
***           consequently reduced LDV mode shares (~75% - 68% for EUR, just to give order of magnitude,
***             there is no effect globally in that regard due the developing regions)
***           constant mode shares for busses.
***  The other scenarios (Mix2) and (Mix3) can be found at roughly 1/3rd and 2/3rd of the ambition level
***  of Mix4.
***  ("HydrHype4") similar to Mix4 but with a strong focus on FCEVs in both passenger and freight sectors.
***  This information has been added on 4.10.22. Please contact the transport sector experts for more detail.
$setGlobal cm_EDGEtr_scen  Mix2ICEban  !! def = Mix2ICEban
*** industry
*** maximum secondary steel share
$setglobal cm_steel_secondary_max_share_scenario  off !! def off , switch on for maximum secondary steel share
*** cm_import_tax
*** set tax on imports for specific regions on traded energy carriers
*** as a fraction of import price
*** example: "EUR.pebiolc.worldPricemarkup 0.5" means bioenergy imports to EUR see 50% tax on top of world market price.
*** If you specify a value for a region within a region group (e.g. DEU in EU27_regi),
*** then the values from the region group disaggregation will be overwritten by this region-specific value.
*** For example: "DEU.pegas.worldPricemarkup 3, EU27_regi.pegas.worldPricemarkup 1.5".
*** Other options are taxCO2markup and avtaxCO2markup that tax imported CO2 emission (i.e emissions associated to imports of energy carriers)
*** with the national CO2 price (CO2taxmarkup) or the max between national and average CO2 price (avCO2taxmarkup).
*** Example: "GLO.(pecoal,pegas,peoil).CO2taxmarkup 1" implements a global CO2 tax markup for imports.
*** Using different markups for each fossil PE is not recommended, "Price|Carbon|Imported" will then report an unweighted average.
*** NOTE: In case of "CO2taxmarkup" and "avCO2taxmarkup" there is double-taxation of the CO2-content of the imported energy carrier:
*** Once when being imported (at the border) and once when being converted to Secondary Energy (normal CO2price applied by REMIND)
*** In combination with endogenous carbon pricing, the import tax will lead to lower overall carbon prices. Can be solved by setting carbonprice to exogenous (config).
$setGlobal cm_import_tax off !! def = off  !! regexp = .*(worldPricemarkup|CO2taxmarkup|avCO2taxmarkup|off).*
*** cm_import_EU                "EU switch for different scenarios of EU SE import assumptions"
*** EU-specific SE import assumptions (used for ariadne)
*** different exogenous hydrogen import scenarios for EU regions (developed in ARIADNE project)
*** "bal", "low_elec", "high_elec", "low_h2", "high_h2", "low_synf", "high_synf", "nzero"
*** see 24_trade/se_trade/datainput for H2 import assumptions, this switch only works if the trade realization "se_trade" is selected
$setGlobal cm_import_EU  off !! def off
*** cm_import_ariadne        "Germany-specific H2 imports assumptions for Ariadne project (needs cm_import_EU to be on)"
*** def <- "off", if import assumptions for Germany in Ariadne project -> switch to "on"
*** switch for ariadne import scenarios (needs cm_import_EU to be not off)
*** this switch activates ARIADNE-specific H2 imports for Germany, it requires that cm_import_EU is not "off"
*** (on) ARIADNE-specific H2 imports for Germany, rest EU has H2 imports from cm_import_EU switch
*** (off) no ARIADNE-specific H2 imports for Germany
$setGlobal cm_import_ariadne  off !! def off
*** cm_PriceDurSlope_elh2, slope of price duration curve for electrolysis (increase means more flexibility subsidy for electrolysis H2)
*** It parameterizes how much the electricity price for electrolysis is reduced relative to the annual average electricity price
*** This switch only has an effect if the flexibility tax is on by cm_flex_tax set to 1
*** Default value is based on data from German Langfristszenarien derived by the power system model Enertile.
*** It is derived by fitting a linear function to capture the relation between electrolysis electricity price and electrolysis share in total electricity demand
*** See https://github.com/remindmodel/development_issues/issues/404 for details.
$setGlobal cm_PriceDurSlope_elh2 GLO 20 !! def = GLO 20
*** cm_trade_SE_exog
*** set exogenous SE trade scenarios (requires se_trade realization of modul 24 to be active)
*** e.g. "2030.2050.MEA.DEU.seh2 0.5", means import of SE hydrogen from MEA to Germany from 2050 onwards of 0.5 EJ/yr,
*** linear scale-up of trade in 2030-2050 period.
*** For region groups (e.g. EU27_regi), trade flows will be dissaggregated by GDP share.
*** If you specify trade flows for a region within a region group,
*** then the values from the region group disaggregation will be overwritten by this region-specific value.
*** For example: "2030.2050.MEA.EU27_regi.seh2 0.5, 2030.2050.MEA.DEU.seh2 0.3".
$setGlobal cm_trade_SE_exog off !! def off
*** This allows to manually adjust the ramp-up curve of the SE tax on electricity. It is mainly used for taxing electricity going into electrolysis for green hydrogen production.
*** The ramp-up curve is a logistic function that determines how fast taxes increase with increasing share of technology in total power demand.
*** This essentially makes an assumption about to what extend the power demand of electrolysis will be taxed and how much tax exemptions there will be at low shares of green hydrogen production
*** The parameter a defines how fast the tax increases with increasing share, with 4/a being the percentage point range over which the tax value increases from 12% to 88%
*** The parameter b defines at which share the tax is halfway between the value at 0 share and
*** the maximum value (defined by a region's electricity tax and the electricity grid cost) that it converges to for high shares.
*** Example use:
*** cm_SEtaxRampUpParam = "GLO.elh2.a 0.2, GLO.elh2.b 20" sets the logistic function parameter values a=0.2 and b=20 for electrolysis (elh2) to all model regions (GLO).
*** cm_SEtaxRampUpParam = "off" disables v21_tau_SE_tax
*** Default:
*** cm_SEtaxRampUpParam = "GLO.elh2.a 0.2, GLO.elh2.b 20, EUR_regi.elh2.a 0.15, EUR_regi.elh2.b 40"
*** This means that electrolysis tax is at half of electricity taxation at 40% electrolysis share in power demand for European regions, and half at 20% share for the rest of the world.
*** We anticipate this lower taxation share in Europe, because Europe has particularly high electricity taxes compared to the rest of the world.
*** For details, please see ./modules/21_tax/on/equations.gms.
$setGlobal cm_SEtaxRampUpParam  GLO.elh2.a 0.2, GLO.elh2.b 20, EUR_regi.elh2.a 0.15, EUR_regi.elh2.b 40    !! def = GLO.elh2.a 0.2, GLO.elh2.b 20, EUR_regi.elh2.a 0.15, EUR_regi.elh2.b 40
*** cm_EnSecScen             "switch for running an ARIADNE energy security scenario, introducing a tax on PE fossil energy in Germany"
*** switch on energy security scenario for Germany (used in ARIADNE project), sets tax on fossil PE
*** switch to activate energy security scenario assumptions for Germany including additional tax on gas/oil
*** (on) energy security scenario for Germany
*** (off) no energy security scenario
$setGlobal cm_EnSecScen  off !! def off
*** cm_EnSecScen_price        "switch on tax on PE gas to simulate continued energy crisis in Germany for ARIADNE energy security scenario"
***  (off) default
***  (on)  switch on tax on PE gas and oil from 2025 in Germany
$setGlobal cm_EnSecScen_price  off !! def off
*** cm_indstExogScen           "choose data source for exogenous industry production fix"
***  (off)            default, no fixing
***  (forecast_bal)   fix to forecast outputs as used in the ARIADNE scenario "Balanced"
***  (forecast_ensec) fix to forecast outputs as used in the ARIADNE scenario "EnSec"
$setGlobal cm_indstExogScen  off !! def off
*** cm_exogDem_scen
*** switch to fix FE or ES demand represented in CES function to trajectories
*** from exogenous sources (not EDGE models) given in file p47_exogDemScen.
*** This switch fixes demand without recalibration of REMIND CES parameters.
*** This should be kept in mind when comparing those runs to baseline runs without fixing
*** as the fixing shifts the CES function away from its optimal point based on the CES parameters used.
*** Warning: the formulation fixing CES quantity nodes in scenarios should be used with care and parsimony.
*** Price and tax-induced solutions are preferable from the REMIND formulation perspective
*** and consequences of fixing CES tree nodes directly require further investigation.
*** (off)              default, no fixing
*** (ariadne_bal)      steel and cement production trajectories for Germany used in the Ariadne "Balanced" scenario
*** (ariadne_ensec)    steel and cement production trajectories for Germany used in the Ariadne "EnSec" (energy security) scenario
*** (ariadne_highDem)
*** (ariadne_lowDem)
$setGLobal cm_exogDem_scen off !! def off  !! regexp = off|ariadne_(bal|ensec|highDem|lowDem)
*** cm_Ger_Pol               "switch for selecting different policies for Germany used in the ARIADNE scenarios"
*** switch for Germany-specific policies
*** (off) default
*** (ensec) policies for energy security scenario, e.g. faster hydrogen upscaling
$setGlobal cm_Ger_Pol  off !! def off
*** cm_altFeEmiFac <- "off"  # def <- "off", regions that should use alternative data from "umweltbundesamt" on emission factors for final energy carriers (ex. "EUR_regi, NEU_regi")
$setGlobal cm_altFeEmiFac  EUR_regi, NEU_regi        !! def = "EUR_regi, NEU_regi"
***  cm_incolearn "change floor investment cost value"
***   Example on how to use:
***     cm_incolearn  "windon=1600,spv=5160,csp=9500"
***       floor investment costs from learning set to 1600 for wind onshore, 5160 for solar photovoltaic and 9500 for concentrated solar power.
$setglobal cm_incolearn  off !! def = off
*** cm_storageFactor "scale curtailment and storage requirements. [factor]"
***   def <- "off" = no change for curtailment and storage requirements;
***   or number (ex. 0.66), multiply by 0.66 to resize the curtailment and storage requirements per region from the default REMIND values.
$setglobal cm_storageFactor  off !! def = off
*** cm_learnRate "change learn rate value by technology."
***   def <- "off" = no change for learn rate value;
***   or list of techs to change learn rate value. (ex. "spv 0.2")
$setglobal cm_learnRate  off !! def = off
*** cm_adj_seed and cm_adj_seed_cont "overwrite the technology-dependent adjustment cost seed value. Smaller means slower scale-up."
***   both swicthes have the same functionality, but allow more changes once the character limit of cm_adj_seed is reached.
***   def <- "off" = use default adj seed values.
***   or list of techs to change adj_seed value. (ex. "spv=1, tnrs = 0.1")
$setglobal cm_adj_seed  off
$setglobal cm_adj_seed_cont  off
*** cm_adj_coeff and cm_adj_coeff_cont "overwrite the technology-dependent adjustment cost coefficient. Higher means higher adjustment cost."
***   both swicthes have the same functionality, but allow more changes once the character limit of cm_adj_coeff is reached.
***   def <- "off" = use default adj coefficient values.
***   or list of techs to change adj_coeff value. (ex. "gash2=1, hydro=0.1")
$setglobal cm_adj_coeff  off
$setglobal cm_adj_coeff_cont  off
*** cm_adj_seed_multiplier "rescale adjustment cost seed value relative to default value. [factor]. Smaller means slower scale-up."
***   def <- "off" = use default adj seed values.
***   or list of techs to change adj_seed value by a multiplication factor. (ex. "spv 0.5, storspv 0.5, windon 0.25")
$setglobal cm_adj_seed_multiplier  off
*** cm_adj_coeff_multiplier "rescale adjustment cost coefficient value relative to default value. [factor]. Higher means higher adjustment cost."
***   def <- "off" = use default adj coefficient values.
***   or list of techs to change adj_cost value by a multiplication factor. (ex. "spv 2, storspv 2, windon 4")
*** A note on adjustment cost changes: A common practice of changing the adjustment cost parameterization is by using the same factor to
*** increase the adjustment cost coefficent and to decrease the adjustment cost seed value at the same time.
$setglobal cm_adj_coeff_multiplier  off
*** cm_inco0Factor "change investment costs. [factor]."
*' *  (off): no scale-factor, use default investment costs (inco0) values
*' *  (any value ge 0) list of techs with respective factor to change inco0 value by a multiplication factor. (e.g. "ccsinje 0.5,bioigccc 0.66)
*'  Note: if %cm_techcosts% == "GLO", switch will not work for policy runs, i.e. cm_startyear > 2005, for pc, ngt and ngcc as this gets overwritten in 05_initialCap module
$setglobal cm_inco0Factor  off !! def = off
*** cm_inco0RegiFactor "change investment costs regionalized technology values. [factor]."
*' *  def <- "off" = use default p_inco0 values.
*' *  or list of techs with respective factor to change p_inco0 value by a multiplication factor. (ex. "windon 0.33, spv 0.33" makes investment costs for windon and spv 3 times cheaper)
*' *  (note: if %cm_techcosts% == "GLO", switch will not work for policy runs, i.e. cm_startyear > 2005, for pc, ngt and ngcc as this gets overwritten in 05_initialCap module)
$setglobal cm_inco0RegiFactor  off  !! def = off
*** cm_CCS_markup "multiplicative factor for CSS cost markup"
***   def <- "off" = use default CCS pm_inco0_t values.
***   or number (ex. 0.66), multiply by 0.66 the CSS cost markup
$setglobal cm_ccsinjeCost med !! def = med !! regexp = med|low|high
*' switch from standard to low and high CO2 transport & storage cost.
*' Warning: it applies absolute values; only use it in combination with default c_techAssumptScen SSP2. 
*'  * (low): old estimate before 03/2024; ~7.5 USD/tCO2 in 2035. Also applies tech_stat=2 and constrTme=0
*'  * (med): new main estimate; 12 USD/tCO2 at all times (similar to ~11.4 USD/tCO2 average of saline formations, on- and offshore DOG fields in Budinis et al 2017)
*'  * (high): upper estimate; ~20USD/tCO2 (constant), assuming upper end of storage cost and long transport distances
$setglobal cm_CCS_markup  off  !! def = off
*** cm_Industry_CCS_markup "multiplicative factor for Industry CSS cost markup"
***   def <- "off"
***   or number (ex. 0.66), multiply by 0.66 Industry CSS cost markup
$setglobal cm_Industry_CCS_markup  off !! def = off
*** cm_renewables_floor_cost "additional floor cost for renewables"
***   def <- "off" = use default floor cost for renewables.
***   or list of techs with respective value to be added to the renewables floor cost in Europe
$setglobal cm_renewables_floor_cost  off  !! def = off
*** cm_sehe_upper "secondary energy district heating and heat pumps upper bound"
***   def <- "off" = no additional limit for district heating and heat pumps.
***   or number (ex. 2), district heating and heat pumps are limited to an upper bound of 2 times the 2020 model values.
$setglobal cm_sehe_upper  off !! def = off
*** cm_rcp_scen_build     "chooses RCP scenario for demand in buildings (climate change impact)"
$setglobal cm_rcp_scen_build  none   !! def = "none"
*** cfg$gms$cm_pushCalib          <- "none" #def <- "none" , "hydrogen" also possible. Reduction of calibration factor over time in logit
$setGlobal cm_pushCalib  none  !! def = none
*** cfg$gms$cm_reducCostB         <- "none" #def <- "none" , "hydrogen" and "heatpumps" also possible. Reduction of costs
$setGlobal cm_reducCostB  none  !! def = none
*** cfg$gms$cm_effHP         <- 5 #def <- 5 , efficiency of heat pumps
$setGlobal cm_effHP  5  !! def = 5

*** Note on CES markup cost:
*** They represent the sector-specific demand-side transformation cost, can also
*** be used to influence efficiencies during calibration as higher markup-cost
*** in calibration will lead to higher efficiencies.
***
*** cm_CESMkup_build "switch for setting markup cost to CES nodes in buildings"
*** def = "standard", applies a markup cost of 200 USD/MWh(el) to heat pumps
*** (feelhpb) and 25 USD/MWh(heat) to district heating (feheb)
*** CES markup cost for buildings to represent sector-specific demand-side
*** transformation cost (only applies to buildings realization "simple" for
*** now).
*** To change them to any specific value, set cm_CESMkup_build to e.g.
*** "feelhpb 0.876".  This will apply a cost markup of $tr 0.876/TWa (equivalent
*** to $100/MWh(el)).  Standard cost markups of the other nodes will remain
*** unchanged, unless you explicity address them with this switch.
$setGlobal cm_CESMkup_build  standard  !! def = standard

*** cm_CESMkup_ind "switch for setting markup cost to CES nodes in industry"
*** def = "standard", applies the following cost markups:
***
*** realisation  | ppfen                | markup
*** -------------+----------------------+-------------
*** subsectors   | feelhth_chemicals    | 100 $/MWh(el)
*** subsectors   | feel_steel_secondary | 100 $/MWh(el)
*** subsectors   | feelhth_otherInd     | 300 $/MWh(el)
*** subsectors   | feh2_cement          | 100 $/MWh(th)
*** subsectors   | feh2_chemicals       | 100 $/MWh(th)
*** subsectors   | feh2_steel           |  50 $/MWh(th)
*** subsectors   | feh2_otherInd        |  50 $/MWh(th)
***
*** To change them to any specific value, either define a new setting besides
*** "standard" in ./modules/37_industry/subsectors/datainput.gms,
*** or use the setting "manual" and set cm_CESMkup_ind_data to e.g. "feelhth_chemicals 0.8".
*** This would apply a cost markup of 0.8 $tr/TWa (100 $/MWh(el)) to the feelhth_chemicals
*** CES node.  Standard markup costs are not effected unless specifically
*** addressed in cm_CESMkup_ind_data.
$setGlobal cm_CESMkup_ind        standard  !! def = standard
$setGlobal cm_CESMkup_ind_data   ""        !! def = ""

*** cm_fxIndUe "switch for fixing UE demand in industry to baseline level - no endogenous demand adjustment"
*** off: endogenous demand.
*** on: exogenous demand fixed to baseline/NPi level (read in from input_ref.gdx)
*** cm_fxIndUeReg "indicates the regions under which the industry demand will be fixed, requires cm_fxIndUe set to on"
*** examples:
*** SSA,NEU,CHA,IND,OAS,MEA,LAM: gives a scenario where all non global north (non-OECD) industry demand is fixed to baseline
*** GLO: fixes industry demand to baseline level everywhere
$setGlobal cm_fxIndUe        off   !! def = off  !! regexp = off|on
$setGlobal cm_fxIndUeReg     ""    !! def = ""

*** cm_taxCO2_functionalForm "switch for choosing the functional form of the global anchor trajectory in 45_carbonprice/functionalForm"
*** (linear): The linear curve is determined by the two points (cm_taxCO2_historicalYr, cm_taxCO2_historical) and (cm_startyear, cm_taxCO2_startyear).
*** (exponential): The exponential curve is determined by the point (cm_startyear, cm_taxCO2_startyear) and the exponential growth rate (cm_taxCO2_expGrowth).
$setglobal cm_taxCO2_functionalForm   linear    !! def = "linear"  !! regexp = linear|exponential
*** cm_taxCO2_historical "switch for setting historical level of CO2 tax (in $ per t CO2eq) that is used if functional form is linear"
*** (gdx_ref): level of CO2 tax (defined as maximum of pm_taxCO2eq over all regions) from path_gdx_ref in cm_taxCO2_historicalYr
*** (any number >= 0): level of co2 tax in cm_taxCO2_historicalYr
$setglobal cm_taxCO2_historical       gdx_ref    !! def = "gdx_ref"  !! regexp = gdx_ref|is.nonnegative
*** cm_taxCO2_historicalYr  "switch for setting the year of cm_taxCO2_historical"
*** (last): last time period before start year (e.g. 2025 if start year is 2030)
*** (any number >= 2005 and < cm_startyear): year for which historical level of CO2 tax (cm_taxCO2_historical) is provided (e.g. 2024)
$setglobal cm_taxCO2_historicalYr     last    !! def = "last"  !! regexp = last|is.nonnegative
*** cm_taxCO2_regiDiff "switch for choosing the regional carbon price differentiation scheme in 45_carbonprice/functionalForm"
*** (none): No regional differetiation, i.e. uniform carbon pricing
*** (initialSpread10): Maximal initial spread of carbon prices in 2030 between OECD regions and poorest region is equal to 10. Initial spread for each region determined based on GDP per capita (PPP) in 2015. Carbon prices converge using quadratic phase-in until cm_taxCO2_regiDiff_endYr (default = 2050).
*** (initialSpread20): Maximal initial spread of carbon prices in 2030 between OECD regions and poorest region is equal to 20. Initial spread for each region determined based on GDP per capita (PPP) in 2015. Carbon prices converge using quadratic phase-in until cm_taxCO2_regiDiff_endYr (default = 2050).
*** (gdpSpread): Regional differentiation based on GDP per capita (PPP) throughout the century. Uses current GDP per capita (PPP) of OECD countries - around 50'000 US$2017 - as threshold for application of full carbon price.
$setglobal cm_taxCO2_regiDiff         initialSpread10    !! def = "initialSpread10"  !! regexp = none|initialSpread10|initialSpread20|gdpSpread
*** cm_taxCO2_regiDiff_endYr "switch for choosing convergence year of regionally differentiated carbon prices when using initialSpread10 or initialSpread20 in 45_carbonprice/functionalForm"
*** Setting cm_taxCO2_regiDiff_endYr to GLO 2050, IND 2070, SSA 2100 means that convergence year is delayed for IND to 2070 and for SSA to 2100
$setglobal cm_taxCO2_regiDiff_endYr   "GLO 2050"    !! def = "GLO 2050"
*** cm_co2_tax_interpolation "switch for interpolation between (a) carbonprice trajectory given by path_gdx_ref (or manually chosen regional carbon price in cm_startyear - see cm_taxCO2_startYearValue) and (b) carbonprice trajectory defined in 45_carbonprice"
*** (off): no interpolation, i.e. (b) is used from cm_startyear onward
*** (one_step): linear interpolation within 10 years between (a) and (b). For example, if cm_startyear = 2030, it uses (a) until 2025, the average of (a) and (b) in 2030, and (b) from 2035.
*** (two_steps): linear interpolation within 15 years between (a) and (b). For example, if cm_startyear = 2030, it uses (a) until 2025, weighted averages of (a) and (b) in 2030 and 2035, and (b) from 2040.
*** Setting cm_co2_tax_interpolation to GLO.2025.2050 2, EUR.2025.2040 1 means that interpolation between (a) and (b) in quadratic [exponent = 2], starts in 2025, and ends in 2050 for all regions, except for Europe that has linear interpolation [exponent = 1] starting in 2025 and ending in 2040
$setglobal cm_taxCO2_interpolation  off    !! def = "off"
*** cm_taxCO2_startYearValue  "switch for manually choosing regional carbon prices in cm_startyear that are used as starting point for interpolation"
*** (off): no manual values provided, i.e. carbonprice trajectory given by path_gdx_ref is used for interpolation
*** Setting cm_taxCO2_startYearValue to GLO 50, SSA 5, CHA 40 means that in cm_startyear, SSA has carbon price of 5$/tCO2,  CHA has carbon price of 40$/tCO2, and all other regions have carbon price of 50$/tCO2.
$setglobal cm_taxCO2_startYearValue off !! def = "off"
*** cm_taxCO2_lowerBound_path_gdx_ref "switch for choosing if carbon price trajectories from path_gdx_ref are used as lower bound"
*** (on): carbon price trajectories (pm_taxCO2eq) from path_gdx_ref is used as lower bound for pm_taxCO2eq
*** (off): no lower bound
$setglobal cm_taxCO2_lowerBound_path_gdx_ref  on    !! def = "on" !! regexp = on|off


*** cm_ind_energy_limit Switch for setting upper limits on industry energy
*** efficiency improvements.  See ./modules/37_subsectors/datainput.gms for
*** implementation.
*** "default" applies the following limits:
***
*** ext_regi |     subsector      | period | maximum "efficiency gain" [0-1]
*** ---------+--------------------+--------+--------------------------------
*** GLO      | ue_cement          |  2050  | 0.75
*** GLO      | ue_steel_primary   |  2050  | 0.75
*** GLO      | ue_steel_secondary |  2050  | 0.75
*** GLO      | ue_chemicals       |  2100  | 0.90
*** GLO      | ue_otherInd        |  2100  | 0.90
***
*** "manual" uses the data present in cm_ind_energy_limit_manual (has the same
*** data as "default" to clarify the format)
$setglobal cm_ind_energy_limit          default   !! def = default   !! regexp = default|manual
$setglobal cm_ind_energy_limit_manual   "2050 . GLO . (ue_cement, ue_steel_primary, ue_steel_secondary)   0.75, 2100 . GLO . (ue_chemicals, ue_otherInd)   0.90"

*** cm_wasteIncinerationCCSshare, proportion of waste incineration emissions that is captured and geologically stored at a given year and region
*** off: means that all plastics incineration emissions in the World goes back to the atmosphere.
*** 2050.GLO 0.5, 2050.EUR 0.8: means that 50% of waste incineration emissions are captured for all regions from 2050 onward, except for Europe that has 80% of its waste incineration emissions captured.
*** The CCS share of waste incineration increases linearly from zero, in 2025, to the value set at the switch, and it is kept constant for years afterwards.
$setglobal cm_wasteIncinerationCCSshare  off      !! def = off
*** cm_feShareLimits <-   "off"  # def <- "off", limit the electricity final energy share to be in line with the industry maximum electrification levels (60% by 2050 in the electric scenario), 10% lower (=50% in 2050) in an increased efficiency World, or 20% lower (40% in 2050) in an incumbents future (incumbents). The incumbents scenario also limits a minimal coverage of buildings heat provided by gas and liquids (25% by 2050).
$setglobal cm_feShareLimits  off  !! def = off
*** VRE potential switches
*** rescaling factor for sensitivity analysis on renewable potentials.
*** This factor rescales all grades of a renewable technology which have not been used by 2020 (to avoid infeasiblities with existing capacities)
*** (example: "spv 0.5, windon 0.75" rescales solar and wind potential by the respective factors)
$setGlobal c_VREPot_Factor  off  !! def = off
*** FE tax switches, allows scaling up or down FE taxes on all sectors, energy carriers flexibly
***   cm_FEtax_trajectory_abs     "switch for setting the aboslute FE tax level explicitly from a given year onwards, before tax levels increases or decreases linearly to that value"
*** swtich for setting FE tax to an absolute value in USD/MWh from a specific year onwards for a given sector and FE carrier (for all regions equally)
*** example: cm_FEtax_trajectory_abs  2040.indst.feels 20  sets FE electricity tax in industry to 20 USD/MWh from 2040 onwards, before: linear increase from cm_startyear to 2040
*** (note: don't put values to 0 as this will make the model ignore the switch)
$setGlobal cm_FEtax_trajectory_abs  off !! def = off
*** cm_FEtax_trajectory_rel     "factor for scaling the FE tax level relative to cm_startyear from a given year onwards, before tax levels increases or decreases linearly to that value"
*** factor for scaling FE tax relative to level in cm_startyear from a specific year onwards for a given sector and FE carrier
*** example: cm_FEtax_trajectory_rel   2040.indst.feels 2 doubles FE electricity tax in industry relative to cm_startyear for all regions by 2040 and after, before: linear increase from cm_startyear to 2040
*** (note: don't put values to 0 as this will make the model ignore the switch)
$setGlobal cm_FEtax_trajectory_rel  off !! def = off
*** Switch to scale agriculture baseline emissions per region relative to default (Magpie) levels
*** example: "CHA 0.2, EUR -0.4" means 20% increase of agricultural baseline emissions in China, 40% decrease in EUR,
*** phase-in of the scaling is gradual over time and full scaling is reached by 2040.
*** If you specify a value for a region within a region group (e.g. DEU in EU27_regi),
*** then the values from the region group disaggregation will be overwritten by this region-specific value.
*** For example: "DEU -0.2, EU27_regi -0.4".
$setGLobal c_agricult_base_shift off !! def off
***  cm_INCONV_PENALTY  on     !! def = on
*** *RP* 2012-03-06 Flag to turn on inconvenience penalties, e.g. for air pollution
$setglobal cm_INCONV_PENALTY  on         !! def = on  !! regexp = off|on
*** cm_INCONV_PENALTY_FESwitch  linear     !! def = linear
*** flag to run on inconvenience penalty to avoid switching shares on buildings, transport and industry biomass use if costs are relatively close (seLiqbio, sesobio, segabio)
*** The penalty acts on changes in FE demand for each sector and SE-FE combination.
*** (off): No inconvenience penalty
*** (linear): Inconvenience penalty favors linear FE development
*** (constant): Inconvenience penalty favors constant FE development
$setglobal cm_INCONV_PENALTY_FESwitch  constant !! def = linear  !! regexp = off|linear|constant
*** cm_INCONV_PENALTY_FESwitchRegi
*** Switch to determine the reference region for the scaling of the FE switch penalty.
*** Needs to be a valid Remind region and should be a region with average total FE demand compared to other regions.
$setglobal cm_INCONV_PENALTY_FESwitchRegi  USA !! def = USA  !! regexp = [A-Z]{3}
*** cm_seFeSectorShareDevMethod "Switch to enable an optimization incentive for sectors to have similar shares of secondary energy fuels and determine the method used for the incentive."
*** Possible values: off or the method name (sqSectorShare, sqSectorAvrgShare, or minMaxAvrgShare)
***  off               "The model can freely allocate bio/syn/fossil fuels between sectors. If not off, a penalization term is added so sectors are incentivized to apply similar shares of bio-fuels, synfuels, and fossils in each sector."
***  sqSectorShare     "Square share penalty. This method is not recommended as it also creates an unwanted incentive for the model to have equal total fos/syn/bio shares, as higher shares are penalized more than lower ones. Runs will be more sensible to the chosen c_seFeSectorShareDevScale values for this reason."
***  sqSectorAvrgShare "Square deviation from average share penalty. Recomended over sqSectorShare (see above)."
***  minMaxAvrgShare   "Min-max deviation from average share penalty."
*** The relative effect of the penalization term in the objective function is scaled to avoid affecting optimization results. This scaling factor can be defined using the switch c_seFeSectorShareDevScale.
$setglobal cm_seFeSectorShareDevMethod  sqSectorAvrgShare !! def = sqSectorAvrgShare  !! regexp = off|sqSectorShare|sqSectorAvrgShare|minMaxAvrgShare
*** c_seFeSectorShareDevUnit "Defines if the penalization term is applied over fuel shares or energy units."
***  share,  "The square penalization is applied directly to the share values. This results in different-sized regions having varying relative penalization incentives, but the range of penalization values will be more consistent from the solver's perspective."
***  energy, "The square penalization is applied to the share values multiplied by the energy demand. This approach scales penalizations better across different-sized regions, but there is a higher risk of the penalizations being ignored and the shares not being enforced if the value range is too small."
$setglobal c_seFeSectorShareDevUnit  share !! def = share  !! regexp = share|energy
***  cm_MOFEX  off    !! def=off
*** *JH/LB* Activate MOFEX partial fossil fuel extraction cost minimization model
*** * Warning: Use a well-converged run since the model uses vm_prodPe from the input GDX
$setGlobal cm_MOFEX  off        !! def = off  !! regexp = off|on
*** cm_limitSolidsFossilRegi off   !! def=off
*** starting in max(2020, cm_startyear), fossil solids use in each (sector x emiMkt) has to decrease compared to the previous time step for each region included in the switch cm_limitSolidsFossilRegi
*** aceptable values: any of the ext_regi set elements
*** e.g. "EUR_regi, USA"  "solids fossil in industry and buildings for regions within EUR_regi and USA have to be lower or equal to the previous time step from 2020 or cm_startyear onward."
$setGlobal cm_limitSolidsFossilRegi off
*** cm_Full_Integration
***    use "on" to treat wind and solar as fully dispatchable electricity production technologies
$setGlobal cm_Full_Integration  off     !! def = off  !! regexp = off|on
*'   MAGICC configuration
*'   either uncalibrated or calibrate year 2000 temperature to HADCRUT4 data (which is very close to AR5).
$setGlobal cm_magicc_calibrateTemperature2000  uncalibrated  !! def = uncalibrated
*'  Derive temperature impulse response to CO2 emissions, based on MAGICC. Adds around 10min runtime.
$setGlobal cm_magicc_temperatureImpulseResponse  off           !! def = off  !! regexp = off|on
*' MAGICC configuration
*' roughly comparable to TCRE value, or even more roughly, equivalent climate sensitivity
*' choose from OLDDEFAULT (REMIND1.7 legacy file); or different percentiles of RCP26 or generic TCRE outcomes calibrated to CMIP5 (see Schultes et al. (2018) for details)
$setGlobal cm_magicc_config  OLDDEFAULT    !! def = OLDDEFAULT ; {OLDDEFAULT, RCP26_[5,15,..,95], TCRE_[LOWEST,LOW,MEDIUM,HIGH,HIGHEST] }
*'  climate damages (HowardNonCatastrophic, DICE2013R, DICE2016, HowardNonCatastrophic, HowardInclCatastrophic, KWcross, KWpanelPop}
$setGlobal cm_damage_DiceLike_specification  HowardNonCatastrophic   !! def = HowardNonCatastrophic
***cfg$gms$cm_KotzWenzPerc <- mean #def = mean; {low,med,mean,high} the percentile of the damage distribution from Kotz et al. (2024), low = 5th, high = 95th percentile
$setGlobal cm_KotzWenzPerc mean !! def = mean !! regexp = low|med|mean|high
*** cfg$gms$cm_damage_Labor_exposure <- "low" # def = "low"; {low,high}
$setGlobal cm_damage_Labor_exposure  low    !! def = low  !! regexp = low|high
*** cfg$gms$cm_TCssp <- "SSP2"  #def = "SSP2"; {SSP2,SSP5} the scenario for which the damage function is specified - currently only SSP2 and SSP5 are available
$setGlobal cm_TCssp  SSP2  !! def = SSP2  !! regexp = SSP2|SSP5
*** cfg$gms$cm_TCpers <- 8   #def = 8; {0,1,2,3,4,5,6,7,8,9} the lags taken into account in the damage function
$setGlobal cm_TCpers  8  !! def = 8  !! regexp = [0-9]
*** cfg$gms$cm_TCspec <- "mean"  # def = mean; {mean,median,95,05,83,17}  the uncertainty estimate of the TC damage function
$setGlobal cm_TCspec  mean  !! def = mean  !! regexp = mean|median|95|05|83|17
*** This flag turns off output production
$setGlobal c_skip_output  off        !! def = off  !! regexp = off|on
***  cm_CO2TaxSectorMarkup     "CO2 tax markup in buildings or transport sector, a value of 0.5 means CO2 tax increased by 50%"
***  (off): no markup
***  ("GLO.build 1, USA_regi.trans 0.25, EUR_regi.trans 0.25"): "example for CO2 tax markup in transport of 25% in USA and EUR, and CO2eq tax markup in buildings sector of 100 % in all regions. Currently, build and trans are the only two elements of the set emi_sectors that are supported."
$setglobal cm_CO2TaxSectorMarkup  off   !! def = off
*** c_regi_nucscen              "regions to apply cm_nucscen to in case of cm_nucscen = 5 (no new nuclear investments), e.g. c_regi_nucscen <- "JPN,USA"
$setGlobal c_regi_nucscen  all  !! def = all
***  c_regi_capturescen              "regions to apply cm_ccapturescen to (availability of carbon capture technologies), e.g. c_regi_nucscen <- "JPN,USA"
$setGlobal c_regi_capturescen  all  !! def = all
*** cm_subsec_model_steel      "switch between ces-based and process-based steel implementation in subsectors realisation of industry module"
$setglobal cm_subsec_model_steel  processes  !! def = processes  !! regexp = processes|ces
*** cm_tech_bounds_2025
*** activate bounds for 2025 for fast-growing technologies (spv, wind etc.) based on 2023 statistics
*** (off) no bounds for 2025
*** (on) some generous bounds for 2025 assuming that certain developments are not possible anymore even for fast growing technologies given 2023 data
$setglobal cm_tech_bounds_2025  on  !! def = on  !! regexp = on|off
*** set conopt version. Warning: conopt4 is in beta
$setGlobal cm_conoptv  conopt3    !! def = conopt3
*' c_empty_model  "Short-circuit the model, just use the input as solution"
*'
*' (off): normal model operation, default
*' (on): no model operation, instead input.gdx is copied to fulldata.gdx
$setGlobal c_empty_model   off    !! def = off  !! regexp = off|on
$setglobal cm_secondary_steel_bound  scenario   !! def = scenario
$setglobal cm_demScen  SSP2     !! def = SSP2
$setGlobal c_scaleEmiHistorical  on  !! def = on  !! regexp = off|on
$SetGlobal cm_quick_mode  off          !! def = off  !! regexp = off|on
$setGLobal cm_debug_preloop  off    !! def = off  !! regexp = off|on
*' cm_APscen "air polution scenario"
*' (SSP2):
*' (SSP5):
*' (CLE): Current Legislation Emissions
*' (MFR): Maximum Feasible Reductions
$setGlobal cm_APscen  SSP2          !! def = SSP2
$setglobal cm_CES_configuration  indu_subsectors-buil_simple-tran_edge_esm-GDPpop_SSP2-En_SSP2-Kap_debt_limit-Reg_62eff8f7   !! this will be changed by start_run()
$setglobal c_CES_calibration_iterations  10     !!  def  =  10
$setglobal c_CES_calibration_industry_FE_target  1
*' setting which region is to be tested in the one-region test run (80_optimization = testOneRegi)
$setglobal c_testOneRegi_region  EUR       !! def = EUR  !! regexp = [A-Z]{3}
*' cm_taxrc_RE     "switch to define whether tax on (CO2 content of) energy imports is recycled to additional direct investments in renewables (wind, solar and storage)"
$setglobal cm_taxrc_RE  none   !! def = none   !! regexp = none|REdirect
*' cm_emifacs_baseyear "base year for deriving nonCO2 emission factors/econometric estimates/scaling factors"
*' (2005): Uses EDGAR data with 2005 as base year, and Lucas et al. 2007 IMAGE for N2O baselines
*' (2020): Uses CEDS2024 data with 2020 as base year, and Harmsen et al. 2022 IMAGE for N2O baselines
$setGlobal cm_emifacs_baseyear  2020          !! def = 2005
*** Switches to choose Marginal Abatement Cost Curves (MACCs) version (PBL_2007, PBL_2022) and scenarios (Default, Pessismistic, Optimistic)
$setGlobal c_nonco2_macc_version  PBL_2022    !! def = PBL_2007
$setGlobal c_nonco2_macc_scenario  Default     !! def = Default
*' cm_repeatNonOpt       "should nonoptimal regions be solved again?"
*'
*' *  (off): no, only infeasable regions are repeated, standard setting
*' *  (on):  also non-optimal regions are solved again, up to cm_solver_try_max
$setglobal cm_repeatNonOpt off      !! def = off  !! regexp = off|on

*' @stop

*-------------------------------------------------------------------------------------
*** automated checks and settings
*ag* set conopt version
option nlp = %cm_conoptv%;
option cns = %cm_conoptv%;

*** empty model just uses input.gdx as the result
$ifthen.empty_model "%c_empty_model%" == "on"
  execute "cp input.gdx fulldata.gdx";
  abort.noerror "cp input.gdx fulldata.gdx";
$endif.empty_model

*--------------------------------------------------------------------------
***           SETS
*--------------------------------------------------------------------------
$include    "./core/sets.gms";
$batinclude "./modules/include.gms"    sets
$include    "./core/sets_calculations.gms";

*--------------------------------------------------------------------------
***        DECLARATION     of equations, variables, parameters and scalars
*--------------------------------------------------------------------------
$include    "./core/declarations.gms";
$batinclude "./modules/include.gms"    declarations

*--------------------------------------------------------------------------
***          DATAINPUT
*--------------------------------------------------------------------------
$include    "./core/datainput.gms";
$batinclude "./modules/include.gms"    datainput

*--------------------------------------------------------------------------
***          EQUATIONS
*--------------------------------------------------------------------------
$include    "./core/equations.gms";
$batinclude "./modules/include.gms"    equations

*--------------------------------------------------------------------------
***           PRELOOP   Calculations before the Negishi-loop starts
***                     (e.g. initial calibration of macroeconomic module)
*--------------------------------------------------------------------------
$include    "./core/preloop.gms";
$batinclude "./modules/include.gms"    preloop

*--------------------------------------------------------------------------
***         LOOP   solve statement, including BOUNDS
*--------------------------------------------------------------------------
$include    "./core/loop.gms";

*--------------------------------------------------------------------------
***         OUTPUT
*--------------------------------------------------------------------------
$ifthen.c_skip_output %c_skip_output% == "off"
$include    "./core/output.gms";
$batinclude "./modules/include.gms"    output
$endif.c_skip_output

*** EOF ./main.gms
