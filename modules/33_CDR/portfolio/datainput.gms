*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/33_CDR/portfolio/datainput.gms

*** direct air capture input data
!! Beutler et al. 2019 (Climeworks)
p33_fedem("dac", "feels") = 5.28; !! FE demand electricity for ventilation
p33_fedem("dac", "fehes") = 21.12; !! FE demand heat for material recovery

*** enhanced weatering input data
table f33_maxProdGradeRegiWeathering(all_regi,rlf)  "regional maximum potentials for enhanced weathering in Gt of grinded stone/a for different grades"
$ondelim
$include "./modules/33_CDR/portfolio/input/f33_maxProdGradeRegiWeathering.cs3r"
$offdelim
;
display f33_maxProdGradeRegiWeathering;
$include "./modules/33_CDR/portfolio/input/p33_transport_costs.inc"

s33_step = 2.5;
*** fix costs [T$/Gt stone]. Data from strefler et al. in $/t stone: mining, crushing, grinding (5.0 investment costs, 25.1 O&M costs), spreading (12.1 O&M costs)
s33_costs_fix = 0.0422;
s33_co2_rem_pot = 0.3 * 12/44;       !! default for basalt, for Olivine 1.1

*** carbon removal rate: eqs 2+c1 in strefler, amann et al., 2017: wr = grain surface area based WR (10^-10.53 mol m^-2 s^-1) * molar weight of basalt/forsterite (140.7 g/mol) * 3.155^7 s/a * SSA(gs)
s33_co2_rem_rate = 10**(-10.53) * 125 * 3.155*10**7 * 69.18*(cm_gs_ew**(-1.24));
p33_co2_rem_rate("1") = -log(1-s33_co2_rem_rate * 0.94);
p33_co2_rem_rate("2") = -log(1-s33_co2_rem_rate * 0.29);

*JeS fit from Thorben: SI D in strefler, amann et al. (2017)
p33_fedem("weathering", "feels") = 6.62 * cm_gs_ew**(-1.16);
p33_fedem("weathering", "fedie") = 0.3;

p33_LimRock(regi) = pm_pop("2005",regi) / sum(regi2,pm_pop("2005",regi2));

*** ocean alkalinity enhancement input data
s33_OAE_rock_demand = 1.7; !! limestone from Renforth et al. 2013 TODO document other rock types
s33_OAE_chem_decomposition = 0.44 * s33_oae_rock_demand; !! can be set to zero if no calcination is considered

!! TODO describe the sources, plug in the right numbers
!! feels from OL csv: 1.251753282
!! fehes from OL csv: 4.385187431
!! fedie from OL csv: 0.131163399 (for distribution) / total fuel: 0.187017546 per 1tCO2 seq 

p33_fedem("oae", "feels") = 1.8 * 3.67; !! TODO change this to s33_oae_rock_demand * energy demand per 1t rock
p33_fedem("oae", "fehes") = 5.4 * 3.67; !! TODO change this to s33_oae_rock_demand * energy demand per 1t rock
p33_fedem("oae", "fedie") = 0.1 * s33_OAE_rock_demand * 3.67; !! 0.1EJ / 1 Gt rock

*** EOF ./modules/33_CDR/portfolio/datainput.gms
