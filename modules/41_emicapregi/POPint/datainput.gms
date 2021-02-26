*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/41_emicapregi/POPint/datainput.gms

*** calculate share of global emissions 
     pm_shPerm(t,regi)  =  sum(t2, pm_pop(t2,regi))/sum((t2,regi2),pm_pop(t2,regi2));

*** EOF ./modules/41_emicapregi/POPint/datainput.gms
