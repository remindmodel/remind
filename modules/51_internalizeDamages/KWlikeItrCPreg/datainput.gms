*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/51_internalizeDamages/KWlikeItrCPreg/datainput.gms

* satisfy dependencies
$ifi not %damages% == 'KWLike' abort "module internalizeDamages=KWlikeItrCPreg requires module damages=KWLike";
$ifi not %cm_magicc_temperatureImpulseResponse% == 'on' abort "module internalizeDamages=KWlikeItrCPreg requires cm_magicc_temperatureImpulseResponse=on";


*inital guess carbon tax for 1st iter. Does not influence solution point.
p51_scc("2020",regi) = 20;
p51_scc(tall,regi)$(tall.val ge 2010 and tall.val le 2150) = p51_scc("2020",regi)*(1+0.02*(tall.val-2020));

pm_taxCO2eqSCC(ttot,regi)$(ttot.val ge 2010) = p51_scc(ttot,regi) * (44/12)/1000;


*** EOF ./modules/51_internalizeDamages/KWlikeItrCPreg/datainput.gms
