*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
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
  
  pm_MPortsPrice(tall,all_regi,all_enty)                                      "Secondary energy import price for region (only used in se_trade realisation)."

  pm_XPortsPrice(tall,all_regi,all_enty)                                      "Export price for region (capacity realisation). Calculated in the postsolve and corresponding to the region secondary energy price [T$/TWa]"
  p24_Xport(ttot,all_regi,all_enty)                                           "Export of traded commodity."
  
*** tracking iterative values of parameters and variables for diagnostics
  p24_XPortsPrice_iter(iteration,ttot,all_regi,all_enty)                      "Iterative values of pm_XPortsPrice for diagnostics."
  
  p24_Xport_iter(iteration,ttot,all_regi,all_enty)                            "Iterative values of vm_Xport for diagnostics."
  p24_Mport_iter(iteration,ttot,all_regi,all_enty)                            "Iterative values of vm_Mport for diagnostics."
  
  p24_trade_iter(iteration,ttot,all_regi,all_regi,tradeModes)                 "Iterative values of v24_trade for diagnostics."
  
  p24_capTrade_iter(iteration,ttot,all_regi,all_regi,teTrade)                 "Iterative values of v24_capTrade for diagnostics."
;

***-------------------------------------------------------------------------------
***                                   VARIABLES
***-------------------------------------------------------------------------------
POSITIVE VARIABLES
  vm_Xport(tall,all_regi,all_enty)                                            "Export of traded commodity."
  vm_Mport(tall,all_regi,all_enty)                                            "Import of traded commodity."

  vm_costTradeCap(tall,all_regi,all_enty)                                     "Trade technology and transportation cost"
  vm_capacityTradeBalance(tall,all_regi)                                      "Capacity trade balance term"

  v24_trade(tall,all_regi,all_regi,tradeModes)                                "Shipment quantities for different transportation modes"

  v24_capTrade(tall,all_regi,all_regi,teTrade)                                "Net total capacities for transportation"
  v24_capEarlyRetiTrade(tall,all_regi,all_regi,teTrade)                       "Early retired capacity"
  v24_deltaCapTrade(tall,all_regi,all_regi,teTrade)                           "Capacity additions for transportation"
;

***-----------------------------------------------------------------------------
***                                   EQUATIONS
***-----------------------------------------------------------------------------
EQUATIONS
  q24_tradeFromMports(ttot,all_regi,tradeCap)                                 "Total imports of each region must equal the demanded imports"
***q24_prohibitMX(ttot,all_regi,tradeCap)                                      "Prohibit importers to be exessive exporters."

  q24_limitCapTradeBilat(ttot,all_regi,all_regi,teTrade)                      "Trade is limited by capacity for pipelines."
  q24_limitCapTradeXport(ttot,all_regi,teTrade)                               "Trade is limited by capacity for Xport terminals."
  q24_limitCapTradeMport(ttot,all_regi,teTrade)                               "Trade is limited by capacity for Mport terminals."

  q24_capTrade(ttot,all_regi,all_regi,teTrade)                                "Trade transportation capacities from deltaCap."
  q24_limitDeltaCap(ttot,all_regi,all_regi,teTrade)                           "Limit deltaCap."

  q24_costTradeCap(ttot,all_regi,tradeCap)                                    "Trade technology and transportation cost"
  q24_tradeBalanceTerms(ttot,all_regi)                                        "Capacity trade balance term"
;

*** EOF ./modules/24_trade/capacity/declarations.gms
