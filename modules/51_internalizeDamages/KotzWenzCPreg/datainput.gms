*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/51_internalizeDamages/KotzWenzCPreg/datainput.gms

* satisfy dependencies
$ifi not %damages% == 'KotzWenz' abort "module internalizeDamages=KotzWenzItr requires module damages=KotzWenz";
$ifi not %cm_magicc_temperatureImpulseResponse% == 'on' abort "module internalizeDamages=KotzWenzCPreg requires cm_magicc_temperatureImpulseResponse=on";

*init carbon tax for 1st iteration
p51_scc(tall,regi) = 0;
p51_scc("2025",regi) = 20;
p51_scc(tall,regi)$(tall.val ge 2025 and tall.val le 2150) = p51_scc("2025",regi)*(1+0.025*(tall.val-2025));

pm_taxCO2eqSCC(ttot,regi)$(ttot.val ge 2010) = p51_scc(ttot,regi) * sm_c_2_co2/1000;

*** EOF ./modules/51_internalizeDamages/KotzWenzCPreg/datainput.gms
