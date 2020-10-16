*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCarbonPrice/declarations.gms

Parameter
	p47_emissionsCurrent(ext_regi)		"previous iteration region GHG emissions [GtCO2]"
	p47_factorRescaleCO2Tax(ext_regi)	"tax rescale factor"
;

$ifThen.regicarbonprice not "%cm_regiCO2target%" == "off" 
Parameter
	p47_regiCO2target(ttot,ext_regi,target_type,emi_type) "region GHG emissions target [GtCO2]" / %cm_regiCO2target% /
    p47_emiTarget(ttot, all_regi,emi_type)		"Emissions used for target level"
;

$endIf.regicarbonprice

*** EOF ./modules/47_regipol/regiCarbonPrice/declarations.gms
