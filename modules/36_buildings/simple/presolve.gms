*** Initialize climate correction factors to 1.0
*** - Always if climate correction is off
*** - In first iteration if climate correction is on
if(iteration.val eq 1 OR sameas("%cm_climateCorrection%","off"),
  pm_climateCorrection(ttot,all_regi,ppfen_buildings_dyn36) = 1.0;
);