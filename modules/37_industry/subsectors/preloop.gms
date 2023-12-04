*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/subsectors/preloop.gms

*** initialize captured CO2 parameter
pm_IndstCO2Captured(t,regi,entySE,entyFE,secInd37,emiMkt) = 0;

*' calculate carbon content of feedstock for chemicals subsector as difference between
*' combustion emissions factor of FE and industrial process emissions factor
*' of feedstocks
p37_FeedstockCarbonContent(ttot,regi,entyFE)
  = sum(se2fe(entySEFos,entyFE,te),
      pm_emifac(ttot,regi,entySEFos,entyFE,te,"co2") 
    - pm_emifacNonEnergy(ttot,regi,entySEFos,entyFE,"indst","co2")
    );

*** EOF ./modules/37_industry/subsectors/preloop.gms
