*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de

*** SOF ./modules/40_techpol/NPi2025/declarations.gms


Parameter 
    p40_TechBound(ttot,all_regi,all_te)          "NPI capacity targets for solar (pv, csp), wind (total, onshore, offshore), nuclear, hydro, biomass, nuclear (GW)"
    p40_ElecBioBound(ttot,all_regi)              "level for lower bound on biomass tech. absolute capacities, in GW"
    p40_noncombust_acc_eff(ttot,iso_regi,all_te) "Efficiency used for the accounting of non-combustibles PE, e.g. 0.45 for 45% under substitution method, eq 1 for all carriers under direct accounting method"
    p40_PEgasBound(ttot,iso_regi)                "level for lower bound of gas share in PE, e.g. 0.2 for 20%"
    p40_PElowcarbonBound(ttot,iso_regi)          "Lower bound on low carbon share, e.g. 0.2 for 20%"
    p40_El_RenShare(ttot,iso_regi)               "Lower bound on low carbon share, e.g. 0.2 for 20%"
    p40_CoalBound(ttot,iso_regi)                 "level for upper bound on absolute capacities, in GW for all technologies except electromobility"
    p40_FE_RenShare(ttot,iso_regi)               "Lower bound on ren share, e.g. 0.2 for 20%";
*   p40_ElCap_RenShare(ttot,all_regi)            "Lower bound on low carbon share in total installed capacity, e.g. 0.2 for 20%";

Equation q40_ElecBioBound                              "equation low-carbon push technology policy for bio power";
Equation q40_FE_RenShare                               "Lower bound on renewable share";
Equation q40_windBound				                   "lower bound on combined wind onshore and offshore";

*** EOF ./modules/40_techpol/NPi2025/declarations.gms


