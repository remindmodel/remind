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
*** track `pm_actualbudgetco2(ttot)` over iterations
p_actualbudgetco2_iter(iteration,ttot)$( 2020 lt ttot.val) = pm_actualbudgetco2(ttot);

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
*NB* this is only relevant for reporting purposes. With reporting tranferred to R, the entire part will become obsolete.

loop ((ttot,regi), 

  if (sum(se2fe("seh2",entyFe,te), vm_demSe.l(ttot,regi,"seh2",entyFe,te)) ne 0, 
    p_share_seh2_s(ttot,regi) = 
      sum(se2fe("seh2","feh2s",te), vm_demSe.l(ttot,regi,"seh2","feh2s",te)) 
    / sum(se2fe("seh2", entyFe,  te), vm_demSe.l(ttot,regi,"seh2", entyFe,  te)); 
  else 
    p_share_seh2_s(ttot,regi) = NA;
  );

  if (sum(se2fe("seel",entyFe,te), vm_demSe.l(ttot,regi,"seel",entyFe,te)) ne 0, 
    p_share_seel_s(ttot,regi) = 
      sum(se2fe("seel","feels",te), vm_demSe.l(ttot,regi,"seel","feels",te)) 
    / sum(se2fe("seel", entyFe,  te), vm_demSe.l(ttot,regi,"seel", entyFe,  te)); 
  else
    p_share_seel_s(ttot,regi) = NA;
  );

  if (sum(se2fe(entySe,entyFe,te)$(sameas(entySe,"seliqfos") OR sameas(entySe,"seliqbio")),
        vm_demSe.l(ttot,regi,entySe,entyFe,te)) ne 0, 
    p_share_seliq_s(ttot,regi) = 
      ( sum(se2fe("seliqfos","fehos",te), vm_demSe.l(ttot,regi,"seliqfos","fehos",te)) + sum(se2fe("seliqbio","fehos",te), vm_demSe.l(ttot,regi,"seliqbio","fehos",te)) )
      / ( sum(se2fe("seliqfos",entyFe,te),  vm_demSe.l(ttot,regi,"seliqfos",entyFe,te)) + sum(se2fe("seliqbio",entyFe,te),  vm_demSe.l(ttot,regi,"seliqbio",entyFe,te)) )
    ;
  else
    p_share_seliq_s(ttot,regi) = NA;
  );

); 

DISPLAY  p_share_seliq_s, p_share_seh2_s, p_share_seel_s;


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
pm_share_CCS_CCO2(t,regi) = sum(teCCS2rlf(te,rlf), vm_co2CCS.l(t,regi,"cco2","ico2",te,rlf)) / (sum(teCCS2rlf(te,rlf), v_co2capture.l(t,regi,"cco2","ico2",te,rlf))+sm_eps);

*** emissions reporting helper parameters
o_emissions_bunkers(ttot,regi,emi)$(ttot.val ge 2005) = 
    sum(se2fe(enty,enty2,te),
        pm_emifac(ttot,regi,enty,enty2,te,emi)
        * vm_demFeSector.l(ttot,regi,enty,enty2,"trans","other")
    )*o_emi_conv(emi);

o_emissions(ttot,regi,emi)$(ttot.val ge 2005) = 
    sum(emiMkt, vm_emiAllMkt.l(ttot,regi,emi,emiMkt))*o_emi_conv(emi)
    - o_emissions_bunkers(ttot,regi,emi);

*** note! this still excludes industry CCS and CCU. To fix. 
o_emissions_energy(ttot,regi,emi)$(ttot.val ge 2005) = 
    sum(emiMkt, vm_emiTeMkt.l(ttot,regi,emi,emiMkt))*o_emi_conv(emi)
    - o_emissions_bunkers(ttot,regi,emi);

*** note! this still excludes industry CCS. To fix. 
o_emissions_energy_demand(ttot,regi,emi)$(ttot.val ge 2005) = 
    sum(sector2emiMkt(sector,emiMkt),
        sum(se2fe(enty,enty2,te),
            pm_emifac(ttot,regi,enty,enty2,te,emi)
            * vm_demFeSector.l(ttot,regi,enty,enty2,sector,emiMkt)
        )
    )*o_emi_conv(emi)
    - o_emissions_bunkers(ttot,regi,emi)
;

*** note! this still excludes industry CCS. To fix.
o_emissions_energy_demand_sector(ttot,regi,emi,sector)$(ttot.val ge 2005) =
    sum(emiMkt$sector2emiMkt(sector,emiMkt),
        sum(se2fe(enty,enty2,te),
            pm_emifac(ttot,regi,enty,enty2,te,emi) * vm_demFeSector.l(ttot,regi,enty,enty2,sector,emiMkt)
        )
    )*o_emi_conv(emi)
    +
   (sum(emiMacSector$(emiMac2sector(emiMacSector,"trans","process",emi)),
        vm_emiMacSector.l(ttot,regi,emiMacSector)
        )*o_emi_conv(emi)
        - o_emissions_bunkers(ttot,regi,emi)
    )$(sameas(sector,"trans"))
    +
    (sum(emiMacSector$(emiMac2sector(emiMacSector,"waste","process",emi)),
         vm_emiMacSector.l(ttot,regi,emiMacSector)
        )*o_emi_conv(emi)
    )$(sameas(sector,"waste"))
;

o_emissions_energy_extraction(ttot,regi,emi,entyPe)$(ttot.val ge 2005) =
***   emissions from non-conventional fuel extraction
    (
    ( sum(emi2fuelMine(emi,entyPe,rlf),      
           p_cint(regi,emi,entyPe,rlf)
         * vm_fuExtr.l(ttot,regi,entyPe,rlf)
         )$( c_cint_scen eq 1 )
     )
***   emissions from conventional fuel extraction
    + ( sum(pe2rlf(entyPe,rlf2),sum(enty2,      
         (pm_cintraw(enty2)
          * pm_fuExtrOwnCons(regi, enty2, entyPe) 
          * vm_fuExtr.l(ttot,regi,entyPe,rlf2)
         )$(pm_fuExtrOwnCons(regi, entyPe, enty2) gt 0)    
        ))
    )
    )*o_emi_conv(emi)
    +
    (sum(emiMacSector$(emiMac2sector("ch4coal","extraction","process",emi)),
         vm_emiMacSector.l(ttot,regi,emiMacSector)
        )*o_emi_conv(emi)
    )$(sameas(entyPe,"pecoal"))
    +
    (sum(emiMacSector$(emiMac2sector("ch4gas","extraction","process",emi)),
         vm_emiMacSector.l(ttot,regi,emiMacSector)
        )*o_emi_conv(emi)
    )$(sameas(entyPe,"pegas"))
    +
    (sum(emiMacSector$(emiMac2sector("ch4oil","extraction","process",emi)),
         vm_emiMacSector.l(ttot,regi,emiMacSector)
        )*o_emi_conv(emi)
    )$(sameas(entyPe,"peoil"))
;


o_emissions_energy_supply_gross(ttot,regi,emi)$(ttot.val ge 2005) =
    sum(pe2se(entyPe,entySe,te)$(pm_emifac(ttot,regi,entyPe,entySe,te,emi)>0),
         pm_emifac(ttot,regi,entyPe,entySe,te,emi)
         * vm_demPe.l(ttot,regi,entyPe,entySe,te)
    )*o_emi_conv(emi)
    +
    sum(entyPe, o_emissions_energy_extraction(ttot,regi,emi,entyPe))
;
    
o_emissions_energy_supply_gross_carrier(ttot,regi,emi,entySe)$(ttot.val ge 2005) =
    sum((entyPe,te)$(pe2se(entyPe,entySe,te) AND (pm_emifac(ttot,regi,entyPe,entySe,te,emi)>0)),
         pm_emifac(ttot,regi,entyPe,entySe,te,emi)
         * vm_demPe.l(ttot,regi,entyPe,entySe,te)
    )*o_emi_conv(emi)
    +
    (
    o_emissions_energy_extraction(ttot,regi,emi,"pecoal")
    )$(sameas(entySe,"sesofos"))
    +
    (
    o_emissions_energy_extraction(ttot,regi,emi,"pegas")
    )$(sameas(entySe,"segafos"))
    +
    (	
    o_emissions_energy_extraction(ttot,regi,emi,"peoil")
    )$(sameas(entySe,"seliqfos"))
;

o_emissions_energy_negative(ttot,regi,emi)$(ttot.val ge 2005) =
    (
     sum(pe2se(entyPe,entySe,te)$(pm_emifac(ttot,regi,entyPe,entySe,te,emi)<0),
         pm_emifac(ttot,regi,entyPe,entySe,te,emi)
         * vm_demPe.l(ttot,regi,entyPe,entySe,te)
    )
    +
    sum((ccs2Leak(enty,enty2,te,emi),teCCS2rlf(te,rlf)),
            pm_emifac(ttot,regi,enty,enty2,te,emi)
            * vm_co2CCS.l(ttot,regi,enty,enty2,te,rlf)
          )
***   Industry CCS emissions
    - sum(emiInd37_fuel,
          vm_emiIndCCS.l(ttot,regi,emiInd37_fuel)
        )$( sameas(emi,"co2") )
    )*o_emi_conv(emi)
;

o_emissions_industrial_processes(ttot,regi,emi)$(ttot.val ge 2005) =
    sum(emiMacSector$(emiMac2sector(emiMacSector,"indst","process",emi)),
        vm_emiMacSector.l(ttot,regi,emiMacSector)
    )*o_emi_conv(emi);

o_emissions_AFOLU(ttot,regi,emi)$(ttot.val ge 2005) =
    sum(emiMacSector$(emiMac2sector(emiMacSector,"agriculture","process",emi) OR emiMac2sector(emiMacSector,"lulucf","process",emi)),
        vm_emiMacSector.l(ttot,regi,emiMacSector)
    )*o_emi_conv(emi);

o_emissions_CDRmodule(ttot,regi,emi)$(ttot.val ge 2005) =
   vm_emiCdr.l(ttot,regi,emi)*o_emi_conv(emi)
;

o_emissions_other(ttot,regi,emi)$(ttot.val ge 2005) =
    pm_emiExog(ttot,regi,emi)*o_emi_conv(emi)
;

***Carbon Management|Carbon Capture (Mt CO2/yr)
o_capture(ttot,regi,"co2")$(ttot.val ge 2005) =
    sum(teCCS2rlf(te,rlf),
        v_co2capture.l(ttot,regi,"cco2","ico2","ccsinje",rlf)
    )*o_emi_conv("co2");

***Carbon Management|Carbon Capture|Process|Energy (Mt CO2/yr)
o_capture_energy(ttot,regi,"co2")$(ttot.val ge 2005) =
    sum(emi2te(enty3,enty4,te2,"cco2"),
        vm_emiTeDetail.l(ttot,regi,enty3,enty4,te2,"cco2")
    )*o_emi_conv("co2");

***Carbon Management|Carbon Capture|Process|Energy|Electricity (Mt CO2/yr)
o_capture_energy_elec(ttot,regi,"co2")$(ttot.val ge 2005) =
    sum(emi2te(enty3,enty4,te2,"cco2")$(sameas(enty4,"seel")),
        vm_emiTeDetail.l(ttot,regi,enty3,enty4,te2,"cco2")
    )*o_emi_conv("co2");

***Carbon Management|Carbon Capture|Process|Energy|Other (Mt CO2/yr)
o_capture_energy_other(ttot,regi,"co2")$(ttot.val ge 2005) =
    sum(emi2te(enty3,enty4,te2,"cco2")$(NOT(sameas(enty4,"seel"))),
        vm_emiTeDetail.l(ttot,regi,enty3,enty4,te2,"cco2")
    )*o_emi_conv("co2");

***Carbon Management|Carbon Capture|Process|Direct Air Capture (Mt CO2/yr)
o_capture_cdr(ttot,regi,"co2")$(ttot.val ge 2005) =
    sum(teCCS2rlf("ccsinje",rlf),
      vm_co2capture_cdr.l(ttot,regi,"cco2","ico2","ccsinje",rlf)
    )*o_emi_conv("co2");

***Carbon Management|Carbon Capture|Process|Industrial Processes (Mt CO2/yr)
o_capture_industry(ttot,regi,"co2")$(ttot.val ge 2005) =
    sum(emiInd37,
      vm_emiIndCCS.l(ttot,regi,emiInd37)
    )*o_emi_conv("co2")
;

***Carbon Management|Carbon Capture|Primary Energy|Biomass (Mt CO2/yr)
o_capture_energy_bio(ttot,regi,"co2")$(ttot.val ge 2005) =
    sum(enty3$peBio(enty3),
        sum(emi2te(enty3,enty4,te2,"cco2"),
            vm_emiTeDetail.l(ttot,regi,enty3,enty4,te2,"cco2")
        )
    )*o_emi_conv("co2");

***Carbon Management|Carbon Capture|Primary Energy|Fossil (Mt CO2/yr)
o_capture_energy_fos(ttot,regi,"co2")$(ttot.val ge 2005) =
    sum(enty3$(NOT(peBio(enty3))),
        sum(emi2te(enty3,enty4,te2,"cco2"),
            vm_emiTeDetail.l(ttot,regi,enty3,enty4,te2,"cco2")
        )
    )*o_emi_conv("co2");

***Carbon Management|CCU (Mt CO2/yr)
o_carbon_CCU(ttot,regi,"co2")$(ttot.val ge 2005) =
    sum(teCCU2rlf(te2,rlf),
        vm_co2CCUshort.l(ttot,regi,"cco2","ccuco2short",te2,rlf)
    )*o_emi_conv("co2");

***Carbon Management|Land Use (Mt CO2/yr)
o_carbon_LandUse(ttot,regi,"co2")$(ttot.val ge 2005) =
    vm_emiMacSector.l(ttot,regi,"co2luc")
    *o_emi_conv("co2");

***Carbon Management|Underground Storage (Mt CO2/yr)
o_carbon_underground(ttot,regi,"co2")$(ttot.val ge 2005) =
    sum(teCCS2rlf(te,rlf), 
         vm_co2CCS.l(ttot,regi,"cco2","ico2",te,rlf)
    )*o_emi_conv("co2") 	
;
    
***Carbon Management|Carbon Re-emitted (Mt CO2/yr)
o_carbon_reemitted(ttot,regi,"co2")$(ttot.val ge 2005) =
     v_co2capturevalve.l(ttot,regi)	
     *o_emi_conv("co2") 	
;

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

*** EOF ./core/postsolve.gms
