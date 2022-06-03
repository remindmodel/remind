*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
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
*** Calculation of implicit tax/subsidy necessary to achieve primary, secondary and/or final energy targets
***---------------------------------------------------------------------------

$ifthen.cm_implicitEnergyBound not "%cm_implicitEnergyBound%" == "off"
*** initialize tax value for first iteration
  p47_implEnergyBoundTax(t,all_regi,energyCarrierLevel,energyType) = 0;

*** load tax from gdx
$ifthen.loadFromGDX_implEnergyBoundTax not "%cm_loadFromGDX_implEnergyBoundTax%" == "off"
Execute_Loadpoint 'input_ref' p47_implEnergyBoundTax = p47_implEnergyBoundTax;
*** disable tax values for inexistent targets
  loop((ttot,ext_regi,taxType,targetType,energyCarrierLevel,energyType)$(NOT (p47_implEnergyBoundTarget(ttot,ext_regi,taxType,targetType,energyCarrierLevel,energyType))),
    loop(all_regi$regi_groupExt(ext_regi,all_regi),
      p47_implEnergyBoundTax(t,all_regi,energyCarrierLevel,energyType) = 0;
    );
  );
$endif.loadFromGDX_implEnergyBoundTax

*** initialize values if not loaded from gdx
loop((ttot,ext_regi,taxType,targetType,energyCarrierLevel,energyType)$p47_implEnergyBoundTarget(ttot,ext_regi,taxType,targetType,energyCarrierLevel,energyType),
  loop(all_regi$regi_groupExt(ext_regi,all_regi),
    if(sameas(taxType,"tax"),
      p47_implEnergyBoundTax(t,all_regi,energyCarrierLevel,energyType)$((t.val ge ttot.val) and (NOT(p47_implEnergyBoundTax(t,all_regi,energyCarrierLevel,energyType)))) = 0.1;
    );
    if(sameas(taxType,"sub"),
      p47_implEnergyBoundTax(t,all_regi,energyCarrierLevel,energyType)$((t.val ge ttot.val) and (NOT(p47_implEnergyBoundTax(t,all_regi,energyCarrierLevel,energyType)))) = - 0.1;
    );
    loop(ttot2,
      s47_firstFreeYear = ttot2.val; 
      break$((ttot2.val ge ttot.val) and (ttot2.val ge cm_startyear)); !!initial free price year
      s47_prefreeYear = ttot2.val;
    );
    loop(ttot2$(ttot2.val eq s47_prefreeYear),
      p47_implEnergyBoundTax(t,all_regi,energyCarrierLevel,energyType)$((t.val ge s47_firstFreeYear) and (t.val lt ttot.val) and (t.val ge cm_startyear) and (NOT(p47_implEnergyBoundTax(t,all_regi,energyCarrierLevel,energyType)))) = 
        p47_implEnergyBoundTax(ttot2,all_regi,energyCarrierLevel,energyType) +
        (
          p47_implEnergyBoundTax(ttot,all_regi,energyCarrierLevel,energyType) - p47_implEnergyBoundTax(ttot2,all_regi,energyCarrierLevel,energyType)
        ) / (ttot.val - ttot2.val)
        * (t.val - ttot2.val)
      ;
    );
  );
);

$endif.cm_implicitEnergyBound

*** EOF ./modules/47_regipol/regiCarbonPrice/preloop.gms

