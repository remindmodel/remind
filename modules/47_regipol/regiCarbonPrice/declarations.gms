*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCarbonPrice/declarations.gms

	
Parameter
	p47_taxCO2eqBeforeStartYear(ttot,all_regi) "CO2eq prices before start year"
	p47_emissionsCurrent(ext_regi)		"previous iteration region GHG emissions [GtCO2]"
	p47_factorRescaleCO2Tax(ext_regi)	"tax rescale factor"
;

$ifThen.regicarbonprice not "%cm_regiCO2target%" == "off" 
Parameter
	p47_regiCO2target(ttot,ext_regi,target_type,emi_type) "region GHG emissions target [GtCO2]" / %cm_regiCO2target% /
;  
$endIf.regicarbonprice

*** It does not need to be a variable (and equations) because is only dealt in between iterations!!!!
variables
	v47_emiTarget(ttot,all_regi,emi_type)      "Emissions used for target level"
;

equations
	q47_emiTarget_grossFFaI(ttot, all_regi)		"Calculates gross co2 emissions from fossil fuels and industry used for target"
	q47_emiTarget_netCO2(ttot, all_regi)	    "Calculates net co2 emissions used for target"
	q47_emiTarget_netGHG(ttot, all_regi)		"Calculates net GHG emissions used for target"
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
	p47_emiTargetES(tall,all_regi)      		"Effort Sharing GtCO2-eq (or GtCO2) emissions target per region"
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

*** EOF ./modules/47_regipol/regiCarbonPrice/declarations.gms
