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
  - ( pm_emiLULUCF_GrassiShift(ttot,regi) )$(sameas(emiMktExt,"other") or sameas(emiMktExt,"all"));

*** net CO2 per Mkt without bunkers and with Grassi LULUCF shift
p47_emiTargetMkt(ttot,regi, emiMktExt,"netCO2_LULUCFGrassi_noBunkers") =
  p47_emiTargetMkt(ttot,regi, emiMktExt,"netCO2_noBunkers")
  - ( pm_emiLULUCF_GrassiShift(ttot,regi) )$(sameas(emiMktExt,"other") or sameas(emiMktExt,"all"));

*** net GHG per Mkt with Grassi LULUCF shift
p47_emiTargetMkt(ttot,regi, emiMktExt,"netGHG_LULUCFGrassi") =
  p47_emiTargetMkt(ttot,regi, emiMktExt,"netGHG")
  - ( pm_emiLULUCF_GrassiShift(ttot,regi) )$(sameas(emiMktExt,"other") or sameas(emiMktExt,"all"));

*** net GHG per Mkt without bunkers and with Grassi LULUCF shift
p47_emiTargetMkt(ttot,regi, emiMktExt,"netGHG_LULUCFGrassi_noBunkers") =
  p47_emiTargetMkt(ttot,regi, emiMktExt,"netGHG_noBunkers")
  - ( pm_emiLULUCF_GrassiShift(ttot,regi) )$(sameas(emiMktExt,"other") or sameas(emiMktExt,"all"));

*** net CO2 per Mkt without bunkers and with Grassi LULUCF shift
p47_emiTargetMkt(ttot,regi, emiMktExt,"netCO2_LULUCFGrassi_intraRegBunker") =
  p47_emiTargetMkt(ttot,regi, emiMktExt,"netCO2_noBunkers")
  - ( pm_emiLULUCF_GrassiShift(ttot,regi) )$(sameas(emiMktExt,"other") or sameas(emiMktExt,"all"))
  + (
    sum(se2fe(enty,enty2,te),
      pm_emifac(ttot,regi,enty,enty2,te,"co2")
      * vm_demFeSector.l(ttot,regi,enty,enty2,"trans","other")
      ) * 0.35  !!35% of total bunkers in average from 2000-2020 for EU27 + UKI countries according UNFCCC numbers
  )$((regi_group("EUR_regi",regi)) and (sameas(emiMktExt,"other") or sameas(emiMktExt,"all")));

*** net GHG per Mkt without bunkers and with Grassi LULUCF shift
p47_emiTargetMkt(ttot,regi, emiMktExt,"netGHG_LULUCFGrassi_intraRegBunker") =
  p47_emiTargetMkt(ttot,regi, emiMktExt,"netGHG_noBunkers")
  - ( pm_emiLULUCF_GrassiShift(ttot,regi) )$(sameas(emiMktExt,"other") or sameas(emiMktExt,"all"))
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

*** ------ CO2 Tax Parameter Initialization ------

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

*** ------ Current Emission Levels & Target Deviation ------

loop((ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47)$pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47),
*** for budget targets
  if(sameas(target_type_47,"budget"), !! budget total CO2 target
    pm_emiMktCurrent(ttot,ttot2,ext_regi,emiMktExt) =
      sum(regi$regi_groupExt(ext_regi,regi),
        sum(ttot3$((ttot3.val ge ttot.val) AND (ttot3.val le ttot2.val)),
          pm_ts(ttot3) * (1 -0.5$(ttot3.val eq ttot.val OR ttot3.val eq ttot2.val))
          *(p47_emiTargetMkt(ttot3, regi,emiMktExt,emi_type_47)*sm_c_2_co2)
      ));
*** Reference budget (2005-end year trapezoidal projection).
    p47_emiMktRefBudget(ttot,ttot2,ext_regi,emiMktExt) =
      sum(regi$regi_groupExt(ext_regi,regi),
        sum(ttot3$((ttot3.val ge ttot.val) AND (ttot3.val le ttot2.val)),
          pm_ts(ttot3) * (1 -0.5$(ttot3.val eq ttot.val OR ttot3.val eq ttot2.val))
          *(p47_emiTargetMkt("2005", regi,emiMktExt,emi_type_47)*sm_c_2_co2)
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
*** floor the denominator at budgetDenomFloorFrac * the cumulative 2005-rate budget, so a near-zero budget target cannot blow the relative deviation up.
    pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt) = (pm_emiMktCurrent(ttot,ttot2,ext_regi,emiMktExt)-pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47) ) / max(abs(pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47)), p47_slopeParam("budgetDenomFloorFrac") * p47_emiMktRefBudget(ttot,ttot2,ext_regi,emiMktExt));
  );
*** for year targets, target deviation is difference of current emissions in target year to target emissions normalized by 2015 emissions
  if(sameas(target_type_47,"year"),
    pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt) = (pm_emiMktCurrent(ttot,ttot2,ext_regi,emiMktExt)-pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47) ) / pm_emiMktRefYear(ttot,ttot2,ext_regi,emiMktExt);
  );
);
pm_emiMktTarget_dev_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) = pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt); !!save regional target deviation across iterations for debugging of target convergence issues

*** Saving the best-so-far per market target: the smallest |deviation| reached so far and the iteration that produced it.
loop((ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47)$pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47),
  if((p47_targetState("bestDevIter",ttot,ttot2,ext_regi,emiMktExt) eq 0)
     OR (abs(pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt)) lt p47_targetState("bestDevAbs",ttot,ttot2,ext_regi,emiMktExt)),
    p47_targetState("bestDevAbs",ttot,ttot2,ext_regi,emiMktExt)  = abs(pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt));
    p47_targetState("bestDevIter",ttot,ttot2,ext_regi,emiMktExt) = iteration.val;
  );

*** only consider the target reached its goal while actively steering its own price, and not as a side effect of other targets changes
  if((p47_slopeParam("divergeMinBest") ge 1e-3)
     AND (p47_targetState("divArmed",ttot,ttot2,ext_regi,emiMktExt) eq 0)
     AND (p47_currentConvergence_iter(iteration-1,ttot2,ext_regi) eq 1)
     AND (abs(pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt))
          le p47_slopeParam("divergeMinBest") * pm_emiMktTarget_tolerance(ext_regi)),
    p47_targetState("divArmed",ttot,ttot2,ext_regi,emiMktExt) = 1;
  );
);

***----Target Convergence State Machine ------

*** Checking sequentially if targets converged (per-market AND aggregation)
*** a region-period is declared converged only when EVERY one of its market targets is, and each target carries its own hysteresis state.
*** The per-target test uses hysteresis + persistence so a target does not flip-flop in and out of the band under Nash noise - each flip would otherwise restart the slope window.
loop((ext_regi,ttot2)$regiANDperiodEmiMktTarget_47(ttot2,ext_regi),
  p47_targetConverged(ttot2,ext_regi) = 1; !! AND: assume converged (= all markets frozen), then clear on the first market target still steering
  p47_targetMet(ttot2,ext_regi)       = 1; !! AND: assume met (= all markets inside the RAW tolerance), then clear on the first market target that is not
  loop((ttot,emiMktExt,target_type_47,emi_type_47)$((pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47))),
    p47_marketConverged_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) = 0; !! this market target not yet FROZEN this iteration (see the frozen-vs-met note below)
    p47_slopeAux("rollIter") = 0; !! iteration whose price path to restore if this target ends up frozen (0 = keep the current price)
    p47_slopeAux("wantRoll") = 0; !! set by the branches that GIVE UP on a target, so the rollback block below runs

***   closest earlier target terminal year of this region.
    p47_slopeAux("prevTgtYr") = 0;
    loop(ttot3$(regiANDperiodEmiMktTarget_47(ttot3,ext_regi) AND (ttot3.val lt ttot2.val)),
      p47_slopeAux("prevTgtYr") = max(p47_slopeAux("prevTgtYr"), ttot3.val);
    );

*** Rollback verify-and-undo: A rollback is a bet that can fail if other regions moved. 
*** Test it on the next iteration; if |dev| got worse, undo it and lock out future rollbacks (rolledBack = 2).
    if((p47_slopeParam("rollbackVerify") gt 0)
       AND (p47_targetState("rolledBack",ttot,ttot2,ext_regi,emiMktExt) eq 1)
       AND (p47_targetState("rollFromIter",ttot,ttot2,ext_regi,emiMktExt) gt 0)
       AND (iteration.val eq p47_targetState("rollFromIter",ttot,ttot2,ext_regi,emiMktExt) + 1)
       AND (abs(pm_emiMktTarget_dev_iter(iteration,ttot,ttot2,ext_regi,emiMktExt))
            gt p47_targetState("rollFromDev",ttot,ttot2,ext_regi,emiMktExt)),
      loop(regi$regi_groupExt(ext_regi,regi),
        loop(emiMkt$emiMktGroup(emiMktExt,emiMkt),
          pm_taxemiMkt(ttot4,regi,emiMkt)$(ttot4.val gt p47_slopeAux("prevTgtYr")) =
            sum(iteration2$(iteration2.val eq p47_targetState("rollFromIter",ttot,ttot2,ext_regi,emiMktExt)), pm_taxemiMkt_iteration(iteration2,ttot4,regi,emiMkt));
        );
      );
      p47_targetState("rolledBack",ttot,ttot2,ext_regi,emiMktExt) = 2; !! rollback tried and rejected - never roll this target again
      p47_slopeTrace_iter("rollUndo",iteration,ttot,ttot2,ext_regi,emiMktExt) = p47_targetState("rollFromIter",ttot,ttot2,ext_regi,emiMktExt);
      put_utility "msg" / "Rollback UNDONE (deviation got worse): restored iteration " p47_targetState("rollFromIter",ttot,ttot2,ext_regi,emiMktExt):3:0 " price for ";
      put_utility "msg" / ttot.tl " " ttot2.tl " " ext_regi.tl " " emiMktExt.tl;
    );

*** Check Convergence:
*** 1. Strictly use raw user tolerance (pm_emiMktTarget_tolerance). Unreachable targets freeze with their real residual.
*** 2. smallPrice: If price hits floor (<1.1 $/tCO2) and emissions are below target, freeze as met (non-binding market).
    loop(regi$regi_groupExt(ext_regi,regi),
      loop(emiMkt$emiMktGroup(emiMktExt,emiMkt),
        if((((pm_taxemiMkt(ttot2,regi,emiMkt) - 1*sm_DptCO2_2_TDpGtC) lt 0.1*sm_DptCO2_2_TDpGtC) and (pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt) lt 0)),
          regiEmiMktconvergenceType(iteration,ttot,ttot2,ext_regi,emiMktExt,"smallPrice") = YES;
          p47_marketConverged_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) = 1;
        );
      );
    );
*** otherwise apply the hysteresis/persistence tolerance test on this target's (aggregate) deviation
    if(p47_marketConverged_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) eq 0,
***   HOLD: Keep previously converged target frozen through temporary Nash noise. Re-open only if deviation stays outside the EXIT band for `persist` consecutive iterations.
      if(p47_marketConverged_iter(iteration-1,ttot,ttot2,ext_regi,emiMktExt) eq 1,
***     Count iterations outside exit band (exitFrac * tolerance). The EXIT band must be wider than the ENTER band (hysteresis) to prevent minor noise from repeatedly breaking the hold.
        p47_slopeAux("outBand") = 0;
        loop(iteration2$((iteration2.val le iteration.val) and (iteration2.val gt iteration.val - p47_slopeParam("persist"))),
          p47_slopeAux("outBand") = p47_slopeAux("outBand")
            + 1$(abs(pm_emiMktTarget_dev_iter(iteration2,ttot,ttot2,ext_regi,emiMktExt)) gt p47_slopeParam("exitFrac")*pm_emiMktTarget_tolerance(ext_regi));
        );
        p47_slopeAux("holdOk") = 0;
***     Persistence only: Do not check current-iteration deviation; requiring in-band status every single iteration would un-freeze targets on minor noise wobbles. (Runaway targets are caught by divergence checks).
        p47_slopeAux("holdOk")$(p47_slopeAux("outBand") lt p47_slopeParam("persist")) = 1;
        if(p47_slopeAux("holdOk") eq 1,
***       Label by outcome: Assign lowerThanTolerance if |dev| <= raw tolerance, otherwise bestAchievable.
          regiEmiMktconvergenceType(iteration,ttot,ttot2,ext_regi,emiMktExt,"lowerThanTolerance")$(abs(pm_emiMktTarget_dev_iter(iteration,ttot,ttot2,ext_regi,emiMktExt)) le pm_emiMktTarget_tolerance(ext_regi)) = YES;
          regiEmiMktconvergenceType(iteration,ttot,ttot2,ext_regi,emiMktExt,"bestAchievable")$(abs(pm_emiMktTarget_dev_iter(iteration,ttot,ttot2,ext_regi,emiMktExt)) gt pm_emiMktTarget_tolerance(ext_regi)) = YES;
          p47_marketConverged_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) = 1;
        else
***       Hold failed (un-freezing target). 3 Outcomes:
***         (a) |dev| <= reopenMaxDev & budget left: Re-open target (charge reopenMax budget, cap first step).
***         (b) Budget spent: Give up, freeze as bestAchievable, roll back price.
***         (c) |dev| > reopenMaxDev: Stay frozen if given up; otherwise release uncharged (releaseCount).
          if((p47_slopeParam("reopenMaxDev") gt 0)
             AND (abs(pm_emiMktTarget_dev_iter(iteration,ttot,ttot2,ext_regi,emiMktExt)) le p47_slopeParam("reopenMaxDev")),
            if(p47_targetState("reopenCount",ttot,ttot2,ext_regi,emiMktExt) lt p47_slopeParam("reopenMax"),
              p47_targetState("reopenCount",ttot,ttot2,ext_regi,emiMktExt) = p47_targetState("reopenCount",ttot,ttot2,ext_regi,emiMktExt) + 1;
              p47_targetState("reopenIter",ttot,ttot2,ext_regi,emiMktExt)  = iteration.val;
***           Reset aim attempts (aimTries = 0) so the re-opened target gets a fresh budget to aim for the tighter enterFrac band.
              p47_targetState("aimTries",ttot,ttot2,ext_regi,emiMktExt)     = 0;
            else
              regiEmiMktconvergenceType(iteration,ttot,ttot2,ext_regi,emiMktExt,"bestAchievable") = YES;
              p47_marketConverged_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) = 1;
              p47_targetState("giveUp",ttot,ttot2,ext_regi,emiMktExt) = 1;
              p47_slopeAux("wantRoll") = 1; !! giving up after reopenMax corrections -> keep the best state reached
            );
***       Stick hold: Permanently freeze abandoned targets (giveUp = 1) to prevent price runaways.
          elseif p47_targetState("giveUp",ttot,ttot2,ext_regi,emiMktExt) eq 1,
            regiEmiMktconvergenceType(iteration,ttot,ttot2,ext_regi,emiMktExt,"bestAchievable") = YES;
            p47_marketConverged_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) = 1;
          else
***       Genuine release: not given up on, but thrown further out than a drift (or re-open switched off via reopenMaxDev). p47_marketConverged_iter stays 0, so the target simply steers again, uncharged.
            p47_targetState("releaseCount",ttot,ttot2,ext_regi,emiMktExt) = p47_targetState("releaseCount",ttot,ttot2,ext_regi,emiMktExt) + 1;
***       Reset aimTries = 0 for released targets too so they get a fresh budget to aim for enterFrac.
            p47_targetState("aimTries",ttot,ttot2,ext_regi,emiMktExt) = 0;
          );
        );
***     ENTER (Convergence Criteria) - Two ways in:
***     (1) AIM: |dev| <= enterFrac (0.75x tolerance) for `persist` iterations (normal path, gives drift buffer).
***     (2) ACCEPT: |dev| <= 1.0x raw tolerance once aimMaxTries attempts are spent (prevents hanging).
***     An aim attempt (aimTries) counts only iterations actively steered AND inside raw tolerance.
      else
        p47_slopeAux("inBand")  = 0;
        loop(iteration2$((iteration2.val le iteration.val) and (iteration2.val gt iteration.val - p47_slopeParam("persist"))),
          p47_slopeAux("inBand") = p47_slopeAux("inBand")
            + 1$(abs(pm_emiMktTarget_dev_iter(iteration2,ttot,ttot2,ext_regi,emiMktExt)) le p47_slopeParam("enterFrac")*pm_emiMktTarget_tolerance(ext_regi));
        );
***     Increment aimTries if steered and inside tolerance; capped at aimMaxTries for accurate reporting.
        if((abs(pm_emiMktTarget_dev_iter(iteration,ttot,ttot2,ext_regi,emiMktExt)) le pm_emiMktTarget_tolerance(ext_regi))
           AND (p47_currentConvergence_iter(iteration-1,ttot2,ext_regi) eq 1),
          p47_targetState("aimTries",ttot,ttot2,ext_regi,emiMktExt) =
            min(p47_targetState("aimTries",ttot,ttot2,ext_regi,emiMktExt) + 1, max(1, p47_slopeParam("aimMaxTries")));
        );
***     ACCEPT: budget spent and currently inside the tolerance -> stop polishing, hand the solve to the next target
        p47_slopeAux("inBand")$((p47_slopeAux("inBand") lt p47_slopeParam("persist"))
                                AND (p47_slopeParam("aimMaxTries") ge 1)
                                AND (p47_targetState("aimTries",ttot,ttot2,ext_regi,emiMktExt) ge p47_slopeParam("aimMaxTries"))
                                AND (abs(pm_emiMktTarget_dev_iter(iteration,ttot,ttot2,ext_regi,emiMktExt))
                                     le pm_emiMktTarget_tolerance(ext_regi))) = p47_slopeParam("persist");
        p47_slopeAux("priceOk") = 1;
        if((p47_slopeParam("priceEps") gt 0) and (iteration.val gt 1),
***       require every constituent market price of this target to have settled
          loop(regi$regi_groupExt(ext_regi,regi),
            loop(emiMkt$emiMktGroup(emiMktExt,emiMkt),
              if(abs(pm_taxemiMkt_iteration(iteration,ttot2,regi,emiMkt) - pm_taxemiMkt_iteration(iteration-1,ttot2,regi,emiMkt)) gt p47_slopeParam("priceEps")*pm_taxemiMkt_iteration(iteration,ttot2,regi,emiMkt),
                p47_slopeAux("priceOk") = 0;
              );
            );
          );
        );
        if((p47_slopeAux("inBand") ge p47_slopeParam("persist")) and (p47_slopeAux("priceOk") eq 1),
***       raw tolerance - see the identical pair in the HOLD branch above
          regiEmiMktconvergenceType(iteration,ttot,ttot2,ext_regi,emiMktExt,"lowerThanTolerance")$(abs(pm_emiMktTarget_dev_iter(iteration,ttot,ttot2,ext_regi,emiMktExt)) le pm_emiMktTarget_tolerance(ext_regi)) = YES;
          regiEmiMktconvergenceType(iteration,ttot,ttot2,ext_regi,emiMktExt,"bestAchievable")$(abs(pm_emiMktTarget_dev_iter(iteration,ttot,ttot2,ext_regi,emiMktExt)) gt pm_emiMktTarget_tolerance(ext_regi)) = YES;
          p47_marketConverged_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) = 1;
        );
      );
    );

***   NOISE-FLOOR STOP (Give-Up): If price is settled and deviation is trapped in a narrow band outside tolerance, accept bestAchievable and freeze. (Guarded by |dev| > tolerance; disabled by noiseFloorMaxDev = 0).
    if((p47_marketConverged_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) eq 0)
       AND (p47_slopeParam("noiseFloorMaxDev") gt 0)
       AND (abs(pm_emiMktTarget_dev_iter(iteration,ttot,ttot2,ext_regi,emiMktExt)) gt pm_emiMktTarget_tolerance(ext_regi))
       AND (abs(pm_emiMktTarget_dev_iter(iteration,ttot,ttot2,ext_regi,emiMktExt)) le p47_slopeParam("noiseFloorMaxDev")),
      p47_slopeAux("devMax")  = -inf;
      p47_slopeAux("devMin")  = inf;
      p47_slopeAux("settled") = 0;
      p47_slopeAux("nWin")    = 0;
***   Find the lowest deviation within the current window (window-local best) for potential rollback.
      p47_slopeAux("devAbsMin")  = inf;
      p47_slopeAux("bestWinIter") = 0;
      loop(iteration2$((iteration2.val le iteration.val) and (iteration2.val gt iteration.val - p47_slopeParam("maxWindow"))),
        p47_slopeAux("devMax") = max(p47_slopeAux("devMax"), pm_emiMktTarget_dev_iter(iteration2,ttot,ttot2,ext_regi,emiMktExt));
        p47_slopeAux("devMin") = min(p47_slopeAux("devMin"), pm_emiMktTarget_dev_iter(iteration2,ttot,ttot2,ext_regi,emiMktExt));
        p47_slopeAux("nWin")   = p47_slopeAux("nWin") + 1;
        if((iteration2.val lt iteration.val)
           AND (abs(pm_emiMktTarget_dev_iter(iteration2,ttot,ttot2,ext_regi,emiMktExt)) lt p47_slopeAux("devAbsMin")),
          p47_slopeAux("devAbsMin")   = abs(pm_emiMktTarget_dev_iter(iteration2,ttot,ttot2,ext_regi,emiMktExt));
          p47_slopeAux("bestWinIter") = iteration2.val;
        );
***     price settled = the tax rescale factor stayed within minPriceSpread of 1 (only the already-computed past iterations)
        p47_slopeAux("settled") = p47_slopeAux("settled")
          + 1$((iteration2.val lt iteration.val) and (abs(p47_factorRescaleemiMktCO2Tax_iter(iteration2,ttot,ttot2,ext_regi,emiMktExt) - 1) le p47_slopeParam("minPriceSpread")));
      );
***     Fire only when deviation is narrow, price is settled, and full window history exists.
      if(((p47_slopeAux("devMax") - p47_slopeAux("devMin")) le max(p47_slopeParam("noiseFloorBandWidth"), p47_slopeParam("noiseFloorBandWidthRel") * pm_emiMktTarget_tolerance(ext_regi)))
         AND (p47_slopeAux("settled") ge (p47_slopeAux("nWin") - 1))
         AND (p47_slopeAux("nWin") ge p47_slopeParam("maxWindow")),
        regiEmiMktconvergenceType(iteration,ttot,ttot2,ext_regi,emiMktExt,"bestAchievable") = YES;
        p47_marketConverged_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) = 1;
        p47_targetState("giveUp",ttot,ttot2,ext_regi,emiMktExt) = 1; !! noise-floor stop: a deliberate give-up, must stay frozen
***     Roll back to the best deviation in the window if the entire window was strictly outside tolerance.
        if((p47_slopeParam("noiseFloorRollback") ge 0.5)
           AND (p47_slopeAux("bestWinIter") gt 0)
           AND (p47_slopeAux("devAbsMin") gt pm_emiMktTarget_tolerance(ext_regi))
           AND (p47_slopeAux("devAbsMin") lt abs(pm_emiMktTarget_dev_iter(iteration,ttot,ttot2,ext_regi,emiMktExt))),
          p47_slopeAux("wantRoll") = 1;
          p47_slopeAux("rollIter") = p47_slopeAux("bestWinIter");
        );
      );
    );

*** Parked-target stop: Gives up on targets trapped by hysteresis (held converged, but sitting outside raw tolerance and inside EXIT band). (Dormant when exitFrac = 1.0).
    if((p47_slopeParam("parkedStop") ge 0.5)
       AND (p47_marketConverged_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) eq 1)
       AND (p47_targetState("giveUp",ttot,ttot2,ext_regi,emiMktExt) eq 0)
       AND (NOT regiEmiMktconvergenceType(iteration,ttot,ttot2,ext_regi,emiMktExt,"smallPrice"))
       AND (abs(pm_emiMktTarget_dev_iter(iteration,ttot,ttot2,ext_regi,emiMktExt)) gt pm_emiMktTarget_tolerance(ext_regi))
       AND (abs(pm_emiMktTarget_dev_iter(iteration,ttot,ttot2,ext_regi,emiMktExt)) le p47_slopeParam("exitFrac") * pm_emiMktTarget_tolerance(ext_regi)),
      p47_slopeAux("devMax")    = -inf;
      p47_slopeAux("devMin")    =  inf;
      p47_slopeAux("devAbsMin") =  inf;
      p47_slopeAux("nWin")      = 0;
      loop(iteration2$((iteration2.val le iteration.val) and (iteration2.val gt iteration.val - p47_slopeParam("maxWindow"))),
        p47_slopeAux("devMax")    = max(p47_slopeAux("devMax"), pm_emiMktTarget_dev_iter(iteration2,ttot,ttot2,ext_regi,emiMktExt));
        p47_slopeAux("devMin")    = min(p47_slopeAux("devMin"), pm_emiMktTarget_dev_iter(iteration2,ttot,ttot2,ext_regi,emiMktExt));
        p47_slopeAux("devAbsMin") = min(p47_slopeAux("devAbsMin"), abs(pm_emiMktTarget_dev_iter(iteration2,ttot,ttot2,ext_regi,emiMktExt)));
        p47_slopeAux("nWin")      = p47_slopeAux("nWin") + 1;
      );
***   Confirm target is truly parked (devAbsMin > tolerance): Ensures deviation never dipped inside tolerance during the window, leaving noisy oscillating targets alone to finish converging.
      if((p47_slopeAux("nWin") ge p47_slopeParam("maxWindow"))
         AND (p47_slopeAux("devAbsMin") gt pm_emiMktTarget_tolerance(ext_regi))
         AND ((p47_slopeAux("devMax") - p47_slopeAux("devMin")) le max(p47_slopeParam("noiseFloorBandWidth"), p47_slopeParam("noiseFloorBandWidthRel") * pm_emiMktTarget_tolerance(ext_regi))),
        regiEmiMktconvergenceType(iteration,ttot,ttot2,ext_regi,emiMktExt,"bestAchievable") = YES;
        p47_targetState("giveUp",ttot,ttot2,ext_regi,emiMktExt) = 1; !! parked stop: a deliberate give-up, must stay frozen
        p47_slopeTrace_iter("parked",iteration,ttot,ttot2,ext_regi,emiMktExt) = 1;
***     No rollback needed: Target was frozen for the whole window, so price was constant.
        put_utility "msg" / "Parked-target stop: held inside the exit band but outside the tolerance at deviation ";
        put_utility "msg" / pm_emiMktTarget_dev_iter(iteration,ttot,ttot2,ext_regi,emiMktExt):10:5 " for " ttot.tl " " ttot2.tl " " ext_regi.tl " " emiMktExt.tl;
      );
    );

***   Infeasible-target stop: Give up & freeze when price rescale hits the cap for a full window without reaching the target.
    if((p47_marketConverged_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) eq 0)
       AND (p47_slopeParam("noiseFloorMaxDev") gt 0)
       AND (abs(pm_emiMktTarget_dev_iter(iteration,ttot,ttot2,ext_regi,emiMktExt)) gt p47_slopeParam("noiseFloorMaxDev")),
      p47_slopeAux("atCap")    = 0;
      p47_slopeAux("nWin")     = 0;
      p47_slopeAux("emiMin")   = inf;
      p47_slopeAux("devAbsMax") = 0;
      p47_slopeAux("devMax")   = -inf;
      p47_slopeAux("devMin")   =  inf;
      loop(iteration2$((iteration2.val lt iteration.val) and (iteration2.val ge iteration.val - p47_slopeParam("maxWindow"))),
        p47_slopeAux("nWin")  = p47_slopeAux("nWin") + 1;
        p47_slopeAux("atCap") = p47_slopeAux("atCap")
          + 1$(p47_factorRescaleemiMktCO2Tax_iter(iteration2,ttot,ttot2,ext_regi,emiMktExt) ge (1 - p47_slopeParam("minPriceSpread")) * p47_slopeParam("rescaleCapHi"));
        p47_slopeAux("emiMin") = min(p47_slopeAux("emiMin"), p47_emiMktCurrent_iter(iteration2,ttot,ttot2,ext_regi,emiMktExt));
        p47_slopeAux("devAbsMax") = max(p47_slopeAux("devAbsMax"), abs(pm_emiMktTarget_dev_iter(iteration2,ttot,ttot2,ext_regi,emiMktExt)));
        p47_slopeAux("devMax") = max(p47_slopeAux("devMax"), pm_emiMktTarget_dev_iter(iteration2,ttot,ttot2,ext_regi,emiMktExt));
        p47_slopeAux("devMin") = min(p47_slopeAux("devMin"), pm_emiMktTarget_dev_iter(iteration2,ttot,ttot2,ext_regi,emiMktExt));
      );
***   Declare infeasible only if: (a) rescale pinned at max cap for full window, (b) deviation stalled (no longer shrinking), and (c) deviation is one-sided (never crossed target).
      if((p47_slopeAux("nWin") ge p47_slopeParam("maxWindow")) AND (p47_slopeAux("atCap") ge p47_slopeAux("nWin"))
         AND (abs(pm_emiMktTarget_dev_iter(iteration,ttot,ttot2,ext_regi,emiMktExt)) ge p47_slopeParam("infeasStallFrac") * p47_slopeAux("devAbsMax"))
         AND (NOT((p47_slopeAux("devMax") gt 0) AND (p47_slopeAux("devMin") lt 0))),
        regiEmiMktconvergenceType(iteration,ttot,ttot2,ext_regi,emiMktExt,"bestAchievable") = YES;
        p47_marketConverged_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) = 1;
        p47_targetState("giveUp",ttot,ttot2,ext_regi,emiMktExt) = 1; !! infeasible-target stop: a deliberate give-up, must stay frozen
        p47_slopeAux("wantRoll") = 1; !! giving up on an (locally) infeasible target -> keep the best state reached
***     Roll back to the "knee": Find the earliest iteration that achieved nearly the same minimum emissions at a much lower, realistic price. (Disabled by infeasEmiTol = 0).
        if(p47_slopeParam("infeasEmiTol") gt 0,
          p47_slopeAux("kneeIter") = iteration.val;
          loop(iteration2$((iteration2.val lt iteration.val) and (iteration2.val ge iteration.val - p47_slopeParam("maxWindow"))
                           and (p47_emiMktCurrent_iter(iteration2,ttot,ttot2,ext_regi,emiMktExt)
                                le p47_slopeAux("emiMin") + p47_slopeParam("infeasEmiTol") * max(abs(p47_slopeAux("emiMin")), pm_emiMktRefYear(ttot,ttot2,ext_regi,emiMktExt), p47_emiMktRefBudget(ttot,ttot2,ext_regi,emiMktExt)))),
            p47_slopeAux("kneeIter") = min(p47_slopeAux("kneeIter"), iteration2.val);
          );
          if(p47_slopeAux("kneeIter") lt iteration.val,
            p47_slopeAux("rollIter") = p47_slopeAux("kneeIter");
          );
        );
      );
    );

*** DIVERGENCE HANDLING: Catches oscillating runaway targets. Triggers only if ALL 3 hurdles are met:
*** (1) Armed (divArmed = 1), (2) Persistent (dev > divergeFactor * bestDev for `persist` iterations), and (3) Not recovering (deviation stalled). (divergeFactor < 1 disables).
    if((p47_marketConverged_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) eq 0)
       AND (p47_slopeParam("divergeFactor") ge 1)
       AND (p47_targetState("divArmed",ttot,ttot2,ext_regi,emiMktExt) eq 1),
      p47_slopeAux("divOut") = 0;
      p47_slopeAux("divMax") = 0;
      loop(iteration2$((iteration2.val le iteration.val) and (iteration2.val gt iteration.val - p47_slopeParam("persist"))),
        p47_slopeAux("divOut") = p47_slopeAux("divOut")
          + 1$(abs(pm_emiMktTarget_dev_iter(iteration2,ttot,ttot2,ext_regi,emiMktExt))
               gt p47_slopeParam("divergeFactor")
                  * max(p47_targetState("bestDevAbs",ttot,ttot2,ext_regi,emiMktExt), pm_emiMktTarget_tolerance(ext_regi)));
        p47_slopeAux("divMax") = max(p47_slopeAux("divMax"), abs(pm_emiMktTarget_dev_iter(iteration2,ttot,ttot2,ext_regi,emiMktExt)));
      );
      if((p47_slopeAux("divOut") ge p47_slopeParam("persist"))
         AND (abs(pm_emiMktTarget_dev_iter(iteration,ttot,ttot2,ext_regi,emiMktExt))
              ge p47_slopeParam("infeasStallFrac") * p47_slopeAux("divMax")),
***     Find the lowest deviation within the recent window (rollbackMaxAge), ensuring we roll back to a recent, relevant price path rather than an ancient one.
        p47_slopeAux("divRoll") = 0;
        p47_slopeAux("divBest") = abs(pm_emiMktTarget_dev_iter(iteration,ttot,ttot2,ext_regi,emiMktExt));
        loop(iteration2$((iteration2.val lt iteration.val)
                         and (iteration2.val ge iteration.val - max(1, p47_slopeParam("rollbackMaxAge")))),
          if(abs(pm_emiMktTarget_dev_iter(iteration2,ttot,ttot2,ext_regi,emiMktExt)) lt p47_slopeAux("divBest"),
            p47_slopeAux("divBest") = abs(pm_emiMktTarget_dev_iter(iteration2,ttot,ttot2,ext_regi,emiMktExt));
            p47_slopeAux("divRoll") = iteration2.val;
          );
        );
***     SENTINEL: Require divergeBrakeMax >= 1 so config sentinel values < 1 mean "freeze on first detection" (no brakes).
        if((p47_slopeParam("divergeBrakeMax") ge 1)
           AND (p47_targetState("divBrakeCount",ttot,ttot2,ext_regi,emiMktExt) lt p47_slopeParam("divergeBrakeMax")),
***       BRAKE (Reversible): Restore window-local best price and keep steering. Cap next step at reopenStepCap to prevent re-divergence.
          p47_targetState("divBrakeCount",ttot,ttot2,ext_regi,emiMktExt) = p47_targetState("divBrakeCount",ttot,ttot2,ext_regi,emiMktExt) + 1;
          if(p47_slopeAux("divRoll") gt 0,
            loop(regi$regi_groupExt(ext_regi,regi),
              loop(emiMkt$emiMktGroup(emiMktExt,emiMkt),
                pm_taxemiMkt(ttot4,regi,emiMkt)$(ttot4.val gt p47_slopeAux("prevTgtYr")) =
                  sum(iteration2$(iteration2.val eq p47_slopeAux("divRoll")), pm_taxemiMkt_iteration(iteration2,ttot4,regi,emiMkt));
              );
            );
          );
          p47_targetState("reopenIter",ttot,ttot2,ext_regi,emiMktExt) = iteration.val;
          p47_slopeTrace_iter("divBrake",iteration,ttot,ttot2,ext_regi,emiMktExt) = p47_slopeAux("divRoll");
          put_utility "msg" / "Divergence BRAKE (" p47_targetState("divBrakeCount",ttot,ttot2,ext_regi,emiMktExt):2:0 " of " p47_slopeParam("divergeBrakeMax"):2:0 "): deviation ";
          put_utility "msg" / pm_emiMktTarget_dev_iter(iteration,ttot,ttot2,ext_regi,emiMktExt):10:5 " -> price restored to iteration " p47_slopeAux("divRoll"):3:0;
          put_utility "msg" / " and still steering, for " ttot.tl " " ttot2.tl " " ext_regi.tl " " emiMktExt.tl;
        else
***       BRAKES EXHAUSTED: Target keeps diverging after max brakes. Freeze at best state (giveUp = 1).
          regiEmiMktconvergenceType(iteration,ttot,ttot2,ext_regi,emiMktExt,"bestAchievable") = YES;
          p47_marketConverged_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) = 1;
          p47_targetState("giveUp",ttot,ttot2,ext_regi,emiMktExt) = 1; !! divergence stop: a deliberate give-up, must stay frozen
          p47_slopeAux("wantRoll") = 1;
          put_utility "msg" / "Divergence STOP (brake budget spent): deviation " pm_emiMktTarget_dev_iter(iteration,ttot,ttot2,ext_regi,emiMktExt):10:5 " far beyond best ";
          put_utility "msg" / p47_targetState("bestDevAbs",ttot,ttot2,ext_regi,emiMktExt):10:5 " for " ttot.tl " " ttot2.tl " " ext_regi.tl " " emiMktExt.tl;
        );
      );
    );

***   PRICE ROLLBACK ON FREEZE: Prefer run-wide best-so-far price if meaningfully better (|dev_best| <= rollbackBestFrac * |dev_now|) and recent enough (rollbackMaxAge). Otherwise keep stop's candidate price.
    if((p47_slopeAux("wantRoll") eq 1)
       AND (p47_targetState("rolledBack",ttot,ttot2,ext_regi,emiMktExt) eq 0)
       AND (p47_marketConverged_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) eq 1)
       AND regiEmiMktconvergenceType(iteration,ttot,ttot2,ext_regi,emiMktExt,"bestAchievable"),
      if((p47_slopeParam("rollbackBestFrac") gt 0)
         AND (p47_targetState("bestDevIter",ttot,ttot2,ext_regi,emiMktExt) gt 0)
         AND (p47_targetState("bestDevIter",ttot,ttot2,ext_regi,emiMktExt) lt iteration.val)
         AND ((p47_slopeParam("rollbackMaxAge") le 0)
              OR (p47_targetState("bestDevIter",ttot,ttot2,ext_regi,emiMktExt) ge iteration.val - p47_slopeParam("rollbackMaxAge")))
         AND (p47_targetState("bestDevAbs",ttot,ttot2,ext_regi,emiMktExt)
              le p47_slopeParam("rollbackBestFrac") * abs(pm_emiMktTarget_dev_iter(iteration,ttot,ttot2,ext_regi,emiMktExt))),
        p47_slopeAux("rollIter") = p47_targetState("bestDevIter",ttot,ttot2,ext_regi,emiMktExt);
      );
***   No rollback candidate (disabled, not better, or too old): Keep current price.
      if(p47_slopeAux("rollIter") gt 0,
        loop(regi$regi_groupExt(ext_regi,regi),
          loop(emiMkt$emiMktGroup(emiMktExt,emiMkt),
            pm_taxemiMkt(ttot4,regi,emiMkt)$(ttot4.val gt p47_slopeAux("prevTgtYr")) =
              sum(iteration2$(iteration2.val eq p47_slopeAux("rollIter")), pm_taxemiMkt_iteration(iteration2,ttot4,regi,emiMkt));
          );
        );
        p47_slopeTrace_iter("rollIter",iteration,ttot,ttot2,ext_regi,emiMktExt) = p47_slopeAux("rollIter");
        p47_targetState("rolledBack",ttot,ttot2,ext_regi,emiMktExt) = 1;
***     Store pre-rollback iteration and deviation to verify and undo on next iteration if worse.
        p47_targetState("rollFromIter",ttot,ttot2,ext_regi,emiMktExt) = iteration.val;
        p47_targetState("rollFromDev",ttot,ttot2,ext_regi,emiMktExt)  = abs(pm_emiMktTarget_dev_iter(iteration,ttot,ttot2,ext_regi,emiMktExt));
        put_utility "msg" / "Best-achievable freeze: price rolled back to iteration " p47_slopeAux("rollIter"):3:0 " for ";
        put_utility "msg" / ttot.tl " " ttot2.tl " " ext_regi.tl " " emiMktExt.tl;
      );
    );

***   NOTE: reopenCount is never reset by re-convergence (prevents limit-cycles). It is cleared only after reopenRefresh consecutive settled iterations.

***   FROZEN vs MET: p47_marketConverged_iter = stop steering price. p47_marketMet_iter = target achieved within raw tolerance (or slack smallPrice).
    p47_marketMet_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) = 0;
    if((abs(pm_emiMktTarget_dev_iter(iteration,ttot,ttot2,ext_regi,emiMktExt)) le pm_emiMktTarget_tolerance(ext_regi))
       OR regiEmiMktconvergenceType(iteration,ttot,ttot2,ext_regi,emiMktExt,"smallPrice"),
      p47_marketMet_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) = 1;
    );

***   RE-OPEN BUDGET REFRESH: Targets frozen and met for reopenRefresh consecutive iterations earn their re-open budget back (reopenCount = 0).
    if((p47_slopeParam("reopenRefresh") ge 1)
       AND (p47_marketConverged_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) eq 1)
       AND (p47_marketMet_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) eq 1)
       AND (p47_targetState("giveUp",ttot,ttot2,ext_regi,emiMktExt) eq 0),
      p47_targetState("settledCount",ttot,ttot2,ext_regi,emiMktExt) = p47_targetState("settledCount",ttot,ttot2,ext_regi,emiMktExt) + 1;
***   Increment refreshCount only when a spent budget (reopenCount > 0) is actually restored.
      if(p47_targetState("settledCount",ttot,ttot2,ext_regi,emiMktExt) ge p47_slopeParam("reopenRefresh"),
        if(p47_targetState("reopenCount",ttot,ttot2,ext_regi,emiMktExt) gt 0,
          put_utility "msg" / "Re-open budget refreshed after " p47_targetState("settledCount",ttot,ttot2,ext_regi,emiMktExt):3:0 " settled iterations for ";
          put_utility "msg" / ttot.tl " " ttot2.tl " " ext_regi.tl " " emiMktExt.tl;
          p47_targetState("refreshCount",ttot,ttot2,ext_regi,emiMktExt) = p47_targetState("refreshCount",ttot,ttot2,ext_regi,emiMktExt) + 1;
        );
        p47_targetState("reopenCount",ttot,ttot2,ext_regi,emiMktExt)  = 0;
        p47_targetState("settledCount",ttot,ttot2,ext_regi,emiMktExt) = 0;
      );
    else
      p47_targetState("settledCount",ttot,ttot2,ext_regi,emiMktExt) = 0;
    );

***   HONESTY RE-LABEL (Promotion): If a given-up target lands inside raw tolerance (met), promote label to lowerThanTolerance.
    if((p47_marketMet_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) eq 1)
       AND regiEmiMktconvergenceType(iteration,ttot,ttot2,ext_regi,emiMktExt,"bestAchievable")
       AND (NOT regiEmiMktconvergenceType(iteration,ttot,ttot2,ext_regi,emiMktExt,"smallPrice")),
      regiEmiMktconvergenceType(iteration,ttot,ttot2,ext_regi,emiMktExt,"bestAchievable")     = NO;
      regiEmiMktconvergenceType(iteration,ttot,ttot2,ext_regi,emiMktExt,"lowerThanTolerance") = YES;
    );

***   HONESTY RE-LABEL (Demotion): Frozen targets outside the EXIT band are re-labelled as unmetFrozen (replaces lowerThanTolerance and bestAchievable).
    if((p47_marketConverged_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) eq 1)
       AND (p47_marketMet_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) eq 0)
       AND (abs(pm_emiMktTarget_dev_iter(iteration,ttot,ttot2,ext_regi,emiMktExt))
            gt p47_slopeParam("exitFrac") * pm_emiMktTarget_tolerance(ext_regi)),
      regiEmiMktconvergenceType(iteration,ttot,ttot2,ext_regi,emiMktExt,"lowerThanTolerance") = NO;
      regiEmiMktconvergenceType(iteration,ttot,ttot2,ext_regi,emiMktExt,"bestAchievable")     = NO;
      regiEmiMktconvergenceType(iteration,ttot,ttot2,ext_regi,emiMktExt,"unmetFrozen")        = YES;
    );

***   AND aggregation: the region-period is not converged if this market target is not converged
    if(p47_marketConverged_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) eq 0,
      p47_targetConverged(ttot2,ext_regi) = 0;
    );
***   ... and separately, not MET if this market target is not met
    if(p47_marketMet_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) eq 0,
      p47_targetMet(ttot2,ext_regi) = 0;
    );
  );
);
p47_targetConverged_iter(iteration,ttot2,ext_regi) = p47_targetConverged(ttot2,ext_regi); !!save regional target converged iteration information for debugging
p47_targetMet_iter(iteration,ttot2,ext_regi)       = p47_targetMet(ttot2,ext_regi);       !!save regional target MET information (raw tolerance, no hysteresis) across iterations

*** CAP-TIME RE-CHECK: At the final iteration cap (cm_iteration_max), any target outside raw tolerance becomes unmetAtCap (excluding smallPrice).
if(ord(iteration) eq cm_iteration_max,
  loop((ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47)$pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47),
    if((abs(pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt)) gt pm_emiMktTarget_tolerance(ext_regi))
       AND (NOT regiEmiMktconvergenceType(iteration,ttot,ttot2,ext_regi,emiMktExt,"smallPrice")),
      regiEmiMktconvergenceType(iteration,ttot,ttot2,ext_regi,emiMktExt,"lowerThanTolerance") = NO;
      regiEmiMktconvergenceType(iteration,ttot,ttot2,ext_regi,emiMktExt,"bestAchievable")     = NO;
      regiEmiMktconvergenceType(iteration,ttot,ttot2,ext_regi,emiMktExt,"unmetFrozen")        = NO;
      regiEmiMktconvergenceType(iteration,ttot,ttot2,ext_regi,emiMktExt,"unmetAtCap")          = YES;
      put_utility "msg" / "Target still outside tolerance at the iteration cap: ";
      put_utility "msg" / ttot.tl " " ttot2.tl " " ext_regi.tl " " emiMktExt.tl " dev " pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt):10:5;
    );
  );
);

*** TWO TERMINATION SIGNALS: p47_allTargetsFrozen drives module 47 flow; pm_allTargetsConverged (read by module 80) requires targets to be frozen AND (met OR giveUp).
loop(ext_regi$regiEmiMktTarget(ext_regi),
  p47_allTargetsFrozen(ext_regi)   = 1;
  p47_allTargetsMet(ext_regi)      = 1;
  loop((ttot)$regiANDperiodEmiMktTarget_47(ttot,ext_regi),
    if(p47_targetConverged(ttot,ext_regi) eq 0,
      p47_allTargetsFrozen(ext_regi) = 0;
    );
    if(p47_targetMet(ttot,ext_regi) eq 0,
      p47_allTargetsMet(ext_regi) = 0;
    );
  );
***   Unmet AND not given up: run must not end yet
  p47_unmetNoGiveUp(ext_regi) = 0;
  loop((ttot,ttot2,emiMktExt,target_type_47,emi_type_47)$(pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47)
        AND (p47_marketMet_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) eq 0)
        AND (NOT regiEmiMktconvergenceType(iteration,ttot,ttot2,ext_regi,emiMktExt,"smallPrice"))
        AND (p47_targetState("giveUp",ttot,ttot2,ext_regi,emiMktExt) eq 0)),
    p47_unmetNoGiveUp(ext_regi) = 1;
  );
  pm_allTargetsConverged(ext_regi) = p47_allTargetsFrozen(ext_regi)$(p47_unmetNoGiveUp(ext_regi) eq 0);
);
p47_allTargetsConverged_iter(iteration,ext_regi) = pm_allTargetsConverged(ext_regi);
p47_allTargetsFrozen_iter(iteration,ext_regi)    = p47_allTargetsFrozen(ext_regi);
p47_allTargetsMet_iter(iteration,ext_regi)       = p47_allTargetsMet(ext_regi);

*** UNREACHABLE-TARGET WARNING: Log warning if a region is frozen but targets are unmet.
loop(ext_regi$(regiEmiMktTarget(ext_regi) AND (p47_allTargetsFrozen(ext_regi) eq 1) AND (p47_allTargetsMet(ext_regi) eq 0)),
  put_utility "msg" / "### WARNING: region " ext_regi.tl " is CONVERGED but its emission targets are NOT MET.";
  put_utility "msg" / "###          The convergence algorithm has stopped steering the carbon price of the targets";
  put_utility "msg" / "###          listed below; each carries the residual shown. Check regiEmiMktconvergenceType";
  put_utility "msg" / "###          (unmetFrozen / unmetAtCap / bestAchievable all carry a residual, lowerThanTolerance";
  put_utility "msg" / "###          and smallPrice do not) and p47_marketMet_iter for the per-market verdict.";
  loop((ttot,ttot2,emiMktExt,target_type_47,emi_type_47)$(pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47)
        AND (p47_marketMet_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) eq 0)),
    put_utility "msg" / "###          unmet: " ttot.tl " " ttot2.tl " " ext_regi.tl " " emiMktExt.tl
                        " dev " pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt):10:5
                        " tolerance " pm_emiMktTarget_tolerance(ext_regi):10:5;
*** END-OF-RUN RE-LABEL: Once fully frozen, re-label any target outside raw tolerance as unmetFrozen.
    if(NOT regiEmiMktconvergenceType(iteration,ttot,ttot2,ext_regi,emiMktExt,"unmetAtCap"),
      regiEmiMktconvergenceType(iteration,ttot,ttot2,ext_regi,emiMktExt,"lowerThanTolerance") = NO;
      regiEmiMktconvergenceType(iteration,ttot,ttot2,ext_regi,emiMktExt,"bestAchievable")     = NO;
      regiEmiMktconvergenceType(iteration,ttot,ttot2,ext_regi,emiMktExt,"unmetFrozen")        = YES;
    );
  );
);

*** ----- Sequential Target Solving & Fit Window Anchor -----

p47_currentConvergence_iter(iteration,ttot,ext_regi) = 0;
loop(ext_regi$regiEmiMktTarget(ext_regi),
  if(not(p47_allTargetsFrozen(ext_regi) eq 1), !!no rescale need if all targets already frozen
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

*** WINDOW ANCHOR: Measured in steered iterations (skipping frozen iterations) to hold up to maxWindow active price-steering iterations.
loop((ext_regi,ttot)$regiANDperiodEmiMktTarget_47(ttot,ext_regi),
  if(ord(iteration) eq 1,
    p47_slopeReferenceIteration_iter(iteration,ttot,ext_regi) = 1;
  else
***   how many steered iterations to walk past before the window starts (keep the LAST maxWindow of them)
    p47_slopeAux("nSteer")    = sum(iteration2$(iteration2.val le iteration.val), p47_currentConvergence_iter(iteration2,ttot,ext_regi));
    p47_slopeAux("skipSteer") = max(0, p47_slopeAux("nSteer") - p47_slopeParam("maxWindow"));
    p47_slopeAux("cntSteer")  = 0;
***   default: no steered history yet -> fresh start at this iteration (the squareDev_firstIteration cold-start ramp)
    p47_slopeReferenceIteration_iter(iteration,ttot,ext_regi) = ord(iteration);
*** walk the steered iterations in order and stop on the (skipSteer+1)-th - the oldest one still inside the
*** window. Written with the conditional-assign + `break$()` idiom used everywhere else in this file.
    loop(iteration2$((iteration2.val le iteration.val) AND (p47_currentConvergence_iter(iteration2,ttot,ext_regi) eq 1)),
      p47_slopeAux("cntSteer") = p47_slopeAux("cntSteer") + 1;
      p47_slopeReferenceIteration_iter(iteration,ttot,ext_regi)$(p47_slopeAux("cntSteer") eq (p47_slopeAux("skipSteer") + 1)) = iteration2.val;
      break$(p47_slopeAux("cntSteer") gt p47_slopeAux("skipSteer"));
    );
  );
);


*** ----- Least-Squares Slope & CO2 Tax Rescale Factor -----

*** resetting rescale factor for the next iteration
p47_factorRescaleSlope(ttot,ttot2,ext_regi,emiMktExt) = 0;
pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt) = 0;
regiEmiMktRescaleType(iteration,ttot,ttot2,ext_regi,emiMktExt,rescaleType) = NO;
*** Calculating the tax rescale factor from a least-squares slope of emissions vs. carbon price over the current window
loop(ext_regi$regiEmiMktTarget(ext_regi),
  loop((ttot2)$(ttot2.val eq p47_currentConvergencePeriod(ext_regi)),
    if(not(p47_targetConverged(ttot2,ext_regi) eq 1), !!no rescale factor calculation need if the target already converged
      loop((ttot,emiMktExt,target_type_47,emi_type_47)$(pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47)),
        loop(emiMkt$emiMktGroup(emiMktExt,emiMkt),
          loop(regi$regiEmiMktTarget2regi_47(ext_regi,regi),
***         if rescale factor was already calculated for ext_regi, there is no need to recalculate it
            continue$(sum(rescaleType$regiEmiMktRescaleType(iteration,ttot,ttot2,ext_regi,emiMktExt,rescaleType), 1));

            s47_slopeWindowStart = p47_slopeReferenceIteration_iter(iteration,ttot2,ext_regi);

***         CASE 1 - no usable history yet (window holds a single point): fall back to squareDev
            if((ord(iteration) - s47_slopeWindowStart) eq 0,
              regiEmiMktRescaleType(iteration,ttot,ttot2,ext_regi,emiMktExt,"squareDev_firstIteration") = YES;
              pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt) = power(1+pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt), 2);
            else
***           accumulate least-squares sums of (price, emissions) over the window [s47_slopeWindowStart .. iteration],
***           counting ONLY iterations in which this region-period was actually steering its own price. The anchor
***           above is chosen so that this collects at most maxWindow points. Iterations spent frozen contribute a
***           duplicate price and would flatten the fit - see the window-anchor note for why the window is measured
***           in steered iterations rather than calendar ones.
              p47_slopeAux(slopeTerm) = 0;
              p47_slopeAux("pMin") = inf; p47_slopeAux("pMax") = -inf;
              loop(iteration2$((iteration2.val ge s47_slopeWindowStart) AND (iteration2.val le iteration.val)
                               AND (p47_currentConvergence_iter(iteration2,ttot2,ext_regi) eq 1)),
                p47_slopeAux("n")     = p47_slopeAux("n")     + 1;
                p47_slopeAux("sumP")  = p47_slopeAux("sumP")  + pm_taxemiMkt_iteration(iteration2,ttot2,regi,emiMkt);
                p47_slopeAux("sumE")  = p47_slopeAux("sumE")  + p47_emiMktCurrent_iter(iteration2,ttot,ttot2,ext_regi,emiMktExt);
                p47_slopeAux("sumP2") = p47_slopeAux("sumP2") + sqr(pm_taxemiMkt_iteration(iteration2,ttot2,regi,emiMkt));
                p47_slopeAux("sumE2") = p47_slopeAux("sumE2") + sqr(p47_emiMktCurrent_iter(iteration2,ttot,ttot2,ext_regi,emiMktExt));
                p47_slopeAux("sumPE") = p47_slopeAux("sumPE") + pm_taxemiMkt_iteration(iteration2,ttot2,regi,emiMkt) * p47_emiMktCurrent_iter(iteration2,ttot,ttot2,ext_regi,emiMktExt);
                p47_slopeAux("pMin")  = min(p47_slopeAux("pMin"), pm_taxemiMkt_iteration(iteration2,ttot2,regi,emiMkt));
                p47_slopeAux("pMax")  = max(p47_slopeAux("pMax"), pm_taxemiMkt_iteration(iteration2,ttot2,regi,emiMkt));
              );
              p47_slopeAux("denom") = p47_slopeAux("n")*p47_slopeAux("sumP2") - sqr(p47_slopeAux("sumP")); !! = n^2 * var(price); zero only if every window price is identical
              p47_slopeAux("num")   = p47_slopeAux("n")*p47_slopeAux("sumPE") - p47_slopeAux("sumP")*p47_slopeAux("sumE");
              p47_slopeAux("varE")  = p47_slopeAux("n")*p47_slopeAux("sumE2") - sqr(p47_slopeAux("sumE"));

***           CASE 2 - insufficient price spread across the window: slope is ill-conditioned, use squareDev
***           (replaces the squareDev_perfectMatch, squareDev_smallChange and squareDev_outsideWindow guards)
              if((p47_slopeAux("pMax") - p47_slopeAux("pMin")) lt p47_slopeParam("minPriceSpread") * abs(pm_taxemiMkt_iteration(iteration,ttot2,regi,emiMkt)),
                regiEmiMktRescaleType(iteration,ttot,ttot2,ext_regi,emiMktExt,"squareDev_lowPriceSpread") = YES;
                pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt) = power(1+pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt), 2);
              else
                p47_slopeAux("slope") = p47_slopeAux("num") / p47_slopeAux("denom");
                p47_slopeAux("r2") = 1; !! default when emissions do not vary in the window (diverted to unstableFit by the sign check below)
                if(p47_slopeAux("varE") gt 0,
                  p47_slopeAux("r2") = sqr(p47_slopeAux("num")) / (p47_slopeAux("denom") * p47_slopeAux("varE"));
                );
                p47_factorRescaleSlope(ttot,ttot2,ext_regi,emiMktExt) = p47_slopeAux("slope");
                p47_slopeTrace_iter("fitR2",iteration,ttot,ttot2,ext_regi,emiMktExt) = p47_slopeAux("r2");

***             CASE 3 - wrong-sign or poorly-fit slope: unreliable for a Newton step, use squareDev
***             (replaces slope_repeatPrev_positiveSlope and squareDev_noNonPositiveSlope, now keyed off fit quality)
                if((p47_slopeAux("slope") ge 0) OR (p47_slopeAux("r2") lt p47_slopeParam("minR2")),
                  regiEmiMktRescaleType(iteration,ttot,ttot2,ext_regi,emiMktExt,"squareDev_unstableFit") = YES;
                  pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt) = power(1+pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt), 2);

***             CASE 4 - degenerate: fitted emission response over the window is negligible both vs 2005 emissions
***             AND vs the remaining gap (near-net-zero start). Only for year targets (pm_emiMktRefYear > 0).
                elseif((pm_emiMktRefYear(ttot,ttot2,ext_regi,emiMktExt) gt 0)
                       AND (abs(p47_slopeAux("slope")*(p47_slopeAux("pMax") - p47_slopeAux("pMin"))) lt p47_slopeParam("degenerateThreshold") * pm_emiMktRefYear(ttot,ttot2,ext_regi,emiMktExt))
                       AND (abs(p47_slopeAux("slope")*(p47_slopeAux("pMax") - p47_slopeAux("pMin"))) lt p47_slopeParam("degenerateThreshold") * abs(pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47) - p47_emiMktCurrent_iter(iteration,ttot,ttot2,ext_regi,emiMktExt)))),
                  regiEmiMktRescaleType(iteration,ttot,ttot2,ext_regi,emiMktExt,"squareDev_degenerateSlope") = YES;
                  pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt) = power(1+pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt), 2);

***             CASE 5 - trustworthy slope: take a Newton step, steepness-capped then trust-region-capped
                else
                  regiEmiMktRescaleType(iteration,ttot,ttot2,ext_regi,emiMktExt,"slope") = YES;
***               steepness cap: record the raw slope, then bound |slope| by p47_slopeParam("maxSteep") to avoid an over-tiny step from a noisy very steep fit
                  if(p47_factorRescaleSlope(ttot,ttot2,ext_regi,emiMktExt) lt -p47_slopeParam("maxSteep"),
                    p47_slopeTrace_iter("rawSlope",iteration,ttot,ttot2,ext_regi,emiMktExt) = p47_factorRescaleSlope(ttot,ttot2,ext_regi,emiMktExt);
                  );
                  p47_factorRescaleSlope(ttot,ttot2,ext_regi,emiMktExt) = max(-p47_slopeParam("maxSteep"), p47_factorRescaleSlope(ttot,ttot2,ext_regi,emiMktExt));
                  pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt) =
                    (
                      (pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47) - p47_emiMktCurrent_iter(iteration,ttot,ttot2,ext_regi,emiMktExt))
                      /
                      (p47_factorRescaleSlope(ttot,ttot2,ext_regi,emiMktExt) * pm_taxemiMkt_iteration(iteration,ttot2,regi,emiMkt))
                    ) + 1;
                );
              );
            );

***         FALLBACK STEP BOUND: power(1+dev,2) assumes a small relative deviation, so for a near-zero year
***         target or a cumulative budget (|dev| of O(1..25)) it always saturates the trust-region cap - i.e.
***         the fallback takes the LARGEST allowed step exactly when the slope fit became unreliable. Bound it
***         by what the algorithm has recently been able to do: at most fallbackStepFactor x the MEAN
***         |rescale-1| over the window, never below fallbackStepFloor. The MEAN, not the maximum: a maximum
***         ratchets, because one large step licenses the next (one target walked 24k -> 157k US$/tCO2 in five
***         fallback steps that way). squareDev_firstIteration is exempt - it is the cold-start ramp, with no
***         history. fallbackStepFactor = 0 disables the bound. Tutorial section 7.3.
            p47_slopeAux("isFallback") = 0;
            p47_slopeAux("isFallback")$regiEmiMktRescaleType(iteration,ttot,ttot2,ext_regi,emiMktExt,"squareDev_lowPriceSpread")   = 1;
            p47_slopeAux("isFallback")$regiEmiMktRescaleType(iteration,ttot,ttot2,ext_regi,emiMktExt,"squareDev_unstableFit")      = 1;
            p47_slopeAux("isFallback")$regiEmiMktRescaleType(iteration,ttot,ttot2,ext_regi,emiMktExt,"squareDev_degenerateSlope")  = 1;
            if((p47_slopeAux("isFallback") eq 1) AND (p47_slopeParam("fallbackStepFactor") gt 0),
              p47_slopeAux("recentStep") = 0;
              p47_slopeAux("nStep")      = 0;
***           only iterations in which this target was actually rescaled carry a meaningful step (an inactive target,
***           i.e. another period being solved, has a recorded factor of 0 and must not count as a "full" step)
              loop(iteration2$((iteration2.val lt iteration.val) and (iteration2.val ge iteration.val - p47_slopeParam("maxWindow"))
                               and (p47_factorRescaleemiMktCO2Tax_iter(iteration2,ttot,ttot2,ext_regi,emiMktExt) gt 0)),
                p47_slopeAux("recentStep") = p47_slopeAux("recentStep") + abs(p47_factorRescaleemiMktCO2Tax_iter(iteration2,ttot,ttot2,ext_regi,emiMktExt) - 1);
                p47_slopeAux("nStep")      = p47_slopeAux("nStep") + 1;
              );
              if(p47_slopeAux("nStep") gt 0,
                p47_slopeAux("stepBound") = max(p47_slopeParam("fallbackStepFloor"), p47_slopeParam("fallbackStepFactor") * p47_slopeAux("recentStep") / p47_slopeAux("nStep"));
                pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt) =
                  max(1 - p47_slopeAux("stepBound"), min(1 + p47_slopeAux("stepBound"), pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt)));
              );
            );

***         trust-region cap applied to EVERY rescale path (Newton and all squareDev fallbacks). power(1+dev,2)
***         is unbounded, so without this a far-from-target step explodes the carbon price (~5e9 US$/tCO2 was
***         observed on an infeasible budget, which destabilised the whole run). Tutorial section 7.4.
            pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt) =
              max(p47_slopeParam("rescaleCapLo"), min(p47_slopeParam("rescaleCapHi"), pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt)));

***         POST-RE-OPEN STEP CAP: a re-opened target is by construction already close (|dev| <= reopenMaxDev),
***         so the correcting step must be a nudge, not a fresh search. Caps the FIRST step after a re-open
***         whichever path produced it. reopenStepCap = 0 disables it. Tutorial section 7.5.
            if((p47_slopeParam("reopenStepCap") gt 0) AND (p47_targetState("reopenIter",ttot,ttot2,ext_regi,emiMktExt) eq iteration.val),
              pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt) =
                max(1 - p47_slopeParam("reopenStepCap"), min(1 + p47_slopeParam("reopenStepCap"), pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt)));
            );

***         progressive oscillation dampening: count how many times the rescale reversed direction (crossed 1)
***         over the window and shrink the step geometrically with that count, floored at dampFloor, so a
***         persistently over-shooting target settles toward the best achievable - where the noise-floor stop
***         can then accept it. Fewer than dampFlipMin reversals is left undamped. Dampening only SHRINKS a
***         step, never flips its sign or freezes a target, so a mis-detection at worst slows convergence.
            if(iteration.val > 3,
***           reversal between the previous and the current (about-to-be-applied) rescale
              p47_slopeAux("nFlip") =
                1$(((p47_factorRescaleemiMktCO2Tax_iter(iteration-1,ttot,ttot2,ext_regi,emiMktExt) - 1) * (pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt) - 1)) lt 0);
***           plus reversals among the already-recorded rescales in the window
              loop(iteration2$((iteration2.val lt iteration.val) and (iteration2.val gt iteration.val - p47_slopeParam("maxWindow")) and (iteration2.val ge 2)),
                p47_slopeAux("nFlip") = p47_slopeAux("nFlip")
                  + 1$(((p47_factorRescaleemiMktCO2Tax_iter(iteration2,ttot,ttot2,ext_regi,emiMktExt) - 1) * (p47_factorRescaleemiMktCO2Tax_iter(iteration2-1,ttot,ttot2,ext_regi,emiMktExt) - 1)) lt 0);
              );
              if(p47_slopeAux("nFlip") ge p47_slopeParam("dampFlipMin"),
                p47_slopeTrace_iter("preDamp",iteration,ttot,ttot2,ext_regi,emiMktExt) = pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt);
                pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt) =
                  1 + (pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt) - 1)
                      * max(p47_slopeParam("dampFloor"), power(p47_slopeParam("dampProgFactor"), p47_slopeAux("nFlip") - p47_slopeParam("dampFlipMin") + 1));
                put_utility "msg" / "Progressive oscillation dampening (" p47_slopeAux("nFlip"):2:0 " reversals): ";
                put_utility "msg" / ttot.tl " " ttot2.tl " " ext_regi.tl " " emiMktExt.tl " " pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt):10:3;
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

*** ----- Carbon Price Trajectory & Inter-Period Ramping -----

*** updating tax values under current targets
loop(ext_regi$regiEmiMktTarget(ext_regi),
*** solving targets sequentially, i.e. only apply target convergence algorithm if previous yearly targets were already achieved
  if(not(p47_allTargetsFrozen(ext_regi) eq 1), !!no rescale need if all targets already frozen (see TWO SIGNALS above: this is the module-internal gate, NOT the module-80 run-end signal)
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
***       optional absolute carbon-price ceiling: an unreachable target would otherwise ramp without bound at
***       rescaleCapHi per iteration. Capping the terminal-year price makes it freeze via the infeasible-target
***       stop (whose recorded rescale factor is unaffected) at a sane price. In US$/tCO2. Tutorial 8.6.
          if(p47_slopeParam("maxPrice") gt 0,
            pm_taxemiMkt(ttot2,regi,emiMkt) = min(pm_taxemiMkt(ttot2,regi,emiMkt), p47_slopeParam("maxPrice") * sm_DptCO2_2_TDpGtC);
          );
***       linear price between first free year and current target terminal year
          loop(ttot3,
            s47_firstFreeYear = ttot3.val;
            break$((ttot3.val ge ttot.val) and (ttot3.val ge cm_startyear) and (ttot3.val ge 2020)); !!initial free price year
            s47_prefreeYear = ttot3.val;
          );
          if(not(ttot2.val eq p47_firstTargetYear(ext_regi)), !! delay price change by cm_emiMktTargetDelay years for later targets
            s47_firstFreeYear = max(s47_firstFreeYear,ttot.val+cm_emiMktTargetDelay);
***         Anchor price ramp at closest earlier target year (starting strictly after it) to prevent overwriting converged prices.
            s47_prevTargetYear = 0;
            loop(ttot3$(regiANDperiodEmiMktTarget_47(ttot3,ext_regi) AND (ttot3.val lt ttot2.val)),
              s47_prevTargetYear = max(s47_prevTargetYear, ttot3.val);
            );
            if(s47_prevTargetYear gt 0,
              s47_prefreeYear   = s47_prevTargetYear;
              s47_firstFreeYear = max(s47_firstFreeYear, s47_prevTargetYear + 1); !! never touch the earlier target year itself
            );
          );
          loop(ttot3$(ttot3.val eq s47_prefreeYear), !! ttot3 = beginning of slope; ttot2 = end of slope
            pm_taxemiMkt(t,regi,emiMkt)$((t.val ge s47_firstFreeYear) AND (t.val lt ttot2.val))  = pm_taxemiMkt(ttot3,regi,emiMkt) + ((pm_taxemiMkt(ttot2,regi,emiMkt) - pm_taxemiMkt(ttot3,regi,emiMkt))/(ttot2.val-ttot3.val))*(t.val-ttot3.val);
          );
*** END OF TARGET PRICE RAMP (marker used by convergence_tests/run_tests.sh to extract this block)
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
  if(not(p47_allTargetsFrozen(ext_regi) eq 1), !!no rescale need if all targets already frozen (see TWO SIGNALS above: this is the module-internal gate, NOT the module-80 run-end signal)
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
***             default: simple average across markets (guards against division by zero when total
***             net emissions are negligibly small, zero, or net-negative with cancellation)
                p47_averagetaxemiMkt(t,regi) =
                  (pm_taxemiMkt(t,regi,"ETS") + pm_taxemiMkt(t,regi,"ES") + pm_taxemiMkt(t,regi,"other")) / 3;
***             override with emission-weighted average when total net emissions are large enough
                p47_averagetaxemiMkt(t,regi)$(abs(p47_emiTargetMkt(t,regi,"ETS",emi_type_47) + p47_emiTargetMkt(t,regi,"ESR",emi_type_47) + p47_emiTargetMkt(t,regi,"other",emi_type_47)) gt 1e-6) =
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

*** ----- Aggregated Tax Diagnostic Parameters -----

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
      ( sum(entyFe$energyQttyTargetANDGroup2enty("FE_indst",qttyTargetGroup,entyFe), sum(se2fe(entySe,entyFe,te), sum((emiMkt)$(entyFe2Sector(entyFe,"indst") AND sector2emiMkt("indst",emiMkt)), vm_demFeSector.l(t,regi,entySe,entyFe,"indst",emiMkt))))
      )$(sameas(qttyTarget,"FE_indst") AND sameas(qttyTargetGroup,"all"))
      +
      ( sum(entyFe$energyQttyTargetANDGroup2enty("FE_build",qttyTargetGroup,entyFe), sum(se2fe(entySe,entyFe,te), sum((emiMkt)$(entyFe2Sector(entyFe,"build") AND sector2emiMkt("build",emiMkt)), vm_demFeSector.l(t,regi,entySe,entyFe,"build",emiMkt))))
      )$(sameas(qttyTarget,"FE_build") AND sameas(qttyTargetGroup,"all"))
      +
      ( sum(entyFe$energyQttyTargetANDGroup2enty("FE_trans",qttyTargetGroup,entyFe), sum(se2fe(entySe,entyFe,te), sum((emiMkt)$(entyFe2Sector(entyFe,"trans") AND sector2emiMkt("trans",emiMkt)), vm_demFeSector.l(t,regi,entySe,entyFe,"trans",emiMkt))))
      )$(sameas(qttyTarget,"FE_trans") AND sameas(qttyTargetGroup,"all"))
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
      ( sum(regi$regi_groupExt(ext_regi,regi),  sum(entyFe$energyQttyTargetANDGroup2enty("FE_indst",qttyTargetGroup,entyFe), sum(se2fe(entySe,entyFe,te), sum((emiMkt)$(entyFe2Sector(entyFe,"indst") AND sector2emiMkt("indst",emiMkt)), vm_demFeSector.l(ttot,regi,entySe,entyFe,"indst",emiMkt)))) )
      )$(sameas(qttyTarget,"FE_indst") AND sameas(qttyTargetGroup,"all"))
      +
      ( sum(regi$regi_groupExt(ext_regi,regi),  sum(entyFe$energyQttyTargetANDGroup2enty("FE_build",qttyTargetGroup,entyFe), sum(se2fe(entySe,entyFe,te), sum((emiMkt)$(entyFe2Sector(entyFe,"build") AND sector2emiMkt("build",emiMkt)), vm_demFeSector.l(ttot,regi,entySe,entyFe,"build",emiMkt)))) )
      )$(sameas(qttyTarget,"FE_build") AND sameas(qttyTargetGroup,"all"))
      +
      ( sum(regi$regi_groupExt(ext_regi,regi),  sum(entyFe$energyQttyTargetANDGroup2enty("FE_trans",qttyTargetGroup,entyFe), sum(se2fe(entySe,entyFe,te), sum((emiMkt)$(entyFe2Sector(entyFe,"trans") AND sector2emiMkt("trans",emiMkt)), vm_demFeSector.l(ttot,regi,entySe,entyFe,"trans",emiMkt)))) )
      )$(sameas(qttyTarget,"FE_trans") AND sameas(qttyTargetGroup,"all"))
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
      +
      ( sum(regi$regi_groupExt(ext_regi,regi),  sum(entyFe$energyQttyTargetANDGroup2enty("FE_indst",qttyTargetGroup,entyFe), sum(se2fe(entySe,entyFe,te), sum((emiMkt)$(entyFe2Sector(entyFe,"indst") AND sector2emiMkt("indst",emiMkt)), vm_demFeSector.l(ttot,regi,entySe,entyFe,"indst",emiMkt)))) )
      )$(sameas(qttyTarget,"FE_indst") AND sameas(qttyTargetGroup,"all"))
      +
      ( sum(regi$regi_groupExt(ext_regi,regi),  sum(entyFe$energyQttyTargetANDGroup2enty("FE_build",qttyTargetGroup,entyFe), sum(se2fe(entySe,entyFe,te), sum((emiMkt)$(entyFe2Sector(entyFe,"build") AND sector2emiMkt("build",emiMkt)), vm_demFeSector.l(ttot,regi,entySe,entyFe,"build",emiMkt)))) )
      )$(sameas(qttyTarget,"FE_build") AND sameas(qttyTargetGroup,"all"))
      +
      ( sum(regi$regi_groupExt(ext_regi,regi),  sum(entyFe$energyQttyTargetANDGroup2enty("FE_trans",qttyTargetGroup,entyFe), sum(se2fe(entySe,entyFe,te), sum((emiMkt)$(entyFe2Sector(entyFe,"trans") AND sector2emiMkt("trans",emiMkt)), vm_demFeSector.l(ttot,regi,entySe,entyFe,"trans",emiMkt)))) )
      )$(sameas(qttyTarget,"FE_trans") AND sameas(qttyTargetGroup,"all"))
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


$ifThen.regiExoPrice_fromFile not "%cm_regiExoPrice_fromFile%" == "off"


*** Removing the existent co2 tax parameters for regions with exogenous set prices
  pm_taxCO2eqSum(ttot,regi)$(ttot.val ge cm_startyear) = 0;
  pm_taxCO2eq(ttot,regi)$(ttot.val ge cm_startyear) = 0;
  pm_taxCO2eqRegi(ttot,regi)$(ttot.val ge cm_startyear)= 0;
  pm_taxCO2eqSCC(ttot,regi)$(ttot.val ge cm_startyear) = 0;

  pm_taxrevGHG0(ttot,regi)$(ttot.val ge cm_startyear) = 0;
  pm_taxrevCO2Sector0(ttot,regi,emi_sectors)$(ttot.val ge cm_startyear) = 0;
  pm_taxrevCO2LUC0(ttot,regi)$(ttot.val ge cm_startyear) = 0;
  pm_taxrevNetNegEmi0(ttot,regi)$(ttot.val ge cm_startyear) = 0;

  pm_taxemiMkt(ttot,regi,emiMkt)$(ttot.val ge cm_startyear) = 0;


*** setting exogenous CO2 prices from GDX file
  pm_taxCO2eq(t,regi) = p47_exoCo2tax_fromFile(t,regi,"ETS");
  pm_taxCO2eqSum(t,regi) = pm_taxCO2eq(t,regi);

execute_unload "postsolve_pm_taxCO2eq_fromFile", pm_taxCO2eq;
display pm_taxCO2eq;
$endIf.regiExoPrice_fromFile

*** EOF ./modules/47_regipol/regiCarbonPrice/postsolve.gms
