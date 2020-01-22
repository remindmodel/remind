*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
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
vm_Xport.l(ttot,regi,tradePe)       = 0;
vm_capDistr.l(t,regi,te,rlf)          = 0;
vm_cap.l(t,regi,te,rlf)              = 0;
vm_fuExtr.l(ttot,regi,"pebiolc","1")$(ttot.val ge 2005)  = 0;
vm_pebiolc_price.l(ttot,regi)$(ttot.val ge 2005)         = 0;
  
*** overwrite default targets with gdx values if wanted
Execute_Loadpoint 'input' p_emi_budget1_gdx = sm_budgetCO2eqGlob;
Execute_Loadpoint 'input' vm_demPe.l = vm_demPe.l;
Execute_Loadpoint 'input' q_balPe.m = q_balPe.m;
Execute_Loadpoint 'input' qm_budget.m = qm_budget.m;
Execute_Loadpoint 'input' pm_pvpRegi = pm_pvpRegi;
Execute_Loadpoint 'input' pm_pvp = pm_pvp;
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

$ifthen setGlobal c_scaleEmiHistorical
*re-scale MAgPie reference emissions to be inline with eurostat data (MagPie overestimates non-CO2 GHG emissions by a factor of 50% more)
display p_macBaseMagpie;
loop(enty$(sameas(enty,"ch4rice") OR sameas(enty,"ch4animals") OR sameas(enty,"ch4anmlwst")),
  p_macBaseMagpie(ttot,regi,enty)$(p_histEmiSector("2005",regi,"ch4","agriculture","process") AND (ttot.val ge 2005)) =
   p_macBaseMagpie(ttot,regi,enty) *
    ( (p_histEmiSector("2005",regi,"ch4","agriculture","process")+p_histEmiSector("2005",regi,"ch4","lulucf","process")) !!no rescaling needed - REMIND-internal unit is Mt CH4
      /
      (sum(enty2$(sameas(enty2,"ch4rice") OR sameas(enty2,"ch4animals") OR sameas(enty2,"ch4anmlwst")), p_macBaseMagpie("2005",regi,enty2)) + p_macBaseExo("2005",regi,"ch4agwaste"))
    )
  ;
);
loop(enty$(sameas(enty,"n2ofertin") OR sameas(enty,"n2ofertcr") OR sameas(enty,"n2oanwstc") OR sameas(enty,"n2oanwstm") OR sameas(enty,"n2oanwstp")),
  p_macBaseMagpie(ttot,regi,enty)$(p_histEmiSector("2005",regi,"n2o","agriculture","process") AND (ttot.val ge 2005)) =
    p_macBaseMagpie(ttot,regi,enty) *
    ( p_histEmiSector("2005",regi,"n2o","agriculture","process")/( 44 / 28) !! rescaling to Mt N (internal unit for N2O emissions)
* eurostat uses 298 to convert N2O to CO2eq
      /
      (sum(enty2$(sameas(enty,"n2ofertin") OR sameas(enty2,"n2ofertcr") OR sameas(enty2,"n2oanwstc") OR sameas(enty2,"n2oanwstm") OR sameas(enty2,"n2oanwstp")), p_macBaseMagpie("2005",regi,enty2)) + p_macBaseExo("2005",regi,"n2oagwaste"))
    )
  ;
);
display p_macBaseMagpie;
$endif


*** EOF ./core/preloop.gms
