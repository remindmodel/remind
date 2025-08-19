*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./core/declarations.gms

*LB* declaration of parameters, variables and equations

*** The declarations file follows the following structure:
*** 1. Macro-Economy
*** 2. Emissions
*** 3. Energy System
*** 4. Other (Not fitting into the above categories or generic declarations used everywhere in the model)
*** Please take this structure into account when adding new parameters, variables or equations.


*** ---------------------------------------------------------------------------
***        1. Macro-Economy
*** ---------------------------------------------------------------------------

*** ------------- Macro Parameters --------------------------------------------
parameters

*** trade prices (move to trade module?)
pm_pvp(ttot,all_enty)                                "Price on commodity markets, [T$/TWa] for energy commodities except uranium, uranium (peur) in [T$/Mt Uranium], emissions permits (perm) in [T$/GtC]"
p_pvpRef(ttot,all_enty)                              "Price on commodity markets - imported from REF gdx, [T$/TWa] for energy commodities except uranium, uranium (peur) in [T$/Mt Uranium], emissions permits (perm) in [T$/GtC]"
p_pvpRegiBeforeStartYear(ttot,all_regi,all_enty)     "prices of traded commodities before start year - regional. only used for permit trade [T$/GtC]"

pm_ies(all_regi)                                     "intertemporal elasticity of substitution",
*** only used in air pollutants module, move there?
pm_share_trans(tall,all_regi)                        "share of transport FE liquids (fedie and fepet) and all FE liquids [share]"

*** macro variables from gdx or previous iteration
pm_gdp_gdx(tall,all_regi)                            "GDP path from gdx, updated iteratively [T$]"
p_inv_gdx(tall,all_regi)                             "macro-investments path from gdx, updated iteratively [T$]"

*** co2 price calculated in 45_carbonprice module (move to tax or carbonprice module?)
pm_taxCO2eq(ttot,all_regi)                           "CO2 tax path calculated in 45_carbonprice module [T$/GtC]. To get $/tCO2, multiply with 272 = 1 / sm_DptCO2_2_TDpGtC"
pm_taxCO2eq_iter(iteration,ttot,all_regi)            "CO2 tax path (pm_taxCO2eq) tracked over iterations [T$/GtC]"
pm_taxCO2eq_anchor_iterationdiff(ttot)               "difference in global anchor carbon price to the last iteration [T$/GtC]"

*** co2 price mark-up per region on top of pm_taxCO2eq calculated in 46_carbonpriceRegi module (move to tax or carbonprice module?)
pm_taxCO2eqRegi(tall,all_regi)                       "Additional regional CO2 tax path calulated in in 46_carbonpriceRegi module to reach regional emissions targets [T$/GtC]. To get $/tCO2, multiply with 272 = 1 / sm_DptCO2_2_TDpGtC"
pm_taxCO2eqSum(tall,all_regi)                        "sum of pm_taxCO2eq, pm_taxCO2eqRegi, pm_taxCO2eqSCC [T$/GtC]. To get $/tCO2, multiply with 272 = 1 / sm_DptCO2_2_TDpGtC"

*** co2 price calculated in 47_regipol module (move to tax or carbonprice module?)
pm_taxemiMkt(ttot,all_regi,all_emiMkt)               "CO2 tax path per region and emissions market calculated in 47_regipol module [T$/GtC]"
pm_taxemiMkt_iteration(iteration,ttot,all_regi,all_emiMkt) "CO2 tax path per region and emissions market calculated in 47_regipol module from previous iteration [T$/GtC]"

*** general macro parameters
pm_cesdata(tall,all_regi,all_in,cesParameter)        "parameters of the CES function: efficiency parameters (xi, eff, effgr) [unitless], target quantities of CES calibration (quantity) [unit of CES node, see set all_in], CES prices resulting from calibration (price) [T$/unit of CES node]"
f_pop(tall,all_regi,all_GDPpopScen)                  "population data for all possible scenarios [million people]"
pm_pop(tall,all_regi)                                "population data [bn people]"
pm_gdp(tall,all_regi)                                "GDP data [trn US$ 2005]"
p_developmentState(tall,all_regi)                    "level of development based on GDP per capita, 0 is low income, 1 is high income"
f_lab(tall,all_regi,all_GDPpopScen)                  "labour data for all possible scenarios [million people]"
pm_lab(tall,all_regi)                                "data for labour [bn people]"
pm_esCapCost(tall,all_regi,all_teEs)                 "Capital energy cost per unit of consumption for end-use capital (energy service layer) [T$/unit energy service]"
pm_cesdata_sigma(ttot,all_in)                        "elasticities of substitution, higher values increase sustitutability between inputs of the CES function (i.e. stronger reaction of quantities to price changes) [unitless]"
p_r(ttot,all_regi)                                   "capital interest rate calculated as a diagnostic parameter (not used in the optimization) as the sum of the pure rate of time preference and endogenous consumption growth rate [year-1]"
;

*** ------------- Macro Variables --------------------------------------------
variables

*** tax revenue (move to tax module?)
vm_taxrev(ttot,all_regi)                             "difference between tax volume in current and previous iteration [T$]"

*** move to module 22?
vm_costSubsidizeLearning(ttot,all_regi)              "regional cost of subsidy for learning technologies [T$]"
*** move to module 41 emicapregi?
vm_dummyBudget(ttot,all_regi)                        "auxiliary variable that helps to meet permit allocation equation in nash case [GtCeq]"
;

*** ------------- Macro Positive Variables ------------------------------------
positive variables

vm_esCapInv(ttot,all_regi,all_teEs)                  "investment for energy end-use capital at the energy service level [T$]"
;

*** ------------- Macro Equations ---------------------------------------------
equations

q_esCapInv(ttot,all_regi,all_teEs)                   "investment equation for end-use capital investments (energy service layer)"
;


*** ---------------------------------------------------------------------------
***        2. Emissions
*** ---------------------------------------------------------------------------

*** ------------- Emissions Parameters ----------------------------------------
parameters

*** air pollutant emissions parameters (move to module 11?)
pm_emiExog(tall,all_regi,all_enty)                   "exogenous emissions from air pollutants [Mt SO2, Mt BC, Mt OC]" 
*** emissions permit parameters (move to module 41?)
pm_shPerm(tall, all_regi)                            "emission permit shares [share]"
pm_emicapglob(tall)                                  "global emission cap [GtC]" 

*** emissions parameters for nash algorithm
pm_co2eqForeign(tall,all_regi)                       "emissions, which are part of the climate policy, of other regions (nash relevant)."
pm_co2eq0(tall,all_regi)                             "Total greenhouse gas emissions from last iteration based on vm_co2eq used in nash algorithm [GtCeq]"

*** parameters used for MAC curves
pm_macBaseMagpie(tall,all_regi,all_enty)             "baseline emissions from MAgPIE (type emiMacMagpie) [GtC, Mt CH4, Mt N]"
p_macBaseMagpieNegCo2(tall,all_regi)                 "net negative CO2 emissions from land-use change [GtC]"
p_macBaseExo(tall,all_regi,all_enty)                 "exogenous baseline emissions (type emiMacExo) [Mt CH4, Mt N]"
p_co2lucSub(tall,all_regi,all_enty)                  "subtypes of CO2 land use change emissions, add up to total land use change emissions, coming from MAgPIE, passed through REMIND for reporting, not used anywhere, remain unchanged [GtC]"
pm_macAbat(tall,all_regi,all_enty,steps)             "abatement levels based on data from van Vuuren [fraction]"
pm_macAbatLev(tall,all_regi,all_enty)                "actual level of abatement per time step, region, and source [fraction]"
p_macAbat_lim(tall,all_regi,all_enty)                "limit of abatement level based on limit of yearly change [fraction]"
p_macUse2005(all_regi,all_enty)                      "usage of MACs in 2005 [fraction]"
p_histEmiMac(tall,all_regi,all_enty)                 "historical emissions per MAC (type emiMacSector); from Eurostat and CEDS, to correct CH4 and N2O reporting [GtC, Mt CH4, Mt N]"
p_histEmiSector(tall,all_regi,all_enty,emi_sectors,sector_types) "historical emissions per sector; from Eurostat and CEDS, to correct CH4 and N2O reporting [GtC, Mt CH4, Mt N]"
p_macLevFree(tall,all_regi,all_enty)                 "Phase in of zero-cost MAC options [fraction]"
pm_macCost(tall,all_regi,all_enty)                   "abatement costs for all emissions subject to MACCs (type emiMacSector) [T$]"
pm_macStep(tall,all_regi,all_enty)                   "step number of abatement level [integer]"
pm_macSwitch(ttot,all_regi,all_enty)                 "switch to include mac options in specific sectors and years [0/1]"
p_macCostSwitch(all_enty)                            "switch to include mac costs in the code [0/1] (e.g. in coupled scenarios, we want to include the costs in REMIND, but MAC effects on emissions are calculated in MAgPIE)"
p_macPE(ttot,all_regi,all_enty)                      "Primary energy production from MACs, e.g. methane production from abated methane leakage in coal extraction [TWa]"
p_priceCO2(tall,all_regi)                            "carbon price [$/tC]"
p_priceCO2forMAC(tall,all_regi,all_enty)             "carbon price defined for MAC gases [$/tC]"
p_priceGas(tall,all_regi)                            "gas price for ch4gas MAC [$/tCeq]"
p_emi_quan_conv_ar4(all_enty)                        "conversion factor of non-CO2 greenhouses gases to GtCeq"

$IFTHEN.agricult_base_shift not "%c_agricult_base_shift%" == "off"
p_agricult_base_shift(ext_regi)                      "fraction by which to scale agricultural emissions of baseline up or down, positive values increase emissions, negative values decrease emissions [fraction]" / %c_agricult_base_shift% /
p_agricult_shift_phasein(ttot)                       "phase in parameter for baseline agricultural process ch4 and no2 reduction [share]"
p_macBaseMagpie_beforeShift(ttot,all_regi,all_enty)  "pm_macBaseMagpie parameter before shift of c_agricult_base_shift is applied [GtC, Mt CH4, Mt N]"
$ENDIF.agricult_base_shift

p_aux_scaleEmiHistorical_n2o(all_regi)               "auxiliary parameter to rescale MAgPIE n2o emissions to historical values [Mt N]"
p_aux_scaleEmiHistorical_ch4(all_regi)               "auxiliary parameter to rescale MAgPIE ch4 emissions to historical values [Mt CH4]"

*** emissions factors and incineration rates
pm_emifac(tall,all_regi,all_enty,all_enty,all_te,all_enty) "emission factor by technology for all types of energy-related emissions [GtC/TWa, Mt CH4/TWa, Mt N/TWa, Mt SO2/TWa, Mt BC/TWa, Mt OC/TWa]"
p_ef_dem(all_regi,all_enty)                          "read-in parameter for demand side emission factors of final energy carriers [MtCO2/EJ]"
pm_emifacNonEnergy(ttot,all_regi,all_enty,all_enty,emi_sectors,all_enty) "emission factor for non-energy fedstocks, only for chemical industry [GtC/TWa]"
pm_incinerationRate(ttot,all_regi)                   "share of plastic waste that gets incinerated [fraction]"
pm_cintraw(all_enty)                                 "CO2 emissions factor of fossil fuels [GtC/TWa]"
p_cint(all_regi,all_enty,all_enty,rlf)               "CO2 emissions factor of energy-related emissions from unconventional fossil fuel extraction [GtC/TWa]" 
p_efFossilFuelExtr(all_regi,all_enty,all_enty)       "CH4 and N2O emission factor of PE production: fugitive CH4 from fossil fuel extraction and N2O from bioenergy [Mt CH4/TWA, Mt N/TWa]"
p_efFossilFuelExtrGlo(all_enty,all_enty)             "CH4 and N2O emission factor of PE production - global value: fugitive CH4 from fossil fuel extraction and N2O from bioenergy [Mt CH4/TWA, Mt N/TWa]"

*** share of stored carbon in captured carbon
pm_share_CCS_CCO2(ttot,all_regi)                     "share of stored CO2 from total captured CO2 from previous iteration [share]"

*** can be removed?

*** output parameters of deprecated internal emissions reporting
o_emissions(ttot,all_regi,all_enty)                  "output parameter"
o_emissions_bunkers(ttot,all_regi,all_enty)          "output parameter"
o_emissions_energy(ttot,all_regi,all_enty)           "output parameter"
o_emissions_energy_demand(ttot,all_regi,all_enty)    "output parameter"
o_emissions_energy_demand_sector(ttot,all_regi,all_enty,emi_sectors) "output parameter"
o_emissions_energy_supply_gross(ttot,all_regi,all_enty) "output parameter"
o_emissions_energy_supply_gross_carrier(ttot,all_regi,all_enty,all_enty) "output parameter"
o_emissions_energy_extraction(ttot,all_regi,all_enty,all_enty) "output parameter"
o_emissions_energy_negative(ttot,all_regi,all_enty)  "output parameter"
o_emissions_industrial_processes(ttot,all_regi,all_enty) "output parameter"
o_emissions_AFOLU(ttot,all_regi,all_enty)            "output parameter"
o_emissions_CDRmodule(ttot,all_regi,all_enty)        "output parameter"
o_emissions_other(ttot,all_regi,all_enty)            "output parameter"

o_capture(ttot,all_regi,all_enty)                    "output parameter"
o_capture_energy(ttot,all_regi,all_enty)             "output parameter"
o_capture_energy_elec(ttot,all_regi,all_enty)        "output parameter"
o_capture_energy_other(ttot,all_regi,all_enty)       "output parameter"
o_capture_cdr(ttot,all_regi,all_enty)                "output parameter"
o_capture_industry(ttot,all_regi,all_enty)           "output parameter"
o_capture_energy_bio(ttot,all_regi,all_enty)         "output parameter"
o_capture_energy_fos(ttot,all_regi,all_enty)         "output parameter"
o_carbon_CCU(ttot,all_regi,all_enty)                 "output parameter"
o_carbon_LandUse(ttot,all_regi,all_enty)             "output parameter"
o_carbon_underground(ttot,all_regi,all_enty)         "output parameter"
o_carbon_reemitted(ttot,all_regi,all_enty)           "output parameter"

o_emi_conv(all_enty)                                 "output parameter" / co2 3666.6666666666666666666666666667, ch4 28, n2o 416.4286, so2 1,	bc  1, oc  1 /
;

*** ------------- Emissions Variables ----------------------------------------
variables

*** total emissions
vm_co2eqGlob(ttot)                                   "total global greenhouse gas emissions to be balanced by allowances [GtCeq]"
vm_co2eq(ttot,all_regi)                              "total greenhouse gas emissions measured in co2 equivalents that are subject to carbon pricing, be aware that emissions coverage of this variable depends on switch cm_multigasscen [GtCeq]"
vm_co2eqMkt(ttot,all_regi,all_emiMkt)                "total greenhouse gas emissions per market measured in co2 equivalents that are subject to carbon pricing, be aware that emissions coverage of this variable depends on switch cm_multigasscen [GtCeq]"
vm_emiAll(ttot,all_regi,all_enty)                    "total emissions by species [GtC, Mt CH4, Mt N, Mt SO2, Mt BC, Mt OC]"
v_co2eqCum(all_regi)                                 "cumulated vm_co2eq emissions for the first budget period [GtCeq]"
*** move to module 41 emicapregi?
vm_perm(ttot,all_regi)                               "emission allowances [GtCeq]"

*** sectoral emissions
vm_emiTeDetail(ttot,all_regi,all_enty,all_enty,all_te,all_enty)  "emissions from energy technologies on supply-side (pm_emifac * PE) and demand-side (pm_emifac * FE), note: not equivalent to Emi|CO2|Energy in reporting [GtC, Mt CH4, Mt N, Mt SO2, Mt BC, Mt OC]"
v_emiEnFuelEx(ttot,all_regi,all_enty)                "energy-related CO2 emissions from fossil fuel extraction [GtC]"
vm_emiTe(ttot,all_regi,all_enty)                     "proxy of total energy-related emissions, based on vm_emiTeDetail and taking into account industry CCS, CCU and feedstocks note: not equivalent to Emi|CO2|Energy in reporting [GtC, Mt CH4, Mt N, Mt SO2, Mt BC, Mt OC]"
vm_emiCO2Sector(ttot,all_regi,emi_sectors)           "total CO2 emissions from individual sectors, so far only buildings and transport excl. bunkers [GtC]"
v_macBase(ttot,all_regi,all_enty)                    "baseline emissions for all emissions subject to MACCs, emissions that are not energy-related [GtC, Mt CH4, Mt N]"
vm_emiMacSector(ttot,all_regi,all_enty)              "total emissions subject to MACCs, emissions that are not energy-related [GtC, Mt CH4, Mt N]"

vm_emiCdr(ttot,all_regi,all_enty)                    "total (negative) CO2 emissions from CDR technologies that are calculated in the CDR module. Note that it includes all atmospheric CO2 entering the CCUS chain (i.e. CO2 stored (CDR) AND used (not CDR)) [GtC]"
vm_emiMac(ttot,all_regi,all_enty)                    "total non-energy-related emission of each region. [GtC, Mt CH4, Mt N]"
vm_emiFgas(ttot,all_regi,all_enty)                   "F-gas emissions by single gases from IMAGE [emiFgasTotal in MtCO2eq, for other units see f_emiFgas.cs4r]"

*** emissions per emissions market
vm_emiTeDetailMkt(tall,all_regi,all_enty,all_enty,all_te,all_enty,all_emiMkt) "emissions from energy technologies on supply-side (pm_emifac * PE) and demand-side (pm_emifac * FE) per emissions market, note: not equivalent to Emi|CO2|Energy in reporting [GtC, Mt CH4, Mt N, Mt SO2, Mt BC, Mt OC]"
vm_emiTeMkt(tall,all_regi,all_enty,all_emiMkt)       "proxy of total energy-related emissions per emissions market, based on vm_emiTeDetail and taking into account industry CCS, CCU and feedstocks note: not equivalent to Emi|CO2|Energy in reporting [GtC, Mt CH4, Mt N, Mt SO2, Mt BC, Mt OC]"
vm_emiAllMkt(tall,all_regi,all_enty,all_emiMkt)      "total emissions per emissions market [GtC, Mt CH4, Mt N, Mt SO2, Mt BC, Mt OC]"
;

*** ------------- Emissions Positive Variables --------------------------------
positive variables

v_co2capture(ttot,all_regi,all_enty,all_enty,all_te,rlf)    "total captured CO2 [GtC/year]"
vm_co2CCS(ttot,all_regi,all_enty,all_enty,all_te,rlf)       "total CO2 injected into geological storage [GtC/a]"
v_co2capturevalve(ttot,all_regi)                            "total CO2 emitted right after capture [GtC/a], note: used in q_balCCUvsCCS to account for different lifetimes of capture and CCU/CCS te and capacities [GtC/year]"
v_ccsShare(ttot,all_regi)                                    "fraction of captured CO2 that is stored geologically [share]"
vm_emiCdrAll(ttot,all_regi)                                  "all CDR emissions, net negative emissions from land-use change, gross removals for all other options [GtC/year]"
;


*** ------------- Emissions Equations -----------------------------------------
equations
q_emiCO2Sector(ttot,all_regi,emi_sectors)            "CO2 emissions from different sectors"
q_emiTeDetail(ttot,all_regi,all_enty,all_enty,all_te,all_enty) "determination of emissions"
q_macBase(tall,all_regi,all_enty)                    "baseline emissions for all emissions subject to MACCs (type emiMacSector)"
q_emiMacSector(ttot,all_regi,all_enty)               "total non-energy-related emission of each region"
q_emiTe(ttot,all_regi,all_enty)                      "total energy-emissions per region"
q_emiAll(ttot,all_regi,all_enty)                     "calculates all regional emissions as sum over energy and non-energy relates emissions"
q_emiCap(ttot,all_regi)                              "emission cap"
q_emiMac(ttot,all_regi,all_enty)                     "summing up all non-energy emissions"
q_co2eq(ttot,all_regi)                               "regional emissions in co2 equivalents"
q_co2eqMkt(ttot,all_regi,all_emiMkt)                 "regional emissions per market in co2 equivalents"
q_co2eqGlob(ttot)                                    "global emissions in co2 equivalents"
qm_co2eqCum(all_regi)                                "cumulate regional emissions over time"
q_budgetCO2eqGlob                                    "global emission budget balance"
q_emiTeDetailMkt(ttot,all_regi,all_enty,all_enty,all_te,all_enty,all_emiMkt) "detailed energy specific emissions per region and market"
q_emiTeMkt(ttot,all_regi,all_enty,all_emiMkt)        "total energy-emissions per region and market"
q_emiEnFuelEx(ttot,all_regi,all_enty)                "energy emissions from fuel extraction"
q_emiAllMkt(ttot,all_regi,all_enty,all_emiMkt)       "total regional emissions for each emission market"
q_emiCdrAll(ttot,all_regi)                           "summing over all CDR emissions"
q_balcapture(ttot,all_regi,all_enty,all_enty,all_te) "balance equation for carbon capture"
q_balCCUvsCCS(ttot,all_regi)                         "balance equation for captured carbon to CCU or CCS or valve"
q_ccsShare(ttot,all_regi)                            "calculate the share of captured CO2 that is stored geologically"

*** q_limitSo2 can be removed?
* RP: this equation is turned off as of 2025-03-11, because it has strong negative side
*     effects on coal use - eg SSA strongly increases coal use until 2050 only because 
*     it wants coal solids in 2070 and needs to ramp it up until 2050 due to this limit
*     this limit 
* q_limitSo2(ttot,all_regi)                             "prevent SO2 from rising again after 2050"
;



*** ---------------------------------------------------------------------------
***        3. Energy System
*** ---------------------------------------------------------------------------

*** ------------- Energy System Parameters ------------------------------------
parameters

*** general technoeconomic parameters
pm_eta_conv(tall,all_regi,all_te)                    "conversion efficiency of all energy technologies, only applying to technologies that do not have explicit time-dependant conversion efficiencies, still eta converges until 2050 to dataglob_values. [efficiency (0..1)]"
pm_dataeta(tall,all_regi,all_te)                     "read-in parameter for conversion efficiency of technologies that vary exogenously over time based on generisdata_varying_eta.prn file [efficiency (0..1)]"
pm_data(all_regi,char,all_te)                        "Large array for most technical parameters of technologies, more detail on the individual technical parameters and their units can be found in the declaration of the set 'char' "
pm_cf(tall,all_regi,all_te)                          "read-in parameter for capacity factor (fraction of the year that a plant is running) [share]"
p_tkpremused(all_regi,all_te)                        "turn-key cost premium used in the model (with a discount rate of 3 + pure rate of time preference), measured as relative increase of overnight investment costs)"
pm_inco0_t(ttot,all_regi,all_te)                     "investment cost parameter including exogenuous time-variance for non-learning technologies [T$/TW]"
pm_omeg(all_regi,opTimeYr,all_te)                    "technical depreciation parameter, gives the share of a capacity that is still usable after technical life time. [none/share, value between 0 and 1]"
p_lifetime_max(all_regi,all_te)                      "maximum lifetime of a technology (generisdata_tech gives the average lifetime) [years]"
p_discountedLifetime(all_te)                         "Sum over the discounted (@6%) depreciation factor (omega) [unitless]"
pm_teAnnuity(all_te)                                 "Annuity factor of a technology [unitless]"

*** parameters used for floor costs calculation
p_maxRegTechCost2015(all_te)                         "highest historical regional investment cost in 2015, used to calculate regionally-differentiated floor costs of learning technologies"
p_maxRegTechCost2020(all_te)                         "highest historical regional investment cost in 2020, used to calculate regionally-differentiated floor costs of learning technologies"
p_gdppcap2050_PPP(all_regi)                          "regional GDP PPP per capita in 2050 [thousand $/capita]"
p_maxPPP2050                                         "maximum income GDP PPP among regions in 2050 [T$]"
p_maxSpvCost                                         "maximum spv investment cost among regions [T$/TW]" 

*** parameters for capacity equations
pm_tsu2opTimeYr(ttot,opTimeYr)                       "auxiliary parameter to map time steps to past time steps: counts the number of model timesteps between years ttot-opTimeYr and ttot, used for q_transPe2se and q_cap equations [unitless]" 

*** parameters used for endogenous technology learning implementation
pm_capCum0(tall,all_regi,all_te)                     "Total cumulated capacity of learning technologies from last iteration used for learning curves based on vm_capCum[TW]"
p_capCum(tall, all_regi,all_te)                      "Total cumulated capacity of learning technologies from input.gdx used for learning curves based on vm_capCum[TW]"
pm_capCumForeign(ttot,all_regi,all_te)               "Total cumulated capacity of learning technologies of all other regions except regi [TW]"

*** biomass parameters (move to biomass module?)
pm_pedem_res(ttot,all_regi,all_te)                   "Demand for pebiolc residues, needed for enhancement of residue potential [TWa]"

*** early retirement parameters
pm_regiEarlyRetiRate(ttot,all_regi,all_te)           "regional early retirement rate, maximum allowed annual increase in the share of early retired capacity of a technology for which early retirement is allowed [1/year]"
pm_extRegiEarlyRetiRate(ext_regi)                    "regional early retirement rate (extended regions) [1/year]" / %c_regi_earlyreti_rate% /
$IFTHEN.tech_earlyreti not "%c_tech_earlyreti_rate%" == "off"
p_techEarlyRetiRate(ext_regi,all_te)                 "Technology specific early retirement rate [1/year" / %c_tech_earlyreti_rate% /
$ENDIF.tech_earlyreti

*** adjustment cost parameters
p_adj_coeff(ttot,all_regi,all_te)                    "coefficient for adjustment costs, higher values mean higher adjustment costs at a specific change rate of capacity additions, default is 8 [unitless]"
p_adj_seed_te(ttot,all_regi,all_te)                  "technology-dependent multiplicative prefactor to the v_adjFactor seed value, smaller means slower scale-up [unitless]"
p_adj_seed_reg(tall,all_regi)                        "market capacity that can be built from 0 and gives v_adjFactor=1 [T$]"
p_adj_coeff_Orig(ttot,all_regi,all_te)               "initial value of p_adj_coeff"
p_adj_seed_te_Orig(ttot,all_regi,all_te)             "initial value of p_adj_seed_te"
$ifthen not "%cm_adj_seed_cont%" == "off"
  p_new_adj_seed(all_te)                             "redefine adjustment seed parameters through model config switch" / %cm_adj_seed% , %cm_adj_seed_cont% /
$elseif not "%cm_adj_seed%" == "off"
  p_new_adj_seed(all_te)                             "redefine adjustment coefficient parameters through model config switch"  / %cm_adj_seed% /
$endif
$ifthen not "%cm_adj_coeff_cont%" == "off"
  p_new_adj_coeff(all_te)                            "new adj coef parameters" / %cm_adj_coeff% , %cm_adj_coeff_cont% /
$elseif not "%cm_adj_coeff%" == "off"
  p_new_adj_coeff(all_te)                            "new adj coef parameters" / %cm_adj_coeff% /
$endif
$ifthen not "%cm_adj_seed_multiplier%" == "off"
  p_adj_seed_multiplier(all_te)                      "factor to multiply standard adjustment seed with" / %cm_adj_seed_multiplier% /
$endif
$ifthen not "%cm_adj_coeff_multiplier%" == "off"
  p_adj_coeff_multiplier(all_te)                     "factor to multiply standard adjustment cost coefficient with" / %cm_adj_coeff_multiplier% /
$endif

*** diagnostic output parameters
*** parameters for interpreting adjustment costs
o_margAdjCostInv(ttot,all_regi,all_te)               "marginal adjustment cost calculated in postsolve for diagnostics [T$/TW]"
o_avgAdjCostInv(ttot,all_regi,all_te)                "average adjustment cost calculated in postsolve for diagnostics [T$/TW]"
o_avgAdjCost_2_InvCost_ratioPc(ttot,all_regi,all_te) "ratio of adjustment cost compared to direct invesment costs [%]"

*** parameters for renewable energy potentials
pm_dataren(all_regi,char,rlf,all_te)                 "regional renewable potential, maxprod [TWa] and capacity factor, nur [share]"
p_datapot(all_regi,char,rlf,all_enty)                "Total land area usable for the solar technologies PV and CSP [km^2]"

*** offshore wind parameters
pm_shareWindPotentialOff2On(all_regi)                "ratio of technical potential of offshore wind to onshore wind power [share]"
pm_shareWindOff(ttot,all_regi)                       "windoff rollout as a fraction of technical potential [share]"

*** parameters for VRE-related switches
$ifthen.VREPot_Factor not "%c_VREPot_Factor%" == "off"
  p_VREPot_Factor(all_te)                            "Rescale factor for renewable potentials" / %c_VREPot_Factor% /
$endif.VREPot_Factor

p_VRE_assumption_factor                              "factor of VRE costs due to cm_VRE_supply_assumptions switch (>1 means higher costs)"

*** parameters used for adjusting historical capacity factors of renewables
p_avCapFac2015(all_regi,all_te)                      "average capacity factor of non-bio renewables in 2015 in REMIND [share]"
p_aux_capToDistr(all_regi,all_te)                    "auxiliary parameter to calculate p_avCapFac2015; The historic capacity in 2015 [TW]"
s_aux_cap_remaining                                  "auxiliary parameter to calculate p_avCapFac2015; countdown parameter [TW]"
p_aux_capThisGrade(all_regi,all_te,rlf)              "auxiliary parameter to calculate p_avCapFac2015; How the historic 2015 capacity is distributed among grades [TW]"
p_aux_capacityFactorHistOverREMIND(all_regi,all_te)  "auxiliary parameter to calculate capacity factors correction (wind and spv): the ratio of historic over REMIND CapFac in 2015"

*** historical IEA calibration data (move to module 4?)
pm_IO_output(tall,all_regi,all_enty,all_enty,all_te) "Historical energy output per technology based on IEA data [TWa]"

*** parameters used for 2005 capacity calibration (move to module 5 intialCap?)
pm_EN_demand_from_initialcap2(all_regi,all_enty)     "PE demand resulting from the initialcap routine. [EJ, Uranium: MT U3O8]" 
pm_vintage_in(all_regi,opTimeYr,all_te)              "historical vintage structure per technology, generic assumptions made in generisdata_vintages.prn [unitless]" 

*** parameters for capacity bounds
p_CapFixFromRWfix(ttot,all_regi,all_te)              "auxiliary parameter for fixing nuclear capacity variable to real-world values in 2010/2015 [TW]"
p_deltaCapFromRWfix(ttot,all_regi,all_te)            "auxiliary parameter with resulting deltacap values resulting from fixing nuclear capacity to real-world values in 2010/2015 [TW/yr]"
pm_delta_histCap(tall,all_regi,all_te)               "historic capacity additions calculated from historic data [TW/yr]"
p_histProdSeGrowthRate(tall,all_regi,all_enty,all_te)"historic energy production growth rate [fraction]"
p_maxhistProdSeGrowthRate(all_regi,all_enty,all_te)  "maximum historic energy production growth rate [fraction]"


*** penalty cost implementation for cm_startyear to limit change in policy run relative to reference run
p_prodSeReference(ttot,all_regi,all_enty,all_enty,all_te) "Secondary Energy output of a technology in the reference run [TWa]"
pm_prodFEReference(ttot,all_regi,all_enty,all_enty,all_te) "Final Energy output of a technology in the reference run [TWa]"
p_prodUeReference(ttot,all_regi,all_enty,all_enty,all_te) "Useful Energy output of a technology in the reference run [TWa]"
p_co2CCSReference(ttot,all_regi,all_enty,all_enty,all_te,rlf) "Captured CO2 put through the CCS chain in ccs2te (pipelines/injection) in the reference run [GtC]"
p_prodAllReference(ttot,all_regi,all_te)             "Sum of the above in the reference run. As each technology has only one type of output, the differing units should not be a problem"

*** output parameters for 2005 calibration (move to 05_initialCap module?)
o_INI_DirProdSeTe                                    "directly produced SE by technology in 2005 (from initialcap2)"
o_INI_TotalDirProdSe                                 "Total direct SE production in 2005 (from initialcap2)"
o_INI_TotalCap                                       "Total electricity producing capacity in 2005 (from initialcap2)"
o_INI_AvCapFac                                       "Average regional capacity factor of the power sector in 2005 (from initialcap2)"

*** CES calibration tarjectories industry and buildings
pm_fedemand(tall,all_regi,all_in)                    "read-in parameter for final energy and production trajectories used for the CES parameter calibration in industry and buildings [TWa]"

*** energy service layer (only relevant for transport, move to transport module?)
pm_fe2es(tall,all_regi,all_teEs)                     "Conversion factor from final energies to transport energy services [Tpkm/TWa, Ttkm/TWa]"
pm_shFeCes(ttot,all_regi,all_enty,all_in,all_teEs)   "Final energy shares for CES nodes in transport [share]"

*** parameters for setting final energy shares
pm_shfe_up(ttot,all_regi,all_enty,emi_sectors)       "Final energy shares exogenous upper bounds per sector [share]"
pm_shfe_lo(ttot,all_regi,all_enty,emi_sectors)       "Final energy shares exogenous lower bounds per sector [share]"
p_shSeFe(ttot,all_regi,all_enty)                     "Initial share of energy carrier subtype in final energy demand of the aggregated carrier type (eg 'the share of bio-based FE liquids in all FE liquids') [share]"
p_shSeFeSector(ttot,all_regi,all_enty,all_enty,emi_sectors,all_emiMkt) "Initial share of energy carrier subtype in final energy demand of the aggregated carrier type for each sector/emiMarket combination (eg 'bio-based FE liquids share in all FE liquids within ETS transport') [share]"
pm_shGasLiq_fe_up(ttot,all_regi,emi_sectors)         "Final energy gases plus liquids shares exogenous upper bounds per sector [share]"
pm_shGasLiq_fe_lo(ttot,all_regi,emi_sectors)         "Final energy gases plus liquids shares exogenous lower bounds per sector [share]"

*** parameters used for inconvenience cost to avoid FE switching behavior across sectors and markets
p_demFeSector0(ttot,all_regi,all_enty,all_enty,emi_sectors,all_emiMkt) "Final Energy demand in the previous iteration [TWa]"
pm_demFeTotal0(ttot,all_regi)                        "Total Final Energy demand in the previous iteration [TWa]"

$ifthen.scaleDemand not "%cm_scaleDemand%" == "off"
*** FE demand rescaling parameters
  pm_scaleDemand(tall,tall,all_regi)                 "Rescaling factor on final energy and usable energy demand, for selected regions and over a phase-in window." / %cm_scaleDemand% /
$endif.scaleDemand

*** industry CES efficiency scaling (move to industry module?)
pm_calibrate_eff_scale(all_in,all_in,eff_scale_par)  "parameters for scaling efficiencies in CES calibration for industry [unitless]" /   /

*** historic biomass shares in final energy (move to biomass module?)
pm_secBioShare(ttot,all_regi,all_enty,emi_sectors)   "Share of biomass per carrier for each sector [share]"

*** energy prices
pm_FEPrice(ttot,all_regi,all_enty,sector,emiMkt)     "parameter to capture all FE prices across sectors and markets [tr$2005/TWa]"
pm_FEPrice_iter(iteration,ttot,all_regi,all_enty,sector,emiMkt) "parameter to capture all FE prices across sectors and markets [tr$2005/TWa] across iterations"
pm_SEPrice(ttot,all_regi,all_enty)                   "parameter to capture all SE prices [tr$2005/TWa]"
pm_PEPrice(ttot,all_regi,all_enty)                   "parameter to capture all PE prices [tr$2005/TWa]"

p_FEPrice_by_SE_Sector_EmiMkt(ttot,all_regi,entySe,all_enty,sector,emiMkt) "parameter to save FE price per SE, sector and emission market [tr$2005/TWa]"
p_FEPrice_by_Sector_EmiMkt(ttot,all_regi,all_enty,sector,emiMkt) "parameter to save FE marginal price per sector and emission market [tr$2005/TWa]"
pm_FEPrice_by_SE_Sector(ttot,all_regi,entySe,all_enty,sector) "parameter to save FE marginal price per SE and sector [tr$2005/TWa]"
p_FEPrice_by_SE_EmiMkt(ttot,all_regi,entySe,all_enty,emiMkt) "parameter to save FE marginal price per SE and emission market [tr$2005/TWa]"
p_FEPrice_by_SE(ttot,all_regi,entySe,all_enty)       "parameter to save FE marginal price per SE [tr$2005/TWa]"
p_FEPrice_by_Sector(ttot,all_regi,all_enty,sector)   "parameter to save FE marginal price per sector [tr$2005/TWa]"
p_FEPrice_by_EmiMkt(ttot,all_regi,all_enty,emiMkt)   "parameter to save FE marginal price per emission market [tr$2005/TWa]"
p_FEPrice_by_FE(ttot,all_regi,all_enty)              "parameter to save FE marginal price [tr$2005/TWa]"

p_FEPrice_by_SE_Sector_EmiMkt_iter(iteration,ttot,all_regi,entySe,all_enty,sector,emiMkt) "parameter to save iteration FE marginal price per SE, sector and emission market [tr$2005/TWa]"
p_FEPrice_by_Sector_EmiMkt_iter(iteration,ttot,all_regi,all_enty,sector,emiMkt) "parameter to save iteration FE marginal price per sector and emission market [tr$2005/TWa]"
p_FEPrice_by_SE_Sector_iter(iteration,ttot,all_regi,entySe,all_enty,sector) "parameter to save iteration FE marginal price per SE and sector [tr$2005/TWa]"
p_FEPrice_by_SE_EmiMkt_iter(iteration,ttot,all_regi,entySe,all_enty,emiMkt) "parameter to save iteration FE marginal price per SE and emission market [tr$2005/TWa]"
p_FEPrice_by_SE_iter(iteration,ttot,all_regi,entySe,all_enty) "parameter to save iteration FE marginal price per SE [tr$2005/TWa]"
p_FEPrice_by_Sector_iter(iteration,ttot,all_regi,all_enty,sector) "parameter to save iteration FE marginal price per sector [tr$2005/TWa]"
p_FEPrice_by_EmiMkt_iter(iteration,ttot,all_regi,all_enty,emiMkt) "parameter to save iteration FE marginal price per emission market [tr$2005/TWa]"
p_FEPrice_by_FE_iter(iteration,ttot,all_regi,all_enty) "parameter to save iteration FE marginal price [tr$2005/TWa]"
;


*** ------------- Energy System Variables ------------------------------------
variables

*** investment and adjustment costs
v_adjFactor(tall,all_regi,all_te)                    "factor to multiply with investment costs for adjustment costs [unitless]"
v_adjFactorGlob(tall,all_regi,all_te)                "factor to multiply with investment costs for adjustment costs - global scale [unitless]"

vm_costInvTeDir(tall,all_regi,all_te)                "annual direct investments into a technology [T$]"
vm_costInvTeAdj(tall,all_regi,all_te)                "annual investments into a technology due to adjustment costs [T$]"

*** CES mark-up costs with budget effect
vm_costCESMkup(ttot,all_regi,all_in)                 "CES markup cost to represent demand-side technology cost of end-use transformation [T$/TWa]"

*** penalty cost implementation for cm_startyear to limit change in policy run relative to reference run
v_changeProdStartyear(ttot,all_regi,all_te)          "absolute change of output with respect to the reference run for each te [TWa] for all energy-conversion tech, [GtC] for the CCS chain in ccs2te (pipelines/injection)"
v_relChangeProdStartYear(ttot,all_regi,all_te)       "calculating the relative change of output with respect to the reference run for each te [Percent]"
v_changeProdStartyearSlack(ttot,all_regi,all_te)     "slack variable to allow a minimum cost-free change with respect to the reference run [TWa] for all energy-conversion tech, [GtC] for the CCS chain in ccs2te (pipelines/injection)"

*** move to biomass module?
vm_costFuBio(ttot,all_regi)                          "fuel costs from bioenergy production [T$]"

*** move to CDR module?
vm_omcosts_cdr(tall,all_regi)                        "O&M costs for spreading grinded rocks on fields [T$]"

*** move to air pollution module?
vm_costpollution(tall,all_regi)                      "costs of air pollution policies [T$]"

*** move to power module?
vm_usableSe(ttot,all_regi,entySe)                    "Usable SE electricity defined as: generation from pe2se technologies + generation from coupled production - storage losses [TWa]"
vm_usableSeTe(ttot,all_regi,entySe,all_te)           "Usable SE electricity per generation technology defined as: generation from pe2se technologies + generation from coupled production - storage losses [TWa]"

vm_flexAdj(tall,all_regi,all_te)                     "flexibility mark-up cost or subsidy, used to emulate price changes of technologies which see lower-than-average or higher-than-average electricity prices due to more or less flexible operation[T$/TWa]"

*** move to tax module?
*** tax revenues of implicit taxes used for quantity and price target implementation
vm_taxrevimplicitQttyTargetTax(ttot,all_regi)        "tax revenue of implict tax for quantity target bound [T$]"
vm_taxrevimplicitPriceTax(ttot,all_regi,entySe,all_enty,sector)   "tax revenue of implict tax for final energy price target [T$]"
vm_taxrevimplicitPePriceTax(ttot,all_regi,all_enty)  "tax revenue of implict tax forprimary energy price target [T$]"
;


*** ------------- Energy System Positive Variables ----------------------------
Positive variables

*** capacity variables
vm_cap(tall,all_regi,all_te,rlf)                     "net total capacities [TW] for energy conversion technologies, [GtC] for CCS chain in ccs2te (pipelines/injection)"
v_capDistr(tall,all_regi,all_te,rlf)                 "net capacities, distributed to the different grades for renewables [TW]"
vm_capTotal(ttot,all_regi,all_enty,all_enty)         "total capacity of pe2se conversion technologies without technology differentation [TW]"
vm_deltaCap(tall,all_regi,all_te,rlf)                "capacity additions [TW/yr] for energy conversion technologies, [GtC/yr^2] for CCS chain in ccs2te (pipelines/injection)"
vm_capCum(tall,all_regi,all_te)                      "cumulated capactiy of learning technologies [TW]"
vm_capEarlyReti(tall,all_regi,all_te)                "fraction of early retired capacity from total standing capacity, can only be increased for technologies for which early retirement is switched on [share]"

*** technoeconomic parameters
vm_capFac(ttot,all_regi,all_te)                      "capacity factor of conversion technologies [share]"
vm_costTeCapital(ttot,all_regi,all_te)               "specific (per capacity) technology investment costs [T$/TW for energy conversion technologies, T$/GtC for CCS chain in ccs2te (pipelines/injection)]"

*** energy supply and demand variables
*** primary energy variables
vm_fuExtr(ttot,all_regi,all_enty,rlf)                "production (extraction) of primary energy fossil fuels, biomass and uranium (before trade)  [TWa, Uranium: Mt Ur]"
*** consider renaming vm_prodPe as production varibles should be before trade?
vm_prodPe(ttot,all_regi,all_enty)                    "primary energy production (after trade but not including PE production for MAC curves, e.g. capturing methane leakage) [TWa, Uranium: Mt Ur]"
vm_demPe(tall,all_regi,all_enty,all_enty,all_te)     "primary energy demand [TWa, Uranium: Mt Ur]"
*** secondary energy variables
vm_prodSe(tall,all_regi,all_enty,all_enty,all_te)    "secondary energy production (including only production as first product, not production as second (coupled) product) [TWa]"
vm_demSe(ttot,all_regi,all_enty,all_enty,all_te)     "secondary energy demand (including only demand as first input, not demand as second (coupled) input) [TWa]"
*** final energy variables
vm_prodFe(ttot,all_regi,all_enty,all_enty,all_te)    "final energy production [TWa]"
vm_demFeSector(ttot,all_regi,all_enty,all_enty,emi_sectors,all_emiMkt) "final energy demand per sector and emissions market, note: taxes should be applied to this variable or variables closer to the supply-side whenever possible so the marginal prices include the tax effects [TWa]"
vm_demFeSector_afterTax(ttot,all_regi,all_enty,all_enty,emi_sectors,all_emiMkt) "final energy demand per sector and emissions market after taxation, demand sectors should use this variable in their final energy balance equations so demand-side marginals include taxes effects [TWa]"
*** move to industry module?
vm_demFeNonEnergySector(ttot,all_regi,all_enty,all_enty,emi_sectors,all_emiMkt) "final energy demand used for material feedstocks in the industry sector [TWa]"

*** energy system cost variables
vm_costEnergySys(ttot,all_regi)                      "total energy system costs [T$]"
v_costFu(ttot,all_regi)                              "costs of primary energy production (extraction) [T$]"
vm_costFuEx(ttot,all_regi,all_enty)                  "costs of exhaustible primary energy production (extraction) of fossil fuels and uranium [T$]"
v_costOM(ttot,all_regi)                              "operation and maintenance costs of technologies [T$]"
v_costInv(ttot,all_regi)                             "total technology investment costs (including adjustment costs) [T$]"

vm_costAddTeInv(tall,all_regi,all_te,emi_sectors)    "additional sector-specific investment cost of demand-side transformation, e.g. investment into initial hydrogen distribution infrastructure [T$]"

*** move to biomass module?
vm_pebiolc_price(ttot,all_regi)                      "bioenergy price based on MAgPIE supply curves [T$/TWa]"

*** energy share variables
v_shGreenH2(ttot,all_regi)                           "share of green hydrogen in total hydrogen production [share]"
v_shBioTrans(ttot,all_regi)                          "share of biofuels in transport liquids [share]"
v_shfe(ttot,all_regi,all_enty,emi_sectors)           "share of final energy carrier total final energy per sector  [share]"
v_shSeFe(ttot,all_regi,all_enty)                     "share of energy carrier subtype in final energy demand of the aggregated carrier type (e.g. 'the share of bio-based FE liquids in all FE liquids') [share]"
v_shSeFeSector(ttot,all_regi,all_enty,all_enty,emi_sectors,all_emiMkt) "share of energy carrier subtype in final energy demand of the aggregated carrier type per sector/emiMarket combination (e.g. 'the share of bio-based FE liquids in all FE liquids used in ETS-covered transport') [share]"
v_shGasLiq_fe(ttot,all_regi,emi_sectors)             "share of gases and liquids in sectoral final energy [share]"

*** energy service variables (currently only used by transport)
vm_demFeForEs(ttot,all_regi,all_enty,all_esty,all_teEs)     "Final energy which will be used in the energy service layer [TWa]"
v_prodEs(ttot,all_regi,all_enty,all_esty,all_teEs)          "Energy services [Tpkm for passenger transport, Ttkm for freight transport]"

*** penalty cost implementation for cm_startyear to limit change in policy run relative to reference run
v_changeProdStartyearAdj(ttot,all_regi,all_te)       "absolute effect size of changing output with respect to the reference run for each technology [unitless]"
vm_changeProdStartyearCost(ttot,all_regi,all_te)     "costs for changing output with respect to the reference run for each technology [T$]"

*** penalty cost implementation to converge shares of bio/syn/fossil fuels in final energy hydrocarbons across sectors and markets
$ifthen.seFeSectorShareDev not "%cm_seFeSectorShareDevMethod%" == "off"
  v_penSeFeSectorShare(ttot,all_regi,all_enty,all_enty,emi_sectors,all_emiMkt) "penalty cost for secondary energy share deviation between sectors, for each sector/emiMarket combination [T$]"
  vm_penSeFeSectorShareDevCost(ttot,all_regi)                                  "total penalty cost for secondary energy share deviation between sectors [T$]"
$endif.seFeSectorShareDev

$ifthen.minMaxSeFeSectorShareDev "%cm_seFeSectorShareDevMethod%" == "minMaxAvrgShare"
  v_NegPenSeFeSectorShare(ttot,all_regi,all_enty,all_enty,emi_sectors,all_emiMkt) "min-max negative penalty for secondary energy share deviation in sectors [T$]"
  v_PosPenSeFeSectorShare(ttot,all_regi,all_enty,all_enty,emi_sectors,all_emiMkt) "min-max positive penalty for secondary energy share deviation in sectors [T$]"
$endif.minMaxSeFeSectorShareDev

*** can be removed?
v_prodUe(ttot,all_regi,all_enty,all_enty,all_te)    "Useful energy production [TWa]"
vm_demSeOth(ttot,all_regi,all_enty,all_te)          "other sety demand from certain technologies, have to calculated in additional equations [TWa]"
v_prodSeOth(ttot,all_regi,all_enty,all_te)          "other sety production from certain technologies, have to be calculated in additional equations [TWa]"
;

*** ------------- Energy System Equations -----------------------
equations


q_costEnergySys(ttot,all_regi)                       "calculate total energy system costs from total investment costs, operation and maintenance costs, fuel costs"
q_costFu(ttot,all_regi)                              "calculate total fuel costs from primary energy production (bioenergy production, fossil fuel and uranium extraction)"
q_costOM(ttot,all_regi)                              "calculate total operation and maintenance costs from all technologies"
q_costInv(ttot,all_regi)                             "calculate total investment costs of energy system from direct investments, adjustment costs and additional costs incurred in the demand sectors"
q_costInvTeDir(ttot,all_regi,all_te)                 "calculation of total direct investment costs (without adjustment costs) for a technology"
q_costInvTeAdj(ttot,all_regi,all_te)                 "calculation of total adjustment costs for a technology"
q_eqadj(all_regi,tall,all_te)                        "calculation of adjustment factor for a technology"

*** capacity equations
q_cap(tall,all_regi,all_te,rlf)                      "calculate available capacities (capacity motion equation) by adding up past capacity additions weighted by the respective technical depreciation parameter"
q_capDistr(tall,all_regi,all_te)                     "distribute available capacities across grades for renewable technologies"
q_capTotal(ttot,all_regi,all_enty,all_enty)          "calculate total capacity of pe2se conversion technologies by energy input and output carrier without technology differentiation by summing up all capacities of pe2se technologies"
q_limitCapEarlyReti(ttot,all_regi,all_te)            "constraint to avoid reactivation of retired capacities"
q_smoothphaseoutCapEarlyReti(ttot,all_regi,all_te)   "constraint to limit phase-out speed of early retirement from one time step to another"
q_capH2BI(ttot,all_regi)                             "calculate hydrogen transmission and distribution capacities for buildings and industry, as total of stationary sector, needed to avoid switching behavior of H2 between both sectors"

*** technology learning equations
q_capCumNet(t0,all_regi,all_te)                      "set initial cumulated capacity of learning technologies (vm_capCum) in start year"
qm_deltaCapCumNet(ttot,all_regi,all_te)              "calculate cumulated capacities of learning technologies (vm_capCum)"
q_costTeCapital(tall,all_regi,all_te)                "calculate investment cost for learning technologies (learning curve)"

*** renewable technology equations
q_limitProd(ttot,all_regi,all_te,rlf)                "constrain renewable production by renewable energy potentials"
q_limitGeopot(ttot,all_regi,all_enty,rlf)            "constrain land use of solar PV and CSP power to compete for the same geographical potential"
q_windoff_low(tall,all_regi)                         "constraint to ensure that offshore wind capacity is also built to a some extend if region builds onshore wind and has notable offshore potential relative to its onshore potential"
q_limitSeel2fehes(ttot,all_regi)                     "equation to limit the share of electricity in district heating"
q_capNonDecreasing(tall,all_regi,all_te)             "constrain capacity of some capital-intensive and site-specific technologies like hydropower and geothermal to not decrease over time once it is built"

*** biomass equations (to be moved to biomass module?)
q_limitBiotrmod(ttot,all_regi)                       "limit the total amount of modern biomass use for solids to the amount of coal use for solids"

*** capacity constraints for energy production (capacity * capacity factor = production)
q_limitCapSe(ttot,all_regi,all_enty,all_enty,all_te)    "capacity constraint for pe2se secondary energy production"
q_limitCapSe2se(ttot,all_regi,all_enty,all_enty,all_te) "capacity constraint for se2se secondary energy production"
q_limitCapFe(ttot,all_regi,all_te)                      "capacity constraint for final energy production"

*** capacity constraint for H2 infrastructure in buildings and indsutry (capacity * capacity factor = FE demand)
q_limitCapFeH2BI(ttot,all_regi,emi_sectors)               "capacity limit equation for H2 infrastructure capacities of buildings and industry, needed to avoid switching behavior of H2 between both sectors"

*** energy balance equations (energy supply = energy demand)
qm_fuel2pe(ttot,all_regi,all_enty)                   "balance of primary energy extraction, import and export and production"
q_balPe(ttot,all_regi,all_enty)                      "balance of primary energy (pe)"
q_balSe(ttot,all_regi,all_enty)                      "balance of secondary energy (se)"
q_balFe(ttot,all_regi,all_enty,all_enty,all_te)      "balance of final energy (fe)"
q_balFeAfterTax(ttot,all_regi,all_enty,all_enty,emi_sectors,all_emiMkt) "balance of final energy after considering FE sectoral taxes (fe)"

*** energy conversion equations (energy input * conversion efficiency = energy output)
q_transPe2se(ttot,all_regi,all_enty,all_enty,all_te) "energy tranformation pe to se"
q_transSe2se(ttot,all_regi,all_enty,all_enty,all_te) "energy transformation se to se"
q_transSe2fe(ttot,all_regi,all_enty,all_enty,all_te) "energy tranformation se to fe"

*** penalty cost implementation for cm_startyear to limit change in policy run relative to reference run
q_changeProdStartyear(ttot,all_regi,all_te)          "calculating the absolute change of output with respect to the reference run for each technology"
q_relChangeProdStartYear(ttot,all_regi,all_te)       "calculating the relative change"
q_changeProdStartyearAdj(ttot,all_regi,all_te)       "calculating the absolute effect size"
q_changeProdStartyearCost(ttot,all_regi,all_te)      "calculating the resulting costs"

*** equations to calculate or limit energy shares (relevant only with specific switches)
q_limitShOil(ttot,all_regi)                          "requires minimum share of liquids from oil in total fossil liquids"
q_shGreenH2(ttot,all_regi)                           "calculate share of green hydrogen in all hydrogen"
q_shBioTrans(ttot,all_regi)                          "calculate share of biofuels in transport liquids"
q_shfe(ttot,all_regi,all_enty,emi_sectors)           "calculate share of final energy carrier in the sectoral final energy"
q_shSeFe(ttot,all_regi,all_enty)                     "calculate share of energy carrier subtype in final energy demand of the aggregated carrier type (e.g. 'the share of bio-based FE liquids in all FE liquids')"
q_shSeFeSector(ttot,all_regi,all_enty,all_enty,emi_sectors,all_emiMkt) "calculate share of energy carrier subtype in final energy demand of the aggregated carrier type for each sector/emiMarket combination (e.g. 'the share of bio-based FE liquids in all FE liquids within ETS-covered transport)"
q_shGasLiq_fe(ttot,all_regi,emi_sectors)             "calculate share of gases and liquids in sectoral final energy"
$IFTHEN.sehe_upper not "%cm_sehe_upper%" == "off"
q_heat_limit(ttot,all_regi)                          "limit maximum level of secondary energy district heating and heat pumps use"
$ENDIF.sehe_upper
$ifthen.limitSolidsFossilRegi not %cm_limitSolidsFossilRegi% == "off"
  q_fossilSolidsLimitReg(ttot,all_regi,all_enty,all_enty,emi_sectors,all_emiMkt) "limit coal use in buildings and industry to be lower or equal to previous year values per sector and emissions market"
$endif.limitSolidsFossilRegi

*** equations to align model with historic data
q_PE_histCap(ttot,all_regi,all_enty,all_enty)        "require minimum of fossil and nuclear power capacity in historial years based on historical data"
q_PE_histCap_NGCC_2020_up(ttot,all_regi,all_enty,all_enty) "require maximum of gas power capacity in 2020 based on 2015 historical data and growth rate assumptions"
q_shbiofe_up(ttot,all_regi,all_enty,emi_sectors,all_emiMkt) "constrain share of biomass in hydrocarbons of sectoral final energy in historical years based on historical data (upper bound)"
q_shbiofe_lo(ttot,all_regi,all_enty,emi_sectors,all_emiMkt) "constrain share of biomass in hydrocarbons of sectoral final energy in historical years based on historical data (lower bound)"

*** energy service layer equations (only relevant for transport)
q_transFe2Es(ttot,all_regi,all_enty,all_esty,all_teEs) "conversion from final energy to energy services"
q_es2ppfen(ttot,all_regi,all_in)                     "hand over energy services to CES production factors"
q_shFeCes(ttot,all_regi,all_enty,all_in,all_teEs)    "require final energy for energy services to have energy mix given by CES function"

*** equations for penalty cost implementation to converge shares of bio/syn/fossil shares across sectors and markets
$ifthen.seFeSectorShareDev not "%cm_seFeSectorShareDevMethod%" == "off"
  q_penSeFeSectorShareDevCost(ttot,all_regi)         "calculate total penalty cost for secondary energy share deviation in sectors"
  q_penSeFeSectorShareDev(ttot,all_regi,all_enty,all_enty,emi_sectors,all_emiMkt) "penalty for secondary energy share deviation in sectors"
$endif.seFeSectorShareDev

$ifthen.minMaxSeFeSectorShareDev "%cm_seFeSectorShareDevMethod%" == "minMaxAvrgShare"
  q_minMaxPenSeFeSectorShareDev(ttot,all_regi,all_enty,all_enty,emi_sectors,all_emiMkt) "min-max penalty balance for secondary energy share deviation in sectors"
$endif.minMaxSeFeSectorShareDev

*** can be removed?
* q_shFeCesNorm(ttot,all_regi,all_in)                "Shares have to sum to 1."
;

*** ---------------------------------------------------------------------------
***        4. Carbon Management
*** ---------------------------------------------------------------------------

*** -------------  Carbon Management Parameters -------------------------------

Parameters

$ifthen.tech_CO2capturerate not "%c_tech_CO2capturerate%" == "off"
p_tech_co2capturerate(all_te)                        "Technology specific CO2 capture rate, fraction of carbon from input fuel that is captured [share]" / %c_tech_CO2capturerate% /
p_PECarriers_CarbonContent(all_enty)                 "Carbon content of PE carriers [GtC/TWa]"
$endif.tech_CO2capturerate
pm_dataccs(all_regi,char,rlf)                        "maximum CO2 storage capacity using CCS technology. [GtC]"
pm_ccsinjecrate(all_regi)                            "Regional CCS injection rate factor. [1/year]."
p_extRegiccsinjecrateRegi(ext_regi)                  "Regional CCS injection rate factor. [1/year]. (extended regions)"
;


*** ------------- Carbon Management Equations -------------------------------

equations
*** carbon management technology equations
*** q_transCCS can be removed?
q_transCCS(ttot,all_regi,all_enty,all_enty,all_te,all_enty,all_enty,all_te,rlf) "transformation equation for ccs"
q_limitCCS(all_regi,all_enty,all_enty,all_te,rlf)    "limit cumulated CO2 injection into geological storage to maximum storage potential"

*** capacity constraint for CCS (capacity * capacity factor = co2 injection)
q_limitCapCCS(ttot,all_regi,all_enty,all_enty,all_te,rlf)  "capacity constraint for ccs"
;

*** ---------------------------------------------------------------------------
***        5. Other
*** ---------------------------------------------------------------------------


*** ------------- Other Parameters ----------------------------
parameters
*** carbon budget parameters
pm_budgetCO2eq(all_regi)                             "budget for regional energy-emissions in period 1 [GtC]"
pm_actualbudgetco2(ttot)                             "actual level of cumulated emissions starting from 2020 [GtCO2]"
p_actualbudgetco2_iter(iteration,ttot)               "track actual level of cumulated emissions starting from 2020 over iterations [GtCO2]"

*** climate system parameters (move to climate module?)
pm_globalMeanTemperature(tall)                       "global mean temperature anomaly [K]" 
pm_globalMeanTemperatureZeroed1900(tall)             "global mean temperature anomaly, zero around 1900 [K]"
pm_temperatureImpulseResponseCO2(tall,tall)          "temperature impulse response to CO2 [K/GtCO2]"

*** damage parameters, (move to damage module?)
pm_taxCO2eqSCC(ttot,all_regi)                        "carbon tax component due to damages (social cost of carbon) [T$/GtCeq] " 
pm_GDPGross(tall,all_regi)                           "gross GDP (before damages) [T$]"

*** iteration parameters
pm_SolNonInfes(all_regi)                             "model status from last iteration. 1 means status 2 or 7, 0 for all other status codes"
o_iterationNumber                                    "output parameter to be able to display the iteration number"

*** time parameters
pm_ttot_val(ttot)                                    "value of ttot set element"
p_tall_val(tall)                                     "value of tall set element"
pm_ts(tall)                                          "(t_n+1 - t_n-1)/2 for a timestep t_n"
pm_dt(tall)                                          "difference to last timestep"
pm_interpolWeight_ttot_tall(tall)                    "weight for linear interpolation of ttot-dependent variables"
pm_tall_2_ttot(tall,ttot)                            "mapping from tall to ttot"
pm_ttot_2_tall(ttot,tall)                            "mapping from ttot to tall"

*** diagnostic output parameters to help track convergence over iterations
o_negitr_cumulative_peprod(iteration,entyPe)         "estimated production 2005-2100. 'estimated' because of different times step lengths around 2100 [ZJ]"
o_negitr_cumulative_CO2_emineg_co2luc(iteration)     "estimated CO2 emissions from LUC 2005-2100. 'estimated' because of different times step lengths around 2100 [GtCO2]"
o_negitr_cumulative_CO2_emineg_cement(iteration)     "estimated CO2 emissions from cement 2005-2100. 'estimated' because of different times step lengths around 2100 [GtCO2]"
o_negitr_cumulative_CO2_emieng_seq(iteration)        "estimated sequestered CO2 emissions 2005-2100. 'estimated' because of different times step lengths around 2100 [GtCO2]"
o_negitr_disc_cons_dr5_reg(iteration,all_regi)       "estimated discounted consumption 2005-2100 with discount rate 5%. 'estimated' because of different times step lengths around 2100 [T$]"
o_negitr_disc_cons_drInt_reg(iteration,all_regi)     "estimated discounted consumption 2005-2100 with internal discount rate. 'estimated' because of different times step lengths around 2100 [T$]"
o_negitr_total_forc(iteration)                       "total forcing in 2100"

*** not used anymore, can be removed?
p_boundtmp(tall,all_regi,all_te,rlf)                 "read-in bound on capacities" 
p_bound_cap(tall,all_regi,all_te,rlf)                "read-in bound on capacities"
p_datacs(all_regi,all_enty)                          "Primary energy oil that is not comubusted but used for non-energy use [TWa]" 

o_DirlcoCCS(ttot,all_regi,all_te)                    "Annuity per sequestered CO2 by CCS technology, calc. from investment costs and fixOM. [$/tCO2]"
o_DirlcoCCS_total(ttot,all_regi)                     "Total annuity per sequestered CO2. [$/tCO2]"
o_CO2emi_per_energy(ttot,all_regi,all_te)            "Emitted CO2 per MWh energy (main product) produced. [kgCO2/MWh]"
o_seq_CCO2emi_per_energy(ttot,all_regi,all_te)       "Sequestered CO2 per MWh energy produced (main product). [kgCO2/MWh]"
o_lcoemarkup_CCS(ttot,all_regi,all_te)               "Additional LCOE mark-up due to CCS transport&storage. [$/MWh]"

pm_emissionsForeign(tall,all_regi,all_enty)          "total emissions of other regions (nash relevant) [GtC, Mt CH4, Mt N]" 
pm_emissions0(tall,all_regi,all_enty)                "Total emissions of last iteration used for nash algorithm [GtC, Mt CH4, Mt N]" 

p_oldFloorCostdata(all_regi,all_te)                  "print old floor cost data [T$/TW]"
p_newFloorCostdata(all_regi,all_te)                  "print new floor cost data [T$/TW]" 

p_adj_coeff_glob(all_te)                             "coefficient for adjustment costs - global scale [unitless]" 

p_share_seliq_s(ttot,all_regi)                       "share of liquids used for stationary sector (fehos). [0..1]"
p_share_seh2_s(ttot,all_regi)                        "share of hydrogen used for stationary sector (feh2s). [0..1]"
p_share_seel_s(ttot,all_regi)                        "Share of electricity used for stationary sector (feels). [0..1]"
;

*** ------------- Scalars ----------------------------
scalars

*** ------------Unit Conversion Factors---------------
*** All these conversion factors with the form "s_xxx_2_yyy" are multplicative factors. 
*** Thus, if you have a number in Unit xxx, you have to multiply this number by the 
*** conversion factor s_xxx_2_yyy to get the new value in Unit yyy.

*** Conversion of energy units:
*** 1J = 1Ws ==> 1GJ = 10^9 / 3600 kWh = 277.77kWh = 277.77 / 8760 kWyr = 0.03171 kWyr.

*** conversion between orders of magnitude
sm_giga_2_non                "giga to non"                             /1e+9/,
sm_trillion_2_non            "trillion to non"                         /1e+12/,

*** energy units
pm_conv_TWa_EJ               "conversion from TWa to EJ"                          /31.536/,
s_zj_2_twa                   "zeta joule to tw year"                              /31.7098/,
sm_EJ_2_TWa                  "multiplicative factor to convert from EJ to TWa"    /31.71e-03/,
sm_GJ_2_TWa                  "multiplicative factor to convert from GJ to TWa"    /31.71e-12/,
sm_TWa_2_TWh                 "tera Watt year to Tera Watt hour"                    /8.76e+3/,
sm_TWa_2_MWh                 "tera Watt year to Mega Watt hour"                    /8.76e+9/,
sm_TWa_2_kWh                 "tera Watt year to kilo Watt hour"                    /8.76e+12/,
sm_h2kg_2_h2kWh              "convert kilogramme of hydrogen to kwh energy value." /32.5/,
sm_DptCO2_2_TDpGtC           "Conversion multiplier to go from $/tCO2 to T$/GtC: 44/12/1000"     /0.00366667/,
sm_tBC_2_TWa                  "t biochar to TWa biochar (28700 [MJ/tBC]*10^-12[EJ/MJ]/31.536[EJ/TWa])" /9.101e-10/,

*** emissions units
sm_c_2_co2                   "conversion from c to co2"                /3.666666666667/,
s_NO2_2_N                    "convert NO2 to N [14 / (14 + 2 * 16)]"   / .304 /
sm_tgn_2_pgc                 "conversion factor 100-yr GWP from TgN to PgCeq"
sm_tgch4_2_pgc               "conversion factor 100-yr GWP from TgCH4 to PgCeq"
s_MtCO2_2_GtC                "conversion factor from MtCO2 to native REMIND emission unit GtC" /2.727e-04/
s_MtCH4_2_TWa                "Energy content of methane. MtCH4 --> TWa: 1 MtCH4 = 1.23 * 10^6 toe * 42 GJ/toe * 10^-9 EJ/GJ * 1 TWa/31.536 EJ = 0.001638 TWa (BP statistical review)"  /0.001638/
s_gwpCH4                     "Global Warming Potentials of CH4, AR5 WG1 CH08 Table 8.7"     /28/
s_gwpN2O                     "Global Warming Potentials of N2O, AR5 WG1 CH08 Table 8.7"     /265/
s_gwpCH4_AR4                 "Global Warming Potentials of CH4 as in the AR4, used in the MACCs"     /25/
s_gwpN2O_AR4                 "Global Warming Potentials of N2O as in the AR4, used in the MACCs"     /298/

*** monetary units
s_DpKWa_2_TDpTWa             "convert Dollar per kWa to TeraDollar per TeraWattYear"       /0.001/
s_DpKW_2_TDpTW               "convert Dollar per kW to TeraDollar per TeraWatt"            /0.001/
sm_DpGJ_2_TDpTWa             "multipl. factor to convert (Dollar per GJoule) to (TerraDollar per TWyear)"    / 31.54e-03/
s_D2010_2_D2017              "Convert US$2010 to US$2017"      /1.1491/
sm_D2015_2_D2017              "Convert US$2015 to US$2017"      /1.0292/
sm_D2005_2_D2017             "Convert US$2005 to US$2017"      /1.231/
sm_D2020_2_D2017             "Convert US$2020 to US$2017"      /0.9469/
sm_EURO2023_2_D2017          "Convert EURO 2023 to US$2017"    /0.8915/



*** ------------ Scalar Model Parameters ---------------
o_modelstat                  "critical solver status for solution"

* GA sm_dmac changes depending on the choice of MACs in c_nonco2_macc_version
sm_dmac                      "step in MAC functions [US$]"                                                                   
sm_macChange                 "maximum yearly increase of relative abatement in percentage points of maximum abatement. [0..1]"      /0.05/

s_co2pipe_leakage            "Leakage rate of CO2 pipelines. [0..1]"
s_tau_cement                 "range of per capita investments for switching from short-term to long-term behavior in CO2 cement emissions"                / 12000 /
s_c_so2                      "constant, see S. Smith, 2004, Future Sulfur Dioxide Emissions"    /4.39445/
s_ccsinjecrate               "CCS injection rate factor. [1/a]"

s_t_start                    "start year of emission budget"
cm_peakBudgYr                "date of net-zero CO2 emissions for peak budget runs without overshoot"

sm_endBudgetCO2eq            "end time step of emission budget period 1"
sm_budgetCO2eqGlob           "budget for global energy-emissions in period 1"
p_emi_budget1_gdx            "budget for global energy-emissions in period 1 from gdx, may overwrite default values"

sm_globalBudget_absDev       "absolute deviation of global cumulated CO2 emissions budget from target budget"

sm_eps                       "small number: 1e-9 "  /1e-9/

sm_CES_calibration_iteration "current calibration iteration number, loaded from environment variable cm_CES_calibration_iteration"  /0/
;

* GA sm_dmac changes depending on the choice of MACs in c_nonco2_macc_version
$ifthen %c_nonco2_macc_version% == "PBL_2007"
* PBL_2007 MACs are discretized in steps of 5 $2005/tCeq
sm_dmac = 5 * sm_D2005_2_D2017;
$elseif %c_nonco2_macc_version% == "PBL_2022"
* PBL_2022 MACs are discretized in steps of 20 $2010/tCeq
sm_dmac = 20 * s_D2010_2_D2017;;
$endif
;


*** calculate further conversion factors for emissions
sm_tgn_2_pgc = (44/28) * s_gwpN2O * (12/44) * 0.001;
sm_tgch4_2_pgc = s_gwpCH4 * (12/44) * 0.001;

*** carbon intensities of coal, oil, and gas (move to core datainput?)
pm_cintraw("pecoal") = 26.1 / s_zj_2_twa;
pm_cintraw("peoil")  = 20.0 / s_zj_2_twa;
pm_cintraw("pegas")  = 15.0 / s_zj_2_twa;

*** EOF ./core/declarations.gms
