*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
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
    + ( vm_emiCdr.l(ttot,regi,"co2")* (1-pm_share_CCS_CCO2(ttot,regi)) )$(sameas(emiMkt,"ETS") or sameas(emiMktExt,"all"))  !! DAC accounting of synfuels: remove CO2 of vm_emiCDR (which is negative) from vm_emiTe which is not stored in vm_co2CCS
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

*** net GHG per Mkt with Grassi LULUCF shift
p47_emiTargetMkt(ttot,regi, emiMktExt,"netGHG_LULUCFGrassi") =
  p47_emiTargetMkt(ttot,regi, emiMktExt,"netGHG")
  - ( p47_LULUCFEmi_GrassiShift(ttot,regi) )$(sameas(emiMktExt,"other") or sameas(emiMktExt,"all"));

*** net GHG per Mkt without bunkers and with Grassi LULUCF shift
p47_emiTargetMkt(ttot,regi, emiMktExt,"netGHG_LULUCFGrassi_noBunkers") =
  p47_emiTargetMkt(ttot,regi, emiMktExt,"netGHG_noBunkers")
  - ( p47_LULUCFEmi_GrassiShift(ttot,regi) )$(sameas(emiMktExt,"other") or sameas(emiMktExt,"all"));

***--------------------------------------------------
*** Emission markets (EU Emission trading system and Effort Sharing)
***--------------------------------------------------

$IFTHEN.emiMkt not "%cm_emiMktTarget%" == "off" 

*** Removing economy wide co2 tax parameters for regions within the emiMKt controlled targets (this is necessary here to remove any calculation made in other modules after the last run in the postsolve)
  loop((ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47)$pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47),
    loop(regi$regi_groupExt(ext_regi,regi),
*** Removing the economy wide co2 tax parameters for regions within the ETS markets
      pm_taxCO2eqSum(t,regi) = 0;
      pm_taxCO2eq(t,regi) = 0;
      pm_taxCO2eqRegi(t,regi) = 0;
      pm_taxCO2eqHist(t,regi) = 0;
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
pm_emiMktTarget_dev_iter(iteration, ttot,ttot2,ext_regi,emiMktExt) = pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt); !!save regional target deviation across iterations for debugging of target convergence issues

*** Checking sequentially if targets converged
loop(ext_regi,
  loop((ttot2)$regiANDperiodEmiMktTarget_47(ttot2,ext_regi),
    if(not (p47_targetConverged(ttot2,ext_regi)),
      p47_targetConverged(ttot2,ext_regi) = 1;
      loop((ttot,emiMktExt,target_type_47,emi_type_47)$((pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47))),
        if((abs(pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt)) > 0.01), !! if any emiMKt target did not converged
          p47_targetConverged(ttot2,ext_regi) = 0;
        );
      );
    );
  );
);
p47_targetConverged_iter(iteration,ttot2,ext_regi) = p47_targetConverged(ttot2,ext_regi); !!save regional target converged iteration information for debugging
loop((ttot,ext_regi)$regiANDperiodEmiMktTarget_47(ttot,ext_regi), !! displaying iteration where targets converged
  if(not (p47_targetConverged(ttot,ext_regi)),
    display 'all regional emission targets for ', ext_regi, ', for the year', ttot, ', converged in iteration ', iteration ;
  );
);

*** Checking if all targets converged at least once
loop(ext_regi$regiEmiMktTarget(ext_regi),
  p47_allTargetsConverged(ext_regi) = 1;
  loop((ttot)$regiANDperiodEmiMktTarget_47(ttot,ext_regi),
    if(not (p47_targetConverged(ttot,ext_regi)),
      p47_allTargetsConverged(ext_regi) = 0;
    );
  );
);
loop(ext_regi$regiEmiMktTarget(ext_regi), !! displaying iteration where all targets converged sequentially
  if(not (p47_allTargetsConverged(ext_regi)),
    display 'all regional emission targets for ', ext_regi, ', converged at least once when sequentially solved in the iteration ', iteration ;
  );
);

*** Calculating the emissions tax rescale factor based on previous iterations emission reduction
loop((ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47)$pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47),
  loop(emiMkt$emiMktGroup(emiMktExt,emiMkt), 
    loop(regi$regi_groupExt(ext_regi,regi),
***   initiliazing first iteration rescale factor based on remaining deviation
      if(iteration.val eq 1,
        pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt) = (1+pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt)) ** 2;
***   else if for the extreme case of a perfect match with no change between the two previous iteration emisssion taxes, in order to avoid a division by zero error, assume the rescale factor based on remaining deviation
      elseif(((iteration.val eq 2) and (pm_taxemiMkt_iteration(iteration,ttot2,regi,emiMkt) eq pm_taxemiMkt_iteration("1",ttot2,regi,emiMkt))) or
             ((iteration.val gt 2) and (pm_taxemiMkt_iteration(iteration,ttot2,regi,emiMkt) eq pm_taxemiMkt_iteration("2",ttot2,regi,emiMkt)))),
        pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt) = (1+pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt)) ** 2;
***   else using previous iteration information to define rescale factor  
***   calculate rescale factor based on slope of previous iterations mitigation levels when compared to relative price difference          
      else
        if(iteration.val eq 2,
          p47_factorRescaleSlope(ttot,ttot2,ext_regi,emiMktExt) =
            (p47_emiMktCurrent_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) - p47_emiMktCurrent_iter("1",ttot,ttot2,ext_regi,emiMktExt))
            /
            (pm_taxemiMkt_iteration(iteration,ttot2,regi,emiMkt) - pm_taxemiMkt_iteration("1",ttot2,regi,emiMkt))
          ;
***     for iterations greater than 2, always calculate the slope relative to the second iteration
        else
          p47_factorRescaleSlope(ttot,ttot2,ext_regi,emiMktExt) =
            (p47_emiMktCurrent_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) - p47_emiMktCurrent_iter("2",ttot,ttot2,ext_regi,emiMktExt))
            /
            (pm_taxemiMkt_iteration(iteration,ttot2,regi,emiMkt) - pm_taxemiMkt_iteration("2",ttot2,regi,emiMkt))
          ;
        );
***     emission tax rescale factor
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
p47_factorRescaleSlope_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) = p47_factorRescaleSlope(ttot,ttot2,ext_regi,emiMktExt);

*** if sequential target achieved a solution and cm_prioRescaleFactor != off, prioritize short term targets rescaling. e.g. multiplicative factor equal to 1 if target is 2030 or lower, and equal to 0.2 (s47_prioRescaleFactor) if target is 2050 or higher.
$ifThen.prioRescaleFactor not "%cm_prioRescaleFactor%" == "off" 
loop((ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47)$pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47),
  if(p47_allTargetsConverged(ext_regi),
    pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt) = min(max(1-((ttot2.val-2030)/(20/(1-s47_prioRescaleFactor))),s47_prioRescaleFactor),1)*(pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt)-1)+1;
  );
);
$endIf.prioRescaleFactor

***pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt)$pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt) = min(max(0.1,pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt)),10); !! clamp the rescale factor between 0.1 (to avoid negative values) and 10 (extremely high price change in between iterations)
p47_factorRescaleemiMktCO2Tax_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) = pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt); !!save rescale factor across iterations for debugging of target convergence issues

loop(ext_regi$regiEmiMktTarget(ext_regi),
*** solving targets sequentially, i.e. only apply target convergence algorithm if previous yearly targets were already achieved
  if(not(p47_allTargetsConverged(ext_regi)),
*** define current target to be solved
    loop((ttot)$regiANDperiodEmiMktTarget_47(ttot,ext_regi),
      p47_currentConvergencePeriod(ext_regi) = ttot.val;
      break$(p47_targetConverged(ttot,ext_regi) eq 0); !!only run target convergence up to the first year that has not converged
    );
    loop((ttot)$(regiANDperiodEmiMktTarget_47(ttot,ext_regi) and (ttot.val gt p47_currentConvergencePeriod(ext_regi))),
      p47_nextConvergencePeriod(ext_regi) = ttot.val;
      break;
    );
*** updating the emiMkt co2 tax for the first non converged yearly target  
    loop((ttot,ttot2,emiMktExt,target_type_47,emi_type_47)$(pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47) AND (ttot2.val eq p47_currentConvergencePeriod(ext_regi))),
      loop(emiMkt$emiMktGroup(emiMktExt,emiMkt),
        loop(regi$regi_groupExt(ext_regi,regi),
***       terminal year price
          if((iteration.val eq 1) and (pm_taxemiMkt(ttot2,regi,emiMkt) eq 0), !!intialize price for first iteration if it is missing 
            pm_taxemiMkt(ttot2,regi,emiMkt) = max(1* sm_DptCO2_2_TDpGtC, 2*pm_taxemiMkt(ttot,regi,emiMkt));    
          else !!update price using rescaling factor
            pm_taxemiMkt(ttot2,regi,emiMkt) = max(1* sm_DptCO2_2_TDpGtC, pm_taxemiMkt_iteration(iteration,ttot2,regi,emiMkt) * pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt));
          );
***       linear price between first free year and current target terminal year
          loop(ttot3,
            s47_firstFreeYear = ttot3.val;
            break$((ttot3.val ge ttot.val) and (ttot3.val ge cm_startyear) and (ttot.val ge 2020)); !!initial free price year
            s47_prefreeYear = ttot3.val;
          );
          if(not(ttot2.val eq p47_firstTargetYear(ext_regi)), !! delay price change by cm_emiMktTargetDelay years for later targets
            s47_firstFreeYear = max(s47_firstFreeYear,ttot.val+cm_emiMktTargetDelay)
          );
          loop(ttot3$(ttot3.val eq s47_prefreeYear), !! ttot3 = beginning of slope; ttot2 = end of slope
            pm_taxemiMkt(t,regi,emiMkt)$((t.val ge s47_firstFreeYear) AND (t.val lt ttot2.val))  = pm_taxemiMkt(ttot3,regi,emiMkt) + ((pm_taxemiMkt(ttot2,regi,emiMkt) - pm_taxemiMkt(ttot3,regi,emiMkt))/(ttot2.val-ttot3.val))*(t.val-ttot3.val); 
          );
***         if not last year target, then assume weighted average convergence price between current target terminal year (ttot2.val) and next target year (p47_nextConvergencePeriod)
          if((not(ttot2.val eq p47_lastTargetYear(ext_regi))),
            p47_averagetaxemiMkt(t,regi) = 
              (pm_taxemiMkt(t,regi,"ETS")*p47_emiTargetMkt(t,regi,"ETS",emi_type_47) + pm_taxemiMkt(t,regi,"ES")*p47_emiTargetMkt(t,regi,"ESR",emi_type_47))
              /
              (p47_emiTargetMkt(t,regi,"ETS",emi_type_47) + p47_emiTargetMkt(t,regi,"ESR",emi_type_47));
            loop(ttot3$(ttot3.val eq p47_nextConvergencePeriod(ext_regi)), !! ttot2 = beginning of slope; ttot3 = end of slope
              pm_taxemiMkt(ttot3,regi,emiMkt) = p47_averagetaxemiMkt(ttot2,regi) + ((p47_averagetaxemiMkt(ttot2,regi)-p47_averagetaxemiMkt(ttot,regi))/(ttot2.val-ttot.val))*(ttot3.val-ttot2.val); !! price at the next target year, p47_nextConvergencePeriod, as linear projection of average price in this target period 
              pm_taxemiMkt(t,regi,emiMkt)$((t.val gt ttot2.val) AND (t.val lt ttot3.val)) = pm_taxemiMkt(ttot2,regi,emiMkt) + ((pm_taxemiMkt(ttot3,regi,emiMkt) - pm_taxemiMkt(ttot2,regi,emiMkt))/(ttot3.val-ttot2.val))*(t.val-ttot2.val); !! price in between current target year and next target year
              pm_taxemiMkt(t,regi,emiMkt)$(t.val gt ttot3.val) = pm_taxemiMkt(ttot3,regi,emiMkt) + (cm_postTargetIncrease*sm_DptCO2_2_TDpGtC)*(t.val-ttot3.val); !! price after next target year
            );
          else
***         fixed year increase after terminal year price (cm_postTargetIncrease €/tCO2 increase per year)
            pm_taxemiMkt(t,regi,emiMkt)$(t.val gt ttot2.val) = pm_taxemiMkt(ttot2,regi,emiMkt) + (cm_postTargetIncrease*sm_DptCO2_2_TDpGtC)*(t.val-ttot2.val);
          );
        );
      );
    );
*** if sequential target achieved a solution, apply the re-scale factor to all year targets at the same time for all further iterations
  else 
    loop((ttot,ttot2,emiMktExt,target_type_47,emi_type_47)$pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47),
      loop(emiMkt$emiMktGroup(emiMktExt,emiMkt), 
        loop(regi$regi_groupExt(ext_regi,regi),
***       terminal year price
          pm_taxemiMkt(ttot2,regi,emiMkt) = max(1* sm_DptCO2_2_TDpGtC, pm_taxemiMkt_iteration(iteration,ttot2,regi,emiMkt) * pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt));
***       linear price between first free year and terminal year
          loop(ttot3,
              s47_firstFreeYear = ttot3.val; 
            break$((ttot3.val ge ttot.val) and (ttot3.val ge cm_startyear)); !!initial free price year
            s47_prefreeYear = ttot3.val;
          );
          if(not(ttot2.val eq p47_firstTargetYear(ext_regi)), !! delay price change by cm_emiMktTargetDelay years for later targets
            s47_firstFreeYear = max(s47_firstFreeYear,ttot.val+cm_emiMktTargetDelay)
          );
          loop(ttot3$(ttot3.val eq s47_prefreeYear), !! ttot3 = beginning of slope; ttot2 = end of slope
            pm_taxemiMkt(t,regi,emiMkt)$((t.val ge s47_firstFreeYear) AND (t.val lt ttot2.val))  = max(1* sm_DptCO2_2_TDpGtC, pm_taxemiMkt(ttot3,regi,emiMkt) + ((pm_taxemiMkt(ttot2,regi,emiMkt) - pm_taxemiMkt(ttot3,regi,emiMkt))/(ttot2.val-ttot3.val))*(t.val-ttot3.val) ); 
          );
***       fixed year increase after terminal year price (cm_postTargetIncrease €/tCO2 increase per year)
          pm_taxemiMkt(t,regi,emiMkt)$(t.val gt ttot2.val) = pm_taxemiMkt(ttot2,regi,emiMkt) + (cm_postTargetIncrease*sm_DptCO2_2_TDpGtC)*(t.val-ttot2.val);
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

*** output helper parameter
p47_taxemiMkt_AggEmi(t,regi) = (sum(emiMkt, pm_taxemiMkt(t,regi,emiMkt) * vm_co2eqMkt.l(t,regi,emiMkt))) / (sum(emiMkt, vm_co2eqMkt.l(t,regi,emiMkt)));
p47_taxCO2eq_AggEmi(ttot,regi) = pm_taxCO2eqSum(ttot,regi);
p47_taxCO2eq_AggEmi(t,regi)$p47_taxemiMkt_AggEmi(t,regi) = p47_taxemiMkt_AggEmi(t,regi);

p47_taxemiMkt_AggFE(t,regi) = (sum(emiMkt, pm_taxemiMkt(t,regi,emiMkt) * sum((entySe,entyFe,sector)$(sefe(entySe,entyFe) AND entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)),vm_demFeSector.l(t,regi,entySe,entyFe,sector,emiMkt)))) / (sum((entySe,entyFe,sector,emiMkt)$(sefe(entySe,entyFe) AND entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)),vm_demFeSector.l(t,regi,entySe,entyFe,sector,emiMkt)));
p47_taxCO2eq_AggFE(ttot,regi) = pm_taxCO2eqSum(ttot,regi);
p47_taxCO2eq_AggFE(t,regi)$p47_taxemiMkt_AggFE(t,regi) = p47_taxemiMkt_AggFE(t,regi);

p47_taxemiMkt_SectorAggFE(t,regi,sector)$(sum((entySe,entyFe,emiMkt)$(sefe(entySe,entyFe) AND entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)),vm_demFeSector.l(t,regi,entySe,entyFe,sector,emiMkt))) = (sum(emiMkt, pm_taxemiMkt(t,regi,emiMkt) * sum((entySe,entyFe)$(sefe(entySe,entyFe) AND entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)),vm_demFeSector.l(t,regi,entySe,entyFe,sector,emiMkt)))) / (sum((entySe,entyFe,emiMkt)$(sefe(entySe,entyFe) AND entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)),vm_demFeSector.l(t,regi,entySe,entyFe,sector,emiMkt)));
p47_taxCO2eq_SectorAggFE(ttot,regi,sector) = pm_taxCO2eqSum(ttot,regi);
p47_taxCO2eq_SectorAggFE(t,regi,sector)$p47_taxemiMkt_SectorAggFE(t,regi,sector) = p47_taxemiMkt_SectorAggFE(t,regi,sector);

*** display pm_emiMktTarget,pm_emiMktCurrent,pm_emiMktRefYear,pm_emiMktTarget_dev,pm_factorRescaleemiMktCO2Tax;

$ENDIF.emiMkt


***---------------------------------------------------------------------------
*** Calculation of implicit tax/subsidy necessary to achieve quantity target for primary, secondary, final energy and/or CCS
***---------------------------------------------------------------------------

$ifthen.cm_implicitQttyTarget not "%cm_implicitQttyTarget%" == "off"

*** saving previous iteration value for implicit tax revenue recycling
p47_implicitQttyTargetTax_prevIter(t,regi,qttyTarget,qttyTargetGroup) = p47_implicitQttyTargetTax(t,regi,qttyTarget,qttyTargetGroup);
p47_implicitQttyTargetTax0(t,regi) =
  sum((qttyTarget,qttyTargetGroup)$p47_implicitQttyTargetTax(t,regi,qttyTarget,qttyTargetGroup),
    ( p47_implicitQttyTargetTax(t,regi,qttyTarget,qttyTargetGroup) * sum(entyPe$energyQttyTargetANDGroup2enty(qttyTarget,qttyTargetGroup,entyPe), sum(pe2se(entyPe,entySe,te), vm_demPe.l(t,regi,entyPe,entySe,te))) 
    )$(sameas(qttyTarget,"PE")) 
    +
    ( p47_implicitQttyTargetTax(t,regi,qttyTarget,qttyTargetGroup) * sum(entySe$energyQttyTargetANDGroup2enty(qttyTarget,qttyTargetGroup,entySe), sum(se2fe(entySe,entyFe,te), vm_demSe.l(t,regi,entySe,entyFe,te))) 
    )$(sameas(qttyTarget,"SE")) 
    +
    ( p47_implicitQttyTargetTax(t,regi,qttyTarget,qttyTargetGroup) * sum(entySe$energyQttyTargetANDGroup2enty("FE",qttyTargetGroup,entySe), sum(se2fe(entySe,entyFe,te), sum((sector,emiMkt)$(entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)), vm_demFeSector.l(t,regi,entySe,entyFe,sector,emiMkt)))) 
    )$(sameas(qttyTarget,"FE") or sameas(qttyTarget,"FE_wo_b") or sameas(qttyTarget,"FE_wo_n_e") or sameas(qttyTarget,"FE_wo_b_wo_n_e"))
    +
    ( p47_implicitQttyTargetTax(t,regi,qttyTarget,qttyTargetGroup) * sum(ccs2te(ccsCO2(enty),enty2,te), sum(teCCS2rlf(te,rlf),vm_co2CCS.l(t,regi,enty,enty2,te,rlf)))
    )$(sameas(qttyTarget,"CCS"))    
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
        +
        ( - ( p47_nonEnergyUse(ttot,ext_regi) )$((sameas(qttyTargetGroup,"all") or sameas(qttyTargetGroup,"fossil"))) !! removing non-energy use if energy type = all (this assumes all no energy use belongs to fossil and should be changed once feedstocks are endogenous to the model)
        )$(sameas(qttyTarget,"FE_wo_n_e") or sameas(qttyTarget,"FE_wo_b_wo_n_e")) 
      )$(sameas(qttyTarget,"FE") or sameas(qttyTarget,"FE_wo_b") or sameas(qttyTarget,"FE_wo_n_e") or sameas(qttyTarget,"FE_wo_b_wo_n_e"))
      +
      ( sum(regi$regi_groupExt(ext_regi,regi), sum(ccs2te(ccsCO2(enty),enty2,te), sum(teCCS2rlf(te,rlf),vm_co2CCS.l(ttot,regi,enty,enty2,te,rlf))))
      )$(sameas(qttyTarget,"CCS")) 
    ;
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
      (   (
        sum(regi$regi_groupExt(ext_regi,regi),  sum(entySe$energyQttyTargetANDGroup2enty("FE",qttyTargetGroup,entySe), sum(se2fe(entySe,entyFe,te), sum((sector,emiMkt)$(entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)), vm_demFeSector.l(ttot,regi,entySe,entyFe,sector,emiMkt)))) )
        + ( - ( sum(regi$regi_groupExt(ext_regi,regi), sum(entySe$energyQttyTargetANDGroup2enty("FE",qttyTargetGroup,entySe), sum(se2fe(entySe,entyFe,te),  vm_demFeSector.l(ttot,regi,entySe,entyFe,"trans","other")) )) ) !! removing bunkers from FE targets
        )$(sameas(qttyTarget,"FE_wo_b") or sameas(qttyTarget,"FE_wo_b_wo_n_e"))
        +
        ( - ( p47_nonEnergyUse(ttot,ext_regi) )$((sameas(qttyTargetGroup,"all") or sameas(qttyTargetGroup,"fossil"))) !! removing non-energy use if energy type = all (this assumes all no energy use belongs to fossil and should be changed once feedstocks are endogenous to the model)
        )$(sameas(qttyTarget,"FE_wo_n_e") or sameas(qttyTarget,"FE_wo_b_wo_n_e")) 
          )
        /
        (
        sum(regi$regi_groupExt(ext_regi,regi),  sum(entySe$energyQttyTargetANDGroup2enty("FE","all",entySe), sum(se2fe(entySe,entyFe,te), sum((sector,emiMkt)$(entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)), vm_demFeSector.l(ttot,regi,entySe,entyFe,sector,emiMkt)))) )
        + ( - ( sum(regi$regi_groupExt(ext_regi,regi), sum(entySe$energyQttyTargetANDGroup2enty("FE","all",entySe), sum(se2fe(entySe,entyFe,te),  vm_demFeSector.l(ttot,regi,entySe,entyFe,"trans","other")) )) ) !! removing bunkers from FE targets
        )$(sameas(qttyTarget,"FE_wo_b") or sameas(qttyTarget,"FE_wo_b_wo_n_e"))
        +
        ( - ( p47_nonEnergyUse(ttot,ext_regi) ) !! removing non-energy use if energy type = all (this assumes all no energy use belongs to fossil and should be changed once feedstocks are endogenous to the model)
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

***  calculating targets implicit tax rescale factor
loop((ttot,ext_regi,taxType,targetType,qttyTarget,qttyTargetGroup)$pm_implicitQttyTarget(ttot,ext_regi,taxType,targetType,qttyTarget,qttyTargetGroup),
  if(sameas(taxType,"tax"),
    if(iteration.val lt 15,
      p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup) = (1 + pm_implicitQttyTarget_dev(ttot,ext_regi,qttyTarget,qttyTargetGroup) ) ** 4;
    else
      p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup) = (1 + pm_implicitQttyTarget_dev(ttot,ext_regi,qttyTarget,qttyTargetGroup) ) ** 2;
    );  
  );
  if(sameas(taxType,"sub"),
    if(iteration.val lt 15,
      p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup) = (1 - pm_implicitQttyTarget_dev(ttot,ext_regi,qttyTarget,qttyTargetGroup) ) ** 4;
    else
      p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup) = (1 - pm_implicitQttyTarget_dev(ttot,ext_regi,qttyTarget,qttyTargetGroup) ) ** 2;
    );  
  );
*** dampen rescale factor with increasing iterations to help convergence if the last two iteration deviations where not in the same direction 
  if((iteration.val gt 3) and (p47_implicitQttyTarget_dev_iter(iteration, ttot,ext_regi,qttyTarget,qttyTargetGroup)*p47_implicitQttyTarget_dev_iter(iteration-1, ttot,ext_regi,qttyTarget,qttyTargetGroup) < 0),
  p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup) =
    max(min( 2 * EXP( -0.15 * iteration.val ) + 1.01 ,p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup)),1/ ( 2 * EXP( -0.15 * iteration.val ) + 1.01));
  );
);

p47_implicitQttyTargetTaxRescale_iter(iteration,ttot,ext_regi,qttyTarget,qttyTargetGroup) = p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup);

*** updating quantity targets implicit tax
pm_implicitQttyTarget_isLimited(iteration,qttyTarget,qttyTargetGroup) = 0;
loop((ttot,ext_regi,taxType,targetType,qttyTarget,qttyTargetGroup)$pm_implicitQttyTarget(ttot,ext_regi,taxType,targetType,qttyTarget,qttyTargetGroup), !! initialize before first year auxiliary parameter for targets
    loop(ttot2$(ttot2.val eq cm_startyear), 
        p47_implicitQttyTarget_initialYear(ext_regi,taxType,targetType,qttyTarget,qttyTargetGroup) =  max(2020,pm_ttot_val(ttot2-1));
    );
);
loop((ttot,ext_regi,taxType,targetType,qttyTarget,qttyTargetGroup)$pm_implicitQttyTarget(ttot,ext_regi,taxType,targetType,qttyTarget,qttyTargetGroup),
  loop(all_regi$regi_groupExt(ext_regi,all_regi),
*** terminal year onward tax
    if(sameas(taxType,"tax"),
      if((p47_implicitQttyTargetTax_prevIter(ttot,all_regi,qttyTarget,qttyTargetGroup) * p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup) lt 1e-10), !! assuring that the updated tax is positive, i.e. the target is achieved without the need for any additional tax
        pm_implicitQttyTarget_isLimited(iteration,qttyTarget,qttyTargetGroup) = 1;
        p47_implicitQttyTargetTax(t,all_regi,qttyTarget,qttyTargetGroup)$(t.val ge ttot.val) = 1e-10;
      else
        p47_implicitQttyTargetTax(t,all_regi,qttyTarget,qttyTargetGroup)$(t.val ge ttot.val) = p47_implicitQttyTargetTax_prevIter(t,all_regi,qttyTarget,qttyTargetGroup) * p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup); 
      ); 
    );
    if(sameas(taxType,"sub"),
      if((p47_implicitQttyTargetTax_prevIter(ttot,all_regi,qttyTarget,qttyTargetGroup) * p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup) gt -1e-10), !! assuring that the updated tax is negative (subsidy), i.e. the target is achieved without the need for any additional subsidy
        pm_implicitQttyTarget_isLimited(iteration,qttyTarget,qttyTargetGroup) = 1;
        p47_implicitQttyTargetTax(t,all_regi,qttyTarget,qttyTargetGroup)$(t.val ge ttot.val) = -1e-10;
      else
        p47_implicitQttyTargetTax(t,all_regi,qttyTarget,qttyTargetGroup)$(t.val ge ttot.val) = p47_implicitQttyTargetTax_prevIter(t,all_regi,qttyTarget,qttyTargetGroup) * p47_implicitQttyTargetTaxRescale(ttot,ext_regi,qttyTarget,qttyTargetGroup); 
      ); 
    );
*** linear price between first free year and target year
    loop(ttot2$(ttot2.val eq p47_implicitQttyTarget_initialYear(ext_regi,taxType,targetType,qttyTarget,qttyTargetGroup)),
      p47_implicitQttyTargetTax(t,all_regi,qttyTarget,qttyTargetGroup)$((t.val gt ttot2.val) and (t.val lt ttot.val) and (t.val ge cm_startyear)) = 
           p47_implicitQttyTargetTax(ttot2,all_regi,qttyTarget,qttyTargetGroup) +
        (
          p47_implicitQttyTargetTax(ttot,all_regi,qttyTarget,qttyTargetGroup) - p47_implicitQttyTargetTax(ttot2,all_regi,qttyTarget,qttyTargetGroup)
        ) * ((t.val - ttot2.val) / (ttot.val - ttot2.val))
      ;
    );
*** checking if there is a hard bound on the model that does not allow the tax to change further the energy usage
*** if current value (p47_implicitQttyTargetCurrent) is unchanged in relation to previous iteration when the rescale factor of the previous iteration was different than one, price changes did not affected quantity and therefore the tax level is reseted to the previous iteration value to avoid unecessary tax increase without target achievment gains.  
    if((iteration.val gt 3),
      if( ((p47_implicitQttyTargetCurrent_iter(iteration-1,ttot,ext_regi,qttyTarget,qttyTargetGroup) - p47_implicitQttyTargetCurrent(ttot,ext_regi,qttyTarget,qttyTargetGroup) lt 1e-10) AND (p47_implicitQttyTargetCurrent_iter(iteration-1,ttot,ext_regi,qttyTarget,qttyTargetGroup) - p47_implicitQttyTargetCurrent(ttot,ext_regi,qttyTarget,qttyTargetGroup) gt -1e-10) ) 
        and (NOT( p47_implicitQttyTargetTaxRescale_iter(iteration-1,ttot,ext_regi,qttyTarget,qttyTargetGroup) lt 0.0001 and p47_implicitQttyTargetTaxRescale_iter(iteration-1,ttot,ext_regi,qttyTarget,qttyTargetGroup) gt -0.0001 )),
        p47_implicitQttyTargetTax(t,all_regi,qttyTarget,qttyTargetGroup) = p47_implicitQttyTargetTax_prevIter(t,all_regi,qttyTarget,qttyTargetGroup);
        pm_implicitQttyTarget_isLimited(iteration,qttyTarget,qttyTargetGroup) = 1;
      );
    );
  );
*** update initialYear for further targets
  p47_implicitQttyTarget_initialYear(ext_regi,taxType,targetType,qttyTarget,qttyTargetGroup) = ttot.val;
);

p47_implicitQttyTargetTax_iter(iteration,ttot,all_regi,qttyTarget,qttyTargetGroup) = p47_implicitQttyTargetTax(ttot,all_regi,qttyTarget,qttyTargetGroup);

display p47_implicitQttyTargetCurrent, pm_implicitQttyTarget, p47_implicitQttyTargetTax_prevIter, pm_implicitQttyTarget_dev, p47_implicitQttyTarget_dev_iter, p47_implicitQttyTargetTax, p47_implicitQttyTargetTaxRescale, p47_implicitQttyTargetTaxRescale_iter, p47_implicitQttyTargetTax_iter, p47_implicitQttyTargetCurrent_iter, p47_implicitQttyTargetTax0;

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
  pm_taxCO2eqHist(ttot,regi)$(regi_group(ext_regi,regi) and (ttot.val ge cm_startyear)) = 0;
  pm_taxCO2eqSCC(ttot,regi)$(regi_group(ext_regi,regi) and (ttot.val ge cm_startyear)) = 0;

  pm_taxrevGHG0(ttot,regi)$(regi_group(ext_regi,regi) and (ttot.val ge cm_startyear)) = 0;
  pm_taxrevCO2Sector0(ttot,regi,emi_sectors)$(regi_group(ext_regi,regi) and (ttot.val ge cm_startyear)) = 0;
  pm_taxrevCO2LUC0(ttot,regi)$(regi_group(ext_regi,regi) and (ttot.val ge cm_startyear)) = 0;
  pm_taxrevNetNegEmi0(ttot,regi)$(regi_group(ext_regi,regi) and (ttot.val ge cm_startyear)) = 0;

  pm_taxemiMkt(ttot,regi,emiMkt)$(regi_group(ext_regi,regi) and (ttot.val ge cm_startyear)) = 0;

*** setting exogenous CO2 prices
  pm_taxCO2eq(ttot,regi)$(regi_group(ext_regi,regi) and (ttot.val ge cm_startyear)) = p47_exoCo2tax(ext_regi,ttot)*sm_DptCO2_2_TDpGtC;
);
display 'update of CO2 prices due to exogenously given CO2 prices in p47_exoCo2tax', pm_taxCO2eq;
$endIf.regiExoPrice

*** EOF ./modules/47_regipol/regiCarbonPrice/postsolve.gms
