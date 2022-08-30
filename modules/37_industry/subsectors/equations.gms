*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/subsectors/equations.gms

*' Industry final energy balance
q37_demFeIndst(ttot,regi,entyFe,emiMkt)$(    ttot.val ge cm_startyear
                                         AND entyFe2Sector(entyFe,"indst") ) ..
  sum(se2fe(entySE,entyFE,te),
    vm_demFEsector(ttot,regi,entySE,entyFE,"indst",emiMkt)
  )
*** substract chemical feedstocks which are supplied by vm_demFENonEnergySector (see q37_demFeFeedstockChemIndst)
*  - sum(se2fe(entySE,entyFE,te),
*    vm_demFENonEnergySector(ttot,regi,entySE,entyFE,"indst",emiMkt)
*    )
  =e=
  sum((fe2ppfEN(entyFE,ppfen_industry_dyn37(in)),
       secInd37_emiMkt(secInd37,emiMkt),secInd37_2_pf(secInd37,in)),
    vm_cesIO(ttot,regi,in)
  + pm_cesdata(ttot,regi,in,"offset_quantity")
  )

*** substract chemical feedstocks which are supplied by vm_demFENonEnergySector (see q37_demFeFeedstockChemIndst)
*  -   sum((fe2ppfEN(entyFE,ppfen_industry_dyn37(in)),              
*       secInd37_emiMkt(secInd37,emiMkt),secInd37_2_pf(secInd37,in_chemicals_37(in))), 
       
*      ( vm_cesIO(ttot,regi,in) 
*      + pm_cesdata(ttot,regi,in,"offset_quantity")
*      )
*      * p37_chemicals_feedstock_share(ttot,regi)
*      )
;

*' Thermodynamic limits on subsector energy demand
q37_energy_limits(ttot,regi,industry_ue_calibration_target_dyn37(out))$(
                                      ttot.val gt 2020
				  AND p37_energy_limit_slope(ttot,regi,out) 
!! deactivate energy limits for calibration, since they would be essentially
!! random
$ifthen.calibration "%CES_parameters%" == "calibrate"   !! CES_parameters
                                  AND NO
$endif.calibration
				                                            ) ..
  sum(ces_eff_target_dyn37(out,in), vm_cesIO(ttot,regi,in))
  =g=
    vm_cesIO(ttot,regi,out)
  * p37_energy_limit_slope(ttot,regi,out)
;

*' Limit the share of secondary steel to historic values, fading to 90 % in 2050
q37_limit_secondary_steel_share(ttot,regi)$(
         ttot.val ge cm_startyear
$ifthen.fixed_production "%cm_import_EU%" == "bal"   !! cm_import_EU
         !! do not limit steel production shares for fixed production
     AND p37_industry_quantity_targets(ttot,regi,"ue_steel_secondary") eq 0
$endif.fixed_production
                                                                            ) ..
  vm_cesIO(ttot,regi,"ue_steel_secondary")
  =l=
    ( vm_cesIO(ttot,regi,"ue_steel_primary")
    + vm_cesIO(ttot,regi,"ue_steel_secondary")
    )
  * p37_steel_secondary_max_share(ttot,regi)
;

*' Compute gross industry emissions before CCS by multiplying sub-sector energy
*' use with fuel-specific emission factors.
q37_macBaseInd(ttot,regi,entyFE,secInd37)$( ttot.val ge cm_startyear ) ..
  vm_macBaseInd(ttot,regi,entyFE,secInd37)
  =e=
    sum((secInd37_2_pf(secInd37,ppfen_industry_dyn37(in)),fe2ppfen(entyFE,in))$(entyFeCC37(entyFe)),
      (vm_cesIO(ttot,regi,in)
      - p37_chemicals_feedstock_share(ttot,regi)
      * vm_cesIO(ttot,regi,in)$(in_chemicals_37(in)))
    * sum((entySe,te)$(se2fe(entySe,entyFe,te) and entySeFos(entySe)),
        pm_emifac(ttot,regi,entySe,entyFe,te,"co2"))
        )
;

*' Compute maximum possible CCS level in industry sub-sectors given the current
*' CO2 price.
q37_emiIndCCSmax(ttot,regi,emiInd37)$( ttot.val ge cm_startyear ) ..
  v37_emiIndCCSmax(ttot,regi,emiInd37)
  =e=
    !! map sub-sector emissions to sub-sector MACs
    !! otherInd has no CCS, therefore no MAC, cement has both fuel and process
    !! emissions under the same MAC
    sum(emiMac2mac(emiInd37,macInd37),
      !! add cement process emissions, which are calculated in core/preloop
      !! from a econometric fit and might not correspond to energy use (FIXME)
      ( sum((secInd37_2_emiINd37(secInd37,emiInd37),entyFE),
          vm_macBaseInd(ttot,regi,entyFE,secInd37)
        )$( NOT sameas(emiInd37,"co2cement_process") )
      + ( vm_macBaseInd(ttot,regi,"co2cement_process","cement")
        )$( sameas(emiInd37,"co2cement_process") )
      )
    * pm_macSwitch(macInd37)              !! sub-sector CCS available or not
    * pm_macAbatLev(ttot,regi,macInd37)   !! abatement level at current price
  )
;

*' Limit industry CCS to maximum possible CCS level.
q37_IndCCS(ttot,regi,emiInd37)$( ttot.val ge cm_startyear ) ..
  vm_emiIndCCS(ttot,regi,emiInd37)
  =l=
  v37_emiIndCCSmax(ttot,regi,emiInd37)
;

*' Fix cement fuel and cement process emissions to the same abatement level.
q37_cementCCS(ttot,regi)$(    ttot.val ge cm_startyear
                          AND pm_macswitch("co2cement")
                          AND pm_macAbatLev(ttot,regi,"co2cement") ) ..
    vm_emiIndCCS(ttot,regi,"co2cement")
  * v37_emiIndCCSmax(ttot,regi,"co2cement_process")
  =e=
    vm_emiIndCCS(ttot,regi,"co2cement_process")
  * v37_emiIndCCSmax(ttot,regi,"co2cement")
;

*' Calculate industry CCS costs.
q37_IndCCSCost(ttot,regi,emiInd37)$( ttot.val ge cm_startyear ) ..
  vm_IndCCSCost(ttot,regi,emiInd37)
  =e=
    1e-3
  * pm_macSwitch(emiInd37)
  * ( sum((enty,secInd37_2_emiInd37(secInd37,emiInd37)),
        vm_macBaseInd(ttot,regi,enty,secInd37)
      )$( NOT sameas(emiInd37,"co2cement_process") )
    + ( vm_macBaseInd(ttot,regi,"co2cement_process","cement")
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


***---------------------------------------------------------------------------
*'  CES markup cost to represent sector-specific demand-side transformation cost in industry
***---------------------------------------------------------------------------
q37_costCESmarkup(t,regi,in)$(ppfen_industry_dyn37(in))..
  vm_costCESMkup(t,regi,in)
  =e=
    p37_CESMkup(t,regi,in)
  * (vm_cesIO(t,regi,in) + pm_cesdata(t,regi,in,"offset_quantity"))
;

***--------------------------------------------------------------------------
*'  Feedstock balances
***--------------------------------------------------------------------------

* lower bound on feso/feli/fega in chemicals FE input for feedstocks
q37_chemicals_feedstocks_limit(t,regi)$( t.val ge cm_startyear ) .. 
  sum(in_chemicals_37(in), vm_cesIO(t,regi,in))
  =g=
    sum(ces_eff_target_dyn37("ue_chemicals",in), vm_cesIO(t,regi,in))
  * p37_chemicals_feedstock_share(t,regi)
;

*Flow of non-energy feedstocks. It is used for emissions accounting 
q37_demFeFeedstockChemIndst(ttot,regi,entyFe,emiMkt)$(    ttot.val ge cm_startyear 
                                                      AND entyFe2sector2emiMkt_NonEn(entyFe,"indst",emiMkt) ) .. 
 
  sum(se2fe(entySE,entyFE,te),

    vm_demFENonEnergySector(ttot,regi,entySE,entyFE,"indst",emiMkt)
  )
  =e=
  sum((fe2ppfEN(entyFE,ppfen_industry_dyn37(in)),              
       secInd37_emiMkt(secInd37,emiMkt),secInd37_2_pf(secInd37,in_chemicals_37(in))), 

    ( vm_cesIO(ttot,regi,in) 
    + pm_cesdata(ttot,regi,in,"offset_quantity")
    )
    * p37_chemicals_feedstock_share(ttot,regi)

  )
;

* feedstocks flow has to be lower than total energy flow into industry
q37_feedstocksLimit(ttot,regi,entySE,entyFE,emiMkt)$(ttot.val ge cm_startyear 
                                                    AND sefe(entySE,entyFE) AND sector2emiMkt("indst",emiMkt) 
                                                    AND entyFe2Sector(entyFe,"indst") AND entyFeCC37(entyFe))..

  vm_demFESector(ttot,regi,entySE,entyFE,"indst",emiMkt)
  =g=
  vm_demFENonEnergySector(ttot,regi,entySE,entyFE,"indst",emiMkt)
  
;


*** calculate carbon contained in chemical feedstocks
q37_FeedstocksCarbon(ttot,regi,entySe,entyFe,emiMkt)$(    entyFe2sector2emiMkt_NonEn(entyFe,"indst",emiMkt)
                                                      AND entySe2entyFe(entySe,entyFe)  ) .. 
  vm_FeedstocksCarbon(ttot,regi,entySe,entyFe,emiMkt)
  =e=
  vm_demFENonEnergySector(ttot,regi,entySe,entyFe,"indst",emiMkt)
    * p37_FeedstockCarbonContent(ttot,regi,entyFe);
;


*** in baseline runs, all industrial feedstocks should come from fossil energy carriers, no biofuels or synfuels
q37_FossilFeedstock_Base(t,regi,entyFe,emiMkt)$(entyFe2sector2emiMkt_NonEn(entyFe,"indst",emiMkt)
                                              AND cm_emiscen eq 1)..
  sum(entySE,
    vm_demFENonEnergySector(t,regi,entySE,entyFE,"indst",emiMkt))
  =e=
  sum(entySE$(entySeFos(entySE)),
    vm_demFENonEnergySector(t,regi,entySE,entyFE,"indst",emiMkt))
;


*** EOF ./modules/37_industry/subsectors/equations.gms
