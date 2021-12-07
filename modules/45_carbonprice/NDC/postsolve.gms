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
p45_actual_co2eq_woLU_regi(p45_NDC_year_set(ttot,regi)) =
    vm_co2eq.l(ttot,regi) * sm_c_2_co2*1000
*** add F-Gases
    + vm_emiFgas.L(ttot,regi,"emiFgasTotal")
*** substract bunker emissions
    - sum(se2fe(enty,enty2,te),
        pm_emifac(ttot,regi,enty,enty2,te,"co2")
        * vm_demFeSector.l(ttot,regi,enty,enty2,"trans","other") * sm_c_2_co2 * 1000
      ); 

display vm_co2eq.l;
display p45_actual_co2eq_woLU_regi;
display p45_ref_co2eq_woLU_regi;

*#' nash compatible convergence scheme: adjustment of co2 tax for next iteration based on deviation of emissions in this iteration (actual) from target emissions (ref)
*#' maximum possible change between iterations decreases with increase of iteration number

if(       iteration.val lt  8, p45_adjust_exponent = 4;
   elseif iteration.val lt 15, p45_adjust_exponent = 3;
   elseif iteration.val lt 23, p45_adjust_exponent = 2;
   else                        p45_adjust_exponent = 1;
);

p45_factorRescaleCO2Tax(p45_NDC_year_set(ttot,regi)) =
  min((( max(0.1, (p45_actual_co2eq_woLU_regi(ttot,regi)+0.0001)/(p45_ref_co2eq_woLU_regi(ttot,regi)+0.0001) ) )**p45_adjust_exponent),max(2-iteration.val/15,1.01-iteration.val/10000));
*** use max(0.1, ...) to make sure that negative emission values cause no problem, use +0.0001 such that net zero targets cause no problem

pm_taxCO2eq(t,regi)$(t.val gt 2016 AND t.val ge cm_startyear AND t.val le p45_last_NDC_year(regi)) = max(1* sm_DptCO2_2_TDpGtC,pm_taxCO2eq(t,regi) * p45_factorRescaleCO2Tax(t,regi) );
p45_factorRescaleCO2TaxTrack(iteration,ttot,regi) = p45_factorRescaleCO2Tax(ttot,regi);

display p45_factorRescaleCO2TaxTrack;

***carbon price safety valve for low-income and lower-middle income regions: max 1/4 of EUR carbon price
***pm_taxCO2eq(t,"IND")$(t.val gt 2014 AND t.val lt 2036) = min(pm_taxCO2eq(t,"IND"),0.25*pm_taxCO2eq(t,"EUR"));
***pm_taxCO2eq(t,"AFR")$(t.val gt 2014 AND t.val lt 2036) = min(pm_taxCO2eq(t,"AFR"),0.25*pm_taxCO2eq(t,"EUR"));
***regions with some low-income or lower-middle income regions: max 50%
***pm_taxCO2eq(t,"LAM")$(t.val gt 2014 AND t.val lt 2036) = min(pm_taxCO2eq(t,"LAM"),0.5*pm_taxCO2eq(t,"EUR"));
***pm_taxCO2eq(t,"MEA")$(t.val gt 2014 AND t.val lt 2036) = min(pm_taxCO2eq(t,"MEA"),0.5*pm_taxCO2eq(t,"EUR"));
***pm_taxCO2eq(t,"OAS")$(t.val gt 2014 AND t.val lt 2036) = min(pm_taxCO2eq(t,"OAS"),0.5*pm_taxCO2eq(t,"EUR"));
***new hard-coded safety valve for SSA: 7.5$ in 2005, 30 in 2025, 45 in 2030
*CB* special case SSA: maximum carbon price at 7.5$ in 2020, 30 in 2025, 45 in 2030, to reflect low energy productivity of region, and avoid high losses
pm_taxCO2eq("2020",regi)$(sameas(regi,"SSA")) = min(pm_taxCO2eq("2020",regi)$(sameas(regi,"SSA")),7.5 * sm_DptCO2_2_TDpGtC);
pm_taxCO2eq("2025",regi)$(sameas(regi,"SSA")) = min(pm_taxCO2eq("2025",regi)$(sameas(regi,"SSA")),30 * sm_DptCO2_2_TDpGtC);
pm_taxCO2eq("2030",regi)$(sameas(regi,"SSA")) = min(pm_taxCO2eq("2030",regi)$(sameas(regi,"SSA")),45 * sm_DptCO2_2_TDpGtC);

*** calculate tax path until NDC target year - linear increase
p45_taxCO2eq_first_NDC_year(regi) = smax(ttot$(ttot.val = p45_first_NDC_year(regi)), pm_taxCO2eq(ttot,regi));
pm_taxCO2eq(ttot,regi)$(ttot.val > 2016 AND ttot.val < p45_first_NDC_year(regi)) = p45_taxCO2eq_first_NDC_year(regi)*(ttot.val-2015)/(p45_first_NDC_year(regi)-2015);

*** replace taxCO2eq between NDC targets such that taxCO2eq between goals does not decrease
loop( p45_NDC_year_set(ttot2,regi) ,
  pm_taxCO2eq(ttot,regi)$(ttot.val > ttot2.val AND not p45_NDC_year_set(ttot,regi)) = pm_taxCO2eq(ttot2,regi);
) ;

*** convergence scheme post NDC target year: exponential increase with 1.25% AND regional convergence until p45_taxCO2eq_convergence_year
p45_taxCO2eq_last_NDC_year(regi) = smax(ttot$(ttot.val = p45_last_NDC_year(regi)), pm_taxCO2eq(ttot,regi));

pm_taxCO2eq(ttot,regi)$(ttot.val gt p45_last_NDC_year(regi))
   = (  !! regional, weight going from 1 in NDC target year to 0  in 2100
        p45_taxCO2eq_last_NDC_year(regi) * 1.0125**(ttot.val-p45_last_NDC_year(regi)) * (max(p45_taxCO2eq_convergence_year,ttot.val) - ttot.val)
        !! global, weight going from 0 in NDC target year to 1 in and after 2100
      + p45_taxCO2eq_global2030          * 1.0125**(ttot.val-2030)                    * (min(ttot.val,p45_taxCO2eq_convergence_year) - p45_last_NDC_year(regi))
      )/(p45_taxCO2eq_convergence_year - p45_last_NDC_year(regi));

***as a minimum, have linear price increase starting from 1$ in 2030
pm_taxCO2eq(ttot,regi)$(ttot.val gt 2030) = max(pm_taxCO2eq(ttot,regi),1*sm_DptCO2_2_TDpGtC * (1+(ttot.val-2030)*9/7));

*** new 2020 carbon price definition: weighted average of 2015 and 2025, with triple weight for 2015 (which is zero for all non-eu regions).
pm_taxCO2eq("2020",regi) = (3*pm_taxCO2eq("2015",regi)+pm_taxCO2eq("2025",regi))/4;

***
***special treatment for 2020 (not relevant if cm_startyear for NDC scenario is 2020, but relevant if earlier)
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
