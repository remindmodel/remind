*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/subsectors/declarations.gms

Scalar
  s37_clinker_process_CO2   "CO2 emissions per unit of clinker production"
  s37_plasticsShare         "share of carbon cointained in feedstocks for the chemicals subsector that goes to plastics"
  s37_shareHistFeDemPenalty "Share of the addiotional historic specific FE demand compared with BAT which is applied to non-historic tech"
;

Parameters
  pm_abatparam_Ind(ttot,all_regi,all_enty,steps)                               "industry CCS MAC curves [ratio @ US$2017]"
  pm_energy_limit(all_in)                                                      "thermodynamic/technical limits of subsector energy use [GJ/t product]"
  p37_energy_limit_slope(tall,all_regi,all_in)                                 "limit for subsector specific energy demand that converges towards the thermodynamic/technical limit [GJ/t product]"
  p37_clinker_cement_ratio(ttot,all_regi)                                      "clinker content per unit cement used"
  pm_ue_eff_target(all_in)                                                     "energy efficiency target trajectories [% p.a.]"
  pm_IndstCO2Captured(ttot,all_regi,all_enty,all_enty,secInd37,all_emiMkt)     "Captured CO2 in industry by energy carrier, subsector and emissions market [GtC/a]"
  pm_NonFos_IndCC_fraction0(ttot,all_regi,emiInd37)                        "share of fuel co2 captured that is from sebio or sesyn [fraction]"
  p37_CESMkup(ttot,all_regi,all_in)                                            "parameter for those CES markup cost accounted as investment cost in the budget [trUSD/CES input]"
  p37_cesIO_up_steel_secondary(tall,all_regi,all_GDPpopScen)                      "upper limit to secondary steel production based on scrap availability"
  p37_steel_secondary_max_share(tall,all_regi)                                 "maximum share of secondary steel production"
  p37_BAU_industry_ETS_solids(tall,all_regi)                                   "industry solids demand in baseline scenario"
  p37_cesIO_baseline(tall,all_regi,all_in)                                     "vm_cesIO from the baseline scenario"
  !! process-based implementation
  p37_specMatDem(mat,all_te,opmoPrc)                                           "Specific materials demand of a production technology and operation mode [t_input/t_output]"
  pm_specFeDem(tall,all_regi,all_enty,all_te,opmoPrc)                          "Actual specific final-energy demand of a tech; blends between IEA data and Target [TWa/Gt_output]"
  p37_demFeTarget(tall,all_regi,all_enty,all_in)                               "Total Fe demand that would be have been consumed historically for production of a UE if all tech had BAT efficiency"
  p37_demFeActual(tall,all_regi,all_enty,all_in)                               "Total historic Fe demand consumed for production of a UE"
  p37_specFeDemTarget(all_enty,all_te,opmoPrc)                                 "Best available technology (will be reached in convergence year) [TWa/Gt_output]"
  p37_matFlowHist(tall,all_regi,all_enty)                                      "Total historic material flow calculated as the sum of outputs of all processes producing the respective material [Gt or GtN for fertilizer]"
  p37_ue_share(tall,all_regi,all_enty,all_in)                                  "Share of material to total ue in CES tree"
  p37_mat2ue(tall,all_regi,all_enty,all_in)                                    "Conversion factor of process output to ue in CES tree; Trivial if just one material per UE, as in steel [Gt/Gt], in chemicals [trn$2017/Gt]"
  p37_ueHistTmp(tall,all_regi)                                                 "TODO - Can this be deleted?"
  p37_demFeRatio(tall,all_regi,all_in)                                         "Ratio of historic Fe demand and Fe demand calculated from historic production and BAT specific demand"
  p37_teMatShareHist(all_regi,all_te,opmoPrc,mat)                              "Share that a tePrc/opmoPrc historically contributes to production of a matFin"
  p37_captureRate(all_te)                                                      "Capture rate of CCS technology"
  p37_selfCaptureRate(all_te)                                                  "Share of emissions from fossil fuels used for a CCS process which are captured by the CCS process itself"
  p37_priceMat(tall,all_regi,all_enty)                                         "Prices of external material input [US$/kg] = [trn$US/Gt]"

  p37_chemicals_feedstock_share(ttot,all_regi)               "minimum share of feso/feli/fega in total chemicals FE input [0-1]"
  p37_FeedstockCarbonContent(ttot,all_regi,all_enty)         "carbon content of feedstocks [GtC/TWa]"
  p37_FE_noNonEn(ttot,all_regi,all_enty,all_enty2,emiMkt)    "testing parameter for FE without non-energy use"
  p37_Emi_ChemProcess(ttot,all_regi,all_enty,emiMkt)         "testing parameter for process emissions from chemical feedstocks"
  p37_CarbonFeed_CDR(ttot,all_regi,all_emiMkt)               "testing parameter for carbon in feedstocks from biogenic and synthetic sources"
  p37_IndFeBal_FeedStock_LH(ttot,all_regi,all_enty,emiMkt)   "testing parameter Ind FE Balance left-hand side feedstock term"
  p37_IndFeBal_FeedStock_RH(ttot,all_regi,all_enty,emiMkt)   "testing parameter Ind FE Balance right-hand side feedstock term"
  p37_EmiEnDemand_NonEnCorr(ttot,all_regi)                   "energy demand co2 emissions with non-energy correction"
  p37_EmiEnDemand(ttot,all_regi)                             "energy demand co2 emissions without non-energy correction"
*** output parameters only for reporting
  o37_cementProcessEmissions(ttot,all_regi,all_enty)                     "cement process emissions [GtC/a]"
  o37_demFeIndTotEn(ttot,all_regi,all_enty,all_emiMkt)                   "total FE per energy carrier and emissions market in industry (sum over subsectors)"
  o37_shIndFE(ttot,all_regi,all_enty,secInd37,all_emiMkt)                "share of subsector in FE industry energy carriers and emissions markets"
  o37_demFeIndSub(ttot,all_regi,all_enty,all_enty,secInd37,all_emiMkt)   "FE demand per industry subsector"
  !! process-based implementation
  o37_demFePrc(ttot,all_regi,all_enty,all_te,opmoPrc)                    "Process-based FE demand per FE type and process"
  o37_shareRoute(ttot,all_regi,all_te,opmoPrc,route)                     "The relative share (between 0 and 1) of a technology and operation mode outflow which belongs to a certain route; For example, bf.standard belongs partly to the route bfbof and partly to the route bfbof"
  o37_ProdIndRoute(ttot,all_regi,mat,route)                              "produciton volume of a material via each process route"
  o37_demFeIndRoute(ttot,all_regi,all_enty,all_te,route,secInd37)        "FE demand by FE type, process route and tech"
  o37_specificEmi(ttot,all_regi,all_te,opmoPrc)                          "Specific emissions of a technology; Needed as auxiliary for relative outflow calculation of CC tech"
  !! TODO: make route specific; So far, this only works because the relative outflow of each tech/opmo is the same for all routes.
  o37_relativeOutflow(ttot,all_regi,all_te,opmoPrc)                      "Outflow of a process relative to the outflow of the route, i.e. the final product of that route; Needed for LCOP calculation"

  p37_CESMkup_input(all_in)  "markup cost parameter read in from config for CES levels in industry to influence demand-side cost and efficiencies in CES tree [trUSD/CES input]"
  /
$ifthen.CESMkup "%cm_CESMkup_ind%" == "manual"
    %cm_CESMkup_ind_data%
$endif.CESMkup
  /

$ifthen.sec_steel_scen NOT "%cm_steel_secondary_max_share_scenario%" == "off"   !! cm_steel_secondary_max_share_scenario
  p37_steel_secondary_max_share_scenario(tall,all_regi)   "scenario limits on share of secondary steel production"
  / %cm_steel_secondary_max_share_scenario% /
$endif.sec_steel_scen

  p37_regionalWasteIncinerationCCSMaxShare(ttot,all_regi)    "upper bound on regional proportion of waste incineration that is captured [%]"
$ifthen.cm_wasteIncinerationCCSshare not "%cm_wasteIncinerationCCSshare%" == "off"
  p37_wasteIncinerationCCSMaxShare(ttot,ext_regi)            "switch values for proportion of waste incineration that is captured [%]"
  / %cm_wasteIncinerationCCSshare% /
$endIf.cm_wasteIncinerationCCSshare
;

Positive Variables
  vm_emiIndBase(ttot,all_regi,all_enty,secInd37)                            "industry CCS baseline emissions; Not used for emission accounting outside CCS [GtC/a]"
  vm_emiIndCCS(ttot,all_regi,all_enty)                                      "industry CCS emissions [GtC/a]"
  vm_IndCCSCost(ttot,all_regi,all_enty)                                     "industry CCS cost"
  v37_emiIndCCSmax(ttot,all_regi,emiInd37)                                  "maximum abatable industry emissions"

  !! feedstocks
  v37_incinerationEmi(ttot,all_regi,all_enty,all_enty,all_emiMkt)           "Emissions from incineration of plastic waste, only carbon that is not captured [GtC]"
  vm_incinerationCCS(ttot,all_regi,all_enty,all_enty,all_emiMkt)            "CCS from incineration of plastic waste [GtC]"
  v37_incineratedPlastics(ttot,all_regi,all_enty,all_enty,all_emiMkt)       "Carbon flow: carbon contained in plastics that are incinerated [GtC]"
  v37_feedstocksCarbon(ttot,all_regi,all_enty,all_enty,all_emiMkt)          "Carbon flow: carbon contained in chemical feedstocks [GtC]"
  v37_plasticsCarbon(ttot,all_regi,all_enty,all_enty,all_emiMkt)            "Carbon flow: carbon contained in plastics [GtC]"
  v37_plasticWaste(ttot,all_regi,all_enty,all_enty,all_emiMkt)              "Carbon flow: carbon contained in plastic waste [GtC]"
  v37_regionalWasteIncinerationCCSshare(tall,all_regi)                      "Share of waste incineration that is captured [%]"
  vm_wasteIncinerationEmiBalance(tall,all_regi,all_enty,all_emiMkt)         "Sum of plastics waste incineration related emissions (positive and negative) [GtC]"
  vm_nonFosPlastic_incinCC(ttot,all_regi,all_emiMkt)                        "Carbon from non-fossil origin in plastics that gets incinerated with carbon capture [GtC]"
  vm_nonFosNonPlasticNonEmitted(ttot,all_regi)                           "Carbon from non-fossil origin in non-plastic materials that does not get emitted to the atmosphere [GtC]"
  v37_emiChemicalsProcess(ttot,all_regi,all_enty,all_emiMkt)                "Chemical process emissions, so far only CO2 emissions [GtC]"

  !! process-based implementation
  vm_outflowPrc(tall,all_regi,all_te,opmoPrc)                               "Production volume of processes in process-based model [Gt/a]"
  v37_matFlow(tall,all_regi,all_enty)                                       "Production of materials [Gt/a]"
  v37_matFlowPrim(tall,all_regi,all_enty)                                   "Production of Primary materials [Gt/a]"
  v37_emiPrc(tall,all_regi,all_enty,all_te,opmoPrc)                         "Emissions per process and operation mode [GtC/a]"
  v37_shareWithCC(tall,all_regi,all_te,opmoPrc)                             "Share of process and operation mode equipped with carbon capture technology"
  vm_costMatPrc(tall,all_regi)                                              "Cost of external material inputs such as iron ore in process-based industry [trn $2017/a]"
  v37_matShareChange(tall,all_regi,all_te,opmoPrc,all_enty)                 "Change of share of processes with rectricted relative share change"
  v37_chemFlow(tall,all_regi,all_enty)                                      "Summed material outflow of historic processes with future restricted shares; Needed as auxiliary for calculating material outflows of historic processes from the restricted shares"
  
;

Variables
!! feedstocks
vm_emiFeedstockNoEnergy(ttot,all_regi,all_enty,all_emiMkt)                "Emissions from feedstocks that are not accounted as energy-related emissions, so far only CO2 emissions [GtC]"
vm_emiNonFosNonIncineratedPlastics(ttot,all_regi,all_enty,all_emiMkt)    "Negative CO2 emissions from non-fossil carbon in non-incinerated plastics [GtC]"
v37_emiNonPlasticWaste(ttot,all_regi,all_enty,all_emiMkt)                 "Emissions from non-plastic waste, so far only CO2 emissions [GtC]"
;

Equations
$ifthen.no_calibration "%CES_parameters%" == "load"   !! CES_parameters
  q37_energy_limits(ttot,all_regi,all_in)                                           "thermodynamic/technical limit of energy use"
$endif.no_calibration
  q37_limit_secondary_steel_share(ttot,all_regi)                                    "no more than 90% of steel from seconday production"
  q37_emiIndBase(ttot,all_regi,all_enty,secInd37)                                   "gross industry emissions before CCS"
  q37_emiIndCCSmax(ttot,all_regi,emiInd37)                                          "maximum abatable industry emissions at current CO2 price"
  q37_IndCCS(ttot,all_regi,emiInd37)                                                "limit industry emissions abatement"
  q37_limit_IndCCS_growth(ttot,all_regi,emiInd37)                                   "limit industry CCS scale-up"
  q37_cementCCS(ttot,all_regi)                                                      "link cement fuel and process abatement"
  q37_IndCCSCost                                                                    "Calculate industry CCS costs"
  q37_demFeIndst(ttot,all_regi,all_enty,all_emiMkt)                                 "industry final energy demand (per emission market)"
  q37_costCESmarkup(ttot,all_regi,all_in)                                           "calculation of additional CES markup cost to represent demand-side technology cost of end-use transformation, for example, cost of heat pumps etc."
  q37_chemicals_feedstocks_limit(ttot,all_regi)                                     "lower bound on feso/feli/fega in chemicals FE input for feedstocks"
  q37_demFeFeedstockChemIndst(ttot,all_regi,all_enty,all_emiMkt)                    "defines energy flow of non-energy feedstocks for the chemicals industry. It is used for emissions accounting"
  q37_FeedstocksCarbon(ttot,all_regi,all_enty,all_enty,all_emiMkt)                  "calculate carbon contained in feedstocks [GtC]"
  q37_plasticsCarbon(ttot,all_regi,all_enty,all_enty,all_emiMkt)                    "calculate carbon contained in plastics [GtC]"
  q37_plasticWaste(ttot,all_regi,all_enty,all_enty,all_emiMkt)                      "calculate carbon contained in plastic waste [GtC]"
  q37_incinerationEmi(ttot,all_regi,all_enty,all_enty,all_emiMkt)                   "calculate carbon contained in plastics that are incinerated [GtC]"
  q37_incinerationCCS(ttot,all_regi,all_enty,all_enty,all_emiMkt)                   "calculate carbon captured from plastics that are incinerated [GtC]"
  q37_nonFosPlastic_incinCC(ttot,all_regi,all_emiMkt)                               "calculate non-fossil carbon captured from plastics that are incinerated [GtC]"
  q37_incineratedPlastics(ttot,all_regi,all_enty,all_enty,all_emiMkt)               "calculate carbon contained in plastics that are incinerated [GtC]"
  q37_feedstocksLimit(ttot,all_regi,all_enty,all_enty,all_emiMkt)                   "restrict feedstocks flow to total energy flows into industry"
  q37_feedstocksShares(ttot,all_regi,all_enty,all_enty,all_emiMkt)                  "identical fossil/biomass/synfuel shares for FE and feedstocks"
  q37_wasteIncinerationEmiBalance(tall,all_regi,all_enty,all_emiMkt)                "sum feedstocks incineration emissions up in order not to clutter the core"
  q37_nonFosNonPlasticNonEmitted(ttot,all_regi)                                    "calculate non-fossil carbon in non-plastic materials that are landfilled [GtC]"

  q37_emiChemicalsProcess(ttot,all_regi,all_enty,all_emiMkt)                        "calculate chemicals process emissions"
  q37_emiNonFosNonIncineratedPlastics(ttot,all_regi,all_enty,all_emiMkt)            "calculate negative emissions from non-fossil non-incinerated plastics"
  q37_emiNonPlasticWaste(ttot,all_regi,all_enty,all_emiMkt)                         "calculate emissions from non-plastic waste"
  q37_emiFeedstockNoEnergy(ttot,all_regi,all_enty,all_emiMkt)                       "calculate total emissions from feedstocks that are not accounted as energy-related emissions"

  !! process-based implementation
  q37_demMatPrc(tall,all_regi,mat)                                                  "Material demand of processes"
  q37_prodMat(tall,all_regi,mat)                                                    "Production volume of processes equals material flow of output material"
  q37_mat2ue(tall,all_regi,mat,all_in)                                              "Connect materials production to ue ces tree nodes"
  q37_restrictMatShareChange(tall,all_regi,all_te,opmoPrc,all_enty)                 "Low Constraining the share of chemical fossil fuel technologies based on historical data"
  q37_chemFlow(tall,all_regi,all_enty)                                              "Restrict future share of processes where several historical processes exist for same material, e.g. Coal-MeOH-HVC vs steam cracker"

  q37_limitCapMat(tall,all_regi,all_te)                                             "Material-flow conversion is limited by capacities"
  q37_limitCapMatHist(tall,all_regi,all_te)                                         "Material-flow conversion is limited by capacities"
  q37_emiPrc(ttot,all_regi,all_enty,all_te,opmoPrc)                                 "Local industry emissions pre-capture; Only used as baseline for CCS [GtC/a]"
  q37_emiCCPrc(tall,all_regi,emiInd37)                                              "Captured emissions from CCS"
  q37_limitOutflowCCPrc(tall,all_regi,all_te)                                       "Carbon capture processes can only capture as much co2 as the base process emits"
  q37_costMat(tall,all_regi)                                                        "External material cost (non-energy)"
;

*** EOF ./modules/37_industry/subsectors/declarations.gms
