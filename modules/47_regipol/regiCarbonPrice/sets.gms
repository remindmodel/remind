*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCarbonPrice/sets.gms

SETS
target_type "CO2 policy target type" / budget , year /

emi_type "emission type used in regional target" / netCO2, netCO2_noBunkers, netCO2_noLULUCF_noBunkers, netGHG, netGHG_noBunkers, netGHG_noLULUCF_noBunkers, grossEnCO2_noBunkers, netGHG_LULUCFGrassi_noBunkers /

ETS_mkt "ETS market"
/
  EU_ETS
/

ETS_regi(ETS_mkt,all_regi) "regions that belong to the same ETS market"
//

$ifthen.cm_implicitFE not "%cm_implicitFE%" == "off"

FEtarget_sector "final energy target sector groups" / stat, trans /

FEtarget_sector2entyFe(FEtarget_sector,all_enty)  "mapping final energy to stationary or transportation sectors"
/
   stat.(fegas,fehos,fesos,feels,fehes,feh2s)
   trans.(fegat,fepet,fedie,feh2t,feelt)
/

$endif.cm_implicitFE
;

*** Defining EU ETS
loop(all_regi$(regi_group("EUR_regi",all_regi) AND (NOT(sameas(all_regi,"UKI")))),
  ETS_regi("EU_ETS",all_regi) = YES;
);
***NEN (to include NEN I need to disable only partially the pm_taxCO2eq tax (because if not the ESD emissions would be without tax).   

alias(emi_type,emi_type2);

*** EOF ./modules/47_regipol/regiCarbonPrice/sets.gms

