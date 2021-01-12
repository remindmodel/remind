*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/negishi/bounds.gms
*AJS* Adjustment costs are only relevant for the Nash realization
vm_costAdjNash.fx(t,regi) = 0;

*ML* fix dummy variable that is only used for Nash 
vm_dummyBudget.fx(t,regi) = 0;

*** EOF ./modules/80_optimization/negishi/bounds.gms
