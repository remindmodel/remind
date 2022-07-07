*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCarbonPrice/preloop.gms

$IFTHEN.regicarbonprice not "%cm_regiCO2target%" == "off" 

loop((ttot,ttot2,ext_regi,target_type,emi_type)$pm_regiCO2target(ttot,ttot2,ext_regi,target_type,emi_type),
	loop(all_regi$(sameas(ext_regi,all_regi) OR (regi_group(ext_regi,all_regi))),
*** 		Initialize EU tax path until 2050
		pm_taxCO2eq(t,all_regi)$(t.val gt 2016 AND t.val le 2050) = pm_taxCO2eq("2020",all_regi)*1.05**(t.val-2020);		
*** 		convergence scheme post 2050: exponential increase with 1.25%
		pm_taxCO2eq(t,all_regi)$(t.val gt 2050) = pm_taxCO2eq("2050",all_regi)*1.0125**(t.val-2050);
	);
);

$ENDIF.regicarbonprice


***--------------------------------------------------
*** Emission markets
***--------------------------------------------------

*** Intialize parameters
pm_emiRescaleCo2TaxETS(ETS_mkt) = 0;
pm_emiRescaleCo2TaxESR(ttot,regi) = 0;

*** Initialize tax path
pm_taxemiMkt(t,regi,emiMkt)$(t.val ge cm_startyear) = 0;

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

