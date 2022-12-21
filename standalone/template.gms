*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de

*** This is a standalone skeleton which should be used as template
*** if only parts of the model should be run. It contains the basic,
*** structural components of the model.
*** To use it, please copy this file, give it an explaining name.
*** After that you can modify it based on the given requirements.
*** You can add own code, but also delete code
*** (e.g. the model statement or the provided loops) if these parts
*** are irrelevant for your analysis.

*##################### R SECTION START (VERSION INFO) ##########################
*
* Regionscode: 690d3718e151be1b450b394c1064b1c5
*
* Input data revision: 5.846
*
* Last modification (input data): Tue Jul 02 13:58:54 2019
*
*###################### R SECTION END (VERSION INFO) ###########################

$title model_title

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

***---------------------    Run name and description    -------------------------
$setGlobal c_expname      default
$setGlobal c_description  "REMIND standalone template"

***------------------------------------------------------------------------------
***                           MODULES
***------------------------------------------------------------------------------
* For now, all realizations must be declared to initialize the core set module2realization

***---------------------    04_PE_FE_parameters    ------------------------------
$setGlobal PE_FE_parameters  iea2014  !! def = iea2014
***---------------------    05_initialCap    ------------------------------------
$setGlobal initialCap  on             !! def = on
***---------------------    11_aerosols    --------------------------------------
$setGlobal aerosols  exoGAINS         !! def = exoGAINS
***---------------------    15_climate    ---------------------------------------
$setGlobal climate  off               !! def = off
***---------------------    16_downscaleTemperature    ---------------------------------------
$setGlobal downscaleTemperature  off  !! def = off
***---------------------    20_growth    ----------------------------------------
$setGlobal growth  exogenous          !! def = exogenous
***---------------------    21_tax    -------------------------------------------
$setGlobal tax  on                    !! def = on
***---------------------    22_subsidizeLearning    -----------------------------
$setGlobal subsidizeLearning  off     !! def = off
***---------------------    23_capitalMarket    -----------------------------
$setGlobal capitalMarket  perfect     !! def = perfect
***---------------------    26_agCosts ------------------------------------------
$setGlobal agCosts  costs               !! def = costs
***---------------------    29_CES_parameters    --------------------------------
$setglobal CES_parameters  load       !! def = load
***---------------------    30_biomass    ---------------------------------------
$setGlobal biomass  magpie_40 !! def = magpie_40
***---------------------    31_fossil    ----------------------------------------
$setGlobal fossil  timeDepGrades        !! def = grades2poly
***---------------------    32_power    ----------------------------------------
$setGlobal power  IntC               !! def = IntC
***---------------------    33_cdr       ----------------------------------------
$setGlobal CDR  DAC                   !! def = DAC
***---------------------    35_transport    -------------------------------------
$setGlobal transport  complex         !! def = complex
***---------------------    36_buildings    -------------------------------------
$setglobal buildings  simple          !! def = simple
***---------------------    37_industry    --------------------------------------
$setglobal industry  fixed_shares     !! def = simple
***---------------------    39_CCU    --------------------------------------
$setglobal CCU  off !! def = off
***---------------------    40_techpol  -----------------------------------------
$setglobal techpol  none              !! def = none
***---------------------    41_emicapregi  --------------------------------------
$setglobal emicapregi  none           !! def = none
***---------------------    42_banking  -----------------------------------------
$setglobal banking  off               !! def = off
***---------------------    45_carbonprice  -------------------------------------
$setglobal carbonprice  none          !! def = none
***---------------------    47_regipol  -------------------------------------
$setglobal regipol  none              !! def = none
***---------------------    50_damages    ---------------------------------------
$setGlobal damages  off               !! def = off
***---------------------    51_internalizeDamages    ---------------------------------------
$setGlobal internalizeDamages  off               !! def = off
***---------------------    70_water  -------------------------------------------
$setglobal water  off                 !! def = off
***---------------------    80_optimization    ----------------------------------
$setGlobal optimization  nash         !! def = nash
***---------------------    81_codePerformance    -------------------------------
$setGlobal codePerformance  off       !! def = off
***-----------------------------------------------------------------------------
***                     SWITCHES and FLAGS
***-----------------------------------------------------------------------------
* For now, all switches and flags must be copied from main.gms.
* Changes can be made below to set new defaults specific to the standalone model.
* It is recommended to first copy this section from the most recent main.gms to stay current.

***--------------- declaration of parameters for switches ----------------------
parameters
cm_iteration_max      "number of Negishi iterations (up to 49)"
cm_solver_try_max      "maximum number of inner iterations within one Negishi iteration (<10)"
c_keep_iteration_gdxes   "save intermediate iteration gdxes"
cm_nash_autoconverge  "choice of nash convergence mode"
cm_emiscen            "policy scenario choice"
cm_co2_tax_2020       "level of co2 tax in year 2020 in $ per t CO2eq, makes sense only for emiscen eq 9 and 45_carbonprice exponential"
cm_co2_tax_growth     "growth rate of carbon tax"
c_macscen            "use of mac"
cm_nucscen            "nuclear option choice"
cm_ccapturescen       "carbon capture option choice"
c_bioliqscen          "bioenergy liquids technology choise"
c_bioh2scen           "bioenergy hydrogen technology choice"
cm_IndCCSscen        "CCS for Industry"
cm_optimisticMAC     "assume optimistic Industry MAC from AR5 Ch. 10?"
cm_CCS_cement        "CCS for cement sub-sector"
cm_CCS_chemicals     "CCS for chemicals sub-sector"
cm_CCS_steel         "CCS for steel sub-sector"
c_solscen             "solar option choice"
cm_bioenergy_SustTax    "level of the bioenergy sustainability tax in fraction of bioenergy price"
cm_bioenergy_EF_for_tax "bioenergy emission factor that is used to derive a bioenergy tax [kgCO2/GJ]"
cm_bioenergymaxscen   "bound on global pebiolc production excluding residues"
cm_tradecost_bio       "choose financal tradecosts for biomass (purpose grown pebiolc)"
cm_1stgen_phaseout    "choose if 1st generation biofuels should phase out after 2030 (vm_deltaCap=0)"
cm_startyear          "first optimized modelling time step"
c_start_budget        "start of GHG budget limit"
cm_prtpScen            "pure rate of time preference standard values"
cm_fetaxscen          "choice of final energy tax path, subsidy path and inconvenience cost path, values other than 0 make setting module 21_tax on"
cm_multigasscen       "scenario on GHG portfolio to be included in permit trading scheme"
cm_permittradescen    "scenario on permit trade"
cm_rentdiscoil        "[grades2poly] discount factor for the oil rent"
cm_rentdiscoil2       "[grades2poly] discount factor for the oil rent achieved in 2100"
cm_rentconvoil        "[grades2poly] number of years required to converge to the 2100 oil rent"
cm_rentdiscgas        "[grades2poly] discount factor for the gas rent"
cm_rentdiscgas2       "[grades2poly] discount factor for the gas rent achieved in 2100"
cm_rentconvgas        "[grades2poly] number of years required to converge to the 2100 gas rent"
cm_rentdisccoal       "[grades2poly] discount factor for the coal rent"
cm_rentdisccoal2      "[grades2poly] discount factor for the coal rent achieved in 2100"
cm_rentconvcoal       "[grades2poly] number of years required to converge to the 2100 coal rent"
c_cint_scen           "additional GHG emissions from mining fossil fuels"
cm_so2tax_scen         "level of SO2 tax"
cm_solwindenergyscen   "scenario for fluctuating renewables, 1 is reference, 2 is pessimistic with limits to fluctuating SE el share"
c_techAssumptScen     "scenario for assumptions of energy technologies based on SSP scenarios, 1: SSP2 (default), 2: SSP1, 3: SSP5"
c_ccsinjecratescen    "CCS injection rate factor, 0.5% by default yielding a 60 Mt per year IR"
c_ccscapratescen      "CCS capture rate"
c_export_tax_scen    "choose which oil export tax is used in the model. 0 = none, 1 = fix"
cm_iterative_target_adj "whether or not a tax or a budget target should be iteratively adjusted depending on actual emission or forcing level"
cm_gdximport_target   "whether or not the starting value for iteratively adjusted budgets, tax scenarios, or forcing targets (emiscen 5,6,8,9) should be read in from the input.gdx"
cm_gs_ew              "grain size (for enhanced weathering, CDR module) [micrometre]"
cm_LimRock             "limit amount of rock spread each year [Gt]"
cm_expoLinear_yearStart "time at which carbon price increases lineraly instead of exponentially"

c_budgetCO2FFI        "carbon budget for CO2 emissions from FFI (in GtCO2)"
c_abtrdy              "first year in which advanced bio-energy technology are ready (unit is year; e.g. 2050)"
c_abtcst              "scaling of the cost of advanced bio-energy technologies (no unit, 50% increase means 1.5)"
c_budgetCO2        "carbon budget for all CO2 emissions (in GtCO2)"

cm_trdcst              "parameter to scale trade export cost for gas"
cm_trdadj              "parameter scale the adjustment cost parameter for increasing gas trade export"

c_refcapbnd           "switch for fixing refinery capacities to the SSP2 levels in 2010 (if equal zero then no fixing)"

cm_damages_BurkeLike_specification      "empirical specification for Burke-like damage functions"
cm_damages_BurkeLike_persistenceTime    " persistence time in years for Burke-like damage functions"
cm_damages_SccHorizon               "Horizon for SCC calculation. Damages cm_damagesSccHorizon years into the future are internalized."
cm_carbonprice_temperatureLimit "not-to-exceed temperature target in degree above pre-industrial"
cm_frac_CCS          "tax on CCS to reflect risk of leakage, formulated as fraction of carbon price"
cm_frac_NetNegEmi    "tax on CDR to reflect risk of overshooting, formulated as fraction of carbon price"

cm_DiscRateScen          "Scenario for the implicit discount rate applied to the energy efficiency capital"
cm_noReboundEffect      "Switch for allowing a rebound effect when closing the efficiency gap (cm_DiscRateScen)"
;

*** --------------------------------------------------------------------------------------------------------------------------------------------------------------------
***                           YOU ARE IN THE WARNING ZONE (DON'T DO CHANGES HERE)
*** --------------------------------------------------------------------------------------------------------------------------------------------------------------------

cm_iteration_max       = 1;     !! def = 1
cm_solver_try_max       = 2;     !! def = 2
c_keep_iteration_gdxes = 0;     !! def = 0
cm_nash_autoconverge   = 1;     !! def = 1
$setglobal cm_MAgPIE_coupling  off     !! def = "off"

cm_emiscen        = 1;         !! def = 1
$setglobal cm_rcp_scen  none   !! def = "none"
cm_co2_tax_2020   = -1;        !! def = -1
cm_co2_tax_growth = 1.05;      !! def = 1.05
c_macscen         = 1;         !! def = 1

cm_nucscen       = 2;        !! def = 2
cm_ccapturescen  = 1;        !! def = 1
c_bioliqscen     = 1;        !! def = 1
c_bioh2scen      = 1;        !! def = 1
c_solscen        = 1;        !! def = 1

cm_IndCCSscen          = 1;        !! def = 1
cm_optimisticMAC       = 0;        !! def = 0
cm_CCS_cement          = 1;        !! def = 1
cm_CCS_chemicals       = 1;        !! def = 1
cm_CCS_steel           = 1;        !! def = 1


cm_bioenergy_SustTax    = 1.5;            !! def = 1.5
cm_bioenergy_EF_for_tax = 0;              !! def = 0
$setGlobal cm_regi_bioenergy_EFTax  glob  !! def = glob
cm_bioenergymaxscen     = 0;              !! def = 0
cm_tradecost_bio        = 2;              !! def = 2
$setglobal cm_LU_emi_scen  SSP2           !! def = SSP2
cm_1stgen_phaseout      = 0;              !! def = 0
$setglobal cm_tradbio_phaseout  default   !! def = default
cm_biolc_tech_phaseout  = 0;              !! def = 0

$setglobal cm_POPscen  pop_SSP2  !! def = pop_SSP2
$setglobal cm_GDPscen  gdp_SSP2  !! def = gdp_SSP2
$setglobal c_GDPpcScen  SSP2     !! def = gdp_SSP2   (automatically adjusted in core/datainput.gms based on GDPscen)

*AG* and *CB* for cm_startyear greater than 2005, you have to copy the fulldata.gdx (rename it to: input_ref.gdx) from the run you want to build your new run onto.
cm_startyear      = 2005;      !! def = 2005 for a BAU, 2015 for policy runs
c_start_budget    = 2100;      !! def = 2100

cm_prtpScen         = 3;         !! def = 3
cm_fetaxscen        = 3;         !! def = 3
cm_multigasscen     = 2;         !! def = 2
cm_permittradescen  = 1;         !! def = 1
$setGlobal cm_oil_scen  medOil         !! def = medOil
$setGlobal cm_gas_scen  medGas         !! def = medGas
$setGlobal cm_coal_scen  medCoal        !! def = medCoal
cm_rentdiscoil      = 0.2;       !! def 0.2
cm_rentdiscoil2     = 0.9;       !! def 0.9
cm_rentconvoil      = 50;        !! def 50
cm_rentdiscgas      = 0.6;       !! def 0.6
cm_rentdiscgas2     = 0.8;       !! def 0.8
cm_rentconvgas      = 50;        !! def 50
cm_rentdisccoal     = 0.4;       !! def 0.4
cm_rentdisccoal2    = 0.6;       !! def 0.6
cm_rentconvcoal     = 50;        !! def 50

cm_so2tax_scen        = 1;         !! def =
c_cint_scen           = 1;         !! def = 1
cm_solwindenergyscen  = 1;         !! def = 1
c_techAssumptScen     = 1;         !! def = 1
c_ccsinjecratescen    = 1;         !! def = 1
c_ccscapratescen      = 1;         !! def = 1
c_export_tax_scen     = 0;         !! def = 0
cm_iterative_target_adj  = 0;      !! def = 0
cm_gdximport_target      = 0;      !! def = 0
$setglobal c_SSP_forcing_adjust  forcing_SSP2   !! def = forcing_SSP2
cm_gs_ew                 = 20;     !! def = 20
cm_LimRock               = 1000;   !! def = 1000
cm_expoLinear_yearStart  = 2050;   !! def = 2050
c_budgetCO2FFI           = 1000;   !! def = 1000
c_abtrdy                 = 2010;   !! def = 2010
c_abtcst                 = 1;      !! def = 1
c_budgetCO2              = 1350;   !! def = 1300
$setGlobal cm_emiMktTarget  off   !! def = off

cm_trdadj            = 2;    !! def = 2.0
cm_trdcst             = 1.5;  !! def = 1.5
c_refcapbnd          = 0;    !! def = 0
cm_frac_CCS          = 10;   !! def = 10
cm_frac_NetNegEmi    = 0.5;  !! def = 0.5

cm_damages_BurkeLike_specification    = 0;     !! def = 0
cm_damages_BurkeLike_persistenceTime  = 30;    !! def = 30
cm_damages_SccHorizon                 = 100;   !! def = 100
cm_carbonprice_temperatureLimit       = 1.8;   !! def = 1.8


cm_DiscRateScen = 0;!! def = 0
cm_noReboundEffect = 0;
*** --------------------------------------------------------------------------------------------------------------------------------------------------------------------
***                           YOU ARE IN THE WARNING ZONE (DON'T DO CHANGES HERE)
*** --------------------------------------------------------------------------------------------------------------------------------------------------------------------
*--------------------flags------------------------------------------------------------
$SETGLOBAL cm_SlowConvergence  off        !! def = off
$setGlobal cm_nash_mode  parallel   !! def = parallel
$setglobal cm_INCONV_PENALTY  on         !! def = on
$setGlobal c_skip_output  off        !! def = off
$setGlobal cm_MOFEX  off        !! def = off
$setGlobal cm_conoptv  conopt3    !! def = conopt3

$setGlobal cm_APscen  SSP2          !! def = SSP2
$setGlobal cm_magicc_calibrateTemperature2000  uncalibrated  !! def=uncalibrated
$setGlobal cm_magicc_config  OLDDEFAULT    !! def = OLDDEFAULT
$setGlobal cm_magicc_temperatureImpulseResponse  off           !! def = off

$setGlobal cm_damage_DiceLike_specification  HowardNonCatastrophic   !! def = HowardNonCatastrophic

$setglobal cm_CES_configuration  indu_fixed_shares-buil_simple-tran_complex-POP_pop_SSP2-GDP_gdp_SSP2-Kap_perfect-Reg_690d3718e1   !! this will be changed by start_run()

$setglobal c_CES_calibration_new_structure  0    !! def =  0
$setglobal c_CES_calibration_iterations  10   !! def = 10
$setglobal c_CES_calibration_write_prices  0    !! def =  0
$setglobal cm_CES_calibration_default_prices  0.01    !! def = 0.01

$setglobal c_testOneRegi_region  EUR       !! def = EUR

$setglobal cm_techcosts  REG       !! def = REG

*** --------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** --------------------------------------------------------------------------------------------------------------------------------------------------------------------
***                                  END OF WARNING ZONE
*** --------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** --------------------------------------------------------------------------------------------------------------------------------------------------------------------

*--------------------more flags-------------------------------------------------------
*-------------------------------------------------------------------------------------
*AG* the remaining flags outside the warning zone are usually not changed
$setGlobal cm_Full_Integration  off     !! def = off

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
$include    "./modules/04_PE_FE_parameters/iea2014/datainput.gms"; !! required if core/bounds.gms is included
$include    "./modules/29_CES_parameters/load/datainput.gms"; !! required if core/bounds.gms is included
*$include "./modules/00_EXAMPLE/REALIZATION/datainput.gms";
*$include "./modules/00_EXAMPLE_dependency/dep_REALIZATION/datainput.gms";  !! if necessary

*--------------------------------------------------------------------------
***          EQUATIONS
*--------------------------------------------------------------------------
$include    "./core/equations.gms";
*$include "./modules/EXAMPLE/REALIZATION/equations.gms";

*** AND list below any necessary equations from core and other modules

*** OR only list below the equations listed in the model

*** q_example ..
***       v_example =g= sum(exampleset, p_example(exampleset));

*--------------------------------------------------------------------------
***           PRELOOP   Calculations before the Negishi-loop starts
***                     (e.g. initial calibration of macroeconomic module)
*--------------------------------------------------------------------------
$include    "./modules/04_PE_FE_parameters/iea2014/preloop.gms";  !! required if core/bounds.gms is included
$include    "./modules/05_initialCap/on/preloop.gms";  !! required if core/bounds.gms is included
$include    "./modules/29_CES_parameters/load/preloop.gms";  !! required if core/bounds.gms is included
*$include "./modules/EXAMPLE/REALIZATION/preloop.gms";  !! if necessary
*$include "./modules/00_EXAMPLE_dependency/dep_REALIZATION/preloop.gms";  !! if necessary

*--------------------- MODEL DEFINITION & SOLVER OPTIONS ------------------
*** use all equations that are available
model example / all /;
*** or list only the needed equations
*** model example / q_example /;

*--------------------------------------------------------------------------
***         solveoptions
*--------------------------------------------------------------------------
option profile   = 0;
option limcol    = 100;
option limrow    = 100;
option savepoint = 0;
option reslim    = 1.e+6;
option iterlim   = 1.e+6;
option solprint  = off ;

***-------------------------------------------------------------------
***                     read GDX
***-------------------------------------------------------------------
*** load start gdx
execute_loadpoint 'input';
***p00_example = vm_example.l  !! initialize relevant parameters for the model

***--------------------------------------------------------------------------
***    start iteration loop
***--------------------------------------------------------------------------

***################# START HERE AN ITERATION IF NEEDED ######################

*---------------------------------------------------------------------------
***         BOUNDS
*---------------------------------------------------------------------------
$include    "./core/bounds.gms";   !! if necessary
*$include "./modules/EXAMPLE/REALIZATION/bounds.gms";  !! if necessary
*$include "./modules/00_EXAMPLE_dependency/dep_REALIZATION/preloop.gms";  !! if necessary

***--------------------------------------------------------------------------
***         PRESOLVE
***--------------------------------------------------------------------------
*$include "./modules/EXAMPLE/REALIZATION/presolve.gms"  !! if necessary

***--------------------------------------------------------------------------
***         SOLVE
***--------------------------------------------------------------------------
*solve m00_EXAMPLE using nlp minimizing/maximizing v00_EXAMPLE_costs;
    o_modelstat = m00_EXAMPLE.modelstat;

***--------------------------------------------------------------------------
***         POSTSOLVE
***--------------------------------------------------------------------------
*$include "./modules/EXAMPLE/REALIZATION/postsolve.gms"  !! if necessary

***################# END HERE AN ITERATION IF NEEDED #######################

*--------------------------------------------------------------------------
***         OUTPUT
*--------------------------------------------------------------------------
*$include "./modules/EXAMPLE/REALIZATION/output.gms"  !! if necessary

*---------------------------------------------------------------------------
***                  save gdx
*---------------------------------------------------------------------------
execute_unload 'fulldata';
