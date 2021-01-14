*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
sets
*** the mappings of the input data are for the CES-Structure (all_in) and in this module all_in is mapped to all_enty
bi2s(all_enty,all_enty,all_te,all_te)   "match ESM fe for buildings and industry to stationary"
/
  fesob . fesos . tdbiosob . tdbiosos 
  fesob . fesos . tdfossob . tdfossos 
  fesoi . fesos . tdbiosoi . tdbiosos
  fesoi . fesos . tdfossoi . tdfossos
  fehob . fehos . tdbiohob . tdbiohos
  fehob . fehos . tdfoshob . tdfoshos
  fehoi . fehos . tdbiohoi . tdbiohos
  fehoi . fehos . tdfoshoi . tdfoshos
  fegab . fegas . tdbiogab . tdbiogas
  fegab . fegas . tdfosgab . tdfosgas
  fegai . fegas . tdbiogai . tdbiogas
  fegai . fegas . tdfosgai . tdfosgas
  feheb . fehes . tdheb . tdhes
  fehei . fehes . tdhei . tdhes
  feelb . feels . tdelb . tdels
  feeli . feels . tdeli . tdels
/
uet2fet(all_enty,all_enty,all_te,all_te)  "match ESM fe for ue-items of the transport sector to final energy of the transport sector"
/
  fepet.fepet.tdbiopet.tdbiopet
  fepet.fepet.tdfospet.tdfospet
  fedie.fedie.tdbiodie.tdbiodie
  fedie.fedie.tdfosdie.tdfosdie
  feelt.feelt.tdelt.tdelt
/
in2enty(all_enty,all_enty,all_te,all_te)  "match ESM fe to CES structure"
in2enty2(all_enty,all_enty,all_te,all_te)  "alias of in2enty"
;

in2enty(all_enty,all_enty2,all_te,all_te2) = bi2s(all_enty,all_enty2,all_te,all_te2) + uet2fet(all_enty,all_enty2,all_te,all_te2);

in2enty2(all_enty,all_enty2,all_te,all_te2) = in2enty(all_enty,all_enty2,all_te,all_te2);
