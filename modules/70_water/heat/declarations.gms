*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/70_water/heat/declarations.gms
*** *IM*2015-05-14* Declaration of parameters
***-------------------------------------------------------------------------------

PARAMETERS
i70_water_con(all_te, coolte70)                                 "water consumption coefficients. Unit: m3/MWh"
i70_water_wtd(all_te, coolte70)                                 "water withdrawal coefficients. Unit: m3/MWh"
i70_cool_share_time(ttot2, all_regi, all_te, coolte70)          "time dependent cooling technology shares. Unit: %"
i70_efficiency(ttot, all_regi, all_te, coolte70)                "efficiency factor for cooling systems. Unit: 0-1"
i70_losses(all_te)                                              "smoke stack fuel input losses. Unit: %"

p70_cap_vintages(ttot, all_regi, all_te, ttot2)                 "capacity build in ttot2 still standing in ttot. Unit: GW"
p70_cap_vintages_share(ttot, all_regi, all_te, ttot2)           "fraction of capacity build in ttot2 still standing in ttot out of total capacity in ttot. Unit: 0-1"
p70_heat(ttot,all_regi,all_enty,all_enty,all_te)                "excess heat. Unit: TWa"
p70_water_con(all_regi, all_te, coolte70)                       "water consumption coefficients per excess heat. Unit: m3/MWh"
p70_water_wtd(all_regi, all_te, coolte70)                       "water withdrawal coefficients per excess heat. Unit: m3/MWh)"

p70_water_output(ttot,all_regi,descr_water_ext)                          "output"

o70_se_production(ttot,all_regi,all_te)                         "secondary energy production. Unit: EJ/yr"
o70_water_consumption(ttot, all_regi, all_te)                   "water consumption per technology. Unit: km3/yr"
o70_water_withdrawal(ttot, all_regi, all_te)                    "water withdrawal per technology. Unit: km3/yr"


;

*** EOF ./modules/70_water/heat/declarations.gms
