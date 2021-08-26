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
  s24_switch_trademodel                                                       "Switch to activate trade model eqns before trade solve and to deactivate them during main solve" /0/
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

  pm_Xport(ttot,all_regi,all_enty)                                            "Export of traded commodity."
  pm_Mport(ttot,all_regi,all_enty)                                            "Import of traded commodity."
  pm_Xport_effective(ttot,all_regi,all_enty)                                  "Export of traded commodity effective (computed from imports)."
  pm_XMport_pipeline(all_regi,all_regi,all_enty)                              "Export and imports of traded commodity via pipeline."
  
  p24_Xport_iter(iteration,tall,all_regi,all_enty)                            "Iterative values of vm_Xport for diagnostics."
  p24_Mport_iter(iteration,tall,all_regi,all_enty)                            "Iterative values of vm_Mport for diagnostics."
  p24_shipment_quan_iter(iteration,ttot,all_regi,all_regi,tradeModes)         "Iterative values of v24_shipment_quan for diagnostics."
  p24_cap_tradeTransp_iter(iteration,ttot,all_regi,all_regi,teTrade)          "Iterative values of v24_cap_tradeTransp for diagnostics."
;

***-------------------------------------------------------------------------------
***                                   VARIABLES
***-------------------------------------------------------------------------------
VARIABLES
  v24_objvar_opttransp                                                        "Objective variable for optimisation inside trade module"
;

POSITIVE VARIABLES
  vm_tradeBudget_Xporter(ttot,all_regi)                                       "Export budget of regions"
  vm_tradeBudget_Mporter(ttot,all_regi)                                       "Import budget of regions"
  
  vm_Xport(tall,all_regi,all_enty)                                            "Export of traded commodity."
  vm_Mport(tall,all_regi,all_enty)                                            "Import of traded commodity."
  
  v24_shipment_quan(ttot,all_regi,all_regi,tradeModes)                        "Shipment quantities for different transportation modes"
  
  v24_cap_tradeTransp(ttot,all_regi,all_regi,teTrade)                         "Net total capacities for transportation"
  v24_capEarlyReti(ttot,all_regi,all_regi,teTrade)                            "Early retired capacity"
  
  v24_deltaCap_tradeTransp(ttot,all_regi,all_regi,teTrade)                    "Capacity additions for transportation"
  
  v24_tradeTransp_cost(ttot,all_regi,all_enty)                                "Cost incurring from trade transportation"
  v24_purchase_cost(ttot,all_regi,all_enty)                                   "Total income or expense generated from trade"
;

***-----------------------------------------------------------------------------
***                                   EQUATIONS
***-----------------------------------------------------------------------------
EQUATIONS
  q24_objfunc_opttransp                                                       "Objective function for optimisation inside trade module"
  
  q24_tradeBudget_Xporter(ttot,all_regi)                                      "Export budget of regions"
  q24_tradeBudget_Mporter(ttot,all_regi)                                      "Import budget of regions"
  
  q24_totMport_quan(ttot,all_regi,all_enty)                                   "Total imports of each region must equal the demanded imports"
  
  q24_cap_teTradeBilat(ttot,all_regi,all_regi,teTrade)                        "Trade is limited by capacity for pipelines."
  q24_cap_teTradeXport(ttot,all_regi,teTrade)                                 "Trade is limited by capacity for Xport terminals."
  q24_cap_teTradeMport(ttot,all_regi,teTrade)                                 "Trade is limited by capacity for Mport terminals."
  
  q24_deltaCap_tradeTransp(ttot,all_regi,all_regi,teTrade)                    "Trade transportation capacities from deltaCap."
  q24_deltaCap_limit(ttot,all_regi,all_regi,teTrade)                          "Limit deltaCap."
  q24_prohibit_MportXport(ttot,all_regi,tradeCap)                             "Prohibit importers to be exessive exporters."

  q24_tradeTransp_cost(ttot,all_regi,all_enty)                                "Cost incurring from trade transportation"
  q24_purchase_cost(ttot,all_regi,all_enty)                                   "Total income or expense generated from trade"
;

*** EOF ./modules/24_trade/capacity/declarations.gms
