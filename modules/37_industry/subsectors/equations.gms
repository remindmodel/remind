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
  =e=
  sum((fe2ppfEN(entyFE,ppfen_industry_dyn37(in)),
       secInd37_emiMkt(secInd37,emiMkt),secInd37_2_pf(secInd37,in)),
    vm_cesIO(ttot,regi,in)
  + pm_cesdata(ttot,regi,in,"offset_quantity")
  )
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
    sum((secInd37_2_pf(secInd37,ppfen_industry_dyn37(in)),
         fe2ppfen(entyFECC37(entyFE),in)),
      vm_cesIO(ttot,regi,in)
    * sum(se2fe(entySEfos,entyFE,te),
        pm_emifac(ttot,regi,entySEfos,entyFE,te,"co2")
      )
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

*** EOF ./modules/37_industry/subsectors/equations.gms
