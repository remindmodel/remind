*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/off/sets.gms

*** These sets are stripped-down version of the sets in the other realisations
*** to allow for the calculation of cement process emissions using the general
*** structure of the module.
Sets
  secInd37   "industry sub-sectors"
  /
    cement   "clinker and cement production"
  /

  emiInd37(all_enty)   "industry emissions"
  /
    co2cement_process   "CO2 process emissions from clinker production"
  /

  secInd37_2_emiInd37(secInd37,emiInd37)   "link industry sub-sectors to sector emissions"
  /
    cement . co2cement_process
  /
  
  macBaseInd37(all_enty,secInd37)   "FE and industry combinations that have emissions"
  /
    co2cement_process . cement
  /
;

*** EOF ./modules/37_industry/off/sets.gms

