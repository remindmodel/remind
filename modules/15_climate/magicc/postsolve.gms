*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/15_climate/magicc/postsolve.gms

***---------------------------------------------------------------------------
*' HERE goes the code for the iterative adjustment of the emission budget for SSP runs
*' emission budgets are adjusted, such that a predefined forcing target in 2100 is met
*' the actual 2100 forcing after each iteration is calculated by a magicc run started from GAMS
***---------------------------------------------------------------------------
*' @code
*** Generate MAGICC scenario file
$include "./core/magicc.gms";
*** execute MAGICC (this is cheap enough, ~2s)
Execute "Rscript run_magicc.R";
*** read in results
Execute "Rscript read_DAT_TOTAL_ANTHRO_RF.R";
Execute_Loadpoint 'p15_forc_magicc'  p15_forc_magicc;
Execute "Rscript read_DAT_SURFACE_TEMP.R";
Execute_Loadpoint 'p15_magicc_temp' pm_globalMeanTemperature = pm_globalMeanTemperature;
*** MAGICC only reports unitl 2300:
pm_globalMeanTemperature(tall)$(tall.val gt 2300) = 0;

***---------------------------------------------------------------------------
*' calibrate temperature (GMT anomaly) to match HADCRUT4 in 2000. 
*' This ensures that different MAGICC configurations start at the same observed temperature.
***---------------------------------------------------------------------------
$ifthen.cm_magicc_calibrateTemperature2000 %cm_magicc_calibrateTemperature2000% == "HADCRUT4"

***---------------------------------------------------------------------------
*' Calibrate temperature such that anomaly in 2006-2015 reference period is 0.97 (SR1.5 Table 2.2, footnote 1)
***---------------------------------------------------------------------------
s15_tempOffset2010 = sum(tall$(tall.val gt 2005 and tall.val le 2015),pm_globalMeanTemperature(tall))/10; 
display s15_tempOffset2010;
pm_globalMeanTemperature(tall) = pm_globalMeanTemperature(tall) - s15_tempOffset2010 + 0.97;
display pm_globalMeanTemperature;

*** temperature convergence indicator
p15_gmt_conv = 100*smax(t,abs(pm_globalMeanTemperature(t)/max(p15_gmt0(t),1e-8) -1));
display p15_gmt_conv;
*** save temp from last iteration
p15_gmt0(tall) = pm_globalMeanTemperature(tall);

$endif.cm_magicc_calibrateTemperature2000

*** offset from HADCRUT4 to zero temperature in 1900, instead of the default 1870 (20 year averages each).
pm_globalMeanTemperatureZeroed1900(tall)  = pm_globalMeanTemperature(tall) + 0.092; 

*** derive temperature impulse response (TIRF) from MAGICC pulse scenarios
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

***---------------------------------------------------------------------------
*' Iterative adjustment of budgets or carbon taxes to meet forcing target 
***---------------------------------------------------------------------------
if (cm_iterative_target_adj eq 2, !! otherwise adjustment happens in core/postsolve.gms 
  
***---------------------------------------------------------------------------
*' Iterative adjustment for budget runs: scale current budget with the ratio of target forcing s15_gr_forc_os to current forcing p15_forc_magicc.
*' The offset is only there to increase the speed of convergence, the values have no physical meaning.
*' For low stabilization targets (rcp2.0, rcp2.6, rcp3.7) the target is the 2100 forcing target (s15_rcpCluster eq 1),
*' for lower targets the forcing target is valid during the full century (s15_rcpCluster eq 0).
***---------------------------------------------------------------------------
  if ((cm_emiscen eq 6),
   
      display sm_budgetCO2eqGlob, s15_gr_forc_os, p15_forc_magicc;
   
      if (s15_rcpCluster eq 1,
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

***---------------------------------------------------------------------------
*' Iterative adjustment for carbon tax runs: scale current tax pathway with the ratio of target forcing s15_gr_forc_os to current forcing p15_forc_magicc.
*' The offset is only there to increase the speed of convergence, the values have no physical meaning.
*' For low stabilization targets (rcp2.0, rcp2.6, rcp3.7) the target is the 2100 forcing target (s15_rcpCluster eq 1),
*' for lower targets the forcing target is valid during the full century (s15_rcpCluster eq 0).
***---------------------------------------------------------------------------
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
*' @stop
*** EOF ./modules/15_climate/magicc/postsolve.gms
