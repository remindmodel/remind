*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/36_buildings/simple/postsolve.gms

*** calculation of FE Buildings Prices (useful for internal use and reporting purposes)
pm_FEPrice(ttot,regi,entyFe,"build",emiMkt)$(abs(qm_budget.m(ttot,regi)) gt sm_eps) =
  q36_demFeBuild.m(ttot,regi,entyFe,emiMkt)
  / qm_budget.m(ttot,regi);

*** Climate correction handling
*** Only run climate assessment from iteration 2 onwards to ensure all postsolve calculations are complete
*** (reportEmiForClimateAssessment requires industry variables calculated in module 37)
$ifthen.climateCorr not "%cm_climateCorrection%" == "off"
if(iteration.val gt 1,

Execute_Unload 'fulldata_postsolve';

*** Execute climate assessment script
Execute "Rscript climateAssessmentInterimRun.R";

*** Call R script to calculate climate correction factors
Execute "Rscript calculateClimateCorrection.R";

*** Load climate correction factors
execute_load "pm_ClimateCorrection.gdx", pm_climateCorrection;

);
$endif.climateCorr

*** EOF ./modules/36_buildings/simple/postsolve.gms
