*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./core/preloop.gms

***------------------------------------------------------------------------------
***------------------------------------------------------------------------------
***                   MODEL             HYBRID
***------------------------------------------------------------------------------
***------------------------------------------------------------------------------
*** definition of model hybrid 
model hybrid /all/;

***------------------------------------------------------------------------------
***------------------------------------------------------------------------------
***                   GDX    stuff       
***------------------------------------------------------------------------------
***------------------------------------------------------------------------------

*** Set level values, so that reference value is available even if gdx has no level value to overwrite. Gams complains if .l was never initialized.
vm_emiMacSector.l(ttot,regi,enty)      = 0;
vm_emiTe.l(ttot,regi,enty)      = 0;
vm_emiCdr.l(ttot,regi,enty)	     = 0;
vm_prodFe.l(ttot,regi,entyFe2,entyFe2,te) = 0;
vm_prodSe.l(ttot,regi,enty,enty2,te) = 0;
vm_demSe.l(ttot,regi,enty,enty2,te) = 0;
vm_Xport.l(ttot,regi,tradePe)       = 0;
vm_capDistr.l(t,regi,te,rlf)          = 0;
vm_cap.l(t,regi,te,rlf)              = 0;
vm_fuExtr.l(ttot,regi,"pebiolc","1")$(ttot.val ge 2005)  = 0;
vm_pebiolc_price.l(ttot,regi)$(ttot.val ge 2005)         = 0;
vm_emiAllMkt.l(t,regi,enty,emiMkt) = 0;
vm_co2eqMkt.l(ttot,regi,emiMkt) = 0;

v_shfe.l(t,regi,enty,sector) = 0;
v_shGasLiq_fe.l(t,regi,sector) = 0;  
pm_share_CCS_CCO2(t,regi) = 0; 
  
*** overwrite default targets with gdx values if wanted
Execute_Loadpoint 'input' p_emi_budget1_gdx = sm_budgetCO2eqGlob;
Execute_Loadpoint 'input' vm_demPe.l = vm_demPe.l;
Execute_Loadpoint 'input' q_balPe.m = q_balPe.m;
Execute_Loadpoint 'input' qm_budget.m = qm_budget.m;
Execute_Loadpoint 'input' pm_pvpRegi = pm_pvpRegi;
Execute_Loadpoint 'input' pm_pvp = pm_pvp;
Execute_Loadpoint 'input' vm_demFeSector.l = vm_demFeSector.l;

if (cm_gdximport_target eq 1,
  if ( ((p_emi_budget1_gdx < 1.5 * sm_budgetCO2eqGlob) AND (p_emi_budget1_gdx > 0.5 * sm_budgetCO2eqGlob)),
  sm_budgetCO2eqGlob=p_emi_budget1_gdx;
  );
);
*MLB 07072014* ficticious budget break down for Negishi mode, not part of the optimization
pm_budgetCO2eq(regi) = 1/card(regi) * sm_budgetCO2eqGlob;
display sm_budgetCO2eqGlob;


*cb adjustment of vintages to account for fast growth in developing countries
*** adjust vintages for real fe growth in years 1995-2005
*** 2005 capacity addition (regi,"1",te) is scaled with ratio between (growth rate + 1/lifetime) and 1/lifetime, 
*** with an offset of 0.5% to account for the general growth assumed in generisdata_vintages; for  regions with declining FE, 10% is minimum ratio
*** 2000 capacity addition (regi,"6",te) is scaled with the average of the above ratio and 1
*** PE2SE technologies
loop(pe2se(enty,entySe,te)$((not sameas(entySe,"seh2")) AND (not sameas(te,"dhp")) AND (not sameas(te,"tnrs")) ),
  pm_vintage_in(regi,"1",te) = pm_vintage_in(regi,"1",te) * max(   ( (pm_histfegrowth(regi,entySe) - 0.005) + 1/fm_dataglob("lifetime",te)) / (1/fm_dataglob("lifetime",te))           , 0.1);
  pm_vintage_in(regi,"6",te) = pm_vintage_in(regi,"6",te) * max( ( ( (pm_histfegrowth(regi,entySe) - 0.005) + 1/fm_dataglob("lifetime",te)) / (1/fm_dataglob("lifetime",te)) + 1) * 0.75 , 0.2);
);
***SE2FE technologies
loop(se2fe(enty,entyFe,te)$((not sameas(enty, "seh2")) AND (not sameas(entyFe, "feelt"))),
pm_vintage_in(regi,"1",te) = pm_vintage_in(regi,"1",te) * max((pm_histfegrowth(regi,entyFe)- 0.005 + 1/fm_dataglob("lifetime",te))/(1/fm_dataglob("lifetime",te)),0.1);
pm_vintage_in(regi,"6",te) = pm_vintage_in(regi,"6",te) * max(((pm_histfegrowth(regi,entyFe)- 0.005 + 1/fm_dataglob("lifetime",te))/(1/fm_dataglob("lifetime",te)) + 1)* 0.75, 0.2);
);
***fe2ue technologies
loop(fe2ue(entyFe,enty,te)$((not sameas(te, "apCarElT")) AND (not sameas(te, "apCarH2T")) AND (not sameas(te, "apTrnElT"))),
pm_vintage_in(regi,"1",te) = pm_vintage_in(regi,"1",te) * max((pm_histfegrowth(regi,entyFe)- 0.005 + 1/fm_dataglob("lifetime",te))/(1/fm_dataglob("lifetime",te)),0.1);
pm_vintage_in(regi,"6",te) = pm_vintage_in(regi,"6",te) * max(((pm_histfegrowth(regi,entyFe)- 0.005 + 1/fm_dataglob("lifetime",te))/(1/fm_dataglob("lifetime",te)) + 1) * 0.75,0.2);
);

*RP
*** First adjustment of CO2 price path for peakBudget runs (set by cm_iterative_target_adj eq 9)
if(cm_iterative_target_adj eq 9,
*** Save the original functional form of the CO2 price trajectory so values for all times can be accessed even if the peakBudgYr is shifted. 
*** Then change to linear increasing CO2 price after peaking time 
  p_taxCO2eq_until2150(t,regi) = pm_taxCO2eq(t,regi);
  loop(t2$(t2.val eq cm_peakBudgYr),
    pm_taxCO2eq(t,regi)$(t.val gt cm_peakBudgYr) = p_taxCO2eq_until2150(t2,regi) + (t.val - t2.val) * cm_taxCO2inc_after_peakBudgYr * sm_DptCO2_2_TDpGtC;  !! increase by cm_taxCO2inc_after_peakBudgYr per year
  );
);

display p_taxCO2eq_until2150, pm_taxCO2eq;

$IFTHEN.scaleEmiHist %c_scaleEmiHistorical% == "on"

*re-scale MAgPie reference emissions to be inline with eurostat data (MagPie overestimates non-CO2 GHG emissions by a factor of 50% more)
display pm_macBaseMagpie;
loop(enty$(sameas(enty,"ch4rice") OR sameas(enty,"ch4animals") OR sameas(enty,"ch4anmlwst")),
  pm_macBaseMagpie(ttot,regi,enty)$(p_histEmiSector("2005",regi,"ch4","agriculture","process") AND (ttot.val ge 2005)) =
   pm_macBaseMagpie(ttot,regi,enty) *
    ( (p_histEmiSector("2005",regi,"ch4","agriculture","process")+p_histEmiSector("2005",regi,"ch4","lulucf","process")) !!no rescaling needed - REMIND-internal unit is Mt CH4
      /
      (sum(enty2$(sameas(enty2,"ch4rice") OR sameas(enty2,"ch4animals") OR sameas(enty2,"ch4anmlwst")), pm_macBaseMagpie("2005",regi,enty2)) + p_macBaseExo("2005",regi,"ch4agwaste"))
    )
  ;
);
loop(enty$(sameas(enty,"n2ofertin") OR sameas(enty,"n2ofertcr") OR sameas(enty,"n2oanwstc") OR sameas(enty,"n2oanwstm") OR sameas(enty,"n2oanwstp")),
  pm_macBaseMagpie(ttot,regi,enty)$(p_histEmiSector("2005",regi,"n2o","agriculture","process") AND (ttot.val ge 2005)) =
    pm_macBaseMagpie(ttot,regi,enty) *
    ( p_histEmiSector("2005",regi,"n2o","agriculture","process")/( 44 / 28) !! rescaling to Mt N (internal unit for N2O emissions)
* eurostat uses 298 to convert N2O to CO2eq
      /
      (sum(enty2$(sameas(enty,"n2ofertin") OR sameas(enty2,"n2ofertcr") OR sameas(enty2,"n2oanwstc") OR sameas(enty2,"n2oanwstm") OR sameas(enty2,"n2oanwstp")), pm_macBaseMagpie("2005",regi,enty2)) + p_macBaseExo("2005",regi,"n2oagwaste"))
    )
  ;
);
display pm_macBaseMagpie;

$ENDIF.scaleEmiHist

*** FS: calculate total bioenregy primary energy demand from last iteration
pm_demPeBio(ttot,regi) = 
  sum(en2en(enty,enty2,te)$(peBio(enty)), 
    vm_demPe.l(ttot,regi,enty,enty2,te))
;

!! all net negative co2luc
p_macBaseMagpieNegCo2(t,regi) = pm_macBaseMagpie(t,regi,"co2luc")$(pm_macBaseMagpie(t,regi,"co2luc") < 0);

p_agriEmiPhaseOut(t) = 0;
p_agriEmiPhaseOut("2025") = 0.25;
p_agriEmiPhaseOut("2030") = 0.5;
p_agriEmiPhaseOut("2035") = 0.75;
p_agriEmiPhaseOut(t)$(t.val ge 2040) = 1;

*** Rescale non-co2 base line emissions from agriculture 
pm_macBaseMagpie(t,regi,enty)$(emiMac2sector(enty,"agriculture","process","ch4") OR emiMac2sector(enty,"agriculture","process","n2o"))
  = (1-p_agriEmiPhaseOut(t)*c_BaselineAgriEmiRed)*pm_macBaseMagpie(t,regi,enty);
  
*** The N2O emissions generated during biomass production in agriculture (in MAgPIE)
*** are represented in REMIND by applying the n2obio emission factor (zero in coupled runs)
*** in q_macBase. In standaolne runs the resulting emissions need to be subtracted (see below)
*** from the exogenous emission baseline read from MAgPIE, since the baseline already implicitly 
*** includes the N2O emissions from biomass. In q_macBase in core/equations.gms the N2O 
*** emissions resulting from the actual biomass demand in REMIND are then added again. 

pm_macBaseMagpie(t,regi,"n2ofertin") = pm_macBaseMagpie(t,regi,"n2ofertin") - (p_efFossilFuelExtr(regi,"pebiolc","n2obio") * pm_pebiolc_demandmag(t,regi));
display pm_macBaseMagpie;

$IFTHEN.out "%cm_debug_preloop%" == "on" 
option limrow = 70;
option limcol = 70;
$ELSE.out
option limrow = 0;
option limcol = 0;
$ENDIF.out


*** load PE, SE, FE price parameters from reference gdx to have prices in time steps before cm_startyear
if (cm_startyear gt 2005,
execute_load "input_ref.gdx", pm_PEPrice, pm_SEPrice, pm_FEPrice;
);

*** EOF ./core/preloop.gms
