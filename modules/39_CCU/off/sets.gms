*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/39_CCU/off/sets.gms

***-------------------------------------------------------------------------
***                  module specific sets
***-------------------------------------------------------------------------

Sets

enty_ccu39(all_enty)      						"all types of quantities"
/
        ccuco2short  							"CCU related parameter for short term stored co2 in ccu products"
/


te_ccu39(all_te)                            "CCU technologies"
/
    h22ch4         							"conversion technology of secondary energy hydrogen to secondary energy gas by methanation using captured CO2"
    MeOH								"conversion technology of secondary energy hydrogen to secondary energy liquids by the H2-Fischer-Tropsch route/Methanol route using captured CO2"
/



teCCU2rlf(all_te,rlf)				  "mapping for CCU technologies to grades"
/
      (h22ch4) . 1
      (MeOH) . 1
/
;

alias(teCCU2rlf,teCCU2rlf2); 

***-------------------------------------------------------------------------
***  add module specific sets and mappings to the global sets and mappings
***-------------------------------------------------------------------------


enty(enty_ccu39)							   = YES;
te(te_ccu39)								   = YES;

*** EOF ./modules/39_CCU/off/sets.gms
