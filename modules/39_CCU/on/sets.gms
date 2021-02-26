*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/39_CCU/on/sets.gms

***-------------------------------------------------------------------------
***                  module specific sets
***-------------------------------------------------------------------------

Sets
enty_ccu39(all_enty)      						"all types of CCU-related quantities"
/
        ccuco2short  							"CCU related parameter for short term stored co2 in ccu products"
/


te_ccu39(all_te)                            "CCU technologies"
/
    h22ch4         							"conversion technology of secondary energy hydrogen to secondary energy gas by methanation using captured CO2"
	MeOH									"conversion technology of secondary energy hydrogen to secondary energy liquids by the H2-Fischer-Tropsch route/Methanol route using captured CO2"
/

***-------------------------------------------------------------------------
***                  module specific mappings
***-------------------------------------------------------------------------

se2se_ccu39(all_enty,all_enty,all_te)  			"map secondary energy to secondary energy using a CCU-technology"
/
		seh2.segabio.h22ch4
		seh2.seliqbio.MeOH
/


teCCU2rlf(all_te,rlf)     "mapping for CCU technologies to grades"
/
      (h22ch4) . 1
	  (MeOH) . 1
/


teSeCCU2rlf(all_te,rlf)     "mapping for secondary energy CCU technologies to grades"
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
se2se(se2se_ccu39)							   = YES;
teSe2rlf(teCCU2rlf)					   		   = YES;

*** EOF ./modules/39_CCU/on/sets.gms

