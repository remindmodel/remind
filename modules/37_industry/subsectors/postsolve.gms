*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/subsectors/postsolve.gms

*** calculation of FE Industry Prices (useful for internal use and reporting
*** purposes)
pm_FEPrice(ttot,regi,entyFe,"indst",emiMkt)$( abs(qm_budget.m(ttot,regi)) gt sm_eps )
  = q37_demFeIndst.m(ttot,regi,entyFe,emiMkt)
  / qm_budget.m(ttot,regi);

*** calculate reporting parameters for FE per subsector and SE origin to make R
*** reporting easier

o37_demFePrc(ttot,regi,entyFe,tePrc,opmoPrc)$(pm_specFeDem(ttot,regi,entyFe,tePrc,opmoPrc))
  = vm_outflowPrc.l(ttot,regi,tePrc,opmoPrc)
    * pm_specFeDem(ttot,regi,entyFe,tePrc,opmoPrc)
;

*** total FE per energy carrier and emissions market in industry (sum over
*** subsectors)
o37_demFeIndTotEn(ttot,regi,entyFe,emiMkt)
  = sum((fe2ppfEn37(entyFe,in),secInd37_2_pf(secInd37,in),
                         secInd37_emiMkt(secInd37,emiMkt))$(NOT secInd37Prc(secInd37)),
      (vm_cesIO.l(ttot,regi,in)
      +pm_cesdata(ttot,regi,in,"offset_quantity"))
    )
  + sum((secInd37_emiMkt(secInd37Prc,emiMkt),secInd37_tePrc(secInd37Prc,tePrc),tePrc2opmoPrc(tePrc,opmoPrc)),
      o37_demFePrc(ttot,regi,entyFe,tePrc,opmoPrc)
    )
;

*** share of subsector in FE industry energy carriers and emissions markets
o37_shIndFE(ttot,regi,entyFe,secInd37,emiMkt)$(
                                    o37_demFeIndTotEn(ttot,regi,entyFe,emiMkt) )
  =
  (
    sum(( fe2ppfEn37(entyFe,in),
          secInd37_2_pf(secInd37,in),
          secInd37_emiMkt(secInd37,emiMkt))$(NOT secInd37Prc(secInd37)),
      (vm_cesIO.l(ttot,regi,in)
      + pm_cesdata(ttot,regi,in,"offset_quantity"))
      )
  + sum((secInd37_emiMkt(secInd37Prc,emiMkt),
           secInd37_tePrc(secInd37Prc,tePrc),
           tePrc2opmoPrc(tePrc,opmoPrc)),
      o37_demFePrc(ttot,regi,entyFe,tePrc,opmoPrc)
      )$(secInd37Prc(secInd37))
  )
  / o37_demFeIndTotEn(ttot,regi,entyFe,emiMkt)
;


*** FE per subsector and energy carriers
o37_demFeIndSub(ttot,regi,entySe,entyFe,secInd37,emiMkt)
  = sum(secInd37_emiMkt(secInd37,emiMkt),
      o37_shIndFE(ttot,regi,entyFe,secInd37,emiMkt)
    * vm_demFeSector_afterTax.l(ttot,regi,entySe,entyFe,"indst",emiMkt)
  );

*** industry captured fuel CO2
pm_IndstCO2Captured(ttot,regi,entySe,entyFe(entyFeCC37),secInd37,emiMkt)$(
                     emiInd37_fe2sec(entyFe,secInd37)
                 AND sum(entyFE2, vm_emiIndBase.l(ttot,regi,entyFE2,secInd37)) )
  = ( o37_demFeIndSub(ttot,regi,entySe,entyFe,secInd37,emiMkt)
    * sum(se2fe(entySE2,entyFe,te),
        !! collapse entySe dimension, so emission factors apply to all entyFe
        !! regardless or origin, and therefore entySEbio and entySEsyn have
        !! non-zero emission factors
        pm_emifac(ttot,regi,entySE2,entyFe,te,"co2")
      )
    ) !! subsector emissions (smokestack, i.e. including biomass & synfuels)

  * ( sum(secInd37_2_emiInd37(secInd37,emiInd37(emiInd37_fuel)),
      vm_emiIndCCS.l(ttot,regi,emiInd37)
      ) !! subsector captured energy emissions

    / sum(entyFeCC37_2,
        vm_emiIndBase.l(ttot,regi,entyFeCC37_2,secInd37)
      ) !! subsector total energy emissions
    ) !! subsector capture share
;


*** calculate share of sebio- and sesyn-based co2 captured
pm_NonFos_IndCC_fraction0(ttot,regi,emiInd37)$(
              sum(secInd37$secInd37_2_emiInd37(secInd37,emiInd37),
                  (sum((entySe,entyFe,emiMkt),
                        pm_IndstCO2Captured(ttot,regi,entySe,entyFe,secInd37,emiMkt)))))
  = sum(secInd37$secInd37_2_emiInd37(secInd37,emiInd37),
        sum( (entySe,entyFe, emiMkt)$(NOT (entySeFos(entySe))),
          pm_IndstCO2Captured(ttot,regi,entySe,entyFe,secInd37,emiMkt))
    / (sum((entySe,entyFe,emiMkt),
          pm_IndstCO2Captured(ttot,regi,entySe,entyFe,secInd37,emiMkt))))
;


*** ---------------------------------------------------------------------------
*** Process-Based
*** ---------------------------------------------------------------------------

!! relative outflow:
!! Needed for LCOP calculation; has to be independent of vm_outflowPrc to also
!! yield valid values for tech with zero vm_outflowPrc
*** ---------------------------------------------------------------------------

o37_relativeOutflow(ttot,regi,tePrc,opmoPrc)$tePrc2opmoPrc(tePrc,opmoPrc) = 1.;
o37_specificEmi(ttot,regi,tePrc,opmoPrc) = 0.;

loop((tePrc1,opmoPrc1,tePrc2,opmoPrc2,mat)$(
                tePrc2matIn(tePrc2,opmoPrc2,mat)
            AND tePrc2matOut(tePrc1,opmoPrc1,mat)),
  o37_relativeOutflow(ttot,regi,tePrc1,opmoPrc1)
    = p37_specMatDem(mat,tePrc2,opmoPrc2)
    * o37_relativeOutflow(ttot,regi,tePrc2,opmoPrc2); !! should be one; becomes relevant for more than two stages; then, ensure to loop backwards through the route!
);

!! auxiliary for CC relative outflow
loop((tePrc,opmoPrc)$(tePrc2opmoPrc(tePrc,opmoPrc)),
  o37_specificEmi(ttot,regi,tePrc,opmoPrc) =
    sum(entyFe,
        pm_specFeDem(ttot,regi,entyFe,tePrc,opmoPrc)
        *
        sum(se2fe(entySeFos,entyFe,te),
          pm_emifac(ttot,regi,entySeFos,entyFe,te,"co2")));
);

!! CC relative outflow
loop((tePrc,opmoPrc,teCCPrc,opmoCCPrc)$(
                          tePrc2teCCPrc(tePrc,opmoPrc,teCCPrc,opmoCCPrc)),

  !! of_cc = cr_base * emi_base * of_base   +   cr_cc * emi_cc * of_cc       !! solve for of_cc
  !! --> of_cc = (cr_base * emi_base * of_base) / (1. - cr_cc * emi_cc)      !! divide by of_fin
  !! --> relOf_cc = (cr_base * emi_base * relOf_base) / (1. - cr_cc * emi_cc)

  o37_relativeOutflow(ttot,regi,teCCPrc,opmoCCPrc)
    = (p37_captureRate(teCCPrc)
      * o37_specificEmi(ttot,regi,tePrc,opmoPrc)
      * o37_relativeOutflow(ttot,regi,tePrc,opmoPrc))
    /
      (1. - p37_selfCaptureRate(teCCPrc) * o37_specificEmi(ttot,regi,teCCPrc,opmoCCPrc) );
);


*** determine shares of vm_outflowPrc that belong to a certain route
*** ---------------------------------------------------------------------------

!! init all to 1
o37_shareRoute(ttot,regi,tePrc,opmoPrc,route)$tePrc2route(tePrc,opmoPrc,route) = 1.;


 !! 1st stage with two second-stage processes
 !! share = methanol * mtoMta*specDem / (mtoMta*specDem + meToFinal*specDem)
 !! - loop over first stage techs
 !! - loop over second stage techs sharing a route
 !! - for each route, share_route is outflowPrc of 2nd stage tech of that route divided by sum_routes(outflowPrc of 2nd stage tech of route)
 !!   (outFlowPrc always multiplied by specMatDem)
 loop((tePrc1,opmoPrc1,tePrc2,opmoPrc2,mat,route)$(
                 tePrc2matIn(tePrc2,opmoPrc2,mat)
             AND tePrc2matOut(tePrc1,opmoPrc1,mat)
             AND tePrc2route(tePrc1,opmoPrc1,route)
             AND tePrc2route(tePrc2,opmoPrc2,route)),
   o37_shareRoute(ttot,regi,tePrc1,opmoPrc1,route)
   = vm_outflowPrc.l(ttot,regi,tePrc2,opmoPrc2)
   * p37_specMatDem(mat,tePrc2,opmoPrc2)
   / max(
       sum((route2,tePrc3,opmoPrc3)$(
                 tePrc2matIn(tePrc3,opmoPrc3,mat)
             AND tePrc2matOut(tePrc1,opmoPrc1,mat)
             AND tePrc2route(tePrc1,opmoPrc1,route2)
             AND tePrc2route(tePrc3,opmoPrc3,route2)
             AND (NOT routeCC(route2))),
         vm_outflowPrc.l(ttot,regi,tePrc3,opmoPrc3)
         * p37_specMatDem(mat,tePrc3,opmoPrc3)
       ),
       sm_eps
     )
   ;
 );


loop((tePrc,opmoPrc,teCCPrc,opmoCCPrc,route)$(
                          tePrc2teCCPrc(tePrc,opmoPrc,teCCPrc,opmoCCPrc)
                      AND tePrc2route(teCCPrc,opmoCCPrc,route)),

  !! share of first-stage tech with CCS
  o37_shareRoute(ttot,regi,tePrc,opmoPrc,route)$(sum(entyFe,v37_emiPrc.l(ttot,regi,entyFe,tePrc,opmoPrc)) gt 0.)
    =   o37_shareRoute(ttot,regi,tePrc,opmoPrc,route)
      * v37_shareWithCC.l(ttot,regi,tePrc,opmoPrc);

  !! share of first-stage tech without CCS
  loop(routeCC2baseRoute(route,route2),
    o37_shareRoute(ttot,regi,tePrc,opmoPrc,route2)
    = o37_shareRoute(ttot,regi,tePrc,opmoPrc,route2)
     * (1. - v37_shareWithCC.l(ttot,regi,tePrc,opmoPrc));
  );
);

!! second stage
loop((tePrc1,opmoPrc1,tePrc2,opmoPrc2,mat,route)$(
                tePrc2matIn(tePrc2,opmoPrc2,mat)
            AND tePrc2matOut(tePrc1,opmoPrc1,mat)
            AND tePrc2route(tePrc1,opmoPrc1,route)
            AND tePrc2route(tePrc2,opmoPrc2,route)),
  !! The share of second-stage tech (such as eaf) which belongs to a certain route equals...
  o37_shareRoute(ttot,regi,tePrc2,opmoPrc2,route)$(vm_outflowPrc.l(ttot,regi,tePrc2,opmoPrc2) gt sm_eps)
  !! ...the outflow of the first-stage tech (such as idr) which provides the input material (such as driron) to the second-stage...
  =   vm_outflowPrc.l(ttot,regi,tePrc1,opmoPrc1)
    !! ...times the share of that 1st stage tech which belongs to a certain route
    * o37_shareRoute(ttot,regi,tePrc1,opmoPrc1,route)
    !! divided by total amount of that input material required by second-stage tech
    / ( vm_outflowPrc.l(ttot,regi,tePrc2,opmoPrc2)
      * p37_specMatDem(mat,tePrc2,opmoPrc2));
);


*** determine production and FE demand by route
*** ---------------------------------------------------------------------------
loop((mat,route)$(matOut(mat)),
  o37_ProdIndRoute(ttot,regi,mat,route)
    = sum((tePrc,opmoPrc)$(    tePrc2matOut(tePrc,opmoPrc,mat)
                           AND tePrc2route(tePrc,opmoPrc,route)),
        vm_outflowPrc.l(ttot,regi,tePrc,opmoPrc)
          * o37_shareRoute(ttot,regi,tePrc,opmoPrc,route)
      );
);

!!
o37_demFeIndRoute(ttot,regi,entyFe,tePrc,route,secInd37) = 0.;
loop((entyFe,route,tePrc,opmoPrc,secInd37)$(    tePrc2route(tePrc,opmoPrc,route)
                                            AND secInd37_tePrc(secInd37,tePrc)
                                            AND (p37_specFeDemTarget(entyFe,tePrc,opmoPrc) gt 0.) ),
  o37_demFeIndRoute(ttot,regi,entyFe,tePrc,route,secInd37)
  = o37_demFeIndRoute(ttot,regi,entyFe,tePrc,route,secInd37) !!sum (only necessary if several opmodes for one route)
    + vm_outflowPrc.l(ttot,regi,tePrc,opmoPrc)
      * o37_shareRoute(ttot,regi,tePrc,opmoPrc,route)
      * pm_specFeDem(ttot,regi,entyFe,tePrc,opmoPrc);
);

*** EOF ./modules/37_industry/subsectors/postsolve.gms
