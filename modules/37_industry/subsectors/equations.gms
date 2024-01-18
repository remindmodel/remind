*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/subsectors/equations.gms

*** ---------------------------------------------------------------------------
***        1. CES-Based (mostly)
*** ---------------------------------------------------------------------------

***------------------------------------------------------
*' Industry final energy balance
***------------------------------------------------------
q37_demFeIndst(ttot,regi,entyFE,emiMkt)$(    ttot.val ge cm_startyear
                                         AND entyFE2Sector(entyFE,"indst") ) ..
  sum(se2fe(entySE,entyFE,te),
    vm_demFeSector_afterTax(ttot,regi,entySE,entyFE,"indst",emiMkt)
  )
  =e=
  sum(fe2ppfEN(entyFE,ppfen_industry_dyn37(in)),
    sum((secInd37_emiMkt(secInd37,emiMkt),secInd37_2_pf(secInd37,in)),
      (
          vm_cesIO(ttot,regi,in)
        + pm_cesdata(ttot,regi,in,"offset_quantity")
      )$(NOT secInd37Prc(secInd37))
    )
  )
  +
  sum((secInd37_emiMkt(secInd37Prc,emiMkt),
       secInd37_tePrc(secInd37Prc,tePrc),
       tePrc2opmoPrc(tePrc,opmoPrc)),
    p37_specFeDem(ttot,regi,entyFE,tePrc,opmoPrc)
    *
    vm_outflowPrc(ttot,regi,tePrc,opmoPrc)
  )
;

***------------------------------------------------------
*' Thermodynamic limits on subsector energy demand
***------------------------------------------------------
$ifthen.no_calibration "%CES_parameters%" == "load"   !! CES_parameters
q37_energy_limits(ttot,regi,industry_ue_calibration_target_dyn37(out))$(
                             ttot.val gt 2020
                             AND NOT ppfUePrc(out)
			                       AND p37_energy_limit_slope(ttot,regi,out) ) ..
  sum(ces_eff_target_dyn37(out,in), vm_cesIO(ttot,regi,in))
  =g=
    vm_cesIO(ttot,regi,out)
  * p37_energy_limit_slope(ttot,regi,out)
;
$endif.no_calibration

***------------------------------------------------------
*' Limit the share of secondary steel to historic values, fading to 90 % in 2050
***------------------------------------------------------
q37_limit_secondary_steel_share(ttot,regi)$(
         ttot.val ge cm_startyear

$ifthen.fixed_production "%cm_import_EU%" == "bal"   !! cm_import_EU
         !! do not limit steel production shares for fixed production
     AND p37_industry_quantity_targets(ttot,regi,"ue_steel_secondary") eq 0
$endif.fixed_production
$ifthen.exogDem_scen NOT "%cm_exogDem_scen%" == "off"
         !! do not limit steel production shares for fixed production
     AND pm_exogDemScen(ttot,regi,"%cm_exogDem_scen%","ue_steel_secondary") eq 0
$endif.exogDem_scen

                                                                            ) ..
  vm_cesIO(ttot,regi,"ue_steel_secondary")
  =l=
    ( vm_cesIO(ttot,regi,"ue_steel_primary")
    + vm_cesIO(ttot,regi,"ue_steel_secondary")
    )
  * p37_steel_secondary_max_share(ttot,regi)
;

***------------------------------------------------------
*' Compute gross local industry emissions before CCS by multiplying sub-sector energy
*' use with fuel-specific emission factors. (Local means from a hypothetical purely fossil
*' energy mix, as that is what can be captured); vm_emiIndBase itself is not used for emission
*' accounting, just as a CCS baseline.
***------------------------------------------------------
q37_emiIndBase(ttot,regi,entyFE,secInd37)$( ttot.val ge cm_startyear ) ..
    vm_emiIndBase(ttot,regi,entyFE,secInd37)
  =e=
    sum((secInd37_2_pf(secInd37,ppfen_industry_dyn37(in)),fe2ppfen(entyFECC37(entyFE),in)),
      ( vm_cesIO(ttot,regi,in)
      - ( p37_chemicals_feedstock_share(ttot,regi)
        * vm_cesIO(ttot,regi,in)
	)$( in_chemicals_feedstock_37(in) )
      )
        *
        sum(se2fe(entySEfos,entyFE,te),
            pm_emifac(ttot,regi,entySEfos,entyFE,te,"co2")
        )
    )$(NOT secInd37Prc(secInd37))
    +
    sum((secInd37_tePrc(secInd37,tePrc),tePrc2opmoPrc(tePrc,opmoPrc)),
        v37_emiPrc(ttot,regi,entyFE,tePrc,opmoPrc)
    )$(secInd37Prc(secInd37))
;

***------------------------------------------------------
*' Compute maximum possible CCS level in industry sub-sectors given the current
*' CO2 price.
***------------------------------------------------------
q37_emiIndCCSmax(ttot,regi,emiInd37)$( ttot.val ge cm_startyear AND NOT sum(secInd37Prc,secInd37_2_emiInd37(secInd37Prc,emiInd37)) ) ..
  v37_emiIndCCSmax(ttot,regi,emiInd37)
  =e=
    !! map sub-sector emissions to sub-sector MACs
    !! otherInd has no CCS, therefore no MAC, cement has both fuel and process
    !! emissions under the same MAC
    sum(emiMac2mac(emiInd37,macInd37),
      !! add cement process emissions, which are calculated in core/preloop
      !! from a econometric fit and might not correspond to energy use (FIXME)
      ( sum((secInd37_2_emiInd37(secInd37,emiInd37),entyFE),
          vm_emiIndBase(ttot,regi,entyFE,secInd37)
        )$( NOT sameas(emiInd37,"co2cement_process") )
      + ( vm_emiIndBase(ttot,regi,"co2cement_process","cement")
        )$( sameas(emiInd37,"co2cement_process") )
      )
    * pm_macSwitch(macInd37)              !! sub-sector CCS available or not
    * pm_macAbatLev(ttot,regi,macInd37)   !! abatement level at current price
  )
;

***------------------------------------------------------
*' Limit industry CCS to maximum possible CCS level.
***------------------------------------------------------
q37_IndCCS(ttot,regi,emiInd37)$( ttot.val ge cm_startyear AND NOT sum(secInd37Prc,secInd37_2_emiInd37(secInd37Prc,emiInd37)) ) ..
  vm_emiIndCCS(ttot,regi,emiInd37)
  =l=
  v37_emiIndCCSmax(ttot,regi,emiInd37)
;

***------------------------------------------------------
*' Limit industry CCS scale-up to sm_macChange (default: 5 % p.a.)
***------------------------------------------------------
q37_limit_IndCCS_growth(ttot,regi,emiInd37) ..
  vm_emiIndCCS(ttot,regi,emiInd37)
  =l=
    vm_emiIndCCS(ttot-1,regi,emiInd37)
  + sum(secInd37_2_emiInd37(secInd37,emiInd37),
      v37_emiIndCCSmax(ttot,regi,emiInd37)
    * sm_macChange
    * pm_ts(ttot)
    )
;

***------------------------------------------------------
*' Fix cement fuel and cement process emissions to the same abatement level.
***------------------------------------------------------
q37_cementCCS(ttot,regi)$(    ttot.val ge cm_startyear
                          AND pm_macswitch("co2cement")
                          AND pm_macAbatLev(ttot,regi,"co2cement") ) ..
    vm_emiIndCCS(ttot,regi,"co2cement")
  * v37_emiIndCCSmax(ttot,regi,"co2cement_process")
  =e=
    vm_emiIndCCS(ttot,regi,"co2cement_process")
  * v37_emiIndCCSmax(ttot,regi,"co2cement")
;

***------------------------------------------------------
*' Calculate industry CCS costs.
***------------------------------------------------------
q37_IndCCSCost(ttot,regi,emiInd37)$( ttot.val ge cm_startyear AND NOT sum(secInd37Prc,secInd37_2_emiInd37(secInd37Prc,emiInd37)) ) ..
  vm_IndCCSCost(ttot,regi,emiInd37)
  =e=
    1e-3
  * pm_macSwitch(emiInd37)
  * ( sum((enty,secInd37_2_emiInd37(secInd37,emiInd37)),
        vm_emiIndBase(ttot,regi,enty,secInd37)
      )$( NOT sameas(emiInd37,"co2cement_process") )
    + ( vm_emiIndBase(ttot,regi,"co2cement_process","cement")
      )$( sameas(emiInd37,"co2cement_process") )
    )
  * sm_dmac
  * sum(emiMac2mac(emiInd37,enty),
      ( pm_macStep(ttot,regi,enty)
      * sum(steps$( ord(steps) eq pm_macStep(ttot,regi,enty) ),
          pm_macAbat(ttot,regi,enty,steps)
        )
      )
    - sum(steps$( ord(steps) le pm_macStep(ttot,regi,enty) ),
        pm_macAbat(ttot,regi,enty,steps)
      )
    )
;


***------------------------------------------------------
*'  CES markup cost that are accounted in the budget (GDP) to represent sector-specific demand-side transformation cost in industry
***------------------------------------------------------
q37_costCESmarkup(t,regi,in)$(ppfen_industry_dyn37(in))..
  vm_costCESMkup(t,regi,in)
  =e=
    p37_CESMkup(t,regi,in)
  * (vm_cesIO(t,regi,in) + pm_cesdata(t,regi,in,"offset_quantity"))
;

***--------------------------------------------------------------------------
*'  Feedstock balances
***--------------------------------------------------------------------------

*' Lower bound on feso/feli/fega in chemicals FE input for feedstocks
q37_chemicals_feedstocks_limit(t,regi)$( t.val ge cm_startyear ) ..
  sum(in_chemicals_feedstock_37(in), vm_cesIO(t,regi,in))
  =g=
    sum(ces_eff_target_dyn37("ue_chemicals",in), vm_cesIO(t,regi,in))
  * p37_chemicals_feedstock_share(t,regi)
;

*' Define the flow of non-energy feedstocks. It is used for emissions accounting and calculating plastics production
q37_demFeFeedstockChemIndst(ttot,regi,entyFE,emiMkt)$(
                         ttot.val ge cm_startyear
                     AND entyFE2sector2emiMkt_NonEn(entyFE,"indst",emiMkt) ) ..
  sum(se2fe(entySE,entyFE,te),
    vm_demFENonEnergySector(ttot,regi,entySE,entyFE,"indst",emiMkt)
  )
  =e=
  sum((fe2ppfEN(entyFE,ppfen_industry_dyn37(in)),
       secInd37_emiMkt(secInd37,emiMkt),
       secInd37_2_pf(secInd37,in_chemicals_feedstock_37(in))),
    ( vm_cesIO(ttot,regi,in)
    + pm_cesdata(ttot,regi,in,"offset_quantity")
    )
  * p37_chemicals_feedstock_share(ttot,regi)
  )
;

*' Feedstocks flow has to be lower than total energy flow into the industry
q37_feedstocksLimit(ttot,regi,entySE,entyFE,emiMkt)$(
                                             ttot.val ge cm_startyear
                                         AND sefe(entySE,entyFE)
                                         AND sector2emiMkt("indst",emiMkt)
                                         AND entyFe2Sector(entyFe,"indst")
                                         AND entyFeCC37(entyFe)            ) ..
  vm_demFESector(ttot,regi,entySE,entyFE,"indst",emiMkt)
  =g=
  vm_demFENonEnergySector(ttot,regi,entySE,entyFE,"indst",emiMkt)
;

*' Calculate mass of carbon contained in chemical feedstocks
q37_FeedstocksCarbon(ttot,regi,sefe(entySE,entyFE),emiMkt)$(
                         entyFE2sector2emiMkt_NonEn(entyFE,"indst",emiMkt) ) ..
  vm_FeedstocksCarbon(ttot,regi,entySE,entyFE,emiMkt)
  =e=
    vm_demFENonEnergySector(ttot,regi,entySE,entyFE,"indst",emiMkt)
  * p37_FeedstockCarbonContent(ttot,regi,entyFE)
;

*' Calculate carbon contained in plastics as a share of carbon in feedstock [GtC]
q37_plasticsCarbon(ttot,regi,sefe(entySE,entyFE),emiMkt)$(
                         entyFE2sector2emiMkt_NonEn(entyFE,"indst",emiMkt) ) ..
  vm_plasticsCarbon(ttot,regi,entySE,entyFE,emiMkt)
  =e=
    vm_FeedstocksCarbon(ttot,regi,entySE,entyFE,emiMkt)
  * s37_plasticsShare
;

*' calculate plastic waste generation, shifted by mean lifetime of plastic products
*' shift by 2 time steps when we have 5-year steps and 1 when we have 10-year steps
*' allocate averge of 2055 and 2060 to 2070
q37_plasticWaste(ttot,regi,sefe(entySE,entyFE),emiMkt)$(
                        entyFE2sector2emiMkt_NonEn(entyFE,"indst",emiMkt)
                    AND ttot.val ge cm_startyear                          ) ..
  vm_plasticWaste(ttot,regi,entySE,entyFE,emiMkt)
  =e=
    vm_plasticsCarbon(ttot-2,regi,entySE,entyFE,emiMkt)$( ttot.val le 2060 )
  + ( ( vm_plasticsCarbon(ttot-2,regi,entySE,entyFE,emiMkt)
      + vm_plasticsCarbon(ttot-1,regi,entySE,entyFE,emiMkt)
      )
    / 2
    )$( ttot.val eq 2070 )
  + vm_plasticsCarbon(ttot-1,regi,entySE,entyFE,emiMkt)$( ttot.val gt 2070 )
  ;

*' plastic waste in the past is not accounted for
vm_plasticWaste.fx(ttot,regi,sefe(entySE,entyFE),emiMkt)$( ttot.val lt 2005 ) = 0 ;
vm_plasticsCarbon.fx(ttot,regi,sefe(entySE,entyFE),emiMkt)$( ttot.val lt 2005 ) = 0 ;

*' emissions from plastics incineration as a share of total plastic waste
q37_incinerationEmi(ttot,regi,sefe(entySE,entyFE),emiMkt)$(
                         entyFE2sector2emiMkt_NonEn(entyFE,"indst",emiMkt)) ..
  vm_incinerationEmi(ttot,regi,entySE,entyFE,emiMkt)
  =e=
    vm_plasticWaste(ttot,regi,entySE,entyFE,emiMkt)
  * pm_incinerationRate(ttot,regi)
;

*' calculate carbon contained in non-incinerated plastics
*' this is used in emissions accounting to subtract the carbon that gets
*' sequestered in plastic products
q37_nonIncineratedPlastics(ttot,regi,sefe(entySE,entyFE),emiMkt)$(
                         entyFE2sector2emiMkt_NonEn(entyFE,"indst",emiMkt) ) ..
  vm_nonIncineratedPlastics(ttot,regi,entySE,entyFE,emiMkt)
  =e=
    vm_plasticWaste(ttot,regi,entySE,entyFE,emiMkt)
  * (1 - pm_incinerationRate(ttot,regi))
  ;

*' calculate flow of carbon contained in chemical feedstock with unknown fate
*' it is assumed that this carbon is re-emitted in the same timestep
q37_feedstockEmiUnknownFate(ttot,regi,sefe(entySE,entyFE),emiMkt)$(
                         entyFE2sector2emiMkt_NonEn(entyFE,"indst",emiMkt) ) ..
  vm_feedstockEmiUnknownFate(ttot,regi,entySE,entyFE,emiMkt)
  =e=
    vm_FeedstocksCarbon(ttot,regi,entySE,entyFE,emiMkt)
  * (1 - s37_plasticsShare)
;

*' in baseline runs, all industrial feedstocks should come from fossil energy
*' carriers, no biofuels or synfuels
q37_FossilFeedstock_Base(t,regi,entyFE,emiMkt)$(
                         entyFE2sector2emiMkt_NonEn(entyFE,"indst",emiMkt)
                     AND cm_emiscen eq 1                                   ) ..
  sum(entySE, vm_demFENonEnergySector(t,regi,entySE,entyFE,"indst",emiMkt))
  =e=
  sum(entySEFos,
    vm_demFENonEnergySector(t,regi,entySEfos,entyFE,"indst",emiMkt)
  )
;

*** ---------------------------------------------------------------------------
***        2. Process-Based
*** ---------------------------------------------------------------------------

***------------------------------------------------------
*' Material input to production
***------------------------------------------------------
q37_demMatPrc(ttot,regi,mat)$((ttot.val ge cm_startyear) AND matIn(mat))..
    v37_matFlow(ttot,regi,mat)
  =e=
    sum(tePrc2matIn(tePrc,opmoPrc,mat),
      p37_specMatDem(mat,tePrc,opmoPrc)
      *
      vm_outflowPrc(ttot,regi,tePrc,opmoPrc)
    )
;

***------------------------------------------------------
*' Material cost
***------------------------------------------------------
q37_costMat(ttot,regi)$(ttot.val ge cm_startyear)..
    vm_costMatPrc(ttot,regi)
  =e=
    sum(mat,
      p37_priceMat(mat)
      *
      v37_matFlow(ttot,regi,mat))
;

***------------------------------------------------------
*' Output material production
***------------------------------------------------------
q37_prodMat(ttot,regi,mat)$((ttot.val ge cm_startyear) AND matOut(mat))..
    v37_matFlow(ttot,regi,mat)
  =e=
    sum(tePrc2matOut(tePrc,opmoPrc,mat),
      vm_outflowPrc(ttot,regi,tePrc,opmoPrc)
    )
;

***------------------------------------------------------
*' Hand-over to CES
***------------------------------------------------------
q37_mat2ue(ttot,regi,all_in)$((ttot.val ge cm_startyear) AND ppfUePrc(all_in))..
    vm_cesIO(ttot,regi,all_in)
  =e=
    sum(mat2ue(mat,all_in),
      p37_mat2ue(mat,all_in)
      *
      v37_matFlow(ttot,regi,mat)
    )
;

***------------------------------------------------------
*' Definition of capacity constraints
***------------------------------------------------------
q37_limitCapMat(ttot,regi,tePrc)$(ttot.val ge cm_startyear) ..
    sum(tePrc2opmoPrc(tePrc,opmoPrc),
      vm_outflowPrc(ttot,regi,tePrc,opmoPrc)
    )
    =l=
    sum(teMat2rlf(tePrc,rlf),
      vm_capFac(ttot,regi,tePrc) * vm_cap(ttot,regi,tePrc,rlf)
    )
;

***------------------------------------------------------
*' Emission from process based industry sector (pre CC)
***------------------------------------------------------
q37_emiPrc(ttot,regi,entyFE,tePrc,opmoPrc)$(ttot.val ge cm_startyear ) ..
    v37_emiPrc(ttot,regi,entyFE,tePrc,opmoPrc)
  =e=
    p37_specFeDem(ttot,regi,entyFE,tePrc,opmoPrc)
    *
    sum(se2fe(entySEfos,entyFE,te),
      pm_emifac(ttot,regi,entySEfos,entyFE,te,"co2"))
    *
    vm_outflowPrc(ttot,regi,tePrc,opmoPrc)
;

***------------------------------------------------------
*' Carbon capture processes can only capture as much co2 as the base process emits
***------------------------------------------------------
q37_limitOutflowCCPrc(ttot,regi,tePrc)$(ttot.val ge cm_startyear ) ..
    sum((entyFE,tePrc2opmoPrc(tePrc,opmoPrc)),
      v37_emiPrc(ttot,regi,entyFE,tePrc,opmoPrc))
  =g=
    sum(tePrc2teCCPrc(tePrc,opmoPrc,teCCPrc,opmoCCPrc),
      1. / p37_captureRate(teCCPrc,opmoCCPrc)
      *
      vm_outflowPrc(ttot,regi,teCCPrc,opmoCCPrc)
    )
;

***------------------------------------------------------
*' Emission captured from process based industry sector
***------------------------------------------------------
q37_emiCCPrc(ttot,regi,emiInd37)$((ttot.val ge cm_startyear ) AND sum(secInd37Prc,secInd37_2_emiInd37(secInd37Prc,emiInd37)) ) ..
    vm_emiIndCCS(ttot,regi,emiInd37)
  =e=
    sum((secInd37_2_emiInd37(secInd37Prc,emiInd37),
         secInd37_tePrc(secInd37Prc,tePrc),
         tePrc2teCCPrc(tePrc,opmoPrc,teCCPrc,opmoCCPrc)),
      vm_outflowPrc(ttot,regi,teCCPrc,opmoCCPrc)
    )
;

*** EOF ./modules/37_industry/subsectors/equations.gms
