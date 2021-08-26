*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/24_trade/capacity/equations.gms

***-------------------------------------------------------------------------------
***                        TRADE MODEL EQUATIONS
***-------------------------------------------------------------------------------

*** all shipments must add up to satisfy the demanded imports
q24_tradeFromMports(ttot,regi,tradeCap)$( (s24_switchTradeModel eq 1) AND (pm_ttot_val(ttot) ge cm_startyear) )..
    sum(  (regi2,tradeEnty2Mode(tradeCap,tradeModes))$(not sameAs(regi,regi2)), v24_trade(ttot,regi2,regi,tradeModes)  )
  =e=
    p24_Mport(ttot,regi,tradeCap);

*** shipments constrained by capacity
q24_limitCapTradeBilat(ttot,regi,regi2,teTradeBilat)$( (s24_switchTradeModel eq 1) AND (pm_ttot_val(ttot) ge cm_startyear)  AND (not sameAs(regi,regi2)) )..
    sum( tradeMode2te(tradeModes, teTradeBilat) , v24_trade(ttot,regi,regi2,tradeModes) )
  =l=
    v24_capTrade(ttot,regi,regi2,teTradeBilat)
;
q24_limitCapTradeXport(ttot,regi,teTradeXport)$( (s24_switchTradeModel eq 1) AND (pm_ttot_val(ttot) ge cm_startyear) )..
    sum( tradeMode2te(tradeModes, teTradeXport) , sum(regi2$(not sameAs(regi,regi2)),v24_trade(ttot,regi,regi2,tradeModes)) )
  =l=
    v24_capTrade(ttot,regi,regi,teTradeXport)
;
q24_limitCapTradeMport(ttot,regi,teTradeMport)$( (s24_switchTradeModel eq 1) AND (pm_ttot_val(ttot) ge cm_startyear) )..
    sum( tradeMode2te(tradeModes, teTradeMport) , sum(regi2$(not sameAs(regi,regi2)),v24_trade(ttot,regi2,regi,tradeModes)) )
  =l=
    v24_capTrade(ttot,regi,regi,teTradeMport)
;

*** capacity can be built over years, but also depreciates
q24_capTrade(ttot,regi,regi2,teTrade)$( (s24_switchTradeModel eq 1) AND (pm_ttot_val(ttot) ge cm_startyear) )..
    v24_capTrade(ttot,regi,regi2,teTrade)
  =e=
***    (1 - v24_capEarlyRetiTrade(ttot,regi,regi2,tradeCap,teTradeTransp))
***    *
    (
      sum(opTimeYr2te(teTrade,opTimeYr)$(tsu2opTimeYr(ttot,opTimeYr) AND (opTimeYr.val gt 1) ),
        pm_ts(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1))
      * pm_omeg(regi2,opTimeYr+1,teTrade)
      * v24_deltaCapTrade(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1),regi,regi2,teTrade)
      )
    + ( pm_dt(ttot) / 2
      * pm_omeg(regi2,"2",teTrade)
      * v24_deltaCapTrade(ttot,regi,regi2,teTrade)
      )
    )
;

*** delta cap constrained to small increase
q24_limitDeltaCap(ttot,regi,regi2,teTrade)$( (s24_switchTradeModel eq 1) AND (pm_ttot_val(ttot) gt cm_startyear) )..
    v24_deltaCapTrade(ttot,regi,regi2,teTrade)
  =l=
    v24_capTrade(ttot-1,regi,regi2,teTrade)
  * (pm_ttot_val(ttot) - pm_ttot_val(ttot-1))
  * p24_cap_relMaxGrowthRate(teTrade)
  + p24_cap_absMaxGrowthRate(teTrade)
  * (pm_ttot_val(ttot) - pm_ttot_val(ttot-1))
;

*** shipments constrained: importers cant be exporters
q24_prohibitMX(ttot,regi,tradeCap)$( (s24_switchTradeModel eq 1) AND (p24_Mport(ttot,regi,tradeCap)) )..
    sum(  (regi2,tradeEnty2Mode(tradeCap, tradeModes))  , v24_trade(ttot,regi,regi2,tradeModes))
  =l=
    p24_XportEff(ttot,regi,tradeCap)
;

*** cost from purchasing/buying
q24_costTradePrice(ttot,regi,tradeCap)$(s24_switchTradeModel eq 1)..
    v24_costTradePrice(ttot,regi,tradeCap) =e= sum(  (regi2,tradeEnty2Mode(tradeCap,tradeModes)), v24_trade(ttot,regi2,regi,tradeModes) * pm_XPortsPrice(ttot,regi2,tradeCap)  )
;

*** cost from transportation capacities
*** cost for a tradeCap enty for importer regi = sum over all modes carrying that enty, 
*** sum over all technologies involved in those trade modes, sum over regi2 (exporter), 
*** sum over inco0,omf,omv, and sum over per distance or not
q24_costTradeCap(ttot,regi,tradeCap)$(s24_switchTradeModel eq 1)..
    v24_costTradeCap(ttot,regi,tradeCap)
  =e=
    sum( tradeEnty2Mode(tradeCap, tradeModes),
      sum( tradeMode2te(tradeModes, teTradeBilat),
        sum( regi2,
          v24_deltaCapTrade(ttot,regi2,regi,teTradeBilat)      * (pm_data(regi,'inco0',teTradeBilat)      + pm_data(regi,'inco0_d',teTradeBilat)     * p24_distance(regi,regi2))
        + v24_capTrade(ttot,regi2,regi,teTradeBilat)           * (pm_data(regi,'omf'  ,teTradeBilat)      + pm_data(regi,'omf_d'  ,teTradeBilat)     * p24_distance(regi,regi2))
        + v24_trade(ttot,regi2,regi,tradeModes)               * (pm_data(regi,'omv'  ,teTradeBilat)      + pm_data(regi,'omv_d'  ,teTradeBilat)     * p24_distance(regi,regi2))
        )
      )
    + sum( tradeMode2te(tradeModes, teTradeXport),
        v24_deltaCapTrade(ttot,regi,regi,teTradeXport)     *  pm_data(regi,'inco0',teTradeXport)
      + v24_capTrade(ttot,regi,regi,teTradeXport)          *  pm_data(regi,'omf'  ,teTradeXport)
      + sum(regi2,v24_trade(ttot,regi2,regi,tradeModes))      *  pm_data(regi,'omv'  ,teTradeXport)
      )
    + sum( tradeMode2te(tradeModes, teTradeMport),
        v24_deltaCapTrade(ttot,regi,regi,teTradeMport)     *  pm_data(regi,'inco0',teTradeMport)
      + v24_capTrade(ttot,regi,regi,teTradeMport)          *  pm_data(regi,'omf'  ,teTradeMport)
      + sum(regi2,v24_trade(ttot,regi,regi2,tradeModes))      *  pm_data(regi,'omv'  ,teTradeMport)
      )
    )
;

*** total budget from purchasing cost plus transportation cost
q24_budgetTradeM(ttot,regi)$(s24_switchTradeModel eq 1)..
    vm_budgetTradeM(ttot,regi)
  =e=
    sum(tradeCap, v24_costTradeCap(ttot,regi,tradeCap))
  + sum(tradeCap, v24_costTradePrice(ttot,regi,tradeCap))
;

*** objective function for trade model
v24_objFunc$(s24_switchTradeModel eq 1)..
    v24_tradeCostGlob
  =e= 
    sum(  (ttot,regi), vm_budgetTradeM(ttot,regi)  )
;

*** total budget from purchasing cost plus transportation cost
q24_budgetTradeX(ttot,regi)$(s24_switchTradeModel eq 1)..
    vm_budgetTradeM(ttot,regi)
  =e=
    sum(tradeCap, v24_costTradeCap(ttot,regi,tradeCap))
  + sum(tradeCap, v24_costTradePrice(ttot,regi,tradeCap))
;

*** EOF ./modules/24_trade/capacity/equations.gms
