*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/32_power/DTcoup/postsolve.gms

*** calculation of SE electricity price (useful for internal use and reporting purposes)
pm_SEPrice(ttot,regi,entySe)$(abs (qm_budget.m(ttot,regi)) gt sm_eps AND sameas(entySe,"seel")) = 
       q32_balSe.m(ttot,regi,entySe) / qm_budget.m(ttot,regi);

*** EOF ./modules/32_power/DTcoup/postsolve.gms

