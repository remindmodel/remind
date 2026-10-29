*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./core/postsolve.gms

*------------------------------- compute cumulative CO2 emissions from 2020 -----------------------------------

*** `pm_actualbudgetco2(ttot)` includes emissions from 2020 to `ttot` (inclusive).
pm_actualbudgetco2(ttot)$( 2020 lt ttot.val )
  = sum((regi,ttot2)$( 2020 le ttot2.val AND ttot2.val le ttot.val ),
      vm_emiAll.l(ttot2,regi,"co2")
      * ( (0.5 + pm_ts(ttot2) / 2)$( ttot2.val eq 2020 ) !! second half of the 2020 period (mid 2020 - end 2022) plus 0.5 to account fo beginning 2020 - mid 2020  
        + (pm_ts(ttot2))$( 2020 lt ttot2.val AND ttot2.val lt ttot.val ) !! entire middle periods
        + ((pm_ttot_val(ttot) - pm_ttot_val(ttot-1)) / 2 + 0.5)$(ttot2.val eq ttot.val ) !! first half of the final period plus 0.5 to account fo mid - end of final year
        )
    )
  * sm_c_2_co2;

*** `pm_actualbudgetco2eqRegi(ttot, regi)` includes emissions from 2020 to `ttot` (inclusive).
pm_actualbudgetco2eqRegi(ttot,regi)$( 2020 lt ttot.val )
  = sum((ttot2)$( 2020 le ttot2.val AND ttot2.val le ttot.val ),
      ((vm_emiAll.l(ttot2,regi,"co2") - vm_emiMacSector.l(ttot2,regi,"co2luc")$(c_budgetscen gt 2 AND c_budgetscen ne 4)) !! co2 emissions including or excluding land-use co2 emissions
      + (sm_tgn_2_pgc * vm_emiAll.l(ttot2, regi, "n2o") + sm_tgch4_2_pgc * vm_emiAll.l(ttot2,regi, "ch4"))$(c_budgetscen le 3)  !! include other GHG emissions if c_budgetscen is 1, 2 or 3
      - sum(se2fe(enty,enty2,te),     !! subtract bunker emissions if cm_bunkerscen is eq 3 or 6
        pm_emifac(ttot2,regi,enty,enty2,te,"co2")
        * vm_demFeSector.l(ttot2,regi,enty,enty2,"trans","other"))$(c_budgetscen eq 3 OR c_budgetscen eq 6))
      * ( (0.5 + pm_ts(ttot2) / 2)$( ttot2.val eq 2020 ) !! second half of the 2020 period (mid 2020 - end 2022) plus 0.5 to account fo beginning 2020 - mid 2020  
        + (pm_ts(ttot2))$( 2020 lt ttot2.val AND ttot2.val lt ttot.val ) !! entire middle periods
        + ((pm_ttot_val(ttot) - pm_ttot_val(ttot-1)) / 2 + 0.5)$(ttot2.val eq ttot.val ) !! first half of the final period plus 0.5 to account fo mid - end of final year
        )
    )
  * sm_c_2_co2;

*** track `pm_actualbudgetco2(ttot)` over iterations
p_actualbudgetco2_iter(iteration,ttot)$( 2020 lt ttot.val) = pm_actualbudgetco2(ttot);
p_actualbudgetco2eqRegi_iter(iteration,ttot,regi)$( 2020 lt ttot.val) = pm_actualbudgetco2eqRegi(ttot,regi);

*** track pm_taxCO2eq over iterations - pm_taxCO2eq is adjusted in 45_carbonprice/functionalForm/postsolve.gms and consequently pm_taxCO2eq_iter gets overwritten there
pm_taxCO2eq_iter(iteration,t,regi) = pm_taxCO2eq(t,regi);

*-------------------------------calculate regional permit prices-----------------------------------

*** saving pm_taxemiMkt used in this iteration
pm_taxemiMkt_iteration(iteration,ttot,regi,emiMkt) = pm_taxemiMkt(ttot,regi,emiMkt);

if( (cm_emiscen eq 6), 
$ifthen.neg %optimization% == 'negishi'     
    pm_taxCO2eqSum(ttot,regi) = abs((abs(q_co2eq.m(ttot,regi)) / pm_ts(ttot)) / (pm_pvp(ttot,"good") + sm_eps));
$else.neg
    pm_taxCO2eqSum(ttot,regi) = abs( abs(q_co2eq.m(ttot,regi)) / (abs(qm_budget.m(ttot,regi))+ sm_eps) );
$endif.neg 
   elseif (cm_emiscen eq 1),  !! even in a BAU scenario without other climate policies, the 2010/2015/2020 CO2 prices should be reported (that still needs to be fixed, I guess, maybe by adding the historic prices to the 45/carbonprice/off variation
    pm_taxCO2eqSum(ttot,regi)$(ttot.val < 2025) = pm_taxCO2eq(ttot,regi); 
);

***-----------------------------------------------
*RP* calculate shares of SE used for different FEs
***-----------------------------------------------

*LB* update parameter that are used for variables during the run
pm_gdp_gdx(ttot,regi)$(ttot.val ge 2005)    = vm_cesIO.l(ttot,regi,"inco");
p_inv_gdx(ttot,regi)$(ttot.val ge 2005)     = vm_invMacro.l(ttot,regi,"kap");

pm_GDPGross(ttot,regi)$( (pm_SolNonInfes(regi) eq 1) ) =  vm_cesIO.l(ttot,regi,"inco");


*interpolate GDP
loop(ttot$(ttot.val ge 2005),
    loop(tall$(pm_tall_2_ttot(tall, ttot)),
        pm_GDPGross(tall,regi) =
       (1- pm_interpolWeight_ttot_tall(tall)) * pm_GDPGross(ttot,regi)
       + pm_interpolWeight_ttot_tall(tall) * pm_GDPGross(ttot+1,regi);
));

*** assume GDP is flat from 2150 on (only enters damage calculations in the far future)
pm_GDPGross(tall,regi)$(tall.val ge 2150) = pm_GDPGross("2149",regi); 


*** CG: calculate marginal adjustment cost for capacity investment: d(vm_costInvTeAdj) / d(vm_deltaCap)  !!!! the closed formula only holds when v_adjFactorGlob.fx(t,regi,te) = 0;
o_margAdjCostInv(ttot,regi,te)$(ttot.val ge max(2010, cm_startyear) AND teAdj(te)) =  vm_costTeCapital.l(ttot,regi,te) * p_adj_coeff(ttot,regi,te)
    * 2 * (sum(te2rlf(te,rlf), vm_deltaCap.l(ttot,regi,te,rlf)) - sum(te2rlf(te,rlf), vm_deltaCap.l(ttot-1,regi,te,rlf)))
    / power((pm_ttot_val(ttot) - pm_ttot_val(ttot-1)), 2)
    / (sum(te2rlf(te,rlf), vm_deltaCap.l(ttot-1,regi,te,rlf)) + p_adj_seed_reg(ttot,regi) * p_adj_seed_te(ttot,regi,te)
      + p_adj_deltacapoffset("2010",regi,te)$(ttot.val eq 2010) + p_adj_deltacapoffset("2015",regi,te)$(ttot.val eq 2015)
      + p_adj_deltacapoffset("2020",regi,te)$(ttot.val eq 2020) + p_adj_deltacapoffset("2025",regi,te)$(ttot.val eq 2025)
    )
    * (1 + 0.02/pm_ies(regi) + pm_prtp(regi)) ** (pm_ts(ttot) / 2)
;

*** CG: calculate average adjustment cost for capacity investment: vm_costInvTeAdj / vm_deltaCap
o_avgAdjCostInv(ttot,regi,te)$(ttot.val ge 2010 AND teAdj(te) AND
                              (vm_costInvTeAdj.l(ttot,regi,te) eq 0 OR sum(te2rlf(te,rlf),vm_deltaCap.l(ttot,regi,te,rlf)) eq 0))
    = 0;
o_avgAdjCostInv(ttot,regi,te)$(ttot.val ge 2010 AND teAdj(te) AND (sum(te2rlf(te,rlf),vm_deltaCap.l(ttot,regi,te,rlf)) ne 0 ))
    = vm_costInvTeAdj.l(ttot,regi,te) / sum(te2rlf(te,rlf),vm_deltaCap.l(ttot,regi,te,rlf));
*** and ratio between average adjCost and direct investment cost
o_avgAdjCost_2_InvCost_ratioPc(ttot,regi,te)$(vm_costInvTeDir.l(ttot,regi,te) ge 1E-22) = vm_costInvTeAdj.l(ttot,regi,te)/vm_costInvTeDir.l(ttot,regi,te) * 100;

*** calculation of PE and SE Prices (useful for internal use and reporting purposes)
pm_SEPrice(ttot,regi,entySe)$(abs (qm_budget.m(ttot,regi)) gt sm_eps AND (NOT (sameas(entySe,"seel")))) = 
       q_balSe.m(ttot,regi,entySe) / qm_budget.m(ttot,regi);

pm_PEPrice(ttot,regi,entyPe)$(abs (qm_budget.m(ttot,regi)) gt sm_eps) = 
       q_balPe.m(ttot,regi,entyPe) / qm_budget.m(ttot,regi);

*** calculate share of stored CO2 from captured CO2
pm_share_CCS_CCO2(t,regi) = sum(teCCS2rlf(te,rlf), vm_co2CCS.l(t,regi,"cco2","ico2",te,rlf)) / (v_co2capture.l(t,regi)+sm_eps);


*CG**ML*: capital interest rate
p_r(ttot,regi)$(ttot.val gt 2005 and ttot.val le 2130)
    = 1 / pm_ies(regi) * (( (vm_cons.l(ttot+1,regi)/pm_pop(ttot+1,regi)) /
      (vm_cons.l(ttot-1,regi)/pm_pop(ttot-1,regi)) )
      ** (1 / ( pm_ttot_val(ttot+1)- pm_ttot_val(ttot-1))) - 1) + pm_prtp(regi)
;

*** CG: growth rate after 2100 is very small (0.02 instead of around 0.05) due to various artefact, we simply set interest rates to 0.05 after 2100
p_r(ttot,regi)$(ttot.val gt 2100) = 0.05;

***------------ FE prices ----------------------
*** calculation of FE Prices including sector specific and energy source information
p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe,entyFe,sector,emiMkt)$(abs (qm_budget.m(t,regi)) gt sm_eps) =
  q_balFeAfterTax.m(t,regi,entySe,entyFe,sector,emiMkt) / qm_budget.m(t,regi);

*** marginal prices of aggregates equal to minimal non-zero marginal price of full equation marginal
loop((t,regi,entySe,entyFe,sector,emiMkt)$(sefe(entySe,entyFe) AND sector2emiMkt(sector,emiMkt) AND entyFe2Sector(entyFe,sector)),

*** initialize prices
  p_FEPrice_by_Sector_EmiMkt(t,regi,entyFe,sector,emiMkt) = 0;
  pm_FEPrice_by_SE_Sector(t,regi,entySe,entyFe,sector)    = 0;
  p_FEPrice_by_SE_EmiMkt(t,regi,entySe,entyFe,emiMkt)     = 0;
  p_FEPrice_by_SE(t,regi,entySe,entyFe)                   = 0;
  p_FEPrice_by_Sector(t,regi,entyFe,sector)               = 0;
  p_FEPrice_by_EmiMkt(t,regi,entyFe,emiMkt)               = 0;
  p_FEPrice_by_FE(t,regi,entyFe)                          = 0;

*** lower level marginal price is equal to non-zero, non-eps minimal price at higher level 
  loop(entySe2, 
    p_FEPrice_by_Sector_EmiMkt(t,regi,entyFe,sector,emiMkt)$(
      (p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe2,entyFe,sector,emiMkt) > EPS) 
      AND
      ( (p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe2,entyFe,sector,emiMkt) < p_FEPrice_by_Sector_EmiMkt(t,regi,entyFe,sector,emiMkt))
        OR (p_FEPrice_by_Sector_EmiMkt(t,regi,entyFe,sector,emiMkt) eq 0)
      ))
      = p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe2,entyFe,sector,emiMkt);
  );

  loop(emiMkt2, 
    pm_FEPrice_by_SE_Sector(t,regi,entySe,entyFe,sector)$(
      (p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe,entyFe,sector,emiMkt2) > EPS) 
      AND
      ( (p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe,entyFe,sector,emiMkt2) < pm_FEPrice_by_SE_Sector(t,regi,entySe,entyFe,sector))
        OR (pm_FEPrice_by_SE_Sector(t,regi,entySe,entyFe,sector) eq 0)
      )) 
      = p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe,entyFe,sector,emiMkt2);
  );

  loop(sector2,
    p_FEPrice_by_SE_EmiMkt(t,regi,entySe,entyFe,emiMkt)$(
      (p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe,entyFe,sector2,emiMkt) > EPS) 
      AND
      ( (p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe,entyFe,sector2,emiMkt) < p_FEPrice_by_SE_EmiMkt(t,regi,entySe,entyFe,emiMkt))
        OR (p_FEPrice_by_SE_EmiMkt(t,regi,entySe,entyFe,emiMkt) eq 0)
      )) 
      = p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe,entyFe,sector2,emiMkt);
  );

  loop((sector2,emiMkt2)$sector2emiMkt(sector2,emiMkt2), 
    p_FEPrice_by_SE(t,regi,entySe,entyFe)$(
      (p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe,entyFe,sector2,emiMkt2) > EPS) 
      AND 
      ( (p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe,entyFe,sector2,emiMkt2) < p_FEPrice_by_SE(t,regi,entySe,entyFe))
        OR (p_FEPrice_by_SE(t,regi,entySe,entyFe) eq 0)
      )) 
      = p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe,entyFe,sector2,emiMkt2);
  );

  loop((entySe2,emiMkt2), !! take minimal non-zero price for aggregation if carrier has no quantity in the model
    p_FEPrice_by_Sector(t,regi,entyFe,sector)$(
      (p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe2,entyFe,sector,emiMkt2) > EPS) 
      AND 
      ( (p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe2,entyFe,sector,emiMkt2) < p_FEPrice_by_Sector(t,regi,entyFe,sector))
        OR (p_FEPrice_by_Sector(t,regi,entyFe,sector) eq 0)
      )) 
      = p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe2,entyFe,sector,emiMkt2);
  );

  loop((entySe2,sector2), !! take minimal non-zero price for aggregation if carrier has no quantity in the model
    p_FEPrice_by_EmiMkt(t,regi,entyFe,emiMkt)$(
      (p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe2,entyFe,sector2,emiMkt) > EPS) 
      AND 
      ( (p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe2,entyFe,sector2,emiMkt) < p_FEPrice_by_EmiMkt(t,regi,entyFe,emiMkt))
        OR (p_FEPrice_by_EmiMkt(t,regi,entyFe,emiMkt) eq 0)
      )) 
      = p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe2,entyFe,sector2,emiMkt);
  );

  loop((entySe2,sector2,emiMkt2)$(sefe(entySe2,entyFe) AND sector2emiMkt(sector2,emiMkt2)), !! take minimal non-zero price for aggregation if carrier has no quantity in the model
    p_FEPrice_by_FE(t,regi,entyFe)$(
      (p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe2,entyFe,sector2,emiMkt2) > EPS) 
      AND 
      ((p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe2,entyFe,sector2,emiMkt2) < p_FEPrice_by_FE(t,regi,entyFe))
        OR (p_FEPrice_by_FE(t,regi,entyFe) eq 0)
      )) 
      = p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe2,entyFe,sector2,emiMkt2);
  );

);

p_FEPrice_by_SE_Sector_EmiMkt_iter(iteration,t,regi,entySe,entyFe,sector,emiMkt) = p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe,entyFe,sector,emiMkt);
p_FEPrice_by_Sector_EmiMkt_iter(iteration,t,regi,entyFe,sector,emiMkt) = p_FEPrice_by_Sector_EmiMkt(t,regi,entyFe,sector,emiMkt);
p_FEPrice_by_SE_Sector_iter(iteration,t,regi,entySe,entyFe,sector) = pm_FEPrice_by_SE_Sector(t,regi,entySe,entyFe,sector);
p_FEPrice_by_SE_EmiMkt_iter(iteration,t,regi,entySe,entyFe,emiMkt) = p_FEPrice_by_SE_EmiMkt(t,regi,entySe,entyFe,emiMkt);
p_FEPrice_by_SE_iter(iteration,t,regi,entySe,entyFe) = p_FEPrice_by_SE(t,regi,entySe,entyFe);
p_FEPrice_by_Sector_iter(iteration,t,regi,entyFe,sector) = p_FEPrice_by_Sector(t,regi,entyFe,sector);
p_FEPrice_by_EmiMkt_iter(iteration,t,regi,entyFe,emiMkt) = p_FEPrice_by_EmiMkt(t,regi,entyFe,emiMkt);
p_FEPrice_by_FE_iter(iteration,t,regi,entyFe) = p_FEPrice_by_FE(t,regi,entyFe);

*** Track demand for purpose-grown ligno-cellulosic biomass across iterations
o_vm_pebiolc_price_iter(iteration,ttot,regi)  = vm_pebiolc_price.l(ttot,regi);
o_vm_fuExtr_pebiolc_iter(iteration,ttot,regi) = vm_fuExtr.l(ttot,regi,"pebiolc","1");
o_PEDem_Bio_ECrops_iter(iteration,ttot,regi) = vm_fuExtr.l(ttot,regi,"pebiolc","1") + (1 - pm_costsPEtradeMp(regi,"pebiolc")) * vm_Mport.l(ttot,regi,"pebiolc") - vm_Xport.l(ttot,regi,"pebiolc");
o_vm_emiMacSector_co2luc_iter(iteration,ttot,regi) = vm_emiMacSector.l(ttot,regi,"co2luc");

*** track CES tree and energy services over iterations
loop(ttot$(ttot.val ge 2005),
  o_vm_cesIO_iter(ttot,regi,in,iteration) = vm_cesIO.l(ttot,regi,in) ;
  loop(entyFe2Sector(entyFe,"trans"),
    o_vm_demFeForEs_iter(ttot,regi,entyFe,esty,teEs,iteration)$fe2es(entyFe,esty,teEs) = vm_demFeForEs.l(ttot,regi,entyFe,esty,teEs);
    o_v_prodEs_iter(ttot,regi,entyFe,esty,teEs,iteration)$fe2es(entyFe,esty,teEs) = v_prodEs.l(ttot,regi,entyFe,esty,teEs);
  );
);

*** track parameters read in from edgeTransport over iterations
if(edgeTransportIter(iteration),
  loop(ttot$(ttot.val ge 2005),
    o_pm_esCapCost_iter(ttot,regi,teEs_dyn35,iteration)                  = pm_esCapCost(ttot,regi,teEs_dyn35);
    o_pm_fe2es_iter(ttot,regi,teEs_dyn35,iteration)                      = pm_fe2es(ttot,regi,teEs_dyn35);
    o_pm_shFeCes_iter(ttot,regi,entyFe,ppfen_dyn35,teEs_dyn35,iteration) = pm_shFeCes(ttot,regi,entyFe,ppfen_dyn35,teEs_dyn35);
  );
); 


*** EOF ./core/postsolve.gms
