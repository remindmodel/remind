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
q47_emiTarget_netCO2(t, regi)..
	v47_emiTarget(t,regi,"netCO2")
	=e=
	vm_emiAll(t,regi,"co2")
;

q47_emiTarget_netCO2_noBunkers(t, regi)..
	v47_emiTarget(t,regi,"netCO2_noBunkers")
	=e=
	vm_emiAll(t,regi,"co2")
	- sum(se2fe(enty,enty2,te),
		pm_emifac(t,regi,enty,enty2,te,"co2")
		* vm_demFeSector(t,regi,enty,enty2,"trans","other"))
;

*** FS: gross energy CO2 emissions (excl. BECCS and bunkers)
*** note: industry BECCS is still missing from this variable, to be added in the future
q47_emiTarget_grossEnCO2(t,regi)..
	v47_emiTarget(t,regi,"grossEnCO2_noBunkers")
	=e=
*** total net CO2 energy CO2 (w/o DAC accounting of synfuels) - DAC accounting of synfuels - captured bio CO2 * CCS share of captured CO2 - bunkers
	vm_emiTe(t,regi,"co2")
*** DAC accounting of synfuels: remove CO2 of vm_emiCDR (which is negative) from vm_emiTe which is not stored in vm_co2CCS
	+  vm_emiCdr(t,regi,"co2") * (1-pm_share_CCS_CCO2(t,regi))
	+  sum(emi2te(enty,enty2,te,enty3)$(teBio(te) AND teCCS(te) AND sameAs(enty3,"cco2")), vm_emiTeDetail(t,regi,enty,enty2,te,enty3)) * pm_share_CCS_CCO2(t,regi)
	-  sum(se2fe(enty,enty2,te), pm_emifac(t,regi,enty,enty2,te,"co2") * vm_demFeSector(t,regi,enty,enty2,"trans","other"))
;

*** net GHG
q47_emiTarget_netGHG(t, regi)..
	v47_emiTarget(t,regi,"netGHG")
	=e=
	vm_co2eq(t,regi)
;

q47_emiTarget_netGHG_noBunkers(t, regi)..
	v47_emiTarget(t,regi,"netGHG_noBunkers")
	=e=
	vm_co2eq(t,regi)
	- 	sum(se2fe(enty,enty2,te),
		(pm_emifac(t,regi,enty,enty2,te,"co2")
		+ pm_emifac(t,regi,enty,enty2,te,"n2o")*sm_tgn_2_pgc
		+ pm_emifac(t,regi,enty,enty2,te,"ch4")*sm_tgch4_2_pgc)
		 * vm_demFeSector(t,regi,enty,enty2,"trans","other"))
;

***$endIf.regicarbonprice

*** net CO2 per Mkt 
q47_emiTarget_mkt_netCO2(t, regi, emiMkt)..
	v47_emiTargetMkt(t,regi,emiMkt,"netCO2")
	=e=
	vm_emiAllMkt(t,regi,"co2",emiMkt)
;

*** net GHG per Mkt
q47_emiTarget_mkt_netGHG(t, regi, emiMkt)..
	v47_emiTargetMkt(t,regi,emiMkt,"netGHG")
	=e=
	vm_co2eqMkt(t,regi,emiMkt)
;


$ifThen.quantity_regiCO2target not "%cm_quantity_regiCO2target%" == "off"

q47_quantity_regiCO2target(t,ext_regi,emi_type)$p47_quantity_regiCO2target(t,ext_regi,emi_type)..
	sum(regi$regi_group(ext_regi,regi),
		v47_emiTarget(t,regi,emi_type) 
	)
	=l=
	p47_quantity_regiCO2target(t,ext_regi,emi_type)
;

$endIf.quantity_regiCO2target


***---------------------------------------------------------------------------
*'  Calculation of tax/subsidy to reflect non carbon pricing driven efficency measures applied to reduce total final energy to comply with efficiency directive targets
***---------------------------------------------------------------------------
$ifthen.cm_implicitFE not "%cm_implicitFE%" == "off"

q47_implFETax(t,regi)$(t.val ge max(2010,cm_startyear))..
  vm_taxrevimplFETax(t,regi)
  =e=
  sum(enty2$entyFE(enty2),
  	p47_implFETax(t,regi,enty2) * sum(se2fe(enty,enty2,te), vm_prodFe(t,regi,enty,enty2,te))
  )
  - p47_implFETax0(t,regi) 
  ;

$endIf.cm_implicitFE

*** EOF ./modules/47_regiPol/regiCarbonPrice/equations.gms
