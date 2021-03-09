*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/35_transport/complex/postsolve.gms

*** calculation of FE Transport Prices (useful for internal use and reporting purposes)
pm_FEPrice(t,regi,entyFE,"trans",emiMkt)$(abs (qm_budget.m(t,regi)) gt sm_eps) = 
       q35_demFeTrans.m(t,regi,entyFE,emiMkt) / qm_budget.m(t,regi);

*** EOF ./modules/35_transport/complex/postsolve.gms
