*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/36_buildings/simple/declarations.gms

scalars
  s36_costAddH2Inv   "additional h2 distribution costs for low diffusion levels (default value: 6.5$/kg = 6.5$/33.33kWh = 0.2$/kWh = 0.2 * 10^-12 T$/ 10^9 TWh = 0.2 * 10^-3 T$/TWh = 0.2 * 10^-3 * 8760 T$/TWa = 0.2 * 8.76 T$/TWa) [$/Kwh]" /0.2/
  s36_costDecayStart "simplified logistic function end of full value (ex. 5%  -> between 0 and 5% the function will have the value 1 -> shorturl.at/dfDNZ). [%]" /0.05/
  s36_costDecayEnd   "simplified logistic function start of null value (ex. 10% -> after 10% the function will have the value 0). [%]"  /0.10/
;

Variables
  v36_costExponent(ttot,all_regi) "logistic function exponent for additional hydrogen low penetration cost"
;

Positive Variables
  v36_expSlack(ttot,all_regi)     "slack variable to avoid overflow on too high logistic function exponent"
  v36_H2share(ttot,all_regi)      "H2 share in gases"
;

Equations
  q36_demFeBuild(ttot,all_regi,all_enty,all_emiMkt) "buildings final energy demand"
  q36_H2Share(ttot,all_regi)         "H2 share in gases"
  q36_costAddTeInv(ttot,all_regi)    "additional buildings hydrogen annual investment costs under low technology diffusion due to T&D conversion"
  q36_auxCostAddTeInv(ttot,all_regi) "auxiliar logistic function exponent calculation for additional hydrogen low penetration cost"   
;

*** EOF ./modules/36_buildings/simple/declarations.gms
