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

*** net CO2 per Mkt 
p47_emiTargetMkt(ttot,regi,emiMktExt,"netCO2")$(ttot.val ge 2005) = 
  sum(emiMkt$emiMktGroup(emiMktExt,emiMkt), vm_emiAllMkt.l(ttot,regi,"co2",emiMkt) );

*** net CO2 per Mkt without bunkers 
p47_emiTargetMkt(ttot,regi,emiMktExt,"netCO2_noBunkers")$(ttot.val ge 2005) =
  sum(emiMkt$emiMktGroup(emiMktExt,emiMkt), vm_emiAllMkt.l(ttot,regi,"co2",emiMkt) )
  - (
    sum(se2fe(enty,enty2,te),
      pm_emifac(ttot,regi,enty,enty2,te,"co2")
      * vm_demFeSector.l(ttot,regi,enty,enty2,"trans","other")
      )
  )$(sameas(emiMktExt,"other") or sameas(emiMktExt,"all"))
;

*** net CO2 per Mkt without bunkers and without LULUCF
p47_emiTargetMkt(ttot,regi, emiMktExt,"netCO2_noLULUCF_noBunkers")$(ttot.val ge 2005) = 
  sum(emiMkt$(emiMktGroup(emiMktExt,emiMkt) and (sameas(emiMkt,"ETS") or sameas(emiMkt,"ES"))), vm_emiAllMkt.l(ttot,regi,"co2",emiMkt) );

*** net GHG per Mkt
p47_emiTargetMkt(ttot,regi,emiMktExt,"netGHG")$(ttot.val ge 2005) = 
  sum(emiMkt$emiMktGroup(emiMktExt,emiMkt),vm_co2eqMkt.l(ttot,regi,emiMkt) );

*** net GHG per Mkt without bunkers
p47_emiTargetMkt(ttot,regi, emiMktExt,"netGHG_noBunkers")$(ttot.val ge 2005) =
  sum(emiMkt$emiMktGroup(emiMktExt,emiMkt),vm_co2eqMkt.l(ttot,regi,emiMkt) )
  - (
    sum(se2fe(enty,enty2,te),
    (pm_emifac(ttot,regi,enty,enty2,te,"co2")
    + pm_emifac(ttot,regi,enty,enty2,te,"n2o")*sm_tgn_2_pgc
    + pm_emifac(ttot,regi,enty,enty2,te,"ch4")*sm_tgch4_2_pgc)
     * vm_demFeSector.l(ttot,regi,enty,enty2,"trans","other")) 
  )$(sameas(emiMktExt,"other") or sameas(emiMktExt,"all"))
;

*** net GHG per Mkt without bunkers and without LULUCF
p47_emiTargetMkt(ttot,regi, emiMktExt,"netGHG_noLULUCF_noBunkers")$(ttot.val ge 2005) = 
  sum(emiMkt$(emiMktGroup(emiMktExt,emiMkt) and (sameas(emiMkt,"ETS") or sameas(emiMkt,"ES"))),vm_co2eqMkt.l(ttot,regi,emiMkt) );

*** net GHG per Mkt without bunkers and without Grassi LULUCF
p47_emiTargetMkt(ttot,regi, emiMktExt,"netGHG_LULUCFGrassi_noBunkers")$(ttot.val ge 2005) =
  sum(emiMkt$emiMktGroup(emiMktExt,emiMkt),vm_co2eqMkt.l(ttot,regi,emiMkt) )
  - (
      sum(se2fe(enty,enty2,te),
      (pm_emifac(ttot,regi,enty,enty2,te,"co2")
      + pm_emifac(ttot,regi,enty,enty2,te,"n2o")*sm_tgn_2_pgc
      + pm_emifac(ttot,regi,enty,enty2,te,"ch4")*sm_tgch4_2_pgc)
      * vm_demFeSector.l(ttot,regi,enty,enty2,"trans","other")
    ) 
    - p47_LULUCFEmi_GrassiShift(ttot,regi)
  )$(sameas(emiMktExt,"other") or sameas(emiMktExt,"all"))
;

*** gross energy CO2 emissions (excl. BECCS and bunkers). note: industry BECCS is still missing from this variable, to be added in the future
p47_emiTarget_grossEnCO2_noBunkers_iter(iteration,ttot,regi)$(ttot.val ge 2005) =
  vm_emiTe.l(ttot,regi,"co2") !! total net CO2 energy CO2 (w/o DAC accounting of synfuels) 
  +  vm_emiCdr.l(ttot,regi,"co2") * (1-pm_share_CCS_CCO2(ttot,regi)) !! DAC accounting of synfuels: remove CO2 of vm_emiCDR (which is negative) from vm_emiTe which is not stored in vm_co2CCS
  +  sum(emi2te(enty,enty2,te,enty3)$(teBio(te) AND teCCS(te) AND sameAs(enty3,"cco2")), vm_emiTeDetail.l(ttot,regi,enty,enty2,te,enty3)) * pm_share_CCS_CCO2(ttot,regi) !! add pe2se BECCS
  +  sum( (entySe,entyFe,secInd37,emiMkt)$(NOT (entySeFos(entySe))), !! add industry CCS with hydrocarbon fuels from biomass (industry BECCS) or synthetic origin
    pm_IndstCO2Captured(ttot,regi,entySe,entyFe,secInd37,emiMkt)) * pm_share_CCS_CCO2(ttot,regi)
  -  sum(se2fe(enty,enty2,te), pm_emifac(ttot,regi,enty,enty2,te,"co2") * vm_demFeSector.l(ttot,regi,enty,enty2,"trans","other")) !! remove bunker emissions
;

***--------------------------------------------------
*** Emission markets (EU Emission trading system and Effort Sharing)
***--------------------------------------------------

$IFTHEN.emiMkt not "%cm_emiMktTarget%" == "off" 

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
***   using previous iteration information to define rescale factor       
    else
***     for the extreme case of a perfect match with no change between the two previous iteration emisssion taxes, in order to avoid a division by zero error, assume the rescale factor based on remaining deviation
        if((pm_taxemiMkt_iteration(iteration,ttot2,regi,emiMkt) eq pm_taxemiMkt_iteration(iteration-1,ttot2,regi,emiMkt)),
          pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt) = (1+pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt)) ** 2;
***     else calculate rescale factor based on slope of previous iterations mitigation levels when compared to relative price difference          
        else
          p47_factorRescaleSlope(ttot,ttot2,ext_regi,emiMktExt) =
            (p47_emiMktCurrent_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) - p47_emiMktCurrent_iter(iteration-1,ttot,ttot2,ext_regi,emiMktExt))
            /
            (pm_taxemiMkt_iteration(iteration,ttot2,regi,emiMkt) - pm_taxemiMkt_iteration(iteration-1,ttot2,regi,emiMkt))
          ;
          p47_factorRescaleIntersect(ttot,ttot2,ext_regi,emiMktExt) = 
            p47_emiMktCurrent_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) - p47_factorRescaleSlope(ttot,ttot2,ext_regi,emiMktExt)*pm_taxemiMkt_iteration(iteration,ttot2,regi,emiMkt)
          ;
          pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt) = 
            (pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47) - p47_factorRescaleIntersect(ttot,ttot2,ext_regi,emiMktExt))
            / 
            p47_factorRescaleSlope(ttot,ttot2,ext_regi,emiMktExt)
            /
            pm_taxemiMkt_iteration(iteration,ttot2,regi,emiMkt)
          ;		  
        );    
      );  
    );
  );
);
p47_factorRescaleSlope_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) = p47_factorRescaleSlope(ttot,ttot2,ext_regi,emiMktExt);
p47_factorRescaleIntersect_iter(iteration,ttot,ttot2,ext_regi,emiMktExt) = p47_factorRescaleIntersect(ttot,ttot2,ext_regi,emiMktExt);

*** if sequential target achieved a solution and cm_prioRescaleFactor != off, prioritize short term targets rescaling. e.g. multiplicative factor equal to 1 if target is 2030 or lower, and equal to 0.2 (s47_prioRescaleFactor) if target is 2050 or higher.
$ifThen.prioRescaleFactor not "%cm_prioRescaleFactor%" == "off" 
loop((ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47)$pm_emiMktTarget(ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47),
  if(p47_allTargetsConverged(ext_regi),
    pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt) = min(max(1-((ttot2.val-2030)/(20/(1-s47_prioRescaleFactor))),s47_prioRescaleFactor),1)*(pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt)-1)+1;
  );
);
$endIf.prioRescaleFactor
pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt)$pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt) = min(max(0.1,pm_factorRescaleemiMktCO2Tax(ttot,ttot2,ext_regi,emiMktExt)),10); !! clamp the rescale factor between 0.1 (to avoid negative values) and 10 (extremely high price change in between iterations)
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
            break$((ttot3.val ge ttot.val) and (ttot3.val ge cm_startyear)); !!initial free price year
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
loop((ttot,ttot2,ext_regi,emiMktExt,target_type_47,emi_type_47)$pm_emiMktTarget(ttot,ttot2,ext_regi,"ESR",target_type_47,emi_type_47),
  loop(regi$regi_groupExt(ext_regi,regi),
    pm_taxemiMkt(t,regi,"other") = pm_taxemiMkt(t,regi,"ES");
  );
);
*** display pm_emiMktTarget,pm_emiMktCurrent,pm_emiMktRefYear,pm_emiMktTarget_dev,pm_factorRescaleemiMktCO2Tax;

$ENDIF.emiMkt


***---------------------------------------------------------------------------
*** Calculation of implicit tax/subsidy necessary to achieve primary, secondary and/or final energy targets
***---------------------------------------------------------------------------

$ifthen.cm_implicitEnergyBound not "%cm_implicitEnergyBound%" == "off"

*** saving previous iteration value for implicit tax revenue recycling
p47_implEnergyBoundTax_prevIter(t,regi,energyCarrierLevel,energyType) = p47_implEnergyBoundTax(t,regi,energyCarrierLevel,energyType);
p47_implEnergyBoundTax0(t,regi) =
  sum((energyCarrierLevel,energyType)$p47_implEnergyBoundTax(t,regi,energyCarrierLevel,energyType),
  ( p47_implEnergyBoundTax(t,regi,energyCarrierLevel,energyType) * sum(entyPe$energyCarrierANDtype2enty(energyCarrierLevel,energyType,entyPe), sum(pe2se(entyPe,entySe,te), vm_demPe.l(t,regi,entyPe,entySe,te))) 
  )$(sameas(energyCarrierLevel,"PE")) 
  +
  ( p47_implEnergyBoundTax(t,regi,energyCarrierLevel,energyType) * sum(entySe$energyCarrierANDtype2enty(energyCarrierLevel,energyType,entySe), sum(se2fe(entySe,entyFe,te), vm_demSe.l(t,regi,entySe,entyFe,te))) 
  )$(sameas(energyCarrierLevel,"SE")) 
  +
  ( p47_implEnergyBoundTax(t,regi,energyCarrierLevel,energyType) * sum(entySe$energyCarrierANDtype2enty("FE",energyType,entySe), sum(se2fe(entySe,entyFe,te), sum((sector,emiMkt)$(entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)), vm_demFeSector.l(t,regi,entySe,entyFe,sector,emiMkt)))) 
  )$(sameas(energyCarrierLevel,"FE") or sameas(energyCarrierLevel,"FE_wo_b") or sameas(energyCarrierLevel,"FE_wo_n_e") or sameas(energyCarrierLevel,"FE_wo_b_wo_n_e"))
  )
;

***  Calculating current PE, SE and/or FE energy type level
loop((ttot,ext_regi,taxType,targetType,energyCarrierLevel,energyType)$pm_implEnergyBoundTarget(ttot,ext_regi,taxType,targetType,energyCarrierLevel,energyType),
  if(sameas(targetType,"t"), !!absolute target (t=total) 
    p47_implEnergyBoundCurrent(ttot,ext_regi,energyCarrierLevel,energyType) = 
    (
      sum(regi$regi_groupExt(ext_regi,regi), sum(entyPe$energyCarrierANDtype2enty("PE",energyType,entyPe), sum(pe2se(entyPe,entySe,te), vm_demPe.l(ttot,regi,entyPe,entySe,te))) )
    )$(sameas(energyCarrierLevel,"PE")) 
    +
    ( 
      sum(regi$regi_groupExt(ext_regi,regi), sum(entySe$energyCarrierANDtype2enty("SE",energyType,entySe), sum(se2fe(entySe,entyFe,te), vm_demSe.l(ttot,regi,entySe,entyFe,te))) )
    )$(sameas(energyCarrierLevel,"SE")) 
    +
    ( 
      sum(regi$regi_groupExt(ext_regi,regi),  sum(entySe$energyCarrierANDtype2enty("FE",energyType,entySe), sum(se2fe(entySe,entyFe,te), sum((sector,emiMkt)$(entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)), vm_demFeSector.l(ttot,regi,entySe,entyFe,sector,emiMkt)))) )
      + ( - ( sum(regi$regi_groupExt(ext_regi,regi), sum(entySe$energyCarrierANDtype2enty("FE",energyType,entySe), sum(se2fe(entySe,entyFe,te),  vm_demFeSector.l(ttot,regi,entySe,entyFe,"trans","other")) )) ) !! removing bunkers from FE targets
      )$(sameas(energyCarrierLevel,"FE_wo_b") or sameas(energyCarrierLevel,"FE_wo_b_wo_n_e"))
      +
      ( - ( p47_nonEnergyUse(ttot,ext_regi) )$((sameas(energytype,"all") or sameas(energytype,"fossil"))) !! removing non-energy use if energy type = all (this assumes all no energy use belongs to fossil and should be changed once feedstocks are endogenous to the model)
      )$(sameas(energyCarrierLevel,"FE_wo_n_e") or sameas(energyCarrierLevel,"FE_wo_b_wo_n_e")) 
    )$(sameas(energyCarrierLevel,"FE") or sameas(energyCarrierLevel,"FE_wo_b") or sameas(energyCarrierLevel,"FE_wo_n_e") or sameas(energyCarrierLevel,"FE_wo_b_wo_n_e"))
  ;
  ); 
  if(sameas(targetType,"s"), !!relative target (s=share) 
    p47_implEnergyBoundCurrent(ttot,ext_regi,energyCarrierLevel,energyType) = 
    (
      ( sum(regi$regi_groupExt(ext_regi,regi), sum(entyPe$energyCarrierANDtype2enty("PE",energyType,entyPe), sum(pe2se(entyPe,entySe,te), vm_demPe.l(ttot,regi,entyPe,entySe,te))) ) )
      /
      ( sum(regi$regi_groupExt(ext_regi,regi), sum(entyPe$energyCarrierANDtype2enty("PE","all",entyPe), sum(pe2se(entyPe,entySe,te), vm_demPe.l(ttot,regi,entyPe,entySe,te))) ) )
    )$(sameas(energyCarrierLevel,"PE")) 
    +
    ( 
      ( sum(regi$regi_groupExt(ext_regi,regi), sum(entySe$energyCarrierANDtype2enty("SE",energyType,entySe), sum(se2fe(entySe,entyFe,te), vm_demSe.l(ttot,regi,entySe,entyFe,te))) ) )
      /
      ( sum(regi$regi_groupExt(ext_regi,regi), sum(entySe$energyCarrierANDtype2enty("SE","all",entySe), sum(se2fe(entySe,entyFe,te), vm_demSe.l(ttot,regi,entySe,entyFe,te))) ) )
    )$(sameas(energyCarrierLevel,"SE")) 
    +
    (   (
      sum(regi$regi_groupExt(ext_regi,regi),  sum(entySe$energyCarrierANDtype2enty("FE",energyType,entySe), sum(se2fe(entySe,entyFe,te), sum((sector,emiMkt)$(entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)), vm_demFeSector.l(ttot,regi,entySe,entyFe,sector,emiMkt)))) )
      + ( - ( sum(regi$regi_groupExt(ext_regi,regi), sum(entySe$energyCarrierANDtype2enty("FE",energyType,entySe), sum(se2fe(entySe,entyFe,te),  vm_demFeSector.l(ttot,regi,entySe,entyFe,"trans","other")) )) ) !! removing bunkers from FE targets
      )$(sameas(energyCarrierLevel,"FE_wo_b") or sameas(energyCarrierLevel,"FE_wo_b_wo_n_e"))
      +
      ( - ( p47_nonEnergyUse(ttot,ext_regi) )$((sameas(energytype,"all") or sameas(energytype,"fossil"))) !! removing non-energy use if energy type = all (this assumes all no energy use belongs to fossil and should be changed once feedstocks are endogenous to the model)
      )$(sameas(energyCarrierLevel,"FE_wo_n_e") or sameas(energyCarrierLevel,"FE_wo_b_wo_n_e")) 
        )
      /
      (
      sum(regi$regi_groupExt(ext_regi,regi),  sum(entySe$energyCarrierANDtype2enty("FE","all",entySe), sum(se2fe(entySe,entyFe,te), sum((sector,emiMkt)$(entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)), vm_demFeSector.l(ttot,regi,entySe,entyFe,sector,emiMkt)))) )
      + ( - ( sum(regi$regi_groupExt(ext_regi,regi), sum(entySe$energyCarrierANDtype2enty("FE","all",entySe), sum(se2fe(entySe,entyFe,te),  vm_demFeSector.l(ttot,regi,entySe,entyFe,"trans","other")) )) ) !! removing bunkers from FE targets
      )$(sameas(energyCarrierLevel,"FE_wo_b") or sameas(energyCarrierLevel,"FE_wo_b_wo_n_e"))
      +
      ( - ( p47_nonEnergyUse(ttot,ext_regi) ) !! removing non-energy use if energy type = all (this assumes all no energy use belongs to fossil and should be changed once feedstocks are endogenous to the model)
      )$(sameas(energyCarrierLevel,"FE_wo_n_e") or sameas(energyCarrierLevel,"FE_wo_b_wo_n_e")) 
      )  
    )$(sameas(energyCarrierLevel,"FE") or sameas(energyCarrierLevel,"FE_wo_b") or sameas(energyCarrierLevel,"FE_wo_n_e") or sameas(energyCarrierLevel,"FE_wo_b_wo_n_e"))
  ;
  ); 
);
p47_implEnergyBoundCurrent_iter(iteration,ttot,ext_regi,energyCarrierLevel,energyType) = p47_implEnergyBoundCurrent(ttot,ext_regi,energyCarrierLevel,energyType);

*** calculate target deviation
loop((ttot,ext_regi,taxType,targetType,energyCarrierLevel,energyType)$pm_implEnergyBoundTarget(ttot,ext_regi,taxType,targetType,energyCarrierLevel,energyType),
  if(sameas(targetType,"t"),
    pm_implEnergyBoundTarget_dev(ttot,ext_regi,energyCarrierLevel,energyType) = ( p47_implEnergyBoundCurrent(ttot,ext_regi,energyCarrierLevel,energyType) - pm_implEnergyBoundTarget(ttot,ext_regi,taxType,targetType,energyCarrierLevel,energyType) ) / pm_implEnergyBoundTarget(ttot,ext_regi,taxType,targetType,energyCarrierLevel,energyType);
  );
  if(sameas(targetType,"s"),
    pm_implEnergyBoundTarget_dev(ttot,ext_regi,energyCarrierLevel,energyType) = p47_implEnergyBoundCurrent(ttot,ext_regi,energyCarrierLevel,energyType) - pm_implEnergyBoundTarget(ttot,ext_regi,taxType,targetType,energyCarrierLevel,energyType);
  );
* save regional target deviation across iterations for debugging of target convergence issues
  p47_implEnergyBoundTarget_dev_iter(iteration, ttot,ext_regi,energyCarrierLevel,energyType) = pm_implEnergyBoundTarget_dev(ttot,ext_regi,energyCarrierLevel,energyType);
);

***  calculating targets implicit tax rescale factor
loop((ttot,ext_regi,taxType,targetType,energyCarrierLevel,energyType)$pm_implEnergyBoundTarget(ttot,ext_regi,taxType,targetType,energyCarrierLevel,energyType),
  if(sameas(taxType,"tax"),
    if(iteration.val lt 15,
      p47_implEnergyBoundTax_Rescale(ttot,ext_regi,energyCarrierLevel,energyType) = (1 + pm_implEnergyBoundTarget_dev(ttot,ext_regi,energyCarrierLevel,energyType) ) ** 4;
    else
      p47_implEnergyBoundTax_Rescale(ttot,ext_regi,energyCarrierLevel,energyType) = (1 + pm_implEnergyBoundTarget_dev(ttot,ext_regi,energyCarrierLevel,energyType) ) ** 2;
    );  
  );
  if(sameas(taxType,"sub"),
    if(iteration.val lt 15,
      p47_implEnergyBoundTax_Rescale(ttot,ext_regi,energyCarrierLevel,energyType) = (1 - pm_implEnergyBoundTarget_dev(ttot,ext_regi,energyCarrierLevel,energyType) ) ** 4;
    else
      p47_implEnergyBoundTax_Rescale(ttot,ext_regi,energyCarrierLevel,energyType) = (1 - pm_implEnergyBoundTarget_dev(ttot,ext_regi,energyCarrierLevel,energyType) ) ** 2;
    );  
  );
*** dampen rescale factor with increasing iterations to help convergence if the last two iteration deviations where not in the same direction 
  if((iteration.val gt 3) and (p47_implEnergyBoundTarget_dev_iter(iteration, ttot,ext_regi,energyCarrierLevel,energyType)*p47_implEnergyBoundTarget_dev_iter(iteration-1, ttot,ext_regi,energyCarrierLevel,energyType) < 0),
  p47_implEnergyBoundTax_Rescale(ttot,ext_regi,energyCarrierLevel,energyType) =
    max(min( 2 * EXP( -0.15 * iteration.val ) + 1.01 ,p47_implEnergyBoundTax_Rescale(ttot,ext_regi,energyCarrierLevel,energyType)),1/ ( 2 * EXP( -0.15 * iteration.val ) + 1.01));
  );
);

p47_implEnergyBoundTax_Rescale_iter(iteration,ttot,ext_regi,energyCarrierLevel,energyType) = p47_implEnergyBoundTax_Rescale(ttot,ext_regi,energyCarrierLevel,energyType);

*** updating energy targets implicit tax
pm_implEnergyBoundLimited(iteration,energyCarrierLevel,energyType) = 0;
loop((ttot,ext_regi,taxType,targetType,energyCarrierLevel,energyType)$pm_implEnergyBoundTarget(ttot,ext_regi,taxType,targetType,energyCarrierLevel,energyType),
  loop(all_regi$regi_groupExt(ext_regi,all_regi),
*** terminal year onward tax
    if(sameas(taxType,"tax"),
      p47_implEnergyBoundTax(t,all_regi,energyCarrierLevel,energyType)$(t.val ge ttot.val) = max(1e-10, p47_implEnergyBoundTax_prevIter(t,all_regi,energyCarrierLevel,energyType) * p47_implEnergyBoundTax_Rescale(ttot,ext_regi,energyCarrierLevel,energyType)); !! assuring that the updated tax is positive, otherwise other policies like the carbon tax are already enough to achieve the efficiency target
    );
    if(sameas(taxType,"sub"),
      p47_implEnergyBoundTax(t,all_regi,energyCarrierLevel,energyType)$(t.val ge ttot.val) = min(1e-10, p47_implEnergyBoundTax_prevIter(t,all_regi,energyCarrierLevel,energyType) * p47_implEnergyBoundTax_Rescale(ttot,ext_regi,energyCarrierLevel,energyType)); !! assuring that the updated tax is negative (subsidy)
    );
*** linear price between first free year and terminal year
    loop(ttot2,
      s47_firstFreeYear = ttot2.val; 
      break$((ttot2.val ge ttot.val) and (ttot2.val ge cm_startyear)); !!initial free price year
      s47_prefreeYear = ttot2.val;
    );
    loop(ttot2$(ttot2.val eq s47_prefreeYear),
      p47_implEnergyBoundTax(t,all_regi,energyCarrierLevel,energyType)$((t.val ge s47_firstFreeYear) and (t.val lt ttot.val) and (t.val ge cm_startyear)) = 
           p47_implEnergyBoundTax(ttot2,all_regi,energyCarrierLevel,energyType) +
        (
          p47_implEnergyBoundTax(ttot,all_regi,energyCarrierLevel,energyType) - p47_implEnergyBoundTax(ttot2,all_regi,energyCarrierLevel,energyType)
        ) / (ttot.val - ttot2.val)
        * (t.val - ttot2.val)
      ;
    );
*** checking if there is a hard bound on the model that does not allow the tax to change further the energy usage
*** if current value (p47_implEnergyBoundCurrent) is unchanged in relation to previous iteration when the rescale factor of the previous iteration was different than one, price changes did not affected quantity and therefore the tax level is reseted to the previous iteration value to avoid unecessary tax increase without target achievment gains.  
    if((iteration.val gt 3),
      if( ((p47_implEnergyBoundCurrent_iter(iteration-1,ttot,ext_regi,energyCarrierLevel,energyType) - p47_implEnergyBoundCurrent(ttot,ext_regi,energyCarrierLevel,energyType) lt 1e-10) AND (p47_implEnergyBoundCurrent_iter(iteration-1,ttot,ext_regi,energyCarrierLevel,energyType) - p47_implEnergyBoundCurrent(ttot,ext_regi,energyCarrierLevel,energyType) gt -1e-10) ) 
        and (NOT( p47_implEnergyBoundTax_Rescale_iter(iteration-1,ttot,ext_regi,energyCarrierLevel,energyType) lt 0.0001 and p47_implEnergyBoundTax_Rescale_iter(iteration-1,ttot,ext_regi,energyCarrierLevel,energyType) gt -0.0001 )),
        p47_implEnergyBoundTax(t,all_regi,energyCarrierLevel,energyType) = p47_implEnergyBoundTax_prevIter(t,all_regi,energyCarrierLevel,energyType);
        pm_implEnergyBoundLimited(iteration,energyCarrierLevel,energyType) = 1;
      );
    );
  );
);

p47_implEnergyBoundTax_iter(iteration,ttot,all_regi,energyCarrierLevel,energyType) = p47_implEnergyBoundTax(ttot,all_regi,energyCarrierLevel,energyType);

display p47_implEnergyBoundCurrent, pm_implEnergyBoundTarget, p47_implEnergyBoundTax_prevIter, pm_implEnergyBoundTarget_dev, p47_implEnergyBoundTarget_dev_iter, p47_implEnergyBoundTax, p47_implEnergyBoundTax_Rescale, p47_implEnergyBoundTax_Rescale_iter, p47_implEnergyBoundTax_iter, p47_implEnergyBoundCurrent_iter, p47_implEnergyBoundTax0;


$endIf.cm_implicitEnergyBound


***---------------------------------------------------------------------------
*** Calculation of implicit tax/subsidy necessary to final energy price targets
***---------------------------------------------------------------------------

$ifthen.cm_implicitPriceTarget not "%cm_implicitPriceTarget%" == "off"

*** saving previous iteration value for implicit tax revenue recycling
  p47_implicitPriceTax0(t,regi,entyFe,entySe,sector)$p47_implicitPriceTarget(t,regi,entyFe,entySe,sector) = p47_implicitPriceTax(t,regi,entyFe,entySe,sector) * sum(emiMkt$sector2emiMkt(sector,emiMkt), vm_demFeSector.l(t,regi,entySe,entyFe,sector,emiMkt));

*** Calculate target deviation
  p47_implicitPrice_dev(t,regi,entyFe,entySe,sector)$p47_implicitPriceTarget(t,regi,entyFe,entySe,sector) = ((pm_FEPrice_by_SE_Sector(t,regi,entySe,entyFe,sector) - p47_implicitPriceTarget(t,regi,entyFe,entySe,sector)) / p47_implicitPriceTarget(t,regi,entyFe,entySe,sector));
* save regional target deviation across iterations for debugging of target convergence issues
  p47_implicitPrice_dev_iter(iteration,t,regi,entyFe,entySe,sector) = p47_implicitPrice_dev(t,regi,entyFe,entySe,sector);

*** updating implicit price target tax
***  p47_implicitPriceTax(t,regi,entyFe,entySe,sector)$p47_implicitPriceTarget(t,regi,entyFe,entySe,sector) = (p47_implicitPriceTarget(t,regi,entyFe,entySe,sector) - pm_FEPrice_by_SE_Sector(t,regi,entySe,entyFe,sector));
  if((iteration.val eq 1),
***    p47_implicitPriceTax(t,regi,entyFe,entySe,sector)$p47_implicitPriceTarget(t,regi,entyFe,entySe,sector) = (p47_implicitPriceTarget(t,regi,entyFe,entySe,sector) - pm_FEPrice_by_SE_Sector(t,regi,entySe,entyFe,sector));
    p47_implicitPriceTax(t,regi,entyFe,entySe,sector)$p47_implicitPriceTarget(t,regi,entyFe,entySe,sector) = 0.001; !!small value just to initialize first iteration
  else
***    p47_implicitPriceTax(t,regi,entyFe,entySe,sector)$p47_implicitPriceTarget(t,regi,entyFe,entySe,sector) = (p47_implicitPriceTarget(t,regi,entyFe,entySe,sector) - (pm_FEPrice_by_SE_Sector(t,regi,entySe,entyFe,sector) + pm_FEPrice_by_SE_Sector_iter(iteration-1,t,regi,entySe,entyFe,sector))/2 ) + p47_implicitPriceTax_iter(iteration-1,t,regi,entyFe,entySe,sector); !!using average of two last iterations to avoid zigzag behavior
    p47_implicitPriceTax(t,regi,entyFe,entySe,sector)$(p47_implicitPriceTarget(t,regi,entyFe,entySe,sector) and pm_FEPrice_by_SE_Sector(t,regi,entySe,entyFe,sector)) = 
      (p47_implicitPriceTarget(t,regi,entyFe,entySe,sector) - pm_FEPrice_by_SE_Sector(t,regi,entySe,entyFe,sector))/2 !! only applying half of the deviation to avoid overshooting
      + p47_implicitPriceTax_iter(iteration-1,t,regi,entyFe,entySe,sector); 
  );
  p47_implicitPriceTax("2080",regi,entyFe,entySe,sector)$p47_implicitPriceTax("2070",regi,entyFe,entySe,sector) = p47_implicitPriceTax("2070",regi,entyFe,entySe,sector)*2/3;
  p47_implicitPriceTax("2090",regi,entyFe,entySe,sector)$p47_implicitPriceTax("2070",regi,entyFe,entySe,sector) = p47_implicitPriceTax("2070",regi,entyFe,entySe,sector)*1/3;
  
*** limit the size of subsidies (-0.5 T$/TWa) to avoid extreme negative price markups (these cases are disconsidered when checking for price convergence)
  p47_implicitPrice_dev_adj(t,regi,entyFe,entySe,sector) = p47_implicitPrice_dev(t,regi,entyFe,entySe,sector);
  loop((t,regi,entyFe,entySe,sector)$p47_implicitPriceTarget(t,regi,entyFe,entySe,sector),
    if (( p47_implicitPriceTax(t,regi,entyFe,entySe,sector) < -0.5 ),
      p47_implicitPriceTax(t,regi,entyFe,entySe,sector) = -0.5;
      p47_implicitPrice_dev_adj(t,regi,entyFe,entySe,sector) = 0; !! reset deviation calculated values to avoid this case to be considered in the decision of running additional iterations  
    );
  );

* save price target tax across iterations for debugging of target convergence issues
p47_implicitPriceTax_iter(iteration,t,regi,entyFe,entySe,sector) = p47_implicitPriceTax(t,regi,entyFe,entySe,sector);

display p47_implicitPriceTarget, p47_implicitPriceTax, p47_implicitPrice_dev, p47_implicitPrice_dev_adj, p47_implicitPriceTax_iter, p47_implicitPrice_dev_iter;
$endIf.cm_implicitPriceTarget

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
