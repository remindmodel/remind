*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./core/preloop.gms

loop ((t,counter),
if ( pm_dt(t) eq 2 * counter.val,
pm_cumDeprecFactor_old(t,regi,in)$(ppfKap(in) OR in_putty(in)) 
=   ((1 - pm_delta_kap(regi,in)) ** (pm_dt(t)/2 )
      - (1 - pm_delta_kap(regi,in)) ** (pm_dt(t) ))
     /  pm_delta_kap(regi,in)
    ;

pm_cumDeprecFactor_new(t,regi,in)$(ppfKap(in) OR in_putty(in)) 
=   ( 1 
     - (1 - pm_delta_kap(regi,in)) ** (pm_dt(t)/2)
      )
     /  pm_delta_kap(regi,in)
    ;

);
if ( pm_dt(t) eq (2 * counter.val -1),
pm_cumDeprecFactor_old(t,regi,in)$(ppfKap(in) OR in_putty(in)) 
=   ((1 - pm_delta_kap(regi,in)) ** (pm_dt(t)/2 - 0.5)
      - (1 - pm_delta_kap(regi,in)) ** (pm_dt(t)))
     /  pm_delta_kap(regi,in)
    - 1/2 * (1 - pm_delta_kap(regi,in)) ** (pm_dt(t)/2 - 0.5 ) 
    ;

pm_cumDeprecFactor_new(t,regi,in)$(ppfKap(in) OR in_putty(in)) 
=   ( 1 
     - (1 - pm_delta_kap(regi,in)) ** (pm_dt(t)/2 - 0.5 + 1)
      )
     /  pm_delta_kap(regi,in)
    - 1/2 * (1 - pm_delta_kap(regi,in)) ** (pm_dt(t)/2 - 0.5) 
    ;
    
);
); 
display "test Deprec", pm_cumDeprecFactor_new,pm_cumDeprecFactor_old;

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


*** EOF ./core/preloop.gms
