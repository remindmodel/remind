*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/24_trade/capacity/equations.gms

***-------------------------------------------------------------------------------
***             TRADE MODEL EQUATIONS -- IMPORT AND EXPORT CONDITIONS
***-------------------------------------------------------------------------------

*** all shipments must add up to satisfy the demanded imports
q24_tradeFromMports(t,regi,tradeCap)..
    sum(  (trade_regi,tradeEnty2Mode(tradeCap,tradeModes))$(not sameAs(trade_regi,regi)), v24_trade(t,trade_regi,regi,tradeModes)  )
  =e=
    vm_Mport(t,regi,tradeCap);

*** shipments constrained: importers cant be exporters
*q24_prohibitMX(t,regi,tradeCap)$( (s24_switchTradeModel eq 1) AND (p24_Mport(t,regi,tradeCap)) )..
*    sum(  (trade_regi,tradeEnty2Mode(tradeCap, tradeModes))  , v24_trade(t,regi,trade_regi,tradeModes))
*  =l=
*    p24_XportEff(t,regi,tradeCap)
*;

***-------------------------------------------------------------------------------
***                   TRADE MODEL EQUATIONS -- CAPACITIES
***-------------------------------------------------------------------------------

*** shipments constrained by capacity
q24_limitCapTradeBilat(t,trade_regi,regi,teTradeBilat)$( (not sameAs(trade_regi,regi)) )..
    sum( tradeMode2te(tradeModes, teTradeBilat) , v24_trade(t,trade_regi,regi,tradeModes) )
  =l=
    v24_capTrade(t,trade_regi,regi,teTradeBilat)
;
q24_limitCapTradeXport(t,regi,teTradeXport)..
    sum( tradeMode2te(tradeModes, teTradeXport) , sum(trade_regi$(not sameAs(trade_regi,regi)), v24_trade(t,regi,trade_regi,tradeModes)) )
  =l=
    v24_capTrade(t,regi,regi,teTradeXport)
;
q24_limitCapTradeMport(t,regi,teTradeMport)..
    sum( tradeMode2te(tradeModes, teTradeMport) , sum(trade_regi$(not sameAs(trade_regi,regi)), v24_trade(t,trade_regi,regi,tradeModes)) )
  =l=
    v24_capTrade(t,regi,regi,teTradeMport)
;

*** capacity can be built over years, but also depreciates
q24_capTrade(ttot,trade_regi,regi,teTrade)$( 
      (ttot.val ge cm_startyear)
  and ((teTradeBilat(teTrade) and not sameAs(regi,trade_regi))
  or   (teTradeMport(teTrade) and sameAs(regi,trade_regi))
  or   (teTradeXport(teTrade) and sameAs(regi,trade_regi)))
)..
    v24_capTrade(ttot,trade_regi,regi,teTrade)
  =e=
***    (1 - v24_capEarlyRetiTrade(ttot,trade_regi,regi,tradeCap,teTradeTransp))
***    *
    (
      sum(opTimeYr2te(teTrade,opTimeYr)$(tsu2opTimeYr(ttot,opTimeYr) AND (opTimeYr.val ge 1) ),
        pm_ts(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1))
      * pm_omeg(regi,opTimeYr+1,teTrade)
      * v24_deltaCapTrade(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1),trade_regi,regi,teTrade)
      )
    )
;

*** delta cap constrained to small increase
q24_limitDeltaCap(ttot,trade_regi,regi,teTrade)$( 
      (ttot.val ge cm_startyear)
  and ((teTradeBilat(teTrade) and not sameAs(regi,trade_regi))
  or   (teTradeMport(teTrade) and sameAs(regi,trade_regi))
  or   (teTradeXport(teTrade) and sameAs(regi,trade_regi)))
)..
v24_deltaCapTrade(ttot,trade_regi,regi,teTrade)
  =l=
    v24_capTrade(ttot-1,trade_regi,regi,teTrade)
  * (pm_ttot_val(ttot) - pm_ttot_val(ttot-1))
  * p24_cap_relMaxGrowthRate(teTrade)
  + p24_cap_absMaxGrowthRate(teTrade)
  * (pm_ttot_val(ttot) - pm_ttot_val(ttot-1))
;

***-------------------------------------------------------------------------------
***             TRADE MODEL EQUATIONS -- COST AND BUDGET TERMS
***-------------------------------------------------------------------------------

*** cost from transportation capacities
*** cost for a tradeCap enty for importer regi = sum over all modes carrying that enty, 
*** sum over all technologies involved in those trade modes, sum over regi2 (exporter), 
*** sum over inco0,omf,omv, and sum over per distance or not
q24_costTradeCap(t,regi,tradeCap)..
    vm_costTradeCap(t,regi,tradeCap)
  =e=
    sum( tradeEnty2Mode(tradeCap, tradeModes),
      sum( tradeMode2te(tradeModes, teTradeBilat),
        sum( trade_regi,
          v24_deltaCapTrade(t,trade_regi,regi,teTradeBilat)      * (pm_data(regi,'inco0',  teTradeBilat)
                                                                  + pm_data(regi,'inco0_d',teTradeBilat)  * p24_distance(trade_regi,regi))
        + v24_capTrade(t,trade_regi,regi,teTradeBilat)           * (pm_data(regi,'omf'  ,  teTradeBilat)
                                                                  + pm_data(regi,'omf_d'  ,teTradeBilat)  * p24_distance(trade_regi,regi))
        + v24_trade(t,trade_regi,regi,tradeModes)                * (pm_data(regi,'omv'  ,  teTradeBilat)
                                                                  + pm_data(regi,'omv_d'  ,teTradeBilat)  * p24_distance(trade_regi,regi))
        )
      )
    + sum( tradeMode2te(tradeModes, teTradeMport),
        v24_deltaCapTrade(t,regi,regi,teTradeMport)              *  pm_data(regi,'inco0',teTradeMport)
      + v24_capTrade(t,regi,regi,teTradeMport)                   *  pm_data(regi,'omf'  ,teTradeMport)
      + sum(trade_regi,v24_trade(t,trade_regi,regi,tradeModes))  *  pm_data(regi,'omv'  ,teTradeMport)
      )
    + sum( tradeMode2te(tradeModes, teTradeXport),
        v24_deltaCapTrade(t,regi,regi,teTradeXport)              *  pm_data(regi,'inco0',teTradeXport)
      + v24_capTrade(t,regi,regi,teTradeXport)                   *  pm_data(regi,'omf'  ,teTradeXport)
      + sum(trade_regi,v24_trade(t,trade_regi,regi,tradeModes))  *  pm_data(regi,'omv'  ,teTradeXport)
    )
  )
;


q24_tradeBalanceTerms(ttot,regi)$(ttot.val ge 2005)..
    vm_capacityTradeBalance(ttot,regi)
  =e=
    sum(tradeCap, 
        + sum(trade_regi, sum(  tradeEnty2Mode(tradeCap,tradeModes), v24_trade(ttot,regi,trade_regi,tradeModes)  ) * pm_XPortsPrice(ttot,regi,tradeCap) )
        - sum(trade_regi, sum(  tradeEnty2Mode(tradeCap,tradeModes), v24_trade(ttot,trade_regi,regi,tradeModes)  ) * pm_XPortsPrice(ttot,trade_regi,tradeCap) )
    )
;

*** EOF ./modules/24_trade/capacity/equations.gms
