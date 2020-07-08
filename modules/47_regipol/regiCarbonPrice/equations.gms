*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regiPol/regiCarbonPrice/equations.gms

***$ifThen.regicarbonprice not "%cm_regiCO2target%" == "off"
*** FS: calculate emissions used in regional target
*** net CO2 
q47_emiTarget_netCO2(ttot, regi)$(ttot.val ge 2005)..
	v47_emiTarget(ttot,regi,"netCO2")
	=e=
	vm_emiAll(ttot,regi,"co2")
;

*** gross Fossil Fuel and Industry co2 emissions: net energy co2 + cement co2 + BECCS
q47_emiTarget_grossFFaI(ttot, regi)$(ttot.val ge 2005)..
	v47_emiTarget(ttot,regi,"grossFFaI")
	=e=
	  vm_emiTe(ttot,regi,"co2") 
	+ vm_emiMacSector(ttot,regi,"co2cement_process")
	+ sum( (enty,enty2,te)$(pe2se(enty,enty2,te) AND teBio(te)), vm_emiTeDetail(ttot,regi,enty,enty2,te,"cco2"))
;

*** net GHG
q47_emiTarget_netGHG(ttot, regi)$(ttot.val ge 2005)..
	v47_emiTarget(ttot,regi,"netGHG")
	=e=
	vm_co2eq(ttot,regi)
;

***$endIf.regicarbonprice

*** net CO2 per Mkt 
q47_emiTarget_mkt_netCO2(ttot, regi, emiMkt)$(ttot.val ge 2005)..
	v47_emiTargetMkt(ttot,regi,emiMkt,"netCO2")
	=e=
	vm_emiAllMkt(ttot,regi,"co2",emiMkt)
;

*** net GHG per Mkt
q47_emiTarget_mkt_netGHG(ttot, regi, emiMkt)$(ttot.val ge 2005)..
	v47_emiTargetMkt(ttot,regi,emiMkt,"netGHG")
	=e=
	vm_co2eqMkt(ttot,regi,emiMkt)
;


$ifThen.quantity_regiCO2target not "%cm_quantity_regiCO2target%" == "off"

q47_quantity_regiCO2target(ttot,ext_regi,emi_type)$p47_quantity_regiCO2target(ttot,ext_regi,emi_type)..
	sum(regi$regi_group(ext_regi,regi),
		v47_emiTarget(ttot,regi,emi_type) 
	)
	=l=
	p47_quantity_regiCO2target(ttot,ext_regi,emi_type)
;

$endIf.quantity_regiCO2target

*** EOF ./modules/47_regiPol/regiCarbonPrice/equations.gms
