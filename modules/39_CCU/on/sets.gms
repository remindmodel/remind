*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
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

enty_ccu39(all_enty)      						"all types of quantities"
/
        ccuco2short  							"CCU related parameter for short term stored co2 in ccu products"

/


te_ccu39(all_te)                               "CCU technologies"
/
        h22ch4         							"Methanation, H2 + 4 CO2 --> CH4 + 2 H20"
		MeOH									"Methanol production /liquid fuel, CO2 hydrogenation, CO2 + 3 H2 --> CH3OH + H20"
/


***-------------------------------------------------------------------------
***                  module specific mappings
***-------------------------------------------------------------------------

se2se_ccu39(all_enty,all_enty,all_te)  			"map secondary energy to secondary energy using a CCU-technology"
/
		seh2.segafos.h22ch4
		seh2.seliqfos.MeOH
/

emi2teCCU(all_enty,all_enty,all_te,all_enty)    "map emissions to CCU-technologies"
/
	   seh2.segafos.h22ch4.CtoH
	   seh2.seliqfos.MeOH.CtoH
/

teCCU2rlf(all_te,rlf)     "mapping for CCU technologies to grades"
/
      (h22ch4) . 1
	  (MeOH) . 1
/

teCCU2rlf2(all_te,rlf)				  "mapping for CCU technologies to grades, only used to always list ccu-technologies in te2rlf"
/
      (h22ch4) . 1
	  (MeOH) . 1
/

teSe2rlf_ccu39(all_te,rlf)        "mapping for techologies to grades. Currently, the information was shifted to teRe2rlfDetail. Thus, teSe2rlf now only has '1' for the rlf values"
/
      (h22ch4 ) . 1
	  (MeOH) . 1
/
;

***-------------------------------------------------------------------------
***  add module specific sets and mappings to the global sets and mappings
***-------------------------------------------------------------------------

enty(enty_ccu39)							   = YES;
te(te_ccu39)								   = YES;
se2se(se2se_ccu39)							   = YES;
teSe2rlf(teSe2rlf_ccu39)					   = YES;

*** EOF ./modules/39_CCU/on/sets.gms

