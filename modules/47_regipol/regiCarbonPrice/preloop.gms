*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCarbonPrice/preloop.gms

***--------------------------------------------------
*** Emission markets (EU Emission trading system and Effort Sharing)
***--------------------------------------------------

*** Initialize tax path
pm_taxemiMkt(t,regi,emiMkt)$(t.val ge cm_startyear) = 0;

$IFTHEN.emiMkt not "%cm_emiMktTarget%" == "off" 
*** Initializing emi market historical and reference prices
  loop((ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47)$(pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47)),
    loop(regi$regi_groupExt(ext_regi,regi),
      loop(emiMkt$emiMktGroup(emiMktExt,emiMkt), 
        pm_taxemiMkt(ttot3,regi,emiMkt) = p47_taxemiMkt_init(ttot3,regi,emiMkt);
      );
    );
  );
$ENDIF.emiMkt

***---------------------------------------------------------------------------
*** Calculation of implicit tax/subsidy necessary to achieve quantity target for primary, secondary, final energy and/or CCS
***---------------------------------------------------------------------------

$ifthen.cm_implicitQttyTarget not "%cm_implicitQttyTarget%" == "off"
*** initialize tax value for the first iteration
  p47_implicitQttyTargetTax(t,all_regi,qttyTarget,qttyTargetGroup) = 0;

*** load tax from gdx
$ifthen.loadFromGDX_implicitQttyTargetTax not "%cm_loadFromGDX_implicitQttyTargetTax%" == "off"
Execute_Loadpoint 'input_ref' p47_implicitQttyTargetTax = p47_implicitQttyTargetTax;
*** disable tax values for inexistent targets
  loop((ttot,ext_regi,taxType,targetType,qttyTarget,qttyTargetGroup)$(NOT (pm_implicitQttyTarget(ttot,ext_regi,taxType,targetType,qttyTarget,qttyTargetGroup))),
    loop(all_regi$regi_groupExt(ext_regi,all_regi),
      p47_implicitQttyTargetTax(t,all_regi,qttyTarget,qttyTargetGroup) = 0;
    );
  );
$endif.loadFromGDX_implicitQttyTargetTax

*** initialize values if not loaded from gdx
loop((ttot,ext_regi,taxType,targetType,qttyTarget,qttyTargetGroup)$pm_implicitQttyTarget(ttot,ext_regi,taxType,targetType,qttyTarget,qttyTargetGroup),
  loop(all_regi$regi_groupExt(ext_regi,all_regi),
    if(sameas(taxType,"tax"),
      p47_implicitQttyTargetTax(t,all_regi,qttyTarget,qttyTargetGroup)$((t.val ge ttot.val) and (NOT(p47_implicitQttyTargetTax(t,all_regi,qttyTarget,qttyTargetGroup)))) = 0.1;
    );
    if(sameas(taxType,"sub"),
      p47_implicitQttyTargetTax(t,all_regi,qttyTarget,qttyTargetGroup)$((t.val ge ttot.val) and (NOT(p47_implicitQttyTargetTax(t,all_regi,qttyTarget,qttyTargetGroup)))) = - 0.1;
    );
    loop(ttot2,
      s47_firstFreeYear = ttot2.val; 
      break$((ttot2.val ge ttot.val) and (ttot2.val ge cm_startyear)); !!initial free price year
      s47_prefreeYear = ttot2.val;
    );
    loop(ttot2$(ttot2.val eq s47_prefreeYear),
      p47_implicitQttyTargetTax(t,all_regi,qttyTarget,qttyTargetGroup)$((t.val ge s47_firstFreeYear) and (t.val lt ttot.val) and (t.val ge cm_startyear) and (NOT(p47_implicitQttyTargetTax(t,all_regi,qttyTarget,qttyTargetGroup)))) = 
        p47_implicitQttyTargetTax(ttot2,all_regi,qttyTarget,qttyTargetGroup) +
        (
          p47_implicitQttyTargetTax(ttot,all_regi,qttyTarget,qttyTargetGroup) - p47_implicitQttyTargetTax(ttot2,all_regi,qttyTarget,qttyTargetGroup)
        ) / (ttot.val - ttot2.val)
        * (t.val - ttot2.val)
      ;
    );
  );
);

$endif.cm_implicitQttyTarget


***---------------------------------------------------------------------------
*** implicit tax/subsidy necessary to final energy price targets
***---------------------------------------------------------------------------

$ifthen.cm_implicitPriceTarget not "%cm_implicitPriceTarget%" == "off"

*** initialize tax value for the first iteration
  p47_implicitPriceTax(t,regi,entyFe,entySe,sector) = 0;
  
$endIf.cm_implicitPriceTarget

***---------------------------------------------------------------------------
*** implicit tax/subsidy necessary to primary energy price targets
***---------------------------------------------------------------------------

$ifthen.cm_implicitPePriceTarget not "%cm_implicitPePriceTarget%" == "off"

*** initialize tax value for the first iteration
  p47_implicitPePriceTax(t,regi,entyPe) = 0;
  
$endIf.cm_implicitPePriceTarget

*** Increase SE2FE efficiency for gases in DEU following AGEB data from 2020
pm_eta_conv("2010",regi,"tdfosgas")$(sameAs(regi,"DEU")) = 0.949;
pm_eta_conv("2015",regi,"tdfosgas")$(sameAs(regi,"DEU")) = 0.962;
pm_eta_conv(t,regi,"tdfosgas")$(sameAs(regi,"DEU") and t.val ge 2020) = 0.975;

pm_eta_conv("2010",regi,"tdbiogas")$(sameAs(regi,"DEU")) = 0.949;
pm_eta_conv("2015",regi,"tdbiogas")$(sameAs(regi,"DEU")) = 0.962;
pm_eta_conv(t,regi,"tdbiogas")$(sameAs(regi,"DEU") and t.val ge 2020) = 0.975;

pm_eta_conv("2010",regi,"tdsyngas")$(sameAs(regi,"DEU")) = 0.949;
pm_eta_conv("2015",regi,"tdsyngas")$(sameAs(regi,"DEU")) = 0.962;
pm_eta_conv(t,regi,"tdsyngas")$(sameAs(regi,"DEU") and t.val ge 2020) = 0.975;

*** Increase SE2FE efficiency for gases in DEU following AGEB data from 2020
pm_eta_conv("2010",regi,"tdfosgas")$(sameAs(regi,"DEU")) = 0.949;
pm_eta_conv("2015",regi,"tdfosgas")$(sameAs(regi,"DEU")) = 0.962;
pm_eta_conv(t,regi,"tdfosgas")$(sameAs(regi,"DEU") and t.val ge 2020) = 0.975;

pm_eta_conv("2010",regi,"tdbiogas")$(sameAs(regi,"DEU")) = 0.949;
pm_eta_conv("2015",regi,"tdbiogas")$(sameAs(regi,"DEU")) = 0.962;
pm_eta_conv(t,regi,"tdbiogas")$(sameAs(regi,"DEU") and t.val ge 2020) = 0.975;

pm_eta_conv("2010",regi,"tdsyngas")$(sameAs(regi,"DEU")) = 0.949;
pm_eta_conv("2015",regi,"tdsyngas")$(sameAs(regi,"DEU")) = 0.962;
pm_eta_conv(t,regi,"tdsyngas")$(sameAs(regi,"DEU") and t.val ge 2020) = 0.975;

***---------------------------------------------------------------------------
*** Exogenous CO2 tax level:
***---------------------------------------------------------------------------

*** initialize exogenous CO2 prices 
$ifThen.regiExoPrice not "%cm_regiExoPrice%" == "off"

*** setting exogenous CO2 prices from the input gdx
$ifThen.regiExoPriceType "%cm_regiExoPrice%" == "gdx" 
  pm_taxemiMkt(t,regi,emiMkt) = p47_tau_taxemiMkt(t,regi,emiMkt);
  pm_taxCO2eq(t,regi) = pm_tau_CO2_tax_gdx(t,regi);
*** Removing economy wide co2 tax parameters for regions within the emiMKt controlled targets (this is necessary here to remove any calculation made in other modules after the last run in the postsolve)
  loop((t,regi,emiMkt)$pm_taxemiMkt(t,regi,emiMkt),
    pm_taxCO2eq(t,regi) = 0;
  );
*** Redefining the pm_taxCO2eqSum parameter
  pm_taxCO2eqSum(t,regi) = pm_taxCO2eq(t,regi);
*** Removing additional co2 tax parameters
  pm_taxCO2eqRegi(t,regi) = 0;
  pm_taxCO2eqSCC(t,regi) = 0;
  pm_taxrevGHG0(t,regi) = 0;
  pm_taxrevCO2Sector0(t,regi,emi_sectors) = 0;
  pm_taxrevCO2LUC0(t,regi) = 0;
  pm_taxrevNetNegEmi0(t,regi) = 0;
display 'update of CO2 prices to exogenously given CO2 prices defined in the reference gdx', pm_taxCO2eq, pm_taxemiMkt;

*** setting exogenous CO2 prices from switch cm_regiExoPrice
$else.regiExoPriceType
loop((t,ext_regi)$p47_exoCo2tax(ext_regi,t),
  loop(regi$regi_group(ext_regi,regi),
*** Removing the existent co2 tax parameters for regions with exogenous set prices
    pm_taxCO2eqSum(t,regi) = 0;
    pm_taxCO2eq(t,regi) = 0;
    pm_taxCO2eqRegi(t,regi) = 0;
    pm_taxCO2eqSCC(t,regi) = 0;

    pm_taxrevGHG0(t,regi) = 0;
    pm_taxrevCO2Sector0(t,regi,emi_sectors) = 0;
    pm_taxrevCO2LUC0(t,regi) = 0;
    pm_taxrevNetNegEmi0(t,regi) = 0;

    pm_taxemiMkt(t,regi,emiMkt) = 0;

*** setting exogenous CO2 prices
    pm_taxCO2eq(t,regi) = p47_exoCo2tax(ext_regi,t)*sm_DptCO2_2_TDpGtC;
    pm_taxCO2eqSum(t,regi) = pm_taxCO2eq(t,regi);
  );
);
display 'update of CO2 prices due to exogenously given CO2 prices in p47_exoCo2tax', pm_taxCO2eq;
$endIf.regiExoPriceType
$endIf.regiExoPrice

*** EOF ./modules/47_regipol/regiCarbonPrice/preloop.gms

