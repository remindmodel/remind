*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/subsectors/preloop.gms

*** initialize captured CO2 parameter
pm_IndstCO2Captured(t,regi,entySe,entyFe,secInd37,emiMkt) = 0;
pm_NonFos_IndCC_fraction0(ttot,all_regi,secInd37) = 0;
pm_NonFos_IndCC_fraction_Emi0(ttot,all_regi,emiInd37) = 0;

*' calculate carbon content of feedstock for chemicals subsector as difference between
*' combustion emissions factor of FE and industrial process emissions factor
*' of feedstocks
p37_FeedstockCarbonContent(ttot,regi,entyFe)
  = sum(se2fe(entySeFos,entyFe,te),
      pm_emifac(ttot,regi,entySeFos,entyFe,te,"co2") 
    - pm_emifacNonEnergy(ttot,regi,entySeFos,entyFe,"indst","co2")
    );

*** EOF ./modules/37_industry/subsectors/preloop.gms
