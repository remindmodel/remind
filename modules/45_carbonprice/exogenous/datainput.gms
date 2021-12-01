*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/exogenous/datainput.gms
***----------------------------
*** CO2 Tax level
***----------------------------

if((cm_emiscen eq 9),

*** Include exogenous tax level
$ifThen.cm_regiExoPrice not "%cm_regiExoPrice%" == "off" 
loop((ttot,ext_regi)$p45_exo_co2_tax(ext_regi,ttot),
  p45_tau_co2_tax(ttot,regi)$(regi_group(ext_regi,regi) and ttot.val ge cm_startyear) = p45_exo_co2_tax(ext_regi,ttot)*sm_DptCO2_2_TDpGtC;
);
pm_taxCO2eq(t,regi) = p45_tau_co2_tax(t,regi);

$else.cm_regiExoPrice

$include "./modules/45_carbonprice/exogenous/input/p45_tau_co2_tax.inc"
pm_taxCO2eq(ttot,regi)$(ttot.val ge 2005) = p45_tau_co2_tax(ttot,regi);

$endIf.cm_regiExoPrice


else
  pm_taxCO2eq(ttot,regi)$(ttot.val ge 2005) = 0;
abort "Error: Please set cm_emiscen to 9";
);

*** EOF ./modules/45_carbonprice/exogenous/datainput.gms
