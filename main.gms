*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
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
*' ![Technical Structure of REMIND](technical_structure.png){ width=100% }
*'
*'
*' The GAMS code follows a naming etiquette based on the following prefixes:
*'
*' * "q_" to designate equations,
*' * "v_" to designate variables,
*' * "s_" to designate scalars,
*' * "f_" to designate file parameters (parameters that contain unaltered data read in from input files),
*' * "o_" to designate output parameters (parameters that do not affect the optimization, but are affected by it),
*' * "c_" to designate switches (parameters that enable different configuration choices),
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



*##################### R SECTION START (VERSION INFO) ##########################
* 
* Regionscode: 690d3718e151be1b450b394c1064b1c5
* 
* Input data revision: 5.94
* 
* Last modification (input data): Thu Mar 19 16:15:13 2020
* 
*###################### R SECTION END (VERSION INFO) ###########################

*----------------------------------------------------------------------
*** main.gms: main file. welcome to remind!
*----------------------------------------------------------------------
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

*--------------------------------------------------------------------------
***           basic scenario choices
*--------------------------------------------------------------------------

***------------------------------------------------------------------------------------------------
***------------------------------------------------------------------------------------------------
*** WARNING *** WARNING *** WARNING *** WARNING *** WARNING *** WARNING ***
***------------------------------------------------------------------------------------------------
***                        START OF WARNING ZONE
***------------------------------------------------------------------------------------------------
***
*** PLEASE DO NOT PERFORM ANY CHANGES IN THE WARNING ZONE! ALL SETTINGS WILL BE AUTOMATICALLY
*** SET BY submit.R BASED ON THE SETTINGS OF THE CORRESPONDING CFG FILE
*** PLEASE DO ALL SETTINGS IN THE CORRESPONDING CFG FILE (e.g. config/default.cfg)
***
***------------------------------------------------------------------------------------------------
*** WARNING *** WARNING *** WARNING *** WARNING *** WARNING *** WARNING ***
***------------------------------------------------------------------------------------------------


***---------------------    Run name    -----------------------------------------
$setGlobal c_expname  default

***------------------------------------------------------------------------------
***                           MODULES
***------------------------------------------------------------------------------

***---------------------    01_macro    -----------------------------------------
$setGlobal macro  singleSectorGr  !! def = singleSectorGr
***---------------------    02_welfare    ---------------------------------------
$setGlobal welfare  utilitarian  !! def = utilitarian
***---------------------    04_PE_FE_parameters    ------------------------------
$setGlobal PE_FE_parameters  iea2014  !! def = iea2014
***---------------------    05_initialCap    ------------------------------------
$setGlobal initialCap  on             !! def = on
***---------------------    11_aerosols    --------------------------------------
$setGlobal aerosols  exoGAINS         !! def = exoGAINS
***---------------------    15_climate    ---------------------------------------
$setGlobal climate  off               !! def = off
***---------------------    16_downscaleTemperature    --------------------------
$setGlobal downscaleTemperature  off  !! def = off
***---------------------    20_growth    ----------------------------------------
$setGlobal growth  exogenous          !! def = exogenous
***---------------------    21_tax    -------------------------------------------
$setGlobal tax  on                    !! def = on
***---------------------    22_subsidizeLearning    -----------------------------
$setGlobal subsidizeLearning  off     !! def = off
***---------------------    23_capitalMarket    -----------------------------
$setGlobal capitalMarket  debt_limit     !! def = debt_limit
***---------------------    24_trade    -----------------------------------------
$setGlobal trade  standard     !! def = standard
***---------------------    26_agCosts ------------------------------------------
$setGlobal agCosts  costs               !! def = costs
***---------------------    29_CES_parameters    --------------------------------
$setglobal CES_parameters  load       !! def = load
***---------------------    30_biomass    ---------------------------------------
$setGlobal biomass  magpie_40 !! def = magpie_40
***---------------------    31_fossil    ----------------------------------------
$setGlobal fossil  grades2poly        !! def = grades2poly
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
***---------------------    38_stationary    --------------------------------------
$setglobal stationary  off            !! def = simple
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
***--------------- declaration of parameters for switches ----------------------
parameters
cm_iteration_max      "number of Negishi iterations (up to 49)"
c_solver_try_max      "maximum number of inner iterations within one Negishi iteration (<10)"
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
cm_bioenergy_tax      "level of bioenergy tax in fraction of bioenergy price"
cm_bioenergymaxscen   "choose bound on global pebiolc production excluding residues"
cm_tradecost_bio       "choose financal tradecosts for biomass (purpose grown pebiolc)"
cm_1stgen_phaseout    "choose if 1st generation biofuels should phase out after 2030 (vm_deltaCap=0)"
cm_cprice_red_factor  "reduction factor for price on co2luc when calculating the revenues. Replicates the reduction applied in MAgPIE"
cm_startyear          "first optimized modelling time step [year]"
c_start_budget        "start of GHG budget limit"
cm_prtpScen           "pure rate of time preference standard values"
cm_fetaxscen          "choice of final energy tax path, subsidy path and inconvenience cost path, values other than 0 make setting module 21_tax on"
cm_multigasscen       "scenario on GHG portfolio to be included in permit trading scheme"
cm_permittradescen    "scenario on permit trade"
cm_limit_peur_scen    "limit total uranium production"
cm_rentdiscoil        "[grades2poly] discount factor for the oil rent"
cm_rentdiscoil2       "[grades2poly] discount factor for the oil rent achieved in 2100"
cm_rentconvoil        "[grades2poly] number of years required to converge to the 2100 oil rent"
cm_rentdiscgas        "[grades2poly] discount factor for the gas rent"
cm_rentdiscgas2       "[grades2poly] discount factor for the gas rent achieved in 2100"
cm_rentconvgas        "[grades2poly] number of years required to converge to the 2100 gas rent"
cm_rentdisccoal       "[grades2poly] discount factor for the coal rent"
cm_rentdisccoal2      "[grades2poly] discount factor for the coal rent achieved in 2100"
cm_rentconvcoal       "[grades2poly] number of years required to converge to the 2100 coal rent"
cm_earlyreti_rate     "maximum portion of capital stock that can be retired in one year"
c_cint_scen           "additional GHG emissions from mining fossil fuels"
cm_so2tax_scen         "level of SO2 tax"
cm_damage              "cm_damage factor for forcing overshoot"
cm_solwindenergyscen   "scenario for fluctuating renewables, 1 is reference, 2 is pessimistic with limits to fluctuating SE el share"
c_techAssumptScen     "scenario for assumptions of energy technologies based on SSP scenarios, 1: SSP2 (default), 2: SSP1, 3: SSP5"
c_ccsinjecratescen    "CCS injection rate factor, 0.5% by default yielding a 60 Mt per year IR"
c_ccscapratescen      "CCS capture rate"
c_export_tax_scen    "choose which oil export tax is used in the model. 0 = none, 1 = fix"
cm_iterative_target_adj "whether or not a tax or a budget target should be iteratively adjusted depending on actual emission or forcing level"
cm_gdximport_target   "whether or not the starting value for iteratively adjusted budgets, tax scenarios, or forcing targets (emiscen 5,6,8,9) should be read in from the input.gdx"
cm_gs_ew              "grain size (for enhanced weathering, CDR module) [micrometre]"
cm_LimRock             "limit amount of rock spread each year [Gt]"
c_tau_so2_xmpt       "switch for temporarily (mainly in the past) exempting chinese SO2 emissions from the SO2 tax"
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
cm_frac_CCS          "tax on CCS to reflect risk of leakage, formulated as fraction of ccs O&M costs"
cm_frac_NetNegEmi    "tax on CDR to reflect risk of overshooting, formulated as fraction of carbon price"

cm_DiscRateScen          "Scenario for the implicit discount rate applied to the energy efficiency capital"
cm_noReboundEffect      "Switch for allowing a rebound effect when closing the efficiency gap (cm_DiscRateScen)"
cm_peakBudgYr       "date of net-zero CO2 emissions for peak budget runs without overshoot"
cm_taxCO2inc_after_peakBudgYr "annual increase of CO2 price after the Peak Budget Year in $ per tCO2"
cm_CO2priceRegConvEndYr      "Year at which regional CO2 prices converge in module 45 realization diffPhaseIn2LinFlex"
c_regi_nucscen				"regions to apply nucscen to"
c_regi_capturescen			"region to apply ccapturescen to"
;

*** --------------------------------------------------------------------------------------------------------------------------------------------------------------------
***                           YOU ARE IN THE WARNING ZONE (DON'T DO CHANGES HERE)
*** --------------------------------------------------------------------------------------------------------------------------------------------------------------------

cm_iteration_max       = 1;     !! def = 1
c_solver_try_max       = 2;     !! def = 2
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


cm_bioenergy_tax    = 1.5;       !! def = 1.5
cm_bioenergymaxscen = 0;         !! def = 0
cm_tradecost_bio     = 2;         !! def = 2
$setglobal cm_LU_emi_scen  SSP2   !! def = SSP2
cm_1stgen_phaseout  = 0;         !! def = 0
cm_cprice_red_factor  = 1;         !! def = 1

$setglobal cm_POPscen  pop_SSP2  !! def = pop_SSP2
$setglobal cm_GDPscen  gdp_SSP2  !! def = gdp_SSP2
$setglobal c_GDPpcScen  SSP2     !! def = gdp_SSP2   (automatically adjusted by start_run() based on GDPscen) 

*AG* and *CB* for cm_startyear greater than 2005, you have to copy the fulldata.gdx (rename it to: input_ref.gdx) from the run you want to build your new run onto.
cm_startyear      = 2005;      !! def = 2005 for a BAU, 2015 for policy runs
c_start_budget    = 2100;      !! def = 2100

cm_prtpScen         = 3;         !! def = 3
cm_fetaxscen        = 3;         !! def = 3
cm_multigasscen     = 2;         !! def = 2
cm_permittradescen  = 1;         !! def = 1
cm_limit_peur_scen  = 1;         !! def = 1
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
cm_earlyreti_rate   = 0.09;      !! def 0.09

cm_so2tax_scen        = 1;         !! def =
c_cint_scen           = 1;         !! def = 1
cm_damage             = 0.005;     !! def = 0.005
cm_solwindenergyscen  = 1;         !! def = 1
c_techAssumptScen     = 1;         !! def = 1
c_ccsinjecratescen    = 1;         !! def = 1
c_ccscapratescen      = 1;         !! def = 1
c_export_tax_scen     = 0;         !! def = 0
cm_iterative_target_adj  = 0;      !! def = 0
cm_gdximport_target      = 0;      !! def = 0
$setglobal c_SSP_forcing_adjust  forcing_SSP2   !! def = forcing_SSP2
$setglobal c_delayPolicy  SPA0           !! def = SPA0
cm_gs_ew                 = 20;     !! def = 20
cm_LimRock               = 1000;   !! def = 1000
c_tau_so2_xmpt           = 0;      !! def = 0
cm_expoLinear_yearStart  = 2050;   !! def = 2050
c_budgetCO2FFI           = 1000;   !! def = 1000
c_abtrdy                 = 2010;   !! def = 2010
c_abtcst                 = 1;      !! def = 1
c_budgetCO2              = 1350;   !! def = 1300
$setGlobal cm_regiCO2target  off       !! def = off
cm_peakBudgYr                 = 2050;    !! def = 2050
cm_taxCO2inc_after_peakBudgYr = 2;      !! def = 2
cm_CO2priceRegConvEndYr       = 2050;   !! def = 2050

cm_trdadj            = 2;    !! def = 2.0
cm_trdcst            = 1.5;  !! def = 1.5
c_refcapbnd          = 0;    !! def = 0
cm_frac_CCS          = 10;   !! def = 10
cm_frac_NetNegEmi    = 0.5;  !! def = 0.5

cm_damages_BurkeLike_specification    = 0;     !! def = 0
cm_damages_BurkeLike_persistenceTime  = 30;    !! def = 30
cm_damages_SccHorizon                 = 100;   !! def = 100
cm_carbonprice_temperatureLimit       = 1.8;   !! def = 1.8


cm_DiscRateScen        = 0;!! def = 0
cm_noReboundEffect     = 0;
$setGlobal cm_EsubGrowth         low  !! def = low
$setGlobal c_scaleEmiHistorical  on  !! def = on

$setGlobal cm_EDGEtr_scen  Conservative_liquids  !! def = Conservative_liquids

$setGlobal c_regi_nucscen  all !! def = all
$setGlobal c_regi_capturescen  all !! def = all

*** --------------------------------------------------------------------------------------------------------------------------------------------------------------------
***                           YOU ARE IN THE WARNING ZONE (DON'T DO CHANGES HERE)
*** --------------------------------------------------------------------------------------------------------------------------------------------------------------------
*--------------------flags------------------------------------------------------------
$SETGLOBAL cm_SlowConvergence  off        !! def = off
$setGlobal cm_nash_mode  parallel      !! def = parallel
$setGlobal c_EARLYRETIRE       on         !! def = on
$setGlobal cm_OILRETIRE  off        !! def = off
$setglobal cm_INCONV_PENALTY  on         !! def = on
$setGlobal cm_so2_out_of_opt  on         !! def = on
$setGlobal c_skip_output  off        !! def = off
$setGlobal cm_MOFEX  off        !! def = off
$setGlobal cm_conoptv  conopt3    !! def = conopt3
$setGlobal cm_ccsfosall  off        !! def = off

$setGlobal cm_APscen  SSP2          !! def = SSP2
$setGlobal cm_magicc_calibrateTemperature2000  uncalibrated  !! def=uncalibrated
$setGlobal cm_magicc_config  OLDDEFAULT    !! def = OLDDEFAULT
$setGlobal cm_magicc_temperatureImpulseResponse  off           !! def = off

$setGlobal cm_damage_DiceLike_specification  HowardNonCatastrophic   !! def = HowardNonCatastrophic

$setglobal cm_CES_configuration  stat_off-indu_fixed_shares-buil_simple-tran_complex-POP_pop_SSP2-GDP_gdp_SSP2-Kap_debt_limit-Reg_690d3718e1   !! this will be changed by start_run()

$setglobal c_CES_calibration_new_structure  0    !! def =  0
$setglobal c_CES_calibration_iterations  10    !! def = 10
$setglobal c_CES_calibration_iteration          1    !! def =  1
$setglobal c_CES_calibration_write_prices  0    !! def =  0
$setglobal cm_CES_calibration_default_prices  0    !! def = 0

$setglobal c_testOneRegi_region  EUR       !! def = EUR

$setglobal cm_cooling_shares  static    !! def = static
$setglobal cm_techcosts  REG       !! def = REG
$setglobal cm_regNetNegCO2  on       !! def = on

*** --------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** --------------------------------------------------------------------------------------------------------------------------------------------------------------------
***                                  END OF WARNING ZONE
*** --------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** --------------------------------------------------------------------------------------------------------------------------------------------------------------------

*--------------------more flags-------------------------------------------------------
*-------------------------------------------------------------------------------------
*AG* the remaining flags outside the warning zone are usually not changed
*LB* default: 5 years time steps from 2005 to 2150
*LB* test_TS: 2005,2010, 2020,2030,2040,2050,2070,2090,2110,2130,2150
*LB* cm_less_TS: 2005,2010,2015,2020,2025,2030,2035,2040,2045,2050,2055,2060,2070,2080,2090,2100,2110,2130,2150
*LB* END2110: 2005:5:2105,2120
$setGlobal cm_less_TS  on  !! def = on
***$setGlobal test_TS             !! def = off
*GL* Flag for short time horizon
***$setGlobal END2110             !! def = off
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
