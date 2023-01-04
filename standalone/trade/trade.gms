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
* Regionscode: 62eff8f7
* 
* Input data revision: 6.241
* 
* Last modification (input data): Thu Aug 19 11:55:43 2021
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
$setGlobal c_expname      standalone_trade
$setGlobal c_description  "standalone trade model"

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
$setGlobal trade  capacity     !! def = standard
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
$setglobal CCU  on !! def = on
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
cm_iteration_max      "number of Negishi iterations"
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
c_shGreenH2           "lower bound on share of green hydrogen in all hydrogen by 2030"
c_shBioTrans          "upper bound on share of bioliquids in transport from 2025 onwards"
cm_shSynTrans         "lower bound on share of synthetic fuels in all transport fuels by 2045"
cm_shSynGas           "lower bound on share of synthetic gases by 2045"
cm_IndCCSscen        "CCS for Industry"
cm_optimisticMAC     "assume optimistic Industry MAC from AR5 Ch. 10?"
cm_CCS_cement        "CCS for cement sub-sector"
cm_CCS_chemicals     "CCS for chemicals sub-sector"
cm_CCS_steel         "CCS for steel sub-sector"
c_solscen             "solar option choice"
cm_bioenergy_SustTax    "level of the bioenergy sustainability tax in fraction of bioenergy price"
cm_bioenergy_EF_for_tax "bioenergy emission factor that is used to derive a bioenergy tax [kgCO2/GJ]"
cm_bioenergymaxscen   "choose bound on global pebiolc production excluding residues"
cm_tradecost_bio       "choose financal tradecosts for biomass (purpose grown pebiolc)"
cm_1stgen_phaseout    "choose if 1st generation biofuels should phase out after 2030 (vm_deltaCap=0)"
cm_tradbio_phaseout   "Switch that allows for a faster phase out of traditional biomass"
cm_startyear          "first optimized modelling time step [year]"
c_start_budget        "start of GHG budget limit"
cm_prtpScen           "pure rate of time preference standard values"
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

cm_postTargetIncrease     "carbon price increase per year after target is reached (euro per tCO2)"

c_refcapbnd           "switch for fixing refinery capacities to the SSP2 levels in 2010 (if equal zero then no fixing)"

cm_damages_BurkeLike_specification      "empirical specification for Burke-like damage functions"
cm_damages_BurkeLike_persistenceTime    " persistence time in years for Burke-like damage functions"
cm_damages_SccHorizon               "Horizon for SCC calculation. Damages cm_damagesSccHorizon years into the future are internalized."
cm_carbonprice_temperatureLimit "not-to-exceed temperature target in degree above pre-industrial"
cm_frac_CCS          "tax on CCS to reflect risk of leakage, formulated as fraction of ccs O&M costs"
cm_frac_NetNegEmi    "tax on CDR to reflect risk of overshooting, formulated as fraction of carbon price"

cm_DiscRateScen          "Scenario for the implicit discount rate applied to the energy efficiency capital"
cm_noReboundEffect      "Switch for allowing a rebound effect when closing the efficiency gap (cm_DiscRateScen)"
cm_priceSensiBuild    "Price sensitivity of energy carrier choice in buildings"
cm_peakBudgYr       "date of net-zero CO2 emissions for peak budget runs without overshoot"
cm_taxCO2inc_after_peakBudgYr "annual increase of CO2 price after the Peak Budget Year in $ per tCO2"
cm_CO2priceRegConvEndYr      "Year at which regional CO2 prices converge in module 45 realization diffPhaseIn2LinFlex"
c_regi_nucscen				"regions to apply nucscen to"
c_regi_capturescen			"region to apply ccapturescen to"
c_regi_synfuelscen			"region to apply synfuelscen to"
cm_TaxConvCheck             "switch for enabling tax convergence check in nash mode"
c_regi_sensscen				"regions which regional sensitivity parameters apply to"
cm_biotrade_phaseout        "switch for phaseing out biomass trade in the respective regions by 2030"
cm_bioprod_histlim			"regional parameter to limit biomass (pebiolc.1) production to a multiple of the 2015 production"
cm_flex_tax                 "switch for enabling flexibility tax"
cm_H2targets                "switches on capacity targets for electrolysis in NDC techpol following national Hydrogen Strategies"
cm_PriceDurSlope_elh2       "slope of price duration curve of electrolysis"
cm_FlexTaxFeedback          "switch deciding whether flexibility tax feedback on buildlings and industry electricity prices is on"
cm_VRE_supply_assumptions        "default (0), optimistic (1), sombre (2), or bleak (3) assumptions on VRE supply"
cm_build_H2costAddH2Inv     "additional h2 distribution costs for low diffusion levels (default value: 6.5$/ 100 /Kwh)"
cm_build_H2costDecayStart     "simplified logistic function end of full value (ex. 5%  -> between 0 and 5% the function will have the value 1). [%]"
cm_build_H2costDecayEnd     "simplified logistic function start of null value (ex. 10% -> after 10% the function will have the value 0). [%]"
cm_indst_H2costAddH2Inv     "additional h2 distribution costs for low diffusion levels. [3.25$/ 0.1 /kWh]"
cm_indst_costDecayStart     "simplified logistic function end of full value   (ex. 5%  -> between 0 and 5% the simplified logistic function will have the value 1). [%]"
cm_indst_H2costDecayEnd     "simplified logistic function start of null value (ex. 10% -> between 10% and 100% the simplified logistic function will have the value 0). [%]"
cm_BioSupply_Adjust_EU      "factor for scaling sub-EU bioenergy supply curves"
cm_BioImportTax_EU          "factor for EU bioenergy import tax"
cm_import_EU                "EU switch for different scenarios of EU SE import assumptions"
cm_logitCal_markup_conv_b   "value to which logit calibration markup of standard fe2ue technologies in detailed buildings module converges to"
cm_logitCal_markup_newtech_conv_b "value to which logit calibration markup of new fe2ue technologies in detailed buildings module converges to"
cm_demTcomplex              "switch used to select the source of demand trends for the complex transport realization. By default, temporary handmade trajectories; if set to fromEDGET, EDGE-T based mrremind results."
cm_noPeFosCCDeu              "switch to suppress Pe2Se Fossil Carbon Capture in Germany"
cm_HeatLim_b                "switch to set maximum share of district heating in FE buildings"
cm_ElLim_b                  "switch to set maximum share of electricity in FE buildings"
cm_startIter_EDGET          "starting iteration of EDGE-T"
cm_ARIADNE_FeShareBounds    "switch for minimum share of liquids and gases for industry needed for the ARIADNE project"
cm_ariadne_trade_el         "switch for enabling electricity imports to Germany for ARIADNE project"
cm_ariadne_trade_h2         "switch for enabling H2 imports to Germany for ARIADNE project"
cm_ariadne_trade_synliq        "switch for enabling synfuel liquids imports to Germany for ARIADNE project"
cm_ariadne_trade_syngas        "switch for enabling synfuel gases imports to Germany for ARIADNE project"
c_VREPot_Factor             "switch for rescaling renewable potentials in all grades which have not been used by 2020"
cm_FEtax_trajectory_abs     "switch for setting the aboslute FE tax level explicitly from a given year onwards, before tax levels increases or decreases linearly to that value"
cm_FEtax_trajectory_rel     "factor for scaling the FE tax level relative to cm_startyear from a given year onwards, before tax levels increases or decreases linearly to that value"
cm_CESMkup_ind                 "switch for setting markup cost to CES nodes in industry" 
cm_CESMkup_build               "switch for setting markup cost to CES nodes in buildings" 
c_BaselineAgriEmiRed     "switch to lower agricultural base line emissions as fraction of standard assumption, a value of 0.25 will lower emissions by a fourth"
cm_deuCDRmax                 "switch to limit maximum annual CDR amount in Germany in MtCO2 per y"
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
c_shGreenH2      = 0;        !! def = 0
c_shBioTrans     = 1;        !! def = 1
cm_shSynTrans    = 0;        !! def = 0
cm_shSynGas      = 0;        !! def = 0
c_solscen        = 1;        !! def = 1

cm_IndCCSscen          = 1;        !! def = 1
cm_optimisticMAC       = 0;        !! def = 0
cm_CCS_cement          = 1;        !! def = 1
cm_CCS_chemicals       = 1;        !! def = 1
cm_CCS_steel           = 1;        !! def = 1

$setglobal cm_secondary_steel_bound  none   !! def = "scenario"

cm_bioenergy_SustTax    = 1.5;            !! def = 1.5
cm_bioenergy_EF_for_tax = 0;              !! def = 0
$setGlobal cm_regi_bioenergy_EFTax  glob  !! def = glob
cm_bioenergymaxscen     = 0;              !! def = 0
cm_tradecost_bio        = 2;              !! def = 2
$setglobal cm_LU_emi_scen  SSP2           !! def = SSP2
cm_1stgen_phaseout      = 0;              !! def = 0
$setglobal cm_tradbio_phaseout  default   !! def = default
cm_biolc_tech_phaseout  = 0;              !! def = 0

$setglobal cm_POPscen  pop_SSP2EU  !! def = pop_SSP2EU
$setglobal cm_GDPscen  gdp_SSP2EU  !! def = gdp_SSP2EU
$setglobal cm_demScen  gdp_SSP2EU  !! def = gdp_SSP2EU
$setglobal c_GDPpcScen  SSP2EU     !! def = gdp_SSP2   (automatically adjusted by start_run() based on GDPscen) 

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
cm_postTargetIncrease    = 0;      !! def = 0
$setGlobal cm_quantity_regiCO2target  off !! def = off
cm_peakBudgYr            = 2050;   !! def = 2050
cm_taxCO2inc_after_peakBudgYr = 2; !! def = 2
cm_CO2priceRegConvEndYr  = 2050;   !! def = 2050

$setGlobal cm_NucRegiPol	 off   !! def = off		
$setGlobal cm_CoalRegiPol	 off   !! def = off		
$setGlobal cm_proNucRegiPol	 off   !! def = off
$setGlobal cm_CCSRegiPol	 off   !! def = off	
$setGlobal cm_vehiclesSubsidies  off !! def = off
$setGlobal cm_implicitQttyTarget  off !! def = off

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
cm_priceSensiBuild     = -3;
$setGlobal c_scaleEmiHistorical  on  !! def = on
$setGlobal cm_pushCalib  none !! def = none
$setGlobal cm_reducCostB  none !! def = none
$setGlobal cm_effHP  5 !! def = 5

$setGlobal cm_EDGEtr_scen  ConvCase  !! def = ConvCase

$setGlobal c_regi_nucscen  all !! def = all
$setGlobal c_regi_capturescen  all !! def = all
$setGlobal c_regi_synfuelscen  all !! def = all
$setGlobal c_regi_sensscen  all !! def = all



																	  
cm_biotrade_phaseout = 0; !! def 0
cm_bioprod_histlim = -1; !! def -1	

cm_H2targets = 0; !! def 0

*** EU import switches
$setGlobal cm_import_EU  off !! def off

*** buildings services_putty switches
cm_logitCal_markup_conv_b = 0.8; !! def 0.8
cm_logitCal_markup_newtech_conv_b = 0.3; !! def 0.3

*** flex tax switches
cm_flex_tax = 0; !! def 0
cm_PriceDurSlope_elh2 = 20; !! def 10
cm_FlexTaxFeedback = 0; !! def 0

*** VRE switch
cm_VRE_supply_assumptions = 0; !! 0 - default, 1 - optimistic, 2 - sombre, 3 - bleak

*** H2 simple buildings/industry switches
cm_build_H2costAddH2Inv = 0.2;  !! def 6.5$/kg = 0.2 $/Kwh
cm_build_H2costDecayStart = 0.05; !! def 5%
cm_build_H2costDecayEnd = 0.1;  !! def 10%

cm_indst_H2costAddH2Inv = 0.1;  !! def 6.5$/kg = 0.2 $/Kwh
cm_indst_costDecayStart = 0.05; !! def 5%
cm_indst_H2costDecayEnd = 0.1;  !! def 10%

*** EU bioenergy switches
cm_BioSupply_Adjust_EU = 3; !! def 1
cm_BioImportTax_EU = 1; !! def 0.25

$setGlobal cm_demTcomplex  temporary_trend !! def = temporary_trend

cm_noPeFosCCDeu = 0; !! def 0


cm_HeatLim_b = 1; !! def 1
cm_ElLim_b = 1; !! def 1

cm_startIter_EDGET = 14; !! def 14, by default EDGE-T is run first in iteration 14


cm_TaxConvCheck = 0; !! def 0, which means tax convergence check is off


$setGlobal cm_ARIADNE_FeShareBounds  off !! def = off

cm_ariadne_trade_el = 0; !! def 0
cm_ariadne_trade_h2 = 0; !! def 0
cm_ariadne_trade_synliq = 0; !! def 0
cm_ariadne_trade_syngas = 0; !! def 0


$setGlobal c_VREPot_Factor  off !! def = off

$setGlobal cm_FEtax_trajectory_abs  off !! def = off
$setGlobal cm_FEtax_trajectory_rel  off !! def = off

$setGlobal cm_altFeEmiFac  off        !! def = off	


$setGlobal cm_CESMkup_ind  standard !! def = standard
$setGlobal cm_CESMkup_build  standard !! def = standard
c_BaselineAgriEmiRed = 0; !! def = 0

cm_deuCDRmax = -1; !! def = -1

*** --------------------------------------------------------------------------------------------------------------------------------------------------------------------
***                           YOU ARE IN THE WARNING ZONE (DON'T DO CHANGES HERE)
*** --------------------------------------------------------------------------------------------------------------------------------------------------------------------
*--------------------flags------------------------------------------------------------
$SETGLOBAL cm_SlowConvergence  off        !! def = off
$setGlobal cm_nash_mode  parallel      !! def = parallel
$setGLobal cm_debug_preloop  off !! def = off
$setglobal cm_INCONV_PENALTY  on         !! def = on
$setglobal cm_INCONV_PENALTY_bioSwitch  off !! def = off
$setGlobal c_skip_output  off        !! def = off
$setGlobal cm_MOFEX  off        !! def = off
$setGlobal cm_conoptv  conopt3    !! def = conopt3

$setGlobal cm_APscen  SSP2          !! def = SSP2
$setGlobal cm_magicc_calibrateTemperature2000  uncalibrated  !! def=uncalibrated
$setGlobal cm_magicc_config  OLDDEFAULT    !! def = OLDDEFAULT
$setGlobal cm_magicc_temperatureImpulseResponse  off           !! def = off

$setGlobal cm_damage_DiceLike_specification  HowardNonCatastrophic   !! def = HowardNonCatastrophic

$setglobal cm_CES_configuration  stat_off-indu_fixed_shares-buil_simple-tran_complex-POP_pop_SSP2-GDP_gdp_SSP2-Kap_debt_limit-Reg_62eff8f7   !! this will be changed by start_run()

$setglobal c_CES_calibration_new_structure  0    !! def =  0
$setglobal c_CES_calibration_iterations  10    !! def = 10
$setglobal c_CES_calibration_write_prices  0    !! def =  0
$setglobal cm_CES_calibration_default_prices  0    !! def = 0
$setglobal cm_calibration_string  off      !! def = off

$setglobal c_testOneRegi_region  EUR       !! def = EUR

$setglobal cm_techcosts  REG       !! def = REG
$setglobal cm_regNetNegCO2  on       !! def = on

$setglobal cm_calibration_FE  off      !! def = off

$setglobal cm_eni  off!! def = off
$setglobal cm_enb  off!! def = off

$setglobal cm_LDV_mkt_share  off !! def = off

$setglobal cm_incolearn  off !! def = off
$setglobal cm_storageFactor  off !! def = off

$setglobal cm_adj_seed  off
$setglobal cm_adj_seed_cont  off
$setglobal cm_adj_coeff  off
$setglobal cm_adj_coeff_cont  off

$setglobal cm_adj_seed_multiplier  off
$setglobal cm_adj_coeff_multiplier  off

$setglobal cm_inco0Factor  off !! def = off
$setglobal cm_inco0RegiFactor  off !! def = off

$setglobal cm_CCS_markup  off !! def = off
$setglobal cm_Industry_CCS_markup  off !! def = off
$setglobal cm_renewables_floor_cost  off !! def = off 

$setglobal cm_DAC_eff  off !! def = off 

$setglobal cm_sehe_upper  off !! def = off 

$setglobal cm_fixCO2price  off !! def = off

$setglobal cm_feShareLimits  off  !! def = off

$setglobal c_fuelprice_init  off !! def = off
$setglobal cm_seTradeScenario  off  !! def = off

$setglobal cm_wind_offshore  0      !! def = 0
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

* set log file
file logfile /""/;

*--------------------------------------------------------------------------
***          SETS
*--------------------------------------------------------------------------
$include    "./core/sets.gms";
$batinclude "./modules/include.gms"    sets
$include    "./core/sets_calculations.gms";

*--------------------------------------------------------------------------
***          DECLARATION     of equations, variables, parameters and scalars
*--------------------------------------------------------------------------
$include    "./core/declarations.gms";
$batinclude "./modules/include.gms"    declarations

*--------------------------------------------------------------------------
***          DATAINPUT
*--------------------------------------------------------------------------
$include    "./core/datainput.gms";
$include    "./modules/24_trade/capacity/datainput.gms";

*--------------------------------------------------------------------------
***          EQUATIONS
*--------------------------------------------------------------------------
$include    "./core/equations.gms";
$include    "./modules/24_trade/capacity/equations.gms";

*--------------------------------------------------------------------------
***          solveoptions
*--------------------------------------------------------------------------
option profile   = 0;
option limcol    = 100;
option limrow    = 100;
option savepoint = 0;
option reslim    = 1.e+6;
option iterlim   = 1.e+6;
option solprint  = on;

*--------------------------------------------------------------------------
***          PRELOOP
*--------------------------------------------------------------------------
pm_SEPrice(ttot,all_regi,all_enty) = 0.0;
pm_PEPrice(ttot,all_regi,all_enty) = 0.0;
$include "./modules/24_trade/capacity/preloop.gms"

*--------------------------------------------------------------------------
***          LOAD INPUT GDX
*--------------------------------------------------------------------------
PARAMETER p_PEPrice(ttot,all_regi,all_enty);

execute_loadpoint 'input.gdx' vm_Mport;
execute_loadpoint 'input.gdx' vm_Xport;
execute_loadpoint 'input.gdx' p_PEPrice;

pm_PEPrice(ttot,all_regi,all_enty) = p_PEPrice(ttot,all_regi,all_enty);

*--------------------------------------------------------------------------
***          SOLVE TRADE MODEL IN 24_TRADE PRESOLVE
*--------------------------------------------------------------------------
$include "./modules/24_trade/capacity/presolve.gms"

*---------------------------------------------------------------------------
***                  save gdx
*---------------------------------------------------------------------------
execute_unload 'fulldata';
