*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/51_internalizeDamages/off/declarations.gms

parameters

pm_sccConvergenceMaxDeviation "max deviation of SCC from last iteration [percent]"
pm_taxCO2eqSCC(ttot,all_regi) "carbon tax component due to damages (social cost of carbon) [T$/GtCeq]"
pm_GDPGross(tall,all_regi) "gross GDP (before damages) [T$]"
;

*** EOF ./modules/51_internalizeDamages/off/declarations.gms
