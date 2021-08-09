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

pm_XMport_pipeline(regi,regi2,tradeSe) = 0.0;
pm_XMport_pipeline('MEA','EUR','pegas') = 0.100;
pm_XMport_pipeline('REF','EUR','pegas') = 0.150;

*** prices
pm_exportPrice(ttot,regi,'pegas') = p_PEPrice(ttot,regi,'pegas');



***-------------------------------------------------------------------------------
***                        TRADE MODEL EQUATIONS
***-------------------------------------------------------------------------------

*** all shipments must add up to satisfy the demanded imports
q24_totMport_quan(ttot,regi,tradeSe)..
    pm_Mport(ttot,regi,tradeSe) =e= sum(  (regi2,teTradeTranspModes), v24_shipment_quan(ttot,regi2,regi,tradeSe,teTradeTranspModes)  );

*** shipments constrained by capacity
q24_cap_tradeTransp_pipeline(ttot,regi,regi2,tradeSe)..
    v24_shipment_quan(ttot,regi,regi2,tradeSe,'pipeline')
  =l=
    v24_cap_tradeTransp(ttot,regi,regi2,tradeSe,'pipeline')
;

q24_cap_tradeTransp_shipping_Mport(ttot,regi,tradeSe)..
    sum(regi2, v24_shipment_quan(ttot,regi2,regi,tradeSe,'shipping'))
  =l=
    v24_cap_tradeTransp(ttot,regi,regi,tradeSe,'shipping_Mport')
;

q24_cap_tradeTransp_shipping_Xport(ttot,regi,tradeSe)..
    sum(regi2, v24_shipment_quan(ttot,regi,regi2,tradeSe,'shipping'))
  =l=
    v24_cap_tradeTransp(ttot,regi,regi,tradeSe,'shipping_Xport')
;

$ontext
q24_deltaCap_tradeTransp(ttot,regi,regi2,tradeSe,teTradeTransp)$(pm_ttot_val(ttot) gt cm_startyear)..
    v24_deltaCap_tradeTransp(ttot,regi,regi2,tradeSe,teTradeTransp)
  =e=
    v24_cap_tradeTransp(ttot,regi,regi2,tradeSe,teTradeTransp)
  - v24_cap_tradeTransp(ttot-1,regi,regi2,tradeSe,teTradeTransp)
;
$offtext

q24_deltaCap_tradeTransp(ttot,regi,regi2,tradeSe,teTradeTransp)$(ttot.val ge cm_startyear)..
    v24_cap_tradeTransp(ttot,regi,regi2,tradeSe,teTradeTransp)
  =e=
***    (1 - v24_capEarlyReti(ttot,regi,regi2,tradeSe,teTradeTransp))
***    *
    (
      sum(opTimeYr2te(teTradeTransp,opTimeYr)$(tsu2opTimeYr(ttot,opTimeYr) AND (opTimeYr.val gt 1) ),
        pm_ts(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1))
      * pm_omeg(regi2,opTimeYr+1,teTradeTransp)
      * v24_deltaCap_tradeTransp(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1),regi,regi2,tradeSe,teTradeTransp)
      )
    + ( pm_dt(ttot) / 2
      * pm_omeg(regi2,"2",teTradeTransp)
      * v24_deltaCap_tradeTransp(ttot,regi,regi2,tradeSe,teTradeTransp)
      )
    )
;

*** delta cap constrained to small increase
q24_deltaCap_limit(ttot,regi,regi2,tradeSe,teTradeTransp)$(pm_ttot_val(ttot) gt cm_startyear)..
    v24_deltaCap_tradeTransp(ttot,regi,regi2,tradeSe,teTradeTransp)
  =l=
    v24_cap_tradeTransp(ttot-1,regi,regi2,tradeSe,teTradeTransp)
  * (pm_ttot_val(ttot) - pm_ttot_val(ttot-1))
  * p24_cap_relMaxGrowthRate(teTradeTransp)
  + p24_cap_absMaxGrowthRate(teTradeTransp)
  * (pm_ttot_val(ttot) - pm_ttot_val(ttot-1))
;

*** shipments constrained: importers cant be exporters
q24_prohibit_MportXport(ttot,regi,tradeSe)$(pm_Mport(ttot,regi,tradeSe))..
    sum((regi2,teTradeTranspModes), v24_shipment_quan(ttot,regi,regi2,tradeSe,teTradeTranspModes))
  =l=
    pm_Xport_effective(ttot,regi,tradeSe)
;

*** cost from purchasing/buying
q24_purchase_cost(ttot,regi,tradeSe)..
    v24_purchase_cost(ttot,regi,tradeSe) =e= sum(  (regi2,teTradeTranspModes), v24_shipment_quan(ttot,regi2,regi,tradeSe,teTradeTranspModes) * pm_exportPrice(ttot,regi2,tradeSe)  )
;

*** cost from transportation capacities
q24_tradeTransp_cost(ttot,regi,tradeSe)..
    v24_tradeTransp_cost(ttot,regi,tradeSe)
  =e=
    sum(regi2,
      v24_deltaCap_tradeTransp(ttot,regi2,regi,tradeSe,'pipeline')        * (p24_dataglob_transp('inco0',tradeSe,'pipeline')         + p24_dataglob_transp('inco0_d',tradeSe,'pipeline')         * p24_distance(regi,regi2))
    + v24_cap_tradeTransp(ttot,regi2,regi,tradeSe,'pipeline')             * (p24_dataglob_transp('omf'  ,tradeSe,'pipeline')         + p24_dataglob_transp('omf_d'  ,tradeSe,'pipeline')         * p24_distance(regi,regi2))
    + v24_shipment_quan(ttot,regi2,regi,tradeSe,'pipeline')               * (p24_dataglob_transp('omv'  ,tradeSe,'pipeline')         + p24_dataglob_transp('omv_d'  ,tradeSe,'pipeline')         * p24_distance(regi,regi2))
    + v24_deltaCap_tradeTransp(ttot,regi2,regi2,tradeSe,'shipping_Xport') * (p24_dataglob_transp('inco0',tradeSe,'shipping_Xport')   + p24_dataglob_transp('inco0_d',tradeSe,'shipping_Xport')   * p24_distance(regi,regi2))
    + v24_cap_tradeTransp(ttot,regi2,regi2,tradeSe,'shipping_Xport')      * (p24_dataglob_transp('omf'  ,tradeSe,'shipping_Xport')   + p24_dataglob_transp('omf_d'  ,tradeSe,'shipping_Xport')   * p24_distance(regi,regi2))
    + v24_deltaCap_tradeTransp(ttot,regi2,regi2,tradeSe,'shipping_Mport') * (p24_dataglob_transp('inco0',tradeSe,'shipping_Mport')   + p24_dataglob_transp('inco0_d',tradeSe,'shipping_Mport')   * p24_distance(regi,regi2))
    + v24_cap_tradeTransp(ttot,regi2,regi2,tradeSe,'shipping_Mport')      * (p24_dataglob_transp('omf'  ,tradeSe,'shipping_Mport')   + p24_dataglob_transp('omf_d'  ,tradeSe,'shipping_Mport')   * p24_distance(regi,regi2))
    + v24_shipment_quan(ttot,regi2,regi,tradeSe,'shipping')               * (p24_dataglob_transp('omv'  ,tradeSe,'shipping_vessels') + p24_dataglob_transp('omv_d'  ,tradeSe,'shipping_vessels') * p24_distance(regi,regi2))
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

*** variable constraints
v24_shipment_quan.lo(ttot,all_regi,all_regi,all_enty,teTradeTranspModes) = 0.0;
v24_shipment_cost.lo(ttot,all_regi,all_enty) = 0.0;
v24_nonserve_cost.lo(ttot,all_regi,all_enty) = 0.0;
v24_cap_tradeTransp.lo(ttot,all_regi,all_regi,all_enty,teTradeTransp) = 0.0;
v24_deltaCap_tradeTransp.lo(ttot,all_regi,all_regi,all_enty,teTradeTransp) = 0.0;

v24_cap_tradeTransp.fx(ttot,regi,regi2,tradeSe,'shipping_Mport')$(not sameAs(regi,regi2)) = 0.0;
v24_cap_tradeTransp.fx(ttot,regi,regi2,tradeSe,'shipping_Xport')$(not sameAs(regi,regi2)) = 0.0;

*** fix initial capacities
v24_cap_tradeTransp.fx(ttot,regi,regi2,tradeSe,'pipeline')$(pm_ttot_val(ttot) eq cm_startyear) = pm_XMport_pipeline(regi,regi2,tradeSe);
v24_cap_tradeTransp.fx(ttot,regi,regi,tradeSe,'shipping_Mport')$(pm_ttot_val(ttot) eq cm_startyear) = pm_Mport(ttot,regi,tradeSe)-sum(regi2,pm_XMport_pipeline(regi2,regi,tradeSe));
v24_cap_tradeTransp.fx(ttot,regi,regi,tradeSe,'shipping_Xport')$(pm_ttot_val(ttot) eq cm_startyear) = pm_Xport_effective(ttot,regi,tradeSe)-sum(regi2,pm_XMport_pipeline(regi,regi2,tradeSe));

*** shipments constrained: no self-imports or self-exports
v24_shipment_quan.fx(ttot,regi,regi2,tradeSe,teTradeTranspModes)$sameAs(regi,regi2) = 0.0;

*** shipments constrained: trade only allowed between defined regions
v24_shipment_quan.fx(ttot,regi,regi2,tradeSe,teTradeTranspModes)$(p24_disallowed(regi,regi2,tradeSe,teTradeTranspModes) gt 0.0) = 0.0;



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
        
        q24_cap_tradeTransp_pipeline
        q24_cap_tradeTransp_shipping_Mport
        q24_cap_tradeTransp_shipping_Xport
        
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
