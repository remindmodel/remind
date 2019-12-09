*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
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
        h22ch4         							"CO2 hydrogenation, H2 to CH2 (currently only H2 as feed, as for now we consider CO2 supply to be non-binding, equations for CC --> CCU will be the next step)"
		MeOH									"Methanol production /liquid fuel, CO2 hydrogenation, CO2 + 3 H2 --> CH3OH + H20"
/



***-------------------------------------------------------------------------
***                  module specific mappings
***-------------------------------------------------------------------------


teCCU2rlf(all_te,rlf)     "mapping for CCU technologies to grades"
/
/


teCCU2rlf2(all_te,rlf)				  "mapping for CCU technologies to grades, only used to always list ccu-technologies in te2rlf"
/
      (h22ch4) . 1
	  (MeOH) . 1
/
;

***-------------------------------------------------------------------------
***  add module specific sets and mappings to the global sets and mappings
***-------------------------------------------------------------------------


enty(enty_ccu39)							   = YES;
te(te_ccu39)								   = YES;

*** EOF ./modules/39_CCU/off/sets.gms
