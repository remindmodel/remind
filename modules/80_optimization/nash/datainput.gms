*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/nash/datainput.gms
pm_w(regi) = 1;

*MLB 20130920* initialization only
pm_cumEff(t, regi, in) = 100;

*MLB 20140109* initialization of climate externality is sensitive
pm_co2eqForeign(t, regi) = (1 - pm_shPerm(t,regi)) * pm_emicapglob(t);

***convergence mode
if(cm_nash_autoconverge gt 0,

*** set max number of iterations
cm_iteration_max = 100;

 if(cm_nash_autoconverge eq 1,
***convergences thresholds - coarse 
  p80_surplusMaxTolerance(tradePe) = 1.5 * sm_EJ_2_TWa;          !! convert EJ/yr into internal unit TWa
  p80_surplusMaxTolerance("good") = 100/1000;                  !! in internal unit, trillion Dollar
  p80_surplusMaxTolerance("perm") = 300 * 12/44 / 1000;                !! convert MtCO2eq into internal unit GtC
   );
 if(cm_nash_autoconverge eq 2,
***convergences thresholds - fine 
  p80_surplusMaxTolerance(tradePe) = 0.3 * sm_EJ_2_TWa;          !! convert EJ/yr into internal unit TWa
  p80_surplusMaxTolerance("good") = 20/1000;                  !! in internal unit, trillion Dollar
  p80_surplusMaxTolerance("perm") = 70 * 12/44 / 1000 ;                !! convert MtCO2eq into internal unit GtC
   );
);
    

*Nash adjustment costs. Involves a trade-off: If set too low, markets jump far away from clearance. Set too high, changes in trade patten over iterations are very slow, convergence takes many many iterations. Default value around 150
p80_etaAdj(tradePe) = 80; 
p80_etaAdj("good") = 100;
p80_etaAdj("perm") = 10;

*LB* parameter for nash price algorithm within the optimization. 
p80_etaXp(tradePe) = 0.1;
p80_etaXp("good") = 0.1;
p80_etaXp("perm") = 0.2;

*LB* parameter for Nash price algorithm between different iterations
p80_etaLT(trade) = 0;
p80_etaLT("perm") = 0.03;

***These parameters are pretty sensitive. If market surpluses diverge, try higher values (up to 1). If surpluses oscillate, try lower values. 
p80_etaST(tradePe) = 0.3;
p80_etaST("good") = 0.25;
p80_etaST("perm") = 0.3;

$ifi %banking% == "banking"  p80_etaST("perm") = 0.2;      !! in banking mode, the permit market reacts more sensitively.
$ifi %emicapregi% == "budget"  p80_etaST("perm") = 0.25;      !! in budget mode, the permit market reacts more sensitively.

*AJS* bio market seems to like this:
p80_etaST("pebiolc") = 0.8;
***peur market is more sensitive, so choose lower etaST
p80_etaST("peur") = 0.2;

s80_converged = 0;

***initialize some convergence process parameters
s80_fadeoutPriceAnticipStartingPeriod = 0;
sm_fadeoutPriceAnticip = 1;
*AJS*technical stuff. We want GAMS to import values for the following variables/parameters from the gdx, it would not do that unless you set them a (any) value beforehand.
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
pm_capCumForeign(ttot,regi,teLearn)$(ttot.val ge 2005)=0;
qm_co2eqCum.m(regi) = 0;
q80_budgetPermRestr.m(regi) = 0;

***read in price paths as fallback option
***p80_pvpFallback(ttot,trade) = 0;
$include "./modules/80_optimization/nash/input/prices_NASH.inc";

*** read in hard coded weights only to be used if due to infeasibilities internal computation of weights (postsolve) does not work
parameter p80_eoWeights_fix(all_regi)        "hard coded fallback nash weights"
/
$ondelim
$include "./modules/80_optimization/nash/input/p80_eoWeights_fix.cs4r"
$offdelim
/
;

***EMIOPT------------------------------------------------------------------------------
if ( cm_emiscen eq 6,
$ifthen.emiopt %emicapregi% == "none"
*AJS* initialize
  p80_eoMargEmiCum(regi) = 0;
  p80_eoMargPermBudg(regi) = 0;
*** ML 20150609 * initialization of permit budget shares (emiopt version, no permit trade)
*** convergence sensitive to initial allocation
*** ML 20161808 * If you change pm_shPerm, ensure that sum(regi, pm_shPerm) = 1; otherwise, a mismatch between global 
*** and regional budgets will likely disturb results in runs with iterative adjustment
   pm_shPerm("2050",regi) = pm_pop("2050",regi)/ sum(regi2, pm_pop("2050",regi2) );  
$endif.emiopt
);
*** EOF ./modules/80_optimization/nash/datainput.gms
