*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/36_buildings/simple/bounds.gms

*** Upper bound for exponent to avoid exponential gams overflow (if > 20 -> 3^20 > 1e10 what would cause GAMS to get an overflow x**y error) 
v36_costExponent.up(t,regi) = 20; 

*** lower bound for gases and liquids share in buildings for an incumbents scenario
$ifthen "%cm_feShareLimits%" == "incumbents"
 vm_shGasLiq_fe.lo(t,regi,"build")$(t.val ge 2050) = 0.25;
 vm_shGasLiq_fe.lo(t,regi,"build")$(t.val ge 2030 AND t.val le 2045) = 0.15 + (0.10/20)*(t.val-2030);
$endif

*** EOF ./modules/36_buildings/simple/bounds.gms

