*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/30_biomass/magpie_4/declarations.gms

scalars
s30_D2TD                "multiplicative factor to convert from Dollar to TeraDollar"     /1.0e-12/
s30_max_pebiolc         "absolute end value of bound on global pebiolc production in EJ/a"
s30_switch_shiftcalc    "activates equation for shift calculation before main solve and deactivates it during main solve" /0/
;

parameter
p30_datapebio(all_regi,all_enty,rlf,charPeRe,ttot) "global bioenergy potential for residues and 1st generation crops"
p30_max_pebiolc_path(all_regi,tall)             "time path of maximal pebiolc production containing absolute values for 200 EJ case"
p30_max_pebiolc_path_glob(tall)                 "time path of maximal pebiolc production containing absolute values for 200 EJ case"
p30_max200_path(tall)                           "time path of maximal pebiolc production containing absolute values for 200 EJ case"
p30_maxprod_residue(ttot,all_regi)              "enhanced (by demand of biotr) potential of residues"
p30_min_pebiolc(ttot,all_regi)                  "additional lower bounds to avoid very steep beginning of some supply curves"
p30_pebiolc_pricemag(tall,all_regi)             "prices and costs for 2nd gen. purpose grown bioenergy from MAgPIE"
p30_pebiolc_demandmag(tall,all_regi)            "production of 2nd gen. purpose grown bioenergy from MAgPIE"

*** Shift factor calculation
p30_pebiolc_costs_emu_preloop(ttot,all_regi)    "bioenergy costs calculated with emulator using MAgPIE demand for shift factor calculation"
p30_pebiolc_price_emu_preloop(ttot,all_regi)    "bioenergy price calculated with emulator using MAgPIE demand for shift factor calculation"
p30_pebiolc_price_emu_preloop_shifted(ttot,all_regi) "bioenergy price calculated with emulator using MAgPIE demand after shift factor calculation"
p30_pebiolc_pricshift(ttot,all_regi)            "regional translation factor that shifts emulator prices to better fit actual MAgPIE prices"
p30_pebiolc_pricmult(ttot,all_regi)             "regional multiplication factor that sclaes emulator prices to better fit actual MAgPIE prices"

*** Parameters for regression of MAgPIE prices and costs ("MAgPIE emulator")

*** Parameters used in the equation are chosen from above according to year and climate target
i30_bioen_price_a(ttot,all_regi)              "time dependent intercept in bioenergy price formula"
i30_bioen_price_b(ttot,all_regi)              "time dependent slope in bioenergy price formula"

*** Parameters used for the determination of regional biomass bounds consistent with global bound based on same marginal supply costs
p30_pebiolc_price_dummy                         "dummy for the bio-energy price to match it with the bioenergy bound s30_max_pebiolc"
p30_max_pebiolc_dummy                           "dummy for bio energy supply at p30_pebiolc_price_dummy"
p30_fuelex_dummy(all_regi)                      "dummy for bio-energy supply per region"
;


variables
v30_pebiolc_costs(ttot,all_regi)                         "bioenergy costs according to MAgPIE supply curves"
v30_shift_r2                                             "least square to minimize during shift calculation"
;


Positive variable
v30_priceshift(ttot,all_regi)      "regional shift factor for bioenergy prices"
v30_pricemult(ttot,all_regi)       "regional slope factor for bioenergy prices"
v30_multcost(ttot,all_regi)        "cost markup factor for deviations from demand of last coupling iteration"
;


equations
q30_costFuBio(ttot,all_regi)             "total costs of bioenergy production"
q30_pebiolc_price(ttot,all_regi)         "MAgPIE emulator: calculates the price of pebiolc according to MAgPIE supply curves"
q30_pebiolc_price_base(ttot,all_regi)    "MAgPIE emulator: calculates the price of pebiolc according to MAgPIE supply curves"
q30_pebiolc_costs(ttot,all_regi)         "MAgPIE emulator: calculates the costs of pebiolc according to MAgPIE supply curves"
q30_priceshift                           "calculates shift factor by minimizing least squares of price differences between MAgPIE output and MAgPIE emulator"
q30_limitXpBio(ttot,all_regi)            "only purpose grown bioenergy may be exported, no residues"
q30_costAdj(ttot,all_regi)               "improve convergence penalizing deviations from last coupling iteration"
;
*** EOF ./modules/30_biomass/magpie_4/declarations.gms
