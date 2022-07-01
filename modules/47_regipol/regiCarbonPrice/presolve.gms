*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCarbonPrice/presolve.gms

***--------------------------------------------------
*** Emission markets (EU Emission trading system and Effort Sharing)
***--------------------------------------------------

*** Removing economy wide co2 tax parameters for regions within the emiMKt controlled targets
$IFTHEN.emiMkt not "%cm_emiMktTarget%" == "off" 
  loop((ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47)$pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47),
    loop(regi$regi_groupExt(ext_regi,regi),
*** Removing the economy wide co2 tax parameters for regions within the ETS markets
      pm_taxCO2eqSum(t,regi) = 0;
      pm_taxCO2eq(t,regi) = 0;
      pm_taxCO2eqRegi(t,regi) = 0;
      pm_taxCO2eqHist(t,regi) = 0;
      pm_taxCO2eqSCC(t,regi) = 0;

      pm_taxrevGHG0(t,regi) = 0;
      pm_taxrevCO2Sector0(t,regi,emi_sectors) = 0;
      pm_taxrevCO2LUC0(t,regi) = 0;
      pm_taxrevNetNegEmi0(t,regi) = 0;
    );
  );
$ENDIF.emiMkt

***---------------------------------------------------------------------------
*** Calculation of implicit tax/subsidy necessary to achieve primary, secondary and/or final energy targets
***---------------------------------------------------------------------------

$ifthen.cm_implicitEnergyBound not "%cm_implicitEnergyBound%" == "off"

*** saving value for implicit tax revenue recycling
  p47_implEnergyBoundTax0(t,regi) = 
    sum((energyCarrierLevel,energyType)$p47_implEnergyBoundTax(t,regi,energyCarrierLevel,energyType),
    ( p47_implEnergyBoundTax(t,regi,"PE",energyType) * sum(entyPe$energyCarrierANDtype2enty("PE",energyType,entyPe), sum(pe2se(entyPe,entySe,te), vm_demPe.l(t,regi,entyPe,entySe,te))) 
    )$(sameas(energyCarrierLevel,"PE")) 
    +
    ( p47_implEnergyBoundTax(t,regi,"SE",energyType) * sum(entySe$energyCarrierANDtype2enty("SE",energyType,entySe), sum(se2fe(entySe,entyFe,te), vm_demSe.l(t,regi,entySe,entyFe,te))) 
    )$(sameas(energyCarrierLevel,"SE")) 
    +
    ( p47_implEnergyBoundTax(t,regi,energyCarrierLevel,energyType) * sum(entySe$energyCarrierANDtype2enty("FE",energyType,entySe), sum(se2fe(entySe,entyFe,te), sum((sector,emiMkt)$(entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)), vm_demFeSector.l(t,regi,entySe,entyFe,sector,emiMkt)))) 
    )$(sameas(energyCarrierLevel,"FE") or sameas(energyCarrierLevel,"FE_wo_b") or sameas(energyCarrierLevel,"FE_wo_n_e") or sameas(energyCarrierLevel,"FE_wo_b_wo_n_e"))
  )
  ;

$endIf.cm_implicitEnergyBound


***---------------------------------------------------------------------------
*** Calculation of implicit tax/subsidy necessary to final energy price targets
***---------------------------------------------------------------------------

$ifthen.cm_implicitPriceTarget not "%cm_implicitPriceTarget%" == "off"

*** saving value for implicit tax revenue recycling
  p47_implicitPriceTax0(t,regi,entyFe,entySe,sector) = p47_implicitPriceTax(t,regi,entyFe,entySe,sector) * sum(emiMkt$sector2emiMkt(sector,emiMkt), vm_demFeSector.l(t,regi,entySe,entyFe,sector,emiMkt));

$endIf.cm_implicitPriceTarget


*** EOF ./modules/47_regipol/regiCarbonPrice/presolve.gms

