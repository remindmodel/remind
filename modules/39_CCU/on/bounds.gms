*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/39_CCU/on/bounds.gms

*** -------------------------------------------------------------------------------------------------------------
***LP* Narrowing down the solution space for vm_co2capture for CCU
*** -------------------------------------------------------------------------------------------------------------
vm_co2capture.lo(t,regi,"cco2","ico2","ccsinje","1") = 0;
vm_co2capture.up(t,regi,"cco2","ico2","ccsinje","1") = 50;

***----------------------------------------------------------------------------
*** force synthetic liquids in as a share of total liquids
***----------------------------------------------------------------------------

v39_shSynTrans.lo(t,regi)$(t.val eq 2030) = cm_shSynTrans / 4;
v39_shSynTrans.lo(t,regi)$(t.val eq 2035) = cm_shSynTrans / 2;
v39_shSynTrans.lo(t,regi)$(t.val gt 2040) = cm_shSynTrans;

***----------------------------------------------------------------------------
*** force synthetic gas in as a share of total gases
***----------------------------------------------------------------------------

v39_shSynGas.lo(t,regi)$(t.val eq 2030) = cm_shSynGas / 4;
v39_shSynGas.lo(t,regi)$(t.val eq 2035) = cm_shSynGas / 2;
v39_shSynGas.lo(t,regi)$(t.val gt 2040) = cm_shSynGas;



*** EOF ./modules/39_CCU/39_CCU.gms
