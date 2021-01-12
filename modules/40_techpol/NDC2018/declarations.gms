*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de

*** SOF ./modules/40_techpol/NDC2018/declarations.gms
Parameter p40_TechBound(ttot,all_regi,all_te)          "level for lower bound on absolute capacities, in GW, for solar and wind";
Parameter p40_ElecBioBound(ttot,all_regi)              "level for lower bound on biomass tech. absolute capacities, in GW";
Parameter p40_noncombust_acc_eff(ttot,iso_regi,all_te) "Efficiency used for the accounting of non-combustibles PE, e.g. 0.45 for 45% under substitution method, eq 1 for all carriers under direct accounting method";
Parameter p40_PEgasBound(ttot,iso_regi)                "level for lower bound of gas share in PE, e.g. 0.2 for 20%";
Parameter p40_PElowcarbonBound(ttot,iso_regi)          "Lower bound on low carbon share, e.g. 0.2 for 20%";
Parameter p40_El_RenShare(ttot,iso_regi)               "Lower bound on low carbon share, e.g. 0.2 for 20%";
Parameter p40_CoalBound(ttot,iso_regi)                 "level for upper bound on absolute capacities, in GW for all technologies except electromobility";
Parameter p40_FE_RenShare(tall,all_regi)               "Lower bound on ren share, e.g. 0.2 for 20%";
Parameter p40_ElCap_RenShare(ttot,all_regi)            "Lower bound on low carbon share in total installed capacity, e.g. 0.2 for 20%";


Equation q40_ElecBioBound                              "equation low-carbon push technology policy for bio power";
Equation q40_PEgasBound                                "Mandating minimum PE gas share";
Equation q40_PElowcarbonBound                          "Lower bound on low carbon share";
Equation q40_FE_RenShare                               "Lower bound on renewable share";
Equation q40_El_RenShare                               "Lower bound on low carbon share in electricity";
Equation q40_CoalBound                                 "Restricting new coal power plants in regions with regulation";
Equation q40_ElCap_RenShare                            "Lower bound on low carbon share in total installed capacity";

*** EOF ./modules/40_techpol/NDC2018/declarations.gms


