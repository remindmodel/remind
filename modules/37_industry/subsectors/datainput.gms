*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/subsectors/datainput.gms

vm_macBaseInd.l(ttot,regi,entyFE,secInd37) = 0;

*** substitution elasticities
Parameter 
  p37_cesdata_sigma(all_in)  "substitution elasticities"
  /
    ue_industry                      1.1   !! cement - chemicals - steel - other

      ue_cement                      1.7   !! energy - capital
        en_cement                    1.3   !! non-electric - electric
          en_cement_non_electric     2.0   !! solids - liquids - gases - hydrogen

      ue_chemicals                   1.7   !! energy - capital
        en_chemicals                 1.3   !! carbonous - non-carbonous
          en_chemicals_carbon        2.0   !! solids - liquids - gases
          en_chemicals_non_carbon    1.7   !! hydrogen - electricity

      ue_steel                       5     !! primary steel - secondary steel
        ue_steel_primary             1.7   !! energy - capital
          en_steel_primary           1.3   !! furnace - electricity
            en_steel_furnace         2.0   !! solids - liquids - gases - hydrogen
        ue_steel_secondary           1.7   !! energy - capital

      ue_otherInd                    1.7   !! energy - capital
        en_otherInd                  1.3   !! non-electric - electricity
          en_otherInd_non_electric   2.0   !! solids - liquids - gases - hydrogen - heat
  /
;
pm_cesdata_sigma(ttot,in)$p37_cesdata_sigma(in) = p37_cesdata_sigma(in);

*** abatement parameters for industry CCS MACs
$include "./modules/37_industry/fixed_shares/input/pm_abatparam_Ind.gms";

if (cm_IndCCSscen eq 1,
  if (cm_CCS_cement eq 1,
    
    emiMac2mac("co2cement_process","co2cement") = YES;
     );
   );

*** assume 50 year lifetime for industry energy efficiency capital
pm_delta_kap(regi,ppfKap_industry_dyn37) = -log(1 / 4) / 50;

p37_energy_limit("ue_cement","en_cement")                     = 100;
p37_energy_limit("ue_steel_primary","en_steel_primary")       = 100;
p37_energy_limit("ue_steel_secondary","feel_steel_secondary") = 100;

*** EOF ./modules/37_industry/subsectors/datainput.gms

