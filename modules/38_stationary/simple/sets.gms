*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/38_stationary/simple/sets.gms
Sets
  in_stationary_dyn38(all_in)   "all inputs and outputs of the CES function - stationary"
  /
    ens     "stationary energy use"
    ensh    "stationary heat energy use"
    fesos   "stationary use of solid energy carriers"
    fehos   "stationary use of liquid energy carriers"
    fegas   "stationary use of gaseous energy carriers"
    feh2s   "stationary use of hydrogen"
    fehes   "stationary use of district heat"
    feels   "stationary use of electricity"
  /


  
  ppfen_stationary_dyn38(all_in)   "primary production factors energy - stationary"
  / fesos, fehos, fegas, feh2s, fehes, feels /

 

  ces_stationary_dyn38(all_in,all_in)   "CES tree structure - stationary"
  /
    en    . ens
    ens   . (ensh, feels)
    ensh  . (fesos, fehos, fegas, feh2s, fehes)
  /

 
  fe2ppfEn38(all_enty,all_in)   "match ESM entyFe to ppfEn"
  /
    fesos . fesos
    fehos . fehos
    fegas . fegas
    feh2s . feh2s
    fehes . fehes
    feels . feels
  /
  
 fe_tax_sub38(all_in,all_in)  "correspondence between tax and subsidy input data resolution and model sectoral resolution"
  /
    fesos . fesos
    fehos . fehos
    fegas . fegas
    feh2s . feh2s
    fehes . fehes
    feels . feels
  /
;


***-------------------------------------------------------------------------
***  add module specific sets and mappings to the global sets and mappings
***-------------------------------------------------------------------------
in(in_stationary_dyn38)             = YES;
ppfEn(ppfen_stationary_dyn38)       = YES;
cesOut2cesIn(ces_stationary_dyn38)           = YES;
fe2ppfEn(fe2ppfEn38)                    = YES;
fe_tax_sub_sbi(fe_tax_sub38) = YES;
*** EOF ./modules/38_stationary/simple/sets.gms
