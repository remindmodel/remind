*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/nash/postsolve.gms


 
*ML*2015-02-04* calculate current account
*LB* needed for decomposition script
p80_curracc(ttot, regi) =  SUM(trade$(NOT tradeSe(trade)), pm_pvp(ttot,trade)/ max(pm_pvp(ttot,"good"),sm_eps) * (vm_Xport.l(ttot,regi,trade)- vm_Mport.l(ttot,regi,trade))  );

p80_taxrev0(ttot,regi)$( (ttot.val ge max(2010,cm_startyear)) and (pm_SolNonInfes(regi) eq 1) ) = vm_taxrev.l(ttot,regi);

*AJS*update normalization paramaters, take values from last iteration for regions that were not solved optimally
p80_normalize0(ttot,regi,"good")$(ttot.val ge 2005) = max(vm_cons.l(ttot,regi)$(pm_SolNonInfes(regi) eq 1) + p80_normalize0(ttot,regi,"good")$(pm_SolNonInfes(regi) eq 0),sm_eps);
*ML*normalize permit trade corrections to consumption or positive cap path instead of emissions, as those may be negative
p80_normalize0(ttot,regi,"perm")$(ttot.val ge 2005) = max(abs(pm_shPerm(ttot,regi) * pm_emicapglob("2050")) , sm_eps);
p80_normalize0(ttot,regi,tradePe)$(ttot.val ge 2005) = max(0.5 * (sum(rlf, vm_fuExtr.l(ttot,regi,tradePe,rlf)) + vm_prodPe.l(ttot,regi,tradePe))$(pm_SolNonInfes(regi) eq 1)
                                                        + p80_normalize0(ttot,regi,tradePe)$(pm_SolNonInfes(regi) eq 0) ,sm_eps);


***calculate residual surplus on the markets
loop(ttot$(ttot.val ge 2005),
  loop(trade$(NOT tradeSe(trade)),
     p80_surplus(ttot,trade,iteration) = sum(regi, (vm_Xport.l(ttot,regi,trade) - vm_Mport.l(ttot,regi,trade))$(pm_SolNonInfes(regi) eq 1)
                                               + (pm_Xport0(ttot,regi,trade) - p80_Mport0(ttot,regi,trade) )$(pm_SolNonInfes(regi) eq 0) );
      ); 
); 

*' calculate both the size of the price change due to the price change anticipation effect in percent, as well as  
*' the deviation of the yearly monetary export/import expenditure due to the price change anticipation effect: 
loop(ttot$(ttot.val ge 2005),
  loop(trade$(NOT tradeSe(trade)),
    loop(regi,
      p80_PriceChangePriceAnticipReg(ttot,trade,regi) = 100 *
        ( sm_fadeoutPriceAnticip*p80_etaXp(trade)
          * ( (pm_Xport0(ttot,regi,trade) - p80_Mport0(ttot,regi,trade)) - (vm_Xport.l(ttot,regi,trade) - vm_Mport.l(ttot,regi,trade))
              - p80_taxrev0(ttot,regi)$(ttot.val gt 2005)$(sameas(trade,"good")) + vm_taxrev.l(ttot,regi)$(ttot.val gt 2005)$(sameas(trade,"good"))
            )
          / (p80_normalize0(ttot,regi,trade) + sm_eps)
        )
      ;

      p80_DevPriceAnticipReg(ttot,trade,regi) = 
        ( vm_Xport.l(ttot,regi,trade) - vm_Mport.l(ttot,regi,trade) ) 
        * pm_pvp(ttot,trade) / pm_pvp(ttot,"good")
        * p80_PriceChangePriceAnticipReg(ttot,trade,regi)
      ;
    );
  p80_DevPriceAnticipGlob(ttot,trade) = sum(regi, abs( p80_DevPriceAnticipReg(ttot,trade,regi) ) );  
  );
p80_DevPriceAnticipGlobAll(ttot) = sum(trade$(NOT tradeSe(trade)), p80_DevPriceAnticipGlob(ttot,trade));
);

*' calculate maximum of p80_DevPriceAnticipGlob
p80_DevPriceAnticipGlobMax(ttot,trade)$((ttot.val ge cm_startyear) AND (NOT tradeSe(trade))) = 
  smax(ttot2$(ttot2.val ge cm_startyear AND ttot2.val le ttot.val), p80_DevPriceAnticipGlob(ttot2,trade) )
;
*' calculate maximum of p80_DevPriceAnticipGlobAll
p80_DevPriceAnticipGlobAllMax(ttot)$((ttot.val ge cm_startyear)) = 
  smax(ttot2$(ttot2.val ge cm_startyear AND ttot2.val le ttot.val), p80_DevPriceAnticipGlobAll(ttot2) )
;

p80_DevPriceAnticipGlobIter(ttot,trade,iteration)$((ttot.val ge cm_startyear) AND (NOT tradeSe(trade))) = p80_DevPriceAnticipGlob(ttot,trade);
p80_DevPriceAnticipGlobMax2100Iter(trade,iteration)$(NOT tradeSe(trade)) = p80_DevPriceAnticipGlobMax("2100",trade);
p80_DevPriceAnticipGlobAllMax2100Iter(iteration) = p80_DevPriceAnticipGlobAllMax("2100");


*' For display of price change p80_PriceChangePriceAnticipReg, round to 0.1% 
*o80_PriceChangePriceAnticipReg(ttot,trade,regi) = p80_PriceChangePriceAnticipReg(ttot,trade,regi);
o80_PriceChangePriceAnticipReg(ttot,trade,regi) = round(p80_PriceChangePriceAnticipReg(ttot,trade,regi),1);

*' determine largest price change in p80_PriceChangePriceAnticipReg
o80_PriceChangePriceAnticipRegMaxIter("2100",iteration) = smax( (ttot,trade,regi)$(ttot.val le 2100) , abs(o80_PriceChangePriceAnticipReg(ttot,trade,regi) ) );
o80_PriceChangePriceAnticipRegMaxIter("2150",iteration) = smax( (ttot,trade,regi)$(ttot.val ge 2110) , abs(o80_PriceChangePriceAnticipReg(ttot,trade,regi) ) );

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

***calculate aggregated intertemporal market volumes - used in calculation of price corrections later on  
loop(trade$(NOT tradeSe(trade)),
       p80_normalizeLT(trade) = sum(ttot$(ttot.val ge 2005), sum(regi, pm_pvp(ttot,trade) * pm_ts(ttot) *  p80_normalize0(ttot,regi,trade) ));
     if (p80_normalizeLT(trade) = 0, p80_normalizeLT(trade) = sm_eps);
    );

*LB* calculate price correction terms
p80_etaLT_correct(trade,iteration)$(NOT tradeSe(trade)) = 
          p80_etaLT(trade) *
         sum(ttot2$(ttot2.val ge cm_startyear), pm_pvp(ttot2,trade) * pm_ts(ttot2) * p80_surplus(ttot2,trade,iteration) )
        / p80_normalizeLT(trade);

p80_etaST_correct(ttot,trade,iteration)$((ttot.val ge 2005) AND (NOT tradeSe(trade))) = 
           p80_etaST(trade)    
         * ( (  (1-sm_fadeoutPriceAnticip) + sm_fadeoutPriceAnticip * sqrt(pm_pvp(ttot,"good")/pm_pvp("2100","good"))  )$(sameas(trade,"perm")) + 1$(NOT sameas(trade,"perm")) )    
      * ((sm_fadeoutPriceAnticip + (1-sm_fadeoutPriceAnticip) * (pm_pvp(ttot,"good")/pm_pvp('2040',"good")) )$(sameas(trade,"perm")) + 1$(NOT sameas(trade,"perm")) )
      * ((sm_fadeoutPriceAnticip + (1-sm_fadeoutPriceAnticip) * (pm_pvp(ttot,trade)/pm_pvp('2050',trade)) )$(tradePe(trade)) + 1$(NOT tradePe(trade)) )
         * p80_surplus(ttot,trade,iteration)
         / max(sm_eps , sum(regi, p80_normalize0(ttot,regi,trade)));

*RP* add a stronger push to the price adjustment if convergence doesn't happen for an extended amount of iterations:
p80_etaST_correct_safecopy(ttot,trade,iteration)$(NOT tradeSe(trade)) = p80_etaST_correct(ttot,trade,iteration); !! first make a copy of the initial adjustment values

*RP* track sign of the surplus
if(iteration.val > 2, 
  loop(ttot$(ttot.val ge 2005),
    loop(trade$(tradePe(trade) OR sameas(trade,"good") ),
      if( abs(p80_surplus(ttot,trade,iteration)) gt p80_surplusMaxTolerance(trade),
          o80_SurplusOverTolerance(ttot,trade,iteration) = Sign(p80_surplus(ttot,trade,iteration) );
        );
    );
  );
);

*RP* track continued surplusses with the same sign (to show where convergence is too slow)
if(iteration.val > 2, 
  loop(ttot$(ttot.val ge 2005),
    loop(trade$(tradePe(trade) OR sameas(trade,"good") ),
      if(     ( Sign(p80_surplus(ttot,trade,iteration) ) eq Sign(p80_surplus(ttot,trade,iteration-1) ) )  
          AND ( abs(p80_surplus(ttot,trade,iteration)) gt p80_surplusMaxTolerance(trade) ) ,
        o80_trackSurplusSign(ttot,trade,iteration) = o80_trackSurplusSign(ttot,trade,iteration-1) +1;
      else
        o80_trackSurplusSign(ttot,trade,iteration) = 0;
      );
    );
  );
);

if(iteration.val > 15,
  loop(ttot$(ttot.val ge 2005),
    loop(trade$(tradePe(trade) OR sameas(trade,"good")),
      if( abs(p80_surplus(ttot,trade,iteration)) gt p80_surplusMaxTolerance(trade) , 
        if( ( abs( sum(iteration2$( (iteration2.val le iteration.val) AND (iteration2.val ge (iteration.val - 4))),      
                  p80_surplus(ttot,trade,iteration2)          !! this sum should ensure the additional price adjustment only happens if the surplus was always off the same sign
                )
              ) ge ( 5 * p80_surplusMaxTolerance(trade) ) ) AND ( o80_trackSurplusSign(ttot,trade,iteration) ge 5 ) , !! check if surplus was out of the target range for 5 consecutive iterations
          p80_etaST_correct(ttot,trade,iteration) = 4 * p80_etaST_correct(ttot,trade,iteration);
          o80_counter_iteration_trade_ttot(ttot,trade,iteration) = 1;
          
          if(iteration.val gt 20,      !! only start checking if a stronger push is necessary a few iterations later, so that step 1 could potentially show an effect
            if( ( abs( sum(iteration2$( (iteration2.val le iteration.val) AND (iteration2.val ge (iteration.val - 9))),
                         p80_surplus(ttot,trade,iteration2)
                       )
                  ) ge ( 10 * p80_surplusMaxTolerance(trade)) ) AND ( o80_trackSurplusSign(ttot,trade,iteration) ge 10 ), !! check if surplus was out of the target range for 10 consecutive iterations
              p80_etaST_correct(ttot,trade,iteration) = 2 * p80_etaST_correct(ttot,trade,iteration);
              o80_counter_iteration_trade_ttot(ttot,trade,iteration) = 2;
              
              if(iteration.val gt 25,   !! only start checking if a stronger push is necessary a few iterations later, so that step 1&2 could potentially show an effect
                if( ( abs( sum(iteration2$( (iteration2.val le iteration.val) AND (iteration2.val ge (iteration.val - 14))),
                             p80_surplus(ttot,trade,iteration2)
                           )
                      ) ge ( 15 * p80_surplusMaxTolerance(trade)) ) AND ( o80_trackSurplusSign(ttot,trade,iteration) ge 15 ), !! check if surplus was out of the target range for 15 consecutive iterations
                  p80_etaST_correct(ttot,trade,iteration) = 2 * p80_etaST_correct(ttot,trade,iteration);
                  o80_counter_iteration_trade_ttot(ttot,trade,iteration) = 3;
                );
              );
            );
          );
        );
      );
    ); !! trade
  ); !! ttot
); !! iteration>15


***calculate prices for next iteration 
p80_pvp_itr(ttot,trade,iteration+1)$((ttot.val ge cm_startyear) AND (NOT tradeSe(trade))) = 
 pm_pvp(ttot,trade)
 * max(0.05,                                                  !! prevent prices from turning negative by limiting extreme prices corrections
       (1 - p80_etaLT_correct(trade,iteration)
        - p80_etaST_correct(ttot,trade,iteration)
       )
      )
     ;

*AJS* feed updated prices and quantities into the next iteration:
*ML* adjustments in case of infeasibilities (increase import)
loop(trade$(NOT tradeSe(trade)),
    loop(regi,
    loop(ttot$(ttot.val ge cm_startyear),
        pm_pvp(ttot,trade)  = p80_pvp_itr(ttot,trade,iteration+1);
        pm_Xport0(ttot,regi,trade)$(pm_SolNonInfes(regi) eq 1)  = vm_Xport.l(ttot,regi,trade);
        p80_Mport0(ttot,regi,trade)$(pm_SolNonInfes(regi) eq 1) = vm_Mport.l(ttot,regi,trade);
        p80_Mport0(ttot,regi,trade)$(pm_SolNonInfes(regi) eq 0) = 1.2 * vm_Mport.l(ttot,regi,trade);
    );
    );
);

***some diagnostic output:
p80_taxrev_agg(ttot,iteration)$(ttot.val ge 2005) = sum(regi,vm_taxrev.l(ttot,regi));

*AJS* calculate maximum residual surplusses on markets
p80_surplusMax_iter(trade,iteration,ttot)$((ttot.val ge cm_startyear) AND (NOT tradeSe(trade))) = smax(ttot2$(ttot2.val ge cm_startyear AND ttot2.val le ttot.val), abs(p80_surplus(ttot2,trade,iteration)));

***from this, relative residual surplusses.  
p80_surplusMaxRel(trade,iteration,ttot)$((ttot.val ge cm_startyear) AND (NOT tradeSe(trade))) = 100 * smax(ttot2$(ttot2.val ge cm_startyear AND ttot2.val le ttot.val), abs(p80_surplus(ttot2,trade,iteration)) / sum(regi, p80_normalize0(ttot2,regi,trade)));

p80_surplusMax2100(trade)$(NOT tradeSe(trade)) = p80_surplusMax_iter(trade,iteration,"2100");


***convergence indicators 
loop(trade$(NOT tradeSe(trade)),
    p80_defic_trade(trade) = 1/pm_pvp("2005","good") *
    sum(ttot$(ttot.val ge 2005),   pm_ts(ttot) * (
        abs(p80_surplus(ttot,trade,iteration)) * pm_pvp(ttot,trade)
        + sum(regi, abs(p80_taxrev0(ttot,regi)) * pm_pvp(ttot,"good"))$(sameas(trade,"good") and (ttot.val ge max(2010,cm_startyear)) )  
        + sum(regi, abs(vm_costAdjNash.l(ttot,regi)) * pm_pvp(ttot,"good"))$(sameas(trade,"good") and (ttot.val ge 2005) )  

    )
    );
);
p80_defic_sum("1") = 1;
p80_defic_sum(iteration) = sum(trade$(NOT tradeSe(trade)),  p80_defic_trade(trade)); 
p80_defic_sum_rel(iteration) =  100 * p80_defic_sum(iteration) / (p80_normalizeLT("good")/pm_pvp("2005","good"));


***adjust parameters for next iteration 
***Decide on when to fade out price anticipation terms (doing this too early leads to diverging markets)
***if markets are reasonably cleared
if( (smax(tradePe,p80_surplusMax_iter(tradePe,iteration,'2150')) lt (10 * 0.05))   
    AND ( p80_surplusMax_iter("good",iteration,'2150') lt (10 * 0.1) )            !! 
    AND ( p80_surplusMax_iter("perm",iteration,'2150') lt (5 * 0.2) )
    AND (s80_fadeoutPriceAnticipStartingPeriod eq 0),                  !! as long as we are not fading out already
     s80_fadeoutPriceAnticipStartingPeriod = iteration.val;
);


***if thats the case, then start to fade out anticipation terms - begin second phase
if(s80_fadeoutPriceAnticipStartingPeriod ne 0,
 sm_fadeoutPriceAnticip = 0.7**(iteration.val - s80_fadeoutPriceAnticipStartingPeriod + 1);
);
display s80_fadeoutPriceAnticipStartingPeriod, sm_fadeoutPriceAnticip;

*** Save FE prices in each iteration for easier monitoring
pm_FEPrice_iter(iteration,t,regi,enty,sector,emiMkt) =
  pm_FEPrice(t,regi,enty,sector,emiMkt);


***Decide, on whether to end iterating now. if any of the following criteria (contained in the set convMessage80(surplus,infes,nonopt)) is not met, s80_bool is set to 0, and the convergence process is NOT stopped
***reset some indicators
s80_bool=1;  
p80_messageShow(convMessage80) = NO;   
p80_messageFailedMarket(ttot,all_enty) = NO;

***criterion ""surplus": are we converged yet?
loop(trade$(NOT tradeSe(trade)),
 if(p80_surplusMax_iter(trade,iteration,"2100") gt p80_surplusMaxTolerance(trade),
     s80_bool=0;                 
     p80_messageShow("surplus") = YES;
      loop(ttot$((ttot.val ge cm_startyear) and (ttot.val le 2100)),
       if( (abs(p80_surplus(ttot,trade,iteration)) gt p80_surplusMaxTolerance(trade) ),
       p80_messageFailedMarket(ttot,trade) = YES;
       );
      );
 );
 if(p80_surplusMax_iter(trade,iteration,"2150") gt 10 * p80_surplusMaxTolerance(trade),
     s80_bool=0;
     p80_messageShow("surplus") = YES;
      loop(ttot$((ttot.val ge cm_startyear) and (ttot.val gt 2100)),
       if( (abs(p80_surplus(ttot,trade,iteration)) gt p80_surplusMaxTolerance(trade) ),
          p80_messageFailedMarket(ttot,trade) = YES;
       );
      );
 );
);

*** critertion "infes": is any region neither optimal nor intermediate non-optimal -> then it is infeasible 
loop(regi,
  if( (p80_repy(regi,'modelstat') ne 2) and (p80_repy(regi,'modelstat') ne 7),    !! 2 is optimal, 7 nonopt,            
    s80_bool = 0;
    p80_messageShow("infes") = YES;
  );
*** critertion "nonopt": The next lines are a workaround for the status 7
*** problem. If the objective value does not differ too much from the last known
*** optimal solution, accept this solution as if it were optimal. 
  p80_convNashObjVal_iter(iteration,regi) = p80_repy(regi,'objval') - p80_repyLastOptim(regi,'objval');
  if (1 le iteration.val,
    !! no last iteration if this is the first; NA value in p80_repyLastOptim is
    !! sticky, so test this separately
    if ( p80_repy(regi,'modelstat') eq 7
        !! The 1E-4 are quite arbitrary. One should do more research on how
        !! the solution differs over iteration when status 7 occurs. 
        AND p80_convNashObjVal_iter(iteration,regi) lt - 1e-4,
      s80_bool = 0;
      p80_messageShow("nonopt") = YES;     
      display "Not all regions were status 2 in the last iteration. The deviation of the objective function from the last optimal solution is too large to be accepted:";
      s80_dummy = p80_repy(regi,'objval') - p80_repyLastOptim(regi,'objval');
      display s80_dummy;
    );
  );
); !! loop over regi

*** criterion only for checking, not applied anymore: are the anticipation terms sufficienctly small?
p80_fadeoutPriceAnticip_iter(iteration) = sm_fadeoutPriceAnticip;
if(sm_fadeoutPriceAnticip gt cm_maxFadeOutPriceAnticip, 
***  s80_bool = 0; !! not an active convergence criterion anymore 
  p80_messageShow("anticip") = YES;
);

*' criterion "Deviation due to price anticipation": are the resulting deviations sufficiently small?
*' compare to 1/10th of the cutoff for goods imbalance 
if(p80_DevPriceAnticipGlobAllMax2100Iter(iteration) gt 0.1 * p80_surplusMaxTolerance("good"),
  s80_bool=0;                
  p80_messageShow("DevPriceAnticip") = YES;
);

*' criterion "Did REMIND run sufficient iterations (currently set at 18, to allow for at least 4 iterations with EDGE-T)
if( (iteration.val le 17),
  s80_bool=0;                
  p80_messageShow("IterationNumber") = YES;
);

***additional criterion: did taxes converge? (only checked if cm_TaxConvCheck is 1)
p80_convNashTaxrev_iter(iteration,t,regi) = 0;
loop(regi,
    loop(t,
         p80_convNashTaxrev_iter(iteration,t,regi) = vm_taxrev.l(t,regi) / vm_cesIO.l(t,regi,"inco");
         if (cm_TaxConvCheck eq 1,
             if( abs(p80_convNashTaxrev_iter(iteration,t,regi)) gt 0.001,
                 s80_bool = 0;
                 p80_messageShow("taxconv") = YES;
             );
         );
    );
);

*** additional criterion: Were regional climate targets reached? 
$ifthen.emiMkt not "%cm_emiMktTarget%" == "off" 
loop((ttot,ttot2,ext_regi,emiMktExt)$pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt),
  if(NOT(pm_allTargetsConverged(ext_regi) eq 1),
    s80_bool = 0;
    p80_messageShow("regiTarget") = YES;
  );
);
$endif.emiMkt

*** additional criterion: Were the quantity targets reached by implicit taxes and/or subsidies? 
$ifthen.cm_implicitQttyTarget not "%cm_implicitQttyTarget%" == "off"
p80_implicitQttyTarget_dev_iter(iteration,ttot,ext_regi,qttyTarget,qttyTargetGroup) = pm_implicitQttyTarget_dev(ttot,ext_regi,qttyTarget,qttyTargetGroup);
loop((ttot,ext_regi,taxType,targetType,qttyTarget,qttyTargetGroup)$pm_implicitQttyTarget(ttot,ext_regi,taxType,targetType,qttyTarget,qttyTargetGroup),
  if(abs(p80_implicitQttyTarget_dev_iter(iteration,ttot,ext_regi,qttyTarget,qttyTargetGroup)) gt cm_implicitQttyTarget_tolerance,
    if(NOT ((sameas(taxType,"tax") and p80_implicitQttyTarget_dev_iter(iteration,ttot,ext_regi,qttyTarget,qttyTargetGroup) lt 0) 
        OR  (sameas(taxType,"sub") and p80_implicitQttyTarget_dev_iter(iteration,ttot,ext_regi,qttyTarget,qttyTargetGroup) gt 0)),
      if(NOT(pm_implicitQttyTarget_isLimited(iteration,ttot,ext_regi,qttyTarget,qttyTargetGroup) eq 1), !!no tax update either by reaching target or due to tax changes not affecting quantitties  
        s80_bool = 0;
        p80_messageShow("implicitEnergyTarget") = YES;
      );
    );
  );
);
$endif.cm_implicitQttyTarget

*** additional criterion: Were FE price targets reached by implicit taxes and/or subsidies?
$ifthen.cm_implicitPriceTarget not "%cm_implicitPriceTarget%" == "off"
loop((t,regi,entyFe,entySe,sector)$pm_implicitPriceTarget(t,regi,entyFe,entySe,sector),
  if((pm_implicitPrice_NotConv(regi,sector,entyFe,entySe,t)), 
    s80_bool = 0;
    p80_messageShow("cm_implicitPriceTarget") = YES;
  );
);  
$endIf.cm_implicitPriceTarget

*** additional criterion: Were PE price targets reached by implicit taxes and/or subsidies?
$ifthen.cm_implicitPePriceTarget not "%cm_implicitPePriceTarget%" == "off"
loop((t,regi,entyPe)$pm_implicitPePriceTarget(t,regi,entyPe),
  if((pm_implicitPePrice_NotConv(regi,entyPe,t)), 
    s80_bool = 0;
    p80_messageShow("cm_implicitPePriceTarget") = YES;
  );
);  
$endIf.cm_implicitPePriceTarget

*** check global budget target from core/postsolve, must be within cm_budgetCO2_absDevTol (default 2 Gt) of target value
p80_globalBudget_absDev_iter(iteration) = sm_globalBudget_absDev;
if ( abs(p80_globalBudget_absDev_iter(iteration)) gt cm_budgetCO2_absDevTol , !! check if CO2 budget met in tolerance range,
  s80_bool = 0;
  p80_messageShow("globalbudget") = YES;
);


$ifthen.carbonprice %carbonprice% == "functionalForm"
*** check whether cm_peakBudgYr corresponds to year of maximum cumulative CO2 emissions
if (  (     cm_iterative_target_adj eq 9
        AND cm_peakBudgYr ne sm_peakBudgYr_check  )
  s80_bool = 0;
  p80_messageShow("peakbudgyr") = YES;
);

*** Check whether difference in cumulative emissions between both time steps is greater than sm_peakbudget_diff_tolerance
if (  (   cm_iterative_target_adj eq 9
      AND abs(sm_peakbudget_diff) gt sm_peakbudget_diff_tolerance),
  s80_bool = 0;
  p80_messageShow("peakbudget") = YES;
);
$endIf.carbonprice


*** additional criterion: if damage internalization is on, is damage iteration converged?
p80_sccConvergenceMaxDeviation_iter(iteration) = pm_sccConvergenceMaxDeviation;
p80_gmt_conv_iter(iteration) = pm_gmt_conv;
$ifthen.internalizeDamages not "%internalizeDamages%" == "off"
   if(p80_sccConvergenceMaxDeviation_iter(iteration) gt cm_sccConvergence OR p80_gmt_conv_iter(iteration) gt cm_tempConvergence,
      s80_bool = 0;
      p80_messageShow("damage") = YES;
   );
$endIf.internalizeDamages

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
        if(sameas(convMessage80, "globalbudget"),
		      display "#### 6.) A global climate target has not been reached yet.";
          display "#### check sm_globalBudget_absDev for the deviation from the global target CO2 budget (convergence criterion defined via cm_budgetCO2_absDevTol [default = 2 Gt CO2]), as well as";
          display "#### pm_taxCO2eq_iter (regional CO2 tax path tracked over iterations [T$/GtC]) and"; 
          display "#### pm_taxCO2eq_anchor_iterationdiff (difference in global anchor carbon price to the last iteration [T$/GtC]) in diagnostics section below."; 
          display sm_globalBudget_absDev;
	      );
        if(sameas(convMessage80, "peakbudgyr"),
		      display "#### 6.) Years are different: cm_peakBudgYr is not equal to sm_peakBudgYr_check.";
          display cm_peakBudgYr;
	      );
        if(sameas(convMessage80, "peakbudget"),
		      display "#### 6.) PeakBudget not reached: sm_peakbudget_diff is greater than sm_peakbudget_diff_tolerance.";
          display sm_peakbudget_diff;
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
if( (s80_bool eq 0) and (iteration.val eq cm_iteration_max),     !! reached max number of iteration, still no convergence
     OPTION decimals = 3;
     display "################################################################################################";
     display "####################################  Nash Solution Report  ####################################";
     display "################################################################################################";
     display "####  !! Nash did NOT converge within the maximum number of iterations allowed !!"
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
        if(sameas(convMessage80, "globalbudget"),
		      display "#### 6.) A global climate target has not been reached yet.";
          display "#### check sm_globalBudget_absDev for the deviation from the global target CO2 budget (convergence criterion defined via cm_budgetCO2_absDevTol [default = 2 Gt CO2]), as well as";
          display "#### pm_taxCO2eq_iter (regional CO2 tax path tracked over iterations [T$/GtC]) and"; 
          display "#### pm_taxCO2eq_anchor_iterationdiff (difference in global anchor carbon price to the last iteration [T$/GtC]) in diagnostics section below."; 
          display sm_globalBudget_absDev;
	      );
        if(sameas(convMessage80, "peakbudgyr"),
		      display "#### 6.) Years are different: cm_peakBudgYr is not equal to sm_peakBudgYr_check.";
          display cm_peakBudgYr;
	      );
        if(sameas(convMessage80, "peakbudget"),
		      display "#### 6.) PeakBudget not reached: sm_peakbudget_diff is greater than sm_peakbudget_diff_tolerance.";
          display sm_peakbudget_diff;
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


***if all conditions are met, stop optimization.
if(s80_bool eq 1,
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

*** check if any region has failed to solve consecutively for
*** cm_abortOnConsecFail times
if (cm_abortOnConsecFail gt 0,
  loop (regi,
    if (   (    p80_repy_iteration(regi,"solvestat",iteration) eq 1
            AND p80_repy_iteration(regi,"modelstat",iteration) eq 2)
        OR (    p80_repy_iteration(regi,"solvestat",iteration) eq 4
            AND p80_repy_iteration(regi,"modelstat",iteration) eq 7),
      !! region was solved successfully
      p80_trackConsecFail(regi) = 0;
    else
      !! region failed to solve
      p80_trackConsecFail(regi) = p80_trackConsecFail(regi) + 1;
    );
  );

  if (smax(regi, p80_trackConsecFail(regi)) >= cm_abortOnConsecFail,
    if ((s80_runInDebug eq 0) AND (cm_nash_mode ne 1), !! auto-start debug only if not already in debug mode
      if (sum(regi, pm_SolNonInfes(regi) ne 0) eq 0, !! if all regions are infeasible debug makes no sense
        execute_unload "abort.gdx";
        abort "Run was aborted because the maximum number of consecutive failures was reached in at least one region! No debug started since all regions are infeasible.";
      else !! start debug mode only if at leat one region was feasible
        s80_runInDebug = 1;
        cm_nash_mode = 1;
        display "Starting nash in debug mode after maximum number of consecutive failures was reached in at least one region.";
      );
    else !! s80_runInDebug eq 1 AND/OR cm_nash_mode eq 1
      execute_unload "abort.gdx";
      abort "After debug mode run was aborted because the maximum number of consecutive failures was still reached in at least one region!";
    );
  else
  !! Set nash mode back to parallel because all regions got feasible after they have been automatically restarted as debug
    if (s80_runInDebug eq 1,
      s80_runInDebug = 0;
      cm_nash_mode = 2;
      display "Set nash mode back to parallel after regions got feasible in auto-debug mode.";
    );
  );
);


***--------------------------
***  EMIOPT implementation
***--------------------------
$ifthen.emiopt %emicapregi% == 'none' 
if(cm_emiscen eq 6,

*** nash emiopt algorithm
*** we iteratively reach the point where these two marginals are equal for each region by adjusting regional permit budgets:
*** marginal of cumulative emissions:
p80_eoMargEmiCum(regi) = 5*(abs(qm_co2eqCum.m(regi)))$(pm_SolNonInfes(regi) eq 1);
*** marginal of permit budget :
p80_eoMargPermBudg(regi) = 5*(abs(q80_budgetPermRestr.m(regi)))$(pm_SolNonInfes(regi) eq 1);

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
  if ((pm_SolNonInfes(regi) eq 0),
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
