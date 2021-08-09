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
*** define sets and parameters for trade exports and imports
**********************************************************************
SETS
    teTradeTransp(all_te)                                                       'Technologies for transportation in trade'          
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
