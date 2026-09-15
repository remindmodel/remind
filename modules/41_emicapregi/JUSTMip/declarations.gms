*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  REMIND you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/41_emicapregi/JUSTMip/declarations.gms

variables
vm_perm(ttot,all_regi)                          "emission allowances [GtCeq]"
;

parameter
pm_shPerm(tall, all_regi)                       "emission permit shares [share]"
pm_emicapglob(tall)                             "global emission cap [GtCeq]"
p41_gdpGlob(ttot)                                "global GDP"
;

equations
q41_globalPermitTradeCap(ttot,all_regi)                   "emission permit allocation"
;


*** EOF ./modules/41_emicapregi/JUSTMip/declarations.gms
