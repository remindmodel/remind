*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/36_buildings/simple/bounds.gms

*** Upper bound for exponent to avoid exponential gams overflow (if > 20 -> 3^20 > 1e10 what would cause GAMS to get an overflow x**y error) 
v36_costExponent.up(t,regi) = 20; 


*** Fix H2 Phase-In costs to zero for calibration runs
$ifthen.CES_calibration "%CES_parameters%" == "calibrate"
v36_costAddH2LowPen.fx(t,regi) = 0;
$endif.CES_calibration


*** EOF ./modules/36_buildings/simple/bounds.gms
