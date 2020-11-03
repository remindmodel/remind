*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/subsectors/datainput.gms

vm_macBaseInd.l(ttot,regi,entyFE,secInd37) = 0;

*** substitution elasticities
Parameter 
  p37_cesdata_sigma(all_in)  "industry substitution elasticities"
  /
    ue_industry                      0.5   !! cement - chemicals - steel - other

      ue_cement                      1.7   !! energy, capital
        en_cement                    0.7   !! non-electric, electric
          en_cement_non_electric     2.0   !! solids, liquids, gases, hydrogen

      ue_chemicals                   1.7   !! energy, capital
        en_chemicals                 0.7   !! fuels and high-temperature heat, electricity
          en_chemicals_fhth          3.0   !! solids, liquids, gases, electricity

      ue_steel                       5     !! primary steel, secondary steel
        ue_steel_primary             1.7   !! energy, capital
          en_steel_primary           0.7   !! furnace, electricity
            en_steel_furnace         2.0   !! solids, liquids, gases, hydrogen
        ue_steel_secondary           1.7   !! energy, capital

      ue_otherInd                    1.7   !! energy, capital
        en_otherInd                  0.7   !! high-temperature heat, electricity
          en_otherInd_hth            2.0   !! solids, liquids, gases, hydrogen, heat
  /
;
pm_cesdata_sigma(ttot,in)$( p37_cesdata_sigma(in) ) = p37_cesdata_sigma(in);

*** converge substitution elasticities until 2105
loop (cesOUt2cesIn(out,in)$(   sameas(in,"en_chemicals") 
                            OR sameas(in,"en_otherInd")  ),
  pm_cesdata_sigma(ttot,out)$( ttot.val ge 2005 )
  = p37_cesdata_sigma(out)
  + (p37_cesdata_sigma(in) - p37_cesdata_sigma(out))
  * min(1, (ttot.val - 2005) / 100);
);

*** abatement parameters for industry CCS MACs
$include "./modules/37_industry/fixed_shares/input/pm_abatparam_Ind.gms";

if (cm_IndCCSscen eq 1,
  if (cm_CCS_cement eq 1,
    
    emiMac2mac("co2cement_process","co2cement") = YES;
     );
   );

*** assume 50 year lifetime for industry energy efficiency capital
pm_delta_kap(regi,ppfKap_industry_dyn37) = -log(1 / 4) / 50;

*** FIXME: this is temporary data, insert meaningful figures!
p37_energy_limit("ue_cement")          =  10000;
p37_energy_limit("ue_steel_primary")   =  10000;
p37_energy_limit("ue_steel_secondary") = 100000;

*' Emission factors for calculating industry emissions
p37_fctEmi("fesos") = fm_dataemiglob("pecoal","sesofos", "coaltr","co2");
p37_fctEmi("fehos") = fm_dataemiglob("peoil", "seliqfos","refliq","co2");
p37_fctEmi("fegas") = fm_dataemiglob("pegas", "segafos", "gastr", "co2");

*** CCS for industry is off by default
emiMacSector(emiInd37_fuel) = NO;
pm_macSwitch(emiInd37)      = NO;

*** turn on CCS for industry emissions
if (cm_IndCCSscen eq 1,
  if (cm_CCS_cement eq 1,
    emiMacSector("co2cement") = YES;
    pm_macSwitch("co2cement") = YES;
    pm_macSwitch("co2cement_process") = YES;
    emiMac2mac("co2cement","co2cement") = YES;
    emiMac2mac("co2cement_process","co2cement") = YES;
  );

  if (cm_CCS_chemicals eq 1,
    emiMacSector("co2chemicals") = YES;
    pm_macSwitch("co2chemicals") = YES;
    emiMac2mac("co2chemicals","co2chemicals") = YES;
  );

  if (cm_CCS_steel eq 1,
    emiMacSector("co2steel") = YES;
    pm_macSwitch("co2steel") = YES;
    emiMac2mac("co2steel","co2steel") = YES;
  );
);

*** CCS for other industry is off in any case
emiMacSector("co2otherInd") = NO;
pm_macSwitch("co2otherInd") = NO;
emiMac2mac("co2otherInd","co2otherInd") = NO;

*** data on maximum secondary steel production
Parameter 
  p37_cesIO_up_steel_secondary(tall,all_regi,all_GDPscen)   "upper limit to secondary steel production based on scrap availability"
  /
$ondelim
$include "./modules/37_industry/subsectors/input/p37_cesIO_up_steel_secondary.inc";
$offdelim
  /
;

s37_clinker_process_CO2 = 0.5262;

*** FIXME *** this needs to be in moinput
p37_clinker_cement_ratio("2005","CAZ") = 0.81;
p37_clinker_cement_ratio("2005","CHA") = 0.58;
p37_clinker_cement_ratio("2005","EUR") = 0.73;
p37_clinker_cement_ratio("2005","IND") = 0.71;
p37_clinker_cement_ratio("2005","JPN") = 0.80;
p37_clinker_cement_ratio("2005","LAM") = 0.70;
p37_clinker_cement_ratio("2005","MEA") = 0.81;
p37_clinker_cement_ratio("2005","NEU") = 0.81;
p37_clinker_cement_ratio("2005","OAS") = 0.80;
p37_clinker_cement_ratio("2005","REF") = 0.80;
p37_clinker_cement_ratio("2005","SSA") = 0.77;
p37_clinker_cement_ratio("2005","USA") = 0.82;

*' Clinker-to-cement ratios converge to the lowest regional 2005 value by 2100.
p37_clinker_cement_ratio(t,regi)
  = p37_clinker_cement_ratio("2005",regi)
  + ( smin(regi2, p37_clinker_cement_ratio("2005",regi2))
    - p37_clinker_cement_ratio("2005",regi)
    )
  * (min(t.val, 2100) - 2005)
  / (2100             - 2005);

*** Cement demand reduction is implicit in the production function, so no extra
*** costs have to be calculated.
pm_CementDemandReductionCost(ttot,regi) = 0;

if (cm_emiscen ne 1,
  Execute_Loadpoint "input_ref.gdx" p37_cesIO_base = vm_cesIO.l;
);

*** FIXME calibration debug
Parameter
  p37_arcane_FE_limits(all_in,all_in)   "minimum ratio of feelhth/feelwlth and feh2/fega (may be needed for calibration)"
  /
    feh2_cement       . fega_cement          1e-5
    feh2_chemicals    . fega_chemicals       1e-5
    feh2_steel        . fega_steel           1e-5
    feh2_otherInd     . fega_otherInd        1e-5
    feelhth_chemicals . feelwlth_chemicals   1e-5
    feelhth_otherInd  . feelwlth_otherInd    1e-5
  /
;
*** end FIXME calibration debug

* Parameters for scaling the efficiencies of feelhth_X and feh2_X towards that
* of fega_X over time.
$ontext saved for when gms::codeCheck() can handle tables properly
Table pm_calibrate_eff_scale(all_in,all_in,eff_scale_par)   "parameters for scaling efficiencies in CES calibration"
                                         level   midperiod   width
    feelhth_chemicals . fega_chemicals   1.5     2030        15
    feelhth_otherInd  . fega_otherInd    1.5     2030        15

    feh2_cement       . fega_cement      1.4     2030        22
    feh2_chemicals    . fega_chemicals   1.4     2030        22
    feh2_steel        . fega_steel       1.4     2030        22
    feh2_otherInd     . fega_otherInd    1.4     2030        22
;
$offtext

pm_calibrate_eff_scale("feelhth_chemicals","fega_chemicals","level")     = 1.5;
pm_calibrate_eff_scale("feelhth_chemicals","fega_chemicals","midperiod") = 2030;
pm_calibrate_eff_scale("feelhth_chemicals","fega_chemicals","width")     = 15;
pm_calibrate_eff_scale("feelhth_otherInd","fega_otherInd","level")       = 1.5;
pm_calibrate_eff_scale("feelhth_otherInd","fega_otherInd","midperiod")   = 2030;
pm_calibrate_eff_scale("feelhth_otherInd","fega_otherInd","width")       = 15;
pm_calibrate_eff_scale("feh2_cement","fega_cement","level")              = 1.4;
pm_calibrate_eff_scale("feh2_cement","fega_cement","midperiod")          = 2030;
pm_calibrate_eff_scale("feh2_cement","fega_cement","width")              = 22;
pm_calibrate_eff_scale("feh2_chemicals","fega_chemicals","level")        = 1.4;
pm_calibrate_eff_scale("feh2_chemicals","fega_chemicals","midperiod")    = 2030;
pm_calibrate_eff_scale("feh2_chemicals","fega_chemicals","width")        = 22;
pm_calibrate_eff_scale("feh2_steel","fega_steel","level")                = 1.4;
pm_calibrate_eff_scale("feh2_steel","fega_steel","midperiod")            = 2030;
pm_calibrate_eff_scale("feh2_steel","fega_steel","width")                = 22;
pm_calibrate_eff_scale("feh2_otherInd","fega_otherInd","level")          = 1.4;
pm_calibrate_eff_scale("feh2_otherInd","fega_otherInd","midperiod")      = 2030;
pm_calibrate_eff_scale("feh2_otherInd","fega_otherInd","width")          = 22;

pm_ue_eff_target("ue_cement")           = 0.0075;
pm_ue_eff_target("ue_chemicals")        = 0.001;
pm_ue_eff_target("ue_steel_primary")    = 0.0075;
pm_ue_eff_target("ue_steel_secondary")  = 0.005;
pm_ue_eff_target("ue_otherInd")         = 0.0075;

*** EOF ./modules/37_industry/subsectors/datainput.gms

