*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/30_biomass/magpie_4/declarations.gms

scalars
s30_D2TD                "Multiplicative factor to convert from Dollar to TeraDollar"     /1.0e-12/
s30_max_pebiolc         "Absolute end value of bound on global pebiolc production [TWa]"
s30_switch_shiftcalc    "Switch to activate equation for shift calculation before main solve and to deactivate it during main solve" /0/
;

parameter
p30_datapebio(all_regi,all_enty,rlf,charPeRe,ttot) "Global bioenergy potential for lignocellulosic residues and 1st generation crops [TWa]"
p30_max_pebiolc_path(all_regi,tall)             "Time path of regional maximal pebiolc production [TWa]"
p30_max_pebiolc_path_glob(tall)                 "Time path of global maximal pebiolc production [TWa]"
p30_max200_path(tall)                           "Time path of global maximal pebiolc production containing values for 200 EJ case [TWa]"
p30_maxprod_residue(ttot,all_regi)              "Maximal potential of residues enhanced by demand of biotr [TWa]"
p30_pebiolc_pricemag(tall,all_regi)             "Prices for lignocellulosic purpose grown bioenergy from MAgPIE [T$US/TWa]"
p30_pebiolc_demandmag(tall,all_regi)            "Production of lignocellulosic purpose grown bioenergy from MAgPIE [TWa]"
p30_demPe(ttot,all_regi)                        "Primary energy demand imported from gdx or previous iteration [TWa]"
***p30_pedemBio_BAU(ttot,all_regi)                 "Primary bioenergy demand imported from reference gdx [TWa]"


*** Shift factor calculation
p30_pebiolc_costs_emu_preloop(ttot,all_regi)    "Bioenergy costs calculated with emulator using MAgPIE demand. For shift factor calculation [T$US]"
p30_pebiolc_price_emu_preloop(ttot,all_regi)    "Bioenergy price calculated with emulator using MAgPIE demand. For shift factor calculation [T$US/TWa]"
p30_pebiolc_price_emu_preloop_shifted(ttot,all_regi) "Bioenergy price calculated with emulator using MAgPIE demand after shift factor calculation [T$US/TWa]"
p30_pebiolc_pricshift(ttot,all_regi)            "Regional translation factor that shifts emulator prices to better fit actual MAgPIE prices [-]"
p30_pebiolc_pricmult(ttot,all_regi)             "Regional multiplication factor that sclaes emulator prices to better fit actual MAgPIE prices [-]"

*** Parameters for regression of MAgPIE prices and costs ("MAgPIE emulator")

*** Parameters used in the equation are chosen from above according to year and climate target
i30_bioen_price_a(ttot,all_regi)   "Time dependent intercept in bioenergy price formula [T$US/TWa]"
i30_bioen_price_b(ttot,all_regi)   "Time dependent slope in bioenergy price formula [T$US/TWa/TWa]"

*** Parameters used for the determination of regional biomass bounds consistent with global bound based on same marginal supply costs
p30_pebiolc_price_dummy            "Dummy for the bio-energy price to match the bioenergy bound s30_max_pebiolc"
p30_max_pebiolc_dummy              "Dummy for bio energy supply at p30_pebiolc_price_dummy"
p30_fuelex_dummy(all_regi)         "Dummy for bio-energy supply per region"
;

*** Define parameter to read in regionally specific bounds on lignocellulosic bioenergy
$ifThen.regiBioenergymax not "%cm_regiBioenergymax%" == "off"
parameter
    p30_regiBioenergymax(all_regi) "auxiliary parameter to read in regionally specific bounds on lignocellulosic bioenergy. [EJ/yr]" / %cm_regiBioenergymax% /
;
$endIf.regiBioenergymax

variables
v30_pebiolc_costs(ttot,all_regi)   "Bioenergy costs according to MAgPIE supply curves [T$US]"
v30_shift_r2                       "Least square to minimize during shift calculation"
;

Positive variable
v30_priceshift(ttot,all_regi)      "Regional translation factor that shifts emulator prices to better fit actual MAgPIE prices [-]"
v30_pricemult(ttot,all_regi)       "Regional multiplication factor that sclaes emulator prices to better fit actual MAgPIE prices [-]"
v30_multcost(ttot,all_regi)        "Cost markup factor for deviations from demand of last coupling iteration [-]"
***v30_pedem_BAU(tall,all_regi,all_enty,all_enty,all_te)    "Primary energy demand imported from refernce gdx [TWa]"
***v30_seprod_BAU(tall,all_regi,all_enty,all_enty,all_te)   "Secondary energy production imported from reference gdx [TWa]"

;

equations
q30_costFuBio(ttot,all_regi)       "Total costs of bioenergy production"
q30_pebiolc_price(ttot,all_regi)   "MAgPIE emulator: calculates the price of pebiolc according to MAgPIE supply curves"
q30_pebiolc_costs(ttot,all_regi)   "MAgPIE emulator: calculates the costs of pebiolc according to MAgPIE supply curves"
q30_priceshift                     "Calculates shift factor by minimizing least squares of price differences between MAgPIE output and MAgPIE emulator"
q30_limitXpBio(ttot,all_regi)      "Only purpose grown bioenergy may be exported, no residues"
q30_costAdj(ttot,all_regi)         "Improve convergence penalizing deviations from last coupling iteration"
q30_limitTeBio(ttot,all_regi)      "Limit BECCS in policy runs relative to reference scenario"
;
*** EOF ./modules/30_biomass/magpie_4/declarations.gms
