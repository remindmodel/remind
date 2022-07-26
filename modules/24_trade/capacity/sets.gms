*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
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
  pegas
/

***-------------------------------------------------------------------------------
***                               TRADE MODEL SETS
***-------------------------------------------------------------------------------
tradeModes                                  "Modes of trade, i.e. ways in which a commodity can be transported between regions."
/
  pegas_pipe                                "Trading of natural gas via pipeline."
  pegas_ship_lng                            "Trading of natural gas as LNG via shipping."
  pecoal_ship                               "Trading of coal as a solid via shipping."
  peoil_pipe                                "Trading of PE oil via pipeline."
  peoil_ship                                "Trading of PE oil via shipping."
  seh2_pipe                                 "Trading of hydrogen via pipeline."
  seh2_ship_lh2                             "Trading of hydrogen via shipping in liquified state."
  seh2_ship_lohc                            "Trading of hydrogen via shipping using an LOHC."
  seh2_ship_nh3                             "Trading of hydrogen via shipping by converting it to ammonia."
/

teTrade(all_te)                             "Technologies used for trading goods."
/
  pipe_gas                                  "Pipelines transporting natural gas"
  termX_lng                                 "Export terminals for LNG (liquification)"
  termM_lng                                 "Import terminals for LNG (regasification)"
  vess_lng                                  "Vessels transporting LNG"

***  vess_coal                                 "Vessels transporting coal"

***  pipe_oil                                  "Pipelines transporting oil"
***  vess_oil                                  "Vessels transporting oil"

***  pipe_h2                                   "Pipelines transporting hydrogen"
***  termX_lh2                                 "Export terminals for liquid hydrogen (liquification)"
***  termM_lh2                                 "Import terminals for liquid hydrogen (regasification)"
***  vess_lh2                                  "Vessels transporting liquid hydrogen"
***  termX_lohc                                "Export terminals for liquid hydrogen (liquification)"
***  termM_lohc                                "Import terminals for liquid hydrogen (regasification)"
***  vess_lohc                                 "Vessels transporting liquid hydrogen"
***  termX_nh3                                 "Export terminals for liquid hydrogen (liquification)"
***  termM_nh3                                 "Import terminals for liquid hydrogen (regasification)"
***  vess_nh3                                  "Vessels transporting liquid hydrogen"
/

teTradeBilat(teTrade)                       "Technologies used for trading that are installed bilaterally, i.e. in between two regions (e.g. pipelines)."
/
  pipe_gas
  vess_lng
  
***  vess_coal

***  pipe_oil
***  vess_oil

***  pipe_h2
***  vess_lh2
***  termX_lohc
***  termM_lohc
***  vess_lohc
***  vess_nh3
/

teTradeXport(teTrade)                       "Technologies used for trading that are installed in the exporting region only (e.g. liquification terminals)."
/
  termX_lng
***  termX_lh2
***  termX_nh3
/

teTradeMport(teTrade)                       "Technologies used for trading that are installed in the importing region only (e.g. regasification terminals)."
/
  termM_lng
***  termM_lh2
***  termM_nh3
/

tradeEnty2Mode(all_enty, tradeModes)        "Mapping of traded commodities onto the possible trade modes."
/
  pegas.(pegas_pipe,pegas_ship_lng)
***  pecoal.pecoal_ship
***  peoil.(peoil_pipe,peoil_ship)
***  seh2.(seh2_pipe,seh2_ship_lh2,seh2_ship_lohc,seh2_ship_nh3)
/

tradeMode2te(tradeModes, teTrade)           "Mapping of trade modes onto the required technologies."
/
  pegas_pipe.pipe_gas
  pegas_ship_lng.(termX_lng,termM_lng,vess_lng)
  
***  pecoal_ship.vess_coal
  
***  peoil_pipe.pipe_oil
***  peoil_ship.vess_oil
  
***  seh2_pipe.pipe_h2
***  seh2_ship_lh2.(termX_lh2,termM_lh2,vess_lh2)
***  seh2_ship_lohc.(termX_lohc,termM_lohc,vess_lohc)
***  seh2_ship_nh3.(termX_nh3,termM_nh3,vess_nh3)
/
;

*** EOF ./modules/24_trade/capacity/sets.gms
