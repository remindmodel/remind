*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/36_buildings/simple/sets.gms
Sets
  in_buildings_dyn36(all_in)   "all inputs and outputs of the CES function - buildings"
  /
    enb     "buildings energy use"
    enhb    "buildings heat energy use"
    enhgab  "buildings heat gaseous energy use (fegab and feh2b)"     
    fesob   "buildings use of solid energy carriers"
    fehob   "buildings use of liquid energy carriers"
    fegab   "buildings use of gaseous energy carriers"
    feh2b   "buildings use of hydrogen"
    feheb   "buildings use of district heat"
    feelb   "buildings use of electricity"
  /

   
  ppfen_buildings_dyn36(all_in)   "primary production factors energy - buildings"
  / fesob, fehob, fegab, feh2b, feheb, feelb /

  cal_ppf_buildings_dyn36(all_in)   "primary production factors for calibration - buildings"
 
  ces_buildings_dyn36(all_in,all_in)   "CES tree structure - buildings"
  /
    en    . enb
    enb   . (enhb, feelb)
    enhb  . (fesob, fehob, feheb, enhgab)
    enhgab . (fegab, feh2b)
  /

 
  entyFe36(all_enty)   "FE carriers used in buildings"
  /
    fesos 
    fehos 
    fegas
    feh2s
    fehes
    feels
  /

  fe2ppfEn36(all_enty,all_in)   "match ESM entyFe to ppfEn"
  /
    fesos . fesob
    fehos . fehob
    fegas . fegab
    feh2s . feh2b
    fehes . feheb
    feels . feelb
  /
  
  fe_tax_sub36(all_in,all_in)  "correspondence between tax and subsidy input data resolution and model sectoral resolution"
  /
  fesob . fesob
  fehob . fehob
  fegab . fegab
  feh2b . feh2b
  feheb . feheb
  feelb . feelb
  /
  
 ue_dyn36(all_in)  "useful energy items"
 //
;

cal_ppf_buildings_dyn36(ppfen_buildings_dyn36) = YES;

***-------------------------------------------------------------------------
***  add module specific sets and mappings to the global sets and mappings
***-------------------------------------------------------------------------
in(in_buildings_dyn36)            = YES;
ppfEn(ppfen_buildings_dyn36)      = YES;
cesOut2cesIn(ces_buildings_dyn36) = YES;
fe2ppfEn(fe2ppfEn36)              = YES;
fe_tax_sub_sbi(fe_tax_sub36) = YES;
*** EOF ./modules/36_buildings/simple/sets.gms
