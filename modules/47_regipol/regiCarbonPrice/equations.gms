*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCarbonPrice/equations.gms

***---------------------------------------------------------------------------
*'  Implicit tax/subsidy necessary to achieve quantity target for primary, secondary, final energy and/or CCS
***---------------------------------------------------------------------------
$ifthen.cm_implicitQttyTarget not "%cm_implicitQttyTarget%" == "off"

q47_implicitQttyTargetTax(t,regi)$(t.val ge max(2010,cm_startyear))..
  vm_taxrevimplicitQttyTargetTax(t,regi)
  =e=
  sum((qttyTarget,qttyTargetGroup)$p47_implicitQttyTargetTax(t,regi,qttyTarget,qttyTargetGroup),
    ( 
      p47_implicitQttyTargetTax(t,regi,qttyTarget,qttyTargetGroup) * sum(entyPe$energyQttyTargetANDGroup2enty(qttyTarget,qttyTargetGroup,entyPe), sum(pe2se(entyPe,entySe,te), vm_demPe(t,regi,entyPe,entySe,te))) 
    )$(sameas(qttyTarget,"PE")) 
    +
    ( 
      p47_implicitQttyTargetTax(t,regi,qttyTarget,qttyTargetGroup) * sum(entySe$energyQttyTargetANDGroup2enty(qttyTarget,qttyTargetGroup,entySe), sum(se2fe(entySe,entyFe,te), vm_demSe(t,regi,entySe,entyFe,te))) 
    )$(sameas(qttyTarget,"SE")) 
    +
    ( 
      p47_implicitQttyTargetTax(t,regi,qttyTarget,qttyTargetGroup) * sum(entySe$energyQttyTargetANDGroup2enty("FE",qttyTargetGroup,entySe), sum(se2fe(entySe,entyFe,te), sum((sector,emiMkt)$(entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)), vm_demFeSector(t,regi,entySe,entyFe,sector,emiMkt)))) 
    )$(sameas(qttyTarget,"FE") or sameas(qttyTarget,"FE_wo_b") or sameas(qttyTarget,"FE_wo_n_e") or sameas(qttyTarget,"FE_wo_b_wo_n_e"))
    +
    ( 
      p47_implicitQttyTargetTax(t,regi,qttyTarget,qttyTargetGroup) * sum(ccs2te(ccsCO2(enty),enty2,te), sum(teCCS2rlf(te,rlf),vm_co2CCS(t,regi,enty,enty2,te,rlf)))
    )$(sameas(qttyTarget,"CCS"))  
  )
  -
  p47_implicitQttyTargetTax0(t,regi)
;

$endIf.cm_implicitQttyTarget

***---------------------------------------------------------------------------
*** implicit tax/subsidy necessary to final energy price targets
***---------------------------------------------------------------------------

$ifthen.cm_implicitPriceTarget not "%cm_implicitPriceTarget%" == "off"

q47_implicitPriceTax(t,regi,entyFe,entySe,sector)$((t.val ge max(2010,cm_startyear)) and (entyFe2Sector(entyFe,sector)))..
  vm_taxrevimplicitPriceTax(t,regi,entySe,entyFe,sector)
  =e=
  (
    p47_implicitPriceTax(t,regi,entyFe,entySe,sector) * sum(emiMkt$sector2emiMkt(sector,emiMkt), vm_demFeSector(t,regi,entySe,entyFe,sector,emiMkt))
  )
  -
  p47_implicitPriceTax0(t,regi,entyFe,entySe,sector)
;

$endIf.cm_implicitPriceTarget

***---------------------------------------------------------------------------
*** implicit tax/subsidy necessary to primary energy price targets
***---------------------------------------------------------------------------

$ifthen.cm_implicitPePriceTarget not "%cm_implicitPePriceTarget%" == "off"

q47_implicitPePriceTax(t,regi,entyPe)$(t.val ge max(2010,cm_startyear))..
  vm_taxrevimplicitPePriceTax(t,regi,entyPe)
  =e=
  (
    p47_implicitPePriceTax(t,regi,entyPe) * vm_prodPe(t,regi,entyPe)
  )
  -
  p47_implicitPePriceTax0(t,regi,entyPe)
;

$endIf.cm_implicitPePriceTarget

***---------------------------------------------------------------------------
*'  Emission quantity target
***---------------------------------------------------------------------------

$ifThen.quantity_regiCO2target not "%cm_quantity_regiCO2target%" == "off"

q47_quantity_regiCO2target(t,ext_regi)$p47_quantity_regiCO2target(t,ext_regi)..
*** net CO2 without bunkers 
  sum(emiMkt,
	  sum(emiMkt$emiMktGroup(emiMktExt,emiMkt), vm_emiAllMkt(t,regi,"co2",emiMkt) )
	- (
		sum(se2fe(enty,enty2,te),
		pm_emifac(t,regi,enty,enty2,te,"co2")
		* vm_demFeSector(t,regi,enty,enty2,"trans","other")
		)
	)$(sameas(emiMktExt,"other") or sameas(emiMktExt,"all"))
  )
  =l=
  p47_quantity_regiCO2target(t,ext_regi)/sm_c_2_co2
;

$endIf.quantity_regiCO2target


***---------------------------------------------------------------------------
*** per region minimum variable renewables share in electricity:
***---------------------------------------------------------------------------
$ifthen.cm_VREminShare not "%cm_VREminShare%" == "off"

q47_VREShare(ttot,regi)..
  v47_VREshare(ttot,regi)
  =g=
  sum(teVRE, vm_shSeEl(ttot,regi,teVRE))
;

$endIf.cm_VREminShare

***---------------------------------------------------------------------------
*** per region maximum CCS:
***---------------------------------------------------------------------------
$ifthen.cm_CCSmaxBound not "%cm_CCSmaxBound%" == "off"

q47_CCSmaxBound(t,regi)$p47_CCSmaxBound(regi)..
  sum(ccs2te(ccsCO2(enty),enty2,te), sum(teCCS2rlf(te,rlf),vm_co2CCS(t,regi,enty,enty2,te,rlf)))
  =l=
  p47_CCSmaxBound(regi)
;

$endIf.cm_CCSmaxBound


*** EOF ./modules/47_regipol/regiCarbonPrice/equations.gms
