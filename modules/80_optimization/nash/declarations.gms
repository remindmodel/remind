*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/nash/declarations.gms

parameter
*LB* parameters for ajustments within one iteration. These cause price anticipation
p80_etaXp(all_enty)                         "Parameter governing price anticipation on commodity markets"


*LB* parameters for ajustments between different iterations
p80_etaLT(all_enty)                         "long term price ajustment elasticity "
p80_etaST(all_enty)                         "short term price ajustment elasticity"

*AJS*  adjustment costs between iterations
p80_etaAdj(all_enty)                        "Adjustment costs for changes of trade pattern between iterations"

***prices
p80_pvp_itr(ttot,all_enty,iteration)        "Price on commodity markets per iteration",
p80_pvpFallback(ttot,all_enty)              "Helper parameter. Price path from input/prices_NASH.inc. Only used if reading prices from gdx fails.",

p80_normalizeLT(all_enty)                   "Aggregated intertemporal  market volume",
p80_normalize0(ttot,all_regi,all_enty)      "Normalization parameter for market volume"

***parameter containing the respective level values from last iteration (the first set of values taken from gdx in the first iteration, respectively)
p80_Mport0(tall,all_regi,all_enty)          "Imports in last iteration"
p80_surplus(tall,all_enty,iteration)        "Surplus on commodity market",
p80_defic_trade(all_enty)                   "Surplus in monetary terms over all times on commodity markets [trillion US$2017]",
p80_defic_sum(iteration)                    "Surplus in monetary terms over all times on all commodity markets combined [trillion US$2017] (NOTE: to compare this number with the Negishi defic_sum, divide by around 100)",
p80_defic_sum_rel(iteration)                "Surplus monetary value over all times on all commodity markets combined, normalized to consumption [%]",

*LB* diagnostic parameters
p80_etaLT_correct(all_enty,iteration)       "long term price correction factor in percent"
p80_etaST_correct(tall,all_enty,iteration)  "short term price correction factor in percent"

p80_etaST_correct_safecopy(tall,all_enty,iteration)       "auxiliary parameter to remember short term price correction factor in percent, before new convergence adjustments"
o80_counter_iteration_trade_ttot(ttot,all_enty,iteration) "auxiliary parameter to display in which iteration and for which item (ttot, trade) additional convergence measures were taken"
o80_trackSurplusSign(ttot,all_enty,iteration)             "auxiliary parameter to track how long the surplus for an item (ttot, trade) had the same sign over iterations"
o80_SurplusOverTolerance(ttot,all_enty,iteration)         "auxiliary parameter to track in which iterations which item surpassed the tolerance (positive/negative)"


p80_surplusMax_iter(all_enty,iteration,tall)    "Diagnostics for Nash: Worst residual market surplus until given year, absolute value. [TWa, trillion Dollar, GtC]"
p80_surplusMax2100(all_enty)               "Worst residual market surplus until 2100, absolute value. [TWa, trillion Dollar, GtC]"
p80_surplusMaxRel(all_enty,iteration,tall) "Diagnostics for Nash: Worst residual market surplus until given year, in per cent."
p80_surplusMaxTolerance(all_enty)          "maximum tolerable residual value of absolute market surplus in 2100."

p80_taxrev0(tall,all_regi)                 "vm_taxrev from last iteration"
p80_taxrev_agg(tall,iteration)             "vm_taxrev globally from last iteration"


p80_handle(all_regi)                       "parallel mode handle parameter"
p80_repy(all_regi,solveinfo80)             "summary report from solver "
p80_repy_iteration(all_regi,solveinfo80,iteration) "summary report from solver in iteration"
p80_repyLastOptim(all_regi,solveinfo80)    "p80_repy from last iteration"
p80_repy_thisSolitr(all_regi,solveinfo80)    "p80_repy from the current solitr - only shows results for regions that were run in this solItr"
p80_repy_nashitr_solitr(all_regi,solveinfo80,iteration,sol_itr)   "summary report from solver in nash iteration and solver iteration"
p80_messageFailedMarket(tall,all_enty)     "nash display helper"
p80_messageShow(convMessage80)             "nash display helper"
p80_trackConsecFail(all_regi)              "Parameter to keep track of consecutive solve failures of regions in Nash mode."

p80_curracc(ttot,all_regi)                 "current account"

pm_cumEff(tall,all_regi,all_in)            "parameter for spillover externality (aggregated productivity level)"

p80_PriceChangePriceAnticipReg(ttot,all_enty,all_regi)  "Price change of a trade good due to the price anticipation effect. [Percent]"
o80_PriceChangePriceAnticipReg(ttot,all_enty,all_regi)  "only for display: Price change of a trade good due to price anticipation. If nothing is displayed, all values are <0.1%. [Percent, rounded to 0.1%]"
o80_PriceChangePriceAnticipRegMaxIter(ttot,iteration)   "only for display: Largest absolute value of o80_PriceChangePriceAnticipReg until 2100/2150, tracked over iteration. [Percent, rounded to 0.1%]"
p80_DevPriceAnticipReg(ttot,all_enty,all_regi)          "Deviation of the yearly monetary export/import expenditure due to price change anticipation effect. [trillion Dollar]"
p80_DevPriceAnticipGlob(ttot,all_enty)                  "Global sum of p80_DevPriceAnticipReg. [trillion Dollar]"
p80_DevPriceAnticipGlobIter(ttot,all_enty,iteration)    "Track p80_DevPriceAnticipGlob over iterations. [trillion Dollar]"
p80_DevPriceAnticipGlobAll(ttot)                        "p80_DevPriceAnticipGlob summed over all trade goods. [trillion Dollar]"
p80_DevPriceAnticipGlobMax(ttot,all_enty)               "Max of p80_DevPriceAnticipGlob until the given year. [trillion Dollar]"
p80_DevPriceAnticipGlobAllMax(ttot)                     "Max of p80_DevPriceAnticipGlobAll until the given year. [trillion Dollar]"
p80_DevPriceAnticipGlobMax2100Iter(all_enty,iteration)  "Track the 2100 value of p80_DevPriceAnticipGlobMax over iterations. [trillion Dollar]"
p80_DevPriceAnticipGlobAllMax2100Iter(iteration)        "Track the 2100 value of p80_DevPriceAnticipGlobAllMax over iterations. [trillion Dollar]"

*EMIOPT relevant
p80_eoMargPermBudg(all_regi)               "marginal of permit budget restriction"
p80_eoMargEmiCum(all_regi)                 "marginal of cumulative emissions"

p80_eoMargAverage                          "global average of marginals from nash budget equation"
p80_eoMargDiff(all_regi)                   "scaled deviation of regional marginals from global average"
p80_eoDeltaEmibudget                       "total change in permit budget"
p80_eoEmiMarg(all_regi)                    "weighted marginal utility of emissions"
p80_eoWeights(all_regi)                    "welfare weights"

p80_eoMargDiffItr(all_regi,iteration)      "scaled deviation of regional marginals from global average"
p80_eoEmibudget1RegItr(all_regi,iteration) "corrected regional permit budgets"
p80_eoEmibudgetDiffAbs(iteration)          "convergence indicator"
p80_count                                  "count regions with feasible solution"
p80_eoWeights_fix(all_regi)                "default and fallback weighting factors"

p80_SolNonOpt(all_regi)                    "solve status"

pm_fuExtrForeign(ttot,all_regi,all_enty,rlf) "foreign fuel extraction"

p80_convNashTaxrev_iter(iteration,ttot,all_regi) "deviation of tax revenue relative to GDP per iteration, thus 0.01 means 1 percent [1]"
p80_convNashObjVal_iter(iteration,all_regi)          "deviation of objective value to objective value from last iteration per iteration"
p80_fadeoutPriceAnticip_iter(iteration)           "Helper parameter, describes fadeout of price anticipation during iterations per iteration"
$ifthen.cm_implicitQttyTarget not "%cm_implicitQttyTarget%" == "off"
p80_implicitQttyTarget_dev_iter(iteration,ttot,ext_regi,qttyTarget,qttyTargetGroup)      "deviation of current iteration quantity target from target per iteration - relative for total targets, absolute (= share points) for share targets"
$endif.cm_implicitQttyTarget
p80_globalBudget_absDev_iter(iteration)           "absolute deviation of global cumulated CO2 emissions budget from target budget"
p80_sccConvergenceMaxDeviation_iter(iteration)    "max deviation of SCC from last iteration per iteration [percent]"
p80_gmt_conv_iter(iteration)                      "global mean temperature convergence per iteration"
;

positive variable
*AJS* Adjustment costs for Nash trade algorithm.  Only non-zero in the Nash_test realization of 80_optimization module.
vm_costAdjNash(ttot,all_regi)               "Adjustment costs for deviation from the trade structure of the last iteration."
;

equations
q80_budg_intertemp(all_regi)               "interemporal trade balance (Nash mode only)"
q80_costAdjNash(ttot,all_regi)             "calculate Nash adjustment costs (of anticipation of the difference in trade pattern, compared to the last iteration), combined for all markets"
q80_budgetPermRestr(all_regi)              "constraints regional permit budget to given regional emission budget";

scalars
***convergence criteria. if met, the optimization is stopped. Feel free to adjust these to your needs. Denote maximum tolerable deviation from market clearance.(the one for goods is given in  million US$2017/yr, the resources in EJ/yr)
sm_fadeoutPriceAnticip                     "Helper parameter, describes fadeout of price anticipation during iterations"
s80_fadeoutPriceAnticipStartingPeriod      "Helper parameter, denotes iteration in which price anticipation fadeout starts"
s80_dummy                                  "dummy scalar"
s80_before                                 "value of time step befor current interpolation time step"
s80_after                                  "value of time step after current interpolation time step"
s80_numberIterations                       "display helper"
s80_bool                                   "helper"
s80_converged                              "if nash converged, this is 1"
s80_runInDebug                             "Is 1 if regions stayed infeasible in nash and start in debug mode automatically following the parallel mode" /0/
;

*' defining specific output formats:
option   p80_DevPriceAnticipGlobAll:3:0:1;
option   p80_DevPriceAnticipGlobAllMax:3:0:1;
option   o80_PriceChangePriceAnticipReg:1:2:1;
option   o80_PriceChangePriceAnticipRegMaxIter:1:1:1;


*** EOF ./modules/80_optimization/nash/declarations.gms
