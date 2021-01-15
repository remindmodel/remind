*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/15_climate/box/postsolve.gms
***-------- taken from loop.gms --------------------------------
*** update kyoto forcing guardrail
***s15_gr_forc_kyo = s15_gr_forc_kyo - (v15_forcComp.l('2100','TTL')-s15_gr_forc_os);
s15_gr_forc_kyo = s15_gr_forc_kyo - (v15_forcRcp.l('2100')-s15_gr_forc_os);
if (cm_emiscen=8, v15_forcKyo.up(ta10)$(ord(ta10)>100) = s15_gr_forc_kyo);
display s15_gr_forc_kyo;
*** s15_gr_forc_kyo_nte(ta10) = s15_gr_forc_kyo_nte(ta10) - (v15_forcComp.l(ta10,'TTL')-s15_gr_forc_nte);
*** s15_gr_forc_kyo_nte = s15_gr_forc_kyo_nte - (smax((ta10),(v15_forcComp.l(ta10,'TTL')))-s15_gr_forc_nte);
s15_gr_forc_kyo_nte = s15_gr_forc_kyo_nte - (smax((ta10),(v15_forcRcp.l(ta10)))-s15_gr_forc_nte);
if (cm_emiscen=5, v15_forcKyo.up(ta10)$(ord(ta10)>1) = s15_gr_forc_kyo_nte);
display s15_gr_forc_kyo_nte;

o_negitr_total_forc(iteration) = v15_forcComp.l("2100","TTL");

s15_diffrad=s15_gr_forc_os-v15_forcRcp.l("2100");
display sm_budgetCO2eqGlob;
*TiA / JeS: adjust budget until 2100 such that radiative forcing target is reached
if(abs(s15_diffrad) ge 0.01,
$if not %cm_rcp_scen% == "none"     sm_budgetCO2eqGlob = sm_budgetCO2eqGlob * s15_gr_forc_os/(v15_forcRcp.l("2100")) ;
display sm_budgetCO2eqGlob;
);
*ML 20141029 * computation of permit prices (might be eps in equations used otherwise)
loop(ta10,
  pm_pricePerm(ttot)$(ttot.val eq ta10.val) =  abs( q15_linkEMI.m(ttot,ta10,"co2","co2"))
);
display pm_pricePerm;

*** EOF ./modules/15_climate/box/postsolve.gms
