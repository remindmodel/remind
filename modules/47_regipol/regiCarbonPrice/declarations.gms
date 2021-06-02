*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCarbonPrice/declarations.gms

	
Parameter
  pm_regiTarget_dev(ext_regi,ttot,ttot2)       "target deviation across iterations in current emissions divided by target emissions"
  p47_regiTarget_dev_iter(iteration,ext_regi,ttot,ttot2)  "parameter to save pm_regiTarget_dev across iterations"
  p47_taxCO2eqBeforeStartYear(ttot,all_regi)   "CO2eq prices before start year"
  p47_emissionsCurrent(ext_regi,ttot,ttot2)	   "previous iteration region GHG emissions (from year ttot to ttot2 for budget) [GtCO2]"
  p47_factorRescaleCO2Tax(ext_regi,ttot,ttot2) "multiplicative tax rescale factor that rescales carbon price from iteration to iteration to reach regipol targets"
;

$ifThen.regicarbonprice not "%cm_regiCO2target%" == "off" 
Parameter
	p47_regiCO2target(ttot,ttot2,ext_regi,target_type,emi_type) "region GHG emissions target [GtCO2]" / %cm_regiCO2target% /
;  
$endIf.regicarbonprice

*** It does not need to be a variable (and equations) because is only dealt in between iterations!!!!
variables
	v47_emiTarget(ttot,all_regi,emi_type)      "Emissions used for target level"
;

equations
	q47_emiTarget_grossEnCO2(ttot, all_regi)		"Calculates gross energy-related co2 emissions"
	q47_emiTarget_netCO2(ttot, all_regi)	    "Calculates net co2 emissions used for target"
	q47_emiTarget_netCO2_noBunkers(ttot, all_regi) "Calculates net CO2 emissions excluding bunkers used for target"
	q47_emiTarget_netGHG(ttot, all_regi)		"Calculates net GHG emissions used for target"
	q47_emiTarget_netGHG_noBunkers(ttot, all_regi) "Calculates net GHG emissions excluding bunkers used for target"
;

$ifThen.emiMktETS not "%cm_emiMktETS%" == "off" 
Parameter
	p47_taxemiMktBeforeStartYear(ttot,all_regi,all_emiMkt) "CO2eq mkt prices before start year"
	p47_regiCO2ETStarget(ttot,target_type,emi_type) "ETS emissions target [GtCO2]" / %cm_emiMktETS% /
;
$endIf.emiMktETS    

Parameter
***	p47_emiTargetETS(ttot,ETS_mkt)				"ETS emission target (GtCO2-eq)"
	p47_emiCurrentETS(ETS_mkt)					"previous iteration ETS CO2 equivalent emissions"
	p47_emiRescaleCo2TaxETS(ETS_mkt)			"ETS CO2 equivalent price re-scale update factor in between iterations"
	pm_emiTargetES(tall,all_regi)      		"Effort Sharing GtCO2-eq (or GtCO2) emissions target per region"
	p47_emiRescaleCo2TaxES(ttot,all_regi)		"Effort Sharing CO2 equivalent (or CO2) price re-scale update factor in between iterations"
;

variables
	v47_emiTargetMkt(ttot,all_regi,all_emiMkt,emi_type) "Emissions per emission market used for target level"
;

equations
	q47_emiTarget_mkt_netCO2(ttot, all_regi, all_emiMkt) "Calculates net CO2 emissions per emission market used for target"
	q47_emiTarget_mkt_netGHG(ttot, all_regi, all_emiMkt) "Calculates net GHG emissions per emission market used for target"
;


$ifThen.quantity_regiCO2target not "%cm_quantity_regiCO2target%" == "off"
Parameter
	p47_quantity_regiCO2target(ttot,ext_regi,emi_type) "Exogenously emissions quantity constrain" / %cm_quantity_regiCO2target% /
;
equations
	q47_quantity_regiCO2target(ttot,ext_regi,emi_type) "Exogenously emissions quantity constrain"
;
$endIf.quantity_regiCO2target    



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
	p47_nonEnergyUse(ttot,ext_regi)                  "non-energy use: EUR in 2030 =~ 90Mtoe (90 * 10^6 toe -> 90 * 10^6 toe * 41.868 GJ/toe -> 3768.12 * 10^6 GJ * 10^-9 EJ/GJ -> 3.76812 EJ * 1 TWa/31.536 EJ -> 0.1194863 TWa)" / 2030.EUR_regi 0.1194863 /
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
	p47_implFEExoTax(ttot,ext_regi,FEtarget_sector)  "final energy exogneous tax [$/GJ]" / %cm_implFEExoTax% /
;
$ENDIF.exoTax

equations
	q47_implFETax(ttot,all_regi)      "implicit final energy tax to represent non CO2-price-driven final energy policies"
;
$endIf.cm_implicitFE

*** EOF ./modules/47_regipol/regiCarbonPrice/declarations.gms
