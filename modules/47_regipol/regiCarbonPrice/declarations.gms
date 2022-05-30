*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCarbonPrice/declarations.gms

	
Parameter
  s47_prefreeYear                               "value of the last non-free year for the carbon price trajectory"
  p47_LULUCFEmi_GrassiShift(ttot,all_regi)		"difference between Magpie land-use change emissions and UNFCCC emissions in 2015 to correct for national accounting in emissions targets"
  pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt) "deviation of emissions of current iteration from target emissions, for budget target this is the difference normalized by target emissions, while for year targets this is the difference normalized by 2005 emissions [%]"
;

$ifThen.emiMkt not "%cm_emiMktTarget%" == "off" 
Parameter
  p47_taxemiMkt_init(ttot,all_regi,emiMkt)  "emiMkt CO2eq prices loaded from ref gdx, in T$/GtC = $/kgC. To get $/tCO2, multiply with 272 [T$/GtC]"
  p47_taxCO2eq_ref(ttot,all_regi)           "CO2eq prices loaded from ref gdx, in T$/GtC = $/kgC. To get $/tCO2, multiply with 272 [T$/GtC]"
  pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type,emi_type) "region emissions target [GtCO2 or GtCO2eq]" / %cm_emiMktTarget% /
  pm_emiMktCurrent(ttot,ttot2,ext_regi,emiMktExt)    "previous iteration region emissions (from year ttot to ttot2 for budget) [GtCO2 or GtCO2eq]"
  pm_emiMktCurrent_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) "parameter to save pm_emiMktCurrent across iterations  [GtCO2 or GtCO2eq]"
  pm_emiMktRefYear(ttot,ttot2,ext_regi,emiMktExt)    "emissions in reference year 2015, used for calculating target deviation of year targets [GtCO2 or GtCO2eq]"
  pm_emiMktTarget_dev_iter(iteration, ttot,ttot2,ext_regi,emiMktExt) "parameter to save pm_emiMktTarget_dev across iterations [%]"
  pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt) "multiplicative tax rescale factor that rescales emiMkt carbon price from iteration to iteration to reach regipol targets [%]"
  pm_factorRescaleemiMktCO2Tax_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) "parameter to save rescale factor across iterations for debugginh purposes [%]"

  pm_factorRescaleSlope(ttot,ttot2,ext_regi,emiMktExt)
  pm_factorRescaleIntersect(ttot,ttot2,ext_regi,emiMktExt)
;

$ifThen.prioRescaleFactor not "%cm_prioRescaleFactor%" == "off" 
Parameter
  s47_prioRescaleFactor   "factor to prioritize short term targets in the initial iterations (and vice versa latter) [0..1]" / %cm_prioRescaleFactor% /
  s47_2030taxemiMktConv   "boolean to store information if all targets set for years equal or lower than 2030 converged [0 or 1]" /0/
  s47_up2030taxemiMktConv "boolean to store information if all targets set for years above 2030 converged [0 or 1]" /0/
; 
$endIf.prioRescaleFactor
 
$endIf.emiMkt

$ifThen.regiExoPrice not "%cm_regiExoPrice%" == "off"
Parameter
  p47_exoCo2tax(ext_regi,ttot)   "Exogenous CO2 tax level. Overrides carbon prices in pm_taxCO2eq, only if explicitly defined. Regions and region groups allowed. Format: '<regigroup>.<year> <value>, <regigroup>.<year2> <value2>' or '<regigroup>.(<year1> <value>,<year2> <value>'). [$/tCO2]" / %cm_regiExoPrice% /
;
$endIf.regiExoPrice

*** It does not need to be a variable (and equations) because is only dealt in between iterations!!!!
variables
	v47_emiTarget(ttot,all_regi,emi_type)      "CO2 or GHG Emissions used for target level [GtC]"
	v47_emiTargetMkt(ttot,all_regi,emiMktExt,emi_type) "CO2 or GHG Emissions per emission market used for target level [GtC]"
;

equations
	q47_emiTarget_grossEnCO2(ttot, all_regi)	   "Calculates gross energy-related co2 emissions [GtC]"
*	q47_emiTarget_netCO2(ttot, all_regi)	       "Calculates net co2 emissions used for target [GtC]"
*	q47_emiTarget_netCO2_noBunkers(ttot, all_regi) "Calculates net CO2 emissions excluding bunkers used for target [GtC]"
*	q47_emiTarget_netCO2_noLULUCF_noBunkers(ttot, all_regi) "Calculates net CO2 emissions excluding bunkers and LULUCF (=ESR+ETS) [GtC]"
*	q47_emiTarget_netGHG(ttot, all_regi)		   "Calculates net GHG emissions used for target [GtC]"
*	q47_emiTarget_netGHG_noBunkers(ttot, all_regi) "Calculates net GHG emissions excluding bunkers used for target [GtC]"
*	q47_emiTarget_netGHG_noLULUCF_noBunkers(ttot, all_regi) "Calculates net GHG emissions excluding bunkers and LULUCF (=ESR+ETS) [GtC]"
*	q47_emiTarget_netGHG_LULUCFGrassi_noBunkers(ttot, all_regi) "Calculates net GHG emissions excluding bunkers and shifting LULUCF emissions to meet 2015 UNFCCC values"
	
	q47_emiTarget_mkt_netCO2(ttot, all_regi, emiMktExt)                    "Calculates net CO2 emissions per emission market used for target [GtC]"
	q47_emiTarget_mkt_netCO2_noBunkers(ttot, all_regi, emiMktExt)          "Calculates net CO2 emissions per emission market  excluding bunkers used for target [GtC]"
	q47_emiTarget_mkt_netCO2_noLULUCF_noBunkers(ttot, all_regi, emiMktExt) "Calculates net CO2 emissions per emission market  excluding bunkers and LULUCF (=ESR+ETS) [GtC]"

	q47_emiTarget_mkt_netGHG(ttot, all_regi, emiMktExt)                    "Calculates net GHG emissions per emission market used for target [GtC]"
	q47_emiTarget_mkt_netGHG_noBunkers(ttot, all_regi, emiMktExt)          "Calculates net GHG emissions per emission market  excluding bunkers used for target [GtC]"
	q47_emiTarget_mkt_netGHG_noLULUCF_noBunkers(ttot, all_regi, emiMktExt) "Calculates net GHG emissions per emission market  excluding bunkers and LULUCF (=ESR+ETS) [GtC]"
	q47_emiTarget_mkt_netGHG_LULUCFGrassi_noBunkers(ttot, all_regi, emiMktExt) "Calculates net GHG emissions per emission market  excluding bunkers and shifting LULUCF emissions to meet 2015 UNFCCC values"
;

$ifThen.emiMktETS not "%cm_emiMktETS%" == "off" 
Parameter
  pm_regiCO2ETStarget(ttot,target_type,emi_type) "ETS emissions target [GtCO2]" / %cm_emiMktETS% /
  pm_ETSTarget_dev(ETS_mkt)				    "ETS emissions deviation of current iteration from target emissions [%]"
  pm_ETSTarget_dev_iter(iteration, ETS_mkt)  "parameter to save pm_ETSTarget_dev across iterations [%]"
	
;
$endIf.emiMktETS    

Parameter
    pm_emissionsRefYearETS(ETS_mkt)	        "ETS emissions in reference year 2005, used for calculating target deviation of year targets [GtCO2]"
***	p47_emiTargetETS(ttot,ETS_mkt)				"ETS emission target (GtCO2-eq)"
	pm_emiCurrentETS(ETS_mkt)					"previous iteration ETS CO2 equivalent emissions [GtCO2]"
	pm_emiRescaleCo2TaxETS(ETS_mkt)			"ETS CO2 equivalent price re-scale update factor in between iterations [%]"
    pm_emissionsRefYearESR(ttot,all_regi)	    "ESR emissions in reference year 2005, used for calculating target deviation of year targets [GtCO2]"
	pm_emiTargetESR(ttot,all_regi)      		    "CO2 or GHG Effort Sharing emissions target per region [GtC]"
	pm_emiRescaleCo2TaxESR(ttot,all_regi)		"Effort Sharing CO2 equivalent (or CO2) price re-scale update factor in between iterations [%]"
	pm_ESRTarget_dev(ttot,all_regi)				"ESR emissions deviation of current iteration from target emissions [GtC]"
	pm_ESRTarget_dev_iter(iteration,ttot,all_regi) "parameter to save pm_ESRTarget_dev across iterations [GtC]"
;

*** Emission reduction quantity target
$ifThen.quantity_regiCO2target not "%cm_quantity_regiCO2target%" == "off"
Parameter
	p47_quantity_regiCO2target(ttot,ext_regi,emi_type) "Exogenously emissions quantity constrain [GtCO2]" / %cm_quantity_regiCO2target% /
;
equations
	q47_quantity_regiCO2target(ttot,ext_regi,emi_type) "Exogenously emissions quantity constrain [GtC]"
;
$endIf.quantity_regiCO2target    

*** RR this should be replaced as soon as non-energy is treated endoegenously in the model
Parameter
	p47_nonEnergyUse(ttot,ext_regi)                  "non-energy use: EUR in 2030 =~ 90Mtoe (90 * 10^6 toe -> 90 * 10^6 toe * 41.868 GJ/toe -> 3768.12 * 10^6 GJ * 10^-9 EJ/GJ -> 3.76812 EJ * 1 TWa/31.536 EJ -> 0.1194863 TWa) EU27 =~ 92% EU28" / 2030.EUR_regi 0.1194863, 2030.EU27_regi 0.11 /
;
*** Efficiency final energy target induced by implicit tax
$ifthen.cm_implicitFE not "%cm_implicitFE%" == "off"
Parameter

	p47_implFETax(ttot,all_regi,all_enty)            "tax/subsidy level on FE"
	p47_implFETargetCurrent(ext_regi)                "current iteration total final energy"
	p47_implFETax_Rescale(ext_regi)                  "rescale factor for current implicit FE tax" 
	p47_implFETax_prevIter(ttot,all_regi,all_enty)   "previous iteration implicit final energy target tax"
	p47_implFETax0(ttot,all_regi)					 "previous iteration implicit final energy target tax revenue"

	p47_implFETax_iter(iteration,ttot,all_regi,all_enty) "final energy implicit tax per iteration"
	p47_implFETax_Rescale_iter(iteration,ext_regi)   "final energy implicit tax rescale factor per iteration"    
	p47_implFETargetCurrent_iter(iteration,ext_regi) "total final energy level per iteration"    
;

$ifthen.implicitFEtarget "%cm_implicitFE%" == "FEtarget"
Parameter
	p47_implFETarget(ttot,ext_regi)                  "final energy target [TWa]"  		  / %cm_implFETarget% /
	p47_implFETarget_extended(ttot,ext_regi)         "final energy target with added bunkers and non-energy use [TWa]" 
;
$endIf.implicitFEtarget

$IFTHEN.exoTax "%cm_implFEExoTax%" == "off"
***	default p47_implFEExoTax value
Parameter
	p47_implFEExoTax(ttot,ext_regi,FEtarget_sector)  "final energy exogneous tax [$/GJ]" / 
		2025.EUR_regi.stat   1, 2030.EUR_regi.stat   2, 2035.EUR_regi.stat   3, 2040.EUR_regi.stat   4, 2045.EUR_regi.stat   5,  2050.EUR_regi.stat   7,
		2025.EUR_regi.trans 20, 2030.EUR_regi.trans 40, 2035.EUR_regi.trans 60, 2040.EUR_regi.trans 80, 2045.EUR_regi.trans 100,  2050.EUR_regi.trans 120 
	/
;
$else.exoTax
***	p47_implFEExoTax defined by switch cm_implFEExoTax
Parameter
	p47_implFEExoTax(ttot,ext_regi,FEtarget_sector)  "final energy exogenous tax [$/GJ]" / %cm_implFEExoTax% /
;
$ENDIF.exoTax

equations
	q47_implFETax(ttot,all_regi)      "implicit final energy tax to represent non CO2-price-driven final energy policies"
;
$endIf.cm_implicitFE

*** Implicit tax/subsidy necessary to achieve primary, secondary and/or final energy targets per specific energy type
$ifthen.cm_implicitEnergyBound not "%cm_implicitEnergyBound%" == "off"
Parameter
	p47_implEnergyBoundTax(ttot,all_regi,energyCarrierLevel,energyType)           "tax/subsidy level on PE, SE and/or FE for an specific energy type"
  	p47_implEnergyBoundCurrent(ttot,ext_regi,energyCarrierLevel,energyType) "current iteration total PE, SE and/or FE for an specific energy type"
  	p47_implEnergyBoundTax_Rescale(ttot,ext_regi,energyCarrierLevel,energyType)   "rescale factor for current implicit energy bound tax" 
	p47_implEnergyBoundTax_prevIter(ttot,all_regi,energyCarrierLevel,energyType)  "previous iteration implicit energy bound target tax"
	p47_implEnergyBoundTax0(ttot,all_regi)                                        "previous iteration implicit energy bound target tax revenue"

	p47_implEnergyBoundTax_iter(iteration,ttot,all_regi,energyCarrierLevel,energyType)           "energy bound implicit tax per iteration"
	p47_implEnergyBoundTarget_dev(ttot,ext_regi,energyCarrierLevel,energyType)                   "energy bound implicit tax deviation of current iteration from target"
	p47_implEnergyBoundTarget_dev_iter(iteration,ttot,ext_regi,energyCarrierLevel,energyType)    "parameter to save p47_implEnergyBoundTarget_dev across iterations"
	p47_implEnergyBoundTax_Rescale_iter(iteration,ttot,ext_regi,energyCarrierLevel,energyType)   "energy bound implicit tax rescale factor per iteration"    
	p47_implEnergyBoundCurrent_iter(iteration,ttot,ext_regi,energyCarrierLevel,energyType) "total PE, SE and/or FE level for an specific energy type per iteration"   

	p47_implEnergyBoundTarget(ttot,ext_regi,taxType,targetType,energyCarrierLevel,energyType)           "Energy bound target [absolute: TWa; or percentage: 0.1]"  / %cm_implicitEnergyBound% /

	pm_implEnergyBoundLimited(iteration,energyCarrierLevel,energyType)  "1 (one) if there is a hard bound on the model that does not allow the tax to change further the energy usage"
;

Equations
	q47_implEnergyBoundTax(ttot,all_regi)  "implicit energy bound tax (PE, SE and/or FE for an specific energy type) to represent non CO2-price-driven policies"
;
$endIf.cm_implicitEnergyBound


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
*** Auxiliar parameters:
***---------------------------------------------------------------------------
*** parameters to track regipol emissions calculation
Parameters
p47_emiTarget_grossEnCO2_noBunkers_iter(iteration,ttot,all_regi)	"parameter to save value of gross energy emissions target over iterations to check whether values converge"
;

*** EOF ./modules/47_regipol/regiCarbonPrice/declarations.gms
