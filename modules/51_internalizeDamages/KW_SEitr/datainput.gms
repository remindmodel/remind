*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/51_internalizeDamages/KW_SEitr/datainput.gms

* satisfy dependencies
*$ifi not %damages% == 'KWLike' abort "module internalizeDamages=KWlikeItr requires module damages=KWLike";
$ifi not %cm_magicc_temperatureImpulseResponse% == 'on' abort "module internalizeDamages=KWlikeItr requires cm_magicc_temperatureImpulseResponse=on";


*inital guess carbon tax for 1st iter. Does not influence solution point.
p51_scc(tall) = 0;
p51_scc("2025") = 20;
p51_scc(tall)$(tall.val ge 2025 and tall.val le 2150) = p51_scc("2025")*(1+0.025*(tall.val-2025));

pm_taxCO2eqSCC(ttot,regi)$(ttot.val ge 2010) = p51_scc(ttot) * sm_c_2_co2/1000;


*** EOF ./modules/51_internalizeDamages/KW_SEitr/datainput.gms
