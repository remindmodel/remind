*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/NDC/postsolve.gms
if(cm_iterative_target_adj eq 3, 

		display pm_taxCO2eq;
		
		



*#' @equations 
*#' calculate emission variable to be used for NDC target: GHG emissions w/o land-use change and w/o transport bunker emissions, unit [Mt CO2eq/yr]
p45_actual_co2eq_woLU_regi(regi_2030target) = 
	vm_co2eq.l("2030",regi_2030target)*sm_c_2_co2*1000
*** add F-Gases
	+ vm_emiFgas.L("2030",regi_2030target,"emiFgasTotal") 
*** substract bunker emissions
	- sum(se2fe(enty,enty2,te),
        pm_emifac("2030",regi_2030target,enty,enty2,te,"co2")
        * vm_demFeSector.l("2030",regi_2030target,enty,enty2,"trans","other")*sm_c_2_co2*1000
    )
; 


*#' special case: US target refers to 2025
p45_actual_co2eq_woLU_regi(regi_2025target) = 
	vm_co2eq.l("2025",regi_2025target)*sm_c_2_co2*1000
*** add F-Gases
	+ vm_emiFgas.L("2025",regi_2025target,"emiFgasTotal") 
*** substract bunker emissions
	- sum(se2fe(enty,enty2,te),
        pm_emifac("2025",regi_2025target,enty,enty2,te,"co2")
        * vm_demFeSector.l("2025",regi_2025target,enty,enty2,"trans","other")*sm_c_2_co2*1000
    )
; 

display vm_co2eq.l;
display p45_actual_co2eq_woLU_regi;
display p45_ref_co2eq_woLU_regi;
		
*#' nash compatible convergence scheme: adjustment of co2 tax for next iteration based on deviation of emissions in this iteration (actual) from target emissions (ref)
*#' maximum possible change between iterations decreases with increase of iteration number
if(iteration.val lt 8,  
 p45_factorRescaleCO2Tax(regi) = min((( max(0.1, p45_actual_co2eq_woLU_regi(regi)/p45_ref_co2eq_woLU_regi(regi) ) )** 4),max(2-iteration.val/15,1.01-iteration.val/10000)); !! use max(0.1, ...) to make sure that negative emission values cause no problem
elseif iteration.val lt 15,
 p45_factorRescaleCO2Tax(regi) = min((( max(0.1, p45_actual_co2eq_woLU_regi(regi)/p45_ref_co2eq_woLU_regi(regi) ) )**3),max(2-iteration.val/15,1.01-iteration.val/10000));
elseif iteration.val lt 23,
 p45_factorRescaleCO2Tax(regi) = min((( max(0.1, p45_actual_co2eq_woLU_regi(regi)/p45_ref_co2eq_woLU_regi(regi) ) )**2),max(2-iteration.val/15,1.01-iteration.val/10000));
else
 p45_factorRescaleCO2Tax(regi) = min((( max(0.1, p45_actual_co2eq_woLU_regi(regi)/p45_ref_co2eq_woLU_regi(regi) ) )**1),max(2-iteration.val/15,1.01-iteration.val/10000));
); 

pm_taxCO2eq(t,regi)$(t.val gt 2016 AND t.val ge cm_startyear AND t.val lt 2031) = max(1* sm_DptCO2_2_TDpGtC,pm_taxCO2eq(t,regi) * p45_factorRescaleCO2Tax(regi) );
p45_factorRescaleCO2TaxTrack(iteration,regi) = p45_factorRescaleCO2Tax(regi);

display p45_factorRescaleCO2TaxTrack;

***carbon price safety valve for low-income and lower-middle income regions: max 1/4 of EUR carbon price
***pm_taxCO2eq(t,"IND")$(t.val gt 2014 AND t.val lt 2036) = min(pm_taxCO2eq(t,"IND"),0.25*pm_taxCO2eq(t,"EUR"));
***pm_taxCO2eq(t,"AFR")$(t.val gt 2014 AND t.val lt 2036) = min(pm_taxCO2eq(t,"AFR"),0.25*pm_taxCO2eq(t,"EUR"));
****** regions with some low-income or lower-middle income regions: max 50%                                                 
***pm_taxCO2eq(t,"LAM")$(t.val gt 2014 AND t.val lt 2036) = min(pm_taxCO2eq(t,"LAM"),0.5*pm_taxCO2eq(t,"EUR"));
***pm_taxCO2eq(t,"MEA")$(t.val gt 2014 AND t.val lt 2036) = min(pm_taxCO2eq(t,"MEA"),0.5*pm_taxCO2eq(t,"EUR"));
***pm_taxCO2eq(t,"OAS")$(t.val gt 2014 AND t.val lt 2036) = min(pm_taxCO2eq(t,"OAS"),0.5*pm_taxCO2eq(t,"EUR"));
***new hard-coded safety valve for SSA: 7.5$ in 2005, 30 in 2025, 45 in 2030
*CB* special case SSA: maximum carbon price at 7.5$ in 2020, 30 in 2025, 45 in 2030, to reflect low energy productivity of region, and avoid high losses
pm_taxCO2eq("2020",regi)$(sameas(regi,"SSA")) = min(pm_taxCO2eq("2020",regi)$(sameas(regi,"SSA")),7.5 * sm_DptCO2_2_TDpGtC);
pm_taxCO2eq("2025",regi)$(sameas(regi,"SSA")) = min(pm_taxCO2eq("2025",regi)$(sameas(regi,"SSA")),30 * sm_DptCO2_2_TDpGtC);
pm_taxCO2eq("2030",regi)$(sameas(regi,"SSA")) = min(pm_taxCO2eq("2030",regi)$(sameas(regi,"SSA")),45 * sm_DptCO2_2_TDpGtC);

*#' convergence scheme post 2030: exponential increase with 1.25% AND regional convergence
pm_taxCO2eq(ttot,regi)$(ttot.val gt 2030) = (pm_taxCO2eq("2030",regi)*1.0125**(ttot.val-2030)*max(70-ttot.val+2030,0) + 30 * sm_DptCO2_2_TDpGtC * 1.0125**(ttot.val-2030)*min(ttot.val-2030,70))/70;
*#'special case USA: already after 2025 shift to convergence
pm_taxCO2eq(ttot,regi_2025target)$(ttot.val gt 2025) = (pm_taxCO2eq("2025",regi_2025target)*1.0125**(ttot.val-2025)*max(75-ttot.val+2025,0) + 30 * sm_DptCO2_2_TDpGtC * 1.0125**(ttot.val-2030)*min(ttot.val-2025,75))/75;
*#'as a minimum, have linear price increase starting from 1$ in 2030
pm_taxCO2eq(ttot,regi)$(ttot.val gt 2030) = max(pm_taxCO2eq(ttot,regi),1*sm_DptCO2_2_TDpGtC * (1+(ttot.val-2030)*9/7));
*#' exception for China to meet the target of 2030 peak: linear increase starts already in 2025
pm_taxCO2eq(ttot,regi)$(ttot.val gt 2025 AND (sameas(regi,"CHN") OR sameas(regi,"CHA"))) = max(pm_taxCO2eq(ttot,regi),1*sm_DptCO2_2_TDpGtC * (1+(ttot.val-2025)*9/7));

*** new 2020 carbon price definition: weighted average of 2015 and 2025, with triple weight for 2015 (which is zero for all non-eu regions).
pm_taxCO2eq("2020",regi) = (3*pm_taxCO2eq("2015",regi)+pm_taxCO2eq("2025",regi))/4;

***
******special treatment for 2020 (not relevant if cm_startyear for NDC scenario is 2020, but relevant if earlier)
***pm_taxCO2eq("2020","EUR") = 5 * sm_DptCO2_2_TDpGtC;
***pm_taxCO2eq("2020","USA") = 3 * sm_DptCO2_2_TDpGtC;
***pm_taxCO2eq("2020","JPN") = 3 * sm_DptCO2_2_TDpGtC;
***pm_taxCO2eq("2020","ROW") = 3 * sm_DptCO2_2_TDpGtC;
***pm_taxCO2eq("2020","CHN") = 1 * sm_DptCO2_2_TDpGtC;
***pm_taxCO2eq("2020","IND") = 0.5 * sm_DptCO2_2_TDpGtC;
***pm_taxCO2eq("2020","LAM") = 0.5 * sm_DptCO2_2_TDpGtC;
***pm_taxCO2eq("2020","OAS") = 0.5 * sm_DptCO2_2_TDpGtC;
***pm_taxCO2eq("2020","AFR") = 0.5 * sm_DptCO2_2_TDpGtC;
***pm_taxCO2eq("2020","MEA") = 0.5 * sm_DptCO2_2_TDpGtC;
***pm_taxCO2eq("2020","RUS") = 0.5 * sm_DptCO2_2_TDpGtC;


		display pm_taxCO2eq;
);
*** EOF ./modules/45_carbonprice/NDC/postsolve.gms
