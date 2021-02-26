*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de


p50_damageFuncCoef1 = 0;
p50_damageFuncCoef2 = 0;

* http://www.econ.yale.edu/~nordhaus/homepage/DICE2013R_110513_vanilla.gms
$ifi %cm_damage_DiceLike_specification% == "DICE2013R" p50_damageFuncCoef2 = 0.00267;

* doi:10.1073/pnas.1609244114
$ifi %cm_damage_DiceLike_specification% == "DICE2016" p50_damageFuncCoef2 = 0.00236;

* Howard et al (2017), 10.1007/s10640-017-0166-z
$ifi %cm_damage_DiceLike_specification% == "HowardNonCatastrophic" p50_damageFuncCoef2 = 0.00744;
$ifi %cm_damage_DiceLike_specification% == "HowardInclCatastrophic" p50_damageFuncCoef2 = 0.0100;

* Kalkuhl & Wenz (2020)
$ifi %cm_damage_DiceLike_specification% == "KWcross" p50_damageFuncCoef1 = 0.023;
$ifi %cm_damage_DiceLike_specification% == "KWpanelPop" p50_damageFuncCoef1 = 0.0373;
$ifi %cm_damage_DiceLike_specification% == "KWpanelPop" p50_damageFuncCoef2 = 0.0009;

*initialize
pm_damage(tall,regi) = 1;


