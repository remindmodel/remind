*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCarbonPrice/sets.gms

SETS
target_type "CO2 policy target type" / budget , year /

emi_type "emission type used in regional target" / netCO2, netCO2_noBunkers, netGHG, netGHG_noBunkers, grossEnCO2_noBunkers /

ETS_mkt "ETS market"
/
  EU_ETS
/ 

$IFTHEN.emiMktETS not "%cm_emiMktETS%" == "off" 
ETS_regi(ETS_mkt,all_regi) "regions that belong to the same ETS market"
/
   EU_ETS.(ENC,EWN,ECS,ESC,ECE,FRA,DEU,UKI,ESW)  !!,NEN (to include NEN I need to disable only partially the pm_taxCO2eq tax (because if not the ESD emissions would be without tax).   
/
$ENDIF.emiMktETS



$ifthen.cm_implicitFE not "%cm_implicitFE%" == "off"

FEtarget_sector "final energy target sector groups" / stat, trans /

FEtarget_sector2entyFe(FEtarget_sector,all_enty)  "mapping final energy to stationary or transportation sectors"
/
   stat.(fegas,fehos,fesos,feels,fehes,feh2s)
   trans.(fegat,fepet,fedie,feh2t,feelt)
/

$ENDIF.cm_implicitFE

;

*** EOF ./modules/47_regipol/regiCarbonPrice/sets.gms

