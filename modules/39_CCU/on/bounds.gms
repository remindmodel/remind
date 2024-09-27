*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/39_CCU/on/bounds.gms

*** -------------------------------------------------------------------------------------------------------------
***LP* Narrowing down the solution space for vm_co2capture for CCU
*** -------------------------------------------------------------------------------------------------------------

vm_co2capture.up(t,regi,"cco2","ico2","ccsinje","1") = 50;

*** FS: overwrite bounds of se2se technologies in core/bounds.gms and set synfuel lower bounds only from 2035 on
*** (they are only there in case the solver misses to see the technologies)
vm_cap.lo(t,regi,te_ccu39,"1")=0;
vm_cap.lo(t,regi,te_ccu39,"1")$(t.val gt 2031)=1e-7;

*** CCU technologies will not be used at scale before 2030
vm_cap.up(t,regi,te_ccu39,"1")$(t.val le 2025)=1e-6;
*** CCU technologies will not be used at scale in 2030 (for non potential exporting regions)
vm_cap.up(t,regi,te_ccu39,"1")$((t.val eq 2030) and (not(sameas(regi,"SSA") or sameas(regi,"LAM") or sameas(regi,"MEA"))))=1e-6;

*** FS: switch off CCU in baseline runs (as CO2 capture technologies teCCS are also switched off)
if(cm_emiscen = 1,
  vm_cap.fx(t,regi,te_ccu39,rlf) = 0;
);

***----------------------------------------------------------------------------
*** force synthetic liquids in as a minimum share of total liquids if cm_shSynLiq switch used
***----------------------------------------------------------------------------

if (cm_shSynLiq gt 0,
  v39_shSynLiq.lo(t,regi)$(t.val eq 2035) = cm_shSynLiq / 4;
  v39_shSynLiq.lo(t,regi)$(t.val eq 2040) = cm_shSynLiq / 2;
  v39_shSynLiq.lo(t,regi)$(t.val ge 2045) = cm_shSynLiq;
);

***----------------------------------------------------------------------------
*** force synthetic gases in as a minimum share of total liquids if cm_shSynGas switch used
***----------------------------------------------------------------------------

if (cm_shSynGas gt 0,
v39_shSynGas.lo(t,regi)$(t.val eq 2035) = cm_shSynGas / 4;
v39_shSynGas.lo(t,regi)$(t.val eq 2040) = cm_shSynGas / 2;
v39_shSynGas.lo(t,regi)$(t.val ge 2045) = cm_shSynGas;
);
*** EOF ./modules/39_CCU/on/bounds.gms
