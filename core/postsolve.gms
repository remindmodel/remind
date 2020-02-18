*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./core/postsolve.gms

*-------------------------------calculate regional permit prices-----------------------------------
*** saving CO2 tax used in this iteration
pm_taxCO2eq_iteration(iteration,ttot,regi) = pm_taxCO2eq(ttot,regi);

*RP* added the historic 2010/2015 CO2 prices 
if (cm_emiscen eq 9,
 pm_pvpRegi(ttot,regi,"perm") = (pm_taxCO2eq(ttot,regi) + pm_taxCO2eqHist(ttot,regi) + pm_taxCO2eqSCC(ttot,regi))* pm_pvp(ttot,"good");
elseif ((cm_emiscen eq 2) OR (cm_emiscen eq 5) OR (cm_emiscen eq 8)),
 pm_pvpRegi(ttot,regi,"perm") =  pm_pricePerm(ttot) / pm_ts(ttot) + ( pm_taxCO2eqHist(ttot,regi) * pm_pvp(ttot,"good") );
 
elseif (cm_emiscen eq 6), !! the 2010/2015 CO2 prices do not need to be individually included, as they already influence the marginal of the q_co2eq equation (empirically tested) 

$ifthen.neg %optimization% == 'negishi'     
 pm_pvpRegi(ttot,regi,"perm") = abs(q_co2eq.m(ttot,regi)) / pm_ts(ttot) ;
$else.neg
pm_pvpRegi(ttot,regi,"perm") = abs(q_co2eq.m(ttot,regi)) / (abs(qm_budget.m(ttot,regi) )+ sm_eps) * pm_pvp(ttot,"good") ; 
$endif.neg 
   
elseif (cm_emiscen eq 1),  !! even in a BAU scenario without other climate policies, the 2010/2015 CO2 prices should be reported
 pm_pvpRegi(ttot,regi,"perm") = ( pm_taxCO2eqHist(ttot,regi) * pm_pvp(ttot,"good") );
    
);
*** if the bau or ref gdx has been run with a carbon tax (e.g. cm_emiscen=9), overwrite values before cm_startyear  
if ( (cm_startyear gt 2005),
  Execute_Loadpoint 'input_ref' p_pvpRegiBeforeStartYear = pm_pvpRegi;
  pm_pvpRegi(ttot,regi,"perm")$((ttot.val gt 2005) AND (ttot.val lt cm_startyear)) = p_pvpRegiBeforeStartYear(ttot,regi,"perm");
);

*LB* use the global permit price as regional permit price if no regional permit price is calculated
loop(ttot$(ttot.val ge 2005),
  loop(regi,
    if(pm_pvpRegi(ttot,regi,"perm") eq NA,
      pm_pvpRegi(ttot,regi,"perm") = pm_pvp(ttot,"perm") + ( pm_taxCO2eqHist(ttot,regi) * pm_pvp(ttot,"good") );
    );
  );
);


if(cm_iterative_target_adj eq 1,
***cb 20140212 Update tax levels/ multigasbudget values to reach the emission target / CO2 budget (s_actualbudgetco2 runs from 2000-2100)
	if (cm_emiscen eq 6,
		display sm_budgetCO2eqGlob;
***cb from awp2 20140212: budget calculated as 2005-2095*pm_ts (92.5 years)  + 2100*5 + 2000*2.5; 
*for the period 2000.5 until the end of 2002 (therefore the factor 2.5 in line 11) we have to use historical data:  6.9 GtC CO2 in 2001 according to http://cdiac.ornl.gov/ftp/ndp030/global.1751_2008.ems + 1.4GtC luc http://cdiac.ornl.gov/trends/landuse/houghton/1850-2005.txt
		s_actualbudgetco2 =    sum(ttot$(ttot.val < 2100 AND ttot.val ge 2005), (sum(regi, (vm_emiTe.l(ttot,regi,"co2") + vm_emiCdr.l(ttot,regi,"co2") + vm_emiMac.l(ttot,regi,"co2")))*sm_c_2_co2 * pm_ts(ttot)))
$if not setglobal test_TS     + sum(regi, vm_emiTe.l("2100",regi,"co2") + vm_emiCdr.l("2100",regi,"co2") + vm_emiMac.l("2100",regi,"co2"))*sm_c_2_co2 * pm_ts("2100")/2
$if setglobal test_TS         + sum(regi, vm_emiTe.l("2090",regi,"co2") + vm_emiCdr.l("2090",regi,"co2") + vm_emiMac.l("2090",regi,"co2"))*sm_c_2_co2 * pm_ts("2090")/2
                              + (6.9 + 1.4)*sm_c_2_co2 * 2.5;
		display s_actualbudgetco2;
		if(o_modelstat eq 2 AND ord(iteration)<cm_iteration_max ,!!only for optimal iterations, and not after the last one
			sm_budgetCO2eqGlob=sm_budgetCO2eqGlob*(s_referencebudgetco2/s_actualbudgetco2);
			pm_budgetCO2eq(regi)=pm_budgetCO2eq(regi)*(s_referencebudgetco2/s_actualbudgetco2);
		else
			sm_budgetCO2eqGlob=sm_budgetCO2eqGlob;
		);
		display sm_budgetCO2eqGlob;
	elseif cm_emiscen eq 9,
		display pm_taxCO2eq;
***cb from awp2 20140212: Kyoto emissions in 2030 to update tax level: unit [Gt CO2eq/yr]
		s_actual2030co2eq = (sum(regi, vm_co2eq.l("2030",regi)*sm_c_2_co2 + vm_emiFgas.L("2030",regi,"emiFgasTotal")/1000));
		display vm_co2eq.l;
		display s_actual2030co2eq;
		if(o_modelstat eq 2 AND ord(iteration)<cm_iteration_max,!!only for optimal iterations, and not after the last one
			pm_taxCO2eq(t,regi)=pm_taxCO2eq(t,regi)*min(((s_actual2030co2eq/s_reference2030co2eq)**8),2);
		);
    pm_taxCO2eq(t,regi)$(t.val gt 2110) = pm_taxCO2eq("2110",regi); !! to prevent huge taxes after 2110 and the resulting convergence problems, set taxes after 2110 equal to 2110 value
		display pm_taxCO2eq;
	 );
);

if(cm_iterative_target_adj eq 4,
*JeS* Update tax levels/ multigasbudget values to reach the CO2 FF&I budget (s_actualbudgetco2 runs from 2010-2100)

*** budget calculated as 2015-2095 + 2100*5 + 2010*2.5 in Gt CO2; 
s_actualbudgetco2 =           sum(ttot$(ttot.val < 2100 AND ttot.val > 2010), (sum(regi, vm_emiTe.l(ttot,regi,"co2") + vm_emiMacSector.l(ttot,regi,"co2cement_process")) * sm_c_2_co2 * pm_ts(ttot)))
$if not setglobal test_TS     + sum(regi, vm_emiTe.l("2100",regi,"co2") + vm_emiMacSector.l("2100",regi,"co2cement_process"))*sm_c_2_co2 * pm_ts("2100")/2
$if setglobal test_TS         + sum(regi, vm_emiTe.l("2090",regi,"co2") + vm_emiMacSector.l("2090",regi,"co2cement_process"))*sm_c_2_co2 * pm_ts("2090")/2
                              + sum(regi, vm_emiTe.l("2010",regi,"co2") + vm_emiMacSector.l("2010",regi,"co2cement_process"))*sm_c_2_co2 * pm_ts("2010")/2;
display s_actualbudgetco2;
		
	if (cm_emiscen eq 6,
		if(o_modelstat eq 2 AND ord(iteration)<cm_iteration_max ,   !!only for optimal iterations, and not after the last one
		display sm_budgetCO2eqGlob;		
			sm_budgetCO2eqGlob = sm_budgetCO2eqGlob + ((1/sm_c_2_co2) * (c_budgetCO2FFI - s_actualbudgetco2));
			pm_budgetCO2eq(regi) = pm_budgetCO2eq(regi) + ((1/sm_c_2_co2) * (c_budgetCO2FFI - s_actualbudgetco2) / card(regi));
		else
			sm_budgetCO2eqGlob = sm_budgetCO2eqGlob;
		);
		display sm_budgetCO2eqGlob;
	elseif cm_emiscen eq 9,
	    if(o_modelstat eq 2 AND ord(iteration)<cm_iteration_max ,   !!only for optimal iterations, and not after the last one
		display pm_taxCO2eq;		
			pm_taxCO2eq(t,regi) = pm_taxCO2eq(t,regi) * (s_actualbudgetco2/c_budgetCO2FFI);
		else
			pm_taxCO2eq(t,regi) = pm_taxCO2eq(t,regi);
		);
    pm_taxCO2eq(t,regi)$(t.val gt 2110) = pm_taxCO2eq("2110",regi); !! to prevent huge taxes after 2110 and the resulting convergence problems, set taxes after 2110 equal to 2110 value
		display pm_taxCO2eq;
	 );
);

if(cm_iterative_target_adj eq 5,
*JeS* Update tax levels/ multigasbudget values to reach the CO2 budget (s_actualbudgetco2 runs from 2011-2100)

*** budget calculated as 2015-2095 + 2100*5.5 + 2010*2 in Gt CO2; 
s_actualbudgetco2 =           sum(ttot$(ttot.val < 2100 AND ttot.val > 2010), (sum(regi, (vm_emiTe.l(ttot,regi,"co2") + vm_emiCdr.l(ttot,regi,"co2") + vm_emiMac.l(ttot,regi,"co2"))) * sm_c_2_co2 * pm_ts(ttot)))
$if not setglobal test_TS     + sum(regi, (vm_emiTe.l("2100",regi,"co2") + vm_emiCdr.l("2100",regi,"co2") + vm_emiMac.l("2100",regi,"co2")))*sm_c_2_co2 * 5.5
                              + sum(regi, (vm_emiTe.l("2010",regi,"co2") + vm_emiCdr.l("2010",regi,"co2") + vm_emiMac.l("2010",regi,"co2")))*sm_c_2_co2 * 2;
display s_actualbudgetco2;
		
	if (cm_emiscen eq 6,
		if(o_modelstat eq 2 AND ord(iteration)<cm_iteration_max ,   !!only for optimal iterations, and not after the last one
		display sm_budgetCO2eqGlob;		
			sm_budgetCO2eqGlob = sm_budgetCO2eqGlob * (c_budgetCO2/s_actualbudgetco2);
			pm_budgetCO2eq(regi) = pm_budgetCO2eq(regi) * (c_budgetCO2/s_actualbudgetco2);
		else
			sm_budgetCO2eqGlob = sm_budgetCO2eqGlob;
		);
		display sm_budgetCO2eqGlob;
	elseif cm_emiscen eq 9,
	    if(o_modelstat eq 2 AND ord(iteration)<cm_iteration_max AND s_actualbudgetco2 > 0 AND abs(c_budgetCO2 - s_actualbudgetco2) ge 0.5,   !!only for optimal iterations, and not after the last one, and only if budget still possitive, and only if target not yet reached
		display pm_taxCO2eq;		
*** make sure that iteration converges: 
*** use multiplicative for budgets higher than 1200 Gt; for lower budgets, use multiplicative adjustment only for first 3 iterations, 
			if(ord(iteration) lt 3 or c_budgetCO2 > 1200,
			    !! change in CO2 price through adjustment: new price - old price; needed for adjustment option 2
				p_taxCO2eq_iterationdiff(t,regi) = pm_taxCO2eq(t,regi) * min(max((s_actualbudgetco2/c_budgetCO2)** (25/(2 * iteration.val + 23)),0.5+iteration.val/208),2 - iteration.val/102)  - pm_taxCO2eq(t,regi);
				pm_taxCO2eq(t,regi) = pm_taxCO2eq(t,regi) + p_taxCO2eq_iterationdiff(t,regi) ;
*** then switch to triangle-approximation based on last two iteration data points			
			else
			    !! change in CO2 price through adjustment: new price - old price; the two instances of "pm_taxCO2eq" cancel out -> only the difference term
				p_taxCO2eq_iterationdiff_tmp(t,regi) = 
				                      max(p_taxCO2eq_iterationdiff(t,regi) * min(max((c_budgetCO2 - s_actualbudgetco2)/(s_actualbudgetco2 - s_actualbudgetco2_last),-2),2),-pm_taxCO2eq(t,regi)/2);
				pm_taxCO2eq(t,regi) = pm_taxCO2eq(t,regi) + 
				                      max(p_taxCO2eq_iterationdiff(t,regi) * min(max((c_budgetCO2 - s_actualbudgetco2)/(s_actualbudgetco2 - s_actualbudgetco2_last),-2),2),-pm_taxCO2eq(t,regi)/2);
			    p_taxCO2eq_iterationdiff(t,regi) = p_taxCO2eq_iterationdiff_tmp(t,regi);
			);
      o_taxCO2eq_iterDiff_Itr(iteration,regi) = p_taxCO2eq_iterationdiff("2030",regi);
      display o_taxCO2eq_iterDiff_Itr;
		else
			if(s_actualbudgetco2 > 0 or abs(c_budgetCO2 - s_actualbudgetco2) < 2, !! if model was not optimal, or if budget already reached, keep tax constant
			pm_taxCO2eq(t,regi) = pm_taxCO2eq(t,regi);
			else
*** if budget has turned negative, reduce CO2 price by 20%
			pm_taxCO2eq(t,regi) = 0.8*pm_taxCO2eq(t,regi);
			);	
		);
		
    pm_taxCO2eq(t,regi)$(t.val gt 2110) = pm_taxCO2eq("2110",regi); !! to prevent huge taxes after 2110 and the resulting convergence problems, set taxes after 2110 equal to 2110 value
    display pm_taxCO2eq;
	 );
);

if(cm_iterative_target_adj eq 6,
*JeS* Update tax levels/ multigasbudget values to reach the peak CO2 budget
 
p_actualbudgetco2(t) =           sum(ttot$(ttot.val < t.val AND ttot.val > 2010), (sum(regi, (vm_emiTe.l(ttot,regi,"co2") + vm_emiCdr.l(ttot,regi,"co2") + vm_emiMac.l(ttot,regi,"co2"))) * sm_c_2_co2 * pm_ts(ttot)))
                              + sum(regi, (vm_emiTe.l(t,regi,"co2") + vm_emiCdr.l(t,regi,"co2") + vm_emiMac.l(t,regi,"co2")))*sm_c_2_co2 * (pm_ts(t) * 0.5 + 0.5)
                              + sum(regi, (vm_emiTe.l("2010",regi,"co2") + vm_emiCdr.l("2010",regi,"co2") + vm_emiMac.l("2010",regi,"co2")))*sm_c_2_co2 * 2;
s_actualbudgetco2 = smax(t,p_actualbudgetco2(t));							  
display s_actualbudgetco2;
		
	if (cm_emiscen eq 6,
		if(o_modelstat eq 2 AND ord(iteration)<cm_iteration_max ,   !!only for optimal iterations, and not after the last one
		display sm_budgetCO2eqGlob;		
			sm_budgetCO2eqGlob = sm_budgetCO2eqGlob * (c_budgetCO2/s_actualbudgetco2);
			pm_budgetCO2eq(regi) = pm_budgetCO2eq(regi) * (c_budgetCO2/s_actualbudgetco2);
		else
			sm_budgetCO2eqGlob = sm_budgetCO2eqGlob;
		);
		display sm_budgetCO2eqGlob;
	elseif cm_emiscen eq 9,
	    if(o_modelstat eq 2 AND ord(iteration)<cm_iteration_max AND s_actualbudgetco2 > 0 AND abs(c_budgetCO2 - s_actualbudgetco2) ge 0.5,   !!only for optimal iterations, and not after the last one, and only if budget still possitive, and only if target not yet reached
		display pm_taxCO2eq;		
*** make sure that iteration converges: 
*** use multiplicative for budgets higher than 1200 Gt; for lower budgets, use multiplicative adjustment only for first 3 iterations, 
			if(ord(iteration) lt 3 or c_budgetCO2 > 1200,
			    !! change in CO2 price through adjustment: new price - old price; needed for adjustment option 2
				p_taxCO2eq_iterationdiff(t,regi) = pm_taxCO2eq(t,regi) * min(max((s_actualbudgetco2/c_budgetCO2)** (25/(2 * iteration.val + 23)),0.5+iteration.val/208),2 - iteration.val/102)  - pm_taxCO2eq(t,regi);
				pm_taxCO2eq(t,regi) = pm_taxCO2eq(t,regi) + p_taxCO2eq_iterationdiff(t,regi) ;
*** then switch to triangle-approximation based on last two iteration data points			
			else
			    !! change in CO2 price through adjustment: new price - old price; the two instances of "pm_taxCO2eq" cancel out -> only the difference term
				p_taxCO2eq_iterationdiff_tmp(t,regi) = 
				                      max(p_taxCO2eq_iterationdiff(t,regi) * min(max((c_budgetCO2 - s_actualbudgetco2)/(s_actualbudgetco2 - s_actualbudgetco2_last),-2),2),-pm_taxCO2eq(t,regi)/2);
				pm_taxCO2eq(t,regi) = pm_taxCO2eq(t,regi) + 
				                      max(p_taxCO2eq_iterationdiff(t,regi) * min(max((c_budgetCO2 - s_actualbudgetco2)/(s_actualbudgetco2 - s_actualbudgetco2_last),-2),2),-pm_taxCO2eq(t,regi)/2);
			    p_taxCO2eq_iterationdiff(t,regi) = p_taxCO2eq_iterationdiff_tmp(t,regi);
			);
      o_taxCO2eq_iterDiff_Itr(iteration,regi) = p_taxCO2eq_iterationdiff("2030",regi);
      display o_taxCO2eq_iterDiff_Itr;
		else
			if(s_actualbudgetco2 > 0 or abs(c_budgetCO2 - s_actualbudgetco2) < 2, !! if model was not optimal, or if budget already reached, keep tax constant
			pm_taxCO2eq(t,regi) = pm_taxCO2eq(t,regi);
			else
*** if budget has turned negative, reduce CO2 price by 20%
			pm_taxCO2eq(t,regi) = 0.8*pm_taxCO2eq(t,regi);
			);	
		);
		
    pm_taxCO2eq(t,regi)$(t.val gt 2110) = pm_taxCO2eq("2110",regi); !! to prevent huge taxes after 2110 and the resulting convergence problems, set taxes after 2110 equal to 2110 value
    display pm_taxCO2eq;
	 );
);

*** ---------------------------------------------------------------------------------------------------------------
*** ENGAGE peakBudg formulation that works with several CO2 price path realizations of module 45 ---------------------
*** it results in a peak budget with zero net CO2 emissions afterwards
*** ---------------------------------------------------------------------------------------------------------------
if(cm_iterative_target_adj eq 7,
*JeS/CB* Update tax levels/ multigasbudget values to reach the peak CO2 budget, but make sure CO2 emissions afterward are close to zero on the global level
 
*** Save the original functional form of the CO2 price trajectory so values for all times can be accessed even if the peakBudgYr is shifted. 
  if( iteration.val eq 1, 
    p_taxCO2eq_until2150(t,regi) = pm_taxCO2eq(t,regi);
	); 
 
p_actualbudgetco2(t) =           sum(ttot$(ttot.val < t.val AND ttot.val > 2010), (sum(regi, (vm_emiTe.l(ttot,regi,"co2") + vm_emiCdr.l(ttot,regi,"co2") + vm_emiMac.l(ttot,regi,"co2"))) * sm_c_2_co2 * pm_ts(ttot)))
                              + sum(regi, (vm_emiTe.l(t,regi,"co2") + vm_emiCdr.l(t,regi,"co2") + vm_emiMac.l(t,regi,"co2")))*sm_c_2_co2 * (pm_ts(t) * 0.5 + 0.5)
                              + sum(regi, (vm_emiTe.l("2010",regi,"co2") + vm_emiCdr.l("2010",regi,"co2") + vm_emiMac.l("2010",regi,"co2")))*sm_c_2_co2 * 2;
s_actualbudgetco2 = smax(t$(t.val le cm_peakBudgYr),p_actualbudgetco2(t));
							

  o_peakBudgYr_Itr(iteration) = cm_peakBudgYr;
							
display s_actualbudgetco2;  
display p_actualbudgetco2;

	if (cm_emiscen eq 9,
	    if(o_modelstat eq 2 AND ord(iteration)<cm_iteration_max AND s_actualbudgetco2 > 0 AND abs(c_budgetCO2 - s_actualbudgetco2) ge 0.5,   !!only for optimal iterations, and not after the last one, and only if budget still possitive, and only if target not yet reached
		display pm_taxCO2eq;		
*** make sure that iteration converges: 
*** use multiplicative for budgets higher than 1600 Gt; for lower budgets, use multiplicative adjustment only for first 3 iterations, 
			if(ord(iteration) lt 3 or c_budgetCO2 > 1600,
			    !! change in CO2 price through adjustment: new price - old price; needed for adjustment option 2
				p_taxCO2eq_iterationdiff(t,regi) = pm_taxCO2eq(t,regi) * min(max((s_actualbudgetco2/c_budgetCO2)** (25/(2 * iteration.val + 23)),0.5+iteration.val/208),2 - iteration.val/102)  - pm_taxCO2eq(t,regi);
				pm_taxCO2eq(t,regi)$(t.val le cm_peakBudgYr) = pm_taxCO2eq(t,regi) + p_taxCO2eq_iterationdiff(t,regi) ;
				p_taxCO2eq_until2150(t,regi) = p_taxCO2eq_until2150(t,regi) + p_taxCO2eq_iterationdiff(t,regi) ;
*** then switch to triangle-approximation based on last two iteration data points			
			else
			    !! change in CO2 price through adjustment: new price - old price; the two instances of "pm_taxCO2eq" cancel out -> only the difference term
				!! until cm_peakBudgYr: expolinear price trajectory
				p_taxCO2eq_iterationdiff_tmp(t,regi) = 
				                      max(p_taxCO2eq_iterationdiff(t,regi) * min(max((c_budgetCO2 - s_actualbudgetco2)/(s_actualbudgetco2 - s_actualbudgetco2_last),-2),2),-pm_taxCO2eq(t,regi)/2);
				pm_taxCO2eq(t,regi)$(t.val le cm_peakBudgYr) = pm_taxCO2eq(t,regi) + 
				                      max(p_taxCO2eq_iterationdiff(t,regi) * min(max((c_budgetCO2 - s_actualbudgetco2)/(s_actualbudgetco2 - s_actualbudgetco2_last),-2),2),-pm_taxCO2eq(t,regi)/2);
			    p_taxCO2eq_until2150(t,regi) = p_taxCO2eq_until2150(t,regi) + 
				                      max(p_taxCO2eq_iterationdiff(t,regi) * min(max((c_budgetCO2 - s_actualbudgetco2)/(s_actualbudgetco2 - s_actualbudgetco2_last),-2),2),-p_taxCO2eq_until2150(t,regi)/2);
				p_taxCO2eq_iterationdiff(t,regi) = p_taxCO2eq_iterationdiff_tmp(t,regi);
				!! after cm_peakBudgYr: adjustment so that emissions become zero: increase/decrease tax in each time step after cm_peakBudgYr by percentage of that year's total CO2 emissions of 2015 emissions
			);
      o_taxCO2eq_iterDiff_Itr(iteration,regi) = p_taxCO2eq_iterationdiff("2030",regi);
      display o_taxCO2eq_iterDiff_Itr;
		else
			if(s_actualbudgetco2 > 0 or abs(c_budgetCO2 - s_actualbudgetco2) < 2, !! if model was not optimal, or if budget already reached, keep tax constant
			pm_taxCO2eq(t,regi) = pm_taxCO2eq(t,regi);
			else
*** if budget has turned negative, reduce CO2 price by 20%
			pm_taxCO2eq(t,regi) = 0.8*pm_taxCO2eq(t,regi);
			p_taxCO2eq_until2150(t,regi) = 0.8*p_taxCO2eq_until2150(t,regi);
			);	
		);
*** after cm_peakBudgYr: always adjust to bring emissions close to zero
		pm_taxCO2eq(t,regi)$(t.val gt cm_peakBudgYr) = pm_taxCO2eq(t,regi) + pm_taxCO2eq(t,regi)*max(sum(regi2,vm_emiAll.l(t,regi2,"co2"))/sum(regi2,vm_emiAll.l("2015",regi2,"co2")),-0.75);

*** check if cm_peakBudgYr is correct: if global emissions already negative, move cm_peakBudgYr forward
*** similar code block as used in iterative-adjust 9 below (credit to RP)
    o_diff_to_Budg(iteration) = (c_budgetCO2 - s_actualbudgetco2);
    o_totCO2emi_peakBudgYr(iteration) = sum(t$(t.val = cm_peakBudgYr), sum(regi2, vm_emiAll.l(t,regi2,"co2")) );
    o_totCO2emi_allYrs(t,iteration) = sum(regi2, vm_emiAll.l(t,regi2,"co2") );
    o_change_totCO2emi_peakBudgYr(iteration) = sum(ttot$(ttot.val = cm_peakBudgYr), (o_totCO2emi_allYrs(ttot-1,iteration) - o_totCO2emi_allYrs(ttot+1,iteration) )/4 );  !! Only gives a tolerance range, exact value not important. Division by 4 somewhat arbitrary - could be 3 or 5 as well. 

    display cm_peakBudgYr, o_diff_to_Budg, o_peakBudgYr_Itr, o_totCO2emi_allYrs, o_totCO2emi_peakBudgYr, o_change_totCO2emi_peakBudgYr;

***if( sum(t,sum(regi2,vm_emiAll.l(t,regi2,"co2")$(t.val = cm_peakBudgYr))) < -0.1,
*** cm_peakBudgYr = tt.val(t - 1)$(t.val = cm_peakBudgYr);
***);		

    if( abs(o_diff_to_Budg(iteration)) < 20,                      !! only think about shifting peakBudgYr if the budget is close enough to target budget
      display "close enough to target budget to check timing of peak year";
      loop(ttot$(ttot.val = cm_peakBudgYr),                               !! look at the peak timing
***        if(  ( (o_totCO2emi_peakBudgYr(iteration) < -(0.1 + o_change_totCO2emi_peakBudgYr(iteration)) ) AND (cm_peakBudgYr > 2040) ), !! no peaking time before 2040
        if(  ( (o_totCO2emi_peakBudgYr(iteration) < -(0.1) ) AND (cm_peakBudgYr > 2040) ), !! no peaking time before 2040
        display "shift peakBudgYr left";
		  o_peakBudgYr_Itr(iteration+1) =  pm_ttot_val(ttot - 1);                
***          pm_taxCO2eq(t,regi)$(t.val gt pm_ttot_val(ttot - 1)) = p_taxCO2eq_until2150(ttot-1,regi) + (t.val - pm_ttot_val(ttot - 1)) * cm_taxCO2inc_after_peakBudgYr * sm_DptCO2_2_TDpGtC;  !! increase by cm_taxCO2inc_after_peakBudgYr per year after peakBudgYr
*** if tax after cm_peakBudgYr is higher than normal increase rate (exceeding a 20% tolerance): shift right
		elseif( ( sum(regi, sum(t2$(t2.val = pm_ttot_val(ttot+1)),pm_taxCO2eq(t2,regi))) > sum(regi,sum(t2$(t2.val = pm_ttot_val(ttot+1)),p_taxCO2eq_until2150(t2,regi)))*1.2 ) AND (cm_peakBudgYr < 2100) ), !! if peaking time would be after 2100, keep 2100 budget year
          if(  (iteration.val > 2) AND ( o_peakBudgYr_Itr(iteration - 1) > o_peakBudgYr_Itr(iteration) ) AND ( o_peakBudgYr_Itr(iteration - 2) = o_peakBudgYr_Itr(iteration) ) , !! if the target year was just shifted left after being shifted right
            o_peakBudgYr_Itr(iteration+1) = o_peakBudgYr_Itr(iteration); !! don't shift right again immediately, but go into a different loop:
            o_delay_increase_peakBudgYear(iteration) = 1;
          else
		    display "shift peakBudgYr right";
            o_peakBudgYr_Itr(iteration+1) =  pm_ttot_val(ttot + 1);  !! ttot+1 is the new peakBudgYr
			loop(t$(t.val ge pm_ttot_val(ttot + 1)),
              pm_taxCO2eq(t,regi) = p_taxCO2eq_until2150(t,regi);
            );
		  );
        
		else   !! don't do anything if the peakBudgYr is already at the corner values (2040, 2100) or if the emissions in the peakBudgYr are close to 0
          o_peakBudgYr_Itr(iteration+1) = o_peakBudgYr_Itr(iteration)
        );
      );
      cm_peakBudgYr = o_peakBudgYr_Itr(iteration+1);
      display cm_peakBudgYr;
    );




		
    pm_taxCO2eq(t,regi)$(t.val gt 2110) = pm_taxCO2eq("2110",regi); !! to prevent huge taxes after 2110 and the resulting convergence problems, set taxes after 2110 equal to 2110 value
    display pm_taxCO2eq;
	 );
);


*** ---------------------------------------------------------------------------------------------------------------
*** new peakBudg formulation that works with several CO2 price path realizations of module 45 ---------------------
*** it results in a peak budget with linear increase by 2$/yr afterwards
*** ---------------------------------------------------------------------------------------------------------------

if(cm_iterative_target_adj eq 9,
*RP* Update tax levels/ multigasbudget values to reach the peak CO2 budget, with a linear increase afterwards given by cm_taxCO2inc_after_peakBudgYr
*** The PeakBudgYr is found automatically by the algorithm (within the time window 204-2100)
 
  p_actualbudgetco2(t) =  sum(ttot$(ttot.val < t.val AND ttot.val > 2010), (sum(regi, (vm_emiTe.l(ttot,regi,"co2") + vm_emiCdr.l(ttot,regi,"co2") + vm_emiMac.l(ttot,regi,"co2"))) * sm_c_2_co2 * pm_ts(ttot)))
                          + sum(regi, (vm_emiTe.l(t,regi,"co2") + vm_emiCdr.l(t,regi,"co2") + vm_emiMac.l(t,regi,"co2")))*sm_c_2_co2 * (pm_ts(t) * 0.5 + 0.5)
                          + sum(regi, (vm_emiTe.l("2010",regi,"co2") + vm_emiCdr.l("2010",regi,"co2") + vm_emiMac.l("2010",regi,"co2")))*sm_c_2_co2 * 2;
  s_actualbudgetco2 = smax(t$(t.val le cm_peakBudgYr),p_actualbudgetco2(t));
  
  o_peakBudgYr_Itr(iteration) = cm_peakBudgYr;
                  
  display s_actualbudgetco2;  
  display p_actualbudgetco2;

  if(cm_emiscen eq 9,
    if(o_modelstat eq 2 AND ord(iteration)<cm_iteration_max AND s_actualbudgetco2 > 0 AND abs(c_budgetCO2 - s_actualbudgetco2) ge 2,   !!only for optimal iterations, and not after the last one, and only if budget still possitive, and only if target not yet reached
      display pm_taxCO2eq;

      if( ( ( p_actualbudgetco2("2100") > 1.1 * s_actualbudgetco2 ) AND ( abs(c_budgetCO2 - s_actualbudgetco2) < 50 ) AND (iteration.val < 12) ), 
        display iteration;
*** if end-of-century budget is higher than budget at peak point, AND end-of-century budget is already in the range of the target budget (+/- 50 GtC), treat as end-of-century budget 
*** for this iteration. Only do this rough approach (jump to 2100) for the first iterations - at later iterations the slower adjustment of the peaking time should work better
        display "this is likely an end-of-century budget with no net negative emissions at all. Shift cm_peakBudgYr to 2100";
        s_actualbudgetco2 = 0.5 * (p_actualbudgetco2("2100") + s_actualbudgetco2); !! due to the potential strong jump in cm_peakBudgYr, which implies that the CO2 price 
*** will increase over a longer time horizon, take the average of the budget at the old peak time and the new peak time
        cm_peakBudgYr = 2100;
      );

*** --------new convergence----------------------------------------------------------
***  calculating the CO2 tax rescale factor

      if(iteration.val lt 10,
        p_factorRescale_taxCO2(iteration) = max(0.1, (s_actualbudgetco2/c_budgetCO2) ) ** 3;
      else
        p_factorRescale_taxCO2(iteration) = max(0.1, (s_actualbudgetco2/c_budgetCO2) ) ** 2;
      );
      p_factorRescale_taxCO2_Funneled(iteration) =
                max(min( 2 * EXP( -0.15 * iteration.val ) + 1.01 ,p_factorRescale_taxCO2(iteration)),
                        1/ ( 2 * EXP( -0.15 * iteration.val ) + 1.01)
                );

      p_taxCO2eq_iterationdiff(t,regi) = max(1* sm_DptCO2_2_TDpGtC, pm_taxCO2eq(t,regi) * p_factorRescale_taxCO2_Funneled(iteration) ) - pm_taxCO2eq(t,regi);
      p_taxCO2eq_until2150(t,regi) = max(1* sm_DptCO2_2_TDpGtC, p_taxCO2eq_until2150(t,regi) * p_factorRescale_taxCO2_Funneled(iteration) );
      pm_taxCO2eq(t,regi) = max(1* sm_DptCO2_2_TDpGtC, pm_taxCO2eq(t,regi) * p_factorRescale_taxCO2_Funneled(iteration) );  !! rescale co2tax
      loop(t2$(t2.val eq cm_peakBudgYr),
	    pm_taxCO2eq(t,regi)$(t.val gt cm_peakBudgYr) = p_taxCO2eq_until2150(t2,regi) + (t.val - t2.val) * cm_taxCO2inc_after_peakBudgYr * sm_DptCO2_2_TDpGtC;  !! increase by cm_taxCO2inc_after_peakBudgYr per year
	  );

      display p_factorRescale_taxCO2, p_factorRescale_taxCO2_Funneled;

      o_taxCO2eq_iterDiff_Itr(iteration,regi) = p_taxCO2eq_iterationdiff("2030",regi);
      loop(regi, !! not a nice solution to having only the price of one regi display (for better visibility), but this way it overwrites again and again until the value from the last regi remain
	    o_taxCO2eq_Itr_1regi(t,iteration+1) = pm_taxCO2eq(t,regi); 
	  );
    
      display o_taxCO2eq_iterDiff_Itr, o_taxCO2eq_Itr_1regi;
	  
  
    else !! if(o_modelstat eq 2 AND ord(iteration)<cm_iteration_max AND s_actualbudgetco2 > 0 AND abs(c_budgetCO2 ))
      if(s_actualbudgetco2 > 0 or abs(c_budgetCO2 - s_actualbudgetco2) < 2, !! if model was not optimal, or if budget already reached, keep tax constant
          p_taxCO2eq_until2150(t,regi) = p_taxCO2eq_until2150(t,regi); !! nothing changes
      else
*** if budget has turned negative, reduce CO2 price by 20%
      p_taxCO2eq_until2150(t,regi) = 0.8*p_taxCO2eq_until2150(t,regi);
      pm_taxCO2eq(t,regi) = 0.8*pm_taxCO2eq(t,regi);
      );  
    ); !! if(o_modelstat eq 2 AND ord(iteration)<cm_iteration_max AND s_actualbudgetco2 > 0 AND abs(c_budgetCO2 - s_actualbudgetco2) ge 2,
    
    display pm_taxCO2eq, p_taxCO2eq_until2150;

	
***-----------------------------------------------  


    o_diff_to_Budg(iteration) = (c_budgetCO2 - s_actualbudgetco2);
    o_totCO2emi_peakBudgYr(iteration) = sum(t$(t.val = cm_peakBudgYr), sum(regi2, vm_emiAll.l(t,regi2,"co2")) );
    o_totCO2emi_allYrs(t,iteration) = sum(regi2, vm_emiAll.l(t,regi2,"co2") );
    o_change_totCO2emi_peakBudgYr(iteration) = sum(ttot$(ttot.val = cm_peakBudgYr), (o_totCO2emi_allYrs(ttot-1,iteration) - o_totCO2emi_allYrs(ttot+1,iteration) )/4 );  !! Only gives a tolerance range, exact value not important. Division by 4 somewhat arbitrary - could be 3 or 5 as well. 

    display cm_peakBudgYr, o_diff_to_Budg, o_peakBudgYr_Itr, o_totCO2emi_allYrs, o_totCO2emi_peakBudgYr, o_change_totCO2emi_peakBudgYr;


*** check if cm_peakBudgYr is correct: if global emissions are already negative, move cm_peakBudgYr forward
    if( abs(o_diff_to_Budg(iteration)) < 20,                      !! only think about shifting peakBudgYr if the budget is close enough to target budget
      display "close enough to target budget to check timing of peak year";
      loop(ttot$(ttot.val = cm_peakBudgYr),                               !! look at the peak timing
        if(  ( (o_totCO2emi_peakBudgYr(iteration) < -(0.1 + o_change_totCO2emi_peakBudgYr(iteration)) ) AND (cm_peakBudgYr > 2040) ), !! no peaking time before 2040
          display "shift peakBudgYr left";
		  o_peakBudgYr_Itr(iteration+1) =  pm_ttot_val(ttot - 1);                
          pm_taxCO2eq(t,regi)$(t.val gt pm_ttot_val(ttot - 1)) = p_taxCO2eq_until2150(ttot-1,regi) + (t.val - pm_ttot_val(ttot - 1)) * cm_taxCO2inc_after_peakBudgYr * sm_DptCO2_2_TDpGtC;  !! increase by cm_taxCO2inc_after_peakBudgYr per year after peakBudgYr
        
		elseif ( ( o_totCO2emi_peakBudgYr(iteration) > (0.1 + o_change_totCO2emi_peakBudgYr(iteration)) ) AND (cm_peakBudgYr < 2100) ), !! if peaking time would be after 2100, keep 2100 budget year
          if(  (iteration.val > 2) AND ( o_peakBudgYr_Itr(iteration - 1) > o_peakBudgYr_Itr(iteration) ) AND ( o_peakBudgYr_Itr(iteration - 2) = o_peakBudgYr_Itr(iteration) ) , !! if the target year was just shifted left after being shifted right
            o_peakBudgYr_Itr(iteration+1) = o_peakBudgYr_Itr(iteration); !! don't shift right again immediately, but go into a different loop:
            o_delay_increase_peakBudgYear(iteration) = 1;
          else
		    display "shift peakBudgYr right";
            o_peakBudgYr_Itr(iteration+1) =  pm_ttot_val(ttot + 1);  !! ttot+1 is the new peakBudgYr
			loop(t$(t.val ge pm_ttot_val(ttot + 1)),
              pm_taxCO2eq(t,regi) = p_taxCO2eq_until2150(ttot+1,regi) 
			                        + (t.val - pm_ttot_val(ttot + 1)) * cm_taxCO2inc_after_peakBudgYr * sm_DptCO2_2_TDpGtC;  !! increase by cm_taxCO2inc_after_peakBudgYr per year 
            );
		  );
        
		else   !! don't do anything if the peakBudgYr is already at the corner values (2040, 2100) or if the emissions in the peakBudgYr are close to 0
          o_peakBudgYr_Itr(iteration+1) = o_peakBudgYr_Itr(iteration)
        );
      );
      cm_peakBudgYr = o_peakBudgYr_Itr(iteration+1);
      display cm_peakBudgYr;
    );
        
    pm_taxCO2eq(t,regi)$(t.val le cm_peakBudgYr) = p_taxCO2eq_until2150(t,regi); !! until peakBudgYr, take the contiuous price trajectory
    
    if (o_delay_increase_peakBudgYear(iteration) = 1,   !! if there was a flip-floping in the previous iterations, try to solve this
      display "not shifting peakBudgYr right, instead adjusting CO2 price for following year";
      loop(ttot$(ttot.val eq cm_peakBudgYr),  !! set ttot to the current peakBudgYr 
        loop(t2$(t2.val eq pm_ttot_val(ttot+1)),  !! set t2 to the following time step
          o_factorRescale_taxCO2_afterPeakBudgYr(iteration) = 1 + max(sum(regi2,vm_emiAll.l(t2,regi2,"co2"))/sum(regi2,vm_emiAll.l("2015",regi2,"co2")),-0.75) ; !! inspired by Christoph. This value is 1 if emissions are 0.
          
		  !! in case the normal linear extension still is not enough to get emissions to 0 after the peakBudgYr, shift peakBudgYr right again:
          if( ( o_reached_until2150pricepath(iteration-1) eq 1 ) AND ( (o_factorRescale_taxCO2_afterPeakBudgYr(iteration) / p_factorRescale_taxCO2_Funneled(iteration)) > 1), 
            display "price in following year reached original path and is still not enough -> shift peakBudgYr to right";
            o_delay_increase_peakBudgYear(iteration) = 0;
            o_reached_until2150pricepath(iteration) = 0;
            o_peakBudgYr_Itr(iteration+1) = t2.val;        !! shift PeakBudgYear to the following time step
            cm_peakBudgYr = o_peakBudgYr_Itr(iteration+1);
            pm_taxCO2eq(t2,regi) = p_taxCO2eq_until2150(t2,regi) ;  !! set CO2 price in t2 to value in the "continuous path"
      
            display cm_peakBudgYr;
          else      !! either didn't reach the continued "until2150"-price path in last iteration, or the increase was high enough to get emissions to 0. 
		            !! in this case, keep PeakBudgYr, and adjust the price in the year after the peakBudgYr to get emissions close to 0,
		    o_peakBudgYr_Itr(iteration+1) = o_peakBudgYr_Itr(iteration);
            pm_taxCO2eq(t2,regi) = max(pm_taxCO2eq(ttot,regi), !! at least as high as the price in the peakBudgYr
                                       pm_taxCO2eq(t2,regi) * (o_factorRescale_taxCO2_afterPeakBudgYr(iteration) / p_factorRescale_taxCO2_Funneled(iteration) ) !! the full path was already rescaled by p_factorRescale_taxCO2_Funneled, so adjust the second rescaling
                                   );
            loop(regi,                   !! this loop necessary to allow the <-comparison in the next if statement
              if( p_taxCO2eq_until2150(t2,regi) < pm_taxCO2eq(t2,regi) ,   !! check if new price would be higher than the price if the peakBudgYr would be one timestep later 
                pm_taxCO2eq(t2,regi) = p_taxCO2eq_until2150(t2,regi);
                o_reached_until2150pricepath(iteration) = 1;             !! upward CO2 price correction reached the continued price path - check in next iteration if this is high enough.  
              );
            );
          );
        
          display o_factorRescale_taxCO2_afterPeakBudgYr;
		  pm_taxCO2eq(t,regi)$(t.val gt t2.val) = pm_taxCO2eq(t2,regi) + (t.val - t2.val) * cm_taxCO2inc_after_peakBudgYr * sm_DptCO2_2_TDpGtC;  !! increase by cm_taxCO2inc_after_peakBudgYr per year
		  
        ); !! loop t2$(t2.val eq pm_ttot_val(ttot+1)),  !! set t2 to the following time step
      );  !! loop ttot$(ttot.val eq cm_peakBudgYr),  !! set ttot to the current peakBudgYr 
      cm_peakBudgYr = o_peakBudgYr_Itr(iteration+1);  !! this has to happen outside the loop, otherwise the loop condition might be true twice
    ); !! if o_delay_increase_peakBudgYear(iteration) = 1,   !! if there was a flip-floping in the previous iterations, try to solve this
	
    display o_delay_increase_peakBudgYear, o_reached_until2150pricepath, pm_taxCO2eq, o_peakBudgYr_Itr;
  ); !! if cm_emiscen eq 9,
);   !! if cm_iterative_target_adj eq 8,

***------ end of "cm_iterative_target_adj" variants-----------------------------------------


*** for having it available in next iteration, too:
s_actualbudgetco2_last = s_actualbudgetco2;

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


*GL*calculation of a bioshare for each FE carrier
*NB* the following is only relevant for reporting. As reporting is moved to R the following will be obsolete.
p_bioshare(ttot,regi,entyFe)$(sum(se2fe(entySe,entyFe,te),
								sum(pe2se(entyPe,entySe,te2), vm_prodSe.l(ttot,regi,entyPe,entySe,te2))
								+ sum(pc2te(entyPe,entySe2,te2,entySe),
									  max(0, pm_prodCouple(regi,entyPe,entySe2,te2,entySe)) * vm_prodSe.l(ttot,regi,entyPe,entySe2,te2)
									)
							) ne 0) 
  = sum(se2fe(entySe,entyFe,te),
		sum(pe2se(peBio,entySe,te2), vm_prodSe.l(ttot,regi,peBio,entySe,te2))
		+ sum(pc2te(peBio,entySe2,te2,entySe),
			  max(0, pm_prodCouple(regi,peBio,entySe2,te2,entySe)) * vm_prodSe.l(ttot,regi,peBio,entySe2,te2)
			)
    ) 
	/
	sum(se2fe(entySe,entyFe,te),
		sum(pe2se(entyPe,entySe,te2), vm_prodSe.l(ttot,regi,entyPe,entySe,te2))
		+ sum(pc2te(entyPe,entySe2,te2,entySe),
			  max(0, pm_prodCouple(regi,entyPe,entySe2,te2,entySe)) * vm_prodSe.l(ttot,regi,entyPe,entySe2,te2)
			)
    )
;

display p_bioshare;

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

* assume GDP is flat from 2150 on (only enters damage calculations in the far future)
pm_GDPGross(tall,regi)$(tall.val ge 2150) = pm_GDPGross("2149",regi); 



***------------ adjust adjustment costs for advanced vehicles according to CO2 price in the previous time step ----------------------
*** (same as in presolve - if you change it here, also change in presolve)
*** this represents the concept that with stringent climate policies (as represented by high CO2 prices), all market actors will have a clearer expectation that 
*** transport shifts to low-carbon vehicles, thus companies will be more likely to invest into new zero-carbon vehicle models, charging infrastructure, etc. 
*** Also, gov'ts will be more likely to implement additional support policies that overcome existing barriers & irrationalities and thereby facilitate deployment 
*** of advanced vehicles, e.g. infrastructure for charging, setting phase-out dates that encourage car manufacturers to develop more advanced fuel models, etc. 
*** Use the CO2 price from the previous time step to represent inertia

$iftheni.CO2priceDependent_AdjCosts %c_CO2priceDependent_AdjCosts% == "on"

loop(ttot$( (ttot.val > cm_startyear) AND (ttot.val > 2020) ),  !! only change values in the unfixed time steps of the current run, and not in the past
  loop(regi,
    if( pm_taxCO2eq(ttot-1,regi) le (40 * sm_DptCO2_2_TDpGtC) ,
	  p_varyAdj_mult_adjSeedTe(ttot,regi) = 0.1;
	  p_varyAdj_mult_adjCoeff(ttot,regi)  = 4;
    elseif ( ( pm_taxCO2eq(ttot-1,regi) gt (40 * sm_DptCO2_2_TDpGtC) ) AND ( pm_taxCO2eq(ttot-1,regi) le (80 * sm_DptCO2_2_TDpGtC) ) ) ,
      p_varyAdj_mult_adjSeedTe(ttot,regi) = 0.25;
	  p_varyAdj_mult_adjCoeff(ttot,regi)  = 2.5;
    elseif ( ( pm_taxCO2eq(ttot-1,regi) gt (80 * sm_DptCO2_2_TDpGtC) ) AND ( pm_taxCO2eq(ttot-1,regi) le (160 * sm_DptCO2_2_TDpGtC) ) ) ,
      p_varyAdj_mult_adjSeedTe(ttot,regi) = 0.5;
	  p_varyAdj_mult_adjCoeff(ttot,regi)  = 1.5;
    elseif ( ( pm_taxCO2eq(ttot-1,regi) gt (160 * sm_DptCO2_2_TDpGtC) ) AND ( pm_taxCO2eq(ttot-1,regi) le (320 * sm_DptCO2_2_TDpGtC) ) ) ,
      p_varyAdj_mult_adjSeedTe(ttot,regi) = 1;
	  p_varyAdj_mult_adjCoeff(ttot,regi)  = 1;	
    elseif ( ( pm_taxCO2eq(ttot-1,regi) gt (320 * sm_DptCO2_2_TDpGtC) ) AND ( pm_taxCO2eq(ttot-1,regi) le (640 * sm_DptCO2_2_TDpGtC) ) ) ,
      p_varyAdj_mult_adjSeedTe(ttot,regi) = 2;
	  p_varyAdj_mult_adjCoeff(ttot,regi)  = 0.5;	
	elseif ( pm_taxCO2eq(ttot-1,regi) gt (640 * sm_DptCO2_2_TDpGtC) ) ,
      p_varyAdj_mult_adjSeedTe(ttot,regi) = 4;
	  p_varyAdj_mult_adjCoeff(ttot,regi)  = 0.25;	
    );
	p_adj_seed_te(ttot,regi,'apCarH2T')        = p_varyAdj_mult_adjSeedTe(ttot,regi) * p_adj_seed_te_Orig(ttot,regi,'apCarH2T');
    p_adj_seed_te(ttot,regi,'apCarElT')        = p_varyAdj_mult_adjSeedTe(ttot,regi) * p_adj_seed_te_Orig(ttot,regi,'apCarElT');
    p_adj_seed_te(ttot,regi,'apCarDiEffT')     = p_varyAdj_mult_adjSeedTe(ttot,regi) * p_adj_seed_te_Orig(ttot,regi,'apCarDiEffT');
    p_adj_seed_te(ttot,regi,'apCarDiEffH2T')   = p_varyAdj_mult_adjSeedTe(ttot,regi) * p_adj_seed_te_Orig(ttot,regi,'apCarDiEffH2T');
    p_adj_coeff(ttot,regi,'apCarH2T')         = p_varyAdj_mult_adjCoeff(ttot,regi) * p_adj_coeff_Orig(ttot,regi,'apCarH2T') ;
    p_adj_coeff(ttot,regi,'apCarElT')         = p_varyAdj_mult_adjCoeff(ttot,regi) * p_adj_coeff_Orig(ttot,regi,'apCarElT') ;
    p_adj_coeff(ttot,regi,'apCarDiEffT')      = p_varyAdj_mult_adjCoeff(ttot,regi) * p_adj_coeff_Orig(ttot,regi,'apCarDiEffT') ;
    p_adj_coeff(ttot,regi,'apCarDiEffH2T')    = p_varyAdj_mult_adjCoeff(ttot,regi) * p_adj_coeff_Orig(ttot,regi,'apCarDiEffH2T') ;
  );
);
display p_adj_seed_te, p_adj_coeff, p_varyAdj_mult_adjSeedTe, p_varyAdj_mult_adjCoeff;

$endif.CO2priceDependent_AdjCosts
*** EOF ./core/postsolve.gms
