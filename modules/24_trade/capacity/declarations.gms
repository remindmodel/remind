*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/24_trade/capacity/declarations.gms

***-------------------------------------------------------------------------------
***                                   SCALARS
***-------------------------------------------------------------------------------
SCALARS
  s24_switchTradeModel                                                        "Switch to activate trade model eqns before trade solve and to deactivate them during main solve" /0/
;

***-------------------------------------------------------------------------------
***                                   PARAMETERS
***-------------------------------------------------------------------------------
PARAMETERS
  pm_tradecostgood(all_regi)                                                  "Trade costs (final good)."
  pm_Xport0(tall,all_regi,all_enty)                                           "Reference level value of export." 
  pm_IO_trade(tall,all_regi,all_enty,char)                                    "Energy trade bounds based on IEA data."
  p24_Mport2005correct(all_regi,all_enty)                                     "Correction factor to match fossil supply and internal region energy demand in the initial year"

  pm_MPortsPrice(tall,all_regi,all_enty)                                      "Secondary energy import price for region. Calculated in the postsolve and assuming that trade is distributed uniformetly according existent capacities defined at p24_seTradeCapacity [T$/TWa]"
  pm_XPortsPrice(tall,all_regi,all_enty)                                      "Secondary energy export price for region. Calculated in the postsolve and corresponding to the region secondary energy price [T$/TWa]"

  p24_Xport(ttot,all_regi,all_enty)                                           "Export of traded commodity."
  p24_Mport(ttot,all_regi,all_enty)                                           "Import of traded commodity."
  p24_XportEff(ttot,all_regi,all_enty)                                        "Export of traded commodity effective (computed from imports)."
  p24_XMportPipe(all_regi,all_regi,all_enty)                                  "Export and imports of traded commodity via pipeline."
  
  p24_Xport_iter(iteration,tall,all_regi,all_enty)                            "Iterative values of vm_Xport for diagnostics."
  p24_Mport_iter(iteration,tall,all_regi,all_enty)                            "Iterative values of vm_Mport for diagnostics."
  p24_shipment_quan_iter(iteration,ttot,all_regi,all_regi,tradeModes)         "Iterative values of v24_trade for diagnostics."
  p24_cap_tradeTransp_iter(iteration,ttot,all_regi,all_regi,teTrade)          "Iterative values of v24_capTrade for diagnostics."
;

***-------------------------------------------------------------------------------
***                                   VARIABLES
***-------------------------------------------------------------------------------
VARIABLES
  v24_tradeCostGlob                                                           "Objective variable for optimisation inside trade module"
;

POSITIVE VARIABLES
  vm_budgetTradeX(ttot,all_regi)                                              "Export budget of regions"
  vm_budgetTradeM(ttot,all_regi)                                              "Import budget of regions"
  
  vm_Xport(tall,all_regi,all_enty)                                            "Export of traded commodity."
  vm_Mport(tall,all_regi,all_enty)                                            "Import of traded commodity."
  
  v24_trade(ttot,all_regi,all_regi,tradeModes)                                "Shipment quantities for different transportation modes"
  
  v24_capTrade(ttot,all_regi,all_regi,teTrade)                                "Net total capacities for transportation"
  v24_capEarlyRetiTrade(ttot,all_regi,all_regi,teTrade)                       "Early retired capacity"
  
  v24_deltaCapTrade(ttot,all_regi,all_regi,teTrade)                           "Capacity additions for transportation"
  
  v24_costTradeCap(ttot,all_regi,all_enty)                                    "Cost incurring from trade transportation"
  v24_costTradePrice(ttot,all_regi,all_enty)                                  "Total income or expense generated from trade"
;

***-----------------------------------------------------------------------------
***                                   EQUATIONS
***-----------------------------------------------------------------------------
EQUATIONS
  v24_objFunc                                                                 "Objective function for optimisation inside trade module"
  
  q24_budgetTradeX(ttot,all_regi)                                             "Export budget of regions"
  q24_budgetTradeM(ttot,all_regi)                                             "Import budget of regions"
  
  q24_tradeFromMports(ttot,all_regi,all_enty)                                 "Total imports of each region must equal the demanded imports"
  
  q24_limitCapTradeBilat(ttot,all_regi,all_regi,teTrade)                      "Trade is limited by capacity for pipelines."
  q24_limitCapTradeXport(ttot,all_regi,teTrade)                               "Trade is limited by capacity for Xport terminals."
  q24_limitCapTradeMport(ttot,all_regi,teTrade)                               "Trade is limited by capacity for Mport terminals."
  
  q24_capTrade(ttot,all_regi,all_regi,teTrade)                                "Trade transportation capacities from deltaCap."
  q24_limitDeltaCap(ttot,all_regi,all_regi,teTrade)                           "Limit deltaCap."
  q24_prohibitMX(ttot,all_regi,tradeCap)                                      "Prohibit importers to be exessive exporters."

  q24_costTradeCap(ttot,all_regi,all_enty)                                    "Cost incurring from trade transportation"
  q24_costTradePrice(ttot,all_regi,all_enty)                                  "Total income or expense generated from trade"
;

*** EOF ./modules/24_trade/capacity/declarations.gms
