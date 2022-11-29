*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
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

*** EOF ./modules/47_regipol/regiCarbonPrice/preloop.gms

