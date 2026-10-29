*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/39_carbonUtilization/off/bounds.gms

vm_co2CCUshort.up(t,regi,"cco2","ccuco2short",teCCU2rlf(te2,rlf)) = sm_eps;
vm_deltaCap.up(t,regi,"h22ch4",rlf) $ (te2rlf("h22ch4",rlf)) = sm_eps;
vm_deltaCap.up(t,regi,"MeOH",rlf) $ (te2rlf("MeOH",rlf)) = sm_eps;

*** EOF ./modules/39_carbonUtilization/off/bounds.gms
