*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/20_growth/exogenous/bounds.gms
 vm_effGr.fx(t,regi,in) = pm_cesdata(t,regi,in,"effgr");
 vm_invInno.fx(t,regi,in) = 0; 
 vm_invImi.fx(t,regi,in) = 0;
*** EOF ./modules/20_growth/exogenous/bounds.gms
