*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/10_emissions/SectorAggregates/declarations.gms


*** ------------- Parameters -----------------------------------------
parameters

*** emissions-factor input and derived parameters
pm_emifac(tall,all_regi,all_enty,all_enty,all_te,all_enty)      "emission factor by technology for all types of energy-related emissions [GtC/TWa, Mt CH4/TWa, Mt N, Mt SO2/TWa, Mt BC/TWa, Mt OC]"
p10_ef_dem(all_regi,all_enty)                                   "read-in parameter for demand side emission factors of final energy carriers [MtCO2/EJ]"
pm_cintraw(all_enty)                                            "CO2 emissions factor of fossil fuels [GtC/TWa]"
p10_cint(all_regi,all_enty,all_enty,rlf)                        "CO2 emissions factor of energy-related emissions from unconventional fossil fuel extraction [GtC/TWa]"
pm_PeProdEmifac(all_regi,all_enty,all_enty)                     "CH4 and N2O emission factor of PE production: fugitive CH4 from fossil fuel extraction and N2O from bioenergy [Mt CH4/TWA, Mt N/TWa]"
pm_PeProdEmifacGlo(all_enty,all_enty)                           "CH4 and N2O emission factor of PE production - global value: fugitive CH4 from fossil fuel extraction and N2O from bioenergy [Mt CH4/TWA, Mt N/TWa]"
pm_share_CCS_CCO2(ttot,all_regi)                                "share of stored CO2 from total captured CO2 from previous iteration [share]"
p10_co2pipe_leakage                                             "leakage rate of CO2 pipelines [0..1]"

$ifthen.tech_CO2capturerate not "%c_tech_CO2capturerate%" == "off"
p10_tech_CO2capturerate(all_te)                      "Technology specific CO2 capture rate, fraction of carbon from input fuel that is captured [share]" / %c_tech_CO2capturerate% /
p10_PECarriers_CarbonContent(all_enty)               "Carbon content of PE carriers [GtC/TWa]"
$endif.tech_CO2capturerate
;



*** ------------- Variables ----------------------------------------
variables

*** total emissions
vm_co2eqGlob(ttot)                                   "total global greenhouse gas emissions to be balanced by allowances [GtCeq]"
vm_co2eq(ttot,all_regi)                              "total greenhouse gas emissions measured in co2 equivalents that are subject to carbon pricing, be aware that emissions coverage of this variable depends on switch cm_multigasscen [GtCeq]"
vm_co2eqMkt(ttot,all_regi,all_emiMkt)                "total greenhouse gas emissions per market measured in co2 equivalents that are subject to carbon pricing, be aware that emissions coverage of this variable depends on switch cm_multigasscen [GtCeq]"
vm_emiAll(ttot,all_regi,all_enty)                    "total emissions by species [GtC, Mt CH4, Mt N, Mt SO2, Mt BC, Mt OC]"
v10_co2eqCum(all_regi)                                 "cumulated vm_co2eq emissions for the first budget period [GtCeq]"
vm_emiGHG_exclLULUCF_exclBunkers(ttot,all_regi)       "total GHG emissions excl LULUCF and excl bunkers, needed for NDC targets [GtCeq]"

*** sectoral emissions
vm_emiTeDetail(ttot,all_regi,all_enty,all_enty,all_te,all_enty)  "emissions from energy technologies on supply-side (pm_emifac * PE) and demand-side (pm_emifac * FE), note: not equivalent to Emi|CO2|Energy in reporting [GtC, Mt CH4, Mt N, Mt SO2, Mt BC, Mt OC]"
v10_emiEnFuelEx(ttot,all_regi,all_enty)                "energy-related CO2 emissions from fossil fuel extraction [GtC]"
vm_emiTe(ttot,all_regi,all_enty)                     "proxy of total energy-related emissions, based on vm_emiTeDetail and taking into account industry CCS, CCU and feedstocks note: not equivalent to Emi|CO2|Energy in reporting [GtC, Mt CH4, Mt N, Mt SO2, Mt BC, Mt OC]"
vm_emiCO2Sector(ttot,all_regi,emi_sectors)           "total CO2 emissions from individual sectors, so far only buildings and transport excl. bunkers [GtC]"
vm_macBase(ttot,all_regi,all_enty)                    "baseline emissions for all emissions subject to MACCs, emissions that are not energy-related [GtC, Mt CH4, Mt N]"
vm_emiMacSector(ttot,all_regi,all_enty)              "total emissions subject to MACCs, emissions that are not energy-related [GtC, Mt CH4, Mt N]"

vm_emiCdr(ttot,all_regi,all_enty)                    "total (negative) CO2 emissions from CDR technologies that are calculated in the CDR module. Note that it includes all atmospheric CO2 entering the CCUS chain (i.e. CO2 stored (CDR) AND used (not CDR)) [GtC]"
vm_emiMac(ttot,all_regi,all_enty)                    "total non-energy-related emission of each region. [GtC, Mt CH4, Mt N]"
vm_emiFgas(ttot,all_regi,all_enty)                   "F-gas emissions by single gases from IMAGE [emiFgasTotal in MtCO2eq, for other units see f_emiFgas.cs4r]"

*** emissions per emissions market
vm_emiTeDetailMkt(tall,all_regi,all_enty,all_enty,all_te,all_enty,all_emiMkt) "emissions from energy technologies on supply-side (pm_emifac * PE) and demand-side (pm_emifac * FE) per emissions market, note: not equivalent to Emi|CO2|Energy in reporting [GtC, Mt CH4, Mt N, Mt SO2, Mt BC, Mt OC]"
vm_emiTeMkt(tall,all_regi,all_enty,all_emiMkt)       "proxy of total energy-related emissions per emissions market, based on vm_emiTeDetail and taking into account industry CCS, CCU and feedstocks note: not equivalent to Emi|CO2|Energy in reporting [GtC, Mt CH4, Mt N, Mt SO2, Mt BC, Mt OC]"
vm_emiAllMkt(tall,all_regi,all_enty,all_emiMkt)      "total emissions per emissions market [GtC, Mt CH4, Mt N, Mt SO2, Mt BC, Mt OC]"
;

*** ------------- Positive Variables --------------------------------
positive variables

vm_co2capture(ttot,all_regi)                                 "total captured CO2 [GtC/year]"
vm_co2CCS(ttot,all_regi,all_enty,all_enty,all_te,rlf)       "total CO2 injected into geological storage [GtC/a]"
vm_co2capturevalve(ttot,all_regi)                            "total CO2 emitted right after capture [GtC/a], note: used in q10_balCCUvsCCS to account for different lifetimes of capture and CCU/CCS te and capacities [GtC/year]"
v10_ccsShare(ttot,all_regi)                                    "fraction of captured CO2 that is stored geologically [share]"
vm_emiCdrNovel(ttot,all_regi)                                 "all novel CDR emissions, gross removals for all options, excluding land-use change emissions and materials [GtC/year]"
vm_emiCdrAll(ttot,all_regi)                                  "all CDR emissions, net negative emissions from land-use change, gross removals for all other options [GtC/year]"
;



*** ------------- Equations -----------------------------------------
equations
q10_emiCO2Sector(ttot,all_regi,emi_sectors)            "CO2 emissions from different sectors"
q10_emiTeDetail(ttot,all_regi,all_enty,all_enty,all_te,all_enty) "determination of emissions"
q10_macBase(tall,all_regi,all_enty)                    "baseline emissions for all emissions subject to MACCs (type emiMacSector)"
q10_emiMacSector(ttot,all_regi,all_enty)               "total non-energy-related emission of each region"
q10_emiTe(ttot,all_regi,all_enty)                      "total energy-emissions per region"
q10_emiAll(ttot,all_regi,all_enty)                     "calculates all regional emissions as sum over energy and non-energy relates emissions"
q10_emiCap(ttot,all_regi)                              "emission cap"
q10_emiMac(ttot,all_regi,all_enty)                     "summing up all non-energy emissions"
qm_co2eq(ttot,all_regi)                                "regional emissions in co2 equivalents"
q10_co2eqMkt(ttot,all_regi,all_emiMkt)                 "regional emissions per market in co2 equivalents"
q10_co2eqGlob(ttot)                                    "global emissions in co2 equivalents"
qm_co2eqCum(all_regi)                                "cumulate regional emissions over time"
q10_budgetCO2eqGlob                                    "global emission budget balance"
q10_emiTeDetailMkt(ttot,all_regi,all_enty,all_enty,all_te,all_enty,all_emiMkt) "detailed energy specific emissions per region and market"
q10_emiTeMkt(ttot,all_regi,all_enty,all_emiMkt)        "total energy-emissions per region and market"
q10_emiEnFuelEx(ttot,all_regi,all_enty)                "energy emissions from fuel extraction"
q10_emiAllMkt(ttot,all_regi,all_enty,all_emiMkt)       "total regional emissions for each emission market"
q10_emiCdrNovel(ttot,all_regi)                         "sum over all CDR emissions, except net negative land-use change emissions and materials"
q10_emiCdrAll(ttot,all_regi)                           "sum over all CDR emissions, incl. net negative land-use change emissions and materials"
q10_balcapture(ttot,all_regi)                          "balance equation for carbon capture"
q10_balCCUvsCCS(ttot,all_regi)                         "balance equation for captured carbon to CCU or CCS or valve"
q10_ccsShare(ttot,all_regi)                            "calculate the share of captured CO2 that is stored geologically"
q10_emiGHG_exclLULUCF_exclBunkers(ttot,all_regi)       "calculate total GHG emissions excl LULUCF and excl bunkers"
;



*** ==================================================================
*** ==================================================================
*' ### Non-CO2 emissions plus LUC MACCs
*** ==================================================================
*** ==================================================================

*' Declarations of the parameters for non-CO2 emissions and land-use change (LUC) CO2 with marginal
*' abatement cost curves (MACCs): baselines, abatement, prices, costs and the scalars of the MAC steps.

***   1. Parameters for MACCs
***   2. Tracking across Nash iterations
***   3. Scalars for the MAC steps


*** ==================================================================
*' #### 1. Parameters for MACCs
*** ==================================================================

parameters

*** parameters used for MAC curves
pm_macBaseMagpie(tall,all_regi,all_enty)             "baseline emissions from MAgPIE (type emiMacMagpie) [GtC, Mt CH4, Mt N]"
f10_macBaseMagpie_coupling(tall,all_regi,all_enty)   "baseline emissions from MAgPIE (type emiMacMagpie) read from magpie.gdx in coupling [GtC, Mt CH4, Mt N]"
p10_macBaseMagpieNegCo2(tall,all_regi)                 "net negative CO2 emissions from land-use change [GtC]"
p10_macBaseExo(tall,all_regi,all_enty)                 "exogenous baseline emissions (type emiMacExo) [Mt CH4, Mt N]"
p10_co2lucSub(tall,all_regi,all_enty)                "subtypes of CO2 land use change emissions, add up to total land use change emissions, coming from MAgPIE, passed through REMIND for reporting, not used anywhere, remain unchanged [GtC]"
pm_macAbat(tall,all_regi,all_enty,steps)             "abatement levels based on data from van Vuuren [fraction]"
pm_macAbatLev(tall,all_regi,all_enty)                "actual level of abatement per time step, region, and source [fraction]"
p10_macAbat_lim(tall,all_regi,all_enty)                "limit of abatement level based on limit of yearly change [fraction]"
p10_macUse2005(all_regi,all_enty)                      "usage of MACs in 2005 [fraction]"
p10_histEmiMac(tall,all_regi,all_enty)                 "historical emissions per MAC (type emiMacSector); from Eurostat and CEDS, to correct CH4 and N2O reporting [GtC, Mt CH4, Mt N]"
p10_histEmiSector(tall,all_regi,all_enty,emi_sectors,sector_types) "historical emissions per sector; from Eurostat and CEDS, to correct CH4 and N2O reporting [GtC, Mt CH4, Mt N]"
p10_macLevFree(tall,all_regi,all_enty)                 "Phase in of zero-cost MAC options [fraction]"
pm_macCost(tall,all_regi,all_enty)                   "abatement costs for all emissions subject to MACCs (type emiMacSector) [T$]"
pm_macStep(tall,all_regi,all_enty)                   "step number of abatement level [integer]"
pm_macSwitch(ttot,all_regi,all_enty)                 "switch to include mac options in specific sectors and years [0/1]"
p10_macCostSwitch(all_enty)                            "switch to include mac costs in the code [0/1] (e.g. in coupled scenarios, we want to include the costs in REMIND, but MAC effects on emissions are calculated in MAgPIE)"
pm_macPE(ttot,all_regi,all_enty)                     "Primary energy production from MACs, e.g. methane production from abated methane leakage in coal extraction [TWa]"
p10_priceCO2(tall,all_regi)                          "carbon price [$/tC]"
p10_priceCO2forMAC(tall,all_regi,all_enty)             "carbon price defined for MAC gases [$/tC]"
p10_priceGas(tall,all_regi)                            "gas price for ch4gas MAC [$/tCeq]"
p10_emi_quan_conv_ar4(all_enty)                        "conversion factor of non-CO2 greenhouses gases to GtCeq"

$IFTHEN.agricult_base_shift not "%c_agricult_base_shift%" == "off"
p10_agricult_base_shift(ext_regi)                      "fraction by which to scale agricultural emissions of baseline up or down, positive values increase emissions, negative values decrease emissions [fraction]" / %c_agricult_base_shift% /
p10_agricult_shift_phasein(ttot)                       "phase in parameter for baseline agricultural process ch4 and no2 reduction [share]"
p10_macBaseMagpie_beforeShift(ttot,all_regi,all_enty)  "pm_macBaseMagpie parameter before shift of c_agricult_base_shift is applied [GtC, Mt CH4, Mt N]"
$ENDIF.agricult_base_shift

p10_aux_scaleEmiHistorical_n2o(all_regi)               "auxiliary parameter to rescale MAgPIE n2o emissions to historical values [Mt N]"
p10_aux_scaleEmiHistorical_ch4(all_regi)               "auxiliary parameter to rescale MAgPIE ch4 emissions to historical values [Mt CH4]"

;


*** ==================================================================
*' #### 2. Tracking across Nash iterations
*** ==================================================================

parameters

o_pm_macBaseMagpie(iteration,ttot,all_regi,all_enty) "track pm_macBaseMagpie across Nash iterations"
o_pm_macSwitch(iteration,ttot,all_regi,all_enty)     "track pm_macSwitch across Nash iterations"
o_pm_PeProdEmifac_n2obio(iteration,all_regi)          "track pm_PeProdEmifac for n2obio across Nash iterations"

;


*** ==================================================================
*' #### 3. Scalars for the MAC steps
*** ==================================================================

scalars

* GA sm_dmac changes depending on the choice of MACs in cm_nonco2_macc_version
sm_dmac                      "step in MAC functions [US$]"                                                                   
sm_macChange                 "maximum yearly increase of relative abatement in percentage points of maximum abatement. [0..1]"      /0.05/
;

* GA sm_dmac changes depending on the choice of MACs in cm_nonco2_macc_version
$ifthen %cm_nonco2_macc_version% == "PBL_2007"
* PBL_2007 MACs are discretized in steps of 5 $2005/tCeq
sm_dmac = 5 * sm_D2005_2_D2017;
$elseif %cm_nonco2_macc_version% == "PBL_2022"
* PBL_2022 MACs are discretized in steps of 20 $2010/tCeq
sm_dmac = 20 * sm_D2010_2_D2017;
$endif
;

*** EOF ./modules/10_emissions/SectorAggregates/declarations.gms
