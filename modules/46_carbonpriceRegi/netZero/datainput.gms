*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/46_carbonpriceRegi/netZero/datainput.gms

if(not (cm_multigasscen = 2),
  abort "Error: module 46 netZero requires cm_multigasscen = 2, because all pledges include all GHG emissions including LULUCF";
);

if(sum(regi $ sameAs(regi,"EUR"),1) = 0,
  abort "Error: module 46 netZero only works with the H12 regions including EUR.";
);


*' For each region, define its net-zero target year and emission coverage for a certain set of gas species.
*' The coverage reduces if not all countries in the region have a target, and if targets exlude certain emissions.
*' Coverage shares are calculated using PBL's Net-Zero Calculator based on https://zerotracker.net/
*' (methodology and more information at https://zerotracker.net/methodology) and further
*' adaptations based on Climate Action Tracker information, literature or expert opinion.
*' Net-zero claculator "ELEVATE T6.3 Scenario Protocol NDC and LTS information v3.xlsx"
*' "The current CPDB is informed by the annual update cycle for 2025. It contains policies adopted up to and including March 2025." Luka (NCI)
*** The current protocol includes policies until March 2025 (see https://github.com/NewClimateInstitute/policy-modelling/issues/6#event-22523859766)
*' CO2 targets of Countries that are represented by a native REMIND region follow it directly instead of using PBL's coverage shares.
parameter
p46_netZeroTargetCoverage(all_regi,ttot,targetSpecies) "Coverage of emissions in net-zero targets for a given region, year and gas species [1]" /
  CAZ . 2050 . GHG_target  1
  EUR . 2050 . GHG_target  1
  JPN . 2050 . GHG_target  1
  LAM . 2050 . GHG_target  0.83

  MEA . 2055 . GHG_target  0.41
  NEU . 2055 . GHG_target  0.8
  OAS . 2055 . GHG_target  0.86
  SSA . 2055 . GHG_target  0.56

  CHA . 2060 . CO2_target  1 !! CO2 target of China
  REF . 2060 . GHG_target  0.87

  IND . 2070 . CO2_target  1 !! CO2 target of India
/;

pm_taxCO2eqRegi(ttot,regi) = 0;

*** EOF ./modules/46_carbonpriceRegi/netZero/datainput.gms
