*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/nash/datainput.gms


*** convergence with trade surplus thresholds
if(cm_nash_autoconverge > 0,
  cm_iteration_max = 100; !! set max number of iterations

*** default values (cm_nash_autoconverge = 1)
  p80_surplusMaxTolerance(tradePe) = 1.5 * sm_EJ_2_TWa;   !! 1.5 EJ/yr, converted into internal unit TWa
  p80_surplusMaxTolerance("good") = 0.1;                  !! 0.1 trillion Dollar
  p80_surplusMaxTolerance("perm") = 300 * sm_MtCO2_2_GtC; !! 300 MtCO2eq, converted into internal unit GtC

  loop(trade $ (tradePe(trade) or tradeMacro(trade)),
*** fine convergence thresholds (cm_nash_autoconverge = 2)
    p80_surplusMaxTolerance(trade) $ (cm_nash_autoconverge = 2) = 0.2 * p80_surplusMaxTolerance(trade);
*** coarse convergence thresholds (cm_nash_autoconverge = 3)
    p80_surplusMaxTolerance(trade) $ (cm_nash_autoconverge = 3) = 2 * p80_surplusMaxTolerance(trade);
  );
);

*** --------------- Technical parameters for Nash price algorithm ---------------

*** Nash adjustment costs (default value around 150).
*** Multiplicator to penalise trade patterns deviations from the last iteration. Involves a trade-off:
*** - when too low, markets are unstable across iterations and cannot clear
*** - when too high, changes in trade patten over iterations are very slow and convergence takes longer
p80_tradeAdj(tradePe) = 80; 
p80_tradeAdj("good") = 100;
p80_tradeAdj("perm") = 10;

*** Multiplicator to price anticipation
p80_priceAnticipStrength(tradePe) = 0.1;
p80_priceAnticipStrength("good") = 0.1;
p80_priceAnticipStrength("perm") = 0.2;


*** Price adjustment factor across iterations (value between zero and one). These parameters are sensitive:
*** - when too low, market surplus may diverge
*** - when too high, market surplus may oscillate

*** short term price ajustment elasticity
p80_shortTermFac(tradePe) = 0.3;
p80_shortTermFac("pebiolc") = 0.8; !! AJS: bio market seems to like this
p80_shortTermFac("peur") = 0.2; !! uranium market is more sensitive, so choose lower etaST
p80_shortTermFac("good") = 0.25;
p80_shortTermFac("perm") = 0.3;
$ifi %banking% == "banking"  p80_shortTermFac("perm") = 0.2;    !! in banking mode, the permit market reacts more sensitively.
$ifi %emicapregi% == "budget"  p80_shortTermFac("perm") = 0.25; !! in budget mode, the permit market reacts more sensitively.

*** long term price ajustment elasticity
p80_longTermFac(trade) = 0;
p80_longTermFac("perm") = 0.03;


*** --------------- Initialise convergence process parameters ---------------
s80_converged = 0;

s80_fadeoutPriceAnticipStartingPeriod = 0;
sm_fadeoutPriceAnticip = 1;

*** Negishi weights, not used in Nash
pm_w(regi) = 1;

*** parameter for spillover externality (aggregated productivity level)
pm_cumEff(t, regi, in) = 100;

*** auxiliary parameter to track how long the surplus for an item (ttot, trade) had the same sign over iterations
o80_trackSurplusSign(ttot,trade,iteration) $ (not tradeSe(trade)) = 0;

*** AJS: need to set (any) values for the following variables/parameters so that GAMS imports them from the gdx
pm_pvp(ttot,trade)$(ttot.val ge 2005) = NA;
p80_pvpFallback(ttot,trade)$(ttot.val ge 2005) = NA;
pm_Xport0(ttot,regi,trade)$(ttot.val ge 2005) = NA;
p80_Mport0(ttot,regi,trade)$(ttot.val ge 2005) = NA;
vm_Xport.l(ttot,regi,trade)$(ttot.val ge 2005) = NA;
vm_Mport.l(ttot,regi,trade)$(ttot.val ge 2005) = NA;
vm_cons.l(ttot,regi)$(ttot.val ge 2005) = 0;
vm_emiTe.l(ttot,regi,"CO2")$(ttot.val ge 2005) = NA;  
vm_fuExtr.l(ttot,regi,tradePe,rlf)$(ttot.val ge 2005) = 0;
vm_prodPe.l(ttot,regi,tradePe)$(ttot.val ge 2005) = 0;    
vm_taxrev.l(ttot,regi)$(ttot.val gt 2005) = 0;
vm_co2eq.l(ttot,regi) = 0;
vm_emiAll.l(ttot,regi,enty) = 0;
p80_repy(all_regi,solveinfo80) = 0;
p80_repy_iteration(all_regi,solveinfo80,iteration) = 0;
p80_repy_nashitr_solitr(all_regi,solveinfo80,iteration,sol_itr) = 0;
pm_capCumForeign(ttot,regi,teLearn)$(ttot.val ge 2005)=0;
qm_co2eqCum.m(regi) = 0;
q80_budgetPermRestr.m(regi) = 0;

*** read in price paths as fallback option
*** p80_pvpFallback(ttot,trade) = 0;
$include "./modules/80_optimization/nash/input/prices_NASH.inc";

*** --------------- Emissions initialisation ---------------
*** emissions, which are part of the climate policy, of other regions (nash relevant)
*** MLB 20140109: initialisation of climate externality is sensitive
*** may be overwritten in nash/presolve
pm_co2eqForeign(t, regi) = (1 - pm_shPerm(t,regi)) * pm_emicapglob(t); !! (1 - emission permit shares) * global emission cap

$ifthen.emiopt %emicapregi% == "none"
if (cm_emiscen = 6, !! budget
  p80_eoMargEmiCum(regi) = 0;
  p80_eoMargPermBudg(regi) = 0;
*** ML 20150609: initialisation of permit budget shares (emiopt version, no permit trade), convergence sensitive to initial allocation
*** ML 20161808: If you change pm_shPerm, ensure that sum(regi, pm_shPerm) = 1; otherwise, a mismatch between global 
*** and regional budgets will likely disturb results in runs with iterative adjustment
  pm_shPerm("2050",regi) = pm_pop("2050",regi) / sum(regi2, pm_pop("2050",regi2));  
);
$endif.emiopt
*** EOF ./modules/80_optimization/nash/datainput.gms
