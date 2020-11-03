*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/70_water/exogenous/datainput.gms
***-------------------------------------------------------------------------------
*** *IM* 20140502 definition of exogenous data 
***-------------------------------------------------------------------------------

parameter i70_water_con(all_te, coolte70)				"water consumption coefficients"
 /
$ondelim
$include "./modules/70_water/exogenous/input/WaterConsCoef.cs4r"
$offdelim
/;

parameter i70_water_wtd(all_te, coolte70)				"water withdrawal coefficients"
 /
$ondelim
$include "./modules/70_water/exogenous/input/WaterWithCoef.cs4r"
$offdelim
 /;

parameter i70_cool_share(all_regi, all_te, coolte70)	"cooling shares"
/
$ondelim
$include "./modules/70_water/exogenous/input/CoolingShares.cs4r"
$offdelim
/; 

*** EOF ./modules/70_water/exogenous/datainput.gms
