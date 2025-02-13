*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/subsectors/sets.gms

Sets

*** ---------------------------------------------------------------------------
***        1. CES-Based
*** ---------------------------------------------------------------------------

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
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "ces"
    co2chemicals
$endif.cm_subsec_model_chemicals
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "ces"
    co2steel
$endif.cm_subsec_model_steel
  /

  emiInd37_fe2sec(all_enty,secInd37)   "FE and industry combinations that have emissions"
  /
    (fesos, fehos, fegas) . (cement, chemicals, steel, otherInd)
    co2cement_process     . cement
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
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "ces"
    en_chemicals         "energy use of chemicals production"
    kap_chemicals        "energy efficiency capital of chemicals production"
    en_chemicals_fhth    "feedstock and high temperature heat energy use of chemicals production"
    feso_chemicals       "solids energy use of chemicals production"
    feli_chemicals       "liquids energy use of chemicals production"
    fega_chemicals       "gases energy use of chemicals production"
    feh2_chemicals       "hydrogen energy use of chemicals production"
    feelhth_chemicals    "electric energy for high temperature heat in chemicals production"
    feelwlth_chemicals   "electric energy for mechanical work and low temperature heat in chemicals production"
$endif.cm_subsec_model_chemicals

    ue_steel               "useful energy of steel production"
    ue_steel_primary       "useful energy of primary steel production"
    ue_steel_secondary     "useful energy of secondary steel production"
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "ces"
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
$endif.cm_subsec_model_steel

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

$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "ces"
   ue_chemicals             . (en_chemicals, kap_chemicals)
   en_chemicals             . (en_chemicals_fhth, feelwlth_chemicals)
   en_chemicals_fhth        . (feso_chemicals, feli_chemicals, fega_chemicals,
                               feh2_chemicals, feelhth_chemicals)
$endif.cm_subsec_model_chemicals

   ue_steel                 . (ue_steel_primary, ue_steel_secondary)
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "ces"
   ue_steel_secondary       . (feel_steel_secondary, kap_steel_secondary)
   ue_steel_primary         . (en_steel_primary, kap_steel_primary)
   en_steel_primary         . (en_steel_furnace, feel_steel_primary)
   en_steel_furnace         . (feso_steel, feli_steel, fega_steel, feh2_steel)
$endif.cm_subsec_model_steel

   ue_otherInd     . (en_otherInd, kap_otherInd)
   en_otherInd     . (en_otherInd_hth, feelwlth_otherInd)
   en_otherInd_hth . (feso_otherInd, feli_otherInd, fega_otherInd,
                      feh2_otherInd, fehe_otherInd, feelhth_otherInd)
  /

  in_chemicals_feedstock_37(all_in)   "chemicals FE that can provide feedstocks"
  /
    feso_chemicals
    feli_chemicals
    fega_chemicals
  /

  ces_eff_target_dyn37(all_in,all_in)   "limits to specific total energy use"
  /
    ue_cement . (feso_cement, feli_cement, fega_cement, feh2_cement,
                 feel_cement)

$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "ces"
    ue_chemicals . (feso_chemicals, feli_chemicals, fega_chemicals,
                    feh2_chemicals, feelhth_chemicals, feelwlth_chemicals)
$endif.cm_subsec_model_chemicals

$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "ces"
    ue_steel_primary . (feso_steel, feli_steel, fega_steel, feh2_steel,
                        feel_steel_primary)

    ue_steel_secondary . feel_steel_secondary
$endif.cm_subsec_model_steel

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
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "ces"
    kap_chemicals
$endif.cm_subsec_model_chemicals
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "ces"
    kap_steel_primary
    kap_steel_secondary
$endif.cm_subsec_model_steel
    kap_otherInd
  /

  ppfen_industry_dyn37(all_in)   "primary production factors energy - industry"
  /
    feso_cement, feli_cement, fega_cement, feh2_cement, feel_cement,
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "ces"
    feso_chemicals, feli_chemicals, fega_chemicals, feh2_chemicals,
    feelhth_chemicals, feelwlth_chemicals,
$endif.cm_subsec_model_chemicals
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "ces"
    feso_steel, feli_steel, fega_steel, feh2_steel, feel_steel_primary,
    feel_steel_secondary,
$endif.cm_subsec_model_steel
    feso_otherInd, feli_otherInd, fega_otherInd, feh2_otherInd, fehe_otherInd,
    feelhth_otherInd, feelwlth_otherInd
  /

  ppf_industry_dyn37(all_in)   "primary production factors - industry"
  /   /

  ipf_industry_dyn37(all_in)   "intermediate production factors - industry"
  /   /

  !! Calibration Sets
  pf_eff_target_dyn37(all_in)   "production factors with efficiency target"
  pf_quan_target_dyn37(all_in)   "production factors with quantity target"

  pf_quantity_shares_37(all_in,all_in)   "quantities for the calibration defined as a percentage of another pf"
  /
    feh2_cement    . fega_cement
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "ces"
    feh2_chemicals . fega_chemicals
$endif.cm_subsec_model_chemicals
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "ces"
    feh2_steel     . fega_steel
$endif.cm_subsec_model_steel
    feh2_otherInd  . fega_otherInd

    feelhth_chemicals . feelwlth_chemicals
    feelhth_otherInd  . feelwlth_otherInd
  /

  pf_industry_relaxed_bounds_dyn37(all_in)   "production factors with progressively relaxed bounds during the calibration"

  secInd37_2_pf(secInd37,all_in)   "link industry sub-sectors to energy to production factors"
  /
    cement . (ue_cement, en_cement, kap_cement, en_cement_non_electric,
              feso_cement, feli_cement, fega_cement, feh2_cement, feel_cement)

    chemicals . (ue_chemicals
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "ces"
             , en_chemicals, kap_chemicals, en_chemicals_fhth,
                 feso_chemicals, feli_chemicals, fega_chemicals, feh2_chemicals,
                 feelhth_chemicals, feelwlth_chemicals
$endif.cm_subsec_model_chemicals
             )

    steel . (ue_steel, ue_steel_primary, ue_steel_secondary
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "ces"
             , en_steel_primary, kap_steel_primary, en_steel_furnace,
             feso_steel, feli_steel, fega_steel, feh2_steel,
             feel_steel_primary, kap_steel_secondary, feel_steel_secondary
$endif.cm_subsec_model_steel
             )

    otherInd . (ue_otherInd, en_otherInd, kap_otherInd, en_otherInd_hth,
                feso_otherInd, feli_otherInd, fega_otherInd, feh2_otherInd,
                fehe_otherInd, feelhth_otherInd, feelwlth_otherInd)
  /

  ue_industry_2_pf(all_in,all_in)   "link industry sub-sectors activity to pf"
  /
    ue_cement . (en_cement, kap_cement, en_cement_non_electric, feso_cement,
                 feli_cement, fega_cement, feh2_cement, feel_cement)

$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "ces"
    ue_chemicals . (en_chemicals, kap_chemicals, en_chemicals_fhth,
                    feso_chemicals, feli_chemicals, fega_chemicals,
		                feh2_chemicals, feelhth_chemicals, feelwlth_chemicals)
$endif.cm_subsec_model_chemicals

$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "ces"
    ue_steel_primary . (en_steel_primary, kap_steel_primary, en_steel_furnace,
                        feso_steel, feli_steel, fega_steel, feh2_steel,
			                  feel_steel_primary)

    ue_steel_secondary . (kap_steel_secondary, feel_steel_secondary)
$endif.cm_subsec_model_steel

    ue_otherInd . (en_otherInd, kap_otherInd, en_otherInd_hth, feso_otherInd,
                   feli_otherInd, fega_otherInd, feh2_otherInd, fehe_otherInd,
		   feelhth_otherInd, feelwlth_otherInd)
  /

  cal_ppf_industry_dyn37(all_in)   "primary production factors for calibration - industry"
  /   /

  industry_ue_calibration_target_dyn37(all_in)   "target values of industry calibration"
  /
    ue_cement, ue_chemicals, ue_steel_primary, ue_steel_secondary, ue_otherInd
  /

  fe2ppfEn37(all_enty,all_in)   "match ESM entyFe to ppfen"
  /
    fesos . (feso_cement, feso_otherInd)
    fehos . (feli_cement, feli_otherInd)
    fegas . (fega_cement, fega_otherInd)
    feh2s . (feh2_cement, feh2_otherInd)
    fehes . fehe_otherInd
    feels . (feel_cement, feelhth_otherInd, feelwlth_otherInd)
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "ces"
    fesos . feso_chemicals
    fehos . feli_chemicals
    fegas . fega_chemicals
    feh2s . feh2_chemicals
    feels . (feelhth_chemicals, feelwlth_chemicals)
$endif.cm_subsec_model_chemicals
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "ces"
    fesos . feso_steel
    fehos . feli_steel
    fegas . fega_steel
    feh2s . feh2_steel
    feels . (feel_steel_primary, feel_steel_secondary)
$endif.cm_subsec_model_steel
  /

energy_limits37(all_in,all_in)   "thermodynamic limit of energy"
  /
    ue_cement          . en_cement
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "ces"
    ue_steel_primary   . en_steel_primary
    ue_steel_secondary . feel_steel_secondary
$endif.cm_subsec_model_steel
  /

entyFeCC37(all_enty)   "FE carriers in industry which can be used for CO2 capture"
  /
    fesos
    fehos
    fegas
  /

entySE_emiFac_feedstocks(all_enty,all_enty) "SE type of emissions factor that should be used to calculate carbon contained in feedstocks"

/
  sesofos  . fesos
  seliqfos . fehos
  segafos  . fegas
/

ppfen_MkupCost37(all_in)   "primary production factors in industry on which CES mark-up cost can be levied that are counted as expenses in the macroeconomic budget equation"
  /
  /


*** ---------------------------------------------------------------------------
***        2. Process-Based
*** ---------------------------------------------------------------------------

*** -----------------------
*** A) one-dimensional sets
*** -----------------------

secInd37Prc(secInd37)   "Sub-sectors with process-based modeling"
  /
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "processes"
  chemicals
$endif.cm_subsec_model_chemicals
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
  steel
$endif.cm_subsec_model_steel
  /

tePrc(all_te)  "Technologies used in process-based model (including CCS)"
  /
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "processes"
    ChemOld
    ChemELec
    ChemH2

    StCrNG
    StCrLiq

    MeSySol !! methanol tech QIANZHI
    MeSyNG
    MeSyLiq
    MeSySolcc
    MeSyNGcc
    MeSyLiqcc
    MeSyH2

    AmSyCoal !! ammonia tech QIANZHI
    AmSyNG
    AmSyLiq
    AmSyCoalcc
    AmSyNGcc
    AmSyLiqcc
    AmSyH2

    MtOMtA
    FertProd
    FertProdH2
    MeToFinal
    AmToFinal
    AmToFinalH2

$endif.cm_subsec_model_chemicals
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
    bf
    bof
    eaf
    idr

    bfcc
    idrcc
$endif.cm_subsec_model_steel
  /

teCCPrc(all_te)   "Technologies used in process-based model (only CCS)"
  /
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
    bfcc
    idrcc
$endif.cm_subsec_model_steel

$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "processes"
    MeSySolcc
    MeSyNGcc
    MeSyLiqcc

    AmSyCoalcc
    AmSyNGcc
    AmSyLiqcc
$endif.cm_subsec_model_chemicals
  /

teCUPrc(all_te)   "Technologies using CO2 as a feedstock"
  /
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "processes"
  MeSyH2
  FertProdH2
$endif.cm_subsec_model_chemicals
  /

mat(all_enty)   "Materials considered in process-based model; Can be input and/or output of a process"
  /
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "processes"
    OtherChem
    HVC
    Fertilizer
    methanol
    ammonia !! ammonia tech QIANZHI
    ammoniaH2
    MethFinal
    AmmoFinal
    co2f
$endif.cm_subsec_model_chemicals
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
    prsteel
    sesteel
    eafscrap
    bofscrap
    pigiron
    driron
    ironore
    dripell
$endif.cm_subsec_model_steel
  /

matIn(all_enty)   "Materials which serve as input to a process"
  /
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "processes"
    methanol
    ammonia
    ammoniaH2
    co2f
$endif.cm_subsec_model_chemicals
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
    eafscrap   "Steel scrap used in EAF"
    bofscrap   "Steel scrap used in BOF"
    pigiron    "Pig iron"
    driron     "Direct reduced iron"
    ironore    "Iron ore"
    dripell    "DRI pellets"
$endif.cm_subsec_model_steel
  /

matOut(all_enty)   "Materials which serve as output of a process"
  /
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "processes"
    OtherChem
    HVC
    Fertilizer
    methanol
    ammonia !! ammonia tech
    ammoniaH2
    MethFinal
    AmmoFinal
$endif.cm_subsec_model_chemicals
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
    prsteel
    sesteel
    pigiron
    driron
$endif.cm_subsec_model_steel
  /

matFin(mat)   "Final products of a process-based production route"
  /
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "processes"
   OtherChem
   HVC
   Fertilizer !! ammonia tech QIANZHI
   MethFinal
   AmmoFinal
$endif.cm_subsec_model_chemicals
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
   prsteel
   sesteel
$endif.cm_subsec_model_steel
  /

opmoPrc   "Operation modes for technologies in process-based model"
  /
    standard   "Only one operation mode implemented"
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "processes"
    greyh2  !! methanol tech QIANZHI
    greenh2        "Input of green hydrogen to adjust the C-H ratio"
$endif.cm_subsec_model_chemicals
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
    ng         "Direct reduction using natural gas"
    h2         "Direct reduction using hydrogen"
    unheated   "BOF operation with maximum amount of scrap possible without external heating"
    pri        "Primary production of steel (based on iron ore or DRI)"
    sec        "Secondary production of steel (based on scrap)"
$endif.cm_subsec_model_steel
  /

ppfUePrc(all_in)   "Ue CES tree nodes connected to process based implementation, which therefore become primary production factors (ppf)"
  /
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "processes"
   ue_chemicals
$endif.cm_subsec_model_chemicals
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
   ue_steel_primary
   ue_steel_secondary
$endif.cm_subsec_model_steel
  /

route(all_te)  "Process routes; Currently only used for reporting"
  /
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "processes"
    ChemRo_Old
    ChemRo_Elec
    ChemRo_H2

    StCrNG_Ro
    StCrLiq_Ro

    MeSyRo_Sol_greyh2 !! methanol tech QIANZHI
    MeSyRo_Sol_greenh2
    MeSyRo_NG
    MeSyRo_Liq
    MeSyRo_Sol_ccs
    MeSyRo_NG_ccs
    MeSyRo_Liq_ccs
    MeSyRo_H2

    AmSyRo_Coal !! ammonia tech QIANZHI
    AmSyRo_NG
    AmSyRo_Liq
    AmSyRo_Coal_ccs
    AmSyRo_NG_ccs
    AmSyRo_Liq_ccs
    AmSyRo_H2

    MtOMtA_Ro
    FertProd_Ro
    FertProdH2_Ro
    MeToFinal_Ro
    AmToFinal_Ro
    AmToFinalH2_Ro
$endif.cm_subsec_model_chemicals
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
    idreaf_ng
    idreaf_ng_ccs
    idreaf_h2
    bfbof
    bfbof_ccs
    seceaf
$endif.cm_subsec_model_steel
  /

ppfen_no_ces_use(all_in)   "FE nodes of all_in that are not part of the CES tree in the process-based industry model; Needed for pm_fedemand data input"
  /
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "processes"
    feso_chemicals
    feli_chemicals
    fega_chemicals
    feh2_chemicals,
    feelhth_chemicals
    feelwlth_chemicals
$endif.cm_subsec_model_chemicals
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
    feso_steel
    feli_steel
    fega_steel
    feh2_steel
    feel_steel_primary
    feel_steel_secondary
$endif.cm_subsec_model_steel
  /

*** -----------------------
*** B) mappings
*** -----------------------

tePrc2opmoPrc(all_te,opmoPrc)   "Mapping of technologies onto available operation modes"
  /
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "processes"
    ChemOld . standard
    ChemELec . standard
    ChemH2 . standard

    StCrNG . standard
    StCrLiq . standard

    MeSySol . (greyh2,greenh2)  !! methanol tech QIANZHI
    MeSyNG . standard
    MeSyLiq . standard
    MeSySolcc . (greyh2)
    MeSyNGcc . standard
    MeSyLiqcc . standard
    MeSyH2 . standard

    AmSyCoal . standard !! ammonia tech QIANZHI
    AmSyNG . standard
    AmSyLiq . standard
    AmSyCoalcc . standard
    AmSyNGcc . standard
    AmSyLiqcc . standard
    AmSyH2 . standard

    MtOMtA . standard
    FertProd . standard
    FertProdH2 . standard
    MeToFinal . standard
    AmToFinal . standard
    AmToFinalH2 . standard
$endif.cm_subsec_model_chemicals
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
    idr . (ng,h2)
    eaf . (pri,sec)
    bf . (standard)
    bof . (unheated)
    bfcc . (standard)
    idrcc . (ng)
$endif.cm_subsec_model_steel
  /

tePrc2matIn(all_te,opmoPrc,mat)   "Mapping of technologies onto input materials"
  /
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "processes"
    FertProd . standard  . ammonia
    FertProdH2 . standard  . ammoniaH2
    MtOMtA . standard  . methanol
    MeToFinal . standard  . methanol
    AmToFinal . standard  . ammonia
    AmToFinalH2 . standard  . ammoniaH2
$endif.cm_subsec_model_chemicals
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
    idr . (h2,ng) . dripell
    eaf . pri . driron
    eaf . sec . eafscrap
    bf  . standard . ironore
    bof . unheated . (pigiron,bofscrap)
$endif.cm_subsec_model_steel
  /

tePrc2matOut(all_te,opmoPrc,mat)   "Mapping of industry process technologies onto their output materials"
  /
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "processes"
   ChemOld . standard . OtherChem
   ChemElec . standard . OtherChem
   ChemH2 . standard . OtherChem

   StCrNG . standard . HVC
   StCrLiq . standard . HVC

   MeSySol   . (greyh2,greenh2) . methanol
   MeSyNG    . standard     . methanol
   MeSyLiq   . standard     . methanol
   MeSyH2    . standard     . methanol

   AmSyCoal . standard . ammonia
   AmSyNG . standard . ammonia
   AmSyLiq . standard . ammonia
   AmSyH2 . standard . ammoniaH2

   MtOMtA . standard . HVC
   FertProd . standard . Fertilizer
   FertProdH2 . standard . Fertilizer
   MeToFinal . standard . MethFinal
   AmToFinal . standard . AmmoFinal
   AmToFinalH2 . standard . AmmoFinal
$endif.cm_subsec_model_chemicals
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
   bf  . standard . pigiron
   bof . unheated . prsteel
   idr . (h2,ng) . driron
   eaf . pri . prsteel
   eaf . sec . sesteel
$endif.cm_subsec_model_steel
  /

tePrc2ue(all_te,opmoPrc,all_in)   "Mapping of industry process technologies to the UE ces nodes they directly or indirectly feed into"
  /
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "processes"
   ChemOld . standard . ue_chemicals
   ChemElec . standard . ue_chemicals
   ChemH2 . standard . ue_chemicals

   StCrNG . standard . ue_chemicals
   StCrLiq . standard . ue_chemicals

   MeSySol             . (greyh2,greenh2)     . ue_chemicals !! methanol tech QIANZHI
   MeSySolcc           . greyh2           . ue_chemicals
   MeSyNG   . standard         . ue_chemicals
   (MeSyLiq,MeSyLiqcc) . standard         . ue_chemicals
   MeSyH2              . standard         . ue_chemicals

   (AmSyCoal,AmSyCoalcc) . standard . ue_chemicals
   (AmSyNG,AmSyNGcc) . standard . ue_chemicals !! ammonia tech QIANZHI
   (AmSyLiq,AmSyLiqcc) . standard . ue_chemicals
   AmSyH2 . standard . ue_chemicals

   MtOMtA . standard . ue_chemicals
   FertProd . standard . ue_chemicals
   FertProdH2 . standard . ue_chemicals
   MeToFinal . standard . ue_chemicals
   AmToFinal . standard . ue_chemicals
   AmToFinalH2 . standard . ue_chemicals

$endif.cm_subsec_model_chemicals
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
   (bf,bfcc)  . standard        . ue_steel_primary
   bof        . unheated        . ue_steel_primary
   idr        . (h2,ng)         . ue_steel_primary
   idrcc      . ng              . ue_steel_primary
   eaf        . pri             . ue_steel_primary
   eaf        . sec             . ue_steel_secondary
$endif.cm_subsec_model_steel
  /

tePrc2teCCPrc(all_te,opmoPrc,all_te,opmoPrc)  "Mapping of base technologies to CCS technologies"
  /
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "processes"
    MeSySol   . greyh2   . MeSySolcc  . greyh2   !! methanol tech QIANZHI
    MeSyNG    . standard . MeSyNGcc   . standard
    MeSyLiq   . standard . MeSyLiqcc  . standard

    AmSyCoal  . standard . AmSyCoalcc  . standard !! ammonia tech QIANZHI
    AmSyNG    . standard . AmSyNGcc    . standard
    AmSyLiq   . standard . AmSyLiqcc    . standard
$endif.cm_subsec_model_chemicals
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
    bf  . standard . bfcc  . standard
    idr . ng       . idrcc . ng
$endif.cm_subsec_model_steel
  /

tePrc2route(all_te,opmoPrc,route)  "Mapping of technologies onto the production routes they belong to"
  /
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "processes"
   ChemOld . standard . ChemRo_Old
   ChemElec . standard . ChemRo_Elec
   ChemH2 . standard . ChemRo_H2

   StCrNG . standard . StCrNG_Ro
   StCrLiq . standard . StCrLiq_Ro

   MeSySol . greenh2       . MeSyRo_Sol_greenh2 !! methanol tech QIANZHI
   MeSySol . greyh2    . MeSyRo_Sol_greyh2
   MeSySol . greyh2    . MeSyRo_Sol_ccs
   MeSyNG  . standard  . MeSyRo_NG
   MeSyNG  . standard  . MeSyRo_NG_ccs
   MeSyLiq . standard  . MeSyRo_Liq
   MeSyLiq . standard  . MeSyRo_Liq_ccs
   MeSySolcc  . greyh2  . MeSyRo_Sol_ccs
   MeSyNGcc   . standard  . MeSyRo_NG_ccs
   MeSyLiqcc  . standard  . MeSyRo_Liq_ccs
   MeSyH2  . standard  . MeSyRo_H2

   AmSyCoal . standard . AmSyRo_Coal !! ammonia tech QIANZHI
   AmSyCoal . standard . AmSyRo_Coal_ccs
   AmSyNG . standard . AmSyRo_NG
   AmSyNG . standard . AmSyRo_NG_ccs
   AmSyLiq . standard . AmSyRo_Liq
   AmSyLiq . standard . AmSyRo_Liq_ccs
   AmSyCoalcc . standard . AmSyRo_Coal_ccs
   AmSyNGcc . standard . AmSyRo_NG_ccs
   AmSyLiqcc . standard . AmSyRo_Liq_ccs
   AmSyH2 . standard . AmSyRo_H2

   MtOMtA . standard . MtOMtA_Ro
   FertProd . standard . FertProd_Ro
   FertProdH2 . standard . FertProdH2_Ro
   MeToFinal . standard . MeToFinal_Ro
   AmToFinal . standard . AmToFinal_Ro
   AmToFinalH2 . standard . AmToFinalH2_Ro
$endif.cm_subsec_model_chemicals
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
    eaf . sec . seceaf
    idr . h2 . idreaf_h2
    idr . ng . idreaf_ng
    idr . ng . idreaf_ng_ccs
    eaf . pri . idreaf_h2
    eaf . pri . idreaf_ng
    eaf . pri . idreaf_ng_ccs
    idrcc . ng . idreaf_ng_ccs
    bf  . standard . bfbof
    bf  . standard . bfbof_ccs
    bof . unheated . bfbof
    bof . unheated . bfbof_ccs
    bfcc . standard . bfbof_ccs
$endif.cm_subsec_model_steel
  /

mat2ue(mat,all_in)   "Mapping of materials (final route products) onto the UE ces tree node the model is connected to"
  /
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "processes"
   OtherChem . ue_chemicals
   HVC   . ue_chemicals
   Fertilizer   . ue_chemicals !! ammonia tech QIANZHI
   MethFinal   . ue_chemicals
   AmmoFinal   . ue_chemicals
$endif.cm_subsec_model_chemicals
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
   prsteel . ue_steel_primary
   sesteel . ue_steel_secondary
$endif.cm_subsec_model_steel
  /

fe2mat(all_enty,all_enty,all_te)   "Set of industry technologies to be included in en2en, which connects capex and opex to budget"
  /
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "processes"
    entydummy.entydummy.ChemOld
    entydummy.entydummy.ChemELec
    entydummy.entydummy.ChemH2

    entydummy.entydummy.StCrNG
    entydummy.entydummy.StCrLiq

    entydummy.entydummy.MeSySol !! methanol tech QIANZHI
    entydummy.entydummy.MeSyNG
    entydummy.entydummy.MeSyLiq
    entydummy.entydummy.MeSySolcc
    entydummy.entydummy.MeSyNGcc
    entydummy.entydummy.MeSyLiqcc
    entydummy.entydummy.MeSyH2

    entydummy.entydummy.AmSyCoal !! ammonia tech QIANZHI
    entydummy.entydummy.AmSyNG
    entydummy.entydummy.AmSyLiq
    entydummy.entydummy.AmSyCoalcc
    entydummy.entydummy.AmSyNGcc
    entydummy.entydummy.AmSyLiqcc
    entydummy.entydummy.AmSyH2

    entydummy.entydummy.MtOMtA
    entydummy.entydummy.FertProd
    entydummy.entydummy.FertProdH2
    entydummy.entydummy.MeToFinal
    entydummy.entydummy.AmToFinal
    entydummy.entydummy.AmToFinalH2
$endif.cm_subsec_model_chemicals
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
    entydummy.entydummy.bf
    entydummy.entydummy.bof
    entydummy.entydummy.idr
    entydummy.entydummy.eaf
    entydummy.entydummy.bfcc
    entydummy.entydummy.idrcc
$endif.cm_subsec_model_steel
  /

secInd37_tePrc(secInd37,all_te)   "Mapping of technologies onto industry subsectors"
  /
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "processes"
    chemicals . ChemOld
    chemicals . ChemElec
    chemicals . ChemH2

    chemicals . StCrNG
    chemicals . StCrLiq

    chemicals . MeSySol !! methanol tech QIANZHI
    chemicals . MeSyNG
    chemicals . MeSyLiq
    chemicals . MeSySolcc
    chemicals . MeSyNGcc
    chemicals . MeSyLiqcc
    chemicals . MeSyH2

    chemicals . AmSyCoal !! ammonia tech QIANZHI
    chemicals . AmSyNG
    chemicals . AmSyLiq
    chemicals . AmSyCoalcc
    chemicals . AmSyNGcc
    chemicals . AmSyLiqcc
    chemicals . AmSyH2

    chemicals . MtOMtA
    chemicals . FertProd
    chemicals . FertProdH2
    chemicals . MeToFinal
    chemicals . AmToFinal
    chemicals . AmToFinalH2
$endif.cm_subsec_model_chemicals
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
    steel . idr
    steel . eaf
    steel . bf
    steel . bof

    steel . bfcc
    steel . idrcc
$endif.cm_subsec_model_steel
  /

fe2ppfen_no_ces_use(all_enty,all_in)   "Match ESM entyFe to ppfen that are not used in the CES tree, but for datainput for process-bases industry"
  /
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "processes"
    fesos . feso_chemicals
    fehos . feli_chemicals
    fegas . fega_chemicals
    feels . (feelhth_chemicals, feelwlth_chemicals)
$endif.cm_subsec_model_chemicals
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
    fesos . feso_steel
    fehos . feli_steel
    fegas . fega_steel
    feels . (feel_steel_primary, feel_steel_secondary)
$endif.cm_subsec_model_steel
  /

ue2ppfenPrc(all_in,all_in)   "correspondant to ces_eff_target_dyn37, but for use in process-based context, i.e. contained subsectors are complements"
  /
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
    ue_steel_primary . (feso_steel, feli_steel, fega_steel, feh2_steel,
                        feel_steel_primary)

    ue_steel_secondary . feel_steel_secondary
$endif.cm_subsec_model_steel
  /

regi_fxDem37(ext_regi) "regions under which we fix UE demand to baseline demand"
  /
$ifthen.fixedUE_scenario "%cm_fxIndUe%" == "on"
    %cm_fxIndUeReg%
$endif.fixedUE_scenario
  /
;

*** ---------------------------------------------------------------------------
***        add module-specifc sets and mappings to the global ones
*** ---------------------------------------------------------------------------
ppf_industry_dyn37(ppfKap_industry_dyn37)                              = YES;
ppf_industry_dyn37(ppfen_industry_dyn37)                               = YES;
ppf_industry_dyn37(ppfUePrc)                                           = YES;
ipf_industry_dyn37(in_industry_dyn37)                                  = YES;
ipf_industry_dyn37(ppf_industry_dyn37)                                 = NO;
in(in_industry_dyn37)                                                  = YES;
ppfKap(ppfKap_industry_dyn37)                                          = YES;
ppfEn(ppfen_industry_dyn37)                                            = YES;
cesOut2cesIn(ces_industry_dyn37)                                       = YES;
fe2ppfEn(fe2ppfEn37)                                                   = YES;
pf_eff_target_dyn37(ppfen_industry_dyn37)                              = YES;
pf_quan_target_dyn37(ppfKap_industry_dyn37)                            = YES;
pf_industry_relaxed_bounds_dyn37(ppf_industry_dyn37)                   = YES;
pf_industry_relaxed_bounds_dyn37(industry_ue_calibration_target_dyn37) = YES;

ppfen_CESMkup(ppfen_industry_dyn37) = YES;

$ifthen.calibrate "%CES_parameters%" == "calibrate"   !! CES_parameters
pf_eff_target_dyn29(pf_eff_target_dyn37)    = YES;
pf_quan_target_dyn29(pf_quan_target_dyn37)  = YES;
$endif.calibrate

teMat2rlf(tePrc,"1") = YES;
alias(tePrc,tePrc1,tePrc2);
alias(opmoPrc,opmoCCPrc,opmoPrc1,opmoPrc2);
alias(route,route2);
alias(entyFeCC37,entyFeCC37_2);
alias(secInd37_2_pf,secInd37_2_pf2);
alias(fe2ppfEn37,fe2ppfEn37_2);
*** EOF ./modules/37_industry/subsectors/sets.gms
