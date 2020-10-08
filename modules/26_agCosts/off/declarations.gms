*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/26_agCosts/off/declarations.gms
parameter
pm_totLUcosts(tall,all_regi)        "agricultural costs (non-biomass)"
pm_NXagr(tall,all_regi)           "net agricultural exports"
;

pm_totLUcosts(tall,all_regi) = 0;
pm_NXagr(tall,all_regi) = 0;

*** EOF ./modules/26_agCosts/off/declarations.gms
