*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCarbonPrice/equations.gms

$ontext
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

q47_emiTarget_netCO2_noLULUCF_noBunkers(t, regi)..
	v47_emiTarget(t,regi,"netCO2_noLULUCF_noBunkers")
	=e=
	sum(emiMkt$(sameas(emiMkt,"ETS") OR sameas(emiMkt,"ES")),
		vm_emiAllMkt(t,regi,"co2",emiMkt)
	)
;

$offtext

*** FS: gross energy CO2 emissions (excl. BECCS and bunkers)
*** note: industry BECCS is still missing from this variable, to be added in the future
q47_emiTarget_grossEnCO2(t,regi)..
	v47_emiTarget(t,regi,"grossEnCO2_noBunkers")
	=e=
*** total net CO2 energy CO2 (w/o DAC accounting of synfuels) 
	vm_emiTe(t,regi,"co2")
*** DAC accounting of synfuels: remove CO2 of vm_emiCDR (which is negative) from vm_emiTe which is not stored in vm_co2CCS
	+  vm_emiCdr(t,regi,"co2") * (1-pm_share_CCS_CCO2(t,regi))
*** add pe2se BECCS
	+  sum(emi2te(enty,enty2,te,enty3)$(teBio(te) AND teCCS(te) AND sameAs(enty3,"cco2")), vm_emiTeDetail(t,regi,enty,enty2,te,enty3)) * pm_share_CCS_CCO2(t,regi)
*** add industry CCS with hydrocarbon fuels from biomass (industry BECCS) or synthetic origin 
	+  sum( (entySe,entyFe,secInd37,emiMkt)$(NOT (entySeFos(entySe))),
		pm_IndstCO2Captured(t,regi,entySe,entyFe,secInd37,emiMkt)) * pm_share_CCS_CCO2(t,regi)
*** remove bunker emissions
	-  sum(se2fe(enty,enty2,te), pm_emifac(t,regi,enty,enty2,te,"co2") * vm_demFeSector(t,regi,enty,enty2,"trans","other"))
;


$ontext
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

q47_emiTarget_netGHG_noLULUCF_noBunkers(t, regi)..
	v47_emiTarget(t,regi,"netGHG_noLULUCF_noBunkers")
	=e=
	sum(emiMkt$(sameas(emiMkt,"ETS") OR sameas(emiMkt,"ES")),
		vm_co2eqMkt(t,regi,emiMkt)
	)
;


q47_emiTarget_netGHG_LULUCFGrassi_noBunkers(t, regi)..
	v47_emiTarget(t,regi,"netGHG_LULUCFGrassi_noBunkers")
	=e=
	vm_co2eq(t,regi)
	- 	sum(se2fe(enty,enty2,te),
		(pm_emifac(t,regi,enty,enty2,te,"co2")
		+ pm_emifac(t,regi,enty,enty2,te,"n2o")*sm_tgn_2_pgc
		+ pm_emifac(t,regi,enty,enty2,te,"ch4")*sm_tgch4_2_pgc)
		 * vm_demFeSector(t,regi,enty,enty2,"trans","other"))
	- p47_LULUCFEmi_GrassiShift(t,regi)
;

***$endIf.regicarbonprice
$offtext

*** net CO2 per Mkt 
q47_emiTarget_mkt_netCO2(t, regi, emiMktExt)..
	v47_emiTargetMkt(t,regi,emiMktExt,"netCO2")
	=e=
	sum(emiMkt$emiMktGroup(emiMktExt,emiMkt), vm_emiAllMkt(t,regi,"co2",emiMkt) )
;

*** net CO2 per Mkt without bunkers 
q47_emiTarget_mkt_netCO2_noBunkers(t, regi, emiMktExt)..
	v47_emiTargetMkt(t,regi,emiMktExt,"netCO2_noBunkers")
	=e=
	sum(emiMkt$emiMktGroup(emiMktExt,emiMkt), vm_emiAllMkt(t,regi,"co2",emiMkt) )
	- (
		sum(se2fe(enty,enty2,te),
			pm_emifac(t,regi,enty,enty2,te,"co2")
			* vm_demFeSector(t,regi,enty,enty2,"trans","other")
			)
	)$(sameas(emiMktExt,"other") or sameas(emiMktExt,"all"))
;

*** net GHG per Mkt without bunkers and without LULUCF
q47_emiTarget_mkt_netCO2_noLULUCF_noBunkers(t, regi, emiMktExt)..
	v47_emiTargetMkt(t,regi, emiMktExt,"netCO2_noLULUCF_noBunkers")
	=e=
	sum(emiMkt$(emiMktGroup(emiMktExt,emiMkt) and (sameas(emiMkt,"ETS") or sameas(emiMkt,"ES"))), vm_emiAllMkt(t,regi,"co2",emiMkt) )
;

*** net GHG per Mkt
q47_emiTarget_mkt_netGHG(t, regi, emiMktExt)..
	v47_emiTargetMkt(t,regi,emiMktExt,"netGHG")
	=e=
	sum(emiMkt$emiMktGroup(emiMktExt,emiMkt),vm_co2eqMkt(t,regi,emiMkt) )
;

*** net GHG per Mkt without bunkers
q47_emiTarget_mkt_netGHG_noBunkers(t, regi, emiMktExt)..
	v47_emiTargetMkt(t,regi, emiMktExt,"netGHG_noBunkers")
	=e=
	sum(emiMkt$emiMktGroup(emiMktExt,emiMkt),vm_co2eqMkt(t,regi,emiMkt) )
	- (
		sum(se2fe(enty,enty2,te),
		(pm_emifac(t,regi,enty,enty2,te,"co2")
		+ pm_emifac(t,regi,enty,enty2,te,"n2o")*sm_tgn_2_pgc
		+ pm_emifac(t,regi,enty,enty2,te,"ch4")*sm_tgch4_2_pgc)
		 * vm_demFeSector(t,regi,enty,enty2,"trans","other")) 
	)$(sameas(emiMktExt,"other") or sameas(emiMktExt,"all"))
;

*** net GHG per Mkt without bunkers and without LULUCF
q47_emiTarget_mkt_netGHG_noLULUCF_noBunkers(t, regi, emiMktExt)..
	v47_emiTargetMkt(t,regi, emiMktExt,"netGHG_noLULUCF_noBunkers")
	=e=
	sum(emiMkt$(emiMktGroup(emiMktExt,emiMkt) and (sameas(emiMkt,"ETS") or sameas(emiMkt,"ES"))),vm_co2eqMkt(t,regi,emiMkt) )
;

*** net GHG per Mkt without bunkers and without Grassi LULUCF
q47_emiTarget_mkt_netGHG_LULUCFGrassi_noBunkers(t, regi, emiMktExt)..
	v47_emiTargetMkt(t,regi, emiMktExt,"netGHG_LULUCFGrassi_noBunkers")
	=e=
	sum(emiMkt$emiMktGroup(emiMktExt,emiMkt),vm_co2eqMkt(t,regi,emiMkt) )
	- (
	    sum(se2fe(enty,enty2,te),
			(pm_emifac(t,regi,enty,enty2,te,"co2")
			+ pm_emifac(t,regi,enty,enty2,te,"n2o")*sm_tgn_2_pgc
			+ pm_emifac(t,regi,enty,enty2,te,"ch4")*sm_tgch4_2_pgc)
			* vm_demFeSector(t,regi,enty,enty2,"trans","other")
		) 
		- p47_LULUCFEmi_GrassiShift(t,regi)
	)$(sameas(emiMktExt,"other") or sameas(emiMktExt,"all"))
;


*** 


$ifThen.quantity_regiCO2target not "%cm_quantity_regiCO2target%" == "off"

q47_quantity_regiCO2target(t,ext_regi,emi_type_47)$p47_quantity_regiCO2target(t,ext_regi,emi_type_47)..
	sum(regi$regi_group(ext_regi,regi),
		v47_emiTarget(t,regi,emi_type_47) 
	)
	=l=
	p47_quantity_regiCO2target(t,ext_regi,emi_type_47)/sm_c_2_co2
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

***---------------------------------------------------------------------------
*'  Calculation of implicit tax/subsidy necessary to achieve primary, secondary and/or final energy targets
***---------------------------------------------------------------------------
$ifthen.cm_implicitEnergyBound not "%cm_implicitEnergyBound%" == "off"

q47_implEnergyBoundTax(t,regi)$(t.val ge max(2010,cm_startyear))..
  vm_taxrevimplEnergyBoundTax(t,regi)
  =e=
  sum((energyCarrierLevel,energyType)$p47_implEnergyBoundTax(t,regi,energyCarrierLevel,energyType),
	( 
		p47_implEnergyBoundTax(t,regi,energyCarrierLevel,energyType) * sum(entyPe$energyCarrierANDtype2enty(energyCarrierLevel,energyType,entyPe), sum(pe2se(entyPe,entySe,te), vm_demPe(t,regi,entyPe,entySe,te))) 
	)$(sameas(energyCarrierLevel,"PE")) 
	+
	( 
		p47_implEnergyBoundTax(t,regi,energyCarrierLevel,energyType) * sum(entySe$energyCarrierANDtype2enty(energyCarrierLevel,energyType,entySe), sum(se2fe(entySe,entyFe,te), vm_demSe(t,regi,entySe,entyFe,te))) 
	)$(sameas(energyCarrierLevel,"SE")) 
	+
	( 
		p47_implEnergyBoundTax(t,regi,energyCarrierLevel,energyType) * sum(entySe$energyCarrierANDtype2enty("FE",energyType,entySe), sum(se2fe(entySe,entyFe,te), sum((sector,emiMkt)$(entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)), vm_demFeSector(t,regi,entySe,entyFe,sector,emiMkt)))) 
	)$(sameas(energyCarrierLevel,"FE") or sameas(energyCarrierLevel,"FE_wo_b") or sameas(energyCarrierLevel,"FE_wo_n_e") or sameas(energyCarrierLevel,"FE_wo_b_wo_n_e"))
  ) 
  -
  p47_implEnergyBoundTax0(t,regi)
;

$endIf.cm_implicitEnergyBound

***---------------------------------------------------------------------------
*** per region minimun variable renewables share in electricity:
***---------------------------------------------------------------------------
$ifthen.cm_VREminShare not "%cm_VREminShare%" == "off"

q47_VREShare(ttot,regi)..
  v47_VREshare(ttot,regi)
  =g=
  sum(teVRE, v32_shSeEl(ttot,regi,teVRE))
;

$endIf.cm_VREminShare

*** EOF ./modules/47_regiPol/regiCarbonPrice/equations.gms
