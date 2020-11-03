*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/70_water/heat/datainput.gms
***-------------------------------------------------------------------------------
*** *IM*2015-05-14* Definition of exogenous data 
***-------------------------------------------------------------------------------

***------------*Define data*------------------------------------------------------
*---------------------------------------------------------------------------------
parameter i70_water_con(all_te, coolte70)				"water consumption coefficients"
 /
$ondelim
$include "./modules/70_water/heat/input/WaterConsCoef.cs4r"
$offdelim
/;

parameter i70_water_wtd(all_te, coolte70)				"water withdrawal coefficients"
 /
$ondelim
$include "./modules/70_water/heat/input/WaterWithCoef.cs4r"
$offdelim
 /;

parameter i70_cool_share_time(ttot2, all_regi, all_te, coolte70)	"cooling shares"
/
$ondelim
$include "./modules/70_water/heat/input/CoolingShares_time.cs4r"
$offdelim
/; 

***------------*Assign data*------------------------------------------------------
*---------------------------------------------------------------------------------
$ifthen "%cm_cooling_shares%" == "static" 
i70_cool_share_time(ttot2,regi,te_elcool70,coolte70) = i70_cool_share_time("2005",regi,te_elcool70,coolte70);
$elseif "%cm_cooling_shares%" == "dynamic"
i70_cool_share_time(ttot2,regi,te_elcool70,coolte70)$(ttot2.val lt 2020) = i70_cool_share_time("2005",regi,te_elcool70,coolte70);
i70_cool_share_time(ttot2,regi,te_elcool70,coolte70)$(ttot2.val ge 2020) = i70_cool_share_time("2020",regi,te_elcool70,coolte70);  
$endif

i70_efficiency(ttot,regi,te_elcool70,coolte70) = 1;

i70_losses(te_elcool70)$(te_stack70(te_elcool70)) = 0.1;

*** EOF ./modules/70_water/heat/datainput.gms
