*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/33_CDR/all/sets.gms
sets

te_dyn33(all_te)  "all technologies"
/
		rockgrind		"grinding rock for enhanced weathering"
		dac		"direct air capture"
/

teNoTransform_dyn33(all_te) "all technologies that do not transform energy but still have investment and O&M costs (like storage or grid)"
/
       rockgrind       "grinding rock for enhanced weathering"
	   dac       "grinding rock for enhanced weathering"
/

teNoTransform2rlf_dyn33(all_te,rlf)      "mapping for final energy to grades"
/
      (rockgrind) . 1
	  (dac) . 1
/
;

***-------------------------------------------------------------------------
***  add module specific sets and mappings to the global sets and mappings
***-------------------------------------------------------------------------
te(te_dyn33)								   = YES;
teNoTransform(teNoTransform_dyn33)             = YES;
teNoTransform2rlf(teNoTransform2rlf_dyn33)     = YES;

*** EOF ./modules/33_CDR/all/sets.gms
