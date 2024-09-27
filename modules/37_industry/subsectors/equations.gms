*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/subsectors/equations.gms

*' @equations

*** ---------------------------------------------------------------------------
***        1. CES-Based (mostly)
*** ---------------------------------------------------------------------------

***------------------------------------------------------
*' Industry final energy balance
***------------------------------------------------------
q37_demFeIndst(t,regi,entyFe,emiMkt)$( entyFe2Sector(entyFe,"indst") ) ..
  sum(se2fe(entySe,entyFe,te),
    vm_demFeSector_afterTax(t,regi,entySe,entyFe,"indst",emiMkt)
  )
  =e=
  sum(fe2ppfEn(entyFe,ppfen_industry_dyn37(in)),
    sum((secInd37_emiMkt(secInd37,emiMkt),secInd37_2_pf(secInd37,in)),
      (
          vm_cesIO(t,regi,in)
        + pm_cesdata(t,regi,in,"offset_quantity")
      )$(NOT secInd37Prc(secInd37))
    )
  )
  +
  sum((secInd37_emiMkt(secInd37Prc,emiMkt),
       secInd37_tePrc(secInd37Prc,tePrc),
       tePrc2opmoPrc(tePrc,opmoPrc)),
    pm_specFeDem(t,regi,entyFe,tePrc,opmoPrc)
    *
    vm_outflowPrc(t,regi,tePrc,opmoPrc)
  )
;

***------------------------------------------------------
*' Thermodynamic limits on subsector energy demand
***------------------------------------------------------
$ifthen.no_calibration "%CES_parameters%" == "load"   !! CES_parameters
q37_energy_limits(t,regi,industry_ue_calibration_target_dyn37(out))$(
                                        t.val gt 2020
                                    AND NOT ppfUePrc(out)
                                    AND p37_energy_limit_slope(t,regi,out) ) ..
  sum(ces_eff_target_dyn37(out,in), vm_cesIO(t,regi,in))
  =g=
    vm_cesIO(t,regi,out)
  * p37_energy_limit_slope(t,regi,out)
;
$endif.no_calibration

***------------------------------------------------------
*' Limit the share of secondary steel to historic values, fading to 90 % in 2050
***------------------------------------------------------
q37_limit_secondary_steel_share(t,regi)$(
         YES
$ifthen.fixed_production "%cm_import_EU%" == "bal"   !! cm_import_EU
         !! do not limit steel production shares for fixed production
     AND p37_industry_quantity_targets(t,regi,"ue_steel_secondary") eq 0
$endif.fixed_production
$ifthen.exogDem_scen NOT "%cm_exogDem_scen%" == "off"
         !! do not limit steel production shares for fixed production
     AND pm_exogDemScen(t,regi,"%cm_exogDem_scen%","ue_steel_secondary") eq 0
$endif.exogDem_scen
                                                                            ) ..
  vm_cesIO(t,regi,"ue_steel_secondary")
  =l=
    ( vm_cesIO(t,regi,"ue_steel_primary")
    + vm_cesIO(t,regi,"ue_steel_secondary")
    )
  * p37_steel_secondary_max_share(t,regi)
;

***------------------------------------------------------
*' Compute gross local industry emissions before CCS by multiplying sub-sector energy
*' use with fuel-specific emission factors. (Local means from a hypothetical purely fossil
*' energy mix, as that is what can be captured); vm_emiIndBase itself is not used for emission
*' accounting, just as a CCS baseline.
***------------------------------------------------------
q37_emiIndBase(t,regi,enty,secInd37)$(
                                   entyFeCC37(enty)
                                OR (    sameas(enty,"co2cement_process")
                                    AND cm_CCS_cement eq 1               ) ) ..
  vm_emiIndBase(t,regi,enty,secInd37)
  =e=
    sum((secInd37_2_pf(secInd37,ppfen_industry_dyn37(in)),fe2ppfEn(entyFeCC37(enty),in)),
      ( vm_cesIO(t,regi,in)
      - ( p37_chemicals_feedstock_share(t,regi)
        * vm_cesIO(t,regi,in)
        )$( in_chemicals_feedstock_37(in) )
      )
    * sum(se2fe(entySeFos,enty,te),
        pm_emifac(t,regi,entySeFos,enty,te,"co2")
      )
    )$( NOT secInd37Prc(secInd37) )
  + ( s37_clinker_process_CO2
    * p37_clinker_cement_ratio(t,regi)
    * vm_cesIO(t,regi,"ue_cement")
    / sm_c_2_co2
    )$( sameas(enty,"co2cement_process") AND sameas(secInd37,"cement") )
  + sum((secInd37_tePrc(secInd37,tePrc),tePrc2opmoPrc(tePrc,opmoPrc)),
      v37_emiPrc(t,regi,enty,tePrc,opmoPrc)
    )$( secInd37Prc(secInd37) )
;

***------------------------------------------------------
*' Compute maximum possible CCS level in industry sub-sectors given the current
*' CO2 price.
***------------------------------------------------------
q37_emiIndCCSmax(t,regi,emiInd37)$(
           NOT sum(secInd37Prc, secInd37_2_emiInd37(secInd37Prc,emiInd37)) ) ..
  v37_emiIndCCSmax(t,regi,emiInd37)
  =e=
  !! map sub-sector emissions to sub-sector MACs
  !! otherInd has no CCS, therefore no MAC, cement has both fuel and process
  !! emissions under the same MAC
  sum(emiMac2mac(emiInd37,macInd37),
    ( sum((secInd37_2_emiInd37(secInd37,emiInd37),entyFeCC37),
        vm_emiIndBase(t,regi,entyFeCC37,secInd37)
      )$( NOT sameas(emiInd37,"co2cement_process") )
    + ( vm_emiIndBase(t,regi,"co2cement_process","cement")
      )$( sameas(emiInd37,"co2cement_process") )
    )
    * pm_macSwitch(macInd37)              !! sub-sector CCS available or not
    * pm_macAbatLev(t,regi,macInd37)   !! abatement level at current price
  )
;

***------------------------------------------------------
*' Limit industry CCS to maximum possible CCS level.
***------------------------------------------------------
q37_IndCCS(t,regi,emiInd37)$(
            NOT sum(secInd37Prc,secInd37_2_emiInd37(secInd37Prc,emiInd37)) ) ..
  vm_emiIndCCS(t,regi,emiInd37)
  =l=
  v37_emiIndCCSmax(t,regi,emiInd37)
;

***------------------------------------------------------
*' Limit industry CCS scale-up to sm_macChange (default: 5 % p.a.)
***------------------------------------------------------
q37_limit_IndCCS_growth(ttot,regi,emiInd37)$( ttot.val ge cm_startyear ) ..
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
q37_cementCCS(t,regi)$(    pm_macSwitch("co2cement")
                       AND pm_macAbatLev(t,regi,"co2cement") ) ..
    vm_emiIndCCS(t,regi,"co2cement")
  * v37_emiIndCCSmax(t,regi,"co2cement_process")
  =e=
    vm_emiIndCCS(t,regi,"co2cement_process")
  * v37_emiIndCCSmax(t,regi,"co2cement")
;

***------------------------------------------------------
*' Calculate industry CCS costs.
***------------------------------------------------------
q37_IndCCSCost(t,regi,emiInd37)$(
            NOT sum(secInd37Prc,secInd37_2_emiInd37(secInd37Prc,emiInd37)) ) ..
  vm_IndCCSCost(t,regi,emiInd37)
  =e=
    1e-3
  * pm_macSwitch(emiInd37)
  * ( sum((entyFeCC37,secInd37_2_emiInd37(secInd37,emiInd37)),
        vm_emiIndBase(t,regi,entyFeCC37,secInd37)
      )$( NOT sameas(emiInd37,"co2cement_process") )
    + ( vm_emiIndBase(t,regi,"co2cement_process","cement")
      )$( sameas(emiInd37,"co2cement_process") )
    )
  * sm_dmac
  * sum(emiMac2mac(emiInd37,enty),
      ( pm_macStep(t,regi,enty)
      * sum(steps$( ord(steps) eq pm_macStep(t,regi,enty) ),
          pm_macAbat(t,regi,enty,steps)
        )
      )
    - sum(steps$( ord(steps) le pm_macStep(t,regi,enty) ),
        pm_macAbat(t,regi,enty,steps)
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
q37_chemicals_feedstocks_limit(t,regi) ..
  sum(in_chemicals_feedstock_37(in), vm_cesIO(t,regi,in))
  =g=
    sum(ces_eff_target_dyn37("ue_chemicals",in), vm_cesIO(t,regi,in))
  * p37_chemicals_feedstock_share(t,regi)
;

*' Define the flow of non-energy feedstocks. It is used for emissions accounting and calculating plastics production
q37_demFeFeedstockChemIndst(t,regi,entyFe,emiMkt)$(
                         entyFE2sector2emiMkt_NonEn(entyFe,"indst",emiMkt) ) ..
  sum(se2fe(entySe,entyFe,te),
    vm_demFENonEnergySector(t,regi,entySe,entyFe,"indst",emiMkt)
  )
  =e=
  sum((fe2ppfEn(entyFe,ppfen_industry_dyn37(in)),
       secInd37_emiMkt(secInd37,emiMkt),
       secInd37_2_pf(secInd37,in_chemicals_feedstock_37(in))),
    ( vm_cesIO(t,regi,in)
    + pm_cesdata(t,regi,in,"offset_quantity")
    )
  * p37_chemicals_feedstock_share(t,regi)
  )
;

*' Feedstocks flow has to be lower than total energy flow into the industry
q37_feedstocksLimit(t,regi,entySe,entyFe,emiMkt)$(
                                             sefe(entySe,entyFe)
                                         AND sector2emiMkt("indst",emiMkt)
                                         AND entyFe2Sector(entyFe,"indst")
                                         AND entyFeCC37(entyFe)            ) ..
  vm_demFeSector_afterTax(t,regi,entySe,entyFe,"indst",emiMkt)
  =g=
  vm_demFENonEnergySector(t,regi,entySe,entyFe,"indst",emiMkt)
;

*' Feedstocks have identical fossil/biomass/synfuel shares as industry FE
q37_feedstocksShares(t,regi,entySe,entyFe,emiMkt)$(
                         sum(te, se2fe(entySe,entyFe,te))
                     AND entyFE2sector2emiMkt_NonEn(entyFe,"indst",emiMkt)
                     AND cm_emiscen ne 1                                   ) ..
    vm_demFeSector_afterTax(t,regi,entySe,entyFe,"indst",emiMkt)
  * sum(se2fe(entySe2,entyFe,te),
      vm_demFENonEnergySector(t,regi,entySe2,entyFe,"indst",emiMkt)
    )
  =e=
    vm_demFENonEnergySector(t,regi,entySe,entyFe,"indst",emiMkt)
  * sum(se2fe2(entySe2,entyFe,te),
      vm_demFeSector_afterTax(t,regi,entySe2,entyFe,"indst",emiMkt)
    )
;


*' Calculate mass of carbon contained in chemical feedstocks
q37_FeedstocksCarbon(t,regi,sefe(entySe,entyFe),emiMkt)$(
                         entyFE2sector2emiMkt_NonEn(entyFe,"indst",emiMkt) ) ..
  v37_FeedstocksCarbon(t,regi,entySe,entyFe,emiMkt)
  =e=
    vm_demFENonEnergySector(t,regi,entySe,entyFe,"indst",emiMkt)
  * p37_FeedstockCarbonContent(t,regi,entyFe)
;

*' Calculate carbon contained in plastics as a share of carbon in feedstock [GtC]
q37_plasticsCarbon(t,regi,sefe(entySe,entyFe),emiMkt)$(
                         entyFE2sector2emiMkt_NonEn(entyFe,"indst",emiMkt) ) ..
  v37_plasticsCarbon(t,regi,entySe,entyFe,emiMkt)
  =e=
    v37_FeedstocksCarbon(t,regi,entySe,entyFe,emiMkt)
  * s37_plasticsShare
;

*' calculate plastic waste generation, shifted by mean lifetime of plastic
*' products shift by 2 time steps when we have 5-year steps and 1 when we have
*' 10-year steps allocate averge of 2055 and 2060 to 2070, unless `cm_wastelag`
*' is `NO`, in which case waste is incurred in the same period plastics are
*' produced
q37_plasticWaste(ttot,regi,sefe(entySe,entyFe),emiMkt)$(
                         entyFE2sector2emiMkt_NonEn(entyFe,"indst",emiMkt)
                     AND ttot.val ge max(2015, cm_startyear)               ) ..
  v37_plasticWaste(ttot,regi,entySe,entyFe,emiMkt)
  =e=
    !! prompt waste
    v37_plasticsCarbon(ttot,regi,entySe,entyFe,emiMkt)$( NOT %cm_wastelag% )
    !! lagged waste
  + ( v37_plasticsCarbon(ttot-2,regi,entySe,entyFe,emiMkt)$( ttot.val lt 2070 )
    + ( ( v37_plasticsCarbon(ttot-2,regi,entySe,entyFe,emiMkt)
        + v37_plasticsCarbon(ttot-1,regi,entySe,entyFe,emiMkt)
        )
      / 2
      )$( ttot.val eq 2070 )
    + v37_plasticsCarbon(ttot-1,regi,entySe,entyFe,emiMkt)$( ttot.val gt 2070 )
    )$( %cm_wastelag% )
;

*' emissions from plastics incineration as a share of total plastic waste,
*' discounted by captured amount
q37_incinerationEmi(t,regi,sefe(entySe,entyFe),emiMkt)$(
                         entyFE2sector2emiMkt_NonEn(entyFe,"indst",emiMkt) ) ..
  vm_incinerationEmi(t,regi,entySe,entyFe,emiMkt)
  =e=
    v37_plasticWaste(t,regi,entySe,entyFe,emiMkt)
  * pm_incinerationRate(t,regi)
  * (1 - v37_regionalWasteIncinerationCCSshare(t,regi))
;

q37_incinerationCCS(t,regi,sefe(entySe,entyFe),emiMkt)$(
                         entyFE2sector2emiMkt_NonEn(entyFe,"indst",emiMkt) ) ..
  vm_incinerationCCS(t,regi,entySe,entyFe,emiMkt)
  =e=
    v37_plasticWaste(t,regi,entySe,entyFe,emiMkt)
  * pm_incinerationRate(t,regi)
  * v37_regionalWasteIncinerationCCSshare(t,regi)
;

*' calculate carbon contained in non-incinerated plastics
*' this is used in emissions accounting to subtract the carbon that gets
*' sequestered in plastic products
q37_nonIncineratedPlastics(t,regi,sefe(entySe,entyFe),emiMkt)$(
                         entyFE2sector2emiMkt_NonEn(entyFe,"indst",emiMkt) ) ..
  vm_nonIncineratedPlastics(t,regi,entySe,entyFe,emiMkt)
  =e=
    v37_plasticWaste(t,regi,entySe,entyFe,emiMkt)
  * (1 - pm_incinerationRate(t,regi))
  ;

*' calculate flow of carbon contained in chemical feedstock with unknown fate
*' it is assumed that this carbon is re-emitted in the same timestep if cm_feedstockEmiUnknownFate is enabled (=on)
q37_feedstockEmiUnknownFate(t,regi,sefe(entySe,entyFe),emiMkt)$(
                         entyFE2sector2emiMkt_NonEn(entyFe,"indst",emiMkt) ) ..
  vm_feedstockEmiUnknownFate(t,regi,entySe,entyFe,emiMkt)
  =e=
$ifthen.cm_feedstockEmiUnknownFate not "%cm_feedstockEmiUnknownFate%" == "off"
  (
    v37_FeedstocksCarbon(t,regi,entySe,entyFe,emiMkt)
  * (1 - s37_plasticsShare)
  )
$else.cm_feedstockEmiUnknownFate
  0
$endIf.cm_feedstockEmiUnknownFate
;

*** ---------------------------------------------------------------------------
***        2. Process-Based
*** ---------------------------------------------------------------------------

***------------------------------------------------------
*' Material input to production
***------------------------------------------------------
q37_demMatPrc(t,regi,mat)$( matIn(mat) ) ..
    v37_matFlow(t,regi,mat)
  =e=
    sum(tePrc2matIn(tePrc,opmoPrc,mat),
      p37_specMatDem(mat,tePrc,opmoPrc)
      *
      vm_outflowPrc(t,regi,tePrc,opmoPrc)
    )
;

***------------------------------------------------------
*' Material cost
***------------------------------------------------------
q37_costMat(t,regi) ..
    vm_costMatPrc(t,regi)
  =e=
    sum(mat,
      p37_priceMat(mat)
      *
      v37_matFlow(t,regi,mat))
;

***------------------------------------------------------
*' Output material production
***------------------------------------------------------
q37_prodMat(t,regi,mat)$( matOut(mat) ) ..
    v37_matFlow(t,regi,mat)
  =e=
    sum(tePrc2matOut(tePrc,opmoPrc,mat),
      vm_outflowPrc(t,regi,tePrc,opmoPrc)
    )
;

***------------------------------------------------------
*' Hand-over to CES
***------------------------------------------------------
q37_mat2ue(t,regi,mat,in)$( ppfUePrc(in) ) ..
    (vm_cesIO(t,regi,in)
    + pm_cesdata(t,regi,in,"offset_quantity"))
    * p37_ue_share(mat,in)
  =e=
    sum(mat2ue(mat,in),
      p37_mat2ue(mat,in)
      *
      v37_matFlow(t,regi,mat)
    )
;

***------------------------------------------------------
*' Definition of capacity constraints
***------------------------------------------------------
q37_limitCapMat(t,regi,tePrc) ..
    sum(tePrc2opmoPrc(tePrc,opmoPrc),
      vm_outflowPrc(t,regi,tePrc,opmoPrc)
    )
    =l=
    sum(teMat2rlf(tePrc,rlf),
      vm_capFac(t,regi,tePrc)
    * vm_cap(t,regi,tePrc,rlf)
    )
;

***------------------------------------------------------
*' Emission from process based industry sector (pre CC)
***------------------------------------------------------
q37_emiPrc(t,regi,entyFe,tePrc,opmoPrc) ..
    v37_emiPrc(t,regi,entyFe,tePrc,opmoPrc)
  =e=
    pm_specFeDem(t,regi,entyFe,tePrc,opmoPrc)
    *
    sum(se2fe(entySeFos,entyFe,te),
      pm_emifac(t,regi,entySeFos,entyFe,te,"co2"))
    *
    vm_outflowPrc(t,regi,tePrc,opmoPrc)
;


***------------------------------------------------------
*' Carbon capture processes can only capture as much co2 as the base process and the CCS process combined emit
***------------------------------------------------------
q37_limitOutflowCCPrc(t,regi,teCCPrc) ..
    sum(tePrc2opmoPrc(teCCPrc,opmoCCPrc),
      vm_outflowPrc(t,regi,teCCPrc,opmoCCPrc)
    )
  =e=
    p37_captureRate(teCCPrc)
    *
    sum((entyFe,tePrc2teCCPrc(tePrc,opmoPrc,teCCPrc,opmoCCPrc)),
      v37_shareWithCC(t,regi,tePrc,opmoPrc)
      *
      v37_emiPrc(t,regi,entyFe,tePrc,opmoPrc)
    )
    +
    p37_selfCaptureRate(teCCPrc)
    *
    sum((entyFe,tePrc2opmoPrc(teCCPrc,opmoCCPrc)),
      v37_emiPrc(t,regi,entyFe,teCCPrc,opmoCCPrc))
;

***------------------------------------------------------
*' Emission captured from process based industry sector
***------------------------------------------------------
q37_emiCCPrc(t,regi,emiInd37)$(
                sum(secInd37Prc,secInd37_2_emiInd37(secInd37Prc,emiInd37)) ) ..
    vm_emiIndCCS(t,regi,emiInd37)
  =e=
    sum((secInd37_2_emiInd37(secInd37Prc,emiInd37),
         secInd37_tePrc(secInd37Prc,tePrc),
         tePrc2teCCPrc(tePrc,opmoPrc,teCCPrc,opmoCCPrc)),
      vm_outflowPrc(t,regi,teCCPrc,opmoCCPrc)
    )
;

*' @stop
*** EOF ./modules/37_industry/subsectors/equations.gms
