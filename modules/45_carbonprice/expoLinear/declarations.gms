*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/expoLinear/declarations.gms

scalar
s45_taxCO2_startyear                        "CO2 tax provided by cm_taxCO2_startyear converted from $/t CO2eq to T$/GtC"
;
parameter
p45_taxCO2eq_expoLinearIncrease(all_regi)     "Linear annual increase in carbon price [T$/GtC/yr] right before cm_expoLinear_yearStart"
;

*** EOF ./modules/45_carbonprice/expoLinear/declarations.gms
