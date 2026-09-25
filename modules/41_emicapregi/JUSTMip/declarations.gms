*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  REMIND you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/41_emicapregi/JUSTMip/declarations.gms

variables
vm_perm(ttot,all_regi)                          "emission allowances [GtCeq]"
vm_permTradeVolumeRegi(ttot,all_regi)           "emission permit trade volume - regional [trillion USD]"
vm_permTradeVolumeGlo(ttot,all_regi)             "emission permit trade volume - global (from each regions' perspective in an iteration) [trillion USD]"
;

parameter
pm_shPerm(tall, all_regi)                       "emission permit shares [share]"
pm_emicapglob(tall)                             "global emission cap [GtCeq]"
p41_gdpGlob(ttot)                                "global GDP"
pm_permTradeVolumeRegi_iter(iteration,ttot,all_regi)  "regional trade volume, for debugging [trillion USD]"
pm_otherRegionsTradeVolume(ttot,all_regi)               "trade volume of other regions, to be used in the next iteration [trillion USD]"
pm_otherRegionsTradeVolume_iter(iteration,ttot,all_regi)  "trade volume of other regions over time, for debugging [trillion USD]"
pm_permTradeVolumeGlo_full(iteration, ttot)             "actual global trade volume, for debugging [trillion USD]"
;

equations
q41_globalPermitTradeCap(ttot,all_regi)                   "emission permit trade limit - global"
q41_globalPermitTradeCapRegi(ttot, all_regi)                   "emission permit trade limit - regional"
q41_tradeVolumeRegi(ttot,all_regi)              "calculate the emissions permit trade volume - regional"
q41_tradeVolumeGlo(ttot,all_regi)               "calculate the emissions permit trade volume - global"
;


*** EOF ./modules/41_emicapregi/JUSTMip/declarations.gms
