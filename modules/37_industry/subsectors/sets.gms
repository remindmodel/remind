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
    chemOld       "process to produce otherChem with historic FE demand"
    chemElec      "process to produce otherChem with higher share of feels and improved efficiency"
    chemH2        "process to produce otherChem with higher share of feh2s"

    stCrNg        "ethane/propane steam cracking"
    stCrLiq       "naphtha steam cracking"
    stCrChemRe    "pyrolysis (chemical recycling) of plastic waste"

    mechRe        "mechanical recycling of plastic waste"

    meSySol       "methanol synthesis from coal/biomass"
    meSyNg        "methanol synthesis from NG"
    meSyLiq       "methanol synthesis from oil"
    meSySol_cc    "CC for methanol synthesis from coal/biomass"
    meSyNg_cc     "CC for methanol synthesis from NG"
    meSyLiq_cc    "CC for methanol synthesis from oil"
    meSyH2        "methanol synthesis from hydrogen"
    meSyChemRe    "gasification (chemical recycling) of plastic waste"

    amSyCoal      "ammonia synthesis from coal/biomass"
    amSyNG        "ammonia synthesis from NG"
    amSyLiq       "ammonia synthesis from oil"
    amSyCoal_cc   "CC for ammonia synthesis from coal/biomass"
    amSyNG_cc     "CC for ammonia synthesis from NG"
    amSyLiq_cc    "CC for ammonia synthesis from oil"
    amSyH2        "Ammonia synthesis from hydrogen"

    !! differentiate between mtoMta and mtoMtaH2 such that the share of mtoMta (the old technology) can be constrained
    !! after liquids disaggregation by Robert there can be a more specific set differentiating between coal and biomass
    !! same for fertilizer prod; fertProdH2 needs carbon feedstock
    mtoMta        "Methanol to olefins/methanol to aromatics (production of HVC from methanol from fossil feedstocks)"
    mtoMtaH2      "mtoMta from green methanol"
    fertProd      "Fertilizer production from ammonia from fossil feedstocks"
    fertProdH2    "Fertilizer production from green ammonia"
    meToFinal     "dummy process to convert methanol or methanolH2 to methFinal"
    amToFinal     "dummy process to convert ammonia or ammoniaH2 to ammoFinal"

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
    !! maybe add cc for heat generation part of steam cracker, but may not be worth it because we switch to H2 or electricity for heat generation
    meSySol_cc    
    meSyNg_cc     
    meSyLiq_cc    

    amSyCoal_cc   
    amSyNG_cc     
    amSyLiq_cc    
$endif.cm_subsec_model_chemicals
  /

teCUPrc(all_te)   "Technologies using CO2 as a feedstock"
  /
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "processes"
  meSyH2
  fertProdH2
$endif.cm_subsec_model_chemicals
  /

mat(all_enty)   "Materials considered in process-based model; Can be input and/or output of a process"
  /
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "processes"
    otherChem     "All other chemicals not covered in the specific process-representation"
    hvc           "High-value chemicals; consist of ethylene, propylene and BTX"
    fertilizer    "Nitrogen fertilizer; consists of urea, ammonium nitrate, ammonium sulfate and calcium ammonium nitrate"
    methanol      "Methanol produced from fesos, fehos or fegas; intermediate product"
    methanolH2    "Methanol produced from hydrogen or gasification of plastic waste (differentiation from methanol in order to restrict historic shares of mtoMta); intermediate product"
    ammonia       "Ammonia produced from fesos, fehos or fegas; intermediate product"
    ammoniaH2     "Ammonia produced from hydrogen (needs co2f input in fertilizer production in difference to ammonia)"
    methFinal     "Methanol; final product"
    ammoFinal     "Ammonia; final product"
    !! REMINDER: once we co2f from the CCU module, make sure that it isn't subtracted twice (once by taking it from CCU, once by subtracting feedstock carbon)
    co2f
    co2fdummy 

    naphtha       "Naphtha"
    plasticWaste  "Plastic waste, mixed"
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
    methanolH2
    ammonia
    ammoniaH2
    co2f
    co2fdummy

    naphtha
    plasticWaste
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
    otherChem
    hvc
    fertilizer
    methanol
    methanolH2
    ammonia !! ammonia tech
    ammoniaH2
    methFinal
    ammoFinal
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
   otherChem
   hvc
   fertilizer 
   methFinal
   ammoFinal
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
    greenh2    "Input of green hydrogen to adjust the C-H ratio"
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

     otherChem_old
     otherChem_elec
     otherChem_h2
     
     mech_recycle

     hvc_stCrLiq
     hvc_stCrNg
     hvc_stCrChemRe
     hvc_meSol
     hvc_meNg
     hvc_meLiq
     hvc_meSol_gh2
     hvc_meSol_cc
     hvc_meNg_cc
     hvc_meLiq_cc
     hvc_meh2
     hvc_mechemRe

     fertilizer_amSol
     fertilizer_amNg
     fertilizer_amLiq
     fertilizer_amLiq_cc
     fertilizer_amNg_cc
     fertilizer_amSol_cc
     fertilizer_amh2

     meFinal_sol
     meFinal_ng
     meFinal_liq
     meFinal_sol_gh2
     meFinal_sol_cc
     meFinal_ng_cc
     meFinal_liq_cc
     meFinal_h2
     meFinal_chemRe

     amFinal_sol
     amFinal_ng
     amFinal_liq
     amFinal_sol_cc
     amFinal_ng_cc
     amFinal_liq_cc
     amFinal_h2
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
    chemOld . standard
    chemElec . standard
    chemH2 . standard

    stCrNg . standard
    stCrLiq . standard
    stCrChemRe . standard

    mechRe . standard

    meSySol . (standard,greenh2) !! methanol synthesis needs hydrogen apart from coal, can be from green hydrogen or coal gasification
    meSyNg . standard
    meSyLiq . standard
    meSySol_cc . standard
    meSyNg_cc . standard
    meSyLiq_cc . standard
    meSyH2 . standard
    meSyChemRe . standard

    amSyCoal . standard 
    amSyNG . standard
    amSyLiq . standard
    amSyCoal_cc . standard
    amSyNG_cc . standard
    amSyLiq_cc . standard
    amSyH2 . standard

    mtoMta . standard
    mtoMtaH2 . standard
    fertProd . standard
    fertProdH2 . standard
    meToFinal . (standard,greenh2) 
    amToFinal . (standard,greenh2)
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
    fertProd . standard  . ammonia
    fertProdH2 . standard  . ammoniaH2
    mtoMta . standard  . methanol
    mtoMtaH2 . standard  . methanolH2
    meToFinal . standard  . methanol
    meToFinal . greenh2  . methanolH2
    amToFinal . standard  . ammonia
    amToFinal . greenh2  . ammoniaH2

    meSyH2 . standard  . co2fdummy
    fertProdH2 . standard  . co2fdummy
    stCrLiq . standard  . naphtha

    mechRe . standard  . plasticWaste
    stCrChemRe . standard  . plasticWaste
    meSyChemRe . standard  . plasticWaste
    
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
   chemOld . standard . otherChem
   chemElec . standard . otherChem
   chemH2 . standard . otherChem

   stCrNg . standard . hvc
   stCrLiq . standard . hvc
   stCrChemRe . standard . hvc
   mechRe . standard . hvc

   meSySol   . (standard,greenh2) . methanol
   meSyNg    . standard     . methanol
   meSyLiq   . standard     . methanol
   meSyH2    . standard     . methanolH2
   meSyChemRe    . standard     . methanolH2

   amSyCoal . standard . ammonia
   amSyNG . standard . ammonia
   amSyLiq . standard . ammonia
   amSyH2 . standard . ammoniaH2

   mtoMta . standard . hvc
   mtoMtaH2 . standard . hvc
   fertProd . standard . fertilizer
   fertProdH2 . standard . fertilizer
   meToFinal . (standard,greenh2) . methFinal
   amToFinal . (standard,greenh2) . ammoFinal
$endif.cm_subsec_model_chemicals
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
   bf  . standard . pigiron
   bof . unheated . prsteel
   idr . (h2,ng) . driron
   eaf . pri . prsteel
   eaf . sec . sesteel
$endif.cm_subsec_model_steel
  /

matStiffShare(all_enty)   "Materials with restricted change of relative process volume shares"
  /
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "processes"
   hvc
   methanol
   ammonia
$endif.cm_subsec_model_chemicals
  /

tePrcStiffShare(all_te,opmoPrc,all_enty)   "Industry process technologies with restricted change of relative shares"
  /
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "processes"

   stCrNg  . standard . hvc
   stCrLiq . standard . hvc
   mtoMta  . standard . hvc

   meSySol . standard . methanol
   meSyNg  . standard . methanol
   meSyLiq . standard . methanol

   amSyCoal . standard . ammonia
   amSyNG   . standard . ammonia
   amSyLiq  . standard . ammonia

$endif.cm_subsec_model_chemicals
  /

tePrc2ue(all_te,opmoPrc,all_in)   "Mapping of industry process technologies to the UE ces nodes they directly or indirectly feed into"
  /
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "processes"
   chemOld . standard . ue_chemicals
   chemElec . standard . ue_chemicals
   chemH2 . standard . ue_chemicals

   stCrNg . standard . ue_chemicals
   stCrLiq . standard . ue_chemicals
   stCrChemRe . standard . ue_chemicals
   mechRe . standard . ue_chemicals

   meSySol             . (standard,greenh2)     . ue_chemicals 
   meSySol_cc           . standard           . ue_chemicals
   meSyNg   . standard         . ue_chemicals
   (meSyLiq,meSyLiq_cc) . standard        . ue_chemicals
   meSyH2               . standard        . ue_chemicals
   meSyChemRe           . standard        . ue_chemicals

   (amSyCoal,amSyCoal_cc) . standard . ue_chemicals
   (amSyNG,amSyNG_cc) . standard . ue_chemicals 
   (amSyLiq,amSyLiq_cc) . standard . ue_chemicals
   amSyH2 . standard . ue_chemicals

   mtoMta . standard . ue_chemicals
   mtoMtaH2 . standard . ue_chemicals
   fertProd . standard . ue_chemicals
   fertProdH2 . standard . ue_chemicals
   meToFinal . (standard,greenh2) . ue_chemicals
   amToFinal . (standard,greenh2) . ue_chemicals

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
    meSySol   . standard . meSySol_cc  . standard   
    meSyNg    . standard . meSyNg_cc   . standard
    meSyLiq   . standard . meSyLiq_cc  . standard

    amSyCoal  . standard . amSyCoal_cc  . standard 
    amSyNG    . standard . amSyNG_cc    . standard
    amSyLiq   . standard . amSyLiq_cc    . standard
$endif.cm_subsec_model_chemicals
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
    bf  . standard . bfcc  . standard
    idr . ng       . idrcc . ng
$endif.cm_subsec_model_steel
  /

tePrc2route(all_te,opmoPrc,route)  "Mapping of technologies onto the production routes they belong to"
  /
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "processes"

   chemOld  . standard . otherChem_old
   chemElec . standard . otherChem_elec
   chemH2   . standard . otherChem_h2

   stCrNg    . standard . hvc_stCrLiq
   stCrLiq   . standard . hvc_stCrNg
   stCrChemRe. standard . hvc_stCrChemRe

   mechRe    . standard . mech_recycle

   meSySol   . standard . (hvc_meSol,     meFinal_sol, hvc_meSol_cc,  meFinal_sol_cc)
   meSyNg    . standard . (hvc_meNg,      meFinal_ng,  hvc_meNg_cc,   meFinal_ng_cc)
   meSyLiq   . standard . (hvc_meLiq,     meFinal_liq, hvc_meLiq_cc,  meFinal_liq_cc)
   meSySol   . greenh2  . (hvc_meSol_gh2, meFinal_sol_gh2)
   meSySol_cc . standard . (hvc_meSol_cc,  meFinal_sol_cc)
   meSyNg_cc  . standard . (hvc_meNg_cc,   meFinal_ng_cc)
   meSyLiq_cc . standard . (hvc_meLiq_cc,  meFinal_liq_cc)
   meSyH2    . standard . (hvc_meh2,      meFinal_h2)
   meSyChemRe    . standard . (hvc_mechemRe,      meFinal_chemRe)

   amSyCoal   . standard . (fertilizer_amSol,    amFinal_sol, fertilizer_amSol_cc, amFinal_sol_cc)
   amSyNG     . standard . (fertilizer_amNg,     amFinal_ng,  fertilizer_amNg_cc,  amFinal_ng_cc)
   amSyLiq    . standard . (fertilizer_amLiq,    amFinal_liq, fertilizer_amLiq_cc, amFinal_liq_cc)
   amSyCoal_cc . standard . (fertilizer_amSol_cc, amFinal_sol_cc)
   amSyNG_cc   . standard . (fertilizer_amNg_cc,  amFinal_ng_cc)
   amSyLiq_cc  . standard . (fertilizer_amLiq_cc, amFinal_liq_cc)
   amSyH2     . standard . (fertilizer_amh2,     amFinal_h2)

   mtoMta     . standard . (hvc_meSol, hvc_meSol_gh2, hvc_meNg, hvc_meLiq,
                            hvc_meSol_cc, hvc_meNg_cc, hvc_meLiq_cc)
   mtoMtaH2   . standard . hvc_meh2
   fertProd   . standard . (fertilizer_amSol, fertilizer_amNg, fertilizer_amLiq,
                            fertilizer_amSol_cc, fertilizer_amNg_cc, fertilizer_amLiq_cc)
   fertProdH2 . standard . fertilizer_amh2
   meToFinal  . standard . (meFinal_sol, meFinal_sol_gh2, meFinal_ng, meFinal_liq,
                            meFinal_sol_cc, meFinal_ng_cc, meFinal_liq_cc)
   meToFinal  . greenh2  . meFinal_h2
   amToFinal  . standard . (amFinal_sol, amFinal_ng, amFinal_liq,
                            amFinal_sol_cc, amFinal_ng_cc, amFinal_liq_cc)
   amToFinal  . greenh2  . amFinal_h2
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
  
  
!! for reporting
routeCC(route)  "TODO"
  /
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "processes"
    hvc_meSol_cc
    hvc_meNg_cc
    hvc_meLiq_cc
    fertilizer_amLiq_cc
    fertilizer_amNg_cc
    fertilizer_amSol_cc
    meFinal_sol_cc
    meFinal_ng_cc
    meFinal_liq_cc
    amFinal_sol_cc
    amFinal_ng_cc
    amFinal_liq_cc

$endif.cm_subsec_model_chemicals
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
    idreaf_ng_ccs
    bfbof_ccs
$endif.cm_subsec_model_steel
  /

routeCC2baseRoute(route,route) "TODO"
  /
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "processes"
    hvc_meSol_cc         . hvc_meSol
    hvc_meNg_cc          . hvc_meNg
    hvc_meLiq_cc         . hvc_meLiq
    fertilizer_amLiq_cc  . fertilizer_amLiq
    fertilizer_amNg_cc   . fertilizer_amNg
    fertilizer_amSol_cc  . fertilizer_amSol
    meFinal_sol_cc       . meFinal_sol
    meFinal_ng_cc        . meFinal_ng
    meFinal_liq_cc       . meFinal_liq
    amFinal_sol_cc       . amFinal_sol
    amFinal_ng_cc        . amFinal_ng
    amFinal_liq_cc       . amFinal_liq
$endif.cm_subsec_model_chemicals
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
    idreaf_ng_ccs        . idreaf_ng
    bfbof_ccs            . bfbof
$endif.cm_subsec_model_steel
  /

mat2ue(mat,all_in)   "Mapping of materials (final route products) onto the UE ces tree node the model is connected to"
  /
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "processes"
   otherChem . ue_chemicals
   hvc   . ue_chemicals
   fertilizer   . ue_chemicals 
   methFinal   . ue_chemicals
   ammoFinal   . ue_chemicals
$endif.cm_subsec_model_chemicals
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
   prsteel . ue_steel_primary
   sesteel . ue_steel_secondary
$endif.cm_subsec_model_steel
  /

fe2mat(all_enty,all_enty,all_te)   "Set of industry technologies to be included in en2en, which connects capex and opex to budget"
  /
$ifthen.cm_subsec_model_chemicals "%cm_subsec_model_chemicals%" == "processes"
    entydummy.entydummy.chemOld
    entydummy.entydummy.chemElec
    entydummy.entydummy.chemH2

    entydummy.entydummy.stCrNg
    entydummy.entydummy.stCrLiq
    entydummy.entydummy.stCrChemRe

    entydummy.entydummy.mechRe

    entydummy.entydummy.meSySol 
    entydummy.entydummy.meSyNg
    entydummy.entydummy.meSyLiq
    entydummy.entydummy.meSySol_cc
    entydummy.entydummy.meSyNg_cc
    entydummy.entydummy.meSyLiq_cc
    entydummy.entydummy.meSyH2
    entydummy.entydummy.meSyChemRe

    entydummy.entydummy.amSyCoal 
    entydummy.entydummy.amSyNG
    entydummy.entydummy.amSyLiq
    entydummy.entydummy.amSyCoal_cc
    entydummy.entydummy.amSyNG_cc
    entydummy.entydummy.amSyLiq_cc
    entydummy.entydummy.amSyH2

    entydummy.entydummy.mtoMta
    entydummy.entydummy.mtoMtaH2
    entydummy.entydummy.fertProd
    entydummy.entydummy.fertProdH2
    entydummy.entydummy.meToFinal
    entydummy.entydummy.amToFinal

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
    chemicals . chemOld
    chemicals . chemElec
    chemicals . chemH2

    chemicals . stCrNg
    chemicals . stCrLiq
    chemicals . stCrChemRe

    chemicals . mechRe

    chemicals . meSySol
    chemicals . meSyNg
    chemicals . meSyLiq
    chemicals . meSySol_cc
    chemicals . meSyNg_cc
    chemicals . meSyLiq_cc
    chemicals . meSyH2
    chemicals . meSyChemRe

    chemicals . amSyCoal
    chemicals . amSyNG
    chemicals . amSyLiq
    chemicals . amSyCoal_cc
    chemicals . amSyNG_cc
    chemicals . amSyLiq_cc
    chemicals . amSyH2

    chemicals . mtoMta
    chemicals . mtoMtaH2
    chemicals . fertProd
    chemicals . fertProdH2
    chemicals . meToFinal
    chemicals . amToFinal

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
alias(tePrc,tePrc1,tePrc2,tePrc3);
alias(opmoPrc,opmoCCPrc,opmoPrc1,opmoPrc2,opmoPrc3);
alias(route,route2);
alias(entyFeCC37,entyFeCC37_2);
alias(secInd37_2_pf,secInd37_2_pf2);
alias(fe2ppfEn37,fe2ppfEn37_2);
*** EOF ./modules/37_industry/subsectors/sets.gms
