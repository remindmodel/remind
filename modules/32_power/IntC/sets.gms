*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/32_power/IntC/sets.gms

*** Define regions, for which the flexibiity tax should be applied
$ifThen.regiFlexTax "%cm_regiFlexTax%" == "all"
Set regiFlexTax_32(all_regi) "Set of regions, in which the flexibility tax is applied";
regiFlexTax_32(regi) = YES;
$else.regiFlexTax
Set regiFlexTax_32(all_regi) "Set of regions, in which the flexibility tax is applied" / %cm_regiFlexTax% /;
$endIf.regiFlexTax

*** EOF ./modules/32_power/IntC/sets.gms