*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/50_damages/Labor/datainput.gms

*satisfy dependencies
$ifi not %downscaleTemperature% == 'CMIP5' abort "module damages=Labor requires downscaleTemperature=CMIP5";

p50_damageFuncCoef1(regi) = 0;
p50_damageFuncCoef2(regi) = 0;

* Dasgupta et al. 2021, global value, low exposure
$ifi %cm_damage_Labor_exposure% == "low" p50_damageFuncCoef1(regi) = 0.079;
$ifi %cm_damage_Labor_exposure% == "low" p50_damageFuncCoef2(regi) = -0.002;

* Dasgupta et al. 2021, global value, high exposure
$ifi %cm_damage_Labor_exposure% == "high" p50_damageFuncCoef1(regi) = 0.157;
$ifi %cm_damage_Labor_exposure% == "high" p50_damageFuncCoef2(regi) = -0.005;

* coefficients estimated specifically for REMIND regions (private communication with Shouro Dasgupta, CMCC)
* for CAZ the regression was not significant - we can set it to zero or use the global value for now
$ifi %cm_damage_Labor_exposure% == "remind" p50_damageFuncCoef1("CAZ") = 0;
$ifi %cm_damage_Labor_exposure% == "remind" p50_damageFuncCoef1("CHA") = 0.1034222;
$ifi %cm_damage_Labor_exposure% == "remind" p50_damageFuncCoef1("EUR") = 0.062799;
$ifi %cm_damage_Labor_exposure% == "remind" p50_damageFuncCoef1("IND") = 0.1718675;
$ifi %cm_damage_Labor_exposure% == "remind" p50_damageFuncCoef1("JPN") = 0.1209185;
$ifi %cm_damage_Labor_exposure% == "remind" p50_damageFuncCoef1("LAM") = 0.0895132;
$ifi %cm_damage_Labor_exposure% == "remind" p50_damageFuncCoef1("MEA") = 0.0885284;
$ifi %cm_damage_Labor_exposure% == "remind" p50_damageFuncCoef1("NEU") = 0.0521479;
$ifi %cm_damage_Labor_exposure% == "remind" p50_damageFuncCoef1("OAS") = 0.176437;
$ifi %cm_damage_Labor_exposure% == "remind" p50_damageFuncCoef1("REF") = 0.039541;
$ifi %cm_damage_Labor_exposure% == "remind" p50_damageFuncCoef1("SSA") = 0.0894126;
$ifi %cm_damage_Labor_exposure% == "remind" p50_damageFuncCoef1("USA") = 0.0141667;
$ifi %cm_damage_Labor_exposure% == "remind" p50_damageFuncCoef2("CAZ") = 0;
$ifi %cm_damage_Labor_exposure% == "remind" p50_damageFuncCoef2("CHA") = -0.0038031;
$ifi %cm_damage_Labor_exposure% == "remind" p50_damageFuncCoef2("EUR") = -0.0033926;
$ifi %cm_damage_Labor_exposure% == "remind" p50_damageFuncCoef2("IND") = -0.0045641;
$ifi %cm_damage_Labor_exposure% == "remind" p50_damageFuncCoef2("JPN") = -0.0050756;
$ifi %cm_damage_Labor_exposure% == "remind" p50_damageFuncCoef2("LAM") = -0.0024092;
$ifi %cm_damage_Labor_exposure% == "remind" p50_damageFuncCoef2("MEA") = -0.0023316;
$ifi %cm_damage_Labor_exposure% == "remind" p50_damageFuncCoef2("NEU") = -0.00321;
$ifi %cm_damage_Labor_exposure% == "remind" p50_damageFuncCoef2("OAS") = -0.0041988;
$ifi %cm_damage_Labor_exposure% == "remind" p50_damageFuncCoef2("REF") = -0.0021479;
$ifi %cm_damage_Labor_exposure% == "remind" p50_damageFuncCoef2("SSA") = -0.0025966;
$ifi %cm_damage_Labor_exposure% == "remind" p50_damageFuncCoef2("USA") = -0.00058;

*initialize
pm_damage(tall,regi) = 1;
pm_damageMarginal(tall,regi)           = 0;

*** EOF ./modules/50_damages/Labor/datainput.gms

