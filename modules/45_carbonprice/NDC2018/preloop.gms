*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/NDC2018/preloop.gms

*CB* special case SSA: maximum carbon price (after adjustment below) at 7.5$ in 2020, 30 in 2025, 45 in 2030, to reflect low energy productivity of region, and avoid high losses
pm_taxCO2eq("2020",regi)$(sameas(regi,"SSA")) = 15 * sm_DptCO2_2_TDpGtC;

*CB* calculate tax path until 2030 - linear increase
pm_taxCO2eq(ttot,regi)$(ttot.val gt 2016 AND ttot.val le 2030) = pm_taxCO2eq("2020",regi)*(ttot.val-2015)/5;

*** convergence scheme post 2030: exponential increase with 1.25% AND regional convergence
pm_taxCO2eq(ttot,regi)$(ttot.val gt 2030) = (pm_taxCO2eq("2030",regi)*1.0125**(ttot.val-2030)*max(70-ttot.val+2030,0) + 30 * sm_DptCO2_2_TDpGtC * 1.0125**(ttot.val-2030)*min(ttot.val-2030,70))/70;
***special case USA: already after 2025 shift to convergence
pm_taxCO2eq(ttot,regi_2025target)$(ttot.val gt 2025) = (pm_taxCO2eq("2025",regi_2025target)*1.0125**(ttot.val-2025)*max(75-ttot.val+2025,0) + 30 * sm_DptCO2_2_TDpGtC * 1.0125**(ttot.val-2030)*min(ttot.val-2025,75))/75;
***as a minimum, have linear price increase starting from 1$ in 2030
pm_taxCO2eq(ttot,regi)$(ttot.val gt 2030) = max(pm_taxCO2eq(ttot,regi),1*sm_DptCO2_2_TDpGtC * (1+(ttot.val-2030)*9/7));
*** exception for China to meet the target of 2030 peak: linear increase starts already in 2025
pm_taxCO2eq(ttot,regi)$(ttot.val gt 2025 AND (sameas(regi,"CHN") OR sameas(regi,"CHA"))) = max(pm_taxCO2eq(ttot,regi),1*sm_DptCO2_2_TDpGtC * (1+(ttot.val-2025)*9/7));

*** new 2020 carbon price definition: weighted average of 2015 and 2025, with triple weight for 2015 (which is zero for all non-eu regions).
pm_taxCO2eq("2020",regi) = (3*pm_taxCO2eq("2015",regi)+pm_taxCO2eq("2025",regi))/4;


*#' @equations 
*#'  calculate level of emission target that it should converge to, two types of targets
*#'  emission target relative to 2005 emissions (target multiplier)
*#'  emission target relative to baseline emissions (baseline multiplier)
p45_ref_co2eq_woLU_regi(regi_2030target) = p45_BAU_reg_emi_wo_LU_bunkers("2005",regi_2030target) !!calculation: 2005 times multiplier, calculated as weighted average of                                             
											* (!! target multiplier 
                                               p45_2005share_target("2030",regi_2030target,"%cm_GDPscen%") 
                                               * p45_factor_targetyear("2030",regi_2030target,"%cm_GDPscen%")
											   !! and baseline multiplier
    										   + (1-p45_2005share_target("2030",regi_2030target,"%cm_GDPscen%")) 
                                                 *  p45_BAU_reg_emi_wo_LU_bunkers("2030",regi_2030target) 
                                                 /  p45_BAU_reg_emi_wo_LU_bunkers("2005",regi_2030target)
                                            );

p45_ref_co2eq_woLU_regi(regi_2025target) = p45_BAU_reg_emi_wo_LU_bunkers("2005",regi_2025target) !!calculation: 2005 times multiplier, calculated as weighted average of 
											* ( !! target multiplier 
                                               p45_2005share_target("2025",regi_2025target,"%cm_GDPscen%") 
                                               * p45_factor_targetyear("2025",regi_2025target,"%cm_GDPscen%")
											   !! and baseline multiplier
											+ (1-p45_2005share_target("2025",regi_2025target,"%cm_GDPscen%")) 
                                              * p45_BAU_reg_emi_wo_LU_bunkers("2025",regi_2025target)
                                              / p45_BAU_reg_emi_wo_LU_bunkers("2005",regi_2025target)
                                            );

	 
display pm_taxCO2eq,p45_ref_co2eq_woLU_regi,regi_2025target,regi_2030target;
*** EOF ./modules/45_carbonprice/NDC2018/preloop.gms
