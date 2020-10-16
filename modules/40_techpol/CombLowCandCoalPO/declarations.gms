*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/40_techpol/CombLowCandCoalPO/declarations.gms
Parameter p40_NewRenBound(ttot,all_te)   "level for lower bound on absolute capacities, in GW for all technologies except electromobility";
Equation q40_NewRenBound "equation low-carbon push technology policy";

Equation q40_CoalBound                   "Allowing gradual phase-out for coal electricity to reflect existing project pipeline";

*** EOF ./modules/40_techpol/CombLowCandCoalPO/declarations.gms
