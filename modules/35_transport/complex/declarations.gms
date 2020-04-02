*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/35_transport/complex/declarations.gms

Positive variables
vm_shUePeT(ttot,all_regi,all_te)             "share of the Uepet production from a certain LDV type in the total Uepet production. Unit: percent"
;

equations
q35_shUePeT(ttot,all_regi,all_te)             "calculate share of the Uepet production from a certain LDV type in the total Uepet production"
q35_shUePeTbal(ttot,all_regi)                 "shares sum must be equal to 100"
;

Parameter
p35_pass_FE_share_transp(ttot,all_regi)            "Share of 'non-LDV passenger FE' in 'total non-LDV FE. Unit: share [0..1]"
p35_pass_nonLDV_ES_efficiency(ttot,all_regi)  "Non-LDV passenger energy service per non-LDV FE. Unit: bn pkm/EJ"
p35_passLDV_ES_efficiency(ttot,all_regi)      "LDV passenger energy service per non-LDV FE. Only correct if applied to CES-input, as BEV and H2FCV have higher efficiencies. Unit: bn pkm/EJ"
p35_freight_ES_efficiency(ttot,all_regi)      "Freight energy service per freight FE. Unit: bn tkm/EJ"

p35_pass_FE_target_share    "The target share for the harmonization of non-LDV passenger FE (p35_pass_FE_share_transp). Unit: share [0..1]"
p35_harmonizing_year        "Year when full harmonization of shares and efficiencies would be reached."

p35_share_seliq_t(ttot,all_regi)                               "share of liquids used for transport sector (fedie + fepet). Unit 0..1"
p35_share_seh2_t(ttot,all_regi)                                "share of hydrogen used for transport sector  (feh2t). Unit 0..1"
p35_share_seel_t(ttot,all_regi)                                "Share of electricity used for transport sector (feelt). Unit 0..1"
;

*** EOF ./modules/35_transport/complex/declarations.gms
