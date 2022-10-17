*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./main.gms
*' @title REMIND - REgional Model of INvestments and Development
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
*' The units (e.g., TWa, EJ, GtC, GtCO2, ...) of variables and parameters are documented in the declaration files.
*'
*' For the labels of parameters, scalars and set, use double quotes only.
*'
*' #### Commenting:
*'
*' * Comment all parts of the code generously
*' * For all equations, it should become clear from the comments what part of the equation is supposed to do what
*' * Variables and parameters should be declared along with a descriptive text (use `" "` for descriptive text to avoid compilation errors)
*' * Use three asterisks `***` for comments or `*'` if the comment should show up in the documentation of REMIND 
*' * Never use 4 asterisks (reserved for GAMS error messages)
*' * Don't use the string `infes` in comments
*' * Don't use `$+number` combinations, e.g., `$20` (this interferes with GAMS error codes).
*' * Indicate the end of a file by inserting `*** EOF filename.inc ***` 
*' 
*' #### Sets
*' 
*' * Don't use set element names with three capital letters (like `ETS` or `ESR`), otherwise the maglcass R
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
*' #### Other general rules:
*' * Decompose large model equations into several small equations to enhance readability and model diagnostics
*' * Don't use hard-coded numbers in the equations part of the model
*' * Parameters should not be overwritten in the initialization part of the models. Use if-statements instead.
*' Notable exceptions include parameters that are part a loop iteration, e.g. Negishi weights.
*' * Have your work double-checked! To avoid bugs and problems: If you make major changes to your code, ask an
*' experienced colleague to review the changes before they are pushed to the git main repository.
*' * Use sets and subsets to avoid redundant formulation of code (e.g., for technology groups)
*' * If big data tables are read in exclude them from the `.lst`-file (by using `$offlisting` and `$onlisting`),
*' nevertheless display the parameter afterwards for an easier debugging later
*' * When declaring a parameter/variable/equation always add the sets it is declared for,
*' e.g. `parameter test(x,y);` instead of `parameter test;`
*' * do not set variables for all set entries to zero (if not necessary), as this will blow up memory requirements.
*' 


*##################### R SECTION START (VERSION INFO) ##########################
* 
* Regionscode: 62eff8f7
* 
* Input data revision: 6.316
* 
* Last modification (input data): Wed Sep 28 10:35:42 2022
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

*' @code
*--------------------------------------------------------------------------
*' #### Configuration - Settings for Scenatios:
*--------------------------------------------------------------------------

***---------------------    Run name and description    -------------------------
$setGlobal c_expname  default
$setGlobal c_description  REMIND run with default settings

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
*' * (magicc): MAGICC - iterative coupling of MAGICC climate model.
*' * (box): Petschel-Held
$setGlobal climate  off               !! def = off
*'---------------------    16_downscaleTemperature    --------------------------
*'
*** (off)
*** (CMIP5): downscale GMT to regional temperature based on CMIP5 data (between iterations, no runtime impact). Requires climate= 'off' and cm_rcp_scen=none"iterative_target_adj" = 9] curved convergence of CO2 prices between regions until cm_CO2priceRegConvEndYr; developed countries have linear path from 0 in 2010 through cm_co2_tax_2020 in 2020;
$setGlobal downscaleTemperature  off  !! def = off
*'---------------------    20_growth    ------------------------------------------
*'
*** (exogenous): exogenous growth
*** (endogenous): endogenous growth !!Warning: still experimental stuff!!
*** (spillover): endogenous growth with spillover externality !!Warning: not yet calibrated!!
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
*' * (perfect):   Perfect capital market (results in large short-term capital flows from North to South)
*' * (debt_limit): Weak imperfection of capital market by debt and surplus growth limits
$setglobal capitalMarket  debt_limit           !! def = debt_limit
*'----------------------    24_trade    ---------------------------------------
*'
*' * (standard): macro-economic commodities and primary energy commodities trading
*' * (se_trade): macro-economic commodities, primary energy commodities and secondary energy hydrogen and electricitiy trading
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
*' * (exogenous):     exogenous biomass extraction and costs
*' * (magpie_40): using supplycurved derived from MAgpIE 4.0
$setglobal biomass  magpie_40              !! def = magpie_hightccost
*'---------------------    31_fossil    ----------------------------------------
*'
*' * (timeDepGrades): time-dependent grade stucture of fossil resources (oil & gas only)
*' * (grades2poly)  : simplified version of the time-dependent grade realization (using polynomial functions)
*' * (exogenous)    : exogenous fossil extraction and costs
$setglobal fossil  grades2poly        !! def = grades2poly
*'---------------------    32_power    ----------------------------------------
*'
*' * (IntC)      :    Power sector formulation with Integration Cost (IntC) markups and curtailment for VRE integration - linearly increasing with VRE share -, and fixed capacity factors for dispatchable power plants
*' * (RLDC)      :    Power sector formulation with Residual Load Duration Curve (RLDC) formulation for VRE power integration, and flexible capacity factors for dispatchable power plants
*' * (DTcoup)    :    Power sector formulation with iterative coupling to hourly power-sector model DIETER: REMIND gives DIETER costs of technologies, power demand, CO2 price and capacity bounds; DIETER gives REMIND markups of generation, capacity factors, peak hourly residual demand
$setglobal power  IntC        !! def = IntC
*'---------------------    33_CDR       ----------------------------------------
*'
*' * (off)        : no carbon dioxide removal technologies except BECCS
*' * (weathering) : includes enhanced weathering
*' * (DAC) :    includes direct air capture
*' * (all) :    includes all CDR technologies
$setglobal CDR  DAC        !! def = DAC
*'---------------------    35_transport    ----------------------------------------
*'
*' * (complex):  transport realization with aggregated transport demand (LDV, HDV, electric trains) via CES function with constrained choice on vehicle technologies
*' * (edge_esm): transport realization with iterative coupling to logit-based transport model EDGE-Transport with detailed representation of transport modes and technologies  
$setglobal transport  edge_esm           !! def = edge_esm
*'---------------------    36_buildings    ---------------------------------
*'
*' * (simple): representation of final energy demand via a CES function calibrated to EDGE-Buildings' demand trajectories
*' * (services_with_capital): representation of the demand by energy service with capital
*' * (services_putty): representation of the demand by energy service with capital and with putty-clay for buildings insulation
$setglobal buildings  simple      !! def = simple
*'---------------------    37_industry    ----------------------------------
*'
*' * (fixed_shares): fixed shares of industry sub-sectors (cement, chemicals,
*'                   steel, other) in industry FE use
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
*' * (NDC): Technology targets for 2030 for spv,wind,tnrs.
*' * (NPi): Reference technology targets, mostly already enacted (N)ational (P]ol(i)cies, mostly for 2020
*' * (EVmandates): mandate for electric vehicles - used for UBA project
$setglobal techpol  none           !! def = none
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
*'---------------------    42_banking  ----------------------------------------
*'
*' * (off): no banking and borrowing of emission permits, no when-flexibility
*' * (banking):  only banking allowed, no borrowing at all
$setglobal banking  off          !! def = off
*'---------------------    45_carbonprice  ----------------------------------------
*' This module defines the carbon price pm_taxCO2eq, with behaviour across regions governed by similar principles (e.g. global targets, or all following NDC or NPi policies).
*'
*' * (none): no tax policy (combined with all emiscens except emiscen eq 9)
*' * (exponential): 5% exponential increase over time of the tax level in 2020 set via cm_co2_tax_2020 (combined with emiscen eq 9 and cm_co2_tax_2020>0)
*' * (expoLinear): 5% exponential increase until c_expoLinear_yearStart, linear increase thereafter
*' * (exogenous): carbon price is specified using an external input file or using the switch cm_regiExoPrice
*' * (linear): linear increase over time of the tax level in 2020 set via cm_co2_tax_2020 (combined with emiscen eq 9 and cm_co2_tax_2020>0)
*' * (diffPriceSameCost) ! experimental ! adjusts regional carbon prices until regional mitigation costs (in NPV GDP) are equal across regions. Use with iterative_adjust=2, emiscen=9. Experimental feature, you are responsible to check for convergence yourself (check that p45_mitiCostRel is about constant over iterations)
*' * (temperatureNotToExceed): [test and verify before using it!] Find the optimal carbon carbon tax (set cm_emiscen=1"iterative_target_adj" = 9] curved convergence of CO2 prices between regions until cm_CO2priceRegConvEndYr; developed countries have linear path from 0 in 2010 through cm_co2_tax_2020 in 2020;
*' * (NDC2constant): linearly phase in global constant price from NDC prices (default 2020-2040 phase-in)
*' * (diffCurvPhaseIn2Lin): [REMIND 2.1 default for validation peakBudget runs, in combination with "iterative_target_adj" = 9] curved convergence of CO2 prices between regions until cm_CO2priceRegConvEndYr; developed countries have linear path from 0 in 2010 through cm_co2_tax_2020 in 2020;
*' * (diffPhaseIn2Constant): !experimental! linearly phase in global constant price, with starting values differentiated by GDP/cap
*' * (NDC): implements a carbon price trajectory consistent with the NDC targets (up to 2030) and a trajectory of comparable ambition post 2030 (1.25%/yr price increase and regional convergence of carbon price). Choose version using cm_NDC_version "2022_cond", "2022_uncond", or replace 2022 by 2021 or 2018 to get all NDC published until end of these years.
$setglobal carbonprice  none           !! def = none
*'---------------------    46_carbonpriceRegi  ---------------------------------
*' This module applies a markup pm_taxCO2eqRegi on top of pm_taxCO2eq to achieve additional intermediate targets.
*'
*' * (none): no regional carbonprice policies
*' * (NDC): implements a carbon price markup trajectory consistent with the NDC targets between 2030 and 2070
*' * (netZero): implements a carbon price markup trajectory consistent with the net zero targets
$setglobal carbonpriceRegi  none      !! def = none
*'---------------------    47_regipol  -----------------------------------------
*' The regiCarbonPrice realisation defines more detailed region or emissions market specific targets, overwriting the behaviour of pm_taxCO2eq and pm_taxCO2eqRegi for these regions.
*'
*' * (none): no regional policies
*' * (regiCarbonPrice): region-specific policies and refinements (regional emissions targets, co2 prices, phase-out policies etc.)
$setglobal regipol  none              !! def = none
*'---------------------    50_damages    ---------------------------------------
*'
*' * (off): no damages on GDP
*' * (DiceLike): DICE-like damages (linear-quadratic damages on GDP). Choose specification via cm_damage_DiceLike_specification
*' * (BurkeLike): Burke-like damages (growth rate damages on GDP). Choose specification via cm_damage_BurkeLike_specification and cm_damage_BurkeLike_persistenceTime
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
*' * (KWlikeItr): Internalize damage function based on Kalkuhl & Wenz (2020). Requires cm_emiscen set to 9 for now.
*' * (KWlikeItrCPnash): Internalize damage function based on Kalkuhl & Wenz (2020), but with Nash SCC, i.e. each region only internalizes its own damages. Requires cm_emiscen set to9 for now.
*' * (KWlikeItrCPreg): Internalize damage function based on Kalkuhl & Wenz (2020), but with regional SCC instead of a global uniform price. Requires cm_emiscen set to 9 for now.
*' * (KW_SEitr): Internalize damage function based on Kalkuhl & Wenz (2020) for upper limit based on standard error. Requires cm_emiscen set to 9 for now.
*' * (KWTCintItr): Internalize combined damages from Kalkuhl & Wenz (2020) and from tropical cyclones. Requires cm_emiscen set to 9 for now.
*' * (LabItr): Internalize labor supply damages based on Dasgupta et al. (2021). Requires cm_emiscen set to 9 for now.
*' * (TCitr): Internalize tropical cyclone damage function based on Krichene et al. (2022). Requires cm_emiscen set to 9 for now.
$setGlobal internalizeDamages  off               !! def = off
*'---------------------    70_water  -------------------------------------------
*'
*' * (off): no water demand taken into account
*' * (exogenous): exogenous water demand is calculated based on data on water demand coefficients and cooling shares
*' * (heat): as exogenous only that vintage structure in combination with time dependent cooling shares as vintages and efficiency factors are also considered and demand is a function of excess heat as opposed to electricity output
$setglobal water  off                 !! def = off
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
*' * (on):  test code performance: noumerous (30) succesive runs performed in a triangle, tax0, tax30, tax150, all growing exponentially,
*'                      therefore use carbonprice|exponential, c_emiscen|9, and cm_co2_tax_2020|0.
$setGlobal codePerformance  off       !! def = off

***-----------------------------------------------------------------------------
*' ####                     SWITCHES 
***-----------------------------------------------------------------------------
parameter
  cm_iteration_max          "number of iterations, if optimization is set to negishi or testOneRegi; used in nash mode only with cm_nash_autoconvergence = 0"
;
  cm_iteration_max       = 1;     !! def = 1
*'
parameter
  cm_abortOnConsecFail      "number of iterations of consecutive failures of one region after which to abort"
;
  cm_abortOnConsecFail   = 5;     !! def = 5
*'
parameter
  c_solver_try_max          "maximum number of inner iterations within one Negishi iteration (<10)"
;
  c_solver_try_max       = 2;     !! def = 2
*'
parameter
  c_keep_iteration_gdxes    "save intermediate iteration gdxes"
;
  c_keep_iteration_gdxes = 0;     !! def = 0
*' in default we do not save gdx files from each iteration but this might be helpful for debugging
*'
*' * (0)  gdx files from each iteration are NOT saved
*' * (1)  gdx files from each iteration are saved
parameter
  cm_keep_presolve_gdxes    "save gdxes for all regions/solver tries/nash iterations for debugging"
;
  cm_keep_presolve_gdxes  = 0;     !! def = 0
*'
parameter
  cm_nash_autoconverge      "choice of nash convergence mode"
;
  cm_nash_autoconverge   = 1;     !! def = 1
*'
*' * (0): manually set number of iterations by adjusting cm_iteration_max
*' * (1): run until solution is sufficiently converged  - coarse tolerances, quick solution.  ! donot use in production runs !
*' * (2): run until solution is sufficiently converged  - fine tolerances, for production runs.
*'
parameter
  cm_emiscen                "policy scenario choice"
;
  cm_emiscen        = 1;               !! def = 1
*'
*' *  (0): no global budget. Policy may still be prescribed by 41_emicaprei module.
*' *  (1): BAU
*' *  (2): temperature cap
*' *  (3): CO2 concentration cap
*' *  (4): emission time path
*' *  (5): forcing target from 2010 (not to exceed)
*' *  (6): budget
*' *  (8): forcing target from 2100 onwards (overshoot scen)
*' *  (9): tax scenario (requires running module 21_tax "on"), tax level controlled by module 45_carbonprice and cm_co2_tax_2020, other ghg etc. controlled by cm_rcp_scen
*' *RP* WARNING: cm_emiscen 3 should not be used anymore, as the MACs are not updated anymore.
*' *JeS* WARNING: data for cm_emiscen 4 only exists for multigas_scen 2 bau scenarios and for multigas_scen 1
*'
parameter
  cm_co2_tax_2020           "level of co2 tax in year 2020 in $ per t CO2eq, makes sense only for emiscen eq 9 and 45_carbonprice exponential"
***  (-1): default setting equivalent to no carbon tax
***  (any number >= 0): tax level in 2020, with 5% exponential increase over time
;
  cm_co2_tax_2020   = -1;              !! def = -1
*'
parameter
  cm_co2_tax_growth         "growth rate of carbon tax"
*'  (any number >= 0): rate of exponential increase over time
;
  cm_co2_tax_growth = 1.05;            !! def = 1.05
*'
parameter
  c_macscen                 "use of mac"
***  (1): on
***  (2): off
;
  c_macscen         = 1;               !! def = 1
*'
parameter
  cm_nucscen                "nuclear option choice"
;
  cm_nucscen       = 2;        !! def = 2
*'   (1): no fnrs, tnrs completely free after 2020
*'   (2): no fnrs, tnrs with restricted new builds until 2030 (based on current data on plants under construction, planned or proposed)
*'   (3): no tnrs no fnrs
*'   (4): fix at bau level
*'   (5): no new nuclear investments after 2020
*'   (6): +33% investment costs (tnrs) & uranium resources increased by a factor of 10
*'
parameter
  cm_ccapturescen       "carbon capture option choice, no carbon capture only if CCS and CCU are switched off!"
;
  cm_ccapturescen  = 1;        !! def = 1
*' *  (1): yes
*' *  (2): no carbon capture (only if CCS and CCU are switched off!)
*' *  (3): no bio carbon capture
*' *  (4): no carbon capture in the electricity sector
*'
parameter
  c_bioliqscen              "bioenergy liquids technology choise"
***  (0): no technologies
***  (1): all technologies
;
  c_bioliqscen     = 1;        !! def = 1
*'
parameter
  c_bioh2scen               "bioenergy hydrogen technology choice"
***  (0): no technologies
***  (1): all technologies
;
  c_bioh2scen      = 1;        !! def = 1
*'
parameter
  c_shGreenH2               "lower bound on share of green hydrogen in all hydrogen from 2030 onwards"
***  (a number between 0 and 1): share
;
  c_shGreenH2      = 0;        !! def = 0
*'
parameter
  c_shBioTrans              "upper bound on share of bioliquids in transport from 2025 onwards"
***  (a number between 0 and 1): share
;
  c_shBioTrans     = 1;        !! def = 1
*'
parameter
  cm_shSynLiq               "lower bound on share of synfuels in SE liquids by 2045, gradual scale-up before"
***  (a number between 0 and 1): share
;
  cm_shSynLiq    = 0;        !! def = 0
*'
parameter
  cm_shSynGas               "lower bound on share of synthetic gas in SE gases by 2045, gradual scale-up before"
;
  cm_shSynGas      = 0;        !! def = 0
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
  c_solscen                 "solar option choice"
***  (1): yes
***  (2): no solar
***  (3): fix at bau level
;
  c_solscen        = 1;        !! def = 1
*'
parameter
  cm_bioenergy_tax          "level of bioenergy sustainability tax in fraction of bioenergy price"
***  The tax is only applied to purpose grown 2nd generation (lignocellulosic)
***  biomass and the level increases linearly with bioenergy demand. A value of 1
***  refers to a tax level of 100% at a production of 200 EJ/ 1.5 /yr or 150% at 300 EJ/yr, for example).
***  (0):               setting equivalent to no tax
***  (1.5):             (default), implying a tax level of 150% at a demand of
***                     200 EJ/yr (or 75% at 100 EJ/yr)
***  (any number >= 0): defines tax level at 200 EJ/yr
;
  cm_bioenergy_tax    = 1.5;       !! def = 1.5
*'
parameter
  cm_bioenergymaxscen       "choose bound on global pebiolc production excluding residues"
***  (0): no bound
***  (1): 100 EJ global bioenergy potential
***  (2): 200 EJ global bioenergy potential
***  (3): 300 EJ global bioenergy potential
***  (4): 152 EJ global bioenergy potential
***  (6): 75 EJ (2050) and 90 EJ (2100) global bioenergy potential (linear
***       interpolation in between)
;
  cm_bioenergymaxscen = 0;         !! def = 0
*'
parameter
  cm_tradecost_bio          "choose financal tradecosts for biomass (purpose grown pebiolc)"
***  (1): low   tradecosts (for other SSP scenarios than SSP2)
;
  cm_tradecost_bio     = 2;         !! def = 2
*'
parameter
  cm_1stgen_phaseout        "choose if 1st generation biofuels should phase out after 2030 (vm_deltaCap=0)"
***  (0): 1st generation biofuels after 2020 are fixed at upper limit of resource potential (maxprod)
***  (1): no new capacities for 1st generation biofuel technologies may be built after 2030 -> phaseout until ~2060
;
  cm_1stgen_phaseout  = 0;         !! def = 0
*'
parameter
  cm_biolc_tech_phaseout    "Switch that allows for a full phaseout of all bioenergy technologies globally"
***  Only working with magpie_40 realization of 30_biomass module. 
***  (0): (default) No phaseout
***  (1): Phaseout capacities of all bioenergy technologies using pebiolc, as far
***       as historical bounds on bioenergy technologies allow it. This covers
***       all types of lignocellulosic feedstocks, i.e. purpose grown biomass and
***       residues. Lower bounds on future electricity production due to NDC
***       tagets in p40_ElecBioBound are removed. The first year, in which no new
***       capacities are allowed, is 2025 or cm_startyear if larger.
;
  cm_biolc_tech_phaseout = 0;        !! def = 0
*'
parameter
  cm_cprice_red_factor      "reduction factor for price on co2luc when calculating the revenues. Replicates the reduction applied in MAgPIE"
;
  cm_cprice_red_factor  = 1;         !! def = 1
*'
parameter
  cm_startyear              "first optimized modelling time step [year]"
*' *  (2005): standard for basline to check if model is well calibrated
*' *  (2015): standard for all policy runs (eq. to fix2010), NDC, NPi and production baselines, especially if various baselines with varying parameters are explored
*' *  (....): later start for delay policy runs, eg. 2025 for what used to be delay2020
;
  cm_startyear      = 2005;      !! def = 2005 for a baseline
*'
parameter
  c_start_budget            "start of GHG budget limit"
;
  c_start_budget    = 2100;      !! def = 2100
*'
parameter
  cm_prtpScen               "pure rate of time preference standard values"
***  (1): 1 %
***  (3): 3 %
;
  cm_prtpScen         = 3;         !! def = 3
*'
parameter
  cm_fetaxscen              "choice of final energy tax path, subsidy path and inconvenience cost path, values other than 0 make setting module 21_tax on"
*** *RP* even if set to 0, the PE inconvenience cost per SO2-cost for coal are always on if module 21_tax is on
***  (0): no tax, sub, inconv
***  (1): constant t,s,i (used in SSP 5 and ADVANCE WP3.1 HighOilSub)
***  (2): converging tax, phased out sub (-2030), no inconvenience cost so far (used in SSP 1)
***  (3): constant tax, phased out sub (-2050), no inconvenience cost so far (used in SSP 2)
***  (4): constant tax, phased out sub (-2030), no inconvenience cost so far (used in SDP)
;
  cm_fetaxscen        = 3;         !! def = 3
*'
parameter
  cm_multigasscen           "scenario on GHG portfolio to be included in permit trading scheme"
***  (1): CO2 only
***  (2): all GHG
***  (3): all GHG excl CO2 emissions from LULUCF
;
  cm_multigasscen     = 2;         !! def = 2
*'
parameter
  cm_permittradescen        "scenario on permit trade"
***  (1): full permit trade (no restrictions)
***  (2): no permit trade (only domestic mitigation)
***  (3): limited trade (certain percentage of GDP)
;
  cm_permittradescen  = 1;         !! def = 1
*'
parameter
  cm_limit_peur_scen        "limit total uranium production"
***  (0): off
***  (1): on
***  (2): high  tradecosts (default and SSP2)
;
  cm_limit_peur_scen  = 1;         !! def = 1
*'
parameter
  cm_rentdiscoil            "[grades2poly] discount factor for the oil rent"
;
  cm_rentdiscoil      = 0.2;       !! def 0.2
*'
parameter
  cm_rentdiscoil2           "[grades2poly] discount factor for the oil rent achieved in 2100"
;
  cm_rentdiscoil2     = 0.9;       !! def 0.9
*'
parameter
  cm_rentconvoil            "[grades2poly] number of years required to converge to the 2100 oil rent"
;
  cm_rentconvoil      = 50;        !! def 50
*'
parameter
  cm_rentdiscgas            "[grades2poly] discount factor for the gas rent"
;
  cm_rentdiscgas      = 0.6;       !! def 0.6
*'
parameter
  cm_rentdiscgas2           "[grades2poly] discount factor for the gas rent achieved in 2100"
;
  cm_rentdiscgas2     = 0.8;       !! def 0.8
*'
parameter
  cm_rentconvgas            "[grades2poly] number of years required to converge to the 2100 gas rent"
;
  cm_rentconvgas      = 50;        !! def 50
*'
parameter
  cm_rentdisccoal           "[grades2poly] discount factor for the coal rent"
;
  cm_rentdisccoal     = 0.4;       !! def 0.4
*'
parameter
  cm_rentdisccoal2          "[grades2poly] discount factor for the coal rent achieved in 2100"
;
  cm_rentdisccoal2    = 0.6;       !! def 0.6
*'
parameter
  cm_rentconvcoal           "[grades2poly] number of years required to converge to the 2100 coal rent"
;
  cm_rentconvcoal     = 50;        !! def 50
*'
parameter
  c_cint_scen               "additional GHG emissions from mining fossil fuels"
***  (0): switch is off (emissions are not accounted)
***  (1): switch is on (emissions are accounted)
;
  c_cint_scen           = 1;         !! def = 1
*'
parameter
  cm_so2tax_scen            "level of SO2 tax"
***  (0): so2 tax is set to zero
***  (1): so2 tax is low
***  (2): so2 tax is standard
***  (3): so2 tax is high
***  (4): so2 tax intermediary between 1 and 2, multiplying (1) tax by the ratio (3) and (2)
;
  cm_so2tax_scen        = 1;         !! def =
*'
parameter
  cm_damage                 "cm_damage factor for forcing overshoot"
*** *JeS* can be used to lower forcing overshoot in cm_emiscen 8 scenarios, use only with box model!
;
  cm_damage             = 0.005;     !! def = 0.005
*'
parameter
  cm_solwindenergyscen      "scenario for fluctuating renewables, 1 is reference, 2 is pessimistic with limits to fluctuating SE el share"
***  (0) advanced - cheap investment costs, higher learning rates for pv, csp and wind
***  (1) reference - normal investment costs & learning rates for pv, csp and wind     EMF27-3nd round Adv scenario
***  (2) pessimistic EMF27 and AWP 2 - share of PV, wind&CSP limited to 20%. Learning rates reduced by 20%, floor costs increased by 40%. EMF27-3nd round Cons scenario
***  (3) frozen - no learning after 2010, share of PV, wind&CSP limited to 20%. EMF27-3rd round Frozen scenario
***  (4) pessimistic SSP: pessimistic techno-economic assumptions
;
  cm_solwindenergyscen  = 1;         !! def = 1
*'
parameter
  c_techAssumptScen         "scenario for assumptions of energy technologies based on SSP scenarios, 1: SSP2 (default), 2: SSP1, 3: SSP5"
*** *JH* This flag defines an energy technology scenario
***   (1) SSP2: reference scenario - default investment costs & learning rates for pv, csp and wind
***   (2) SSP1: advanced renewable energy techno., pessimistic for nuclear and CCS
***   (3) SSP5: pessimistic techno-economic assumptions
;
  c_techAssumptScen     = 1;         !! def = 1
*'
parameter
  c_ccsinjecratescen        "CCS injection rate factor, 0.5% by default yielding a 60 Mt per year IR"
*** *JH* This flag determines the upper bound of the CCS injection rate
*** *LP* CCS refers to carbon sequestration, carbon capture is modelled separately
***   (0) no "CCS" as in no carbon sequestration at all
***   (1) reference case: 0.005
***   (2) lower estimate: 0.0025
***   (3) upper estimate: 0.075
***   (4) unconstrained: 1
***   (5) sustainability case: 0.001
;
  c_ccsinjecratescen    = 1;         !! def = 1
*'
parameter
  c_ccscapratescen          "CCS capture rate"
*** *JH*  This flag determines the CO2 capture rate of CCS technologies
***   (1) reference
***   (2) increased capture rate
;
  c_ccscapratescen      = 1;         !! def = 1
*'
parameter
  c_export_tax_scen         "choose which oil export tax is used in the model. 0 = none, 1 = fix"
;
  c_export_tax_scen     = 0;         !! def = 0
*'
parameter
  cm_iterative_target_adj   "whether or not a tax or a budget target should be iteratively adjusted depending on actual emission or forcing level"
*** (0): no iterative adjustment
*** (2): iterative adjustment II based on magicc calculated forcing (for both budget and tax runs), see modules/ 0 /magicc/postsolve.gms for direct algorithms of adjustment
*** (3): [requires 45_carbonprice = "NDC" and emiscen = 9] iterative adjustment III for tax based on 2025 or 2030 regionally differentiated emissions, see module/45_carbonprice/<NDC/NPi2018>/postsolve.gms for algorithm of adjustment
*** (4): iterative adjustment IV for both budget and tax runs based on CO2 FF&I emissions 2020-2100, see core/postsolve.gms for direct algorithms of adjustment
*** (5): iterative adjustment V for both budget and tax runs based on CO2 emissions 2020-2100, see core/postsolve.gms for direct algorithms of adjustment
*** (6): iterative adjustment VI for both budget and tax runs based on peak CO2 emissions budget, without changing temporal profile (i.e. with overshoot), see core/postsolve.gms for direct algorithms of adjustment
*** (7): iterative adjustment VII for tax runs based on peak CO2 emissions, with change of temporal tax profile after time of peak budget, aiming for net-zero thereafter, see core/postsolve.gms for direct algorithms of adjustment
*** (9): [REMIND 2.1 default for validation peakBudget runs, in combination with carbonprice = none; after the peaking year annual increase by cm_taxCO2inc_after_peakBudgYr. Automatically shifts cm_peakBudgYr to find the correct peaking year for a given .
;
  cm_iterative_target_adj  = 0;      !! def = 0
*'
parameter
  cm_NDC_divergentScenario  "choose scenario about convergence of CO2eq prices in NDC realization of module 45_carbonprice"
***  (0) 70 years after 2030
***  (1) 120 years after 2030
***  (2) until year 3000 ("never")
;
  cm_NDC_divergentScenario = 0;           !! def = 0
*'
parameter
  cm_gdximport_target       "whether or not the starting value for iteratively adjusted budgets, tax scenarios, or forcing targets (emiscen 5,6,8,9) should be read in from the input.gdx"
*** (0): no import, the default starting value as specified in modules/ 0 /on/input/tax_CO2.inc, core/input/data_emibudget.inc, modules/15_climate/box/datainput.gms is used
*** (1): the values from the gdx are read in (works only if the gdx has a parameter value) ATTENTION: make sure that the values from the gdx have the right structure (e.g. regionally differentiated or not)
;
  cm_gdximport_target      = 0;      !! def = 0
*'
parameter
  cm_gs_ew                  "grain size (for enhanced weathering, CDR module) [micrometre]"
;
  cm_gs_ew                 = 20;     !! def = 20
*'
parameter
  cm_LimRock                "limit amount of rock spread each year [Gt]"
;
  cm_LimRock               = 1000;   !! def = 1000
*'
parameter
  c_tau_so2_xmpt            "switch for temporarily (mainly in the past) exempting chinese SO2 emissions from the SO2 tax"
;
  c_tau_so2_xmpt           = 0;      !! def = 0
*'
parameter
  cm_expoLinear_yearStart   "time at which carbon price increases lineraly instead of exponentially"
;
  cm_expoLinear_yearStart  = 2050;   !! def = 2050
*'
parameter
  c_budgetCO2from2020FFI "carbon budget for CO2 emissions starting from 2020 from FFI (in GtCO2)"
;
  c_budgetCO2from2020FFI   = 700;    !! def = 700
*'
parameter
  c_abtrdy              "first year in which advanced bio-energy technology are ready (unit is year; e.g. 2050)"
;
  c_abtrdy                 = 2010;   !! def = 2010
*'
parameter
  c_abtcst              "scaling of the cost of advanced bio-energy technologies (no unit, 50% increase means 1.5)"
;
  c_abtcst                 = 1;      !! def = 1
*'
parameter
  c_budgetCO2from2020   "carbon budget for all CO2 emissions starting from 2020 (in GtCO2)"
*** budgets from AR6 for 2020-2100 (including 2020), for 1.5 C: 400 Gt CO2, for 2 C: 1150 Gt CO2
;
  c_budgetCO2from2020      = 1150;   !! def = 1150
*'
parameter
  cm_trdcst              "parameter to scale trade export cost for gas"
;
  cm_trdcst            = 1.5;  !! def = 1.5
*'
parameter
  cm_trdadj              "parameter scale the adjustment cost parameter for increasing gas trade export"
;
  cm_trdadj            = 2;    !! def = 2.0
*'
parameter
  cm_postTargetIncrease     "carbon price increase per year after regipol emission target is reached (euro per tCO2)"
;
  cm_postTargetIncrease    = 0;      !! def = 0
*'
parameter
cm_emiMktTargetDelay  "number of years for delayed price change in the emission tax convergence algorithm. Not applied to first target set."
;
  cm_emiMktTargetDelay    = 0;       !! def = 0
*'
parameter
  c_refcapbnd           "switch for fixing refinery capacities to the SSP2 levels in 2010 (if equal zero then no fixing)"
;
  c_refcapbnd          = 0;    !! def = 0
*'
parameter
  cm_damages_BurkeLike_specification      "empirical specification for Burke-like damage functions"
*** def = 0; {0,5} Selects the main Burke specification "pooled, short-run" (0) or an alternative one "pooled, long-run "(5)
;
  cm_damages_BurkeLike_specification    = 0;     !! def = 0
*'
parameter
  cm_damages_BurkeLike_persistenceTime    "persistence time in years for Burke-like damage functions"
***  def = 30; Persistence time (half-time) in years. Highly uncertain, but may be in between 5 and 55 years.
;
  cm_damages_BurkeLike_persistenceTime  = 30;    !! def = 30
*'
parameter
  cm_damages_SccHorizon                   "Horizon for SCC calculation. Damages cm_damagesSccHorizon years into the future are internalized."
***  def = 100; Horizon for SCC calculation. Damages cm_damagesSccHorizon years into the future are internalized.
;
  cm_damages_SccHorizon                 = 100;   !! def = 100
*'
parameter
  cm_damage_KWSE                          "standard error for Kalkuhl & Wenz damages"
*** def = 0; {1.645 for 90% CI, 1.96 for 95% CI, no correction when 0}
;
  cm_damage_KWSE                        = 0;     !! def = 0
*'
parameter
  cm_carbonprice_temperatureLimit "not-to-exceed temperature target in degree above pre-industrial"
;
  cm_carbonprice_temperatureLimit       = 1.8;   !! def = 1.8
*'
parameter
  cm_frac_CCS          "tax on CCS to reflect risk of leakage, formulated as fraction of ccs O&M costs"
;
  cm_frac_CCS          = 10;   !! def = 10
*'
parameter
  cm_frac_NetNegEmi    "tax on CDR to reflect risk of overshooting, formulated as fraction of carbon price"
;
  cm_frac_NetNegEmi    = 0.5;  !! def = 0.5
*'
parameter
  cm_DiscRateScen          "Scenario for the implicit discount rate applied to the energy efficiency capital"
*** (0) Baseline without higher discount rate: No additional discount rate
*** (1) Baseline with higher discount rate: Increase the discount rate by 10%pts from 2005 until the end
*** (2) Energy Efficiency policy: 10%pts higher discount rate until cm_start_year and 0 afterwards.
*** (3) Energy Efficiency policy: higher discount rate until cm_start_year and 25% of the initial value afterwards.
*** (4) Energy Efficiency policy: higher discount rate until cm_start_year, decreasing to 25% value linearly until 2030.
;
  cm_DiscRateScen        = 0;!! def = 0
*'
parameter
  cm_noReboundEffect      "Switch for allowing a rebound effect when closing the efficiency gap (cm_DiscRateScen)"
*** def <- -3  , price sensitivity of logit function for heating and cooking technological choice
;
  cm_noReboundEffect     = 0;
*'
parameter
cm_priceSensiBuild    "Price sensitivity of energy carrier choice in buildings"
*** def <- -3  , price sensitivity of logit function for heating and cooking technological choice
;
  cm_priceSensiBuild     = -3;
*'
parameter
  cm_peakBudgYr       "date of net-zero CO2 emissions for peak budget runs without overshoot"
***    time of net-zero CO2 emissions (peak budget), requires emiscen to 9 and cm_iterative_target_adj to 7, will potentially be adjusted by algorithms
;
  cm_peakBudgYr            = 2050;   !! def = 2050
*'
parameter
  cm_taxCO2inc_after_peakBudgYr "annual increase of CO2 price after the Peak Budget Year in $ per tCO2"
;
  cm_taxCO2inc_after_peakBudgYr = 3; !! def = 3
*'
parameter
  cm_CO2priceRegConvEndYr      "Year at which regional CO2 prices converge in module 45 realization diffPhaseIn2LinFlex"
;
  cm_CO2priceRegConvEndYr  = 2050;   !! def = 2050
*'
parameter
  cm_GDPcovid                  "GDP correction for covid"
*** switch to turn on short-term GDP loss by covid-19
*** *ML* emulates a schock, only feasible with start year 2020, don't use in calibration
***  (0):  off
***  (1):  on
;
  cm_GDPcovid      = 0;            !! def = 0
*'
parameter
  cm_TaxConvCheck             "switch for enabling tax convergence check in nash mode"
*** cm_TaxConvCheck - switches tax convergence check in nash mode on and off (check that tax revenue in all regions, periods be smaller than 0.01% of GDP)
*** 0 (off)
*** 1 (on), default
;
  cm_TaxConvCheck = 0; !! def 0, which means tax convergence check is off
*'
parameter
  cm_biotrade_phaseout        "switch for phaseing out biomass trade in the respective regions by 2030"
***  def 0, means no biomass import phase out
;
  cm_biotrade_phaseout = 0; !! def 0
*'
parameter
  cm_bioprod_histlim          "regional parameter to limit biomass (pebiolc.1) production to a multiple of the 2015 production"
*** def -1, means no additional limit to bioenergy production relative to historic production
*** limit biomass domestic production from cm_startyear or 2020 onwards to cm_bioprod_histlim * 2015-level in a EU subregion
;
  cm_bioprod_histlim = -1; !! def -1
*'
parameter
  cm_flex_tax                 "switch for enabling flexibility tax"
*** cm_flex_tax "switch for flexibility tax/subsidy, switching it on activates a tax on a number of technologies with flexible or inflexible electricity input."
*** technologies with flexible eletricity input get a subsidy corresponding to the lower-than-average electricity prices that they see, while 
*** inflexible technologies get a tax corresponding to the higher-than-average electricity prices that they see
*** (0) flexibility tax off 
*** (1) flexibility tax on
;
  cm_flex_tax = 1; !! def 1
*'
parameter
  cm_H2targets                "switches on capacity targets for electrolysis in NDC techpol following national Hydrogen Strategies"
;
  cm_H2targets = 0; !! def 0
*'
parameter
  cm_PriceDurSlope_elh2       "slope of price duration curve of electrolysis"
***  cm_PriceDurSlope_elh2, slope of price duration curve for electrolysis (increase means more flexibility subsidy for electrolysis H2)
*** This switch only has an effect if the flexibility tax is on by cm_flex_tax set to 1 
;
  cm_PriceDurSlope_elh2 = 15; !! def 15
*'
parameter
  cm_FlexTaxFeedback          "switch deciding whether flexibility tax feedback on buildlings and industry electricity prices is on"
*** cm_FlexTaxFeedback, switches on feedback of flexibility tax on buildings and industry.  
*** That is, electricity price decrease for electrolysis has to be matched by electrictiy price increase in buildings and industry. 
*** This switch only has an effect if the flexibility tax is on by cm_flex_tax set to 1.
;
  cm_FlexTaxFeedback = 0; !! def 0
*'
parameter
  cm_VRE_supply_assumptions        "default (0), optimistic (1), sombre (2), or bleak (3) assumptions on VRE supply"
***   for 1 - optimistic, modify
***     - inco0, incolearn, and learn parameters for spv and storspv
***     - ease capacity constraints on storage
***     - reduce necessary storage for electricity production
***  for 2 - sombre, modify
***     - incolearn spv to 5010 (150 $ per kW floor cost)
***  for 3 - bleak, modify
***     - incolearn spv to 4960 (200 $ per kW floor cost)
;
  cm_VRE_supply_assumptions = 0; !! 0 - default, 1 - optimistic, 2 - sombre, 3 - bleak
*'
parameter
  cm_build_H2costAddH2Inv     "additional h2 distribution costs for low diffusion levels (default value: 6.5$/kg = 0.2 $/Kwh)"
;
  cm_build_H2costAddH2Inv = 0.2;  !! def 6.5$/kg = 0.2 $/Kwh
*'
parameter
  cm_build_costDecayStart     "simplified logistic function end of full value (ex. 5%  -> between 0 and 5% the function will have the value 1). [%]"
;
  cm_build_costDecayStart = 0.05; !! def 5%
*'
parameter
  cm_build_H2costDecayEnd     "simplified logistic function start of null value (ex. 10% -> after 10% the function will have the value 0). [%]"
;
  cm_build_H2costDecayEnd = 0.1;  !! def 10%
*'
parameter
  cm_build_AdjCostActive      "Activate adjustment cost to penalise inter-temporal variation of area-specific weatherisation demand and space cooling efficiency slope (only in putty)"
;
  cm_build_AdjCostActive = 0; !! def 0 = Adjustment cost deactivated (set to 1 to activate)
*'
parameter
  cm_indst_H2costAddH2Inv     "additional h2 distribution costs for low diffusion levels (default value: 3.25$kg = 0.1 $/kWh)"
;
  cm_indst_H2costAddH2Inv = 0.1;  !! def 3.25$/kg = 0.1 $/Kwh
*'
parameter
  cm_indst_costDecayStart     "simplified logistic function end of full value   (ex. 5%  -> between 0 and 5% the simplified logistic function will have the value 1). [%]"
;
  cm_indst_costDecayStart = 0.05; !! def 5%
*'
parameter
  cm_indst_H2costDecayEnd     "simplified logistic function start of null value (ex. 10% -> between 10% and 100% the simplified logistic function will have the value 0). [%]"
;
  cm_indst_H2costDecayEnd = 0.1;  !! def 10%
*'
parameter
  cm_BioSupply_Adjust_EU      "factor for scaling sub-EU bioenergy supply curves"
*** scales bioenergy supply curves in EU regions (mainly used to match EUR H12/ 3 /GJ from 2030 onward, and 30$/GJ from 2040 onward, and 40$/GJ from 2040 onward.
*** scales slope of bioenergy supply curves in EU subregions (mainly used to match EUR H12/Magpie bioenergy potential)
*** switch can be removed once supply curves for EU subregions are fixed in input data
;
  cm_BioSupply_Adjust_EU = 3; !! def 3, 3*bioenergy supply slope obtained from input data
*'
parameter
  cm_BioImportTax_EU          "factor for EU bioenergy import tax"
***  def 1, 100% bioenergy import tax
***  if larger zero, EU subregions pay cm_BioImportTax_EU of the world market price for in addition biomass imports after 2030 due to sustainability concerns
***  cm_biotrade_phaseout !! def = 0
***  (0) no biomass trade restrictions
***  (1) constrain biomass imports in EU subregions from cm_startyear or 2020 onwards to a quarter of 2015 PE bioenergy demand
;
  cm_BioImportTax_EU = 1; !! def 0.25
*'
parameter
  cm_HeatLim_b                "switch to set maximum share of district heating in FE buildings"
***  set upper limits for heat and electricity shares in FE buildlings only for the EU regions
*** def 1, no limit on district heating in FE buildings, if <1, then this serves as an upper bound to the buildings FE heat share
;
  cm_HeatLim_b = 1; !! def 1
*'
parameter
  cm_ElLim_b                  "switch to set maximum share of electricity in FE buildings"
*** def 1, no limit on electricity in FE buildings, if <1, then this serves as an upper bound to the buildings FE electricity share
;
  cm_ElLim_b = 1; !! def 1
*'
parameter
  cm_noPeFosCCDeu              "switch to suppress Pe2Se Fossil Carbon Capture in Germany"
*** CCS limitations for Germany
*** def 0, no suppression of Pe2Se Fossil Carbon Capture in Germany, if 1 then no pe2se fossil CO2 capture in Germany
*** fossil CCS limitations in Germany+
*** (0) none
*** (1) no fossil carbon and capture in Germany
;
  cm_noPeFosCCDeu = 0; !! def 0
*'
parameter
  cm_logitCal_markup_conv_b   "value to which logit calibration markup of standard fe2ue technologies in detailed buildings module converges to"
*** def 0.8, long-term convergence value of detailed buildings fe2ue conventional techs price markup
;
  cm_logitCal_markup_conv_b = 0.8; !! def 0.8
*'
parameter
  cm_logitCal_markup_newtech_conv_b "value to which logit calibration markup of new fe2ue technologies in detailed buildings module converges to"
***  def 0.3, long-term convergence value of detailed buildings fe2ue new techs price markup
;
  cm_logitCal_markup_newtech_conv_b = 0.3; !! def 0.3
*'
parameter
  cm_startIter_EDGET          "starting iteration of EDGE-T"
*** EDGE-T transport starting iteration of coupling
*** def 14, EDGE-T coupling starts at 14, if you want to test whether infeasibilities after EDGE-T -> set it to 1 to check after first iteration
;
  cm_startIter_EDGET = 14; !! def 14, by default EDGE-T is run first in iteration 14
*'
parameter
  c_BaselineAgriEmiRed     "switch to lower agricultural base line emissions as fraction of standard assumption, a value of 0.25 will lower emissions by a fourth"
*** switch to lower Baseline agriultural emissions in all regions, value is the fraction of reduction with respect to default assumptions,
*** e.g. 0.4 means 40% lower emissions trajectory relative to default, reduction starts in 2030, reaches full reduction by 2040
;
  c_BaselineAgriEmiRed = 0; !! def = 0
*'
parameter
  cm_deuCDRmax                 "switch to limit maximum annual CDR amount in Germany in MtCO2 per y"
*** switch to cap annual DEU CDR amount by value assigned to switch, or no cap if -1, in MtCO2
;
  cm_deuCDRmax = -1; !! def = -1
***-----------------------------------------------------------------------------
*' ####                     FLAGS 
***-----------------------------------------------------------------------------
*' cm_MAgPIE_coupling    "switch on coupling mode with MAgPIE"
*'
*' *  (off): off = REMIND expects to be run standalone (emission factors are used, shiftfactors are set to zero)
*' *  (on): on  = REMIND expects to be run based on a MAgPIE reporting file (emission factors are set to zero because emissions are retrieved from the MAgPIE reporting, shift factors for supply curves are calculated)
$setglobal cm_MAgPIE_coupling  off     !! def = "off"
*' cm_rcp_scen       "chooses RCP scenario"
*'
*' *  (none): no RCP scenario, standard setting
*' *  (rcp20): RCP2.0
*' *  (rcp26): RCP2.6
*' *  (rcp37): RCP3.7
*' *  (rcp45): RCP4.5
*' *  (rcp60): RCP6.0
*' *  (rcp85): RCP8.5
$setglobal cm_rcp_scen  none         !! def = "none"
*** cm_NDC_version            "choose version year of NDC targets as well as conditional vs. unconditional targets"
***  (2022_cond):   all NDCs conditional to international financial support
***  (2022_uncond): all NDCs independent of international financial support
***  (2021_cond):   all NDCs conditional to international financial support published until December 31, 2021
***  (2021_uncond): all NDCs independent of international financial support published until December 31, 2021
***  (2018_cond):   all NDCs conditional to international financial support published until December 31, 2018
***  (2018_uncond): all NDCs independent of international financial support published until December 31, 2018
$setglobal cm_NDC_version  2022_cond    !! def = "2022_cond", "2022_uncond", "2021_cond", "2021_uncond", "2018_cond", "2018_uncond"
*** c_regi_earlyreti_rate  "maximum portion of capital stock that can be retired in one year for a region"
***  GLO 0.09, EUR_regi 0.15: default value. (0.09 means full retirement after 11 years, 10% standing after 10 years)
$setglobal c_regi_earlyreti_rate  GLO 0.09, EUR_regi 0.15      !! def = GLO 0.09, EUR_regi 0.15
*** c_tech_earlyreti_rate  "maximum portion of capital stock that can be retired in one year for a technology in a region"
***  GLO.(biodiesel 0.14, bioeths 0.1), EUR_regi.(biodiesel 0.15, bioeths 0.15), USA_regi.pc 0.13, REF_regi.pc 0.13, CHA_regi.pc 0.13: default value, including retirement of 1st gen biofuels, higher rate of coal phase-out for USA, REF and CHA
$setglobal c_tech_earlyreti_rate  GLO.(biodiesel 0.14, bioeths 0.14), EUR_regi.(biodiesel 0.15, bioeths 0.15), USA_regi.pc 0.13, REF_regi.pc 0.13, CHA_regi.pc 0.13 !! def = GLO.(biodiesel 0.14, bioeths 0.14), EUR_regi.(biodiesel 0.15, bioeths 0.15), USA_regi.pc 0.13, REF_regi.pc 0.13, CHA_regi.pc 0.13
*** cm_LU_emi_scen   "choose emission baseline for CO2, CH4, and N2O land use emissions from MAgPIE"
***  (SSP1): emissions (from SSP1 scenario in MAgPIE)
***  (SSP2): emissions (from SSP2 scenario in MAgPIE)
***  (SSP5): emissions (from SSP5 scenario in MAgPIE)
$setglobal cm_LU_emi_scen  SSP2   !! def = SSP2
*** cm_tradbio_phaseout "Switch that allows for a faster phase out of traditional biomass"
***  (default):  Default assumption, reaching zero demand in 2100
***  (fast):     Fast phase out, starting in 2025 reaching zero demand in 2070 (close to zero in 2060)
$setglobal cm_tradbio_phaseout  default  !! def = default
*** cm_POPscen      "Population growth scenarios from UN data and IIASA projection used in SSP"
*** pop_SSP1    "SSP1 population scenario"
*** pop_SSP2    "SSP2 population scenario"
*** pop_SSP3    "SSP3 population scenario"
*** pop_SSP4    "SSP4 population scenario"
*** pop_SSP5    "SSP5 population scenario"
$setglobal cm_POPscen  pop_SSP2EU  !! def = pop_SSP2EU
*** cm_GDPscen  "assumptions about future GDP development, linked to population development (cm_POPscen)"
***  (gdp_SSP1):  SSP1 fastGROWTH medCONV
***  (gdp_SSP2):  SSP2 medGROWTH medCONV
***  (gdp_SSP3):  SSP3 slowGROWTH slowCONV
***  (gdp_SSP4):  SSP4  medGROWTH mixedCONV
***  (gdp_SSP5):  SSP5 fastGROWTH fastCONV
$setglobal cm_GDPscen  gdp_SSP2EU  !! def = gdp_SSP2EU
*** cm_oil_scen      "assumption on oil availability"
***  (lowOil): low
***  (medOil): medium (this is the new case)
***  (highOil): high (formerly this has been the "medium" case; RoSE relevant difference)
***  (4): very high (formerly this has been the "high" case; RoSE relevant difference)
$setGlobal cm_oil_scen  medOil         !! def = medOil
*** cm_gas_scen      "assumption on gas availability"
***  (lowGas): low
***  (medGas): medium
***  (highGas): high
$setGlobal cm_gas_scen  medGas         !! def = medGas
*** cm_coal_scen     "assumption on coal availability"
***  (0): very low (this has been the "low" case; RoSE relevant difference)
***  (lowCoal): low (this is the new case)
***  (medCoal): medium
***  (highCoal): high
$setGlobal cm_coal_scen  medCoal        !! def = medCoal
*** c_ccsinjecrateRegi  "regional upper bound of the CCS injection rate, overwrites for specified regions the settings set with c_ccsinjecratescen"
***  ("off") no regional differentiation
***  ("GLO 0.005") reproduces c_ccsinjecratescen = 1
***  ("GLO 0.00125, CAZ_regi 0.0045, CHA_regi 0.004, EUR_regi 0.0045, IND_regi 0.004, JPN_regi 0.002, USA_regi 0.002") "example that is taylored such that NDC goals are achieved without excessive CCS in a delayed transition scenario. Globally, 75% reduction, 10% reduction in CAZ etc. compared to reference case with c_ccesinjecratescen = 1"
$setglobal c_ccsinjecrateRegi  off  !! def = "off"
*** c_SSP_forcing_adjust "chooses forcing target and budget according to SSP scenario such that magicc forcing meets the target";
***   ("forcing_SSP1") settings consistent with SSP 1
***   ("forcing_SSP2") settings consistent with SSP 2
***   ("forcing_SSP5") settings consistent with SSP 5
$setglobal c_SSP_forcing_adjust  forcing_SSP2   !! def = forcing_SSP2
*** cm_regiExoPrice "set exogenous co2 tax path for specific regions using a switch, require regipol module to be set to regiCarbonPrice (e.g. GLO.(2025 38,2030 49,2035 63,2040 80,2045 102,2050 130,2055 166,2060 212,2070 346,2080 563,2090 917,2100 1494,2110 1494,2130 1494,2150 1494) )" 
$setGlobal cm_regiExoPrice  off    !! def = off
*** cm_emiMktTarget "set a budget or year emission target, for all (all) or specific emission markets (ETS, ESD or other), and specific regions (e.g. DEU) or region groups (e.g. EU27)"
***   Example on how to use:
***     cm_emiMktTarget = '2020.2050.EU27_regi.all.budget.netGHG_noBunkers 72, 2020.2050.DEU.all.year.netGHG_noBunkers 0.1'
***     sets a 72 GtCO2eq budget target for European 27 countries (EU27_regi), for all GHG emissions excluding bunkers between 2020 and 2050; and a 100 MtCO2 CO2eq emission target for the year 2050, for Germany"
***     Requires regiCarbonPrice realization in regipol module
$setGlobal cm_emiMktTarget  off    !! def = off
*** cm_prioRescaleFactor "factor applied to carbon tax rescale factor to prioritize short term targets in the initial 15 iterations (and vice versa latter) [0..1].
***   Example on how to use:
***     if equal to 0.1, only 10% of the carbon tax rescaling will be applied in the first 15 iterations for targets from 2050 onward.
***     This prioritize more short term targets (e.g 2030) in the first iteration. The opposite will happen to iterations higher than 15, making short term carbon pricing (e.g. 2030) more rigid to change in later iterations."
$setGlobal cm_prioRescaleFactor off !! def = off
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
*** cm_NucRegiPol "enable European region specific nuclear phase-out and new capacitiy constraints"
$setGlobal cm_NucRegiPol   off   !! def = off
*** cm_CoalRegiPol "enable European region specific coal phase-out and new capacitiy constraints"
$setGlobal cm_CoalRegiPol   off   !! def = off
*** cm_proNucRegiPol "enable European region specific pro nuclear capacitiy constraints"
$setGlobal cm_proNucRegiPol   off   !! def = off
*** cm_CCSRegiPol - year for earliest investment in Europe, with one timestep split between countries currently exploring - Norway (NEN), Netherlands (EWN) and UK (UKI) - and others
$setGlobal cm_CCSRegiPol     off   !! def = off
*** cm_vehiclesSubsidies - If "on" applies country specific BEV and FCEV subsidies from 2020 onwards
$setGlobal cm_vehiclesSubsidies  off !! def = off
*** cm_implicitQttyTarget - Define quantity target for primary, secondary, final energy or CCS (PE, SE and FE in TWa, or CCS in Mt CO2) per target group (total, biomass, fossil, VRE, renewables, synthetic, ...). 
***   The target is achieved by an endogenous calculated markup in the form or a tax or subsidy in between iterations. 
***   Example on how to use:
***     cm_implicitQttyTarget  "2030.EU27_regi.tax.t.FE.all 1.03263"
***       Enforce a tax (tax) that guarantees that the total (t=total) Final Energy (FE.all) in 2030 (2030) is at most the Final energy target in the Fit For 55 regulation in the European Union (EU27_regi) (1.03263 Twa).
***       The p47_implicitQttyTargetTax parameter will contain the tax necessary to achieve that goal. (777.8 Mtoe = 777.8 * 1e6 toe = 777.8 * 1e6 * 41.868 GJ = 777.8 * 1e6 * 41.868 * 1e-9 EJ = 777.8 * 1e6 * 41.868 * 1e-9 * 0.03171 TWa = 1.03263 TWa)   
***     cm_implicitQttyTarget to "2050.GLO.sub.s.FE.electricity 0.8". The p47_implicitQttyTargetTax parameter will contain the subsidy necessary to achieve that goal.          
***       Enforce a subsidy (sub) that guarantees a minimum share (s) of electricity in final energy (FE.electricity) equal to 80% (0.8) from 2050 (2050) onward in all World (GLO) regions. 
***       The p47_implicitQttyTargetTax parameter will contain the subsidy necessary to achieve that goal.
$setGlobal cm_implicitQttyTarget  off !! def = off
*** cm_loadFromGDX_implicitQttyTargetTax "load p47_implicitQttyTargetTax values from gdx for first iteration. Usefull for policy runs."
$setGlobal cm_loadFromGDX_implicitQttyTargetTax  off !! def = off
*** cm_implicitPriceTarget "define tax/subsidies to match FE prices defined in the pm_implicitPriceTarget parameter."
***   Aceptable values: "off", "Initial", "HighElectricityPrice", "HighGasandLiquidsPrice", "HighPrice", "LowPrice", "LowElectricityPrice"
$setGlobal cm_implicitPriceTarget  off !! def = off
*** cm_implicitPePriceTarget "define tax/subsidies to match PE prices defined in the pm_implicitPePriceTarget parameter."
***   Aceptable values: "off", "highFossilPrice".    
$setGlobal cm_implicitPePriceTarget  off !! def = off
*** cm_VREminShare "minimum variable renewables share requirement per region."
***   Example on how to use:
***     cm_VREminShare = "2050.EUR_regi 0.7".
***       Require a minimum 70% VRE share (wind plus solar) in electricity production for all regions that belong to EUR."
$setGlobal cm_VREminShare    off !! def = off
*** cm_CCSmaxBound "limits Carbon Capture and Storage (including DACCS and BECCS) to a maximum value."
***   Example on how to use:
***     cm_CCSmaxBound   GLO 2, EUR 0.25
***     amount of Carbon Capture and Storage (including DACCS and BECCS) is limited to a maximum of 2GtCO2 per yr globally, and 250 Mt CO2 per yr in EU28. 
***   This switch only works for model native regions. If you want to apply it to a group region use cm_implicitQttyTarget instead.
$setGlobal cm_CCSmaxBound    off  !! def = off
$setglobal cm_CES_configuration   indu_subsectors-buil_simple-tran_edge_esm-POP_pop_SSP2EU-GDP_gdp_SSP2EU-En_gdp_SSP2EU-Kap_debt_limit-Reg_62eff8f7   !! this will be changed by start_run()
*** c_CES_calibration_new_structure      <-   0        switch to 1 if you want to calibrate a CES structure different from input gdx
$setglobal c_CES_calibration_new_structure  0     !!  def  =  0
*** c_CES_calibration_write_prices       <-   0       switch to 1 if you want to generate price file, you can use this as new p29_cesdata_price.cs4r price input file
$setglobal c_CES_calibration_write_prices  0     !!  def  =  0
*** cm_CES_calibration_default_prices    <-   0.01    # def <-  0.01 lower value if input factors get negative shares (xi), CES prices in the first calibration iteration
$setglobal cm_CES_calibration_default_prices  0.01  !!  def  =  0.01
*** cm_calibration_string "def = off, else = additional string to include in the calibration name to be used" label for your calibration run to keep calibration files with different setups apart (e.g. with low elasticities, high eleasticies)
$setglobal cm_calibration_string  off    !!  def  =  off
*** cm_esubGrowth            "long term growth of the elasticity of substitution"
*** (low) 1.3
*** (middle) 1.5
*** (high) 2
$setGlobal cm_EsubGrowth  low  !! def = low
*** cm_cooling_shares -    use "static" or "dynamic" cooling shares in module 70_water/heat
$setglobal cm_cooling_shares  dynamic    !! def = dynamic
*** cm_techcosts -     use regionalized or globally homogenous technology costs for certain technologies
$setglobal cm_techcosts  REG       !! def = REG
*** cm_regNetNegCO2 -    default "on" allows for regionally netNegative CO2 emissions, setting "off" activates bound in core/bounds.gms that disallows net negative CO2 emissions at the regional level
$setglobal cm_regNetNegCO2  on       !! def = on
*** c_regi_sensscen: specify regions to which certain regional sensitivity parameters should be applied to applied to sensitivity parameters 
$setGlobal c_regi_sensscen  all !! def = all
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
$setGlobal cm_EDGEtr_scen  Mix1  !! def = Mix1
*** industry
*** maximum secondary steel share
$setglobal cm_steel_secondary_max_share_scenario  off !! def off , switch on for maximum secondary steel share
*** cm_import_EU                "EU switch for different scenarios of EU SE import assumptions"
*** EU-specific SE import assumptions (used for ariadne)
*** different exogenuous hydorgen import scenarios for EU regions (developed in ARIADNE project)
*** "bal", "low_elec", "high_elec", "low_h2", "high_h2", "low_synf", "high_synf"
*** see 24_trade/se_trade/datainput for H2 import assumptions, this switch only works if the trade realization "se_trade" is selected
$setGlobal cm_import_EU  off !! def off
*** Germany-specific H2 imports assumptions for Ariadne project (needs cm_import_EU to be on)
*** def <- "off", if import assumptions for Germany in Ariadne project -> switch to "on"
*** switch for ariadne import scenarios (needs cm_import_EU to be not off)
*** this switch activates ARIADNE-specific H2 imports for Germany, it requires that cm_import_EU is not "off"
*** (on) ARIADNE-specific H2 imports for Germany, rest EU has H2 imports from cm_import_EU switch
*** (off) no ARIADNE-specific H2 imports for Germany
$setGlobal cm_import_ariadne  off !! def off
*** cm_EnSecScen             "switch for running an ARIADNE energy security scenario, introducing a tax on PE fossil energy in Germany"
*** switch on energy security scenario for Germany (used in ARIADNE project), sets tax on fossil PE
*** switch to activate energy security scenario assumptions for Germany including additional tax on gas/oil
*** (on) energy security scenario for Germany
*** (off) no energy security scenario
$setGlobal cm_EnSecScen  off !! def off
*** cm_Ger_Pol               "switch for selecting different policies for Germany used in the ARIADNE scenarios"
*** switch for Germany-specific policies
*** (off) default
*** (ensec) policies for energy security scenario, e.g. faster hydrogen upscaling
$setGlobal cm_Ger_Pol  off !! def off
*** cm_altFeEmiFac <- "off"  # def <- "off", regions that should use alternative data from "umweltbundesamt" on emission factors for final energy carriers (ex. "EUR_regi, NEU_regi")
$setGlobal cm_altFeEmiFac  off        !! def = off
*** overwritte default fe trajectories with low, medium and high alternatives for buildings, transport and industry
$setglobal cm_calibration_FE  off      !! def = off
*** cm_eni "multiplicative factor applied to industry energy elasticity value (eni). [factor]"
***   def <- "off" = no change for industry energy elasticity (eni); 
***   or number (ex. 2) = multiply by 2 the default value used in REMIND.
$setglobal cm_eni  off  !! def = off
*** cm_enb "multiplicative factor applied to buildings energy elasticity value (enb). [factor]"
***   def <- "off" = no change for buildings energy elasticity (eni); 
***   or number (ex. 2) = multiply by 2 the default value used in REMIND.
$setglobal cm_enb  off  !! def = off
*** cm_LDV_mkt_share "set upper or lower bounds to transport LDV market shares in complex realisation"
***   Example on how to use:
***     cm_LDV_mkt_share  apCarElT.up 80, apCarH2T.up 90, apCarPeT.lo 5
***        maximum market share for EV equal to 80%, for H2V 90%, and minimum market share for ICE equal to 5% of the total LDv market 
$setglobal cm_LDV_mkt_share  off !! def = off
*** cm_share_LDV_sales "set upper or lower bounds to transport LDV market share sales in complex realisation"
***   Example on how to use:
***     cm_share_LDV_sales    2030.2050.apCarElT.upper 80, 2030.2050.apCarH2T.upper 90, 2030.2050.apCarPeT.lower 5
***        maximum sales market share for EV equal to 80%, for H2V 90%, and minimum sales market share for ICE equal to 5% in between the years 2030 and 2050 of the total LDV market 
$setglobal cm_share_LDV_sales  off !! def = off
***  cm_incolearn "change floor investment cost value"
***   Example on how to use:
***     cm_incolearn  "apcarelt=17000,wind=1600,spv=5160,csp=9500"
***       floor investment costs from learning set to 17000 for EVs; and 1600, 5160 and 9500 for wind, solar pv and solar csp respectively.
$setglobal cm_incolearn  off !! def = off
*** cm_storageFactor "scale curtailment and storage requirements. [factor]"
***   def <- "off" = no change for curtailment and storage requirements; 
***   or number (ex. 0.66), multiply by 0.66 to resize the curtailment and storage requirements per region from the default REMIND values.
$setglobal cm_storageFactor  off !! def = off
*** cm_learnRate "change learn rate value by technology."
***   def <- "off" = no change for learn rate value; 
***   or list of techs to change learn rate value. (ex. "apcarelt 0.2")
$setglobal cm_learnRate  off !! def = off
*** cm_adj_seed and cm_adj_seed_cont "overwrite the technology-dependent adjustment cost seed value. Smaller means slower scale-up."
***   both swicthes have the same functionality, but allow more changes once the character limit of cm_adj_seed is reached.
***   def <- "off" = use default adj seed values.
***   or list of techs to change adj_seed value. (ex. "apCarH2T=0.5,apCarElT=0.5,apCarDiEffT=0.25,apCarDiEffH2T=0.25")
$setglobal cm_adj_seed  off
$setglobal cm_adj_seed_cont  off
*** cm_adj_coeff and cm_adj_coeff_cont "overwrite the technology-dependent adjustment cost coefficient. Higher means higher adjustment cost."
***   both swicthes have the same functionality, but allow more changes once the character limit of cm_adj_coeff is reached.
***   def <- "off" = use default adj coefficient values.
***   or list of techs to change adj_coeff value. (ex. "apCarH2T=100,apCarElT=100,apCarDiEffT=200,apCarDiEffH2T=200")
$setglobal cm_adj_coeff  off
$setglobal cm_adj_coeff_cont  off
*** cm_adj_seed_multiplier "rescale adjustment cost seed value relative to default value. [factor]. Smaller means slower scale-up."
***   def <- "off" = use default adj seed values.
***   or list of techs to change adj_seed value by a multiplication factor. (ex. "spv 0.5, storspv 0.5, wind 0.25")
$setglobal cm_adj_seed_multiplier  off
*** cm_adj_coeff_multiplier "rescale adjustment cost coefficient value relative to default value. [factor]. Higher means higher adjustment cost."
***   def <- "off" = use default adj coefficient values.
***   or list of techs to change adj_cost value by a multiplication factor. (ex. "spv 2, storspv 2, wind 4")
*** A note on adjustment cost changes: A common practice of changing the adjustment cost parameterization is by using the same factor to 
*** increase the adjustment cost coefficent and to decrease the adjustment cost seed value at the same time. 
$setglobal cm_adj_coeff_multiplier  off
*** cm_inco0Factor "change investment costs. [factor]."
***   def <- "off" = use default inco0 values.
***   or list of techs with respective factor to change inco0 value by a multiplication factor. (ex. "ccsinje=0.5,bioigccc=0.66,bioh2c=0.66,biogas=0.66,bioftrec=0.66,bioftcrec=0.66,igccc=0.66,coalh2c=0.66,coalgas=0.66,coalftrec=0.66,coalftcrec=0.66,ngccc=0.66,gash2c=0.66,gasftrec=0.66,gasftcrec=0.66,tnrs=0.66")
$setglobal cm_inco0Factor  off !! def = off
*** cm_inco0RegiFactor "change investment costs regionalized technology values. [factor]."
***   def <- "off" = use default p_inco0 values.
***   or list of techs with respective factor to change p_inco0 value by a multiplication factor. (ex. "wind=0.33, spv=0.33" makes investment costs for wind and spv 3 times cheaper)
$setglobal cm_inco0RegiFactor  off  !! def = off
*** cm_CCS_markup "multiplicative factor for CSS cost markup"
***   def <- "off" = use default CCS pm_inco0_t values.
***   or number (ex. 0.66), multiply by 0.66 the CSS cost markup
$setglobal cm_CCS_markup  off  !! def = off
*** cm_Industry_CCS_markup "multiplicative factor for Industry CSS cost markup"
***   def <- "off"
***   or number (ex. 0.66), multiply by 0.66 Industry CSS cost markup
$setglobal cm_Industry_CCS_markup  off !! def = off
*** cm_renewables_floor_cost "additional floor cost for renewables"
***   def <- "off" = use default floor cost for renewables.
***   or list of techs with respective value to be added to the renewables floor cost in Europe
$setglobal cm_renewables_floor_cost  off  !! def = off 
*** cm_DAC_eff "multiplicative factor for energy demand per unit carbon captured with DAC"
***   def <- "off" = use default p33_dac_fedem value.
***   or list of stationary energy carriers with respective value to be multiplied to p33_dac_fedem
$setglobal cm_DAC_eff  off  !! def = off 
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
*** represent the sector-specific demand-side transformation cost, can also be used to influence efficiencies during calibration as 
*** higher markup-cost in calibration will lead to higher efficiencies 
*** to change it to any specific value: set cm_CESMkup_ind e.g. to "feeli 0.8" -> this would apply a cost markup of 0.8 tr USD/TWa to feeli CES node of the industry fixed_shares module
*** standard cost markups of the other nodes will remain unchanged unless you explicitly address them with this switch
***   cm_CESMkup_build               "switch for setting markup cost to CES nodes in buildings" 
***  def = "standard", applies a markup cost of 200 USD/MWh(el) to heat pumps (feelhpb) and 25 USD/MWh(heat) to district heating (feheb)
*** CES markup cost for buildings to represent sector-specific demand-side transformation cost
*** (only applies to buildings realization "simple" for now)
$setGlobal cm_CESMkup_build  standard  !! def = standard
***   cm_CESMkup_ind                 "switch for setting markup cost to CES nodes in industry" 
*** def = "standard", applies a markup cost of 0.5 trUSD/TWa (57 USD/MWh(el)) to industry electricity (feeli) 
*** CES markup cost for industry to represent sector-specific demand-side transformation cost
*** (only applies to industry realization "fixed_shares" for now)
*** switch to change CES mark-up cost in industry
*** "standard" applies standard mark-up cost found in 37_industry/subsectors/datainput.gms or 37_industry/fixed_shares/datainput.gms, note that different industry realizations have different CES nodes
*** Setting the switch to, for example: "feelhth_otherInd 1.5, feh2_cement 0.6" would change the mark-up cost for feelhth_otherInd CES node to 1.3 trUSD/TWa and feh2_cement CES node to 0.6 trUSD/TWa
*** and keep all other CES mark-up cost as in the standard configuration
*** Note on CES markup cost:
*** The CES mark-up cost represent the sector-specific demand-side transformation cost. 
*** When used in calibration/baseline runs they affect the CES efficiencies and can be used to increase/decrease them
$setGlobal cm_CESMkup_ind  standard  !! def = standard
*** cm_feShareLimits <-   "off"  # def <- "off", limit the electricity final energy share to be in line with the industry maximum electrification levels (60% by 2050 in the electric scenario), 10% lower (=50% in 2050) in an increased efficiency World, or 20% lower (40% in 2050) in an incumbents future (incumbents). The incumbents scenario also limits a minimal coverage of buildings heat provided by gas and liquids (25% by 2050).   
$setglobal cm_feShareLimits  off  !! def = off
*** VRE potential switches
*** rescaling factor for sensitivity analysis on renewable potentials, this factor rescales all grades of a renewable technology which have not been used by 2020 (to avoid infeasiblities swith existing capacities)
*** (ex. "spv 0.5, wind 0.75" rescales solar and wind potential by the respective factors)
*** rescaling factor for sensitivity analysis on renewable potentials. 
*** This factor rescales all grades of a renewable technology which have not been used by 2020 (to avoid infeasiblities with existing capacities)
*** (example: "spv 0.5, wind 0.75" rescales solar and wind potential by the respective factors)
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
*** wind offshore switch
*** cm_wind_offshore  1, wind energy is represented by "wind" and "windoff", where "wind" means wind onshore. Later this will be the default and the name "wind" will be made to change to windon
*** cm_wind_offshore  0, means wind energy is only represented by "wind", which is a mixture of both wind onshore and wind offshore
$setglobal cm_wind_offshore  1      !! def = 1
*** *RP* Turn on a slower convergence scheme where each conopt file is used twice, thus conopt1 is used for itr 1+2, conopt.op2 for itr 3+4, conopt.op3 for itr 5+6, conopt.op4 for itr 7+8, conopt.op5 from itr 9 on.
*** *RP* from my own experience, this improves convergence and actually decreases total runtime, even if you start from a gdx with good convergence. But, as always, feelings about REMIND runtimes can be misleading :-)
$setglobal cm_SlowConvergence  off        !! def = off
*** *RP* Flag to allow the model to not extract oil, even though the eq_fuelex_dec would force it to extract.
$setGlobal cm_OILRETIRE  on        !! def = on
***  cm_INCONV_PENALTY  on     !! def = on
*** *RP* 2012-03-06 Flag to turn on inconvenience penalties, e.g. for air pollution
$setglobal cm_INCONV_PENALTY  on         !! def = on
*** cm_INCONV_PENALTY_FESwitch  off     !! def = off
*** flag to trun on inconvenience penalty to avoid switching shares on buildings, transport and industry biomass use if costs are relatively close (seLiqbio, sesobio, segabio)
$setglobal cm_INCONV_PENALTY_FESwitch  on !! def = on
***  cm_so2_out_of_opt  on       !! def = on
*** *JeS* Flag to exclude aerosols from optimization routine, should be used especially for temperature targets
$setGlobal cm_so2_out_of_opt  on         !! def = on
***  cm_MOFEX  off    !! def=off
*** *JH/LB* Activate MOFEX partial fossil fuel extraction cost minimization model
*** * Warning: Use a well-converged run since the model uses vm_prodPe from the input GDX
$setGlobal cm_MOFEX  off        !! def = off
*** *LB* default: 5 years time steps from 2005 to 2150
*** *LB* test_TS: 2005,2010, 2020,2030,2040,2050,2070,2090,2110,2130,2150
*** *LB* cm_less_TS: 2005,2010,2015,2020,2025,2030,2035,2040,2045,2050,2055,2060,2070,2080,2090,2100,2110,2130,2150
*** *LB* END2110: 2005:5:2105,2120
$setGlobal cm_less_TS  on  !! def = on
*** cm_Full_Integration
***    use "on" to treat wind and solar as fully dispatchable electricity production technologies
$setGlobal cm_Full_Integration  off     !! def = off
*'   MAGICC configuration 
*'   either uncalibrated or calibrate year 2000 temperature to HADCRUT4 data (which is very close to AR5).
$setGlobal cm_magicc_calibrateTemperature2000  uncalibrated  !! def = uncalibrated
*'  Derive temperature impulse response to CO2 emissions, based on MAGICC. Adds around 10min runtime.
$setGlobal cm_magicc_temperatureImpulseResponse  off           !! def = off
*' MAGICC configuration
*' roughly comparable to TCRE value, or even more roughly, equivalent climate sensitivity
*' choose from OLDDEFAULT (REMIND1.7 legacy file); or different percentiles of RCP26 or generic TCRE outcomes calibrated to CMIP5 (see Schultes et al. (2018) for details)
$setGlobal cm_magicc_config  OLDDEFAULT    !! def = OLDDEFAULT ; {OLDDEFAULT, RCP26_[5,15,..,95], TCRE_[LOWEST,LOW,MEDIUM,HIGH,HIGHEST] }
*'  climate damages (HowardNonCatastrophic, DICE2013R, DICE2016, HowardNonCatastrophic, HowardInclCatastrophic, KWcross, KWpanelPop}
$setGlobal cm_damage_DiceLike_specification  HowardNonCatastrophic   !! def = HowardNonCatastrophic
*** cfg$gms$cm_damage_Labor_exposure <- "low" # def = "low"; {low,high}
$setGlobal cm_damage_Labor_exposure  low    !!def = low
*** cfg$gms$cm_TCssp <- "SSP2"  #def = "SSP2"; {SSP2,SSP5} the scenario for which the damage function is specified - currently only SSP2 and SSP5 are available
$setGlobal cm_TCssp  SSP2  !! def = SSP2
*** cfg$gms$cm_TCpers <- 8   #def = 8; {0,1,2,3,4,5,6,7,8,9} the lags taken into account in the damage function
$setGlobal cm_TCpers  8  !! def = 8
*** cfg$gms$cm_TCspec <- "mean"  #def = mean; {mean,median,95,05,83,17}  the uncertainty estimate of the TC damage function
$setGlobal cm_TCspec  mean  !! def = mean
*** #cm_transpGDPscale <- "on"  # def "on", activate dampening factor to align edge-t non-energy transportation costs with historical GDP data"
$setglobal cm_transpGDPscale  off  !! def = off
*** This flag turns off output production
$setGlobal c_skip_output  off        !! def = off
***  cm_CO2TaxSectorMarkup     "CO2 tax markup in buildings or transport sector, a value of 0.5 means CO2 tax increased by 50%"
***  (off): no markup
***  ("GLO.build 1, USA_regi.trans 0.25, EUR_regi.trans 0.25"): "example for CO2 tax markup in transport of 25% in USA and EUR, and CO2eq tax markup in buildings sector of 100 % in all regions. Currently, build and trans are the only two elements of the set emi_sectors that are supported."
$setglobal cm_CO2TaxSectorMarkup  off   !! def = off
*** c_regi_nucscen              "regions to apply nucscen to"
***  specify regions to which nucscen, capturescen should apply to (e.g. c_regi_nucscen <- "JPN,USA")
$setGlobal c_regi_nucscen  all  !! def = all
***  c_regi_capturescen              "region to apply ccapturescen to"
$setGlobal c_regi_capturescen  all  !! def = all
***  c_regi_synfuelscen              "region to apply synfuelscen to"
$setGlobal c_regi_synfuelscen  all !! def = all
*** cm_process_based_steel      "switch to turn on process-based steel implementation"
*** enable process-based implementation of steel in subsectors realisation of industry module
$setglobal cm_process_based_steel   off  !! off  
*** c_CO2priceDependent_AdjCosts
***    default on changes adjustment costs for advanced vehicles in dependence of CO2 prices
$setglobal c_CO2priceDependent_AdjCosts    on   !! def = on
*** cm_dispatchSetyDown <- "off", if set to some value, this allows dispatching of pe2se technologies, 
***  i.e. the capacity factors can be varied by REMIND and are not fixed. The value of this switch gives the percentage points by how much the lower bound of capacity factors should be lowered.
***  Example: if set to 10, then the CF of all pe2se technologies can be decreased by up to 10% from the default value
***  Setting capacity factors free is numerically expensive but can be helpful to see if negative prices disappear in historic years as the model is allowed to dispatch.
$setGlobal cm_dispatchSetyDown  off   !! def = off  The amount that te producing any sety can dispatch less (in percent) - so setting "20" in a cm_dispatchSetyDown column in scenario_config will allow the model to reduce the output of this te by 20% 
*** cm_dispatchSeelDown <- "off", same as cm_dispatchSetyDown but only provides range to capacity factors of electricity generation technologies
***  cm_steel_secondary_max_share_scenario
***  defines maximum secondary steel share per region
***  Share is faded in from cm_startyear or 2020 to the denoted level by region/year.
***  Example: "2040.EUR 0.6" will cap the share of secondary steel production at 60 % in EUR from 2040 onwards
$setGlobal cm_dispatchSeelDown  off   !! def = off  The amount that te producing seel can dispatch less (in percent) (overrides cm_dispatchSetyDown for te producing seel)
*** set conopt version. Warning: conopt4 is in beta
$setGlobal cm_conoptv  conopt3    !! def = conopt3

$setglobal cm_secondary_steel_bound  scenario   !! def = scenario
$setglobal c_GDPpcScen  SSP2EU     !! def = gdp_SSP2   (automatically adjusted by start_run() based on GDPscen) 
$setglobal cm_demScen  gdp_SSP2EU     !! def = gdp_SSP2EU
$setglobal c_delayPolicy  SPA0           !! def = SPA0
$setGlobal c_scaleEmiHistorical  on  !! def = on
$setGlobal cm_nash_mode  parallel      !! def = parallel
$SetGlobal cm_quick_mode  off          !! def = off
$setGLobal cm_debug_preloop  off    !! def = off
$setGlobal c_EARLYRETIRE  on         !! def = on
$setGlobal cm_ccsfosall  off        !! def = off
$setGlobal cm_APscen  SSP2          !! def = SSP2
$setglobal cm_CES_configuration  indu_subsectors-buil_simple-tran_edge_esm-POP_pop_SSP2EU-GDP_gdp_SSP2EU-En_gdp_SSP2EU-Kap_debt_limit-Reg_62eff8f7   !! this will be changed by start_run()
$setglobal c_CES_calibration_iterations  10     !!  def  =  10
$setglobal c_CES_calibration_iteration  1     !!  def  =  1
$setglobal c_CES_calibration_industry_FE_target  1
$setglobal c_testOneRegi_region  EUR       !! def = EUR
$setglobal cm_fixCO2price  off !! def = off
$setglobal cm_altTransBunkersShare  off      !! def = off

*' @stop
*--------------------more flags-------------------------------------------------------
*-------------------------------------------------------------------------------------
***$setGlobal test_TS             !! def = off
*GL* Flag for short time horizon
***$setGlobal END2110             !! def = off
*-------------------------------------------------------------------------------------
*** automated checks and settings
*ag* set conopt version
option nlp = %cm_conoptv%;
option cns = %cm_conoptv%;

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
$include "./core/magicc.gms";    !!connection to MAGICC, needed for post-processing
$endif.c_skip_output

*** EOF ./main.gms

