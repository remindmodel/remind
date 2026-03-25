*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de

*** SOF ./modules/40_techpol/NPi2025/declarations.gms

*------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------
***                                Capacity Targets
*------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------
Parameter 
    p40_TechBound(ttot,all_regi,all_te)          "NPI capacity targets for solar (pv, csp), wind (total, onshore, offshore), nuclear, hydro, biomass, nuclear (GW)"
    p40_ElecBioBound(ttot,all_regi)              "level for lower bound on biomass tech. absolute capacities, in GW"
    p40_CoalBound(ttot,iso_regi)                 "level for upper bound on absolute capacities, in GW for all technologies except electromobility"
;

    
Equation 
    q40_ElecBioBound                              "equation low-carbon push technology policy for bio power"
    q40_windBound				                  "lower bound on combined wind onshore and offshore"
;

*------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------
***                                Renewable Share Targets
*------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------


Parameter
    p40_RenShareTargets(ttot,all_regi,RenShareTargetType)  "renewable share targets in NPi per REMIND region aggregated from country-level targets [share]"
;

Equation
    q40_RenShare                                  "constraint to enforce minimum share of renewables based on renewable share targets of NPi"
;


*** EOF ./modules/40_techpol/NPi2025/declarations.gms


