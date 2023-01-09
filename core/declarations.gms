*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./core/declarations.gms

*LB* declaration of parameters, variables and equations

***----------------------------------------------------------------------------------------
***                                   PARAMETERS
***----------------------------------------------------------------------------------------
parameters

***----------------------------------------------------------------------------------------
***--------------------------------------------------MACRO module--------------------------
***
***prices
pm_pvp(ttot,all_enty)                                "Price on commodity markets",
p_pvpRef(ttot,all_enty)                              "Price on commodity markets - imported from REF gdx",
pm_pvpRegi(ttot,all_regi,all_enty)                   "prices of traded commodities - regional. only used for permit trade"

p_pvpRegiBeforeStartYear(ttot,all_regi,all_enty)     "prices of traded commodities before start year - regional. only used for permit trade"
pm_pricePerm(ttot)                                   "permit price in special case when the marginal is only found in box module"

p_share(ttot,all_regi,all_in,all_in)                 "share of production factors"
pm_share_trans(tall,all_regi)                        "transportation share"
pm_gdp_gdx(tall,all_regi)                            "GDP path from gdx, updated iteratively."
p_inv_gdx(tall,all_regi)                             "macro-investments path from gdx, updated iteratively."
pm_taxCO2eq(ttot,all_regi)                           "CO2 tax path in T$/GtC = $/kgC. To get $/tCO2, multiply with 272 [T$/GtC]"
pm_taxCO2eqRegi(tall,all_regi)                       "additional regional CO2 tax path in T$/GtC = $/kgC. To get $/tCO2, multiply with 272 [T$/GtC]"
pm_taxCO2eqHist(ttot,all_regi)                       "Historic CO2 tax path in 2010 and 2015 (also in BAU!) in T$/GtC = $/kgC. To get $/tCO2, multiply with 272 [T$/GtC]"
pm_taxCO2eqSum(tall,all_regi)                        "sum of pm_taxCO2eq, pm_taxCO2eqRegi, pm_taxCO2eqHist, pm_taxCO2eqSCC in T$/GtC = $/kgC. To get $/tCO2, multiply with 272 [T$/GtC]"
p_taxCO2eq_iteration(iteration,ttot,all_regi)       "save CO2eq tax used in iteration"
pm_taxCO2eq_iterationdiff(ttot,all_regi)              "help parameter for iterative adjustment of taxes"
pm_taxCO2eq_iterationdiff_tmp(ttot,all_regi)          "help parameter for iterative adjustment of taxes"
o_taxCO2eq_iterDiff_Itr(iteration,all_regi) "track p_taxCO2eq_iterationdiff over iterations"
pm_taxemiMkt(ttot,all_regi,all_emiMkt)                "CO2 or CO2eq region and emission market specific emission tax"
pm_taxemiMkt_iteration(iteration,ttot,all_regi,all_emiMkt) "CO2 or CO2eq region and emission market specific emission tax per iteration"
pm_emissionsForeign(tall,all_regi,all_enty)          "total emissions of other regions (nash relevant)"
pm_co2eqForeign(tall,all_regi)                       "emissions, which are part of the climate policy, of other regions (nash relevant)"
pm_cesdata(tall,all_regi,all_in,cesParameter)        "parameters of the CES function"
pm_cesdata_putty(tall,all_regi,all_in,cesParameter)  "quantities for the putty clay factors"
pm_capital_lifetime_exp(all_regi,all_in)             "number of years for which 25% of the CES capital stocks remains"
f_pop(tall,all_regi,all_POPscen)                     "population data for all possible scenarios"
pm_pop(tall,all_regi)                                "population data [bn people]"
pm_gdp(tall,all_regi)                                "GDP data [trn US$ 2005]"
p_developmentState(tall,all_regi)                    "level of development based on GDP per capita"
f_lab(tall,all_regi,all_POPscen)                     "labour data for all possible scenarios"
pm_lab(tall,all_regi)                                "data for labour [bn people]"
pm_esCapCost(tall,all_regi,all_teEs)                 "Capital energy cost per unit of consumption for end-use capital (energy service layer)"
pm_cesdata_sigma(ttot,all_in)                        "elasticities of substitution"
p_r(ttot,all_regi)				     "calculating capital interest rate"

o_diff_to_Budg(iteration)                             "Difference between actual CO2 budget and target CO2 budget"
o_totCO2emi_peakBudgYr(iteration)                     "Total CO2 emissions in the peakBudgYr"
o_peakBudgYr_Itr(iteration)                           "Year in which the CO2 budget is supposed to peak. Is changed in iterative_target_adjust = 9"
o_factorRescale_taxCO2_afterPeakBudgYr(iteration)     "Multiplicative factor for rescaling the CO2 price in the year after peakBudgYr - only needed if flip-flopping of peakBudgYr occurs"
o_delay_increase_peakBudgYear(iteration)              "Counter that tracks if flip-flopping of peakBudgYr happened. Starts an inner loop to try and overcome this"
o_reached_until2150pricepath(iteration)               "Counter that tracks if the inner loop of increasing the CO2 price AFTER peakBudgYr goes beyond the initial trajectory"
p_taxCO2eq_until2150(ttot,all_regi)                   "CO2 price trajectory continued until 2150 - as if there was no change in trajectory after peakBudgYr. Needed to recalculate CO2 price trajectory after peakBudgYr was shifted right"
o_totCO2emi_allYrs(ttot,iteration)                    "Global CO2 emissions over time and iterations. Needed to check the procedure to find the peakBudgYr"
o_change_totCO2emi_peakBudgYr                         "Measure for how much the CO2 emissions change around the peakBudgYr"
p_factorRescale_taxCO2(iteration)                     "Multiplicative factor for rescaling the CO2 price to reach the target"
p_factorRescale_taxCO2_Funneled(iteration)            "Multiplicative factor for rescaling the CO2 price to reach the target - limited by an iteration-dependent funnel"
o_taxCO2eq_Itr_1regi(ttot,iteration)                  "CO2 taxed in the last region, tracked over iterations for debugging"
o_pkBudgYr_flipflop(iteration)                        "Counter that tracks if flipfloping of cm_peakBudgYr occured in the last iterations"
o_taxCO2eq_afterPeakShiftLoop_Itr_1regi(ttot, iteration) "CO2 taxed in the last region, after the loop that shifts peakBudgYr, tracked over iterations for debugging"

***----------------------------------------------------------------------------------------
***-----------------------------------------------ESM module-------------------------------
pm_emiExog(tall,all_regi,all_enty)                   "exogenous emissions"
pm_macBaseMagpie(tall,all_regi,all_enty)              "baseline emissions from MAgPIE (type emiMacMagpie)"
p_macBaseMagpieNegCo2(tall,all_regi)                 "net negative emissions from co2luc"
p_macBaseExo(tall,all_regi,all_enty)                 "exogenous baseline emissions (type emiMacExo)"
pm_macAbat(tall,all_regi,all_enty,steps)             "abatement levels based on data from van Vuuren [fraction]"
pm_macAbatLev(tall,all_regi,all_enty)                "actual level of abatement per time step, region, and source [fraction]"
p_macAbat_lim(tall,all_regi,all_enty)                "limit of abatement level based on limit of yearly change [fraction]"
p_macUse2005(all_regi,all_enty)                      "usage of MACs in 2005 [fraction]"
p_histEmiMac(tall,all_regi,all_enty)                 "historical emissions per MAC; from Eurostat and CEDS, to correct CH4 and N2O reporting"
p_histEmiSector(tall,all_regi,all_enty,emi_sectors,sector_types) "historical emissions per sector; from Eurostat and CEDS, to correct CH4 and N2O reporting"
p_macLevFree(tall,all_regi,all_enty)                 "Phase in of zero-cost MAC options [fraction]"
pm_macCost(tall,all_regi,all_enty)                   "abatement costs for all emissions subject to MACCs (type emiMacSector) []"
pm_macStep(tall,all_regi,all_enty)                   "step number of abatement level [integer]"
pm_macSwitch(all_enty)                               "switch to include mac option in the code"
pm_macCostSwitch(all_enty)                           "switch to include mac costs in the code (e.g. in coupled scenarios, we want to include the costs in REMIND, but MAC effects on emissions are calculated in MAgPIE)"
pm_priceCO2(tall,all_regi)                           "carbon price [$/tC]"
p_priceCO2forMAC(tall,all_regi,all_enty)             "carbon price defined for MAC gases [$/tC]"
p_priceGas(tall,all_regi)                            "gas price in [$/tCeq] for ch4gas MAC"
pm_ResidualCementDemand(tall,all_regi)               "reduction in cemend demand (and thus process emissions) due to climate policy [0...1]"
pm_CementAbatementPrice(ttot,all_regi)               "CO2 price used during calculation of cement demand reduction [$/tCO2]"
pm_CementDemandReductionCost(tall,all_regi)          "cost of reducing cement demand [tn$2005]"
p_macPE(ttot,all_regi,all_enty)                      "pe from MACs"
pm_shPerm(tall, all_regi)                            "emission permit shares"
pm_emicapglob(tall)                                  "global emission cap"
p_adj_coeff(ttot,all_regi,all_te)                    "coefficient for adjustment costs"
p_adj_coeff_glob(all_te)                             "coefficient for adjustment costs - global scale"
p_switch_cement(ttot,all_regi)                       "describes an s-curve to provide a smooth switching from the short-term behavior (depending on per capita capital investments) to the long-term behavior (constant per capita emissions) of CO2 emissions from cement production"
p_cint(all_regi,all_enty,all_enty,rlf)               "additional emissions of GHG from mining, on top of emissions from combustion"

$IFTHEN.agricult_base_shift not "%c_agricult_base_shift%" == "off"
p_agricult_base_shift(ext_regi)                      "fraction by which to scale agricultural emissions of baseline up or down, positive values increase emissions, negative values decrease emissions" / %c_agricult_base_shift% /
p_agricult_shift_phasein(ttot)                       "phase in parameter for baseline agricultural process ch4 and no2 reduction"
p_macBaseMagpie_beforeShift(ttot,all_regi,all_enty)  "pm_macBaseMagpie parameter before shift of c_agricult_base_shift is applied"
$ENDIF.agricult_base_shift

pm_eta_conv(tall,all_regi,all_te)                    "Time-dependent eta for technologies that do not have explicit time-dependant etas, still eta converges until 2050 to dataglob_values. [efficiency (0..1)]"

pm_extRegiEarlyRetiRate(ext_regi)                    "regional early retirement rate (extended regions)" / %c_regi_earlyreti_rate% /
$IFTHEN.tech_earlyreti not "%c_tech_earlyreti_rate%" == "off"
p_techEarlyRetiRate(ext_regi,all_te)                 "Technology specific early retirement rate" / %c_tech_earlyreti_rate% /
$ENDIF.tech_earlyreti
pm_regiEarlyRetiRate(ttot,all_regi,all_te)                "regional early retirement rate (model native regions)"

pm_EN_demand_from_initialcap2(all_regi,all_enty)     "PE demand resulting from the initialcap routine. [EJ, Uranium: MT U3O8]"
pm_budgetCO2eq(all_regi)                             "budget for regional energy-emissions in period 1"
p_actualbudgetco2(tall)                              "actual level of cumulated emissions starting from 2020 [GtCO2]"

pm_dataccs(all_regi,char,rlf)                               "maximum CO2 storage capacity using CCS technology. [GtC]"
pm_ccsinjecrate(all_regi)                                   "Regional CCS injection rate factor. 1/a."
p_extRegiccsinjecrateRegi(ext_regi)                         "Regional CCS injection rate factor. 1/a. (extended regions)"
pm_dataeta(tall,all_regi,all_te)                            "regional eta data"
p_emi_quan_conv_ar4(all_enty)                               "conversion factor for various gases to GtCeq"
pm_emifac(tall,all_regi,all_enty,all_enty,all_te,all_enty)  "emission factor by technology for all types of emissions in emiTe"
pm_omeg (all_regi,opTimeYr,all_te)                          "technical depreciation parameter, gives the share of a capacity that is still usable after tlt. [none/share, value between 0 and 1]"
p_aux_lifetime(all_regi,all_te)                             "auxiliary parameter for calculating life times, calculated externally in excel sheet"
pm_pedem_res(ttot,all_regi,all_te)                          "Demand for pebiolc residues, needed for enhancement of residue potential [TWa]"
p_ef_dem(all_regi,all_enty)                                 "Demand side emission factor of final energy carriers [MtCO2/EJ]"

pm_secBioShare(ttot,all_regi,all_enty,emi_sectors)           "share of biomass per carrier for each sector"

p_avCapFac2015(all_regi,all_te)                             "average capacity factor of non-bio renewables in 2015 in REMIND"
p_aux_capToDistr(all_regi,all_te)                           "aux. param. to calculate p_avCapFac2015; The historic capacity in 2015"
s_aux_cap_remaining                                         "aux. param. to calculate p_avCapFac2015; countdown parameter"
p_aux_capThisGrade(all_regi,all_te,rlf)                     "aux. param. to calculate p_avCapFac2015; How the historic 2015 capacity is distributed among grades"
p_aux_capacityFactorHistOverREMIND(all_regi,all_te)         "aux. param. to calculate capacity factors correction (wind and spv): the ratio of historic over REMIND CapFac in 2015"
p_aux_scaleEmiHistorical_n2o(all_regi)                      "aux. param. to rescale MAgPIE n2o emissions to historical values"
p_aux_scaleEmiHistorical_ch4(all_regi)                      "aux. param. to rescale MAgPIE ch4 emissions to historical values"

$IFTHEN.WindOff %cm_wind_offshore% == "1"
pm_shareWindPotentialOff2On(all_regi)                 "ratio of technical potential of windoff to windon"
pm_shareWindOff(ttot,all_regi)                        "windoff rollout as a fraction of technical potential"
$ENDIF.WindOff

pm_fe2es(tall,all_regi,all_teEs)                     "Conversion factor from final energies to energy services. Default is 1."

pm_shFeCes(ttot,all_regi,all_enty,all_in,all_teEs)   "Final energy shares for CES nodes"

pm_shfe_up(ttot,all_regi,all_enty,emi_sectors)       "Final energy shares exogenous upper bounds per sector"
pm_shfe_lo(ttot,all_regi,all_enty,emi_sectors)       "Final energy shares exogenous lower bounds per sector"
pm_shGasLiq_fe_up(ttot,all_regi,emi_sectors)         "Final energy gases plus liquids shares exogenous upper bounds per sector"
pm_shGasLiq_fe_lo(ttot,all_regi,emi_sectors)         "Final energy gases plus liquids shares exogenous lower bounds per sector"

p_adj_coeff_Orig(ttot,all_regi,all_te)               "initial value of p_adj_coeff"
p_adj_seed_te_Orig(ttot,all_regi,all_te)             "initial value of p_adj_seed_te"
p_varyAdj_mult_adjSeedTe(ttot,all_regi)              "Multiplicative factor to adjust adjustment cost parameter p_adj_seed_te according to CO2 price level"
p_varyAdj_mult_adjCoeff(ttot,all_regi)               "Multiplicative factor to adjust adjustment cost parameter p_adj_coeff according to CO2 price level"
$ifthen not "%cm_adj_seed_cont%" == "off"
  p_new_adj_seed(all_te)                               "redefine adjustment seed parameters through model config switch" / %cm_adj_seed% , %cm_adj_seed_cont% /
$elseif not "%cm_adj_seed%" == "off"
  p_new_adj_seed(all_te)                               "redefine adjustment coefficient parameters through model config switch"  / %cm_adj_seed% /
$endif
$ifthen not "%cm_adj_coeff_cont%" == "off"
  p_new_adj_coeff(all_te)                              "new adj coef parameters" / %cm_adj_coeff% , %cm_adj_coeff_cont% /
$elseif not "%cm_adj_coeff%" == "off"
  p_new_adj_coeff(all_te)                              "new adj coef parameters" / %cm_adj_coeff% /
$endif

$ifthen not "%cm_adj_seed_multiplier%" == "off"
  p_adj_seed_multiplier(all_te)                               "factor to multiply standard adjustment seed with" / %cm_adj_seed_multiplier% /
$endif

$ifthen not "%cm_adj_coeff_multiplier%" == "off"
  p_adj_coeff_multiplier(all_te)                               "factor to multiply standard adjustment cost coefficient with" / %cm_adj_coeff_multiplier% /
$endif

$ifthen.VREPot_Factor not "%c_VREPot_Factor%" == "off"
  p_VREPot_Factor(all_te) "Rescale factor for renewable potentials" / %c_VREPot_Factor% /
$endif.VREPot_Factor

p_boundtmp(tall,all_regi,all_te,rlf)                 "read-in bound on capacities"
p_bound_cap(tall,all_regi,all_te,rlf)                "read-in bound on capacities"
pm_data(all_regi,char,all_te)                        "Large array for most technical parameters of technologies; more detail on the individual technical parameters can be found in the declaration of the set 'char' "
pm_cf(tall,all_regi,all_te)                          "Installed capacity availability - capacity factor (fraction of the year that a plant is running)"
p_tkpremused(all_regi,all_te)                       "turn-key cost premium used in the model (with a discount rate of 3+ pure rate of time preference); in comparison to overnight costs)"
p_aux_tlt(all_te)                                    "auxilliary parameter to determine maximal lifetime of a technology"
p_aux_check_omeg(all_te)                             "auxiliary parameter for an automated check that no technology is erroneously entered with pm_omeg('1') value of 0"
p_aux_check_tlt(all_te)                              "auxiliary parameter for an automated check that the pm_omeg calculation and filling of the opTimeYr2te mapping is in accordance"
p_aux_tlt_max(all_te)                                "auxiliary parameter to find the last mapping in opTimeYr2te for each technology"
pm_vintage_in(all_regi,opTimeYr,all_te)              "historical vintage structure. [arbitrary]"
p_efFossilFuelExtr(all_regi,all_enty,all_enty)       "emission factor for CH4 from fossil fuel extraction and N2O from bioenergy"
p_efFossilFuelExtrGlo(all_enty,all_enty)             "global emission factor for CH4 from fossil fuel extraction and N2O from bioenergy"
pm_dataren(all_regi,char,rlf,all_te)                 "Array including both regional renewable potential and capacity factor"
p_datapot(all_regi,char,rlf,all_enty)                "Total land area usable for the solar technologies PV and CSP. [km^2]"
p_adj_seed_reg(tall,all_regi)                        "market capacity that can be built from 0 and gives v_adjFactor=1"
p_adj_seed_te(ttot,all_regi,all_te)                                "technology-dependent multiplicative prefactor to the v_adjFactor seed value. Smaller means slower scale-up"
*** appears in q_esm2macro and q_balFeForCes. This energy category is 0 in LAM, IND and AFR in 2005, but a value > 0 is needed for the calculation of CES parameters.
*** Accordingly, a value of sm_eps is inserted in pm_cesdata to allow calculation of the CES parameters.
p_datacs(all_regi,all_enty)                          "fossil energy that is not oxidized (=carbon stored)"
pm_inco0_t(ttot,all_regi,all_te)                     "New inco0 that is time-dependent for some technologies. [T$/TW]"
*LB* calculate parameter pm_tsu2opTimeYr for the eq q_transPe2se and q_cap;
***this parameter counts backwards from time ttot - only the existing time steps
p_tsu2opTimeYr_h(ttot,opTimeYr)                      "parameter to generate pm_tsu2opTimeYr",
pm_tsu2opTimeYr(ttot,opTimeYr)                       "parameter that counts opTimeYr regarding tsu2opTimeYr apping"
pm_emissions0(tall,all_regi,all_enty)                "Emissions in last iteration"
pm_co2eq0(tall,all_regi)                             "vm_co2eq from last iteration"
pm_capCum0(tall,all_regi,all_te)                     "vm_capCum from last iteration"
p_capCum(tall, all_regi,all_te)                      "vm_capCum from input.gdx for recalibration of learning investment costs"

pm_capCumForeign(ttot,all_regi,all_te)               "parameter for learning externality (cumulated capacity of other regions except regi)"
pm_SolNonInfes(all_regi)                             "model status from last iteration. 1 means status 2 or 7, 0 for all other status codes"

p_cintraw(all_enty)                                  "carbon intensity of fossils [GtC per TWa]"

p_CapFixFromRWfix(ttot,all_regi,all_te)              "parameter for fixing capacity variable to Real-World values in 2010/2015"
p_deltaCapFromRWfix(ttot,all_regi,all_te)            "parameter with resulting deltacap values resulting from fixing capacity to real-world values in 2010/2015"

o_margAdjCostInv(ttot,all_regi,all_te)               "marginal adjustment cost calculated in postsolve for diagnostics"
o_avgAdjCostInv(ttot,all_regi,all_te)                "average adjustment cost calculated in postsolve for diagnostics"
o_avgAdjCost_2_InvCost_ratioPc(ttot,all_regi,all_te)   "ratio in % of average adj cost compared to direct inv costs"

pm_calibrate_eff_scale(all_in,all_in,eff_scale_par)   "parameters for scaling efficiencies in CES calibration"
/   /

pm_fedemand(tall,all_regi,all_in)                     "final energy demand"
pm_share_CCS_CCO2(ttot,all_regi)                      "share of stored CO2 from total captured CO2"

pm_delta_histCap(tall,all_regi,all_te)                "parameter to store data of historic capacity additions [TW/yr]"

* Energy carrier Prices
pm_FEPrice(ttot,all_regi,all_enty,sector,emiMkt)      "parameter to capture all FE prices across sectors and markets (tr$2005/TWa)"
pm_FEPrice_iter(iteration,ttot,all_regi,all_enty,sector,emiMkt) "parameter to capture all FE prices across sectors and markets (tr$2005/TWa) across iterations"
pm_SEPrice(ttot,all_regi,all_enty)                    "parameter to capture all SE prices (tr$2005/TWa)"
pm_PEPrice(ttot,all_regi,all_enty)                    "parameter to capture all PE prices (tr$2005/TWa)"

p_FEPrice_by_SE_Sector_EmiMkt(ttot,all_regi,entySe,all_enty,sector,emiMkt) "parameter to save FE price per SE, sector and emission market (tr$2005/TWa)"
p_FEPrice_by_Sector_EmiMkt(ttot,all_regi,all_enty,sector,emiMkt) "parameter to save FE marginal price per sector and emission market (tr$2005/TWa)"
pm_FEPrice_by_SE_Sector(ttot,all_regi,entySe,all_enty,sector)     "parameter to save FE marginal price per SE and sector (tr$2005/TWa)"
p_FEPrice_by_SE_EmiMkt(ttot,all_regi,entySe,all_enty,emiMkt)     "parameter to save FE marginal price per SE and emission market (tr$2005/TWa)"
p_FEPrice_by_SE(ttot,all_regi,entySe,all_enty)                   "parameter to save FE marginal price per SE (tr$2005/TWa)"
p_FEPrice_by_Sector(ttot,all_regi,all_enty,sector)               "parameter to save FE marginal price per sector (tr$2005/TWa)"
p_FEPrice_by_EmiMkt(ttot,all_regi,all_enty,emiMkt)               "parameter to save FE marginal price per emission market (tr$2005/TWa)"
p_FEPrice_by_FE(ttot,all_regi,all_enty)                          "parameter to save FE marginal price (tr$2005/TWa)"

p_FEPrice_by_SE_Sector_EmiMkt_iter(iteration,ttot,all_regi,entySe,all_enty,sector,emiMkt) "parameter to save iteration FE marginal price per SE, sector and emission market (tr$2005/TWa)"
p_FEPrice_by_Sector_EmiMkt_iter(iteration,ttot,all_regi,all_enty,sector,emiMkt) "parameter to save iteration FE marginal price per sector and emission market (tr$2005/TWa)"
p_FEPrice_by_SE_Sector_iter(iteration,ttot,all_regi,entySe,all_enty,sector)     "parameter to save iteration FE marginal price per SE and sector (tr$2005/TWa)"
p_FEPrice_by_SE_EmiMkt_iter(iteration,ttot,all_regi,entySe,all_enty,emiMkt)     "parameter to save iteration FE marginal price per SE and emission market (tr$2005/TWa)"
p_FEPrice_by_SE_iter(iteration,ttot,all_regi,entySe,all_enty)                   "parameter to save iteration FE marginal price per SE (tr$2005/TWa)"
p_FEPrice_by_Sector_iter(iteration,ttot,all_regi,all_enty,sector)               "parameter to save iteration FE marginal price per sector (tr$2005/TWa)"
p_FEPrice_by_EmiMkt_iter(iteration,ttot,all_regi,all_enty,emiMkt)               "parameter to save iteration FE marginal price per emission market (tr$2005/TWa)"
p_FEPrice_by_FE_iter(iteration,ttot,all_regi,all_enty)                          "parameter to save iteration FE marginal price (tr$2005/TWa)"

pm_tau_fe_tax(ttot,all_regi,emi_sectors,all_enty)    "tax path for final energy"
pm_tau_fe_sub(ttot,all_regi,emi_sectors,all_enty)    "subsidy path for final energy"

*** climate related
pm_globalMeanTemperature(tall)                       "global mean temperature anomaly"
pm_globalMeanTemperatureZeroed1900(tall)             "global mean temperature anomaly, zeroed around 1900"
pm_temperatureImpulseResponseCO2(tall,tall)          "temperature impulse response to CO2 [K/GtCO2]"

*** damage related
pm_taxCO2eqSCC(ttot,all_regi)                        "carbon tax component due to damages (social cost of carbon) "
pm_GDPGross(tall,all_regi)                           "gross GDP (before damages)"

***----------------------------------------------------------------------------------------
*** ----- Parameters needed for MAGICC ----------------------------------------------------
p_MAGICC_emi(tall,RCP_regions_world_bunkers,emiRCP)  "emission data to export"
***----------------------------------------------------------------------------------------
***---------------------------parameter for output-----------------------------------------
o_DirlcoCCS(ttot,all_regi,all_te)                    "Annuity per sequestered CO2 by CCS technology, calc. from investment costs and fixOM. [$/tCO2]"
o_DirlcoCCS_total(ttot,all_regi)                     "Total annuity per sequestered CO2. [$/tCO2]"
o_CO2emi_per_energy(ttot,all_regi,all_te)            "Emitted CO2 per MWh energy (main product) produced. [kgCO2/MWh]"
o_seq_CCO2emi_per_energy(ttot,all_regi,all_te)       "Sequestered CO2 per MWh energy produced (main product). [kgCO2/MWh]"
o_lcoemarkup_CCS(ttot,all_regi,all_te)               "Additional LCOE mark-up due to CCS transport&storage. [$/MWh]"

o_INI_DirProdSeTe                                    "directly produced SE by technology in 2005 (from initialcap2)"
o_INI_TotalDirProdSe                                 "Total direct SE production in 2005 (from initialcap2)"
o_INI_TotalCap                                       "Total electricity producing capacity in 2005 (from initialcap2)"
o_INI_AvCapFac                                       "Average regional capacity factor of the power sector in 2005 (from initialcap2)"

o_iterationNumber                                    "output parameter to be able to display the iteration number"
***   Keep track of ESM numbers for output to see changes between iterations
o_negitr_cumulative_peprod(iteration,entyPe)         "estimated production 2005-2100. 'estimated' because of different times step lengths around 2100 [ZJ]"
o_negitr_cumulative_CO2_emineg_co2luc(iteration)     "estimated CO2 emissions from LUC 2005-2100. 'estimated' because of different times step lengths around 2100 [GtCO2]"
o_negitr_cumulative_CO2_emineg_cement(iteration)     "estimated CO2 emissions from cement 2005-2100. 'estimated' because of different times step lengths around 2100 [GtCO2]"
o_negitr_cumulative_CO2_emieng_seq(iteration)        "estimated sequestered CO2 emissions 2005-2100. 'estimated' because of different times step lengths around 2100 [GtCO2]"
o_negitr_disc_cons_dr5_reg(iteration,all_regi)       "estimated discounted consumption 2005-2100 with discount rate 5%. 'estimated' because of different times step lengths around 2100 [T$]"
o_negitr_disc_cons_drInt_reg(iteration,all_regi)     "estimated discounted consumption 2005-2100 with internal discount rate. 'estimated' because of different times step lengths around 2100 [T$]"
o_negitr_total_forc(iteration)                       "total forcing in 2100"

***----------------------------------------------------------------------------------------
***------------------------------------------------trade module----------------------------
pm_ttot_val(ttot)                                    "value of ttot set element"
p_tall_val(tall)                                     "value of tall set element"
pm_ts(tall)                                          "(t_n+1 - t_n-1)/2 for a timestep t_n"
pm_dt(tall)                                          "difference to last timestep"
pm_interpolWeight_ttot_tall(tall)                    "weight for linear interpolation of ttot-dependent variables"
pm_tall_2_ttot(tall,ttot)                            "mapping from tall to ttot"
pm_ttot_2_tall(ttot,tall)                            "mapping from ttot to tall"

p_share_seliq_s(ttot,all_regi)                       "share of liquids used for stationary sector (fehos). [0..1]"
p_share_seh2_s(ttot,all_regi)                        "share of hydrogen used for stationary sector (feh2s). [0..1]"
p_share_seel_s(ttot,all_regi)                        "Share of electricity used for stationary sector (feels). [0..1]"

p_discountedLifetime(all_te)                         "Sum over the discounted (@6%) depreciation factor (omega)"
p_teAnnuity(all_te)                                  "Annuity factor of a technology"

;

***----------------------------------------------------------------------------------------
***                                   VARIABLES
***----------------------------------------------------------------------------------------
variables
***----------------------------------------------------------------------------------------
***--------------------------------------------------MACRO module--------------------------
vm_taxrev(ttot,all_regi)                             "difference between tax volume in current and previous iteration"
vm_costSubsidizeLearning(ttot,all_regi)              "regional cost of subsidy for learning technologies"
vm_dummyBudget(ttot,all_regi)                        "auxiliary variable that helps to meet permit allocation equation in nash case"
***----------------------------------------------------------------------------------------
***-------------------------------------------------ESM module-----------------------------
vm_macBase(ttot,all_regi,all_enty)                   "baseline emissions for all emissions subject to MACCs (type emismac)"
vm_emiCO2Sector(ttot,all_regi,emi_sectors)           "total CO2 emissions from individual sectors [GtC]"
vm_emiTeDetail(ttot,all_regi,all_enty,all_enty,all_te,all_enty)  "energy-related emissions per region and technology"
vm_emiTe(ttot,all_regi,all_enty)                     "total energy-related emissions of each region. [GtC, Mt CH4, Mt N]"
vm_emiMacSector(ttot,all_regi,all_enty)              "total non-energy-related emission of each region. [GtC, Mt CH4, Mt N]"
vm_emiCdr(ttot,all_regi,all_enty)                    "total (negative) emissions due to CDR technologies of each region. [GtC]"
vm_emiMac(ttot,all_regi,all_enty)                    "total non-energy-related emission of each region. [GtC, Mt CH4, Mt N]"
vm_emiAll(ttot,all_regi,all_enty)                    "total regional emissions. [GtC, Mt CH4, Mt N]"
vm_emiAllGlob(ttot,all_enty)                         "total global emissions - link to the climate module. [GtC, Mt CH4, Mt N]"
vm_perm(ttot,all_regi)                               "emission allowances"
vm_co2eqGlob(ttot)                                   "global emissions to be balanced by allowances. [GtCeq]"
vm_co2eq(ttot,all_regi)                              "total emissions measured in co2 equivalents ATTENTION: content depends on multigasscen. [GtCeq]"
vm_co2eqMkt(ttot,all_regi,all_emiMkt)                                         "total emissions per market measured in co2 equivalents ATTENTION: content depends on multigasscen. [GtCeq]"
v_co2eqCum(all_regi)                                 "cumulated vm_co2eq emissions for the first budget period.  [GtCeq]"
vm_banking(ttot,all_regi)                            "banking of emission permits"
v_adjFactor(tall,all_regi,all_te)                    "factor to multiply with investment costs for adjustment costs"
v_adjFactorGlob(tall,all_regi,all_te)                "factor to multiply with investment costs for adjustment costs - global scale"
v_costInvTeDir(tall,all_regi,all_te)                 "annual direct investments into a technology"
v_costInvTeAdj(tall,all_regi,all_te)                 "annual investments into a technology due to adjustment costs"
vm_usableSe(ttot,all_regi,entySe)                    "usable se before se2se and MP/XP (pe2se, +positive oc from pe2se, -storage losses). [TWa]"
vm_usableSeTe(ttot,all_regi,entySe,all_te)           "usable se produced by one te (pe2se, +positive oc from pe2se, -storage losses). [TWa]"
vm_costFuBio(ttot,all_regi)                          "fuel costs from bio energy [tril$US]"
vm_omcosts_cdr(tall,all_regi)                        "O&M costs for spreading grinded rocks on fields"
vm_costpollution(tall,all_regi)                      "costs for air pollution policies"
vm_emiFgas(ttot,all_regi,all_enty)                   "F-gas emissions by single gases from IMAGE"
vm_emiTeDetailMkt(tall,all_regi,all_enty,all_enty,all_te,all_enty,all_emiMkt) "emissions from fuel combustion per region, technology and emission market. [GtC, Mt CH4, Mt N]"
vm_emiTeMkt(tall,all_regi,all_enty,all_emiMkt)       "total energy-emissions of each region and emission market. [GtC, Mt CH4, Mt N]"
v_emiEnFuelEx(ttot,all_regi,all_enty)                 "energy emissions from fuel extraction [GtC, Mt CH4, Mt N]"
vm_emiAllMkt(tall,all_regi,all_enty,all_emiMkt)      "total regional emissions for each emission market. [GtC, Mt CH4, Mt N]"
vm_flexAdj(tall,all_regi,all_te)                     "flexibility adjustment used for flexibility subsidy (tax) to emulate price changes of technologies which see lower-than-average (higher-than-average) elec. prices [trUSD/TWa]"
vm_costCESMkup(ttot,all_regi,all_in)                  "CES markup cost to represent demand-side technology cost of end-use transformation [trUSD/TWa]"
vm_taxrevimplicitQttyTargetTax(ttot,all_regi)        "quantity target bound implemented through implict tax"
vm_taxrevimplicitPriceTax(ttot,all_regi,entySe,all_enty,sector)   "final energy price target implemented through implict tax"
vm_taxrevimplicitPePriceTax(ttot,all_regi,all_enty)  "primary energy price target implemented through implict tax"

;

***----------------------------------------------------------------------------------------
***                                   POSITIVE VARIABLES
***----------------------------------------------------------------------------------------
positive variables
***----------------------------------------------------------------------------------------
***-------------------------------------------------MACRO module---------------------------
vm_enerSerAdj(tall,all_regi,all_in)                  "adjustment costs for energy service transformations"
vm_esCapInv(ttot,all_regi,all_teEs)                   "investment for energy end-use capital at the energy service level"
***----------------------------------------------------------------------------------------
*-----------------------------------------------ESM module---------------------------------
vm_costEnergySys(ttot,all_regi)                      "energy system costs"

vm_cap(tall,all_regi,all_te,rlf)                     "net total capacities"
vm_capDistr(tall,all_regi,all_te,rlf)                "net capacities, distributed to the different grades for renewables"
vm_capTotal(ttot,all_regi,all_enty,all_enty)         "total capacity without technology differentation for technologies where there exists differentation [TW]"
vm_capFac(ttot,all_regi,all_te)                      "capacity factor of conversion technologies"
vm_deltaCap(tall,all_regi,all_te,rlf)                "capacity additions"
vm_capCum(tall,all_regi,all_te)                      "gross capacities (=capacities cumulated over time)"
vm_fuExtr(ttot,all_regi,all_enty,rlf)                "fuel use [TWa]"

vm_demPe(tall,all_regi,all_enty,all_enty,all_te)     "pe demand. [TWa, Uranium: Mt Ur]"
vm_prodPe(ttot,all_regi,all_enty)                    "pe production. [TWa, Uranium: Mt Ur]"
vm_demSe(ttot,all_regi,all_enty,all_enty,all_te)     "se demand. [TWa]"
vm_prodSe(tall,all_regi,all_enty,all_enty,all_te)    "se production. [TWa]"
vm_prodFe(ttot,all_regi,all_enty,all_enty,all_te)    "fe production. [TWa]"
vm_demFeSector(ttot,all_regi,all_enty,all_enty,emi_sectors,all_emiMkt)          "fe demand per sector and emission market. Taxes should be applied to this variable or variables closer to the supply side whenever possible so the marginal prices include the tax effects. [TWa]"
vm_demFeSector_afterTax(ttot,all_regi,all_enty,all_enty,emi_sectors,all_emiMkt) "fe demand per sector and emission market after tax. Demand sectors should use this variable in their fe balance equations so demand side marginals include taxes effects. [TWa]"
v_costFu(ttot,all_regi)                              "fuel costs"
vm_costFuEx(ttot,all_regi,all_enty)                  "fuel costs from exhaustible energy [tril$US]"
vm_pebiolc_price(ttot,all_regi)                      "Bioenergy price according to MAgPIE supply curves [T$US/TWa]"

v_costOM(ttot,all_regi)                              "o&m costs"
v_costInv(ttot,all_regi)                             "investment costs"
vm_costTeCapital(ttot,all_regi,all_te)               "investment costs"
vm_costAddTeInv(tall,all_regi,all_te,emi_sectors)    "additional sector-specific investment cost of demand-side transformation"

vm_co2CCS(ttot,all_regi,all_enty,all_enty,all_te,rlf)       "all differenct ccs. [GtC/a]"

vm_co2capture(ttot,all_regi,all_enty,all_enty,all_te,rlf)   "all captured CO2. [GtC/a]"
v_co2capturevalve(ttot,all_regi)                            "CO2 emitted right after capture [GtC/a] (in q_balCCUvsCCS to account for different lifetimes of capture and CCU/CCS te and capacities)"

vm_prodUe(ttot,all_regi,all_enty,all_enty,all_te)    "Useful energy production [TWa]"

vm_capEarlyReti(tall,all_regi,all_te)                "fraction of early retired capital"
vm_otherFEdemand(ttot,all_regi,all_enty)             "final energy demand from no transformation technologies (e.g. enhanced weathering)"

vm_demSeOth(ttot,all_regi,all_enty,all_te)	         "other sety demand from certain technologies, have to calculated in additional equations [TWa]"
vm_prodSeOth(ttot,all_regi,all_enty,all_te)	         "other sety production from certain technologies, have to be calculated in additional equations [TWa]"

v_shGreenH2(ttot,all_regi)   "share of green hydrogen in all hydrogen by 2030 [0..1]"
v_shBioTrans(ttot,all_regi)    "Share of biofuels in transport liquids from 2025 onwards. Value between 0 and 1."

v_shfe(ttot,all_regi,all_enty,emi_sectors)           "share of final energy in sector total final energy [0..1]"
v_shGasLiq_fe(ttot,all_regi,emi_sectors)             "share of gases and liquids in sector final energy [0..1]"

vm_emiCdrAll(ttot,all_regi)                          "all CDR emissions"

*** ES layer variables
vm_demFeForEs(ttot,all_regi,all_enty,all_esty,all_teEs)     "Final energy which will be used in the ES layer."

vm_prodEs(ttot,all_regi,all_enty,all_esty,all_teEs)          "Energy services (unit determined by conversion factor pm_fe2es)."
vm_transpGDPscale(ttot,all_regi)                            "dampening factor to align edge-t non-energy transportation costs with historical GDP data"  

;
***----------------------------------------------------------------------------------------
***                                   EQUATIONS
***----------------------------------------------------------------------------------------
equations
***----------------------------------------------------------------------------------------
***------------------------------------------------MACRO module----------------------------
q_limitSeel2fehes(ttot,all_regi)                     "equation to limit the share of electricity that can be used for fehes"
q_esCapInv(ttot,all_regi,all_teEs)                   "investment equation for end-use capital investments (energy service layer)"
***----------------------------------------------------------------------------------------
***-----------------------------------------------ESM module-------------------------------
q_costEnergySys(ttot,all_regi)                       "energy system costs"

q_costFu(ttot,all_regi)                              "costs of fuels"
q_costOM(ttot,all_regi)                              "costs of o&m"
q_costInv(ttot,all_regi)                             "costs of investment"

q_cap(tall,all_regi,all_te,rlf)                      "definition of available capacities"
q_capDistr(tall,all_regi,all_te)                     "distribute available capacities across grades"
q_capTotal(ttot,all_regi,all_enty,all_enty)          "calculation of vm_capTotal as total capacity without technology differentation for technologies where there exists differentation"

$IFTHEN.WindOff %cm_wind_offshore% == "1"
q_windoff_low(tall,all_regi)                         "semi-endogenous offshore wind power generation as a share of onshore wind energy, which is proportional to more than half of maxprod ratio"
q_windoff_high(tall,all_regi)                        "semi-endogenous offshore wind power generation as a share of onshore wind energy, which is proportional to less than twice of maxprod ratio"
$ENDIF.WindOff

q_limitCapSe(ttot,all_regi,all_enty,all_enty,all_te)    "capacity constraint for se production"
q_limitCapSe2se(ttot,all_regi,all_enty,all_enty,all_te) "capacity constraint for se to se transformation"
q_limitCapFe(ttot,all_regi,all_te)                      "capacity constraint for fe production"

q_capCumNet(t0,all_regi,all_te)                      "cumulative net capactiy"
qm_deltaCapCumNet(ttot,all_regi,all_te)              "increase of cumulative net capacity"

q_costTeCapital(tall,all_regi,all_te)                "calculation of investment cost for learning technologies"

q_balPe(ttot,all_regi,all_enty)                      "balance of primary energy (pe)"
q_balSe(ttot,all_regi,all_enty)                      "balance of secondary energy (se)"
qm_balFe(ttot,all_regi,all_enty,all_enty,all_te)     "balance of final energy (fe)"
q_balFeAfterTax(ttot,all_regi,all_enty,all_enty,emi_sectors,all_emiMkt) "balance of final energy after considering FE sectoral taxes (fe)"

q_transPe2se(ttot,all_regi,all_enty,all_enty,all_te) "energy tranformation pe to se"
q_transSe2fe(ttot,all_regi,all_enty,all_enty,all_te) "energy tranformation se to fe"
q_transSe2se(ttot,all_regi,all_enty,all_enty,all_te) "energy transformation se to se"

qm_fuel2pe(ttot,all_regi,all_enty)                   "constraint on cumulative fuel use"

q_limitProd(ttot,all_regi,all_te,rlf)                "constraint on annual production"

q_emiCO2Sector(ttot,all_regi,emi_sectors)            "CO2 emissions from different sectors"
q_emiTeDetail(ttot,all_regi,all_enty,all_enty,all_te,all_enty) "determination of emissions"
q_macBase(tall,all_regi,all_enty)                    "baseline emissions for all emissions subject to MACCs (type emiMacSector)"
q_emiMacSector(ttot,all_regi,all_enty)               "total non-energy-related emission of each region"
q_emiTe(ttot,all_regi,all_enty)                      "total energy-emissions per region"
q_emiAll(ttot,all_regi,all_enty)                     "calculates all regional emissions as sum over energy and non-energy relates emissions"
q_emiAllGlob(ttot,all_enty)                          "calculates all global emissions as sum over regions"
q_emiCap(ttot,all_regi)                              "emission cap"
q_emiMac(ttot,all_regi,all_enty)                     "summing up all non-energy emissions"
q_co2eq(ttot,all_regi)                               "regional emissions in co2 equivalents"
q_co2eqMkt(ttot,all_regi,all_emiMkt)                           "regional emissions per market in co2 equivalents"
q_co2eqGlob(ttot)                                    "global emissions in co2 equivalents"
qm_co2eqCum(all_regi)                                "cumulate regional emissions over time"
q_budgetCO2eqGlob                                    "global emission budget balance"

q_emiTeDetailMkt(ttot,all_regi,all_enty,all_enty,all_te,all_enty,all_emiMkt) "detailed energy specific emissions per region and market"
q_emiTeMkt(ttot,all_regi,all_enty,all_emiMkt)			             "total energy-emissions per region and market"
q_emiEnFuelEx(ttot,all_regi,all_enty)                "energy emissions from fuel extraction"
q_emiAllMkt(ttot,all_regi,all_enty,all_emiMkt)       "total regional emissions for each emission market"


q_transCCS(ttot,all_regi,all_enty,all_enty,all_te,all_enty,all_enty,all_te,rlf)        "transformation equation for ccs"
q_limitCapCCS(ttot,all_regi,all_enty,all_enty,all_te,rlf)                              "capacity constraint for ccs"
q_limitCCS(all_regi,all_enty,all_enty,all_te,rlf)                                      "ccs constraint for sequestration alternatives"

q_emiCdrAll(ttot,all_regi)                           "summing over all CDR emissions"

q_balcapture(ttot,all_regi,all_enty,all_enty,all_te)  "balance equation for carbon capture"
q_balCCUvsCCS(ttot,all_regi)                          "balance equation for captured carbon to CCU or CCS or valve"

q_limitSo2(ttot,all_regi)                             "prevent SO2 from rising again after 2050"
q_limitCO2(ttot,all_regi)                             "prevent CO2 from rising again after 2050"

q_limitGeopot(ttot,all_regi,all_enty,rlf)             "constraint on annual renewable production due to competition for the same geographical potential"

q_costInvTeAdj(ttot,all_regi,all_te)                  "calculation of total adjustment costs for a technology"
q_costInvTeDir(ttot,all_regi,all_te)                  "calculation of total direct investment costs (without adjustment costs) for a technology"
q_eqadj(all_regi,tall,all_te)                         "calculation of adjustment factor for a technology"

q_limitCapEarlyReti(ttot,all_regi,all_te)             "constraint to avoid reactivation of retired capacities"
q_smoothphaseoutCapEarlyReti(ttot,all_regi,all_te)    "phase-out constraint for early retirement to avoid immediate retirement"
q_limitBiotrmod(ttot,all_regi)                        "limit the total amount of modern biomass use for solids to the amount of coal use for solids "
q_limitShOil(ttot,all_regi)                           "requires minimum share of liquids from oil in total fossil liquids"
q_PE_histCap(ttot,all_regi,all_enty,all_enty)         "model capacity must be equal or greater than historical capacity"
q_PE_histCap_NGCC_2020_up(ttot,all_regi,all_enty,all_enty) "gas capacity can only increase by 50% maximum from 2015 to 2020, plus 10 GW to account for extra flexibility in regions with small 2015 capacity"

*** ES layer equations
q_transFe2Es(ttot,all_regi,all_enty,all_esty,all_teEs)    "Conversion from final energy to energy service"
q_es2ppfen(ttot,all_regi,all_in)                          "Energy services are handed to the CES tree."
q_shFeCes(ttot,all_regi,all_enty,all_in,all_teEs)         "Shares of final energies in production factors."
*q_shFeCesNorm(ttot,all_regi,all_in)                      "Shares have to sum to 1."
q_shGreenH2(ttot,all_regi)  "share of green hydrogen in all hydrogen"
q_shBioTrans(ttot,all_regi)  "Define the share of biofuels in transport liquids from 2025 on."

q_shfe(ttot,all_regi,all_enty,emi_sectors)            "share of final energy carrier in the sector final energy"
q_shGasLiq_fe(ttot,all_regi,emi_sectors)              "share of gases and liquids in sector final energy"

q_shbiofe_up(ttot,all_regi,all_enty,emi_sectors,all_emiMkt) "share of biomass per carrier in sector final energy (upper bound)"
q_shbiofe_lo(ttot,all_regi,all_enty,emi_sectors,all_emiMkt) "share of biomass per carrier in sector final energy (lower bound)"

q_capH2BI(ttot,all_regi)                                  "H2 infrastructure capacities of buildings and industry need to add up to the total infrastructure of the stationary sector"
q_limitCapFeH2BI(ttot,all_regi,emi_sectors)               "capacity limit equation for H2 infrastructure capacities of buildings and industry"


$IFTHEN.sehe_upper not "%cm_sehe_upper%" == "off"
q_heat_limit(ttot,all_regi)  "equation to limit maximum level of secondary energy district heating and heat pumps use"
$ENDIF.sehe_upper

***----------------------------------------------------------------------------------------
***----------------------------------------------trade module------------------------------

;
***----------------------------------------------------------------------------------------
***                                   SCALARS
***----------------------------------------------------------------------------------------
scalars
o_modelstat                                           "critical solver status for solution"

***----------------------------------------------------------------------------------------
***------------------------------------------------MACRO module----------------------------

***----------------------------------------------------------------------------------------
***-----------------------------------------------ESM module-------------------------------
pm_conv_TWa_EJ                                        "conversion from TWa to EJ"               /31.536/,
sm_c_2_co2                                            "conversion from c to co2"                /3.666666666667/,
*** conversion factors of time units
sm_year_2_day                                         "days per year"                           /365/,
sm_day_2_hour                                         "hours per day"                           /24/,
sm_mega_2_non                                         "mega to non"                             /1e+6/,
sm_giga_2_non                                         "giga to non"                             /1e+9/,
sm_trillion_2_non                                     "trillion to non"                         /1e+12/,
*** conversion of energy units
*** 1J = 1Ws ==> 1GJ = 10^9 / 3600 kWh = 277.77kWh = 277.77 / 8760 kWyr = 0.03171 kWyr
s_zj_2_twa                                            "zeta joule to tw year"                              /31.7098/,
sm_EJ_2_TWa                                           "multiplicative factor to convert from EJ to TWa"    /31.71e-03/,
sm_GJ_2_TWa                                           "multiplicative factor to convert from GJ to TWa"    /31.71e-12/,
sm_TWa_2_MWh                                          "tera Watt year to Mega Watt hour"                    /8.76e+9/,
sm_TWa_2_kWh                                          "tera Watt year to kilo Watt hour"                    /8.76e+12/,
*RP* all these new conversion factors with the form "s_xxx_2_yyy" are multplicative factors. Thus, if you have a number in Unit xxx, you have to
*RP* multiply this number by the conversion factor s_xxx_2_yyy to get the new value in Unit yyy.
s_NO2_2_N                                             "convert NO2 to N [14 / (14 + 2 * 16)]"   / .304 /
s_DpKWa_2_TDpTWa                                      "convert Dollar per kWa to TeraDollar per TeraWattYear"       /0.001/
sm_DpKW_2_TDpTW                                       "convert Dollar per kW to TeraDollar per TeraWatt"            /0.001/
sm_DpGJ_2_TDpTWa                                      "multipl. factor to convert (Dollar per GJoule) to (TerraDollar per TWyear)"    / 31.54e-03/
s_gwpCH4                                              "Global Warming Potentials of CH4, AR5 WG1 CH08 Table 8.7"     /28/
s_gwpN2O                                              "Global Warming Potentials of N2O, AR5 WG1 CH08 Table 8.7"     /265/
sm_dmac                                               "step in MAC functions [US$]"                                                                   /5/
s_macChange                                           "maximum yearly increase of relative abatement in percentage points of maximum abatement. [0..1]"      /0.05/
sm_tgn_2_pgc                                           "conversion factor 100-yr GWP from TgN to PgCeq"
sm_tgch4_2_pgc                                         "conversion factor 100-yr GWP from TgCH4 to PgCeq"

s_MtCH4_2_TWa                                        "Energy content of methane. MtCH4 --> TWa: 1 MtCH4 = 1.23 * 10^6 toe * 42 GJ/toe * 10^-9 EJ/GJ * 1 TWa/31.536 EJ = 0.001638 TWa (BP statistical review)"  /0.001638/

sm_D2015_2_D2005                                      "Convert $2015 to $2005 by dividing by 1.2: 1/1.2 = 0.8333"      /0.8333/
sm_DptCO2_2_TDpGtC                                    "Conversion multiplier to go from $/tCO2 to T$/GtC: 44/12/1000"     /0.00366667/

s_co2pipe_leakage                                     "Leakage rate of CO2 pipelines. [0..1]"
s_tau_cement                                          "range of per capita investments for switching from short-term to long-term behavior in CO2 cement emissions"                / 12000 /
s_c_so2                                               "constant, see S. Smith, 2004, Future Sulfur Dioxide Emissions"    /4.39445/
s_ccsinjecrate                                        "CCS injection rate factor. [1/a]"

s_t_start                                             "start year of emission budget"
cm_peakBudgYr                                         "date of net-zero CO2 emissions for peak budget runs without overshoot"

sm_endBudgetCO2eq                                     "end time step of emission budget period 1"
sm_budgetCO2eqGlob                                    "budget for global energy-emissions in period 1"
p_emi_budget1_gdx                                     "budget for global energy-emissions in period 1 from gdx, may overwrite default values"

s_actualbudgetco2                                     "actual level of 2020-2100 cumulated emissions, including all CO2 for last iteration"
s_actualbudgetco2_last                                "actual level of 2020-2100 cumulated emissions for previous iteration" /0/

sm_globalBudget_dev                                   "actual level of global cumulated emissions budget divided by target budget"

sm_eps                                                "small number: 1e-9 "  /1e-9/

sm_CES_calibration_iteration                          "current calibration iteration number, loaded from environment variable cm_CES_calibration_iteration"  /0/

***----------------------------------------------------------------------------------------
***----------------------------------------------trade module------------------------------
;

sm_tgn_2_pgc = (44/28) * s_gwpN2O * (12/44) * 0.001;
sm_tgch4_2_pgc = s_gwpCH4 * (12/44) * 0.001;

***----------------------------------------------------------------------------------------
*----------------------------------------------carbon intensities of coal, oil, and gas
p_cintraw("pecoal") = 26.1 / s_zj_2_twa;
p_cintraw("peoil")  = 20.0 / s_zj_2_twa;
p_cintraw("pegas")  = 15.0 / s_zj_2_twa;

***----------------------------------------------------------------------------------------
***                                   F I L E S
***----------------------------------------------------------------------------------------
file magicc_scenario /                                   "./magicc/REMIND_%c_expname%.SCEN" /;

magicc_scenario.ap = 0;
magicc_scenario.pw = 3000;

file magicc_sed_script /                                 "./magicc/modify_MAGCFG_USER_CFG.sed" /;

magicc_sed_script.ap = 0;

*** emissions reporting helper parameters

Parameter
o_emissions(ttot,all_regi,all_enty)   "output parameter"
o_emissions_bunkers(ttot,all_regi,all_enty)    "output parameter"
o_emissions_energy(ttot,all_regi,all_enty)   "output parameter"
o_emissions_energy_demand(ttot,all_regi,all_enty)   "output parameter"
o_emissions_energy_demand_sector(ttot,all_regi,all_enty,emi_sectors)   "output parameter"
o_emissions_energy_supply_gross(ttot,all_regi,all_enty)   "output parameter"
o_emissions_energy_supply_gross_carrier(ttot,all_regi,all_enty,all_enty)   "output parameter"
o_emissions_energy_extraction(ttot,all_regi,all_enty,all_enty)   "output parameter"
o_emissions_energy_negative(ttot,all_regi,all_enty)   "output parameter"
o_emissions_industrial_processes(ttot,all_regi,all_enty)   "output parameter"
o_emissions_AFOLU(ttot,all_regi,all_enty)   "output parameter"
o_emissions_DACCS(ttot,all_regi,all_enty)   "output parameter"
o_emissions_other(ttot,all_regi,all_enty)   "output parameter"

o_capture(ttot,all_regi,all_enty)   "output parameter"
o_capture_energy(ttot,all_regi,all_enty)   "output parameter"
o_capture_energy_elec(ttot,all_regi,all_enty)   "output parameter"
o_capture_energy_other(ttot,all_regi,all_enty)   "output parameter"
o_capture_cdr(ttot,all_regi,all_enty)   "output parameter"
o_capture_industry(ttot,all_regi,all_enty)   "output parameter"
o_capture_energy_bio(ttot,all_regi,all_enty)   "output parameter"
o_capture_energy_fos(ttot,all_regi,all_enty)   "output parameter"
o_carbon_CCU(ttot,all_regi,all_enty)   "output parameter"
o_carbon_LandUse(ttot,all_regi,all_enty)   "output parameter"
o_carbon_underground(ttot,all_regi,all_enty)   "output parameter"
o_carbon_reemitted(ttot,all_regi,all_enty)   "output parameter"

o_emi_conv(all_enty)    "output parameter" / co2 3666.6666666666666666666666666667, ch4 28, n2o 416.4286, so2 1,	bc  1, oc  1 /
;

*** EOF ./core/declarations.gms
