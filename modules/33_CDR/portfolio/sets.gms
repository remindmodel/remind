*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/33_CDR/portfolio/sets.gms
sets

te_all33(all_te)  "all CDR technologies"
/
    weathering	"enhanced weathering"
    dac		"direct air capture"
    oae_ng        "ocean akalinity ehnacement via ocean liming using a traditional calciner"
    oae_el        "ocean akalinity ehnacement via ocean liming using a novel calciner technology"
/

te_used33(all_te) "used CDR technologies (specified by switches)"

te_oae33(all_te)    "OAE technologies used"

teNoTransform33(all_te) "used CDR technologies that do not transform energy but still have investment and O&M costs (like storage or grid)"

teNoTransform2rlf33(all_te,rlf) "mapping for final energy to grades (used CDR technologies)"

teAdj33(all_te) "used CDR technologies with linearly growing constraint on control variable"

teLearn33(all_te) "used learning CDR technologies"

te_ccs33(all_te) "used CDR technologies that require CCS"

fe2cdr(all_enty,all_enty,all_te) "mapping of FE carriers supplying FE demand for all technologies"
/
      feels.feels.dac
      fehes.fehes.dac
      feels.fehes.dac
      feh2s.fehes.dac
      fegas.fehes.dac

      feels.feels.weathering
      fedie.fedie.weathering

      feels.feels.oae_ng
      fedie.fedie.oae_ng
      fegas.fehes.oae_ng
      feh2s.fehes.oae_ng

      feels.feels.oae_el
      fedie.fedie.oae_el
      feels.fehes.oae_el
      feh2s.fehes.oae_el
/

rlf_cz33(rlf) "representing weathering rates depending on climate zones according to Strefler, Amann et al. (2017)"
/
      1     "warm regions"
      2     "temperate regions"
/
;

***-------------------------------------------------------------------------
***  add CDR technologies specified by switches
***-------------------------------------------------------------------------

if(cm_33DAC eq 1,
      te_used33("dac") = YES;
      teNoTransform33("dac") = YES;
      teNoTransform2rlf33("dac", "1") = YES;
      teAdj33("dac") = YES;
      teLearn33("dac") = YES;
      te_ccs33("dac") = YES;
);

if(cm_33EW eq 1,
      te_used33("weathering") = YES;
      teNoTransform33("weathering") = YES;
      teNoTransform2rlf33("weathering", "1") = YES;
      teAdj33("weathering") = YES;
);

if(cm_33OAE eq 1,
      te_oae33("oae_ng") = YES;
      te_oae33("oae_el") = YES;
      te_used33(te_oae33) = YES;
      teNoTransform33(te_oae33) = YES;
      teNoTransform2rlf33(te_oae33, "1") = YES;
      teAdj33(te_oae33) = YES;
      te_ccs33(te_oae33) = YES;
);

***-------------------------------------------------------------------------
***  add module specific sets and mappings to the global sets and mappings
***-------------------------------------------------------------------------

te(te_used33) = YES;
teNoTransform(teNoTransform33) = YES;
teNoTransform2rlf(teNoTransform2rlf33) = YES;
teAdj(teAdj33) = YES;
teLearn(teLearn33) = YES;

*** EOF ./modules/33_CDR/portfolio/sets.gms
