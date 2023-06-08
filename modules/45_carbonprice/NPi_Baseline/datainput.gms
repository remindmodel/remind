*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/NPi_Baseline/datainput.gms

pm_taxCO2eq(ttot,regi)$(ttot.val lt 2020) = 0;

* rough EU ETS carbon prices for EUR and NEU regions in 2010 and 2015
* as higher prices in 2010 don't really reflect higher ambition than compared to 2015, a flat 10 $ (2005)/t CO2 seems reasonable
pm_taxCO2eq("2010",regi)$sameas(regi,"EUR")= 10;
pm_taxCO2eq("2010",regi)$sameas(regi,"DEU")= 10;
pm_taxCO2eq("2010",regi)$sameas(regi,"ECE")= 10;
pm_taxCO2eq("2010",regi)$sameas(regi,"ECS")= 10;
pm_taxCO2eq("2010",regi)$sameas(regi,"ENC")= 10;
pm_taxCO2eq("2010",regi)$sameas(regi,"ESC")= 10;
pm_taxCO2eq("2010",regi)$sameas(regi,"ESW")= 10;
pm_taxCO2eq("2010",regi)$sameas(regi,"EWN")= 10;
pm_taxCO2eq("2010",regi)$sameas(regi,"FRA")= 10;
pm_taxCO2eq("2010",regi)$sameas(regi,"UKI")= 10;
pm_taxCO2eq("2010",regi)$sameas(regi,"NEU")= 2.5;
pm_taxCO2eq("2010",regi)$sameas(regi,"NEN")= 2.5;
pm_taxCO2eq("2010",regi)$sameas(regi,"NES")= 2.5;

pm_taxCO2eq("2015",regi)$sameas(regi,"EUR")= 10;
pm_taxCO2eq("2015",regi)$sameas(regi,"DEU")= 10;
pm_taxCO2eq("2015",regi)$sameas(regi,"ECE")= 10;
pm_taxCO2eq("2015",regi)$sameas(regi,"ECS")= 10;
pm_taxCO2eq("2015",regi)$sameas(regi,"ENC")= 10;
pm_taxCO2eq("2015",regi)$sameas(regi,"ESC")= 10;
pm_taxCO2eq("2015",regi)$sameas(regi,"ESW")= 10;
pm_taxCO2eq("2015",regi)$sameas(regi,"EWN")= 10;
pm_taxCO2eq("2015",regi)$sameas(regi,"FRA")= 10;
pm_taxCO2eq("2015",regi)$sameas(regi,"UKI")= 10;
pm_taxCO2eq("2015",regi)$sameas(regi,"NEU")= 5;
pm_taxCO2eq("2015",regi)$sameas(regi,"NEN")= 5;
pm_taxCO2eq("2015",regi)$sameas(regi,"NES")= 5;

*2020 price assumptions for all regions
*EUR price oriented at a rough average price in the 2020-2022 period in the ETS

pm_taxCO2eq("2020",regi)$sameas(regi,"EUR") = 50;
pm_taxCO2eq("2020",regi)$sameas(regi,"DEU") = 50;
pm_taxCO2eq("2020",regi)$sameas(regi,"ECE") = 50;
pm_taxCO2eq("2020",regi)$sameas(regi,"ECS") = 50;
pm_taxCO2eq("2020",regi)$sameas(regi,"ENC") = 50;
pm_taxCO2eq("2020",regi)$sameas(regi,"ESC") = 50;
pm_taxCO2eq("2020",regi)$sameas(regi,"ESW") = 50;
pm_taxCO2eq("2020",regi)$sameas(regi,"EWN") = 50;
pm_taxCO2eq("2020",regi)$sameas(regi,"FRA") = 50;
pm_taxCO2eq("2020",regi)$sameas(regi,"UKI") = 50;
pm_taxCO2eq("2020",regi)$sameas(regi,"NEU") = 10;
pm_taxCO2eq("2020",regi)$sameas(regi,"NEN") = 10;
pm_taxCO2eq("2020",regi)$sameas(regi,"NES") = 10;

pm_taxCO2eq("2020",regi)$sameas(regi,"CAZ") = 20; 
pm_taxCO2eq("2020",regi)$sameas(regi,"CHA") = 5; 
pm_taxCO2eq("2020",regi)$sameas(regi,"IND") = 1; 
pm_taxCO2eq("2020",regi)$sameas(regi,"JPN") = 15; 
pm_taxCO2eq("2020",regi)$sameas(regi,"LAM") = 10; 
pm_taxCO2eq("2020",regi)$sameas(regi,"MEA") = 2.5; 
pm_taxCO2eq("2020",regi)$sameas(regi,"OAS") = 5; 
pm_taxCO2eq("2020",regi)$sameas(regi,"REF") = 2.5; 
pm_taxCO2eq("2020",regi)$sameas(regi,"SSA") = 1; 
pm_taxCO2eq("2020",regi)$sameas(regi,"USA") = 20;


*** convergence scheme post 2020: exponential increase of 5$ dollar in 2020with 1.25% AND regional convergence
pm_taxCO2eq(ttot,regi)$(ttot.val ge 2025) =
  (pm_taxCO2eq("2020",regi)*max(2100-2020-ttot.val+cm_startyear,0)
  + 5 * sm_DptCO2_2_TDpGtC * 1.0125**(ttot.val-2025)*min(ttot.val-2025,2100-2025))/(2100-2025);

display pm_taxCO2eq;
*** EOF ./modules/45_carbonprice/NPi_Baseline/datainput.gms
