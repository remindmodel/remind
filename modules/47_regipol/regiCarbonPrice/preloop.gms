*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCarbonPrice/preloop.gms

$IFTHEN.regicarbonprice not "%cm_regiCO2target%" == "off" 

*** FIXME: In the DIPOL scenarios pm_taxCO2eq is already initialized. 
*** Furthermore the 2020 value in EUR is much too low, so the price path will
*** be completely off in the first iteration. Might cause errors once other 
*** scenarios with regional CO2 targets are run (in particular if 
*** 45_carbonprice is not "diffCurvePhaseIn2Lin").
* loop((ttot,ext_regi,target_type,emi_type)$p47_regiCO2target(ttot,ext_regi,target_type,emi_type),
* 	loop(all_regi$(sameas(ext_regi,all_regi) OR (regi_group(ext_regi,all_regi))),
* *** 		Initialize EU tax path until 2050
* 		pm_taxCO2eq(ttot,all_regi)$(ttot.val gt 2016 AND ttot.val le 2050 AND pm_taxCO2eq("2025",all_regi)) = pm_taxCO2eq("2025",all_regi)*1.05**(ttot.val-2025);		
* *** 		convergence scheme post 2050: exponential increase with 1.25%
* 		pm_taxCO2eq(ttot,all_regi)$(ttot.val gt 2050) = pm_taxCO2eq("2050",all_regi)*1.0125**(ttot.val-2050);
* 	);
* );

$ENDIF.regicarbonprice

*** EOF ./modules/47_regipol/regiCarbonPrice/preloop.gms

