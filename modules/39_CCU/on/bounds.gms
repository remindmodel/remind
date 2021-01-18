*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/39_CCU/on/bounds.gms

*** constrain solution space for CO2 capture
vm_co2capture.up(t,regi,"cco2","ico2","ccsinje","1") = 50;

*** FS: overwrite bounds of se2se technologies in core/bounds.gms and set synfuel lower bounds only from 2035 on
*** (they are only there in case the solver misses to see the technologies)
vm_cap.lo(t,regi,te_ccu39,"1")=0;
vm_cap.lo(t,regi,te_ccu39,"1")$(t.val gt 2031)=1e-7;

*** FS: switch off CCU in baseline runs (as CO2 capture technologies teCCS are also switched off)
if(cm_emiscen = 1,
  vm_cap.fx(t,regi,te_ccu39,rlf) = 0;
);


***----------------------------------------------------------------------------
*** lower bound on share of synthetic fuels in all transport fuels by 2035
***----------------------------------------------------------------------------

v39_shSynTrans.lo(t,regi)$(t.val ge 2030) = cm_shSynTrans / 4;
v39_shSynTrans.lo(t,regi)$(t.val ge 2040) = cm_shSynTrans / 2;
v39_shSynTrans.lo(t,regi)$(t.val ge 2045) = cm_shSynTrans;

***----------------------------------------------------------------------------
*** force synthetic gas in as a share of total gases
***----------------------------------------------------------------------------

v39_shSynGas.lo(t,regi)$(t.val ge 2030) = cm_shSynGas / 4;
v39_shSynGas.lo(t,regi)$(t.val ge 2040) = cm_shSynGas / 2;
v39_shSynGas.lo(t,regi)$(t.val ge 2045) = cm_shSynGas;

*** EOF ./modules/39_CCU/39_CCU.gms
