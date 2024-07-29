*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/33_CDR/portfolio/datainput.gms

*' @code
*' #### DAC input data
*' FE demand from Beuttler et al. 2019 (Climeworks)
p33_fedem("dac", "feels") = 5.28; !! FE demand electricity for ventilation
p33_fedem("dac", "fehes") = 21.12; !! FE demand heat for material recovery


*' #### EW input data
*' @stop
table f33_maxProdGradeRegiWeathering(all_regi,rlf)  "regional maximum potentials for enhanced weathering in Gt of grinded stone/a for different grades"
$ondelim
$include "./modules/33_CDR/portfolio/input/f33_maxProdGradeRegiWeathering.cs3r"
$offdelim
;
display f33_maxProdGradeRegiWeathering;

parameter p33_EW_transport_costs(all_regi,rlf,rlf)    "transport costs [T$/Gt stone]"
/
$ondelim
$include "./modules/33_CDR/portfolio/input/p33_transportCostsWeathering.cs4r"
$offdelim
/
;
display p33_EW_transport_costs;

s33_step = 2.5;

*' @code
*' fix costs [T$/Gt stone]. Data from strefler et al. in $/t stone: mining, crushing, grinding (5.0 investment costs, 25.1 O&M costs), spreading (12.1 O&M costs)
s33_costs_fix = 0.0422;
s33_co2_rem_pot = 0.3 * 12/44;       !! default for basalt, for Olivine 1.1

*' carbon removal rate: eqs 2+c1 in strefler, amann et al. (2018): wr = grain surface area based WR (10^-10.53 mol m^-2 s^-1) * molar weight of basalt/forsterite (140.7 g/mol) * 3.155^7 s/a * SSA(gs)
s33_co2_rem_rate = 10**(-10.53) * 125 * 3.155*10**7 * 69.18*(cm_gs_ew**(-1.24));
p33_co2_rem_rate("1") = -log(1-s33_co2_rem_rate * 0.94);
p33_co2_rem_rate("2") = -log(1-s33_co2_rem_rate * 0.29);

*' JeS FE demand fit from Thorben: SI D in strefler, amann et al. (2018)
p33_fedem("weathering", "feels") = 6.62 * cm_gs_ew**(-1.16);
p33_fedem("weathering", "fedie") = 0.3;

*' Factor distributing the global rock limit across regions according to population
p33_LimRock(regi) = pm_pop("2005",regi) / sum(regi2,pm_pop("2005",regi2));

*** ocean alkalinity enhancement input data (Kowalczyk et al., 2024)

!! An assumption; generally the efficiency might vary between 0.9-1.4 tCO2/tCaO (1.2-1.8 molCO2/molCaO),
!! depending on e.g., ocean chemistry and currents in a given region
s33_OAE_efficiency = cm_33_OAE_eff / sm_c_2_co2; !!   GtC (ocean uptake) per unit of GtCaO

!! 0.78 tCO2 are emitted in the decomposition of limestone to produce 1 tCaO
s33_OAE_chem_decomposition = 0.78 / sm_c_2_co2 / s33_OAE_efficiency; !! GtC from decomposition per 1GtC taken by the ocean, 0.78 t/tCaO

p33_fedem(te_oae33, "feels") = 1.0 / s33_OAE_efficiency; !! 996 MJ/tCaO, used for grinding, air separation, CO2 compression
p33_fedem(te_oae33, "fehes") = 3.1 / s33_OAE_efficiency; !! 3100 MJ/tCaO, used for calcination

if(cm_33_OAE_scen = 0, !! pessimistic scenario for distribution, high diesel demand
    p33_fedem(te_oae33, "fedie") = 2.6 / s33_OAE_efficiency; !! 2600 MJ/tCaO (corresponds to discharge rate of 30 t/h)
); !! fedie is used for inland transport of the material and maritime transport to distribute the material in the ocean

if(cm_33_OAE_scen = 1, !! optimistic scenario for distribution, lower diesel demand
    p33_fedem(te_oae33, "fedie") = 0.77 / s33_OAE_efficiency; !! 770 MJ/tCaO (corresponds to the discharge rate of 100 t/h)
);

*' @stop
*** EOF ./modules/33_CDR/portfolio/datainput.gms
