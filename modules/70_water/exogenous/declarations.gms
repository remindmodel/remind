*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/70_water/exogenous/declarations.gms
*** *IM* 20140502 declaration of parameters
***-------------------------------------------------------------------------------

parameters
i70_water_con(all_te, coolte70)                                 "water consumption coefficients. Unit: m3/MWh"
i70_water_wtd(all_te, coolte70)                                 "water withdrawal coefficients. Unit: m3/MWh"
i70_cool_share(all_regi, all_te, coolte70)                      "cooling technology shares. Unit: %"
;
*** EOF ./modules/70_water/exogenous/declarations.gms
