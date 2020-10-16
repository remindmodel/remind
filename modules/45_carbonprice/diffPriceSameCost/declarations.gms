*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/diffPriceSameCost/declarations.gms

parameter

    p45_correctScale                              "XXX" / 10 /,
    p45_mitiCostRel(all_regi)                     "XXX",
    p45_mitiCostRelGlob                           "XXX",
    p45_gdpBAU(tall,all_regi)                     "baseline GDP path from gdx",


p45_debugMitiCostRel(all_regi,iteration)          "XXX",
p45_debugCprice2020(all_regi,iteration)           "XXX"
;
*** EOF ./modules/45_carbonprice/diffPriceSameCost/declarations.gms
