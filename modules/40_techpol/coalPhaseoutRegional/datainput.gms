*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/40_techpol/coalPhaseoutRegional/datainput.gms
p40_popshare(t, regi) = pm_pop(t, regi)/ sum(regi2, pm_pop(t, regi2));
*** EOF ./modules/40_techpol/coalPhaseoutRegional/datainput.gms
