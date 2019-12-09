*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/15_climate/magicc/postsolve.gms

*cb 20140218 HERE goes the code for the iterative adjustment of the emission budget for SSP runs
*** emission budgets are adjusted, such that a predefined forcing target in 2100 is met
*** the actual 2100 forcing after each iteration is calculated by a magicc run started from GAMS

*** Generate MAGICC scenario file
$include "./core/magicc.gms";

* execute MAGICC (this is cheap enough, ~2s)
Execute "Rscript run_magicc.R";
* read in results
Execute "Rscript read_DAT_TOTAL_ANTHRO_RF.R";
Execute_Loadpoint 'p15_forc_magicc'  p15_forc_magicc;
Execute "Rscript read_DAT_SURFACE_TEMP.R";
Execute_Loadpoint 'p15_magicc_temp' pm_globalMeanTemperature = pm_globalMeanTemperature;
* MAGICC only reports unitl 2300:
pm_globalMeanTemperature(tall)$(tall.val gt 2300) = 0;


$ifthen.cm_magicc_calibrateTemperature2000 %cm_magicc_calibrateTemperature2000% == "HADCRUT4"
*AJS* calibrate temperature (GMT anomaly) to match HADCRUT4 in 2000. This ensures that different MAGICC configurations start at the same observed temperature.
*OLD* The HADCRUT4 offset from 1861-1880 (the SR1.5 reference period) to 1985-2015 is  0.67 degree Celsius (median).
*UPDATE* Use the 2010 offset relative to 2006-2015 reference period (AR6SR Table 2.2, footnote 1; email GL from 19122018)
s15_tempOffset2010 = sum(tall$(tall.val gt 2005 and tall.val le 2015),pm_globalMeanTemperature(tall))/10; 
display s15_tempOffset2010;
pm_globalMeanTemperature(tall) = pm_globalMeanTemperature(tall) - s15_tempOffset2010 + 0.97;
display pm_globalMeanTemperature;

*temperature convergence indicator
p15_gmt_conv = 100*smax(t,abs(pm_globalMeanTemperature(t)/max(p15_gmt0(t),1e-8) -1));
display p15_gmt_conv;
*save temp from last iteration
p15_gmt0(tall) = pm_globalMeanTemperature(tall);

$endif.cm_magicc_calibrateTemperature2000

* offset from HADCRUT4 to zero temperature in 1900, instead of the default 1870 (20 year averages each).
pm_globalMeanTemperatureZeroed1900(tall)  = pm_globalMeanTemperature(tall) + 0.092; 

* derive temperature impulse response (TIRF) from MAGICC pulse scenarios
$ifthen.cm_magicc_tirf "%cm_magicc_temperatureImpulseResponse%" == "on"
* the TIRF does not change much with emissions profile (see, e.g., figure in Schultes et al. 2017); 
* thus only compute TIRF after each of the first 10 iterations, then only every fifth iteration. 
* runtime is ca 30s, so switching on TIRF adds ca 10min to runtime
if( ((iteration.val le 10) or ( mod(iteration.val,5 ) eq 0)) ,
    execute "Rscript run_magicc_temperatureImpulseResponse.R";
    execute_loadpoint 'pm_magicc_temperatureImpulseResponse'  pm_temperatureImpulseResponseCO2 = pm_temperatureImpulseResponse;
);
*NOTE the MAGICC results (*.OUT files) are from  the last pulse experiment now, so take care if reading them in after this point.
$endif.cm_magicc_tirf

*** Iterative adjustment based on 
if (cm_iterative_target_adj eq 2, !! otherwise adjustment happens in core/postsolve.gms 
  
*** Iterative adjustment for budget runs  
  if ((cm_emiscen eq 6),
   
      display sm_budgetCO2eqGlob, s15_gr_forc_os, p15_forc_magicc;
   
      if (s15_rcpCluster eq 1,
display ' Liebe Lavinia ';
        sm_budgetCO2eqGlob 
        = 
          sm_budgetCO2eqGlob 
        * (s15_gr_forc_os       - s15_forcing_budgetiterationoffset)
        / (p15_forc_magicc("2100") - s15_forcing_budgetiterationoffset)
        ;
      
        pm_budgetCO2eq(regi)
        =
          pm_budgetCO2eq(regi)
        * (s15_gr_forc_os       - s15_forcing_budgetiterationoffset)
        / (p15_forc_magicc("2100") - s15_forcing_budgetiterationoffset)
        ;
      elseif (s15_rcpCluster eq 0),
        sm_budgetCO2eqGlob 
        = 
          sm_budgetCO2eqGlob 
        * (s15_gr_forc_nte       - s15_forcing_budgetiterationoffset)
        / (smax(tall,p15_forc_magicc(tall)) - s15_forcing_budgetiterationoffset)
        ;
      
        pm_budgetCO2eq(regi)
        =
          pm_budgetCO2eq(regi)
        * (s15_gr_forc_nte       - s15_forcing_budgetiterationoffset)
        / (smax(tall,p15_forc_magicc(tall)) - s15_forcing_budgetiterationoffset)
        ;
       );
   
     display sm_budgetCO2eqGlob;
     );

*** Iterative adjustments for tax runs
  if (cm_emiscen eq 9, 
  
    display pm_taxCO2eq, s15_gr_forc_os, p15_forc_magicc;
  
    if (s15_rcpCluster eq 1,
       pm_taxCO2eq(t,regi)
       = 
         pm_taxCO2eq(t,regi)
       * ((p15_forc_magicc("2100") - s15_forcing_budgetiterationoffset_tax - max(0,(cm_startyear-2020)/20))
       / (s15_gr_forc_os       - s15_forcing_budgetiterationoffset_tax - max(0,(cm_startyear-2020)/20)))**1.2
       ;
     
     elseif (s15_rcpCluster eq 0),
       pm_taxCO2eq(t,regi)
       = 
         pm_taxCO2eq(t,regi) 
       * ((smax(tall,p15_forc_magicc(tall)) - s15_forcing_budgetiterationoffset_tax - max(0,(cm_startyear-2020)/20))
       / (s15_gr_forc_nte       - s15_forcing_budgetiterationoffset_tax - max(0,(cm_startyear-2020)/20)))**1.2
       ;
      );
    pm_taxCO2eq(t,regi)$(t.val gt 2110) = pm_taxCO2eq("2110",regi); !! to prevent huge taxes after 2110 and the resulting convergence problems, set taxes after 2110 equal to 2110 value
    display pm_taxCO2eq;
    );
);
*** EOF ./modules/15_climate/magicc/postsolve.gms
