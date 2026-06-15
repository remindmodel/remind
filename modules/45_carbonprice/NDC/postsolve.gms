*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/NDC/postsolve.gms


display pm_taxCO2eq;

*#' @equations 
*#' calculate emission variable to be used for NDC target: GHG emissions w/o land-use change and w/o transport bunker emissions, unit [Mt CO2eq/yr]
p45_CO2eqwoLU_actual(p45_NDCyearSet(t,regi)) =
    vm_co2eq.l(t,regi) * sm_c_2_co2*1000
*** add F-Gases
    + vm_emiFgas.L(t,regi,"emiFgasTotal")
*** substract bunker emissions
    - sum(se2fe(enty,enty2,te),
        pm_emifac(t,regi,enty,enty2,te,"co2")
        * vm_demFeSector.l(t,regi,enty,enty2,"trans","other") * sm_c_2_co2 * 1000
      ); 

pm_taxCO2eq_iter(iteration,p45_NDCyearSet(t,regi)) = pm_taxCO2eq(t,regi);
p45_CO2eqwoLU_actual_iter(iteration,p45_NDCyearSet(t,regi)) = p45_CO2eqwoLU_actual(t,regi);

*** calculate relative deviation of actual emissions from target emissions
** as measure how close we are to reaching NDC emissions target
pm_NDCEmiTargetDeviation(p45_NDCyearSet(t,regi)) = (p45_CO2eqwoLU_goal(t,regi) - p45_CO2eqwoLU_actual(t,regi)) / p45_CO2eqwoLU_goal(t,regi);

display vm_co2eq.l;
display p45_CO2eqwoLU_actual;
display p45_CO2eqwoLU_goal;

*#' nash compatible convergence scheme: adjustment of co2 tax for next iteration based on deviation of emissions in this iteration (actual) from target emissions (ref)
*#' maximum possible change between iterations decreases with increase of iteration number

if(       iteration.val lt  8, p45_adjustExponent = 4;
   elseif iteration.val lt 15, p45_adjustExponent = 3;
   elseif iteration.val lt 23, p45_adjustExponent = 2;
   else                        p45_adjustExponent = 1;
);

p45_factorRescaleCO2Tax(p45_NDCyearSet(t,regi)) =
  ( (p45_CO2eqwoLU_actual(t,regi)+0.0001)/(p45_CO2eqwoLU_goal(t,regi)+0.0001) )**p45_adjustExponent;

p45_factorRescaleCO2TaxLtd(p45_NDCyearSet(t,regi)) =
  min(max(0.1**p45_adjustExponent, p45_factorRescaleCO2Tax(t,regi)), max(2-iteration.val/15,1.01-iteration.val/10000));
*** use max(0.1, ...) to make sure that negative emission values cause no problem, use +0.0001 such that net zero targets cause no problem

pm_taxCO2eq(t,regi)$(t.val gt 2021 AND t.val le p45_lastNDCyear(regi)) = max(1* sm_DptCO2_2_TDpGtC,pm_taxCO2eq(t,regi) * p45_factorRescaleCO2TaxLtd(t,regi) );

p45_factorRescaleCO2Tax_iter(iteration,t,regi) = p45_factorRescaleCO2Tax(t,regi);
p45_factorRescaleCO2TaxLtd_iter(iteration,t,regi) = p45_factorRescaleCO2TaxLtd(t,regi);

display p45_factorRescaleCO2TaxLtd_iter;


$ifThen.cm_NDC_CO2PriceLimit not "%cm_NDC_CO2PriceLimit%" == "off"
*** limit CO2 prices in NDC realization according to switch cm_NDC_CO2PriceLimit
  loop( p45_NDCyearSet(t,regi)$( p45_CO2PriceLimitNDC(t,regi) > 0 ) ,
    pm_taxCO2eq(t,regi) = min(    pm_taxCO2eq(t,regi), 
                                  p45_CO2PriceLimitNDC(t,regi) * sm_DptCO2_2_TDpGtC );
$ifThen.cm_NDC_CO2PriceLimit_continuation not "%cm_NDC_CO2PriceLimit_continuation%" == "off"
*** For the periods after the carbon price limit:
*** If this switch is on, limit increase by 20%/yr, but ensure the CO2 price limit (cap) is at least 200$/tCO2.
    pm_taxCO2eq(t2,regi)$( t2.val gt t.val) = min(    pm_taxCO2eq(t2,regi), 
                                                      max(  p45_CO2PriceLimitNDC(t,regi) * (1 + 0.2 * (t2.val - t.val)) * sm_DptCO2_2_TDpGtC,
                                                               200 * sm_DptCO2_2_TDpGtC
                                                      )  
                                                  );
$endif.cm_NDC_CO2PriceLimit_continuation
  );
$endif.cm_NDC_CO2PriceLimit

*** calculate tax path until NDC target year - linear increase
p45_taxCO2eqFirstNDCyear(regi) = smax(t$(t.val = p45_firstNDCyear(regi)), pm_taxCO2eq(t,regi));
pm_taxCO2eq(t,regi)$(t.val > 2021 AND t.val < p45_firstNDCyear(regi)) = (p45_taxCO2eqFirstNDCyear(regi) - pm_taxCO2eq("2020",regi))*(t.val-2020)/(p45_firstNDCyear(regi)-2020) + pm_taxCO2eq("2020",regi);

*** replace taxCO2eq between NDC targets such that taxCO2eq between goals does not decrease
loop( p45_NDCyearSet(t2,regi) ,
  pm_taxCO2eq(t,regi)$(t.val > t2.val AND not p45_NDCyearSet(t,regi)) = pm_taxCO2eq(t2,regi);
) ;


*** post-NDC target year development of CO2 price depends on switch cm_NDC_postTargetDevelopment
$ifThen.cm_NDC_postTargetDevelopment "%cm_NDC_postTargetDevelopment%" == "constant"
loop(regi,
  loop( t2$( t2.val eq p45_lastNDCyear(regi) ) ,
    pm_taxCO2eq(t,regi)$(t.val gt t2.val) = pm_taxCO2eq(t2,regi);
  );
);
$elseif.cm_NDC_postTargetDevelopment "%cm_NDC_postTargetDevelopment%" == "global_conv"
*** set carbon price to 100$/tCO2 from 2100
pm_taxCO2eq(t,regi)$( t.val ge 2100) = 100 * sm_DptCO2_2_TDpGtC;
*** linearly converge from carbon price of last NDC target year to 100$/tCO2 in 2100 for all regions
loop(regi,
  loop( t2$( t2.val eq p45_lastNDCyear(regi) ) ,
    pm_taxCO2eq(t,regi)$(t.val gt t2.val AND t.val le 2100) = pm_taxCO2eq(t2,regi) 
                                                              + (pm_taxCO2eq("2100",regi)-pm_taxCO2eq(t2,regi)) 
                                                                * (t.val - t2.val) 
                                                                / (2100 - t2.val);
  );
);
$endif.cm_NDC_postTargetDevelopment

*** apply assumption about minimum CO2 price according to switch cm_NDC_CO2PriceMinimum
$ifThen.cm_NDC_CO2PriceMinimum "%cm_NDC_CO2PriceMinimum%" == "zero"
*** no minimum CO2 price after first NDC target year, i.e. CO2 price can decrease to zero after first NDC target year, so do nothing
$elseif.cm_NDC_CO2PriceMinimum "%cm_NDC_CO2PriceMinimum%" == "NPi"
*** CO2 price cannot fall below carbon price of NPi run as this represents the development of current policies
*** CO2 Price of NPi stored in p45_taxCO2eq_bau
pm_taxCO2eq(t,regi) = max(  pm_taxCO2eq(t,regi),
                            p45_taxCO2eq_bau(t,regi)  );
$elseif.cm_NDC_CO2PriceMinimum "%cm_NDC_CO2PriceMinimum%" == "NonDecreasing"
*** CO2 price cannot decrease after first NDC target year, but can increase or remain constant
loop(regi,
  loop( t2$( t2.val eq p45_lastNDCyear(regi) ) ,
    pm_taxCO2eq(t,regi)$(t.val gt t2.val) = max(  pm_taxCO2eq(t,regi), 
                                                  pm_taxCO2eq(t2,regi)  );
  );
);
$endif.cm_NDC_CO2PriceMinimum

display pm_taxCO2eq;


*** EOF ./modules/45_carbonprice/NDC/postsolve.gms
