*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCarbonPrice/presolve.gms

*** difference between 2020 land-use change emissions from Magpie and UNFCCC 2015 and 2020 moving average land-use change emissions
p47_LULUCFEmi_GrassiShift(ttot,regi)$(p47_EmiLULUCFCountryAcc("2020",regi)) =
  pm_macBaseMagpie("2020",regi,"co2luc")
  -
  (
    (
      ((p47_EmiLULUCFCountryAcc("2013",regi) + p47_EmiLULUCFCountryAcc("2014",regi) + p47_EmiLULUCFCountryAcc("2015",regi) + p47_EmiLULUCFCountryAcc("2016",regi) + p47_EmiLULUCFCountryAcc("2017",regi))/5)
      +
      ((p47_EmiLULUCFCountryAcc("2018",regi) + p47_EmiLULUCFCountryAcc("2019",regi) + p47_EmiLULUCFCountryAcc("2020",regi) + p47_EmiLULUCFCountryAcc("2021",regi))/4)
    )/2
    * 1e-3/sm_c_2_co2
  )
;

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
      pm_taxCO2eqSCC(t,regi) = 0;

      pm_taxrevGHG0(t,regi) = 0;
      pm_taxrevCO2Sector0(t,regi,emi_sectors) = 0;
      pm_taxrevCO2LUC0(t,regi) = 0;
      pm_taxrevNetNegEmi0(t,regi) = 0;
    );
  );
$ENDIF.emiMkt

***---------------------------------------------------------------------------
*** Calculation of implicit tax/subsidy necessary to achieve quantity target for primary, secondary, final energy and/or CCS
***---------------------------------------------------------------------------

$ifthen.cm_implicitQttyTarget not "%cm_implicitQttyTarget%" == "off"

*** saving value for implicit tax revenue recycling
*** the same line exists in postsolve.gms, don't forget to update there
p47_implicitQttyTargetTax0(t,regi) =
  sum((qttyTarget,qttyTargetGroup)$p47_implicitQttyTargetTax(t,regi,qttyTarget,qttyTargetGroup),
    p47_implicitQttyTargetTax(t,regi,qttyTarget,qttyTargetGroup) * (
      ( sum(entyPe$energyQttyTargetANDGroup2enty(qttyTarget,qttyTargetGroup,entyPe), sum(pe2se(entyPe,entySe,te), vm_demPe.l(t,regi,entyPe,entySe,te)))
      )$(sameas(qttyTarget,"PE"))
      +
      ( sum(entySe$energyQttyTargetANDGroup2enty(qttyTarget,qttyTargetGroup,entySe), sum(se2fe(entySe,entyFe,te), vm_demSe.l(t,regi,entySe,entyFe,te)))
      )$(sameas(qttyTarget,"SE"))
      +
      ( sum(entySe$energyQttyTargetANDGroup2enty("FE",qttyTargetGroup,entySe), sum(se2fe(entySe,entyFe,te), sum((sector,emiMkt)$(entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)), vm_demFeSector.l(t,regi,entySe,entyFe,sector,emiMkt))))
      )$(sameas(qttyTarget,"FE") or sameas(qttyTarget,"FE_wo_b") or sameas(qttyTarget,"FE_wo_n_e") or sameas(qttyTarget,"FE_wo_b_wo_n_e"))
      +
      ( sum(ccs2te(ccsCo2(enty),enty2,te), sum(teCCS2rlf(te,rlf),vm_co2CCS.l(t,regi,enty,enty2,te,rlf)))
      )$(sameas(qttyTarget,"CCS") AND sameas(qttyTargetGroup,"all"))
      +
      ( sum(te_oae33, -vm_emiCdrTeDetail.l(t,regi,te_oae33))
      )$(sameas(qttyTarget,"oae") AND sameas(qttyTargetGroup,"all"))
      +
      (( !! Supply side BECCS
        sum(emiBECCS2te(enty,enty2,te,enty3),vm_emiTeDetail.l(t,regi,enty,enty2,te,enty3))
        !! Industry BECCS (using biofuels in Industry with CCS)
      + sum((emiMkt,entySe,secInd37,entyFe)$entySeBio(entySe), pm_IndstCO2Captured(t,regi,entySe,entyFe,secInd37,emiMkt))
      ) * pm_share_CCS_CCO2(t,regi) )$(sameas(qttyTarget,"CCS") AND sameas(qttyTargetGroup,"biomass"))
    )
  )
;

$endIf.cm_implicitQttyTarget


***---------------------------------------------------------------------------
*** Calculation of implicit tax/subsidy necessary to final energy price targets
***---------------------------------------------------------------------------

$ifthen.cm_implicitPriceTarget not "%cm_implicitPriceTarget%" == "off"

*** saving value for implicit tax revenue recycling
  p47_implicitPriceTax0(t,regi,entyFe,entySe,sector) = p47_implicitPriceTax(t,regi,entyFe,entySe,sector) * sum(emiMkt$sector2emiMkt(sector,emiMkt), vm_demFeSector.l(t,regi,entySe,entyFe,sector,emiMkt));

$endIf.cm_implicitPriceTarget


***---------------------------------------------------------------------------
*** Calculation of implicit tax/subsidy necessary to primary energy price targets
***---------------------------------------------------------------------------

$ifthen.cm_implicitPePriceTarget not "%cm_implicitPePriceTarget%" == "off"

*** saving value for implicit tax revenue recycling
  p47_implicitPePriceTax0(t,regi,entyPe) = p47_implicitPePriceTax(t,regi,entyPe) * vm_prodPe.l(t,regi,entyPe);

$endIf.cm_implicitPePriceTarget


*** EOF ./modules/47_regipol/regiCarbonPrice/presolve.gms

