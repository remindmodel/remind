*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/fixed_shares/sets.gms

Sets
  secInd37   "industry sub-sectors"
  /
    cement      "clinker and cement production"
    chemicals   "chemicals production"
    steel       "steel production"
    otherInd    "other industry (used for reporting only)"
  /

  emiInd37(all_enty)   "industry emissions"
  /
    co2cement           "CO2 emissions from clinker and cement production"
    co2cement_process   "CO2 process emissions from clinker production"
    co2chemicals        "CO2 emissions from chemicals production"
    co2steel            "CO2 emissions from steel production"
    co2otherInd         "CO2 emissions from other industry (used for reporting only)"
  /

  emiInd37_fuel(all_enty)   "industry emissions from fuel combustion"
  /
    co2cement           "CO2 emissions from clinker and cement production"
    co2chemicals        "CO2 emissions from chemicals production"
    co2steel            "CO2 emissions from steel production"
    co2otherInd         "CO2 emissions from other industry (used for reporting only)"
  /

  secInd37_2_emiInd37(secInd37,emiInd37)   "link industry sub-sectors to sector emissions"
  /
    cement    . (co2cement, co2cement_process)
    chemicals . co2chemicals
    steel     . co2steel
    otherInd  . co2otherInd
  /

  macInd37(all_enty)   "industry CCS MACs"
  /
    co2cement
    co2chemicals
    co2steel
  /

  macBaseInd37(all_enty,secInd37)   "FE and industry combinations that have emissions"
  /
    (fesos, fehos, fegas) . (cement, chemicals, steel, otherInd)
    co2cement_process     . cement
  /
 
  in_industry_dyn37(all_in)   "all inputs and outputs of the CES function - industry"
  /
    eni     "industry energy use"
    enhi    "industry heat energy use"
    enhgai  "industry heat gaseous energy use (fegab and feh2b)"
    fesoi   "industry use of solid energy carriers"
    fehoi   "industry use of liquid energy carriers"
    fegai   "industry use of gaseous energy carriers"
    feh2i   "industry use of hydrogen"
    fehei   "industry use of district heat"
    feeli   "industry use of electricity"
  /

  ppfen_industry_dyn37(all_in)   "primary production factors energy - industry"
  / fesoi, fehoi, fegai, feh2i, fehei, feeli /

  cal_ppf_industry_dyn37(all_in)   "primary production factors for calibration - industry"
  / fesoi, fehoi, fegai, feh2i, fehei, feeli /

  ces_industry_dyn37(all_in,all_in)   "CES tree structure - industry"
  /
    en    . eni
    eni   . (enhi, feeli)
    enhi  . (fesoi, fehoi, fehei, enhgai)
    enhgai . (fegai, feh2i)
  /

 
  fe2ppfEn37(all_enty,all_in)   "match ESM entyFe to ppfEn"
  /
    fesos . fesoi
    fehos . fehoi
    fegas . fegai
    feh2s . feh2i
    fehes . fehei
    feels . feeli
  /
  
  fe_tax_sub37(all_in,all_in)  "correspondence between tax and subsidy input data resolution and model sectoral resolution"
  /
  fesoi . fesoi
  fehoi . fehoi
  fegai . fegai
  feh2i . feh2i
  fehei . fehei
  feeli . feeli
  /

  entyFe37(all_enty)   "FE carriers used in industry"
  /
    fesos 
    fehos 
    fegas
    feh2s
    fehes
    feels
  /
  
  secInd37_emiMkt(secInd37,all_emiMkt)   "industry and emission market mapping"
  /
    cement.ETS
    chemicals.ETS
    steel.ETS
    otherInd.ES  
  /  

  !! empty sets from the subsectors realisation
  industry_ue_calibration_target_dyn37(all_in)   "target values of industry calibration"
  /   /
  ppfKap_industry_dyn37(all_in)   "energy efficiency capital of industry"
  /   /
;

*** add module specific sets and mappings to the global sets and mappings
in(in_industry_dyn37)              = YES;
ppfEn(ppfen_industry_dyn37)        = YES;
cesOut2cesIn(ces_industry_dyn37)   = YES;
fe2ppfEn(fe2ppfEn37)               = YES;
fe_tax_sub_sbi(fe_tax_sub37)       = YES;

*** EOF ./modules/37_industry/fixed_shares/sets.gms

