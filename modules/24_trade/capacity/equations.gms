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
q24_totMport_quan(ttot,regi,tradeCap)$( (s24_switch_trademodel eq 1) AND (pm_ttot_val(ttot) ge cm_startyear) )..
    sum(  (regi2,tradeEnty2Mode(tradeCap,tradeModes))$(not sameAs(regi,regi2)), v24_shipment_quan(ttot,regi2,regi,tradeModes)  )
  =e=
    pm_Mport(ttot,regi,tradeCap);

*** shipments constrained by capacity
q24_cap_teTradeBilat(ttot,regi,regi2,teTradeBilat)$( (s24_switch_trademodel eq 1) AND (pm_ttot_val(ttot) ge cm_startyear)  AND (not sameAs(regi,regi2)) )..
    sum( tradeMode2te(tradeModes, teTradeBilat) , v24_shipment_quan(ttot,regi,regi2,tradeModes) )
  =l=
    v24_cap_tradeTransp(ttot,regi,regi2,teTradeBilat)
;
q24_cap_teTradeXport(ttot,regi,teTradeXportonly)$( (s24_switch_trademodel eq 1) AND (pm_ttot_val(ttot) ge cm_startyear) )..
    sum( tradeMode2te(tradeModes, teTradeXportonly) , sum(regi2$(not sameAs(regi,regi2)),v24_shipment_quan(ttot,regi,regi2,tradeModes)) )
  =l=
    v24_cap_tradeTransp(ttot,regi,regi,teTradeXportonly)
;
q24_cap_teTradeMport(ttot,regi,teTradeMportonly)$( (s24_switch_trademodel eq 1) AND (pm_ttot_val(ttot) ge cm_startyear) )..
    sum( tradeMode2te(tradeModes, teTradeMportonly) , sum(regi2$(not sameAs(regi,regi2)),v24_shipment_quan(ttot,regi2,regi,tradeModes)) )
  =l=
    v24_cap_tradeTransp(ttot,regi,regi,teTradeMportonly)
;

*** capacity can be built over years, but also depreciates
q24_deltaCap_tradeTransp(ttot,regi,regi2,teTrade)$( (s24_switch_trademodel eq 1) AND (pm_ttot_val(ttot) ge cm_startyear) )..
    v24_cap_tradeTransp(ttot,regi,regi2,teTrade)
  =e=
***    (1 - v24_capEarlyReti(ttot,regi,regi2,tradeCap,teTradeTransp))
***    *
    (
      sum(opTimeYr2te(teTrade,opTimeYr)$(tsu2opTimeYr(ttot,opTimeYr) AND (opTimeYr.val gt 1) ),
        pm_ts(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1))
      * pm_omeg(regi2,opTimeYr+1,teTrade)
      * v24_deltaCap_tradeTransp(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1),regi,regi2,teTrade)
      )
    + ( pm_dt(ttot) / 2
      * pm_omeg(regi2,"2",teTrade)
      * v24_deltaCap_tradeTransp(ttot,regi,regi2,teTrade)
      )
    )
;

*** delta cap constrained to small increase
q24_deltaCap_limit(ttot,regi,regi2,teTrade)$( (s24_switch_trademodel eq 1) AND (pm_ttot_val(ttot) gt cm_startyear) )..
    v24_deltaCap_tradeTransp(ttot,regi,regi2,teTrade)
  =l=
    v24_cap_tradeTransp(ttot-1,regi,regi2,teTrade)
  * (pm_ttot_val(ttot) - pm_ttot_val(ttot-1))
  * p24_cap_relMaxGrowthRate(teTrade)
  + p24_cap_absMaxGrowthRate(teTrade)
  * (pm_ttot_val(ttot) - pm_ttot_val(ttot-1))
;

*** shipments constrained: importers cant be exporters
q24_prohibit_MportXport(ttot,regi,tradeCap)$( (s24_switch_trademodel eq 1) AND (pm_Mport(ttot,regi,tradeCap)) )..
    sum(  (regi2,tradeEnty2Mode(tradeCap, tradeModes))  , v24_shipment_quan(ttot,regi,regi2,tradeModes))
  =l=
    pm_Xport_effective(ttot,regi,tradeCap)
;

*** cost from purchasing/buying
q24_purchase_cost(ttot,regi,tradeCap)$(s24_switch_trademodel eq 1)..
    v24_purchase_cost(ttot,regi,tradeCap) =e= sum(  (regi2,tradeEnty2Mode(tradeCap,tradeModes)), v24_shipment_quan(ttot,regi2,regi,tradeModes) * pm_XPortsPrice(ttot,regi2,tradeCap)  )
;

*** cost from transportation capacities
*** cost for a tradeCap enty for importer regi = sum over all modes carrying that enty, 
*** sum over all technologies involved in those trade modes, sum over regi2 (exporter), 
*** sum over inco0,omf,omv, and sum over per distance or not
q24_tradeTransp_cost(ttot,regi,tradeCap)$(s24_switch_trademodel eq 1)..
    v24_tradeTransp_cost(ttot,regi,tradeCap)
  =e=
    sum( tradeEnty2Mode(tradeCap, tradeModes),
      sum( tradeMode2te(tradeModes, teTradeBilat),
        sum( regi2,
          v24_deltaCap_tradeTransp(ttot,regi2,regi,teTradeBilat)      * (pm_data(regi,'inco0',teTradeBilat)      + pm_data(regi,'inco0_d',teTradeBilat)     * p24_distance(regi,regi2))
        + v24_cap_tradeTransp(ttot,regi2,regi,teTradeBilat)           * (pm_data(regi,'omf'  ,teTradeBilat)      + pm_data(regi,'omf_d'  ,teTradeBilat)     * p24_distance(regi,regi2))
        + v24_shipment_quan(ttot,regi2,regi,tradeModes)               * (pm_data(regi,'omv'  ,teTradeBilat)      + pm_data(regi,'omv_d'  ,teTradeBilat)     * p24_distance(regi,regi2))
        )
      )
    + sum( tradeMode2te(tradeModes, teTradeXportonly),
        v24_deltaCap_tradeTransp(ttot,regi,regi,teTradeXportonly)     *  pm_data(regi,'inco0',teTradeXportonly)
      + v24_cap_tradeTransp(ttot,regi,regi,teTradeXportonly)          *  pm_data(regi,'omf'  ,teTradeXportonly)
      + sum(regi2,v24_shipment_quan(ttot,regi2,regi,tradeModes))      *  pm_data(regi,'omv'  ,teTradeXportonly)
      )
    + sum( tradeMode2te(tradeModes, teTradeMportonly),
        v24_deltaCap_tradeTransp(ttot,regi,regi,teTradeMportonly)     *  pm_data(regi,'inco0',teTradeMportonly)
      + v24_cap_tradeTransp(ttot,regi,regi,teTradeMportonly)          *  pm_data(regi,'omf'  ,teTradeMportonly)
      + sum(regi2,v24_shipment_quan(ttot,regi,regi2,tradeModes))      *  pm_data(regi,'omv'  ,teTradeMportonly)
      )
    )
;

*** total budget from purchasing cost plus transportation cost
q24_tradeBudget_Mporter(ttot,regi)$(s24_switch_trademodel eq 1)..
    vm_tradeBudget_Mporter(ttot,regi)
  =e=
    sum(tradeCap, v24_tradeTransp_cost(ttot,regi,tradeCap))
  + sum(tradeCap, v24_purchase_cost(ttot,regi,tradeCap))
;

*** objective function for trade model
q24_objfunc_opttransp$(s24_switch_trademodel eq 1)..
    v24_objvar_opttransp
  =e= 
    sum(  (ttot,regi), vm_tradeBudget_Mporter(ttot,regi)  )
;

*** total budget from purchasing cost plus transportation cost
q24_tradeBudget_Xporter(ttot,regi)$(s24_switch_trademodel eq 1)..
    vm_tradeBudget_Mporter(ttot,regi)
  =e=
    sum(tradeCap, v24_tradeTransp_cost(ttot,regi,tradeCap))
  + sum(tradeCap, v24_purchase_cost(ttot,regi,tradeCap))
;

*** EOF ./modules/24_trade/capacity/equations.gms
