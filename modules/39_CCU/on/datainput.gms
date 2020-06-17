*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/39_CCU/on/datainput.gms

*** FS: set CO2 demand of CCU technologies to se2fe emission factor of liquids and gases
*** such that synfuels have the same emission factors as fossil fuels
p39_co2_dem(t,regi,"seh2","segabio","h22ch4") = pm_emifac(t,regi,"segafos","fegas","tdfosgas","co2");
p39_co2_dem(t,regi,"seh2","seliqbio","MeOH") = pm_emifac(t,regi,"seliqfos","fedie","tdfosdie","co2"); !! choose diesel as fuel for HDVt where synfuels most relevant

*** EOF ./modules/39_CCU/on/datainput.gms
