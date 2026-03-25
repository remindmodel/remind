*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/11_aerosols/exoGAINS2025/declarations.gms

variables
vm_costpollution(tall,all_regi)                                                 "costs of air pollution policies [T$]"
;

parameter
p11_emiFacAP(tall,all_regi,all_enty,all_enty,all_te,sectorEndoEmi11,all_enty)  "air pollutant emission factors [Gt(species)/TWa]"
p11_share_sector(tall,all_enty,all_enty,all_te,sectorEndoEmi11,all_regi)       "share of technology that goes into industry, residential, and transport sectorEndoEmi11 [1]"
p11_costpollution(all_te,all_enty,sectorEndoEmi11)                             "pollutant abatement costs in [$/t]"

p11_EF_uncontr(all_enty,all_enty,all_te,all_regi,all_enty,sectorEndoEmi11)     "regional uncontrolled pollutant emission factor"
p11_EF_mean(all_enty,all_enty,all_te,all_enty)                                  "global mean pollutant emission factor in 2005"
p11_cesIO(tall,all_regi,all_in)                                                 "cesIO parameter specific for the module"

p11_share_trans(tall,all_regi)                                                  "share of transport FE liquids (fedie and fepet) and all FE liquids [share]"
;

equations
q11_costpollution(tall,all_regi)                                                "calculates the costs for air pollution policies"
;

*** EOF ./modules/11_aerosols/exoGAINS2025/declarations.gms
