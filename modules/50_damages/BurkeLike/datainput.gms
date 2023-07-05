*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/50_damages/BurkeLike/datainput.gms

* satisfy dependencies
$ifi not %downscaleTemperature% == 'CMIP5' abort "module damages=BurkeLike requires downscaleTemperature=CMIP5";

** damage specification
    

*Burke default lag0 damages:
if(cm_damages_BurkeLike_specification eq 0,
p50_damageFuncCoef1 =  0.01272;
p50_damageFuncCoef2 = -0.00049;
);

* 5lag specification:    
if(cm_damages_BurkeLike_specification eq 5,
p50_damageFuncCoef1 = -0.00371;
p50_damageFuncCoef2 = -0.000097;
);
**
 

* initialize
pm_damage(tall,regi) = 1;
pm_damageGrowthRate(tall,regi)         = 0;
pm_damageMarginal(tall,regi)           = 0;

*** EOF ./modules/50_damages/BurkeLike/datainput.gms
