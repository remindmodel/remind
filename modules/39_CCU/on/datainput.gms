*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/39_CCU/on/datainput.gms

*** carbon efficiency of synthetic liquids (FT synthesis) and synthetic gas production (methanation)
*** set to 0.95 following Mar Pérez-Fortes et al. (2016), https://doi.org/10.1016/j.apenergy.2015.07.067,
*** who assess this for methanol-CCU plant with similar processes as our CCU technologies
p39_carbon_efficiency(t,regi,"MeOH") = 0.95;
p39_carbon_efficiency(t,regi,"h22ch4") = 0.95;

*** CO2 demand of CCU technologies: emission factor of liquids and gases per unit SE divided by carbon efficiency of CCU technology
p39_co2_dem(t,regi,"seh2","segasyn","h22ch4") = pm_emifac(t,regi,"segafos","fegas","tdfosgas","co2") / p39_carbon_efficiency(t,regi,"h22ch4");
p39_co2_dem(t,regi,"seh2","seliqsyn","MeOH") = pm_emifac(t,regi,"seliqfos","fedie","tdfosdie","co2") / p39_carbon_efficiency(t,regi,"MeOH"); !! choose diesel as fuel for HDVt where synfuels most relevant



*** EOF ./modules/39_CCU/on/datainput.gms
