*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCarbonPrice/postsolve.gms

***---------------------------------------------------------------------------
*** Auxiliar parameters:
***---------------------------------------------------------------------------

*** net CO2 per Mkt (including bunkers and LULUCF)
p47_emiTargetMkt(ttot,regi,emiMktExt,"netCO2") = 
  sum(emiMkt$emiMktGroup(emiMktExt,emiMkt), vm_emiAllMkt.l(ttot,regi,"co2",emiMkt) );

*** net CO2 per Mkt without bunkers 
p47_emiTargetMkt(ttot,regi,emiMktExt,"netCO2_noBunkers") =
  p47_emiTargetMkt(ttot,regi,emiMktExt,"netCO2")
  - (
    sum(se2fe(enty,enty2,te),
      pm_emifac(ttot,regi,enty,enty2,te,"co2")
      * vm_demFeSector.l(ttot,regi,enty,enty2,"trans","other")
      )
  )$(sameas(emiMktExt,"other") or sameas(emiMktExt,"all"))
;

*** net CO2 per Mkt without bunkers and without LULUCF
p47_emiTargetMkt(ttot,regi, emiMktExt,"netCO2_noLULUCF_noBunkers") = 
  p47_emiTargetMkt(ttot,regi,emiMktExt,"netCO2_noBunkers")
  - (
    sum(emiMacSector$emiMac2sector(emiMacSector,"lulucf","process","co2"),
      vm_emiMacSector.l(ttot,regi,emiMacSector)
    )
  )$(sameas(emiMktExt,"other") or sameas(emiMktExt,"all"));

*** gross energy CO2 emissions without BECCS and without bunkers. note: industry BECCS is still missing from this variable, to be added in the future
p47_emiTargetMkt(ttot,regi, emiMktExt,"grossEnCO2_noBunkers") =
  sum(emiMkt$emiMktGroup(emiMktExt,emiMkt),
    vm_emiTeMkt.l(ttot,regi,"co2",emiMkt) !! total net CO2 energy CO2 (w/o DAC accounting of synfuels) 
    + ( vm_emiCdrTeDetail.l(ttot,regi,"dac")* (1-pm_share_CCS_CCO2(ttot,regi)) )$(sameas(emiMkt,"ETS") or sameas(emiMktExt,"all"))  !! DAC accounting of synfuels: remove CO2 captured by DAC and used (which is negative) from vm_emiTe which is not stored in vm_co2CCS
    + sum(emi2te(enty,enty2,te,enty3)$(teBio(te) AND teCCS(te) AND sameAs(enty3,"cco2")), vm_emiTeDetailMkt.l(ttot,regi,enty,enty2,te,enty3,emiMkt)) * pm_share_CCS_CCO2(ttot,regi) !! add pe2se BECCS
    + sum( (entySe,entyFe,secInd37)$(NOT (entySeFos(entySe))), pm_IndstCO2Captured(ttot,regi,entySe,entyFe,secInd37,emiMkt)) * pm_share_CCS_CCO2(ttot,regi) !! add industry CCS with hydrocarbon fuels from biomass (industry BECCS) or synthetic origin
    - (sum(se2fe(enty,enty2,te), pm_emifac(ttot,regi,enty,enty2,te,"co2")*vm_demFeSector.l(ttot,regi,enty,enty2,"trans","other")))$(sameas(emiMktExt,"other") or sameas(emiMktExt,"all")) !! remove bunker emissions
  )
;

*** net GHG per Mkt (including F-gases, bunkers and LULUCF)
p47_emiTargetMkt(ttot,regi,emiMktExt,"netGHG") = 
  sum(emiMkt$emiMktGroup(emiMktExt,emiMkt), 
    vm_emiAllMkt.l(ttot,regi,"co2",emiMkt)
    + vm_emiAllMkt.l(ttot,regi,"n2o",emiMkt)*sm_tgn_2_pgc 
    + vm_emiAllMkt.l(ttot,regi,"ch4",emiMkt)*sm_tgch4_2_pgc
  )
  + ( vm_emiFgas.l(ttot,regi,"emiFgasTotal")/(1000*sm_c_2_co2) )$(sameas(emiMktExt,"other") or sameas(emiMktExt,"all"));

*** net GHG per Mkt without LULUCF
p47_emiTargetMkt(ttot,regi, emiMktExt,"netGHG_noLULUCF") =
  p47_emiTargetMkt(ttot,regi,emiMktExt,"netGHG")
  - (
      sum(emiMacSector$emiMac2sector(emiMacSector,"lulucf","process","co2"),
        vm_emiMacSector.l(ttot,regi,emiMacSector)
      )
      + sum(emiMacSector$emiMac2sector(emiMacSector,"lulucf","process","ch4"),
        vm_emiMacSector.l(ttot,regi,emiMacSector)*sm_tgch4_2_pgc
      )
      + sum(emiMacSector$emiMac2sector(emiMacSector,"lulucf","process","n2o"),
        vm_emiMacSector.l(ttot,regi,emiMacSector)*sm_tgn_2_pgc
      )
  )$(sameas(emiMktExt,"other") or sameas(emiMktExt,"all"));

*** net GHG per Mkt without bunkers
p47_emiTargetMkt(ttot,regi, emiMktExt,"netGHG_noBunkers") =
  p47_emiTargetMkt(ttot,regi,emiMktExt,"netGHG")
  - (
    sum(se2fe(enty,enty2,te),
    (pm_emifac(ttot,regi,enty,enty2,te,"co2")
    + pm_emifac(ttot,regi,enty,enty2,te,"n2o")*sm_tgn_2_pgc
    + pm_emifac(ttot,regi,enty,enty2,te,"ch4")*sm_tgch4_2_pgc)
     * vm_demFeSector.l(ttot,regi,enty,enty2,"trans","other")) 
  )$(sameas(emiMktExt,"other") or sameas(emiMktExt,"all"))
;

*** net GHG per Mkt without bunkers and without LULUCF
p47_emiTargetMkt(ttot,regi, emiMktExt,"netGHG_noLULUCF_noBunkers") = 
  p47_emiTargetMkt(ttot,regi, emiMktExt,"netGHG_noLULUCF")
- (
    sum(se2fe(enty,enty2,te),
    (pm_emifac(ttot,regi,enty,enty2,te,"co2")
    + pm_emifac(ttot,regi,enty,enty2,te,"n2o")*sm_tgn_2_pgc
    + pm_emifac(ttot,regi,enty,enty2,te,"ch4")*sm_tgch4_2_pgc)
     * vm_demFeSector.l(ttot,regi,enty,enty2,"trans","other")) 
  )$(sameas(emiMktExt,"other") or sameas(emiMktExt,"all"))
;

*** net CO2 per Mkt with Grassi LULUCF shift
p47_emiTargetMkt(ttot,regi, emiMktExt,"netCO2_LULUCFGrassi") =
  p47_emiTargetMkt(ttot,regi, emiMktExt,"netCO2")
  - ( p47_LULUCFEmi_GrassiShift(ttot,regi) )$(sameas(emiMktExt,"other") or sameas(emiMktExt,"all"));

*** net CO2 per Mkt without bunkers and with Grassi LULUCF shift
p47_emiTargetMkt(ttot,regi, emiMktExt,"netCO2_LULUCFGrassi_noBunkers") =
  p47_emiTargetMkt(ttot,regi, emiMktExt,"netCO2_noBunkers")
  - ( p47_LULUCFEmi_GrassiShift(ttot,regi) )$(sameas(emiMktExt,"other") or sameas(emiMktExt,"all"));

*** net GHG per Mkt with Grassi LULUCF shift
p47_emiTargetMkt(ttot,regi, emiMktExt,"netGHG_LULUCFGrassi") =
  p47_emiTargetMkt(ttot,regi, emiMktExt,"netGHG")
  - ( p47_LULUCFEmi_GrassiShift(ttot,regi) )$(sameas(emiMktExt,"other") or sameas(emiMktExt,"all"));

*** net GHG per Mkt without bunkers and with Grassi LULUCF shift
p47_emiTargetMkt(ttot,regi, emiMktExt,"netGHG_LULUCFGrassi_noBunkers") =
  p47_emiTargetMkt(ttot,regi, emiMktExt,"netGHG_noBunkers")
  - ( p47_LULUCFEmi_GrassiShift(ttot,regi) )$(sameas(emiMktExt,"other") or sameas(emiMktExt,"all"));

*** net CO2 per Mkt without bunkers and with Grassi LULUCF shift
p47_emiTargetMkt(ttot,regi, emiMktExt,"netCO2_LULUCFGrassi_intraRegBunker") =
  p47_emiTargetMkt(ttot,regi, emiMktExt,"netCO2_noBunkers")
  - ( p47_LULUCFEmi_GrassiShift(ttot,regi) )$(sameas(emiMktExt,"other") or sameas(emiMktExt,"all"))
  + (
    sum(se2fe(enty,enty2,te),
      pm_emifac(ttot,regi,enty,enty2,te,"co2")
      * vm_demFeSector.l(ttot,regi,enty,enty2,"trans","other")
      ) * 0.35  !!35% of total bunkers in average from 2000-2020 for EU27 + UKI countries according UNFCCC numbers
  )$((regi_group("EUR_regi",regi)) and (sameas(emiMktExt,"other") or sameas(emiMktExt,"all")));

*** net GHG per Mkt without bunkers and with Grassi LULUCF shift
p47_emiTargetMkt(ttot,regi, emiMktExt,"netGHG_LULUCFGrassi_intraRegBunker") =
  p47_emiTargetMkt(ttot,regi, emiMktExt,"netGHG_noBunkers")
  - ( p47_LULUCFEmi_GrassiShift(ttot,regi) )$(sameas(emiMktExt,"other") or sameas(emiMktExt,"all"))
  + (
    sum(se2fe(enty,enty2,te),
      pm_emifac(ttot,regi,enty,enty2,te,"co2")
      * vm_demFeSector.l(ttot,regi,enty,enty2,"trans","other")
      ) * 0.35  !!35% of total bunkers in average from 2000-2020 for EU27 + UKI countries according UNFCCC numbers
  )$((regi_group("EUR_regi",regi)) and (sameas(emiMktExt,"other") or sameas(emiMktExt,"all")));


p47_emiTargetMkt_iter(iteration,ttot,regi, emiMktExt,emi_type_47) = p47_emiTargetMkt(ttot,regi,emiMktExt,emi_type_47);

***--------------------------------------------------
*** Emission markets (EU Emission trading system and Effort Sharing)
***--------------------------------------------------

$IFTHEN.emiMkt not "%cm_emiMktTarget%" == "off" 

*** Removing economy wide co2 tax parameters for regions within the emiMKt controlled targets (this is necessary here to remove any calculation made in other modules after the last run in the postsolve)
  loop(ext_regi$regiEmiMktTarget(ext_regi),
    loop(regi$regi_groupExt(ext_regi,regi),
*** Removing the economy wide co2 tax parameters for regions within the ETS markets
      pm_taxCO2eqSum(t,regi) = 0;
      pm_taxCO2eq(t,regi) = 0;
      pm_taxCO2eqRegi(t,regi) = 0;
      pm_taxCO2eqSCC(t,regi) = 0;

      pm_taxrevGHG0(t,regi) = 0;
      pm_taxrevCO2Sector0(t,regi,emi_sectors) = 0;
      pm_taxrevCO2LUC0(t,regi) = 0;
      pm_taxrevNetNegEmi0(t,regi) = 0;
    );
  );

*** Calculating the current emission levels...
loop((ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47)$pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47),
*** for budget targets
  if(sameas(target_type_47,"budget"), !! budget total CO2 target
    pm_emiMktCurrent(ttot,ttot2,ext_regi,emiMktExt) =
      sum(regi$regi_groupExt(ext_regi,regi),
        sum(ttot3$((ttot3.val ge ttot.val) AND (ttot3.val le ttot2.val)),
          pm_ts(ttot3) * (1 -0.5$(ttot3.val eq ttot.val OR ttot3.val eq ttot2.val))
          *(p47_emiTargetMkt(ttot3, regi,emiMktExt,emi_type_47)*sm_c_2_co2)
      ));
*** for year targets
  elseif sameas(target_type_47,"year"), !! year total CO2 target
    pm_emiMktCurrent(ttot,ttot2,ext_regi,emiMktExt) = sum(regi$regi_groupExt(ext_regi,regi), p47_emiTargetMkt(ttot2, regi,emiMktExt,emi_type_47)*sm_c_2_co2);
*** Saving 2005 emission levels, used to determine target compliance for year targets
    pm_emiMktRefYear(ttot,ttot2,ext_regi,emiMktExt) = sum(regi$regi_groupExt(ext_regi,regi), p47_emiTargetMkt("2005", regi,emiMktExt,emi_type_47)*sm_c_2_co2);  
  );
);
p47_emiMktCurrent_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) = pm_emiMktCurrent(ttot,ttot2,ext_regi,emiMktExt); !!save current emission levels across iterations 

*** Calculate target deviation...
loop((ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47)$pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47),
*** for budget targets, target deviation is difference of current budget to target budget normalized by target budget
  if(sameas(target_type_47,"budget"),
    pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt) = (pm_emiMktCurrent(ttot,ttot2,ext_regi,emiMktExt)-pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47) ) / pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47);
  );
*** for year targets, target deviation is difference of current emissions in target year to target emissions normalized by 2015 emissions
  if(sameas(target_type_47,"year"),
    pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt) = (pm_emiMktCurrent(ttot,ttot2,ext_regi,emiMktExt)-pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47) ) / pm_emiMktRefYear(ttot,ttot2,ext_regi,emiMktExt);
  );
);
pm_emiMktTarget_dev_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) = pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt); !!save regional target deviation across iterations for debugging of target convergence issues

*** Checking sequentially if targets converged
loop((ext_regi,ttot2)$regiANDperiodEmiMktTarget_47(ttot2,ext_regi),
  p47_targetConverged(ttot2,ext_regi) = 0;
  loop((ttot,emiMktExt,target_type_47,emi_type_47)$((pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47))),
    loop(regi$regi_groupExt(ext_regi,regi),
      loop(emiMkt$emiMktGroup(emiMktExt,emiMkt), 
***     target converged: 
***     if the price is at minimal level (<1$/tCO2 + 10% of tolerance) and current emissions are lower than the target (avoid pushing to negative price values)
        if((((pm_taxemiMkt(ttot2,regi,emiMkt) - 1*sm_DptCO2_2_TDpGtC) lt 0.1*sm_DptCO2_2_TDpGtC) and (pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt) lt 0)),
          regiEmiMktconvergenceType(iteration,ttot,ttot2,ext_regi,emiMktExt,"smallPrice") = YES;
          p47_targetConverged(ttot2,ext_regi) = 1;
***     if current absolute emissions minus the target (=deviation) is lower than the tolerance
        elseif(abs(pm_emiMktTarget_dev_iter(iteration,ttot,ttot2,ext_regi,emiMktExt)) le pm_emiMktTarget_tolerance(ext_regi)),
          regiEmiMktconvergenceType(iteration,ttot,ttot2,ext_regi,emiMktExt,"lowerThanTolerance") = YES;
          p47_targetConverged(ttot2,ext_regi) = 1;
        );
      );
    );
  );
);
p47_targetConverged_iter(iteration,ttot2,ext_regi) = p47_targetConverged(ttot2,ext_regi); !!save regional target converged iteration information for debugging

*** Checking if all targets for the region converged
loop(ext_regi$regiEmiMktTarget(ext_regi),
  pm_allTargetsConverged(ext_regi) = 1;
  loop((ttot)$regiANDperiodEmiMktTarget_47(ttot,ext_regi),
    if(p47_targetConverged(ttot,ext_regi) eq 0,
      pm_allTargetsConverged(ext_regi) = 0;
    );
  );
);
p47_allTargetsConverged_iter(iteration,ext_regi) = pm_allTargetsConverged(ext_regi);

*** define current target to be solved
p47_currentConvergence_iter(iteration,ttot,ext_regi) = 0;
loop(ext_regi$regiEmiMktTarget(ext_regi),
*** solving targets sequentially, i.e. only apply target convergence algorithm if previous yearly targets were already achieved
  if(not(pm_allTargetsConverged(ext_regi) eq 1), !!no rescale need if all targets already converged
*** define current target to be solved
    loop((ttot)$regiANDperiodEmiMktTarget_47(ttot,ext_regi),
      p47_currentConvergencePeriod(ext_regi) = ttot.val;
      break$(p47_targetConverged(ttot,ext_regi) eq 0); !!only run target convergence up to the first year that has not converged
    );
    loop((ttot)$(regiANDperiodEmiMktTarget_47(ttot,ext_regi) and (ttot.val gt p47_currentConvergencePeriod(ext_regi))),
      p47_nextConvergencePeriod(ext_regi) = ttot.val;
      break;
    );
    loop((ttot,ttot2,emiMktExt,target_type_47,emi_type_47)$(pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47) AND (ttot2.val eq p47_currentConvergencePeriod(ext_regi))),
      p47_currentConvergence_iter(iteration,ttot2,ext_regi) = 1;
    );
  );
);

*** reference iteration from which to calculate the mitigation cost slope.
loop((ext_regi,ttot)$regiANDperiodEmiMktTarget_47(ttot,ext_regi),
  if(ord(iteration) eq 1,
    p47_slopeReferenceIteration_iter(iteration,ttot,ext_regi) = 1;
  elseif(NOT(p47_currentConvergence_iter(iteration,ttot,ext_regi) eq p47_currentConvergence_iter(iteration-1,ttot,ext_regi))), !! reset the iteration reference for slope calculation if the target that is being analyzed changes
    p47_slopeReferenceIteration_iter(iteration,ttot,ext_regi) = ord(iteration);
  else
    p47_slopeReferenceIteration_iter(iteration,ttot,ext_regi) = p47_slopeReferenceIteration_iter(iteration-1,ttot,ext_regi);
  );
);

*** resetting rescale factor for the next iteration
p47_factorRescaleSlope(ttot,ttot2,ext_regi,emiMktExt) = 0;
pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt) = 0;
*** Calculating the emissions tax rescale factor based on previous iterations emission reduction for current targets
loop(ext_regi$regiEmiMktTarget(ext_regi),
  loop((ttot2)$(ttot2.val eq p47_currentConvergencePeriod(ext_regi)),
    if(not(p47_targetConverged(ttot2,ext_regi) eq 1), !!no rescale factor calculation need if the target already converged
      loop((ttot,emiMktExt,target_type_47,emi_type_47)$(pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47)),
        loop(emiMkt$emiMktGroup(emiMktExt,emiMkt),
          loop(regi$regiEmiMktTarget2regi_47(ext_regi,regi),
***         if rescale factor was already calculated for ext_regi, there is no need to recalculate it  
            continue$(pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt));
***         calculating the rescale factor   
            loop(iteration2$((iteration2.val le iteration.val) and (iteration2.val eq p47_slopeReferenceIteration_iter(iteration,ttot2,ext_regi))), !!reference iteration for slope calculation
***           if it is the first iteration or the reference iteration changed, initialize the rescale factor based on remaining deviation
              if((iteration.val - iteration2.val) eq 0,
                regiEmiMktRescaleType(iteration,ttot,ttot2,ext_regi,emiMktExt,"squareDev_firstIteration") = YES;
                pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt) = power(1+pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt), 2);
***           else if for the extreme case of a perfect match with no change between the two iterations emisssion taxes used in the slope calculation, in order to avoid a division by zero error assume the rescale factor based on remaining deviation
              elseif((pm_taxemiMkt_iteration(iteration,ttot2,regi,emiMkt) - pm_taxemiMkt_iteration(iteration2,ttot2,regi,emiMkt) eq 0) 
                     AND
                     (pm_taxemiMkt_iteration(iteration,ttot2,regi,emiMkt) - pm_taxemiMkt_iteration("1",ttot2,regi,emiMkt) eq 0)),
                regiEmiMktRescaleType(iteration,ttot,ttot2,ext_regi,emiMktExt,"squareDev_perfectMatch") = YES;
                pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt) = power(1+pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt), 2);
***           else if emission tax variation in relation to base iteration is very small, assume the rescale factor based on the remaining deviation to avoid very slow improvements 
              elseif((abs(pm_taxemiMkt_iteration(iteration,ttot2,regi,emiMkt) - pm_taxemiMkt_iteration(iteration2,ttot2,regi,emiMkt)) lt 1e-2)
                     AND
                     (abs(pm_taxemiMkt_iteration(iteration,ttot2,regi,emiMkt) - pm_taxemiMkt_iteration("1",ttot2,regi,emiMkt)) lt 1e-2)),
                regiEmiMktRescaleType(iteration,ttot,ttot2,ext_regi,emiMktExt,"squareDev_smallChange") = YES;
                pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt) = power(1+pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt), 2);
***           else, calculate rescale factor using quantities and prices slope changes  
              else
***             if denominator in relation to reference is not close to zero, calculate the price slope in relation to the reference iteration mitigation and price levels
                if(NOT(abs(pm_taxemiMkt_iteration(iteration,ttot2,regi,emiMkt) - pm_taxemiMkt_iteration(iteration2,ttot2,regi,emiMkt)) lt 1e-2),
                  regiEmiMktRescaleType(iteration,ttot,ttot2,ext_regi,emiMktExt,"slope_refIteration") = YES;
                  p47_factorRescaleSlope(ttot,ttot2,ext_regi,emiMktExt) = 
                    (p47_emiMktCurrent_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) - p47_emiMktCurrent_iter(iteration2,ttot,ttot2,ext_regi,emiMktExt))
                    /
                    (pm_taxemiMkt_iteration(iteration,ttot2,regi,emiMkt) - pm_taxemiMkt_iteration(iteration2,ttot2,regi,emiMkt));
***             else if denominator in relation to first iteration is not close to zero, calculate the price slope in relation to the first iteration mitigation and price levels instead
                elseif(NOT(abs(pm_taxemiMkt_iteration(iteration,ttot2,regi,emiMkt) - pm_taxemiMkt_iteration("1",ttot2,regi,emiMkt)) lt 1e-2)),
                  regiEmiMktRescaleType(iteration,ttot,ttot2,ext_regi,emiMktExt,"slope_firstIteration") = YES;
                  p47_factorRescaleSlope(ttot,ttot2,ext_regi,emiMktExt) = 
                    (p47_emiMktCurrent_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) - p47_emiMktCurrent_iter("1",ttot,ttot2,ext_regi,emiMktExt))
                    /
                    (pm_taxemiMkt_iteration(iteration,ttot2,regi,emiMkt) - pm_taxemiMkt_iteration("1",ttot2,regi,emiMkt));
***             else if there is a previous iteration calculated slope, repeat the previous iteration slope                       
                elseif((iteration.val gt 1) and (p47_slopeReferenceIteration_iter(iteration,ttot,ext_regi) - p47_slopeReferenceIteration_iter(iteration-1,ttot,ext_regi) eq 0)),
                  regiEmiMktRescaleType(iteration,ttot,ttot2,ext_regi,emiMktExt,"slope_repeatPrev") = YES;
                  p47_factorRescaleSlope(ttot,ttot2,ext_regi,emiMktExt) = p47_factorRescaleSlope_iter(iteration-1,ttot,ttot2,ext_regi,emiMktExt);
***             else slope is not available, set the rescale factor based on remaining deviation
                else
                  regiEmiMktRescaleType(iteration,ttot,ttot2,ext_regi,emiMktExt,"squareDev_noSlope") = YES;
                  pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt) = power(1+pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt), 2);
                );
***             if we are using the slope
                if(NOT(regiEmiMktRescaleType(iteration,ttot,ttot2,ext_regi,emiMktExt,"squareDev_noSlope")),
***               if the slope is positive
                  if(p47_factorRescaleSlope(ttot,ttot2,ext_regi,emiMktExt) gt 0, 
                    regiEmiMktRescaleType(iteration,ttot,ttot2,ext_regi,emiMktExt,rescaleType) = NO;
***                 if there is a previous iteration calculated slope, repeat the previous iteration slope to avoid the positive value because we assume a trade-off between tax and emission levels 
                    if((iteration.val gt 1) and (p47_slopeReferenceIteration_iter(iteration,ttot,ext_regi) - p47_slopeReferenceIteration_iter(iteration-1,ttot,ext_regi) eq 0),
                      regiEmiMktRescaleType(iteration,ttot,ttot2,ext_regi,emiMktExt,"slope_repeatPrev_positiveSlope") = YES;
                      p47_factorRescaleSlope(ttot,ttot2,ext_regi,emiMktExt) = p47_factorRescaleSlope_iter(iteration-1,ttot,ttot2,ext_regi,emiMktExt);
***                 else slope is not available, set the rescale factor based on remaining deviation
                    else
                      regiEmiMktRescaleType(iteration,ttot,ttot2,ext_regi,emiMktExt,"squareDev_noNonPositiveSlope") = YES;
                      pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt) = power(1+pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt), 2);
                    );
                  );
***               if we are still using the slope
                  if(NOT(regiEmiMktRescaleType(iteration,ttot,ttot2,ext_regi,emiMktExt,"squareDev_noNonPositiveSlope")),
***                 clamp slopes values to avoid extreme changes (or no change) on a single iteration (avoid corner cases where other parts of the model changes causing undesirable fluctuations on the calculated slope)
                    if((p47_factorRescaleSlope(ttot,ttot2,ext_regi,emiMktExt) gt -0.3) OR (p47_factorRescaleSlope(ttot,ttot2,ext_regi,emiMktExt) lt -5),
                      p47_clampedRescaleSlope_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) = p47_factorRescaleSlope(ttot,ttot2,ext_regi,emiMktExt);
                    );
                    p47_factorRescaleSlope(ttot,ttot2,ext_regi,emiMktExt) = max(-5,min(-0.3, p47_factorRescaleSlope(ttot,ttot2,ext_regi,emiMktExt)));               
***                 calculate the tax rescale factor using the above calculated slope
                    pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt) = 
                      (
                        (pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47) - p47_emiMktCurrent_iter(iteration,ttot,ttot2,ext_regi,emiMktExt))
                        / 
                        (p47_factorRescaleSlope(ttot,ttot2,ext_regi,emiMktExt) * pm_taxemiMkt_iteration(iteration,ttot2,regi,emiMkt))
                      ) + 1;
                  );
                );
              );
            );
***         dampen if rescale oscillates
            if( (iteration.val > 3) , 
              if ( ( 
                      ( ( ( p47_factorRescaleemiMktCO2Tax_iter(iteration-1,ttot,ttot2,ext_regi,emiMktExt) - 1 ) 
                          * ( pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt) - 1 ) ) < 0 
                      ) AND  !! test if rescale changed from >1 to <1 or vice versa between iteration -1 and current iteration
                      ( ( ( p47_factorRescaleemiMktCO2Tax_iter(iteration-1,ttot,ttot2,ext_regi,emiMktExt) - 1 )
                          * ( p47_factorRescaleemiMktCO2Tax_iter(iteration-2,ttot,ttot2,ext_regi,emiMktExt) -1 ) ) < 0
                    ) !! test if rescale changed from >1 to <1 or vice versa between iteration -2 and iteration -1
                  ) ,
                p47_dampedFactorRescaleemiMktCO2Tax_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) = pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt);
                pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt) =
                  1 + ( ( pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt) - 1 ) / 2 ) 
                ; !! this brings the value closer to one. The formulation works reasonably well within the range of 0.5..2
                put_utility "msg" / "Reducing pm_factorRescaleemiMktCO2Tax due to oscillation in the previous 3 iterations: "; 
                put_utility "msg" / ttot.tl " " ttot2.tl " " ext_regi.tl " "  emiMktExt.tl " " pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt):10:3; 
              );
            );  
          );    
        );
      );
    );
  );
);
p47_factorRescaleSlope_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) = p47_factorRescaleSlope(ttot,ttot2,ext_regi,emiMktExt);
p47_factorRescaleemiMktCO2Tax_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) = pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt); !!save rescale factor across iterations for debugging of target convergence issues

*** updating tax values under current targets
loop(ext_regi$regiEmiMktTarget(ext_regi),
*** solving targets sequentially, i.e. only apply target convergence algorithm if previous yearly targets were already achieved
  if(not(pm_allTargetsConverged(ext_regi) eq 1), !!no rescale need if all targets already converged
*** updating the emiMkt co2 tax for the first non converged yearly target  
    loop((ttot,ttot2,emiMktExt,target_type_47,emi_type_47)$(pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47) AND (ttot2.val eq p47_currentConvergencePeriod(ext_regi))),
      loop(emiMkt$emiMktGroup(emiMktExt,emiMkt),
        loop(regi$regiEmiMktTarget2regi_47(ext_regi,regi),
***       terminal year price
          if((iteration.val eq 1) and (pm_taxemiMkt(ttot2,regi,emiMkt) eq 0), !!intialize price for first iteration if it is missing 
            pm_taxemiMkt(ttot2,regi,emiMkt) = 1* sm_DptCO2_2_TDpGtC;    
          else !!update price using rescaling factor (Minimal aceptable price = 1 dollar/tCO2)
            pm_taxemiMkt(ttot2,regi,emiMkt) = max(1* sm_DptCO2_2_TDpGtC, pm_taxemiMkt(ttot2,regi,emiMkt) * pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt)); 
          );
***       linear price between first free year and current target terminal year
          loop(ttot3,
            s47_firstFreeYear = ttot3.val;
            break$((ttot3.val ge ttot.val) and (ttot3.val ge cm_startyear) and (ttot3.val ge 2020)); !!initial free price year
            s47_prefreeYear = ttot3.val;
          );
          if(not(ttot2.val eq p47_firstTargetYear(ext_regi)), !! delay price change by cm_emiMktTargetDelay years for later targets
            s47_firstFreeYear = max(s47_firstFreeYear,ttot.val+cm_emiMktTargetDelay)
          );
          loop(ttot3$(ttot3.val eq s47_prefreeYear), !! ttot3 = beginning of slope; ttot2 = end of slope
            pm_taxemiMkt(t,regi,emiMkt)$((t.val ge s47_firstFreeYear) AND (t.val lt ttot2.val))  = pm_taxemiMkt(ttot3,regi,emiMkt) + ((pm_taxemiMkt(ttot2,regi,emiMkt) - pm_taxemiMkt(ttot3,regi,emiMkt))/(ttot2.val-ttot3.val))*(t.val-ttot3.val); 
          );
        );
      );
    );
  );
);

***  Assuming that other emissions outside the ESR and ETS see prices equal to the ESR prices
loop((ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47)$(pm_emiMktTarget(ttot,ttot2,ext_regi,"ESR",target_type_47,emi_type_47) or pm_emiMktTarget(ttot,ttot2,ext_regi,"all",target_type_47,emi_type_47)),
  loop(regi$regi_groupExt(ext_regi,regi),
    pm_taxemiMkt(t,regi,"other") = pm_taxemiMkt(t,regi,"ES");
  );
);

*** updating periods after current target
loop(ext_regi$regiEmiMktTarget(ext_regi),
  if(not(pm_allTargetsConverged(ext_regi) eq 1), !!no rescale need if all targets already converged
    loop((ttot,ttot2,emiMktExt,target_type_47,emi_type_47)$(pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47) AND (ttot2.val eq p47_currentConvergencePeriod(ext_regi))),
      loop(emiMkt$emiMktGroup(emiMktExt,emiMkt),
        loop(regi$regiEmiMktTarget2regi_47(ext_regi,regi),
***       if last year target, fixed year increase after terminal year price (cm_postTargetIncrease €/tCO2 increase per year)
          if((ttot2.val eq p47_lastTargetYear(ext_regi)),
            pm_taxemiMkt(t,regi,emiMkt)$(t.val gt ttot2.val) = pm_taxemiMkt(ttot2,regi,emiMkt) + (cm_postTargetIncrease*sm_DptCO2_2_TDpGtC)*(t.val-ttot2.val);
***       if not last year target, define price trajectory for years after the current target terminal year
          else 
            loop(ttot3$(ttot3.val eq p47_nextConvergencePeriod(ext_regi)), !! ttot3 = next convergence terminal year
***           if next target was executed at least once by the algorithm, update next target initial year value to the value adjusted in this iteration and linearly converge it to the previously set target terminal year 
              if(sum(iteration2, p47_currentConvergence_iter(iteration2,ttot3,ext_regi)) gt 0, !! ttot2 = beginning of next target slope; ttot3 = end of slope
                pm_taxemiMkt(t,regi,emiMkt)$((t.val gt ttot2.val) AND (t.val lt ttot3.val)) = pm_taxemiMkt(ttot2,regi,emiMkt) + ((pm_taxemiMkt(ttot3,regi,emiMkt) - pm_taxemiMkt(ttot2,regi,emiMkt))/(ttot3.val-ttot2.val))*(t.val-ttot2.val); !! price in between current target year and next target year
***           else if next target was never executed by the algorithm yet, initialize next target value as weighted average convergence price between current target terminal year (ttot2.val) and next target year (p47_nextConvergencePeriod)
              else
                p47_averagetaxemiMkt(t,regi) = 
                  (pm_taxemiMkt(t,regi,"ETS")*p47_emiTargetMkt(t,regi,"ETS",emi_type_47) + pm_taxemiMkt(t,regi,"ES")*p47_emiTargetMkt(t,regi,"ESR",emi_type_47) + pm_taxemiMkt(t,regi,"other")*p47_emiTargetMkt(t,regi,"other",emi_type_47))
                  /
                  (p47_emiTargetMkt(t,regi,"ETS",emi_type_47) + p47_emiTargetMkt(t,regi,"ESR",emi_type_47) + p47_emiTargetMkt(t,regi,"other",emi_type_47));
                pm_taxemiMkt(ttot3,regi,emiMkt) = p47_averagetaxemiMkt(ttot2,regi); !! ttot2 = beginning of slope; ttot3 = end of slope
                pm_taxemiMkt(t,regi,emiMkt)$((t.val gt ttot2.val) AND (t.val lt ttot3.val)) = pm_taxemiMkt(ttot2,regi,emiMkt) + ((pm_taxemiMkt(ttot3,regi,emiMkt) - pm_taxemiMkt(ttot2,regi,emiMkt))/(ttot3.val-ttot2.val))*(t.val-ttot2.val); !! price in between current target year and next target year
                pm_taxemiMkt(t,regi,emiMkt)$(t.val gt ttot3.val) = pm_taxemiMkt(ttot3,regi,emiMkt) + (cm_postTargetIncrease*sm_DptCO2_2_TDpGtC)*(t.val-ttot3.val); !! price after next target year
              );
            );
          );
        );
      );
    );
  );
);

*** output helper parameter
p47_taxemiMkt_AggEmi(ttot,regi)$(sum(emiMkt, vm_co2eqMkt.l(ttot,regi,emiMkt))) = (sum(emiMkt, pm_taxemiMkt(ttot,regi,emiMkt) * vm_co2eqMkt.l(ttot,regi,emiMkt))) / (sum(emiMkt, vm_co2eqMkt.l(ttot,regi,emiMkt)));
p47_taxCO2eq_AggEmi(ttot,regi) = pm_taxCO2eqSum(ttot,regi);
p47_taxCO2eq_AggEmi(ttot,regi)$p47_taxemiMkt_AggEmi(ttot,regi) = p47_taxemiMkt_AggEmi(ttot,regi);

p47_taxemiMkt_AggFE(ttot,regi)$(sum((entySe,entyFe,sector,emiMkt)$(sefe(entySe,entyFe) AND entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)),vm_demFeSector.l(ttot,regi,entySe,entyFe,sector,emiMkt))) = 
  (
    sum(emiMkt, pm_taxemiMkt(ttot,regi,emiMkt) * 
    sum((entySe,entyFe,sector)$(sefe(entySe,entyFe) AND entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)),vm_demFeSector.l(ttot,regi,entySe,entyFe,sector,emiMkt)))
  ) 
  / 
  (sum((entySe,entyFe,sector,emiMkt)$(sefe(entySe,entyFe) AND entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)),vm_demFeSector.l(ttot,regi,entySe,entyFe,sector,emiMkt)));
p47_taxCO2eq_AggFE(ttot,regi) = pm_taxCO2eqSum(ttot,regi);
p47_taxCO2eq_AggFE(ttot,regi)$p47_taxemiMkt_AggFE(ttot,regi) = p47_taxemiMkt_AggFE(ttot,regi);

p47_taxemiMkt_SectorAggFE(ttot,regi,sector)$(sum((entySe,entyFe,emiMkt)$(sefe(entySe,entyFe) AND entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)),vm_demFeSector.l(ttot,regi,entySe,entyFe,sector,emiMkt))) = 
  (
    sum(emiMkt, pm_taxemiMkt(ttot,regi,emiMkt) 
    * sum((entySe,entyFe)$(sefe(entySe,entyFe) AND entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)),vm_demFeSector.l(ttot,regi,entySe,entyFe,sector,emiMkt)))
  ) 
  /
  (sum((entySe,entyFe,emiMkt)$(sefe(entySe,entyFe) AND entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)),vm_demFeSector.l(ttot,regi,entySe,entyFe,sector,emiMkt)));
p47_taxCO2eq_SectorAggFE(ttot,regi,sector) = pm_taxCO2eqSum(ttot,regi);
p47_taxCO2eq_SectorAggFE(ttot,regi,sector)$p47_taxemiMkt_SectorAggFE(ttot,regi,sector) = p47_taxemiMkt_SectorAggFE(ttot,regi,sector);

*** display pm_emiMktTarget,pm_emiMktCurrent,pm_emiMktRefYear,pm_emiMktTarget_dev,pm_factorRescaleemiMktCO2Tax;

$ENDIF.emiMkt


***---------------------------------------------------------------------------
*** Calculation of implicit tax/subsidy necessary to achieve quantity target for primary, secondary, final energy and/or CCS
***---------------------------------------------------------------------------

$ifthen.cm_implicitQttyTarget not "%cm_implicitQttyTarget%" == "off"

*** saving previous iteration value for implicit tax revenue recycling
*** the same line exists in presolve.gms, don't forget to update there
p47_implicitQttyTargetTax_prevIter(t,regi,qttyTarget,qttyTargetGroup) = p47_implicitQttyTargetTax(t,regi,qttyTarget,qttyTargetGroup);
p47_implicitQttyTargetTax0(t,regi) =
  sum((qttyTarget,qttyTargetGroup)$p47_implicitQttyTargetTax(t,regi,qttyTarget,qttyTargetGroup),
    p47_implicitQttyTargetTax(t,regi,qttyTarget,qttyTargetGroup) * (
      ( sum(entyPe$energyQttyTargetANDGroup2enty(qttyTarget,qttyTargetGroup,entyPe), sum(pe2se(entyPe,entySe,te), vm_demPe.l(t,regi,entyPe,entySe,te)))
      )$(sameas(qttyTarget,"PE"))
      +
      ( sum(entySe$energyQttyTargetANDGroup2enty(qttyTarget,qttyTargetGroup,entySe), sum(se2fe(entySe,entyFe,te), vm_demSe.l(t,regi,entySe,entyFe,te)))
      )$(sameas(qttyTarget,"SE"))
      +
      ( sum(entySe$energyQttyTargetANDGroup2enty("FE",qttyTargetGroup,entySe), sum(se2fe(entySe,entyFe,te), sum((sector,emiMkt)$(entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)), vm_demFeSector.l(t,regi,entySe,entyFe,sector,emiMkt))))
      )$(sameas(qttyTarget,"FE") or sameas(qttyTarget,"FE_wo_b") or sameas(qttyTarget,"FE_wo_n_e") or sameas(qttyTarget,"FE_wo_b_wo_n_e"))
      +
      ( sum(ccs2te(ccsCo2(enty),enty2,te), sum(teCCS2rlf(te,rlf),vm_co2CCS.l(t,regi,enty,enty2,te,rlf)))
      )$(sameas(qttyTarget,"CCS") AND sameas(qttyTargetGroup,"all"))
      +
      ( sum(te_oae33, -vm_emiCdrTeDetail.l(t,regi,te_oae33))
      )$(sameas(qttyTarget,"oae") AND sameas(qttyTargetGroup,"all"))
      +
      (( !! Supply side BECCS
        sum(emiBECCS2te(enty,enty2,te,enty3),vm_emiTeDetail.l(t,regi,enty,enty2,te,enty3))
        !! Industry BECCS (using biofuels in Industry with CCS)
      + sum((emiMkt,entySe,secInd37,entyFe)$entySeBio(entySe), pm_IndstCO2Captured(t,regi,entySe,entyFe,secInd37,emiMkt))
      ) * pm_share_CCS_CCO2(t,regi) )$(sameas(qttyTarget,"CCS") AND sameas(qttyTargetGroup,"biomass"))
    )
  )
;

***  Calculating current quantity target levels (PE, SE, FE and/or CCS level)
loop((ttot,ext_regi,taxType,targetType,qttyTarget,qttyTargetGroup)$pm_implicitQttyTarget(ttot,ext_regi,taxType,targetType,qttyTarget,qttyTargetGroup),
  if(sameas(targetType,"t"), !!absolute target (t=total)
    p47_implicitQttyTargetCurrent(ttot,ext_regi,qttyTarget,qttyTargetGroup) =
      ( sum(regi$regi_groupExt(ext_regi,regi), sum(entyPe$energyQttyTargetANDGroup2enty("PE",qttyTargetGroup,entyPe), sum(pe2se(entyPe,entySe,te), vm_demPe.l(ttot,regi,entyPe,entySe,te))) )
      )$(sameas(qttyTarget,"PE"))
      +
      ( sum(regi$regi_groupExt(ext_regi,regi), sum(entySe$energyQttyTargetANDGroup2enty("SE",qttyTargetGroup,entySe), sum(se2fe(entySe,entyFe,te), vm_demSe.l(ttot,regi,entySe,entyFe,te))) )
      )$(sameas(qttyTarget,"SE"))
      +
      ( sum(regi$regi_groupExt(ext_regi,regi),  sum(entySe$energyQttyTargetANDGroup2enty("FE",qttyTargetGroup,entySe), sum(se2fe(entySe,entyFe,te), sum((sector,emiMkt)$(entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)), vm_demFeSector.l(ttot,regi,entySe,entyFe,sector,emiMkt)))) )
        + ( - ( sum(regi$regi_groupExt(ext_regi,regi), sum(entySe$energyQttyTargetANDGroup2enty("FE",qttyTargetGroup,entySe), sum(se2fe(entySe,entyFe,te),  vm_demFeSector.l(ttot,regi,entySe,entyFe,"trans","other")) )) ) !! removing bunkers from FE targets
        )$(sameas(qttyTarget,"FE_wo_b") or sameas(qttyTarget,"FE_wo_b_wo_n_e"))
        + ( - ( sum(regi$regi_groupExt(ext_regi,regi),  sum(entySe$energyQttyTargetANDGroup2enty("FE",qttyTargetGroup,entySe), sum(se2fe(entySe,entyFe,te), sum((sector,emiMkt)$(entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)), vm_demFeNonEnergySector.l(ttot,regi,entySe,entyFe,sector,emiMkt)))) ) ) !! removing non-energy from FE targets
        )$(sameas(qttyTarget,"FE_wo_n_e") or sameas(qttyTarget,"FE_wo_b_wo_n_e"))
      )$(sameas(qttyTarget,"FE") or sameas(qttyTarget,"FE_wo_b") or sameas(qttyTarget,"FE_wo_n_e") or sameas(qttyTarget,"FE_wo_b_wo_n_e"))
      +
      ( sum(regi$regi_groupExt(ext_regi,regi), sum(ccs2te(ccsCo2(enty),enty2,te), sum(teCCS2rlf(te,rlf),vm_co2CCS.l(ttot,regi,enty,enty2,te,rlf))))
      )$(sameas(qttyTarget,"CCS") AND sameas(qttyTargetGroup,"all"))
      +
      ( sum(regi$regi_groupExt(ext_regi,regi), sum(te_oae33, -vm_emiCdrTeDetail.l(ttot,regi,te_oae33)))
      )$(sameas(qttyTarget,"oae") AND sameas(qttyTargetGroup,"all"))
      +
      sum(regi$regi_groupExt(ext_regi,regi), ( !! Supply side BECCS
        sum(emiBECCS2te(enty,enty2,te,enty3),vm_emiTeDetail.l(ttot,regi,enty,enty2,te,enty3))
        !! Industry BECCS (using biofuels in Industry with CCS)
      + sum((emiMkt,entySe,secInd37,entyFe)$entySeBio(entySe), pm_IndstCO2Captured(ttot,regi,entySe,entyFe,secInd37,emiMkt))
      ) * pm_share_CCS_CCO2(ttot,regi))$(sameas(qttyTarget,"CCS") AND sameas(qttyTargetGroup,"biomass"))
  );
  if(sameas(targetType,"s"), !!relative target (s=share) (not applied to CCS)
    p47_implicitQttyTargetCurrent(ttot,ext_regi,qttyTarget,qttyTargetGroup) = 
      (
        ( sum(regi$regi_groupExt(ext_regi,regi), sum(entyPe$energyQttyTargetANDGroup2enty("PE",qttyTargetGroup,entyPe), sum(pe2se(entyPe,entySe,te), vm_demPe.l(ttot,regi,entyPe,entySe,te))) ) )
        /
        ( sum(regi$regi_groupExt(ext_regi,regi), sum(entyPe$energyQttyTargetANDGroup2enty("PE","all",entyPe), sum(pe2se(entyPe,entySe,te), vm_demPe.l(ttot,regi,entyPe,entySe,te))) ) )
      )$(sameas(qttyTarget,"PE")) 
      +
      ( 
        ( sum(regi$regi_groupExt(ext_regi,regi), sum(entySe$energyQttyTargetANDGroup2enty("SE",qttyTargetGroup,entySe), sum(se2fe(entySe,entyFe,te), vm_demSe.l(ttot,regi,entySe,entyFe,te))) ) )
        /
        ( sum(regi$regi_groupExt(ext_regi,regi), sum(entySe$energyQttyTargetANDGroup2enty("SE","all",entySe), sum(se2fe(entySe,entyFe,te), vm_demSe.l(ttot,regi,entySe,entyFe,te))) ) )
      )$(sameas(qttyTarget,"SE")) 
      +
      ( 
        (
        sum(regi$regi_groupExt(ext_regi,regi),  sum(entySe$energyQttyTargetANDGroup2enty("FE",qttyTargetGroup,entySe), sum(se2fe(entySe,entyFe,te), sum((sector,emiMkt)$(entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)), vm_demFeSector.l(ttot,regi,entySe,entyFe,sector,emiMkt)))) )
        + ( - ( sum(regi$regi_groupExt(ext_regi,regi), sum(entySe$energyQttyTargetANDGroup2enty("FE",qttyTargetGroup,entySe), sum(se2fe(entySe,entyFe,te),  vm_demFeSector.l(ttot,regi,entySe,entyFe,"trans","other")) )) ) !! removing bunkers from FE targets
        )$(sameas(qttyTarget,"FE_wo_b") or sameas(qttyTarget,"FE_wo_b_wo_n_e"))
        + ( - ( sum(regi$regi_groupExt(ext_regi,regi),  sum(entySe$energyQttyTargetANDGroup2enty("FE",qttyTargetGroup,entySe), sum(se2fe(entySe,entyFe,te), sum((sector,emiMkt)$(entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)), vm_demFeNonEnergySector.l(ttot,regi,entySe,entyFe,sector,emiMkt)))) ) ) !! removing non-energy from FE targets
        )$(sameas(qttyTarget,"FE_wo_n_e") or sameas(qttyTarget,"FE_wo_b_wo_n_e"))
        )
        /
        (
        sum(regi$regi_groupExt(ext_regi,regi),  sum(entySe$energyQttyTargetANDGroup2enty("FE","all",entySe), sum(se2fe(entySe,entyFe,te), sum((sector,emiMkt)$(entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)), vm_demFeSector.l(ttot,regi,entySe,entyFe,sector,emiMkt)))) )
        + ( - ( sum(regi$regi_groupExt(ext_regi,regi), sum(entySe$energyQttyTargetANDGroup2enty("FE","all",entySe), sum(se2fe(entySe,entyFe,te),  vm_demFeSector.l(ttot,regi,entySe,entyFe,"trans","other")) )) ) !! removing bunkers from FE targets
        )$(sameas(qttyTarget,"FE_wo_b") or sameas(qttyTarget,"FE_wo_b_wo_n_e"))
        + ( - ( sum(regi$regi_groupExt(ext_regi,regi),  sum(entySe$energyQttyTargetANDGroup2enty("FE",qttyTargetGroup,entySe), sum(se2fe(entySe,entyFe,te), sum((sector,emiMkt)$(entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)), vm_demFeNonEnergySector.l(ttot,regi,entySe,entyFe,sector,emiMkt)))) ) ) !! removing non-energy from FE targets
        )$(sameas(qttyTarget,"FE_wo_n_e") or sameas(qttyTarget,"FE_wo_b_wo_n_e"))
        )  
      )$(sameas(qttyTarget,"FE") or sameas(qttyTarget,"FE_wo_b") or sameas(qttyTarget,"FE_wo_n_e") or sameas(qttyTarget,"FE_wo_b_wo_n_e"))
    ;
  ); 
);
p47_implicitQttyTargetCurrent_iter(iteration,ttot,ext_regi,qttyTarget,qttyTargetGroup) = p47_implicitQttyTargetCurrent(ttot,ext_regi,qttyTarget,qttyTargetGroup);

*** calculate target deviation
loop((ttot,ext_regi,taxType,targetType,qttyTarget,qttyTargetGroup)$pm_implicitQttyTarget(ttot,ext_regi,taxType,targetType,qttyTarget,qttyTargetGroup),
  if(sameas(targetType,"t"),
    pm_implicitQttyTarget_dev(ttot,ext_regi,qttyTarget,qttyTargetGroup) = ( p47_implicitQttyTargetCurrent(ttot,ext_regi,qttyTarget,qttyTargetGroup) - pm_implicitQttyTarget(ttot,ext_regi,taxType,targetType,qttyTarget,qttyTargetGroup) ) / pm_implicitQttyTarget(ttot,ext_regi,taxType,targetType,qttyTarget,qttyTargetGroup);
  );
  if(sameas(targetType,"s"),
    pm_implicitQttyTarget_dev(ttot,ext_regi,qttyTarget,qttyTargetGroup) = p47_implicitQttyTargetCurrent(ttot,ext_regi,qttyTarget,qttyTargetGroup) - pm_implicitQttyTarget(ttot,ext_regi,taxType,targetType,qttyTarget,qttyTargetGroup);
  );
* save regional target deviation across iterations for debugging of target convergence issues
  p47_implicitQttyTarget_dev_iter(iteration, ttot,ext_regi,qttyTarget,qttyTargetGroup) = pm_implicitQttyTarget_dev(ttot,ext_regi,qttyTarget,qttyTargetGroup);
);

*** Defining if quantity target algorithm should be active based on cm_implicitQttyTarget_delay option
p47_implicitQttyTargetActive_iter(iteration,ext_regi) = 0; !!if no delay is defined 
$ifthen.cm_implicitQttyTarget_delay "%cm_implicitQttyTarget_delay%" == "off"
  p47_implicitQttyTargetActive_iter(iteration,ext_regi) = 1;
$else.cm_implicitQttyTarget_delay
  if(p47_implicitQttyTarget_delay("iteration"), !!iteration delay is defined
    if(p47_implicitQttyTarget_delay("iteration") le iteration.val,
      p47_implicitQttyTargetActive_iter(iteration,ext_regi) = 1;
    );
  elseif(p47_implicitQttyTarget_delay("emiConv")), !!only after emissions targets converged
    if(abs(sm_globalBudget_absDev) le cm_budgetCO2_absDevTol,
      p47_implicitQttyTargetActive_iter(iteration,ext_regi) = 1;
    );
$ifThen.emiMkt not "%cm_emiMktTarget%" == "off"
    loop(ext_regi,
      if((smax((ttot,ttot2,emiMktExt),abs(pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt))) gt pm_emiMktTarget_tolerance(ext_regi)), !! resetting active state if regipol target is defined and it did not converged
        p47_implicitQttyTargetActive_iter(iteration,ext_regi) = 0;
      );
    );
  elseif(p47_implicitQttyTarget_delay("emiRegiConv")), !!emiTarget delay is defined and deviation is lower than tolerance times p47_implicitQttyTarget_delay("emiRegiConv")
    loop(ext_regi,
      if((smax((ttot,ttot2,emiMktExt),abs(pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt))) lt (pm_emiMktTarget_tolerance(ext_regi) * p47_implicitQttyTarget_delay("emiRegiConv"))),
        p47_implicitQttyTargetActive_iter(iteration,ext_regi) = 1;
      );
    );
$endIf.emiMkt 
  );
$endIf.cm_implicitQttyTarget_delay

display p47_implicitQttyTargetActive_iter;

loop((ttot,ext_regi,taxType,targetType,qttyTarget,qttyTargetGroup)$pm_implicitQttyTarget(ttot,ext_regi,taxType,targetType,qttyTarget,qttyTargetGroup),

  if(p47_implicitQttyTargetActive_iter(iteration,ext_regi) = 1,

    loop(iteration2,
      p47_implicitQttyTargetReferenceIteration(ext_regi) = iteration2.val;
      break$(p47_implicitQttyTargetActive_iter(iteration2,ext_regi) = 1);
    );
    p47_implicitQttyTargetIterationCount(ext_regi) = iteration.val - p47_implicitQttyTargetReferenceIteration(ext_regi) + 1;

***  calculating the rescale factor for the implicit tax to achieve the target
    if(sameas(taxType,"tax"),
      if(p47_implicitQttyTargetIterationCount(ext_regi) lt 15,
        p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup) = power(1 + pm_implicitQttyTarget_dev(ttot,ext_regi,qttyTarget,qttyTargetGroup), 4);
      else
        p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup) = power(1 + pm_implicitQttyTarget_dev(ttot,ext_regi,qttyTarget,qttyTargetGroup), 2);
      );  
    );
    if(sameas(taxType,"sub"),
      if(p47_implicitQttyTargetIterationCount(ext_regi) lt 15,
        p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup) = power(1 - pm_implicitQttyTarget_dev(ttot,ext_regi,qttyTarget,qttyTargetGroup), 4);
      else
        p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup) = power(1 - pm_implicitQttyTarget_dev(ttot,ext_regi,qttyTarget,qttyTargetGroup), 2);
      );  
    );
    put_utility "msg" / "Dampening rescaling for " ttot.tl " " ext_regi.tl " "  qttyTarget.tl " " qttyTargetGroup.tl;
    put_utility "msg" / "p47_implicitQttyTargetTaxRescale before dampening:  " ttot.tl " " ext_regi.tl " "  qttyTarget.tl " " qttyTargetGroup.tl " " p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup):10:3; 

*** dampen rescale factor when closer than 1.5 / 0.75 to reduce oscillations
    if( p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup) > 1,
      if( p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup) > 1.7, !! prevent numeric explosion by limiting the maximum value
        p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup) = 1.7;
      );
      p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup) =
        (  
          ( p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup) - 1 )
            * exp( (p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup) - 1.5 ) * 2 ) !! this is 0.4 at p47_rescale = 1.01; 1 at 1.5, 2.7 at 2 
            * ( 2 * ( exp( -0.025 * p47_implicitQttyTargetIterationCount(ext_regi)) + 0.1 ) )  !! in order to also have some dampening over iterations, 
        !! this line decreases from 2.1 at p47_implicitQttyTargetIterationCount 1 to 0.36 in p47_implicitQttyTargetIterationCount 100. 
        )
        + 1
      ;       
    else !! if rescale is <1, do the same procedure on (1/rescale)
      if( p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup) < 0.6,  !! prevent numeric explosion by limiting the minimum value
        p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup) = 0.6;
      );
      p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup) =
        1
        / (
            (  
              ( 1 / p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup) - 1 )
              * exp( ( 1 / p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup) - 1.5 ) * 2 ) !! this is 0.4 at p47_rescale = 1.01; 1 at 1.5, 2.7 at 2 
              * ( 2 * ( exp( -0.025 * p47_implicitQttyTargetIterationCount(ext_regi)) + 0.1 ) )  !! in order to also have some dampening over iterations, 
                !! this line decreases from 2.1 at p47_implicitQttyTargetIterationCount 1 to 0.36 in p47_implicitQttyTargetIterationCount 100. 
            )
            + 1
          )
      ;
    );
    put_utility "msg" / "p47_implicitQttyTargetTaxRescale after dampening: " ttot.tl " " ext_regi.tl " "  qttyTarget.tl " " qttyTargetGroup.tl " " p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup):10:3; 

*** with increasing iterations, tighten the bound around the rescale factor to prevent large jumps in late iterations
    p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup) =
      max( min( 2 * EXP( -0.05 * p47_implicitQttyTargetIterationCount(ext_regi) ) + 1.01 ,
                p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup)
          ),
          1 / ( 2 * EXP( -0.05 * p47_implicitQttyTargetIterationCount(ext_regi) ) + 1.01)
      );
    put_utility "msg" / "p47_implicitQttyTargetTaxRescale after boundaries: " ttot.tl " " ext_regi.tl " "  qttyTarget.tl " " qttyTargetGroup.tl " " p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup):10:3; 

*** dampen if rescale oscillates
    if( (iteration.val > 3) , 
      if ( ( 
              ( ( ( p47_implicitQttyTargetTaxRescale_iter(iteration-1,ttot,ext_regi,qttyTarget,qttyTargetGroup) - 1 ) 
                  * ( p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup) - 1 ) ) < 0 
              ) AND  !! test if rescale changed from >1 to <1 or vice versa between iteration -1 and current iteration
              ( ( ( p47_implicitQttyTargetTaxRescale_iter(iteration-1,ttot,ext_regi,qttyTarget,qttyTargetGroup) - 1 )
                  * ( p47_implicitQttyTargetTaxRescale_iter(iteration-2,ttot,ext_regi,qttyTarget,qttyTargetGroup) -1 ) ) < 0
            ) !! test if rescale changed from >1 to <1 or vice versa between iteration -2 and iteration -1
          ) ,
        p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup) =
          1 + ( ( p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup) - 1 ) / 2 ) 
        ; !! this brings the value closer to one. The formulation works reasonably well within the range of 0.5..2
        put_utility "msg" / "Reducing p47_implicitQttyTargetTaxRescale due to oscillation in the previous 3 iterations: "; 
        put_utility "msg" / ttot.tl " " ext_regi.tl " "  qttyTarget.tl " " qttyTargetGroup.tl " " p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup):10:3; 
      );
    );   
  );
);
p47_implicitQttyTargetTaxRescale_iter(iteration,ttot,ext_regi,qttyTarget,qttyTargetGroup) = p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup);

*** updating quantity targets implicit tax
pm_implicitQttyTarget_isLimited(iteration,ttot,ext_regi,qttyTarget,qttyTargetGroup) = 0;
loop((ttot,ext_regi,taxType,targetType,qttyTarget,qttyTargetGroup)$pm_implicitQttyTarget(ttot,ext_regi,taxType,targetType,qttyTarget,qttyTargetGroup), !! initialize before first year auxiliary parameter for targets
    loop(ttot2$(ttot2.val eq cm_startyear), 
        p47_implicitQttyTarget_initialYear(ext_regi,taxType,targetType,qttyTarget,qttyTargetGroup) =  max(2020,pm_ttot_val(ttot2-1));
    );
);

loop((ttot,ext_regi,taxType,targetType,qttyTarget,qttyTargetGroup)$pm_implicitQttyTarget(ttot,ext_regi,taxType,targetType,qttyTarget,qttyTargetGroup),
  if(p47_implicitQttyTargetActive_iter(iteration,ext_regi) = 1,
    loop(all_regi$regi_groupExt(ext_regi,all_regi),
***   terminal year onward tax
      if(sameas(taxType,"tax"),
        if((p47_implicitQttyTargetTax_prevIter(ttot,all_regi,qttyTarget,qttyTargetGroup) * p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup) lt 1e-10), !! assuring that the updated tax is positive, i.e. the target is achieved without the need for any additional tax
          pm_implicitQttyTarget_isLimited(iteration,ttot,ext_regi,qttyTarget,qttyTargetGroup) = 1;
          p47_implicitQttyTargetTax(t,all_regi,qttyTarget,qttyTargetGroup)$(t.val ge ttot.val) = 1e-10;
        else
          p47_implicitQttyTargetTax(t,all_regi,qttyTarget,qttyTargetGroup)$(t.val ge ttot.val) = p47_implicitQttyTargetTax_prevIter(t,all_regi,qttyTarget,qttyTargetGroup) * p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup); 
        ); 
      );
      if(sameas(taxType,"sub"),
        if((p47_implicitQttyTargetTax_prevIter(ttot,all_regi,qttyTarget,qttyTargetGroup) * p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup) gt -1e-10), !! assuring that the updated tax is negative (subsidy), i.e. the target is achieved without the need for any additional subsidy
          pm_implicitQttyTarget_isLimited(iteration,ttot,ext_regi,qttyTarget,qttyTargetGroup) = 1;
          p47_implicitQttyTargetTax(t,all_regi,qttyTarget,qttyTargetGroup)$(t.val ge ttot.val) = -1e-10;
        else
          p47_implicitQttyTargetTax(t,all_regi,qttyTarget,qttyTargetGroup)$(t.val ge ttot.val) = p47_implicitQttyTargetTax_prevIter(t,all_regi,qttyTarget,qttyTargetGroup) * p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup); 
        ); 
      );
***   linear price between first free year and target year
      loop(ttot2$(ttot2.val eq p47_implicitQttyTarget_initialYear(ext_regi,taxType,targetType,qttyTarget,qttyTargetGroup)),
        p47_implicitQttyTargetTax(t,all_regi,qttyTarget,qttyTargetGroup)$((t.val gt ttot2.val) and (t.val lt ttot.val) and (t.val ge cm_startyear)) = 
            p47_implicitQttyTargetTax(ttot2,all_regi,qttyTarget,qttyTargetGroup) +
          (
            p47_implicitQttyTargetTax(ttot,all_regi,qttyTarget,qttyTargetGroup) - p47_implicitQttyTargetTax(ttot2,all_regi,qttyTarget,qttyTargetGroup)
          ) * ((t.val - ttot2.val) / (ttot.val - ttot2.val))
        ;
      );
***   checking if there is a hard bound on the model that does not allow the tax to change further the energy usage
***   if current value (p47_implicitQttyTargetCurrent) is unchanged in relation to previous iteration when the rescale factor of the previous iteration was different than one, price changes did not affected quantity and therefore the tax level is reseted to the previous iteration value to avoid unecessary tax increase without target achievment gains.  
      if((iteration.val gt 3),
        if( ((p47_implicitQttyTargetCurrent_iter(iteration-1,ttot,ext_regi,qttyTarget,qttyTargetGroup) - p47_implicitQttyTargetCurrent(ttot,ext_regi,qttyTarget,qttyTargetGroup) lt 1e-5) AND (p47_implicitQttyTargetCurrent_iter(iteration-1,ttot,ext_regi,qttyTarget,qttyTargetGroup) - p47_implicitQttyTargetCurrent(ttot,ext_regi,qttyTarget,qttyTargetGroup) gt -1e-5) ) 
          and (NOT( p47_implicitQttyTargetTaxRescale_iter(iteration-1,ttot,ext_regi,qttyTarget,qttyTargetGroup) lt 0.0001 and p47_implicitQttyTargetTaxRescale_iter(iteration-1,ttot,ext_regi,qttyTarget,qttyTargetGroup) gt -0.0001 )),
          p47_implicitQttyTargetTax(t,all_regi,qttyTarget,qttyTargetGroup) = p47_implicitQttyTargetTax_prevIter(t,all_regi,qttyTarget,qttyTargetGroup);
          pm_implicitQttyTarget_isLimited(iteration,ttot,ext_regi,qttyTarget,qttyTargetGroup) = 1;
        );
      );
    );
***   update initialYear for further targets
    p47_implicitQttyTarget_initialYear(ext_regi,taxType,targetType,qttyTarget,qttyTargetGroup) = ttot.val;
  );

*** tax associated with a specific iteration is the tax that was used in this iteration
  p47_implicitQttyTargetTax_iter(iteration,ttot,all_regi,qttyTarget,qttyTargetGroup) = p47_implicitQttyTargetTax_prevIter(ttot,all_regi,qttyTarget,qttyTargetGroup); 

  display p47_implicitQttyTargetCurrent, pm_implicitQttyTarget, p47_implicitQttyTargetTax_prevIter, pm_implicitQttyTarget_dev, p47_implicitQttyTarget_dev_iter, p47_implicitQttyTargetTax, 
    p47_implicitQttyTargetTaxRescale, p47_implicitQttyTargetTaxRescale_iter, p47_implicitQttyTargetTax_iter, p47_implicitQttyTargetCurrent_iter, p47_implicitQttyTargetTax0;

);


$endIf.cm_implicitQttyTarget


***---------------------------------------------------------------------------
*** Calculation of implicit tax/subsidy necessary to achieve final energy price targets
***---------------------------------------------------------------------------

$ifthen.cm_implicitPriceTarget not "%cm_implicitPriceTarget%" == "off"

*** saving previous iteration value for implicit tax revenue recycling
  p47_implicitPriceTax0(t,regi,entyFe,entySe,sector)$pm_implicitPriceTarget(t,regi,entyFe,entySe,sector) = p47_implicitPriceTax(t,regi,entyFe,entySe,sector) * sum(emiMkt$sector2emiMkt(sector,emiMkt), vm_demFeSector.l(t,regi,entySe,entyFe,sector,emiMkt));

*** saving previous iteration value price target tax for debugging of target convergence issues
  p47_implicitPriceTax_iter(iteration,t,regi,entyFe,entySe,sector) = p47_implicitPriceTax(t,regi,entyFe,entySe,sector);

*** Calculate target deviation
  p47_implicitPrice_dev(t,regi,entyFe,entySe,sector)$pm_implicitPriceTarget(t,regi,entyFe,entySe,sector) = ((pm_FEPrice_by_SE_Sector(t,regi,entySe,entyFe,sector) - pm_implicitPriceTarget(t,regi,entyFe,entySe,sector)) / pm_implicitPriceTarget(t,regi,entyFe,entySe,sector));
*** save regional target deviation across iterations for debugging of target convergence issues
  p47_implicitPrice_dev_iter(iteration,t,regi,entyFe,entySe,sector) = p47_implicitPrice_dev(t,regi,entyFe,entySe,sector);

*** updating implicit price target tax for next iteration (iteration+1)
  loop((t,regi,entyFe,entySe,sector)$pm_implicitPriceTarget(t,regi,entyFe,entySe,sector),
    if((abs(p47_implicitPrice_dev(t,regi,entyFe,entySe,sector)) gt 0.05), !! convergence criteria not reached
      if((pm_FEPrice_by_SE_Sector(t,regi,entySe,entyFe,sector) lt 1e-5), !! repeat tax if there is no price
        p47_implicitPriceTax(t,regi,entyFe,entySe,sector) = p47_implicitPriceTax(t,regi,entyFe,entySe,sector);
      else
        p47_implicitPriceTax(t,regi,entyFe,entySe,sector) = 
          (pm_implicitPriceTarget(t,regi,entyFe,entySe,sector) - pm_FEPrice_by_SE_Sector(t,regi,entySe,entyFe,sector))
          + p47_implicitPriceTax(t,regi,entyFe,entySe,sector);
      );
    );
  );

*** convergence criteria
  pm_implicitPrice_NotConv(regi,sector,entyFe,entySe,t) = 0;
  pm_implicitPrice_NotConv(regi,sector,entyFe,entySe,t)$(abs(p47_implicitPrice_dev(t,regi,entyFe,entySe,sector)) gt 0.05) = p47_implicitPrice_dev(t,regi,entyFe,entySe,sector); !! target did not converged = prices deviate more than 5% from target
*** additional convergence checks: 
***   ignoring non existent prices from price convergence check
  pm_implicitPrice_ignConv(regi,sector,entyFe,entySe,t)$((pm_implicitPrice_NotConv(regi,sector,entyFe,entySe,t)) AND (pm_FEPrice_by_SE_Sector(t,regi,entySe,entyFe,sector) lt 1e-5)) = 1; !!1 = non existent price  
  pm_implicitPrice_NotConv(regi,sector,entyFe,entySe,t)$((pm_implicitPrice_NotConv(regi,sector,entyFe,entySe,t)) AND (pm_FEPrice_by_SE_Sector(t,regi,entySe,entyFe,sector) lt 1e-5)) = 0; !! removing from convergence check
***   checking if there is a hard bound on the model that does not allow the prices to change further in between iterations 
***   if current value (p47_implicitPriceTax) is unchanged in relation to previous two iterations, i.e. less than 1% variation, when the deviation is still greater than 5%, the tax is not affecting anymore the prices.  
  if((iteration.val gt 3),
    loop((t,regi,entyFe,entySe,sector)$pm_implicitPrice_NotConv(regi,sector,entyFe,entySe,t),
      if((abs(p47_implicitPriceTax(t,regi,entyFe,entySe,sector) - p47_implicitPriceTax_iter(iteration-1,t,regi,entyFe,entySe,sector)) lt 1e-2), !! less than 1% variation in relation to previous iteration price
        if((abs(p47_implicitPriceTax_iter(iteration-1,t,regi,entyFe,entySe,sector) - p47_implicitPriceTax_iter(iteration-2,t,regi,entyFe,entySe,sector)) lt 1e-2), !! less than 1% variation in the two previous iteration prices
          pm_implicitPrice_ignConv(regi,sector,entyFe,entySe,t) = 2; !! 2 = less than 1% price change in this and the previous two iterations  
          pm_implicitPrice_NotConv(regi,sector,entyFe,entySe,t) = 0; !! removing from convergence check
        );
      );
    );
  );

*** smoothing out tax phase-in and phase-out for non controlled years
  loop((regi,entyFe,entySe,sector)$p47_implicitPriceTarget_terminalYear(regi,entyFe,entySe,sector),
*** terminal year onward tax (continuous tax up to 2100 and linear decay afterwards)
    loop(ttot$(ttot.val eq p47_implicitPriceTarget_terminalYear(regi,entyFe,entySe,sector)),
      p47_implicitPriceTax(t,regi,entyFe,entySe,sector)$(t.val gt ttot.val) = p47_implicitPriceTax(ttot,regi,entyFe,entySe,sector);
      p47_implicitPriceTax(t,regi,entyFe,entySe,sector)$(t.val gt 2100) = p47_implicitPriceTax("2100",regi,entyFe,entySe,sector) * (1 - ((t.val - 2100) / (2150 - 2100)));
    );
*** linear tax between period before cm_startyear and initial year (p47_implicitPriceTarget_initialYear)
    loop(ttot,
      s47_firstFreeYear = ttot.val; 
      break$((ttot.val ge cm_startyear) and (ttot.val gt 2020));
      s47_prefreeYear = ttot.val;
    );
    loop(ttot$(ttot.val eq p47_implicitPriceTarget_initialYear(regi,entyFe,entySe,sector)),
      p47_implicitPriceTax(t,regi,entyFe,entySe,sector)$((t.val ge cm_startyear) and (t.val lt ttot.val)) = p47_implicitPriceTax(ttot,regi,entyFe,entySe,sector) * ((t.val - s47_prefreeYear) / (ttot.val - s47_prefreeYear));
    );
  );

display pm_implicitPriceTarget, p47_implicitPriceTax, p47_implicitPrice_dev, p47_implicitPriceTax_iter, p47_implicitPrice_dev_iter;
$endIf.cm_implicitPriceTarget

***---------------------------------------------------------------------------
*** Calculation of implicit tax/subsidy necessary to achieve primary energy price targets
***---------------------------------------------------------------------------

$ifthen.cm_implicitPePriceTarget not "%cm_implicitPePriceTarget%" == "off"

*** saving previous iteration value for implicit tax revenue recycling
  p47_implicitPePriceTax0(t,regi,entyPe)$pm_implicitPePriceTarget(t,regi,entyPe) = p47_implicitPePriceTax(t,regi,entyPe) * vm_prodPe.l(t,regi,entyPe);

*** saving previous iteration value price target tax for debugging of target convergence issues
  p47_implicitPePriceTax_iter(iteration,t,regi,entyPe) = p47_implicitPePriceTax(t,regi,entyPe);

*** Calculate target deviation
  p47_implicitPePrice_dev(t,regi,entyPe)$pm_implicitPePriceTarget(t,regi,entyPe) = ((pm_PEPrice(t,regi,entyPe) - pm_implicitPePriceTarget(t,regi,entyPe)) / pm_implicitPePriceTarget(t,regi,entyPe));
*** save regional target deviation across iterations for debugging of target convergence issues
  p47_implicitPePrice_dev_iter(iteration,t,regi,entyPe) = p47_implicitPePrice_dev(t,regi,entyPe);

*** updating implicit price target tax for next iteration (iteration+1)
  loop((t,regi,entyPe)$pm_implicitPePriceTarget(t,regi,entyPe),
    if((abs(p47_implicitPePrice_dev(t,regi,entyPe)) gt 0.05), !! convergence criteria not reached
      if((pm_PEPrice(t,regi,entyPe) lt 1e-5), !! repeat tax if there is no price
        p47_implicitPePriceTax(t,regi,entyPe) = p47_implicitPePriceTax(t,regi,entyPe);
      else
        p47_implicitPePriceTax(t,regi,entyPe) = 
          (pm_implicitPePriceTarget(t,regi,entyPe) - pm_PEPrice(t,regi,entyPe))
          + p47_implicitPePriceTax(t,regi,entyPe);
      );
    );
  );

*** convergence criteria
  pm_implicitPePrice_NotConv(regi,entyPe,t) = 0;
  pm_implicitPePrice_NotConv(regi,entyPe,t)$(abs(p47_implicitPePrice_dev(t,regi,entyPe)) gt 0.05) = p47_implicitPePrice_dev(t,regi,entyPe); !! target did not converged = prices deviate more than 5% from target
*** additional convergence checks: 
***   ignoring non existent prices from price convergence check
  pm_implicitPePrice_ignConv(regi,entyPe,t)$((pm_implicitPePrice_NotConv(regi,entyPe,t)) AND (pm_PEPrice(t,regi,entyPe) lt 1e-5)) = 1; !!1 = non existent price  
  pm_implicitPePrice_NotConv(regi,entyPe,t)$((pm_implicitPePrice_NotConv(regi,entyPe,t)) AND (pm_PEPrice(t,regi,entyPe) lt 1e-5)) = 0; !! removing from convergence check
***   checking if there is a hard bound on the model that does not allow the prices to change further in between iterations 
***   if current value (p47_implicitPePriceTax) is unchanged in relation to previous two iterations, i.e. less than 1% variation, when the deviation is still greater than 5%, the tax is not affecting anymore the prices.  
  if((iteration.val gt 3),
    loop((t,regi,entyPe)$pm_implicitPePrice_NotConv(regi,entyPe,t),
      if((abs(p47_implicitPePriceTax(t,regi,entyPe) - p47_implicitPePriceTax_iter(iteration-1,t,regi,entyPe)) lt 1e-2), !! less than 1% variation in relation to previous iteration price
        if((abs(p47_implicitPePriceTax_iter(iteration-1,t,regi,entyPe) - p47_implicitPePriceTax_iter(iteration-2,t,regi,entyPe)) lt 1e-2), !! less than 1% variation in the two previous iteration prices
          pm_implicitPePrice_ignConv(regi,entyPe,t) = 2; !! 2 = less than 1% price change in this and the previous two iterations  
          pm_implicitPePrice_NotConv(regi,entyPe,t) = 0; !! removing from convergence check
        );
      );
    );
  );

*** smoothing out tax phase-in and phase-out for non controlled years
  loop((regi,entyPe)$p47_implicitPePriceTarget_terminalYear(regi,entyPe),
*** terminal year onward tax (continuous tax up to 2100 and linear decay afterwards)
    loop(ttot$(ttot.val eq p47_implicitPePriceTarget_terminalYear(regi,entyPe)),
      p47_implicitPePriceTax(t,regi,entyPe)$(t.val gt ttot.val) = p47_implicitPePriceTax(ttot,regi,entyPe);
      p47_implicitPePriceTax(t,regi,entyPe)$(t.val gt 2100) = p47_implicitPePriceTax("2100",regi,entyPe) * (1 - ((t.val - 2100) / (2150 - 2100)));
    );
*** linear tax between cm_startyear and initial year (p47_implicitPePriceTarget_initialYear)
    loop(ttot,
      s47_firstFreeYear = ttot.val; 
      break$((ttot.val ge cm_startyear) and (ttot.val gt 2020));
      s47_prefreeYear = ttot.val;
    );
    loop(ttot$(ttot.val eq p47_implicitPePriceTarget_initialYear(regi,entyPe)),
      p47_implicitPePriceTax(t,regi,entyPe)$((t.val ge cm_startyear) and (t.val lt ttot.val)) = p47_implicitPePriceTax(ttot,regi,entyPe) * ((t.val - s47_prefreeYear) / (ttot.val - s47_prefreeYear));
    );
  );

display pm_implicitPePriceTarget, p47_implicitPePriceTax, p47_implicitPePrice_dev, p47_implicitPePriceTax_iter, p47_implicitPePrice_dev_iter;
$endIf.cm_implicitPePriceTarget

***---------------------------------------------------------------------------
*** Exogenous CO2 tax level:
***---------------------------------------------------------------------------

$ifThen.regiExoPrice not "%cm_regiExoPrice%" == "off"
loop((ttot,ext_regi)$p47_exoCo2tax(ext_regi,ttot),
*** Removing the existent co2 tax parameters for regions with exogenous set prices
  pm_taxCO2eqSum(ttot,regi)$(regi_group(ext_regi,regi) and (ttot.val ge cm_startyear)) = 0;
  pm_taxCO2eq(ttot,regi)$(regi_group(ext_regi,regi) and (ttot.val ge cm_startyear)) = 0;
  pm_taxCO2eqRegi(ttot,regi)$(regi_group(ext_regi,regi) and (ttot.val ge cm_startyear)) = 0;
  pm_taxCO2eqSCC(ttot,regi)$(regi_group(ext_regi,regi) and (ttot.val ge cm_startyear)) = 0;

  pm_taxrevGHG0(ttot,regi)$(regi_group(ext_regi,regi) and (ttot.val ge cm_startyear)) = 0;
  pm_taxrevCO2Sector0(ttot,regi,emi_sectors)$(regi_group(ext_regi,regi) and (ttot.val ge cm_startyear)) = 0;
  pm_taxrevCO2LUC0(ttot,regi)$(regi_group(ext_regi,regi) and (ttot.val ge cm_startyear)) = 0;
  pm_taxrevNetNegEmi0(ttot,regi)$(regi_group(ext_regi,regi) and (ttot.val ge cm_startyear)) = 0;

  pm_taxemiMkt(ttot,regi,emiMkt)$(regi_group(ext_regi,regi) and (ttot.val ge cm_startyear)) = 0;

*** setting exogenous CO2 prices
  pm_taxCO2eq(ttot,regi)$(regi_group(ext_regi,regi) and (ttot.val ge cm_startyear)) = p47_exoCo2tax(ext_regi,ttot)*sm_DptCO2_2_TDpGtC;
  pm_taxCO2eqSum(ttot,regi)$(regi_group(ext_regi,regi) and (ttot.val ge cm_startyear)) = pm_taxCO2eq(ttot,regi);
);
display 'update of CO2 prices due to exogenously given CO2 prices in p47_exoCo2tax', pm_taxCO2eq;
$endIf.regiExoPrice

*** EOF ./modules/47_regipol/regiCarbonPrice/postsolve.gms
