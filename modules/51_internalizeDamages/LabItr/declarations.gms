*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/51_internalizeDamages/LabItr/declarations.gms

parameters
p51_scc(tall) "Social cost of carbon (due to GDP damages) [$ per tCO2eq]"
p51_sccLastItr(tall) "Social cost of carbon (due to GDP damages) from last iteration [$ per tCO2eq]"
p51_sccParts(tall,tall,all_regi)  "component needed for SCC calculation"
p51_dy(tall,all_regi)		"damage factor for GDP instead of labor"

p51_sccConvergenceMaxDeviation "max deviation of SCC from last iteration [percent]"

p51_labRho(tall,all_regi)	"ces parameter rho for labor, needed for extension beyond 2150"
p51_labXi(tall,all_regi)	"ces parameter xi for labor, needed for extension beyond 2150"
p51_labEff(tall,all_regi)	"ces parameter eff for labor, needed for extension beyond 2150"
p51_labEffgr(tall,all_regi)	"ces parameter effgr for labor, needed for extension beyond 2150"
p51_lab(tall,all_regi)		"labor for extension beyond 2150"
p51_ygross(tall,all_regi)		"GDP net of labor damage"
;

*** EOF ./modules/51_internalizeDamages/LabItr/declarations.gms
