*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/33_CDR/all/datainput.gms
!! Beutler et al. 2019 (Climeworks)
!!fe demand electricity for ventilation
p33_dac_fedem_el("feels") = 5.28;
!!fe demand heat for material recovery
p33_dac_fedem_heat("fehes") = 21.12;
p33_dac_fedem_heat("fegas") = 21.12;
p33_dac_fedem_heat("feh2s") = 21.12;
p33_dac_fedem_heat("feels") = 21.12;

*** enhanced weatering data
table f33_maxProdGradeRegiWeathering(all_regi,rlf)                                      "regional maximum potentials for enhanced weathering in Gt of grinded stone/a for different grades"
$ondelim
$include "./modules/33_CDR/weathering/input/f33_maxProdGradeRegiWeathering.cs3r"
$offdelim
;
display f33_maxProdGradeRegiWeathering;
$include "./modules/33_CDR/weathering/input/p33_transport_costs.inc"

s33_step = 2.5;
s33_rockfield_fedem = 0.3;
*** fix costs [T$/Gt stone]. Data from strefler et al. in $/t stone: mining, crushing, grinding (5.0 investment costs, 25.1 O&M costs), spreading (12.1 O&M costs)
s33_costs_fix = 0.0422;
s33_co2_rem_pot = 0.3 * 12/44;       !! default for basalt, for Olivine 1.1 

*** carbon removal rate: eqs 2+c1 in strefler, amann et al., 2017: wr = grain surface area based WR (10^-10.53 mol m^-2 s^-1) * molar weight of basalt/forsterite (140.7 g/mol) * 3.155^7 s/a * SSA(gs)
s33_co2_rem_rate = 10**(-10.53) * 125 * 3.155*10**7 * 69.18*(cm_gs_ew**(-1.24));
p33_co2_rem_rate("1") = -log(1-s33_co2_rem_rate * 0.94);
p33_co2_rem_rate("2") = -log(1-s33_co2_rem_rate * 0.29);

*JeS fit from Thorben: SI D in strefler, amann et al. (2017)
s33_rockgrind_fedem = 6.62 * cm_gs_ew**(-1.16);

p33_LimRock(regi) = pm_pop("2005",regi)/sum(regi2,pm_pop("2005",regi2));

*** EOF ./modules/33_CDR/all/datainput.gms
