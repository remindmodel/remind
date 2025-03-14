*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/52_internalizeLCAimpacts/off/datainput.gms

*** All ecotax components set to zero
pm_taxEnvironmentalImpacts(ttot,regi)     = 0;
pm_taxEI_SE(ttot,all_regi,all_te) = 0;
pm_taxEI_PE(ttot,all_regi,all_enty) = 0;
pm_taxEI_cap(ttot,all_regi,all_te) = 0;

*** EOF ./modules/52_internalizeLCAimpacts/off/datainput.gms
