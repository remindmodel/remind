*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/46_carbonpriceRegi/netZero/sets.gms

sets

targetSpecies "Gases included in national net-zero targets" / CO2_target, GHG_target /

$ifthen.LTSexcludeRegi not "%cm_LTSexcludeRegi%" == "off"
    LTSexcludeRegi(all_regi) "Regions for which net-zero targets are ignored" / %cm_LTSexcludeRegi% /
$else.LTSexcludeRegi
    LTSexcludeRegi(all_regi) "Regions for which net-zero targets are ignored" / /
$endif.LTSexcludeRegi
;

*** EOF ./modules/46_carbonpriceRegi/netZero/sets.gms
