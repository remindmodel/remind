*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/24_trade/network_trade/declarations.gms

***-------------------------------------------------------------------------------
***                                   SCALARS
***-------------------------------------------------------------------------------
scalars
s24_switch_trademodel    "Switch to activate trade model eqns before main solve and to deactivate them during main solve" /0/
;

***-----------------------------------------------------------------------------
***                                   PARAMETERS
***-----------------------------------------------------------------------------
PARAMETERS
pm_tradecostgood(all_regi)                  "Trade costs (final good)."
pm_Xport0(tall,all_regi,all_enty)           "Reference level value of export." 
pm_IO_trade(tall,all_regi,all_enty,char)    "Energy trade bounds based on IEA data."
p24_Mport2005correct(all_regi,all_enty)     "Correction factor to match fossil supply and internal region energy demand in the initial year"

p24_seTradeCapacity(tall,all_regi,all_regi,all_enty) "Secondary energy international yearly trade capacity potential from regi to regi2 [TWa]"

p24_MportsRegi(tall,all_regi,all_regi,tradeSe)      "Mports to regi from regi2, assuming that trade is distributed uniformetly according existent capacities defined at p24_seTradeCapacity [TWa]"
p24_XportsRegi(tall,all_regi,all_regi,tradeSe)      "Exports from regi to regi2. Defined in the postsolve as a result of p24_MportsRegi calculation [TWa]"
pm_MPortsPrice(tall,all_regi,tradeSe)              "Secondary energy import price for region. Calculated in the postsolve and assuming that trade is distributed uniformetly according existent capacities defined at p24_seTradeCapacity [T$/TWa]"
pm_XPortsPrice(tall,all_regi,tradeSe)              "Secondary energy export price for region. Calculated in the postsolve and corresponding to the region secondary energy price [T$/TWa]"
;

PARAMETERS
    pm_Xport(ttot,all_regi,all_enty)                                            'Export of traded commodity.'
    pm_Mport(ttot,all_regi,all_enty)                                            'Import of traded commodity.'
    pm_Xport_effective(ttot,all_regi,all_enty)                                  'Export of traded commodity effective (computed from imports).'
    pm_XMport_pipeline(all_regi,all_regi,all_enty)                              'Export and imports of traded commodity via pipeline.'
;

***-----------------------------------------------------------------------------
***                                   VARIABLES
***-----------------------------------------------------------------------------
POSITIVE VARIABLES
vm_Xport(tall,all_regi,all_enty)            "Export of traded commodity."
vm_Mport(tall,all_regi,all_enty)            "Import of traded commodity."
;

POSITIVE VARIABLES
  v24_shipment_quan(ttot,all_regi,all_regi,tradeModes)                          'Shipment quantities for different transportation modes'
  v24_cap_tradeTransp(ttot,all_regi,all_regi,teTrade)                           'Net total capacities for transportation'
  v24_deltaCap_tradeTransp(ttot,all_regi,all_regi,teTrade)                      'Capacity additions for transportation'
  v24_capEarlyReti(ttot,all_regi,all_regi,teTrade)                              'Early retired capacity'
  v24_tradeTransp_cost(ttot,all_regi,all_enty)                                  'Cost incurring from trade transportation'
  v24_purchase_cost(ttot,all_regi,all_enty)                                     'Total income or expense generated from trade'
  vm_tradeBudget_Xporter(ttot,all_regi)                                         'Export budget of regions'
  vm_tradeBudget_Mporter(ttot,all_regi)                                         'Import budget of regions'
;

VARIABLE  v24_objvar_opttransp                                                  'Objective variable for optimisation inside trade module';

***-----------------------------------------------------------------------------
***                                   EQUATIONS
***-----------------------------------------------------------------------------
EQUATIONS
  q24_totMport_quan(ttot,all_regi,all_enty)                                     'Total imports of each region must equal the demanded imports'
  
  q24_cap_teTradeBilat(ttot,all_regi,all_regi,teTrade)                          'Trade is limited by capacity for pipelines.'
  q24_cap_teTradeXport(ttot,all_regi,teTrade)                                   'Trade is limited by capacity for Xport terminals.'
  q24_cap_teTradeMport(ttot,all_regi,teTrade)                                   'Trade is limited by capacity for Mport terminals.'
  
  q24_deltaCap_tradeTransp(ttot,all_regi,all_regi,teTrade)                      'Trade transportation capacities from deltaCap.'
  q24_deltaCap_limit(ttot,all_regi,all_regi,teTrade)                            'Limit deltaCap.'
  q24_prohibit_MportXport(ttot,all_regi,tradeSe)                                'Prohibit importers to be exessive exporters.'

  q24_purchase_cost(ttot,all_regi,all_enty)                                     'Total income or expense generated from trade'
  q24_tradeTransp_cost(ttot,all_regi,all_enty)                                  'Cost incurring from trade transportation'
  q24_tradeBudget_Xporter(ttot,all_regi)                                        'Export budget of regions'
  q24_tradeBudget_Mporter(ttot,all_regi)                                        'Import budget of regions'
;

EQUATION  q24_objfunc_opttransp                                                 'Objective function for optimisation inside trade module';

*** EOF ./modules/24_trade/network_trade/declarations.gms
