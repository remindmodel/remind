*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/24_trade/capacity/sets.gms

***-------------------------------------------------------------------------------
***                               GENERAL TRADE SETS
***-------------------------------------------------------------------------------
SETS
trade(all_enty)                             "All traded commodities"
/
/

tradeMacro(all_enty)                        "Traded macro-economic commodities"
/
  good, 
  perm
/

tradePe(all_enty)                           "Traded primary energy commodities"
/
  peoil, 
  pecoal, 
  pegas, 
  peur, 
  pebiolc
/

tradeSe(all_enty)                           "Traded secondary energy commodities"
/
  null
/

tradeCap(all_enty)                          "Commodities traded via capacity mode."
/
  pecoal,
  pegas
/

***-------------------------------------------------------------------------------
***                               TRADE MODEL SETS
***-------------------------------------------------------------------------------
tradeModes                                  "Modes of trade, i.e. ways in which a commodity can be transported between regions."
/
  pegas_pipe                                "Trading of natural gas via pipeline."
  pegas_shiplng                             "Trading of natural gas as LNG via shipping."
  pecoal_ship                               "Trading of coal as a solid via shipping."
  peoil_pipe                                "Trading of PE oil via pipeline."
  peoil_ship                                "Trading of PE oil via shipping."
  seh2_shipliq                              "Trading of hydrogen via shipping in liquified state."
  seh2_shiplohc                             "Trading of hydrogen via shipping using an LOHC."
  seh2_ammonia                              "Trading of hydrogen via shipping by converting it to ammonia."
  seh2_pipe                                 "Trading of hydrogen via pipeline."
/

teTrade(all_te)                             "Technologies used for trading goods."
/
  gas_pipe
  lng_liq
  lng_gas
  lng_ves
  coal_ves
/

teTradeBilat(teTrade)                       "Technologies used for trading that are installed bilaterally, i.e. in between two regions (e.g. pipelines)."
/
  gas_pipe
  lng_ves
  coal_ves
/

teTradeXport(teTrade)                       "Technologies used for trading that are installed in the exporting region only (e.g. liquification terminals)."
/
  lng_liq
/

teTradeMport(teTrade)                       "Technologies used for trading that are installed in the importing region only (e.g. regasification terminals)."
/
  lng_gas
/

tradeEnty2Mode(all_enty, tradeModes)        "Mapping of traded commodities onto the possible trade modes."
/
  pegas.(pegas_pipe,pegas_shiplng)
  pecoal.pecoal_ship
  peoil.(peoil_pipe,peoil_ship)
  seh2.(seh2_shipliq,seh2_shiplohc,seh2_ammonia,seh2_pipe)
/

tradeMode2te(tradeModes, teTrade)           "Mapping of trade modes onto the required technologies."
/
  pegas_pipe.gas_pipe
  pegas_shiplng.(lng_liq,lng_gas,lng_ves)
  pecoal_ship.coal_ves
/
;

*** EOF ./modules/24_trade/capacity/sets.gms
