*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/32_power/IntC/presolve.gms

*** calculation of SE electricity price (useful for internal use and reporting purposes)
pm_SEPrice(t,regi,entySE)$(    abs(qm_budget.m(t,regi)) gt sm_eps
                           AND sameas(entySE,"seel") )
  = q32_balSe.m(t,regi,entySE)
  / qm_budget.m(t,regi);

*** EOF ./modules/32_power/IntC/presolve.gms
