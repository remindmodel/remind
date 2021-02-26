*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/subsectors/sets.gms

Sets
  secInd37   "industry sub-sectors"
  /
    cement      "clinker and cement production"
    chemicals   "chemicals production"
    steel       "iron and steel production"
    otherInd    "aggregated other industry sub-sectors"
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

  macInd37(all_enty)   "industry CCS MACs"
  /
    co2cement
    co2chemicals
    co2steel
  /

  secInd37_2_emiInd37(secInd37,emiInd37)   "link industry sub-sectors to sector emissions"
  /
    cement    . (co2cement, co2cement_process)
    chemicals . co2chemicals
    steel     . co2steel
    otherInd  . co2otherInd
  /

  secInd37_emiMkt(secInd37,all_emiMkt)   "industry and emission market mapping"
  /
    cement    . ETS
    chemicals . ETS
    steel     . ETS
    otherInd  . ES  
  /  

  in_industry_dyn37(all_in)   "all inputs and outputs of the CES function - industry"
  /
    ue_industry   "useful energy of industry sector"

    ue_cement                "useful energy of cement production"
    en_cement                "energy use of cement production"
    kap_cement               "energy efficiency capital of cement production"
    en_cement_non_electric   "non-electric energy use of cement production"
    feso_cement              "solids energy use of cement production"
    feli_cement              "liquids energy use of cement production"
    fega_cement              "gases energy use of cement production"
    feh2_cement              "hydrogen energy use of cement production"
    feel_cement              "electricity energy use of cement production"
 

    ue_chemicals         "useful energy of chemicals production"
    en_chemicals         "energy use of chemicals production"
    kap_chemicals        "energy efficiency capital of chemicals production"
    en_chemicals_fhth    "feedstock and high temperature heat energy use of chemicals production"
    feso_chemicals       "solids energy use of cement production"
    feli_chemicals       "liquids energy use of chemicals production"
    fega_chemicals       "gases energy use of chemicals production"
    feh2_chemicals       "hydrogen energy use of chemicals production"
    feelhth_chemicals    "electric energy for high temperature heat in chemicals production"
    feelwlth_chemicals   "electric energy for mechanical work and low temperature heat in chemicals production"

    ue_steel               "useful energy of steel production"
    ue_steel_primary       "useful energy of primary steel production"
    ue_steel_secondary     "useful energy of secondary steel production"
    en_steel_primary       "energy use of primary steel production"
    kap_steel_primary      "energy efficiency capital of primary steel production"
    kap_steel_secondary    "energy efficiency capital of secondary steel production"
    en_steel_furnace       "non-electric energy use of primary steel production"
    feso_steel             "solids energy use of primary steel production"
    feli_steel             "liquids energy use of primary steel production"
    fega_steel             "gases energy use of primary steel production"
    feh2_steel             "hydrogen energy use of primary steel production"
    feel_steel_primary     "electricity energy use pf primary steel production"
    feel_steel_secondary   "electricity energy use of secondary steel production"

    ue_otherInd       "useful energy of other industry production"
    en_otherInd       "energy use of other industry production"
    kap_otherInd      "energy efficiency capital of other industry production"
    en_otherInd_hth   "high temperature heat energy use on other industry production"
    feso_otherInd     "solids energy use of other industry production"
    feli_otherInd     "liquids energy use of other industry production"
    fega_otherInd     "gases energy use of other industry production"
    feh2_otherInd     "hydrogen energy use of other industry production"
    fehe_otherInd     "heat energy use of other industry production"
    feelhth_otherInd  "electric energy for high temperature heat in other industry production"
    feelwlth_otherInd "electric energy for mechanical work and low temperature heat in other industry production"
  /

  ces_industry_dyn37(all_in,all_in)   "CES tree structure - industry"
  /
   en                       . ue_industry

   ue_industry              . (ue_cement, ue_chemicals, ue_steel, ue_otherInd)

   ue_cement                . (en_cement, kap_cement)
   en_cement                . (en_cement_non_electric, feel_cement)
   en_cement_non_electric   . (feso_cement, feli_cement, fega_cement, feh2_cement)

   ue_chemicals             . (en_chemicals, kap_chemicals)
   en_chemicals             . (en_chemicals_fhth, feelwlth_chemicals)
   en_chemicals_fhth        . (feso_chemicals, feli_chemicals, fega_chemicals,
                               feh2_chemicals, feelhth_chemicals)

   ue_steel                 . (ue_steel_primary, ue_steel_secondary)
   ue_steel_secondary       . (feel_steel_secondary, kap_steel_secondary)
   ue_steel_primary         . (en_steel_primary, kap_steel_primary)
   en_steel_primary         . (en_steel_furnace, feel_steel_primary)
   en_steel_furnace         . (feso_steel, feli_steel, fega_steel, feh2_steel)

   ue_otherInd     . (en_otherInd, kap_otherInd)
   en_otherInd     . (en_otherInd_hth, feelwlth_otherInd)
   en_otherInd_hth . (feso_otherInd, feli_otherInd, fega_otherInd, 
                      feh2_otherInd, fehe_otherInd, feelhth_otherInd)
  /  

  ces_eff_target_dyn37(all_in,all_in)   "limits to specific total energy use"
  /
    ue_cement . (feso_cement, feli_cement, fega_cement, feh2_cement, 
                 feel_cement)

    ue_chemicals . (feso_chemicals, feli_chemicals, fega_chemicals, 
                    feh2_chemicals, feelhth_chemicals, feelwlth_chemicals)

    ue_steel_primary . (feso_steel, feli_steel, fega_steel, feh2_steel, 
                        feel_steel_primary)

    ue_steel_secondary . feel_steel_secondary

    ue_otherInd . (feso_otherInd, feli_otherInd, fega_otherInd, feh2_otherInd,
                   fehe_otherInd, feelhth_otherInd, feelwlth_otherInd)
  /

  ue_industry_dyn37(all_in)   "industry production in physical or monetary values"
  /
    ue_cement
    ue_chemicals
    ue_steel_primary
    ue_steel_secondary
    ue_otherInd
  /

  ppfKap_industry_dyn37(all_in)   "energy efficiency capital of industry"
  /
    kap_cement
    kap_chemicals
    kap_steel_primary
    kap_steel_secondary
    kap_otherInd
  /

  ppfen_industry_dyn37(all_in)   "primary production factors energy - industry"
  /
    feso_cement, feli_cement, fega_cement, feh2_cement, feel_cement,
    feso_chemicals, feli_chemicals, fega_chemicals, feh2_chemicals, 
    feelhth_chemicals, feelwlth_chemicals,
    feso_steel, feli_steel, fega_steel, feh2_steel, feel_steel_primary, 
    feel_steel_secondary,
    feso_otherInd, feli_otherInd, fega_otherInd, feh2_otherInd, fehe_otherInd,
    feelhth_otherInd, feelwlth_otherInd
  /

  !! Calibration Sets
  pf_eff_target_dyn37(all_in)    "production factors with efficiency target"
  pf_quan_target_dyn37(all_in)   "production factors with quantity target"

  pf_quantity_shares_37(all_in,all_in)   "quantities for the calibration defined as a percentage of another pf"
  /
    feh2_cement    . fega_cement
    feh2_chemicals . fega_chemicals
    feh2_steel     . fega_steel
    feh2_otherInd  . fega_otherInd

    feelhth_chemicals . feelwlth_chemicals
    feelhth_otherInd  . feelwlth_otherInd
  /


  secInd37_2_pf(secInd37,all_in)   "link industry sub-sectors to energy to production factors"
  /
    cement . (ue_cement, en_cement, kap_cement, en_cement_non_electric, 
              feso_cement, feli_cement, fega_cement, feh2_cement, feel_cement)

    chemicals . (ue_chemicals, en_chemicals, kap_chemicals, en_chemicals_fhth,
                 feso_chemicals, feli_chemicals, fega_chemicals, feh2_chemicals,
                 feelhth_chemicals, feelwlth_chemicals)

    steel . (ue_steel, ue_steel_primary, ue_steel_secondary, en_steel_primary,
             kap_steel_primary, en_steel_furnace, feso_steel, feli_steel, 
             fega_steel, feh2_steel, feel_steel_primary, kap_steel_secondary,
             feel_steel_secondary)

    otherInd . (ue_otherInd, en_otherInd, kap_otherInd, en_otherInd_hth,
                feso_otherInd, feli_otherInd, fega_otherInd, feh2_otherInd,
                fehe_otherInd, feelhth_otherInd, feelwlth_otherInd)
  /

  cal_ppf_industry_dyn37(all_in)   "primary production factors for calibration - industry"
  /   /

  industry_ue_calibration_target_dyn37(all_in)   "target values of industry calibration"
  /
    ue_cement, ue_chemicals, ue_steel_primary, ue_steel_secondary, ue_otherInd
  /

  fe2ppfen37(all_enty,all_in)   "match ESM entyFE to ppfen"
  /
    fesos . (feso_cement, feso_chemicals, feso_steel, feso_otherInd)
    fehos . (feli_cement, feli_chemicals, feli_steel, feli_otherInd)
    fegas . (fega_cement, fega_chemicals, fega_steel, fega_otherInd)
    feh2s . (feh2_cement, feh2_chemicals, feh2_steel, feh2_otherInd)
    fehes . fehe_otherInd
    feels . (feel_cement, feelhth_chemicals, feelwlth_chemicals, 
             feel_steel_primary, feel_steel_secondary, feelhth_otherInd,
             feelwlth_otherInd)
  /

  
 fe_tax_sub37(all_in,all_in)  "correspondence between tax and subsidy input data resolution and model sectoral resolution"
  /
    fesoi . (feso_cement, feso_chemicals, feso_steel, feso_otherInd)
    fehoi . (feli_cement, feli_chemicals, feli_steel, feli_otherInd)
    fegai . (fega_cement, fega_chemicals, fega_steel, fega_otherInd)
    feh2i . (feh2_cement, feh2_chemicals, feh2_steel, feh2_otherInd)
    fehei . fehe_otherInd
    feeli . (feel_cement, feelhth_chemicals, feelwlth_chemicals, 
             feel_steel_primary, feel_steel_secondary, feelhth_otherInd,
             feelwlth_otherInd)
  /
  
  energy_limits37(all_in,all_in)   "thermodynamic limit of energy"
  /
    ue_cement          . en_cement
    ue_steel_primary   . en_steel_primary
    ue_steel_secondary . feel_steel_secondary
  /
;

*** ---------------------------------------------------------------------------
***        add module-specifc sets and mappings to the global ones
*** ---------------------------------------------------------------------------
ppfKap(ppfKap_industry_dyn37)                 = YES;
in(in_industry_dyn37)                         = YES;
ppfen(ppfen_industry_dyn37)                   = YES;
cesOut2cesIn(ces_industry_dyn37)              = YES;
fe2ppfen(fe2ppfen37)                          = YES;
fe_tax_sub_sbi(fe_tax_sub37) = YES;

pf_eff_target_dyn37(ppfen_industry_dyn37)   = YES;
pf_quan_target_dyn37(ppfkap_industry_dyn37) = YES;

$ifthen.calibrate "%CES_parameters%" == "calibrate"   !! CES_parameters
pf_eff_target_dyn29(pf_eff_target_dyn37)   = YES;
pf_quan_target_dyn29(pf_quan_target_dyn37) = YES;
$endif.calibrate

alias(secInd37_2_pf,secInd37_2_pf2);
alias(fe2ppfen37,fe2ppfen37_2);

*** EOF ./modules/37_industry_four_sectors/sets.gms

