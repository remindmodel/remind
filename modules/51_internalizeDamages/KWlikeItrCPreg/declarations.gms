*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/51_internalizeDamages/KWlikeItrCPreg/declarations.gms

parameters

p51_marginalDamageCumul(tall,tall,all_regi) "marginal cumulative damage damages"
p51_scc(tall,all_regi) "Social cost of carbon (due to GDP damages) [$ per tCO2eq]"
p51_sccLastItr(tall,all_regi) "Social cost of carbon (due to GDP damages) from last iteration [$ per tCO2eq]"
p51_sccParts(tall,tall,all_regi) "Social cost of carbon components (time, region)"


p51_sccConvergenceMaxDeviation(all_regi) "max deviation of SCC from last iteration [percent]"
;

*** EOF ./modules/51_internalizeDamages/KWlikeItrCPreg/declarations.gms
