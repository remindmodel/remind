*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/24_trade/network_trade/presolve.gms

$ifthen.toy_model_off not "%trade_toy_model%" == "ON"
pm_Xport0(ttot,regi,tradePe) = vm_Xport.l(ttot,regi,tradePe);

*** Secondary energy trade

*** Temporarily forcing Mports (until all bugs are fixed with automatic trading)
vm_Mport.fx(t,regi,entySe)$(sum(regi2,p24_seTradeCapacity(t,regi2,regi,entySe)) gt 0) = sum(regi2,p24_seTradeCapacity(t,regi2,regi,entySe));
vm_Mport.l(t,regi,entySe)$(sum(regi2,p24_seTradeCapacity(t,regi2,regi,entySe)) gt 0) = sum(regi2,p24_seTradeCapacity(t,regi2,regi,entySe));

*** Xport price
pm_XPortsPrice(t,regi,tradeSe) = pm_SEPrice(t,regi,tradeSe);

*** Setting Xport price bound to avoid unrealists trading prices.
*** Lower bound: avoiding epsilon values (caused by using equation marginals for setting prices) or unrealistic small value for H2 exporting prices -> minimun price = 1$/kg (1$/kg = 0.030769231 $/Kwh = 0.030769231 / (10^12/10^9*8760) T$/TWa = 0.26953846356 T$/TWa) 
pm_XPortsPrice(t,regi,"seh2") = min(0.26953846356,pm_XPortsPrice(t,regi,"seh2"));

*** Mports from where? Mports from regi to regi2, assuming that trade is distributed uniformetly according existent trade capacities
p24_MportsRegi(t,regi,regi2,tradeSe)$(p24_seTradeCapacity(t,regi2,regi,tradeSe)) =
  vm_Mport.l(t,regi,tradeSe)*
 (p24_seTradeCapacity(t,regi2,regi,tradeSe)/sum(regi3,p24_seTradeCapacity(t,regi3,regi,tradeSe)))
;

*** Xports quantitites as a result of Mports
p24_XportsRegi(t,regi,regi2,tradeSe) = p24_MportsRegi(t,regi2,regi,tradeSe);

*** Mport price. Calculates the secondary energy price seen by the importing country as a weighted average of prices observed in countries with capacity to export (regi2) to the country (regi) and their existent capacity connections with the importing country
pm_MPortsPrice(t,regi,tradeSe)$(sum(regi2,p24_XportsRegi(t,regi2,regi,tradeSe)) gt 0) =
  sum(regi2$p24_seTradeCapacity(t,regi2,regi,tradeSe),
    pm_XPortsPrice(t,regi2,tradeSe)
    *(
      p24_XportsRegi(t,regi2,regi,tradeSe)
      /
      sum(regi3$p24_seTradeCapacity(t,regi3,regi,tradeSe), p24_XportsRegi(t,regi3,regi,tradeSe))
    )
  )
;

*** Fixing exports for current iteration based on previous iteration trade results
vm_Xport.fx(t,regi,tradeSe) = sum(regi2, p24_XportsRegi(t,regi,regi2,tradeSe));

display  p24_seTradeCapacity, p24_MportsRegi, p24_XportsRegi, pm_MPortsPrice, pm_XPortsPrice, pm_SEPrice;
$endif.toy_model_off



***-------------------------------------------------------------------------------
***                        PREPARING THE TRADE MODEL
***-------------------------------------------------------------------------------

*** get Mports and Xports from REMIND
pm_Xport(ttot,regi,tradeSe) = vm_Xport.l(ttot,regi,tradeSe);
pm_Mport(ttot,regi,tradeSe) = vm_Mport.l(ttot,regi,tradeSe);

pm_Xport_effective(ttot,regi,tradeSe)
 = pm_Xport(ttot,regi,tradeSe)
 + sum(regi2,pm_Mport(ttot,regi2,tradeSe) - pm_Xport(ttot,regi2,tradeSe))
 * pm_Xport(ttot,regi,tradeSe) / sum(regi2,pm_Xport(ttot,regi2,tradeSe))
;

pm_XMport_pipeline(regi,regi2,'pegas') = 0.0;
pm_XMport_pipeline('MEA','EUR','pegas') = 0.100;
pm_XMport_pipeline('REF','EUR','pegas') = 0.150;

*** prices
pm_exportPrice(ttot,regi,'pegas') = p_PEPrice(ttot,regi,'pegas');



***-------------------------------------------------------------------------------
***                        TRADE MODEL EQUATIONS
***-------------------------------------------------------------------------------

*** all shipments must add up to satisfy the demanded imports
q24_totMport_quan(ttot,regi,tradeSe)..
    sum(  (regi2,tradeEnty2Mode(tradeSe,tradeModes))$(not sameAs(regi,regi2)), v24_shipment_quan(ttot,regi2,regi,tradeModes)  )
  =e=
    pm_Mport(ttot,regi,tradeSe);

*** shipments constrained by capacity
q24_cap_teTradeBilat(ttot,regi,regi2,teTradeBilat)$(not sameAs(regi,regi2))..
    sum( tradeMode2te(tradeModes, teTradeBilat) , v24_shipment_quan(ttot,regi,regi2,tradeModes) )
  =l=
    v24_cap_tradeTransp(ttot,regi,regi2,teTradeBilat)
;
q24_cap_teTradeXport(ttot,regi,teTradeXportonly)..
    sum( tradeMode2te(tradeModes, teTradeXportonly) , sum(regi2$(not sameAs(regi,regi2)),v24_shipment_quan(ttot,regi,regi2,tradeModes)) )
  =l=
    v24_cap_tradeTransp(ttot,regi,regi,teTradeXportonly)
;
q24_cap_teTradeMport(ttot,regi,teTradeMportonly)..
    sum( tradeMode2te(tradeModes, teTradeMportonly) , sum(regi2$(not sameAs(regi,regi2)),v24_shipment_quan(ttot,regi2,regi,tradeModes)) )
  =l=
    v24_cap_tradeTransp(ttot,regi,regi,teTradeMportonly)
;

*** capacity can be built over years, but also depreciates
q24_deltaCap_tradeTransp(ttot,regi,regi2,teTrade)$(ttot.val ge cm_startyear)..
    v24_cap_tradeTransp(ttot,regi,regi2,teTrade)
  =e=
***    (1 - v24_capEarlyReti(ttot,regi,regi2,tradeSe,teTradeTransp))
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
q24_deltaCap_limit(ttot,regi,regi2,teTrade)$(pm_ttot_val(ttot) gt cm_startyear)..
    v24_deltaCap_tradeTransp(ttot,regi,regi2,teTrade)
  =l=
    v24_cap_tradeTransp(ttot-1,regi,regi2,teTrade)
  * (pm_ttot_val(ttot) - pm_ttot_val(ttot-1))
  * p24_cap_relMaxGrowthRate(teTrade)
  + p24_cap_absMaxGrowthRate(teTrade)
  * (pm_ttot_val(ttot) - pm_ttot_val(ttot-1))
;

*** shipments constrained: importers cant be exporters
q24_prohibit_MportXport(ttot,regi,tradeSe)$(pm_Mport(ttot,regi,tradeSe))..
    sum(  (regi2,tradeEnty2Mode(tradeSe, tradeModes))  , v24_shipment_quan(ttot,regi,regi2,tradeModes))
  =l=
    pm_Xport_effective(ttot,regi,tradeSe)
;

*** cost from purchasing/buying
q24_purchase_cost(ttot,regi,tradeSe)..
    v24_purchase_cost(ttot,regi,tradeSe) =e= sum(  (regi2,tradeEnty2Mode(tradeSe,tradeModes)), v24_shipment_quan(ttot,regi2,regi,tradeModes) * pm_exportPrice(ttot,regi2,tradeSe)  )
;

*** cost from transportation capacities
*** cost for a tradeSe enty for importer regi = sum over all modes carrying that enty, 
*** sum over all technologies involved in those trade modes, sum over regi2 (exporter), 
*** sum over inco0,omf,omv, and sum over per distance or not
q24_tradeTransp_cost(ttot,regi,tradeSe)..
    v24_tradeTransp_cost(ttot,regi,tradeSe)
  =e=
    sum( tradeEnty2Mode(tradeSe, tradeModes),
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
qm_budget(ttot,regi)..
    vm_budget(ttot,regi)
  =e=
    sum(tradeSe, v24_tradeTransp_cost(ttot,regi,tradeSe))
  + sum(tradeSe, v24_purchase_cost(ttot,regi,tradeSe))
;



***-------------------------------------------------------------------------------
***                               TRADE MODEL BOUNDS
***-------------------------------------------------------------------------------

*** positive variables
v24_shipment_quan.lo(ttot,all_regi,all_regi,tradeModes) = 0.0;
v24_cap_tradeTransp.lo(ttot,all_regi,all_regi,teTrade) = 0.0;
v24_deltaCap_tradeTransp.lo(ttot,all_regi,all_regi,teTrade) = 0.0;

*** shipments constrained: no self-imports or self-exports
v24_shipment_quan.fx(ttot,regi,regi2,tradeModes)$sameAs(regi,regi2) = 0.0;

*** trade capacity for terminals lives on the diagonal
v24_cap_tradeTransp.fx(ttot,regi,regi2,teTradeXportonly)$(not sameAs(regi,regi2)) = 0.0;
v24_cap_tradeTransp.fx(ttot,regi,regi2,teTradeMportonly)$(not sameAs(regi,regi2)) = 0.0;

*** fix initial capacities for pegas
v24_cap_tradeTransp.fx(ttot,regi,regi2,'gas_pipe')$(pm_ttot_val(ttot) eq cm_startyear) = pm_XMport_pipeline(regi,regi2,'pegas');
v24_cap_tradeTransp.fx(ttot,regi,regi,'lng_liq')$(pm_ttot_val(ttot) eq cm_startyear) = pm_Xport_effective(ttot,regi,'pegas')-sum(regi2,pm_XMport_pipeline(regi,regi2,'pegas'));
v24_cap_tradeTransp.fx(ttot,regi,regi,'lng_gas')$(pm_ttot_val(ttot) eq cm_startyear) = pm_Mport(ttot,regi,'pegas')-sum(regi2,pm_XMport_pipeline(regi2,regi,'pegas'));

*** shipments constrained: trade only allowed between defined regions
v24_shipment_quan.fx(ttot,regi,regi2,tradeModes)$(p24_disallowed(regi,regi2,tradeModes) gt 0.0) = 0.0;



***-------------------------------------------------------------------------------
***                        SOLVING THE TRADE MODEL
***-------------------------------------------------------------------------------

*** objective function for trade model
q24_objfunc_opttransp..
    v24_objvar_opttransp
  =e= 
    sum(  (ttot,regi), vm_budget(ttot,regi)  )
;

*** trade model
MODEL m24_tradeTransp
    /
        q24_totMport_quan
        
        q24_cap_teTradeBilat
        q24_cap_teTradeXport
        q24_cap_teTradeMport
        
        q24_deltaCap_tradeTransp
        q24_deltaCap_limit
        q24_prohibit_MportXport
        
        q24_purchase_cost
        q24_tradeTransp_cost
        qm_budget
        
        q24_objfunc_opttransp
    /
;

SOLVE m24_tradeTransp USING lp MINIMIZING v24_objvar_opttransp;



*** EOF ./modules/24_trade/network_trade/presolve.gms
