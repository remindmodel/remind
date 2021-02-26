*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/36_buildings/simple/bounds.gms

*** Upper bound for exponent to avoid exponential gams overflow (if > 20 -> 3^20 > 1e10 what would cause GAMS to get an overflow x**y error) 
v36_costExponent.up(t,regi) = 20; 


*** FS: bounds on maximum heat and electricity share in buildings for DEU from 2035 onwards, used for some ariadne scenarios
v36_Heatshare.up(t,regi)$(sameas(regi,"DEU") AND t.val gt 2030) = cm_HeatLim_b+0.05;
v36_Heatshare.up(t,regi)$(sameas(regi,"DEU") AND t.val gt 2040) = cm_HeatLim_b;

v36_Elshare.up(t,regi)$(sameas(regi,"DEU") AND t.val gt 2030) = cm_ElLim_b+0.05;
v36_Elshare.up(t,regi)$(sameas(regi,"DEU") AND t.val gt 2040) = cm_ElLim_b;


*** FS: no H2 in buildings before 2050
vm_demFeSector.up('2010',regi,'seh2','feh2s','build','ES') = 0;
vm_demFeSector.up('2015',regi,'seh2','feh2s','build','ES') = 0;
vm_demFeSector.up('2020',regi,'seh2','feh2s','build','ES') = 1e-5;
vm_demFeSector.up('2025',regi,'seh2','feh2s','build','ES') = 1e-5;


*** lower bound for gases and liquids share in buildings for an incumbents scenario
$IFTHEN.feShare not "%cm_feShareLimits%" == "off" 

$ifthen.feShareScenario "%cm_feShareLimits%" == "incumbents"
  pm_shGasLiq_fe_lo(t,regi,"build")$(t.val ge 2050) = 0.25;
  pm_shGasLiq_fe_lo(t,regi,"build")$(t.val ge 2030 AND t.val le 2045) = 0.15 + (0.10/20)*(t.val-2030);
$endif.feShareScenario

vm_shGasLiq_fe.up(t,regi,sector)$pm_shGasLiq_fe_up(t,regi,sector) = pm_shGasLiq_fe_up(t,regi,sector);
vm_shGasLiq_fe.lo(t,regi,sector)$pm_shGasLiq_fe_lo(t,regi,sector) = pm_shGasLiq_fe_lo(t,regi,sector);

$endif.feShare

*** Assure that h2 penetration is not high in calibration so the extra t&d cost can be considered by the model. In case contrary, H2 is competitive against gas in buildings and industry even during calibration.
$ifthen.CES_calibration "%CES_parameters%" == "calibrate"
v36_H2share.up(t,regi) = s36_costDecayStart;
$endif.CES_calibration

*** EOF ./modules/36_buildings/simple/bounds.gms
