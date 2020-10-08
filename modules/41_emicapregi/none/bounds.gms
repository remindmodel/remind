*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/41_emicapregi/none/bounds.gms

*LB* set the regional emission cap at a high level
*ML* to be overwritten in Nash EMIOPT 
vm_perm.fx(t,regi) = 1000;

*** No region participates in emissions trading
vm_Xport.fx(t,regi,"perm") = 0;
vm_Mport.fx(t,regi,"perm") = 0;

*** EOF ./modules/41_emicapregi/none/bounds.gms
