*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCarbonPrice/preloop.gms

***--------------------------------------------------
*** Emission markets
***--------------------------------------------------

*** Intialize parameters
pm_emiRescaleCo2TaxETS(ETS_mkt) = 0;
pm_emiRescaleCo2TaxESR(ttot,regi) = 0;

*** Initialize tax path
pm_taxemiMkt(t,regi,emiMkt)$(t.val ge cm_startyear) = 0;

$IFTHEN.emiMkt not "%cm_emiMktTarget%" == "off" 
  loop((ttot,ttot2,ext_regi,emiMktExt,target_type,emi_type)$(pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type,emi_type)),
	loop(regi$regi_groupExt(ext_regi,regi),
		loop(emiMkt$emiMktGroup(emiMktExt,emiMkt), 
    		pm_taxemiMkt(ttot3,regi,emiMkt)$(ttot3.val le cm_startyear) = p47_taxemiMktBeforeStartYear(ttot3,regi,emiMkt);
		);
	);
  );
$ENDIF.emiMkt

$IFTHEN.emiMktETS not "%cm_emiMktETS%" == "off" 
if ( (cm_startyear gt 2005),
  Execute_Loadpoint 'input_ref' pm_taxemiMkt = pm_taxemiMkt;
  pm_taxemiMkt(t,regi,"ETS")$(NOT (ETS_regi("EU_ETS",regi))) = 0;
);
$ENDIF.emiMktETS

$IFTHEN.emiMktES not "%cm_emiMktES%" == "off"
if ( (cm_startyear gt 2005),
  Execute_Loadpoint 'input_ref' pm_taxemiMkt = pm_taxemiMkt;
  pm_taxemiMkt(t,regi,"ES")$(NOT (regi_group("EU27_regi",regi))) = 0;
  pm_taxemiMkt(t,regi,"other")$(NOT (ETS_regi("EU_ETS",regi) OR regi_group("EU27_regi",regi))) = 0;
);
$ENDIF.emiMktES

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
			break$((ttot2.val ge ttot.val) and (ttot2.val ge cm_startyear)); !!initial free price year
			s47_prefreeYear = ttot2.val;
		);
		loop(ttot2$(ttot2.val eq s47_prefreeYear),
			p47_implEnergyBoundTax(t,all_regi,energyCarrierLevel,energyType)$((t.val gt ttot2.val) and (t.val lt ttot.val) and (t.val ge cm_startyear) and (NOT(p47_implEnergyBoundTax(t,all_regi,energyCarrierLevel,energyType)))) = 
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

$ontext
*** Removing the economy wide co2 tax parameters for regions within the ETS
$IFTHEN.ETSprice not "%cm_emiMktETS%" == "off" 
	loop(ETS_mkt,
		pm_taxCO2eq(t,regi)$((t.val ge cm_startyear) and ETS_regi(ETS_mkt,regi)) = 0;
		pm_taxCO2eqHist(t,regi)$((t.val ge cm_startyear) and ETS_regi(ETS_mkt,regi)) = 0;
  	);
$ENDIF.ETSprice

*** Removing the economy wide co2 tax parameters for regions within the ES
$IFTHEN.ESprice not "%cm_emiMktES%" == "off" 
	loop((regi)$pm_emiTargetESR("2030",regi),
		pm_taxCO2eq(t,regi)$(t.val ge cm_startyear) = 0;
		pm_taxCO2eqHist(t,regi)$(t.val ge cm_startyear) = 0;
  );
$ENDIF.ESprice
$offtext
*** EOF ./modules/47_regipol/regiCarbonPrice/preloop.gms

