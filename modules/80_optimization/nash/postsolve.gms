*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/nash/postsolve.gms



***------------------------------------------------------------------------------
*' #### Price corrections to improve convergence of next iteration
***------------------------------------------------------------------------------

*' The objective of the nash optimisation is to find a set of prices that clears the markets.
*' If a certain trade has a positive surplus, it means that the global price is too high and should be reduced to obtain convergence.
*' The price corrections are given by    price reduction   = price adjustment elasticity * market surplus / market volume
*'                        for example    p80_etaST_correct = p80_etaST                   * p80_surplus    / p80_marketVolume

*' Compute market volume for different trades (take values from last iteration for regions that were not solved optimally)
loop(ttot $ (ttot.val >= 2005),
  loop(regi $ (pm_SolNonInfes(regi) = 1),
    p80_marketVolume(ttot,regi,"good")  = max(sm_eps, vm_cons.l(ttot,regi));
    p80_marketVolume(ttot,regi,tradePe) = max(sm_eps, (sum(rlf, vm_fuExtr.l(ttot,regi,tradePe,rlf)) + vm_prodPe.l(ttot,regi,tradePe)) / 2);
  );
  loop(regi $ (pm_SolNonInfes(regi) = 0),
    p80_marketVolume(ttot,regi,"good")  = max(sm_eps, p80_marketVolume(ttot,regi,"good"));
    p80_marketVolume(ttot,regi,tradePe) = max(sm_eps, p80_marketVolume(ttot,regi,tradePe));
  );
*** ML: normalize permit trade corrections to consumption or positive cap path instead of emissions, as those may be negative
  p80_marketVolume(ttot,regi,"perm") = max(sm_eps, abs(pm_shPerm(ttot,regi) * pm_emicapglob("2050")));
);

loop(trade $ (not tradeSe(trade)),
*' Calculate residual surplus on the markets
  p80_surplus(ttot,trade,iteration) $ (ttot.val >= 2005) = sum(regi,
      (vm_Xport.l(ttot,regi,trade) - vm_Mport.l(ttot,regi,trade)) $ (pm_SolNonInfes(regi) = 1)
    + (pm_Xport0(ttot,regi,trade) - p80_Mport0(ttot,regi,trade) ) $ (pm_SolNonInfes(regi) = 0) );

*' Long term correction takes into account the aggregated intertemporal market revenue (instead of volume) defined by
*'      market revenue = price * duration * market yearly volume (or pm_pvp * pm_ts * p80_marketVolume)
  p80_intertemporalSurplusRevenue(trade,iteration) = sum(ttot $ (ttot.val >= cm_startyear),
    pm_pvp(ttot,trade) * pm_ts(ttot) * p80_surplus(ttot,trade,iteration));
  p80_itertemporalMarketRevenue(trade) = max(sm_eps, sum((ttot, regi) $ (ttot.val >= 2005),
    pm_pvp(ttot,trade) * pm_ts(ttot) * p80_marketVolume(ttot,regi,trade)));

  p80_etaLT_correct(trade,iteration) =
    p80_etaLT(trade) * p80_intertemporalSurplusRevenue(trade,iteration) / p80_itertemporalMarketRevenue(trade);

*' Short term correction takes into account the market surplus volume of a single time step
*' For permit and primary energy trade, price anticipation impacts the price correction
  p80_etaST_correct(ttot,trade,iteration) $ (ttot.val >= 2005) =
    p80_etaST(trade) * p80_surplus(ttot,trade,iteration) / max(sm_eps , sum(regi, p80_marketVolume(ttot,regi,trade)));

  p80_etaST_correct(ttot,"perm",iteration) $ (ttot.val >= 2005) = p80_etaST_correct(ttot,"perm",iteration)
    * ((1-sm_fadeoutPriceAnticip) + sm_fadeoutPriceAnticip * sqrt(pm_pvp(ttot,"good") / pm_pvp("2100","good"))) 
    * (sm_fadeoutPriceAnticip + (1-sm_fadeoutPriceAnticip) * (pm_pvp(ttot,"good") / pm_pvp("2040","good")));
  p80_etaST_correct(ttot,tradePe(trade),iteration) $ (ttot.val >= 2005) = p80_etaST_correct(ttot,trade,iteration)
    * (sm_fadeoutPriceAnticip + (1-sm_fadeoutPriceAnticip) * (pm_pvp(ttot,trade) / pm_pvp("2050",trade)));
);


*' If the surplus remains over several iterations, increase the price correction terms
p80_etaST_correct_safecopy(ttot,trade,iteration) $ (not tradeSe(trade)) = p80_etaST_correct(ttot,trade,iteration); !! copy of initial values

loop(ttot $ (ttot.val >= 2005),
  loop(trade $ (tradePe(trade) or sameas(trade,"good")),
    if(abs(p80_surplus(ttot,trade,iteration)) <= p80_surplusMaxTolerance(trade),
        o80_trackSurplusSign(ttot,trade,iteration) = 0; !! reset counter if surplus is within tolerance range
    else !! if surplus is outside tolerance range
      o80_SurplusOverTolerance(ttot,trade,iteration) = Sign(p80_surplus(ttot,trade,iteration)); !! track the sign of the surplus

      if(iteration.val > 2, 
        if(Sign(p80_surplus(ttot,trade,iteration)) = Sign(p80_surplus(ttot,trade,iteration-1)), !! if deviation is in the same direction as in previous iteration
          o80_trackSurplusSign(ttot,trade,iteration) = 1 + o80_trackSurplusSign(ttot,trade,iteration-1);
        else
          o80_trackSurplusSign(ttot,trade,iteration) = 0; !! reset counter if sign changed
        );
      );

      if(iteration.val > 15 and o80_trackSurplusSign(ttot,trade,iteration) >= 5, !! if surplus was beyond tolerance for 5 consecutive iterations
        p80_etaST_correct(ttot,trade,iteration) = 4 * p80_etaST_correct(ttot,trade,iteration);
        o80_counter_iteration_trade_ttot(ttot,trade,iteration) = 1;
      );
      if(iteration.val > 20 and o80_trackSurplusSign(ttot,trade,iteration) >= 10, !! push stronger if previous increase did not help after a few iterations
        p80_etaST_correct(ttot,trade,iteration) = 2 * p80_etaST_correct(ttot,trade,iteration);
        o80_counter_iteration_trade_ttot(ttot,trade,iteration) = 2;
      ); 
      if(iteration.val > 25 and o80_trackSurplusSign(ttot,trade,iteration) >= 15, !! push stronger if previous increase did not help after a few iterations
        p80_etaST_correct(ttot,trade,iteration) = 2 * p80_etaST_correct(ttot,trade,iteration);
        o80_counter_iteration_trade_ttot(ttot,trade,iteration) = 3;
      );
    ); !! if surplus is outside tolerance range
  ); !! trade
); !! ttot


*** calculate prices for next iteration, prevent prices from turning negative by limiting extreme prices corrections
p80_pvp_itr(ttot,trade,iteration+1) $ (ttot.val >= cm_startyear and not tradeSe(trade)) = 
  pm_pvp(ttot,trade) * max(0.05, 1 - p80_etaLT_correct(trade,iteration) - p80_etaST_correct(ttot,trade,iteration));

*** AJS: feed updated prices and quantities into the next iteration, ML: adjustments in case of infeasibilities (increase import)
loop(trade $ (not tradeSe(trade)),
  loop(ttot $ (ttot.val >= cm_startyear),
    pm_pvp(ttot,trade) = p80_pvp_itr(ttot,trade,iteration+1);
    pm_Xport0(ttot,regi,trade)  $ (pm_SolNonInfes(regi) = 1) = vm_Xport.l(ttot,regi,trade);
    p80_Mport0(ttot,regi,trade) $ (pm_SolNonInfes(regi) = 1) = vm_Mport.l(ttot,regi,trade);
    p80_Mport0(ttot,regi,trade) $ (pm_SolNonInfes(regi) = 0) = vm_Mport.l(ttot,regi,trade) * 1.2;
  );
);
p80_taxrev0(ttot,regi) $ (ttot.val >= max(2010, cm_startyear) and pm_SolNonInfes(regi) = 1) = vm_taxrev.l(ttot,regi);

loop(trade $ (not tradeSe(trade)),
*** AJS: calculate maximum residual surplus on markets, absolute and relative
  loop(ttot $ (ttot.val >= cm_startyear),
    p80_surplusMax_iter(trade,iteration,ttot) = smax(ttot2 $ (ttot2.val >= cm_startyear and ttot2.val <= ttot.val), abs(p80_surplus(ttot2,trade,iteration)));
    p80_surplusMaxRel(trade,iteration,ttot) = 100 * smax(ttot2 $ (ttot2.val >= cm_startyear and ttot2.val <= ttot.val), abs(p80_surplus(ttot2,trade,iteration)) / sum(regi, p80_marketVolume(ttot2,regi,trade)));
  );
  p80_surplusMax2100(trade) = p80_surplusMax_iter(trade,iteration,"2100");

*** convergence indicators
  p80_defic_trade(trade) = 1 / pm_pvp("2005","good") *
    sum(ttot $ (ttot.val >= 2005),
      pm_ts(ttot) * (
          abs(p80_surplus(ttot,trade,iteration)) * pm_pvp(ttot,trade)
        + sum(regi, abs(p80_taxrev0(ttot,regi)) * pm_pvp(ttot,"good")) $ (sameas(trade,"good") and ttot.val >= max(2010,cm_startyear) )
        + sum(regi, abs(vm_costAdjNash.l(ttot,regi)) * pm_pvp(ttot,"good")) $ (sameas(trade,"good") and (ttot.val >= 2005) )
      )
    );
);
p80_defic_sum("1") = 1;
p80_defic_sum(iteration) = sum(trade $ (not tradeSe(trade)), p80_defic_trade(trade)); 
p80_defic_sum_rel(iteration) = 100 * p80_defic_sum(iteration) / (p80_itertemporalMarketRevenue("good") / pm_pvp("2005","good"));


*** adjust parameters for next iteration 
*** Decide on when to fade out price anticipation terms if markets are reasonably cleared (doing this too early leads to diverging markets)
if(    smax(tradePe, p80_surplusMax_iter(tradePe,iteration,"2150")) < 0.5
   and p80_surplusMax_iter("good",iteration,"2150") < 1
   and p80_surplusMax_iter("perm",iteration,"2150") < 1
   and s80_fadeoutPriceAnticipStartingPeriod = 0, !! as long as we are not fading out already
     s80_fadeoutPriceAnticipStartingPeriod = iteration.val;
);

if(s80_fadeoutPriceAnticipStartingPeriod > 0,
  sm_fadeoutPriceAnticip = 0.7 ** (iteration.val - s80_fadeoutPriceAnticipStartingPeriod + 1);
);
display s80_fadeoutPriceAnticipStartingPeriod, sm_fadeoutPriceAnticip;


***------------------------------------------------------------------------------
*' #### Output and monitoring
***------------------------------------------------------------------------------

*** ML 2015-02-04: calculate current account, LB: needed for cost decomposition script
p80_curracc(ttot, regi) = sum(trade $ (not tradeSe(trade)),
  pm_pvp(ttot,trade) / max(pm_pvp(ttot,"good"), sm_eps) * (vm_Xport.l(ttot,regi,trade) - vm_Mport.l(ttot,regi,trade)));

*** diagnostic output: vm_taxrev globally from last iteration
p80_taxrev_agg(ttot,iteration) $ (ttot.val >= 2005) = sum(regi, vm_taxrev.l(ttot,regi));

*** save all FE prices across sectors and markets [tr$2005/TWa] across iterations
pm_FEPrice_iter(iteration,t,regi,enty,sector,emiMkt) = pm_FEPrice(t,regi,enty,sector,emiMkt);



*' calculate both the size of the price change due to the price change anticipation effect in percent
*' and the deviation of the yearly monetary export/import expenditure due to the price change anticipation effect
loop(ttot $ (ttot.val >= 2005),
  loop(trade $ (not tradeSe(trade)),
    p80_PriceChangePriceAnticipReg(ttot,trade,regi) = 100 *
      sm_fadeoutPriceAnticip * p80_etaXp(trade)
      * (   (pm_Xport0(ttot,regi,trade) - p80_Mport0(ttot,regi,trade)) - (vm_Xport.l(ttot,regi,trade) - vm_Mport.l(ttot,regi,trade))
          - (p80_taxrev0(ttot,regi) - vm_taxrev.l(ttot,regi)) $ (ttot.val > 2005 and sameas(trade,"good"))
        )
      / (p80_marketVolume(ttot,regi,trade) + sm_eps);

    p80_DevPriceAnticipReg(ttot,trade,regi) = 
      ( vm_Xport.l(ttot,regi,trade) - vm_Mport.l(ttot,regi,trade) ) 
      * pm_pvp(ttot,trade) / pm_pvp(ttot,"good")
      * p80_PriceChangePriceAnticipReg(ttot,trade,regi);

    p80_DevPriceAnticipGlob(ttot,trade) = sum(regi, abs( p80_DevPriceAnticipReg(ttot,trade,regi) ) );  
  );
  p80_DevPriceAnticipGlobAll(ttot) = sum(trade $ (not tradeSe(trade)), p80_DevPriceAnticipGlob(ttot,trade));
); !! end of ttot loop


*' calculate maximum of p80_DevPriceAnticipGlob
p80_DevPriceAnticipGlobMax(ttot,trade) $ (ttot.val >= cm_startyear and not tradeSe(trade)) = 
  smax(ttot2 $ (ttot2.val >= cm_startyear and ttot2.val <= ttot.val), p80_DevPriceAnticipGlob(ttot2,trade) );
*' calculate maximum of p80_DevPriceAnticipGlobAll
p80_DevPriceAnticipGlobAllMax(ttot) $ (ttot.val >= cm_startyear) = 
  smax(ttot2 $ (ttot2.val >= cm_startyear and ttot2.val <= ttot.val), p80_DevPriceAnticipGlobAll(ttot2) );

p80_DevPriceAnticipGlobIter(ttot,trade,iteration) $ (ttot.val >= cm_startyear and not tradeSe(trade)) = p80_DevPriceAnticipGlob(ttot,trade);
p80_DevPriceAnticipGlobMax2100Iter(trade,iteration) $ (not tradeSe(trade)) = p80_DevPriceAnticipGlobMax("2100",trade);
p80_DevPriceAnticipGlobAllMax2100Iter(iteration) = p80_DevPriceAnticipGlobAllMax("2100");


*' For display of price change p80_PriceChangePriceAnticipReg, round to 0.1% 
o80_PriceChangePriceAnticipReg(ttot,trade,regi) = round(p80_PriceChangePriceAnticipReg(ttot,trade,regi), 1);

*' determine largest price change in p80_PriceChangePriceAnticipReg
o80_PriceChangePriceAnticipRegMaxIter("2100",iteration) = smax( (ttot,trade,regi) $ (ttot.val <= 2100) , abs(o80_PriceChangePriceAnticipReg(ttot,trade,regi) ) );
o80_PriceChangePriceAnticipRegMaxIter("2150",iteration) = smax( (ttot,trade,regi) $ (ttot.val >= 2110) , abs(o80_PriceChangePriceAnticipReg(ttot,trade,regi) ) );

display  
  p80_DevPriceAnticipGlob, 
  p80_DevPriceAnticipGlobMax, 
  p80_DevPriceAnticipGlobAllMax, 
  p80_DevPriceAnticipGlobMax2100Iter,
  p80_DevPriceAnticipGlobAllMax2100Iter,
  p80_DevPriceAnticipGlobAll,  
  o80_PriceChangePriceAnticipReg
  o80_PriceChangePriceAnticipRegMaxIter
; 


***------------------------------------------------------------------------------
*' #### Convergence criteria
***------------------------------------------------------------------------------
*** Iterations continue if any of the convergence criteria is not met
*** Criteria are contained in convMessage80(surplus,infes,nonopt), and continuing means that s80_bool = 0

*** reset indicators
s80_bool = 1; !! assume all the criteria are met
p80_messageShow(convMessage80) = NO;   
p80_messageFailedMarket(ttot,all_enty) = NO;

*' criterion "surplus": did trade converge yet?
loop(trade $ (not tradeSe(trade)),
 if(p80_surplusMax_iter(trade,iteration,"2100") > p80_surplusMaxTolerance(trade),
    s80_bool = 0;                 
    p80_messageShow("surplus") = YES;
    loop(ttot $ (ttot.val >= cm_startyear and ttot.val <= 2100),
      if(abs(p80_surplus(ttot,trade,iteration)) > p80_surplusMaxTolerance(trade),
        p80_messageFailedMarket(ttot,trade) = YES;
      );
    );
 );
 if(p80_surplusMax_iter(trade,iteration,"2150") > 10 * p80_surplusMaxTolerance(trade),
    s80_bool = 0;
    p80_messageShow("surplus") = YES;
    loop(ttot $ (ttot.val >= cm_startyear and ttot.val > 2100),
      if(abs(p80_surplus(ttot,trade,iteration)) > p80_surplusMaxTolerance(trade),
        p80_messageFailedMarket(ttot,trade) = YES;
      );
    );
  );
);

*' critertion "infes": is any region neither optimal nor intermediate non-optimal? then it is infeasible 
loop(regi,
  if(p80_repy(regi,'modelstat') ne 2 and p80_repy(regi,'modelstat') ne 7, !! 2 is optimal, 7 nonopt,            
    s80_bool = 0;
    p80_messageShow("infes") = YES;
  );

*' critertion "nonopt":
*** The next lines are a workaround for the status 7 problem
*** If the objective value does not differ too much from the last known optimal solution, accept this solution as if it were optimal
  p80_convNashObjVal_iter(iteration,regi) = p80_repy(regi,'objval') - p80_repyLastOptim(regi,'objval');
  if(1 <= iteration.val, !! no last iteration if this is the first; NA value in p80_repyLastOptim is sticky, so test this separately
    if(p80_repy(regi,'modelstat') = 7 and p80_convNashObjVal_iter(iteration,regi) < - 1e-4,
      !! 1E-4 is quite arbitrary. One should do more research on how the solution differs over iteration when status 7 occurs. 
      s80_bool = 0;
      p80_messageShow("nonopt") = YES;     
      display "Not all regions were status 2 in the last iteration. The deviation of the objective function from the last optimal solution is too large to be accepted:";
      s80_dummy = p80_repy(regi,'objval') - p80_repyLastOptim(regi,'objval');
      display s80_dummy;
    );
  );
); !! loop over regi

*' criterion: are the anticipation terms sufficienctly small? (only for checking, not applied anymore)
p80_fadeoutPriceAnticip_iter(iteration) = sm_fadeoutPriceAnticip;
if(sm_fadeoutPriceAnticip > cm_maxFadeOutPriceAnticip, 
  !! s80_bool = 0; !! not an active convergence criterion anymore 
  p80_messageShow("anticip") = YES;
);

*' criterion "Deviation due to price anticipation": are the resulting deviations sufficiently small?
*** compare to 1/10th of the cutoff for goods imbalance 
if(p80_DevPriceAnticipGlobAllMax2100Iter(iteration) > 0.1 * p80_surplusMaxTolerance("good"),
  s80_bool = 0;                
  p80_messageShow("DevPriceAnticip") = YES;
);

*' criterion "Did REMIND run sufficient iterations": currently set at 18, to allow for at least 4 iterations with EDGE-T
if(iteration.val <= 17,
  s80_bool = 0;                
  p80_messageShow("IterationNumber") = YES;
);

*' additional criterion: did taxes converge? (only checked if cm_TaxConvCheck is 1)
p80_convNashTaxrev_iter(iteration,t,regi) = 0;
loop(regi,
  loop(t,
    p80_convNashTaxrev_iter(iteration,t,regi) = vm_taxrev.l(t,regi) / vm_cesIO.l(t,regi,"inco");
    if (cm_TaxConvCheck = 1,
      if(abs(p80_convNashTaxrev_iter(iteration,t,regi)) > 0.001,
        s80_bool = 0;
        p80_messageShow("taxconv") = YES;
      );
    );
  );
);

*' additional criterion: Were regional climate targets reached? 
$ifthen.emiMkt not "%cm_emiMktTarget%" == "off" 
loop((ttot,ttot2,ext_regi,emiMktExt) $ pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt),
  if(not(pm_allTargetsConverged(ext_regi) = 1),
    s80_bool = 0;
    p80_messageShow("regiTarget") = YES;
  );
);
$endif.emiMkt

*' additional criterion: Were the quantity targets reached by implicit taxes and/or subsidies? 
$ifthen.cm_implicitQttyTarget not "%cm_implicitQttyTarget%" == "off"
p80_implicitQttyTarget_dev_iter(iteration,ttot,ext_regi,qttyTarget,qttyTargetGroup) = pm_implicitQttyTarget_dev(ttot,ext_regi,qttyTarget,qttyTargetGroup);
loop((ttot,ext_regi,taxType,targetType,qttyTarget,qttyTargetGroup) $ pm_implicitQttyTarget(ttot,ext_regi,taxType,targetType,qttyTarget,qttyTargetGroup),
  if(abs(p80_implicitQttyTarget_dev_iter(iteration,ttot,ext_regi,qttyTarget,qttyTargetGroup)) > cm_implicitQttyTarget_tolerance,
    if(not ((sameas(taxType,"tax") and p80_implicitQttyTarget_dev_iter(iteration,ttot,ext_regi,qttyTarget,qttyTargetGroup) < 0) 
        or  (sameas(taxType,"sub") and p80_implicitQttyTarget_dev_iter(iteration,ttot,ext_regi,qttyTarget,qttyTargetGroup) > 0)),
      if(not(pm_implicitQttyTarget_isLimited(iteration,ttot,ext_regi,qttyTarget,qttyTargetGroup) = 1), !! no tax update either by reaching target or due to tax changes not affecting quantities  
        s80_bool = 0;
        p80_messageShow("implicitEnergyTarget") = YES;
      );
    );
  );
);
$endif.cm_implicitQttyTarget

*' additional criterion: Were FE price targets reached by implicit taxes and/or subsidies?
$ifthen.cm_implicitPriceTarget not "%cm_implicitPriceTarget%" == "off"
loop((t,regi,entyFe,entySe,sector) $ pm_implicitPriceTarget(t,regi,entyFe,entySe,sector),
  if((pm_implicitPrice_NotConv(regi,sector,entyFe,entySe,t)), 
    s80_bool = 0;
    p80_messageShow("cm_implicitPriceTarget") = YES;
  );
);  
$endIf.cm_implicitPriceTarget

*' additional criterion: Were PE price targets reached by implicit taxes and/or subsidies?
$ifthen.cm_implicitPePriceTarget not "%cm_implicitPePriceTarget%" == "off"
loop((t,regi,entyPe) $ pm_implicitPePriceTarget(t,regi,entyPe),
  if((pm_implicitPePrice_NotConv(regi,entyPe,t)), 
    s80_bool = 0;
    p80_messageShow("cm_implicitPePriceTarget") = YES;
  );
);  
$endIf.cm_implicitPePriceTarget

*' additional criterion: global budget target from core/postsolve must be within 2 Gt of target value
p80_globalBudget_absDev_iter(iteration) = sm_globalBudget_absDev;
if (abs(p80_globalBudget_absDev_iter(iteration)) > cm_budgetCO2_absDevTol,
  s80_bool = 0;
  p80_messageShow("target") = YES;
);

*' additional criterion: if damage internalization is on, is damage iteration converged?
p80_sccConvergenceMaxDeviation_iter(iteration) = pm_sccConvergenceMaxDeviation;
p80_gmt_conv_iter(iteration) = pm_gmt_conv;
$ifthen.internalizeDamages not "%internalizeDamages%" == "off"
  if(p80_sccConvergenceMaxDeviation_iter(iteration) > cm_sccConvergence or p80_gmt_conv_iter(iteration) > cm_tempConvergence,
    s80_bool = 0;
    p80_messageShow("damage") = YES;
  );
$endIf.internalizeDamages


***------------------------------------------------------------------------------
*' #### Display convergence diagnostics in full.lst
***------------------------------------------------------------------------------

display "####";
display "Convergence diagnostics";
display "Iteration number: ";
o_iterationNumber = iteration.val;
display o_iterationNumber;
option decimals = 3;

display "In the following you find some diagnostics on whether the model converged in this iteration: ";   

display "solvestat and modelstat parameters: ";
display p80_repy;

display "trade convergence indicators";
display p80_surplusMaxTolerance, p80_surplusMax2100;
display p80_defic_trade, p80_defic_sum,p80_defic_sum_rel;

display "Reasons for non-convergence in this iteration (if not yet converged)";

	 loop(convMessage80$(p80_messageShow(convMessage80)),
	      if(sameas(convMessage80, "infes"),
          display "#### 1.) Infeasibilities found in at least some regions in the last iteration. Please check parameter p80_repy for details. ";
		      display "#### Try a different gdx, or re-run the optimization with cm_nash_mode set to debug in order to debug the infes.";
        );
        if(sameas(convMessage80, "surplus"),
	        display "#### 2.) Some markets failed to reach a residual surplus below the prescribed threshold. ";
	        display "#### In the following, the offending markets are indicated by a 1:";
	        OPTION decimals = 0;
          display p80_messageFailedMarket;
	        OPTION decimals = 3;
          display "#### You will find detailed trade convergence indicators below, search for p80_defic_trade";
        );	   
        if(sameas(convMessage80, "nonopt"),
    		  display "#### 3.) Found a feasible, but non-optimal solution. This is the infamous status-7 problem: ";
		      display "#### We can't accept this solution, because it is non-optimal, and, in addition, too far away from the last known optimal solution. ";
		      display "#### Just trying a different gdx may help.";
	      );	 
	      if(sameas(convMessage80, "taxconv"),
		      display "#### 4.) Taxes did not converge in all regions and time steps. Absolute level of tax revenue must be smaller than 0.1 percent of GDP. Check p80_convNashTaxrev_iter below.";
	      );
        if(sameas(convMessage80, "DevPriceAnticip"),
		      display "#### 5.) The total monetary value of the price anticipation term times the traded amount are larger than the goods imbalance threshold * 0.1";
          display "#### Check out p80_DevPriceAnticipGlobAllMax2100Iter, which needs to be below 0.1 * the threshold for goods imbalance, p80_surplusMaxTolerance";
	      );
        if(sameas(convMessage80, "anticip"),
		      display "#### 5b.) only for checking, not anymore a criterion that stops convergence: The fadeout price anticipation terms are not sufficiently small.";
          display "#### Check out sm_fadeoutPriceAnticip which needs to be below cm_maxFadeOutPriceAnticip.";
          display sm_fadeoutPriceAnticip, cm_maxFadeOutPriceAnticip;
	      );
        if(sameas(convMessage80, "target"),
		      display "#### 6.) A global climate target has not been reached yet.";
          display "#### check sm_globalBudget_absDev for the deviation from the global target CO2 budget (convergence criterion defined via cm_budgetCO2_absDevTol [default = 2 Gt CO2]), as well as";
          display "#### pm_taxCO2eq_iter (regional CO2 tax path tracked over iterations [T$/GtC]) and"; 
          display "#### pm_taxCO2eq_anchor_iterationdiff (difference in global anchor carbon price to the last iteration [T$/GtC]) in diagnostics section below."; 
          display sm_globalBudget_absDev;
	      );
        if(sameas(convMessage80, "IterationNumber"),
          display "#### 0.) REMIND did not run sufficient iterations (currently set at 18, to allow for at least 4 iterations with EDGE-T)";
        );
$ifthen.emiMkt not "%cm_emiMktTarget%" == "off"       
        if(sameas(convMessage80, "regiTarget"),
		      display "#### 7) A regional climate target has not been reached yet.";
          display "#### Check out the pm_emiMktTarget_dev parameter of 47_regipol module.";
          display "#### For budget targets, the parameter gives the percentage deviation of current emissions in relation to the target value.";
          display "#### For yearly targets, the parameter gives the current emissions minus the target value in relative terms to the 2005 emissions.";
          display "#### The deviation must to be less than pm_emiMktTarget_tolerance. By default within 1%, i.e. in between -0.01 and 0.01 of 2005 emissions to reach convergence.";
          display pm_emiMktTarget_tolerance, pm_emiMktTarget_dev, pm_factorRescaleemiMktCO2Tax, pm_emiMktCurrent, pm_emiMktTarget, pm_emiMktRefYear;
          display pm_emiMktTarget_dev_iter;
          display pm_taxemiMkt_iteration;
	      );
$endif.emiMkt  
$ifthen.cm_implicitQttyTarget not "%cm_implicitQttyTarget%" == "off"    
        if(sameas(convMessage80, "implicitEnergyTarget"),
		      display "#### 10) A quantity target has not been reached yet.";
          display "#### Check out the pm_implicitQttyTarget_dev parameter of 47_regipol module.";
          display "#### The relative deviation must to be less than cm_implicitQttyTarget_tolerance, which is 1 percent by default.";
          display "#### For taxes, this means every value > +0.01, while for subsidies everything < -0.01 is problematic in the following lines.";
          display cm_implicitQttyTarget_tolerance, pm_implicitQttyTarget_dev;
	      );
$endif.cm_implicitQttyTarget
$ifthen.cm_implicitPriceTarget not "%cm_implicitPriceTarget%" == "off"
        if(sameas(convMessage80, "cm_implicitPriceTarget"),
		      display "#### 11) A price target has not been reached yet.";
          display "#### Check out below the pm_implicitPrice_NotConv parameter values for non convergence cases.";
          display "####     Deviations must be lower than 5%.";
          display "#### The pm_implicitPrice_ignConv stores the cases disconsidered in the convergence check.";
          display pm_implicitPrice_NotConv, pm_implicitPrice_ignConv;
	      );
$endIf.cm_implicitPriceTarget
$ifthen.cm_implicitPePriceTarget not "%cm_implicitPePriceTarget%" == "off"
        if(sameas(convMessage80, "cm_implicitPePriceTarget"),
		      display "#### 11) A primary energy price target has not been reached yet.";
          display "#### Check out below the pm_implicitPePrice_NotConv parameter values for non convergence cases.";
          display "####     Deviations must be lower than 5%.";
          display "#### The pm_implicitPePrice_ignConv stores the cases disconsidered in the convergence check.";
          display pm_implicitPePrice_NotConv, pm_implicitPePrice_ignConv;
	      );
$endIf.cm_implicitPePriceTarget
$ifthen.internalizeDamages not "%internalizeDamages%" == "off"
	if(sameas(convMessage80,"damage"),
	   display "#### 11) The damage iteration did not converge.";
	   display "#### Check out below the values for pm_gmt_conv and pm_sccConvergenceMaxDeviation."
 	   display "#### They should be below 0.05."
	   display pm_gmt_conv, pm_sccConvergenceMaxDeviation;
	);
$endIf.internalizeDamages
   );

display "See the indicators below to dig deeper on the respective reasons of non-convergence: "

display "tax convergence indicators";
display p80_convNashTaxrev_iter;

display "detailed trade convergence indicators";
display p80_defic_trade, p80_defic_sum,p80_defic_sum_rel;
OPTION decimals = 7;
display p80_surplus;
OPTION decimals = 3;

display "Carbon tax tracked over iterations of 45_carbonprice/functionalForm/postsolve";
display pm_taxCO2eq_iter;

display "Carbon tax difference to last iteration for global targets of 45_carbonprice/functionalForm/postsolve";
display pm_taxCO2eq_anchor_iterationdiff;


*RP* display effect of additional convergence push
display "display effect of additional convergence push";
display  o80_trackSurplusSign, o80_SurplusOverTolerance, o80_counter_iteration_trade_ttot, p80_etaST_correct_safecopy,p80_etaST_correct,p80_pvp_itr;



***end with failure message if max number of iterations is reached w/o convergence:
if( (s80_bool = 0) and (iteration.val = cm_iteration_max),     !! reached max number of iteration, still no convergence
     OPTION decimals = 3;
     display "################################################################################################";
     display "####################################  Nash Solution Report  ####################################";
     display "################################################################################################";
     display "####  !! Nash did not converge within the maximum number of iterations allowed !!"
	 display "#### The reasons for failing to successfully converge are:"
	 loop(convMessage80$(p80_messageShow(convMessage80)),
	     if(sameas(convMessage80, "infes"),
		 display "####";
		 display "#### 1.) Infeasibilities found in at least some regions in the last iteration. Plase check parameter p80_repy for details. ";
		 display "#### Try a different gdx, or re-run the optimization with cm_nash_mode set to debug in order to debug the infes.";
		 display p80_repy;
	     );	 
	     if(sameas(convMessage80 , "surplus"),
	       display "####";
	       display "#### 2.) Some markets failed to reach a residual surplus below the prescribed threshold. ";
	       display "#### You may try less stringent convergence target (a lower cm_nash_autoconverge), or a different gdx. ";
	       display "#### In the following, the offending markets are indicated by a 1:";
	       OPTION decimals = 0;
               display p80_messageFailedMarket;
	       OPTION decimals = 3;	       
	      );
	     if(sameas(convMessage80, "nonopt"),
		 display "####";
		 display "#### 3.) Found a feasible, but non-optimal solution. This is the infamous status-7 problem: ";
		 display "#### We can't accept this solution, because it is non-optimal, and too far away from the last known optimal solution. ";
		 display "#### Just trying a different gdx may help.";
	     );	 
	     if(sameas(convMessage80, "taxconv"),
		 display "####";
		 display "#### 4.) Taxes did not converge in all regions and time steps. Absolut level of tax revenue must be smaller than 0.1 percent of GDP. Check p80_convNashTaxrev_iter.";
	     );	
      if(sameas(convMessage80, "anticip"),
		      display "#### 5.) The fadeout price anticipation terms are not sufficiently small.";
	     );
        if(sameas(convMessage80, "target"),
		      display "#### 6.) A global climate target has not been reached yet.";
          display "#### check sm_globalBudget_absDev for the deviation from the global target CO2 budget (convergence criterion defined via cm_budgetCO2_absDevTol [default = 2 Gt CO2]), as well as";
          display "#### pm_taxCO2eq_iter (regional CO2 tax path tracked over iterations [T$/GtC]) and"; 
          display "#### pm_taxCO2eq_anchor_iterationdiff (difference in global anchor carbon price to the last iteration [T$/GtC]) in diagnostics section below."; 
          display sm_globalBudget_absDev;
	      );
$ifthen.emiMkt not "%cm_emiMktTarget%" == "off"       
        if(sameas(convMessage80, "regiTarget"),
		      display "#### 7) A regional climate target has not been reached yet.";
          display "#### Check out the pm_emiMktTarget_dev parameter of 47_regipol module.";
          display "#### For budget targets, the parameter gives the percentage deviation of current emissions in relation to the target value.";
          display "#### For yearly targets, the parameter gives the current emissions minus the target value in relative terms to the 2005 emissions.";
          display "#### The deviation must to be less than pm_emiMktTarget_tolerance. By default within 1%, i.e. in between -0.01 and 0.01 of 2005 emissions to reach convergence.";
          display pm_emiMktTarget_tolerance, pm_emiMktTarget_dev, pm_factorRescaleemiMktCO2Tax, pm_emiMktCurrent, pm_emiMktTarget, pm_emiMktRefYear;
          display pm_emiMktTarget_dev_iter;
          display pm_taxemiMkt_iteration;
	      );
$endif.emiMkt
$ifthen.cm_implicitQttyTarget not "%cm_implicitQttyTarget%" == "off"    
        if(sameas(convMessage80, "implicitEnergyTarget"),
		      display "#### 10) A quantity target has not been reached yet.";
          display "#### Check out the pm_implicitQttyTarget_dev parameter of 47_regipol module.";
          display "#### The deviation must to be less than cm_implicitQttyTarget_tolerance. By default within 1%, i.e. in between -0.01 and 0.01 of the defined target.";
          display cm_implicitQttyTarget_tolerance, pm_implicitQttyTarget_dev;
	      );
$endif.cm_implicitQttyTarget
$ifthen.cm_implicitPriceTarget not "%cm_implicitPriceTarget%" == "off"
        if(sameas(convMessage80, "cm_implicitPriceTarget"),
		      display "#### 11) A final energy price target has not been reached yet.";
          display "#### Check out below the pm_implicitPrice_NotConv parameter values for non convergence cases.";
          display "####     Deviations must be lower than 5%.";
          display "#### The pm_implicitPrice_ignConv stores the cases disconsidered in the convergence check.";
          display pm_implicitPrice_NotConv, pm_implicitPrice_ignConv;
	      );
$endIf.cm_implicitPriceTarget
$ifthen.cm_implicitPePriceTarget not "%cm_implicitPePriceTarget%" == "off"
        if(sameas(convMessage80, "cm_implicitPePriceTarget"),
		      display "#### 11) A primary energy price target has not been reached yet.";
          display "#### Check out below the pm_implicitPePrice_NotConv parameter values for non convergence cases.";
          display "####     Deviations must be lower than 5%.";
          display "#### The pm_implicitPePrice_ignConv stores the cases disconsidered in the convergence check.";
          display pm_implicitPePrice_NotConv, pm_implicitPePrice_ignConv;
	      );
$endIf.cm_implicitPePriceTarget
	 );
	 display "#### Info: These residual market surplusses in current monetary values are:";
	 display  p80_defic_trade;
	 display "#### The sum of those, normalized to the total consumption, given in percent is: ";
	 display  p80_defic_sum_rel;

     display "################################################################################################";
     display "################################################################################################";

);


***------------------------------------------------------------------------------
*' #### Finishing or aborting
***------------------------------------------------------------------------------

***if all conditions are met, stop optimization.
if(s80_bool = 1,
***in automatic mode, set iteration_max such that no next iteration takes place 
     if(cm_nash_autoconverge ne 0,
      cm_iteration_max = iteration.val - 1;
        );
     OPTION decimals = 3;
     s80_numberIterations = cm_iteration_max + 1;
     display "######################################################################################################";
     display "Run converged!!";
     display "#### Nash Solution Report";
     display "#### Convergence threshold reached within ",s80_numberIterations, "iterations.";
     display "############";
     display "Model solution parameters of last iteration";
     display p80_repy;
     display "#### Residual market surpluses in 2100 are:";
     display  p80_surplusMax2100;
     display "#### This meets the prescribed tolerance requirements of: ";
     display  p80_surplusMaxTolerance;
     display "#### Info: These residual market surplusses in monetary are :";
     display  p80_defic_trade;
     display "#### Info: And the sum of those (equivalent to Negishi's defic_sum):";
     display  p80_defic_sum;
     display "#### This value in percent of the NPV of consumption is: ";
     display  p80_defic_sum_rel;
     display "############";
     display "######################################################################################################";
     OPTION decimals = 3;
     s80_converged = 1;         !! set machine-readable status parameter

);

*** check if any region has failed to solve consecutively for cm_abortOnConsecFail times
if (cm_abortOnConsecFail > 0,
  loop (regi,
    if (   (p80_repy_iteration(regi,"solvestat",iteration) = 1 and p80_repy_iteration(regi,"modelstat",iteration) = 2)
        or (p80_repy_iteration(regi,"solvestat",iteration) = 4 and p80_repy_iteration(regi,"modelstat",iteration) = 7),
      !! region was solved successfully
      p80_trackConsecFail(regi) = 0;
    else !! region failed to solve
      p80_trackConsecFail(regi) = p80_trackConsecFail(regi) + 1;
    );
  );

  if (smax(regi, p80_trackConsecFail(regi)) >= cm_abortOnConsecFail,
    if ((s80_runInDebug = 0) and (cm_nash_mode ne 1), !! auto-start debug only if not already in debug mode
      if (sum(regi, pm_SolNonInfes(regi) ne 0) = 0, !! if all regions are infeasible debug makes no sense
        execute_unload "abort.gdx";
        abort "Run was aborted because the maximum number of consecutive failures was reached in at least one region! No debug started since all regions are infeasible.";
      else !! start debug mode only if at leat one region was feasible
        s80_runInDebug = 1;
        cm_nash_mode = 1;
        display "Starting nash in debug mode after maximum number of consecutive failures was reached in at least one region.";
      );
    else !! s80_runInDebug = 1 and/or cm_nash_mode = 1
      execute_unload "abort.gdx";
      abort "After debug mode run was aborted because the maximum number of consecutive failures was still reached in at least one region!";
    );
  else
  !! Set nash mode back to parallel because all regions got feasible after they have been automatically restarted as debug
    if (s80_runInDebug = 1,
      s80_runInDebug = 0;
      cm_nash_mode = 2;
      display "Set nash mode back to parallel after regions got feasible in auto-debug mode.";
    );
  );
);


***------------------------------------------------------------------------------
*' #### EMIOPT nash algorithm implementation
***------------------------------------------------------------------------------
$ifthen.emiopt %emicapregi% == 'none' 
if(cm_emiscen = 6, !! budget
*** we iteratively reach the point where these two marginals are equal for each region by adjusting regional permit budgets:
*** marginal of cumulative emissions:
p80_eoMargEmiCum(regi) = 5*(abs(qm_co2eqCum.m(regi))) $ (pm_SolNonInfes(regi) = 1);
*** marginal of permit budget :
p80_eoMargPermBudg(regi) = 5*(abs(q80_budgetPermRestr.m(regi))) $ (pm_SolNonInfes(regi) = 1);

display pm_budgetCO2eq;

*** weighting factors to be used in finding efficient permit allocation 
loop(regi,
    p80_eoWeights(regi) = 1/max(abs(qm_budget.m("2050",regi)),1E-9);
);
***normalize sum to unity
p80_eoWeights(regi) = p80_eoWeights(regi) / sum(regi2, p80_eoWeights(regi2) );



p80_eoEmiMarg(regi) = p80_eoWeights(regi) * (p80_eoMargPermBudg(regi) + p80_eoMargEmiCum(regi));
p80_count=0;
*** rename, it becomes confusing otherwise 
p80_count = smax(regi, p80_eoEmiMarg(regi));
loop(regi,
*** dealing with infeasibles
  if ((pm_SolNonInfes(regi) = 0),
      p80_eoEmiMarg(regi) = p80_count;
  else p80_eoEmiMarg(regi) = p80_eoEmiMarg(regi);
  );
);

p80_eoMargAverage = sum(regi, p80_eoEmiMarg(regi))/card(regi);
*** dealing with non-optimals
loop(regi,
  if (((p80_SolNonOpt(regi)=1) and (p80_eoMargEmiCum(regi)=EPS) and (p80_eoMargPermBudg(regi)=EPS)),
     p80_eoEmiMarg(regi)=p80_eoMargAverage
  );
);  
p80_eoMargAverage = sum(regi, p80_eoEmiMarg(regi))/card(regi);
p80_eoMargDiff(regi) = iteration.val**0.8  * 10 *(p80_eoEmiMarg(regi) - p80_eoMargAverage);  

p80_eoDeltaEmibudget = min(50, sum(regi2,  pm_budgetCO2eq(regi2) * abs(p80_eoMargDiff(regi2))));
pm_budgetCO2eq(regi) = max(0, pm_budgetCO2eq(regi) + p80_eoMargDiff(regi) * p80_eoDeltaEmibudget);

***just reporting:
p80_eoEmibudget1RegItr(regi,iteration) = pm_budgetCO2eq(regi);
p80_eoMargDiffItr(regi,iteration)  = p80_eoMargDiff(regi);

p80_eoEmibudgetDiffAbs(iteration) = sum(regi, abs(p80_eoMargDiff(regi) * p80_eoDeltaEmibudget) );
    
option decimals = 5;    
display p80_eoMargEmiCum, p80_eoMargPermBudg, p80_eoEmiMarg, p80_eoMargAverage, p80_eoMargDiff, p80_eoDeltaEmibudget, p80_eoWeights,p80_eoEmibudget1RegItr
;

);
$endif.emiopt

*** EOF ./modules/80_optimization/nash/postsolve.gms
