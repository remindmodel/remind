*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCarbonPrice/declarations.gms

***---------------------------------------------------------------------------
*** Auxiliar parameters:
***---------------------------------------------------------------------------

Parameter
  s47_firstFreeYear                                  "value of first free year for the carbon price trajectory"
  s47_prefreeYear                                    "value of the last non-free year for the carbon price trajectory"
  p47_LULUCFEmi_GrassiShift(ttot,all_regi)           "difference between Magpie land-use change emissions and UNFCCC emissions in 2015 to correct for national accounting in emissions targets"
  pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt) "deviation of emissions of current iteration from target emissions, for budget target this is the difference normalized by target emissions, while for year targets this is the difference normalized by 2005 emissions [%]"

*** RR this should be replaced as soon as non-energy is treated endogenously in the model
  p47_nonEnergyUse(ttot,ext_regi)                  "non-energy use"
;

*** parameters to track regipol emissions calculation
Parameters
  p47_emiTargetMkt(ttot,all_regi,emiMktExt,emi_type_47)            "CO2 or GHG Emissions per emission market used for target level [GtC]"
  p47_emiTarget_grossEnCO2_noBunkers_iter(iteration,ttot,all_regi) "parameter to save value of gross energy emissions target over iterations to check whether values converge"
;

***--------------------------------------------------
*** Emission markets (EU Emission trading system and Effort Sharing)
***--------------------------------------------------
$ifThen.emiMkt not "%cm_emiMktTarget%" == "off" 
Parameter
  pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47) "region emissions target [GtCO2 or GtCO2eq]" / %cm_emiMktTarget% /

*** Initialization parameters (load data from the gdx)
  p47_taxemiMkt_init(ttot,all_regi,emiMkt)  "emiMkt CO2eq prices loaded from ref gdx, in T$/GtC = $/kgC. To get $/tCO2, multiply with 272 [T$/GtC]"
  p47_taxCO2eq_ref(ttot,all_regi)           "CO2eq prices loaded from ref gdx, in T$/GtC = $/kgC. To get $/tCO2, multiply with 272 [T$/GtC]"

*** Parameters necessary to calculate current emission target deviations
  pm_emiMktCurrent(ttot,ttot2,ext_regi,emiMktExt)    "previous iteration region emissions (from year ttot to ttot2 for budget) [GtCO2 or GtCO2eq]"
  p47_emiMktCurrent_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) "parameter to save pm_emiMktCurrent across iterations  [GtCO2 or GtCO2eq]"
  pm_emiMktRefYear(ttot,ttot2,ext_regi,emiMktExt)    "emissions in reference year 2015, used for calculating target deviation of year targets [GtCO2 or GtCO2eq]"
  pm_emiMktTarget_dev_iter(iteration, ttot,ttot2,ext_regi,emiMktExt) "parameter to save pm_emiMktTarget_dev across iterations [%]"

*** Parameters necessary to calculate the emission tax rescaling factor
  p47_factorRescaleSlope(ttot,ttot2,ext_regi,emiMktExt)     "auxiliar parameter to save the slope corresponding to the observed mitigation derivative regarding to co2tax level changes from the two previous iterations [#]"
  p47_factorRescaleSlope_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) "parameter to save mitigation curve slope across iterations [#]"
  pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt) "multiplicative tax rescale factor that rescales emiMkt carbon price from iteration to iteration to reach regipol targets [%]"
  p47_factorRescaleemiMktCO2Tax_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) "parameter to save rescale factor across iterations for debugging purposes [%]"

*** Parameters necessary to define the CO2 tax curve shape   
  p47_targetConverged(ttot,ext_regi)                 "boolean to store if emission target has converged [0 or 1]"
  p47_targetConverged_iter(iteration,ttot,ext_regi)  "parameter to save p47_targetConverged across iterations [0 or 1]"
  p47_allTargetsConverged(ext_regi)                  "boolean to store if all emission targets converged at least once [0 or 1]"
  p47_allTargetsConverged_iter(iteration,ext_regi)   "parameter to save p47_allTargetsConverged across iterations [0 or 1]"
  p47_firstTargetYear(ext_regi)                      "first year with a pre defined policy emission target in the region [year]"
  p47_lastTargetYear(ext_regi)                       "last year with a pre defined policy emission target in the region [year]"
  p47_currentConvergencePeriod(ext_regi)             "auxiliar parameter to store the current target year being executed by the convergence algorithm [year]"
  p47_nextConvergencePeriod(ext_regi)                "auxiliar parameter to store the next target year being executed by the convergence algorithm [year]"
  p47_averagetaxemiMkt(ttot,all_regi)                "auxiliar parameter to store the weighted average convergence price between the current target terminal year and the next target year. Only applied for target years different than p47_lastTargetYear"

*** output parameters
  p47_taxemiMkt_AggEmi(ttot,all_regi)                "CO2eq regional aggregated emission tax (aggregated by emissions)"
  p47_taxCO2eq_AggEmi(ttot,all_regi)                 "CO2eq global and regional aggregated emission taxes (aggregated by emissions)"
  p47_taxemiMkt_AggFE(ttot,all_regi)                 "CO2eq regional aggregated emission tax (aggregated by final energy)"
  p47_taxCO2eq_AggFE(ttot,all_regi)                  "CO2eq global and regional aggregated emission taxes (aggregated by final energy)"
  p47_taxemiMkt_SectorAggFE(ttot,all_regi,sector)    "CO2eq regional aggregated sectoral emission tax (aggregated by final energy)"
  p47_taxCO2eq_SectorAggFE(ttot,all_regi,sector)     "CO2eq global and regional aggregated sectoral emission taxes (aggregated by final energy)"
;
 
$endIf.emiMkt

***---------------------------------------------------------------------------
*** Implicit tax/subsidy necessary to achieve quantity target for primary, secondary, final energy and/or CCS
***---------------------------------------------------------------------------
$ifthen.cm_implicitQttyTarget not "%cm_implicitQttyTarget%" == "off"
Parameter
  p47_implicitQttyTargetTax(ttot,all_regi,qttyTarget,qttyTargetGroup)          "tax/subsidy level necessary to achieve a quantity target"
  p47_implicitQttyTargetCurrent(ttot,ext_regi,qttyTarget,qttyTargetGroup)      "current iteration total value for an specific quantity target"
  p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup)  "rescale factor for current implicit quantity target tax" 
  p47_implicitQttyTargetTax_prevIter(ttot,all_regi,qttyTarget,qttyTargetGroup) "previous iteration quantity target tax"
  p47_implicitQttyTargetTax0(ttot,all_regi)                                    "previous iteration quantity target tax revenue"

  p47_implicitQttyTargetTax_iter(iteration,ttot,all_regi,qttyTarget,qttyTargetGroup)        "tax/subsidy level necessary to achieve a quantity target per iteration"
  pm_implicitQttyTarget_dev(ttot,ext_regi,qttyTarget,qttyTargetGroup)                 "deviation of current iteration quantity target from target"
  p47_implicitQttyTarget_dev_iter(iteration,ttot,ext_regi,qttyTarget,qttyTargetGroup) "parameter to save pm_implicitQttyTarget_dev across iterations"
  p47_implicitQttyTargetTaxRescale_iter(iteration,ttot,ext_regi,qttyTarget,qttyTargetGroup) "rescale factor for current implicit quantity target tax per iteration"    
  p47_implicitQttyTargetCurrent_iter(iteration,ttot,ext_regi,qttyTarget,qttyTargetGroup)    "current iteration total value for an specific quantity target per iteration"   

  pm_implicitQttyTarget(ttot,ext_regi,taxType,targetType,qttyTarget,qttyTargetGroup)  "quantity target [absolute: TWa or GtC; or percentage: 0.1]"  / %cm_implicitQttyTarget% /

  pm_implicitQttyTarget_isLimited(iteration,qttyTarget,qttyTargetGroup)  "1 (one) if there is a hard bound on the model that does not allow the tax to change further the quantity"

  p47_implicitQttyTarget_initialYear(ext_regi,taxType,targetType,qttyTarget,qttyTargetGroup) "initial year of quantity target for a given region [year]"
;

Equations
  q47_implicitQttyTargetTax(ttot,all_regi)  "implicit quantity target tax (PE, SE, FE and/or FE CCS) to represent non CO2-price-driven policies or exogenously defined quantity constraint scenarios"
;
$endIf.cm_implicitQttyTarget

***---------------------------------------------------------------------------
*** implicit tax/subsidy necessary to final energy price targets
***---------------------------------------------------------------------------
$ifthen.cm_implicitPriceTarget not "%cm_implicitPriceTarget%" == "off"
Parameter
  pm_implicitPriceTarget(ttot,all_regi,all_enty,entySe,sector) "price target for FE carrier per sector [2005 TerraDollar per TWyear]"
  p47_implicitPriceTax(ttot,all_regi,all_enty,entySe,sector)   "tax/subsidy level on FE for reaching the price target [2005 TerraDollar per TWyear]"
  p47_implicitPriceTax0(ttot,all_regi,all_enty,entySe,sector)  "previous iteration implicit price target tax revenue  [2005 TerraDollar]"
  p47_implicitPrice_dev(ttot,all_regi,all_enty,entySe,sector)   "implicit price tax deviation of current iteration from target [%]"
  p47_implicitPrice_dev_iter(iteration,ttot,all_regi,all_enty,entySe,sector) "implicit price tax deviation of current iteration from target per iteration [%]"
  pm_implicitPrice_NotConv(all_regi,sector,all_enty,entySe,ttot) "auxiliary parameter to store the price targets that did not converged [%]" 
  pm_implicitPrice_ignConv(all_regi,sector,all_enty,entySe,ttot) "auxiliary parameter to store the price targets that were ignored in the convergence check (cases: 1 = non existent price, 2 = no change in prices for the last 3 iterations) [#]" 
  p47_implicitPriceTax_iter(iteration,ttot,all_regi,all_enty,entySe,sector)  "tax/subsidy level on FE for reaching the price target per iteration [2005 TerraDollar per TWyear]"
  p47_implicitPriceTarget_terminalYear(all_regi,all_enty,entySe,sector) "terminal year of price target for given region and energy carrier [year]"
  p47_implicitPriceTarget_initialYear(all_regi,all_enty,entySe,sector) "initial year of price target for given region and energy carrier [year]"
;

Equations
  q47_implicitPriceTax(ttot,all_regi,all_enty,entySe,sector)  "implicit tax/subsidy FE tax to reach target energy sector sectoral price"
;
$endIf.cm_implicitPriceTarget


***---------------------------------------------------------------------------
*** implicit tax/subsidy necessary to primary energy price targets
***---------------------------------------------------------------------------
$ifthen.cm_implicitPePriceTarget not "%cm_implicitPePriceTarget%" == "off"
Parameter
  pm_implicitPePriceTarget(ttot,all_regi,all_enty) "price target for PE carrier per sector [2005 TerraDollar per TWyear]"
  p47_implicitPePriceTax(ttot,all_regi,all_enty)   "tax/subsidy level on PE for reaching the price target [2005 TerraDollar per TWyear]"
  p47_implicitPePriceTax0(ttot,all_regi,all_enty)  "previous iteration implicit price target tax revenue  [2005 TerraDollar]"
  p47_implicitPePrice_dev(ttot,all_regi,all_enty)   "implicit price tax deviation of current iteration from target [%]"
  p47_implicitPePrice_dev_iter(iteration,ttot,all_regi,all_enty) "implicit price tax deviation of current iteration from target per iteration [%]"
  pm_implicitPePrice_NotConv(all_regi,all_enty,ttot) "auxiliary parameter to store the price targets that did not converged [%]" 
  pm_implicitPePrice_ignConv(all_regi,all_enty,ttot) "auxiliary parameter to store the price targets that were ignored in the convergence check (cases: 1 = non existent price, 2 = no change in prices for the last 3 iterations) [#]" 
  p47_implicitPePriceTax_iter(iteration,ttot,all_regi,all_enty)  "tax/subsidy level on PE for reaching the price target per iteration [2005 TerraDollar per TWyear]"
  p47_implicitPePriceTarget_terminalYear(all_regi,all_enty) "terminal year of price target for given region and energy carrier [year]"
  p47_implicitPePriceTarget_initialYear(all_regi,all_enty) "initial year of price target for given region and energy carrier [year]"
;

Equations
  q47_implicitPePriceTax(ttot,all_regi,all_enty)  "implicit tax/subsidy PE tax to reach target energy sector sectoral price"
;
$endIf.cm_implicitPePriceTarget

***---------------------------------------------------------------------------
*'  Emission quantity target
***---------------------------------------------------------------------------
$ifThen.quantity_regiCO2target not "%cm_quantity_regiCO2target%" == "off"
Parameter
  p47_quantity_regiCO2target(ttot,ext_regi) "Exogenously emissions quantity constrain on net CO2 without bunkers [GtCO2]" / %cm_quantity_regiCO2target% /
;
equations
  q47_quantity_regiCO2target(ttot,ext_regi) "Exogenously emissions quantity constrain on net CO2 without bunkers [GtC]"
;
$endIf.quantity_regiCO2target   

***---------------------------------------------------------------------------
*** per region minimun variable renewables share in electricity:
***---------------------------------------------------------------------------
$ifthen.cm_VREminShare not "%cm_VREminShare%" == "off"
Variable
  v47_VREshare(ttot,all_regi) "share of variable renewables (wind and solar) in electricity"
;
Parameter
  p47_VREminShare(ttot,ext_regi) "per region minimun share of variable renewables (wind and solar) in electricity. Applied to yaers greater or equal to ttot. Unit [0..1]" / %cm_VREminShare% /  
;
Equation
  q47_VREShare(ttot,all_regi) "per region minimun share of variable renewables (wind and solar) from ttot year onward"
;
$endIf.cm_VREminShare

***---------------------------------------------------------------------------
*** per region maximum CCS:
***---------------------------------------------------------------------------
$ifthen.cm_CCSmaxBound not "%cm_CCSmaxBound%" == "off"
Parameter
  p47_CCSmaxBound(all_regi) "per region yearly maximum CCS. Unit[Gt C]" / %cm_CCSmaxBound% /  
;
p47_CCSmaxBound(regi) = p47_CCSmaxBound(regi) / sm_c_2_co2;
Equation
  q47_CCSmaxBound(ttot,all_regi) "per region yearly maximum CCS"
;
$endIf.cm_CCSmaxBound

***---------------------------------------------------------------------------
*** Exogenous CO2 tax level:
***---------------------------------------------------------------------------
$ifThen.regiExoPrice not "%cm_regiExoPrice%" == "off"
Parameter
  p47_exoCo2tax(ext_regi,ttot)   "Exogenous CO2 tax level. Overrides carbon prices in pm_taxCO2eq, only if explicitly defined. Regions and region groups allowed. Format: '<regigroup>.<year> <value>, <regigroup>.<year2> <value2>' or '<regigroup>.(<year1> <value>,<year2> <value>'). [$/tCO2]" / %cm_regiExoPrice% /
;
$endIf.regiExoPrice


*** EOF ./modules/47_regipol/regiCarbonPrice/declarations.gms
