*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/50_damages/KW_SE/datainput.gms

* satisfy dependencies
$ifi not %downscaleTemperature% == 'CMIP5' abort "module damages=KWLike requires downscaleTemperature=CMIP5";

** damage specification
    

*default specification from Kalkuhl & Wenz 2020:
p50_damageFuncCoefa1 =  0.00641;
p50_damageFuncCoefa2 =  0.00345;
p50_damageFuncCoefb1 = -0.00109;
p50_damageFuncCoefb2 = -0.000718;

* variance parameters based on Kalkuhl & Wenz 2020 (personal communication with Leonie Wenz)
p50_var_a1 = 0.00003811;
p50_var_a2 = 0.00002616;
p50_var_b1 = 2.88e-7;
p50_var_b2 = 1.797e-7;
p50_cov_a1_a2 = 0.00001781;
p50_cov_a1_b1 = -2.227e-6;
p50_cov_a1_b2 = -1.577e-6;
p50_cov_a2_b1 = -1.851e-6;
p50_cov_a2_b2  = -1.610e-6;
p50_cov_b1_b2 = 1.354e-7;


* initialize
pm_damage(tall,regi) = 1;
pm_damageImp(tall,tall2,regi) = 1;
pm_damageScc(tall,tall2,regi) = 1;
pm_damageGrowthRate(tall,regi)         = 0;
pm_damageMarginalT(tall,regi)           = 0;
pm_damageMarginalTm1(tall,regi)           = 0;
pm_damageMarginalTm2(tall,regi)           = 0;


*** EOF ./modules/50_damages/KW_SE/datainput.gms
