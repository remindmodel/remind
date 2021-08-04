*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/24_trade/network_trade/sets.gms

sets
trade(all_enty)             "All traded commodities"
/
/

tradeMacro(all_enty)        "Traded macro-economic commodities"
/
    good, 
    perm
/

tradePe(all_enty)           "Traded primary energy commodities"
/
    peoil, 
    pecoal,
    peur, 
    pebiolc
/

tradeSe(all_enty)           "Traded secondary energy commodities"
/
***    seel,
***    seh2,
    pegas
/
;



**********************************************************************
*** Definition of the main characteristics set 'char':
**********************************************************************
SET char_trade    "Characteristics of transport technologies"
/  
  tech_stat       "Technology status: how close a technology is to market readiness. Scale: 0-3, with 0 'I can go out and build a GW plant today' to 3 'Still some research necessary'."
  inco0           "Initial investment costs given in $(2015)/kW(output) capacity. Independent of distance."
  inco0_d         "Initial investment costs given in $(2015)/kW(output) capacity. Per 1000km."
  constrTme       "Construction time in years, needed to calculate turn-key cost premium compared to overnight costs"
  eta             "Conversion efficieny, i.e. the amount of energy NOT lost in transportation. Independent of distance (e.g. conversion processes etc)."
  eta_d           "Conversion efficieny, i.e. the amount of energy NOT lost in transportation. Per 1000km."
  omf             "Fixed operation and maintenance costs given as a fraction of investment costs inco0. Independent of distance."
  omf_d           "Fixed operation and maintenance costs given as a fraction of investment costs inco0_d. Per 1000km."
  omv             "Variable operation and maintenance costs given in $(2015)/kWa energy production. Independent of distance."
  omv_d           "Variable operation and maintenance costs given in $(2015)/kWa energy production. Per 1000km."
  lifetime        "Given in years"
/
;



**********************************************************************
*** define sets and parameters for trade exports and imports
**********************************************************************
SETS
    teTradeTransp                                                               'Technologies for transportation in trade'          
        /
        pipeline
        shipping
        shipping_Mport
        shipping_Xport
        shipping_vessels
        /
    teTradeTranspModes(teTradeTransp)                                           'Primary transportation modes'          
        /
        pipeline
        shipping
        /
;



*** EOF ./modules/24_trade/network_trade/sets.gms
