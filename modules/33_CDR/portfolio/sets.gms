*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
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
    oae		"ocean alkalinity enhancement"
/

te_used33(all_te) "used CDR technologies (specified by switches)"

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
      feels.feels.oae
      fegas.fehes.oae
      feels.fehes.oae
      feh2s.fehes.oae
      fedie.fedie.oae
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
);

if(cm_33OAE eq 1,
      te_used33("oae") = YES;
      teNoTransform33("oae") = YES;
      teNoTransform2rlf33("oae", "1") = YES;
      teAdj33("oae") = YES;
      te_ccs33("oae") = YES;
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
