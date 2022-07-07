*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/50_damages/KWLike/datainput.gms

* satisfy dependencies
$ifi not %downscaleTemperature% == 'CMIP5' abort "module damages=KWLike requires downscaleTemperature=CMIP5";

** damage specification
    

*default specification:
p50_damageFuncCoefa1 =  0.00641;
p50_damageFuncCoefa2 =  0.00345;
p50_damageFuncCoefb1 = -0.00109;
p50_damageFuncCoefb2 = -0.000718;

 

* initialize
pm_damage(tall,regi) = 1;
pm_damageGrowthRate(tall,regi)         = 0;
pm_damageMarginalT(tall,regi)           = 0;
pm_damageMarginalTm1(tall,regi)           = 0;
pm_damageMarginalTm2(tall,regi)           = 0;


*** EOF ./modules/50_damages/KWLike/datainput.gms
