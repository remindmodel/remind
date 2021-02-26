*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/fixed_shares/equations.gms

***---------------------------------------------------------------------------
*'  Industry Final Energy Balance
***---------------------------------------------------------------------------
q37_demFeIndst(ttot,regi,entyFe,emiMkt)$((ttot.val ge cm_startyear) AND (entyFe2Sector(entyFe,"indst"))) .. 
  sum((entySe,te)$(se2fe(entySe,entyFe,te)), 
    vm_demFeSector(ttot,regi,entySe,entyFe,"indst",emiMkt)
  ) 
  =e=
  sum(in$(fe2ppfEn(entyFe,in) and ppfen_industry_dyn37(in)),
      ( vm_cesIO(ttot,regi,in)
        + pm_cesdata(ttot,regi,in,"offset_quantity")
      ) * sum(secInd37$secInd37_emiMkt(secInd37,emiMkt), p37_shIndFE(regi,in,secInd37))
  ) 
;

*' Baseline (emitted and captured) emissions by final energy carrier and 
*' industry subsector are calculated from final energy use in industry, the 
*' subsectors' shares in that final energy carriers use, and the emission 
*' factor the final energy carrier. 
q37_macBaseInd(ttot,regi,entyFE,secInd37)$( ttot.val ge cm_startyear ) .. 
  vm_macBaseInd(ttot,regi,entyFE,secInd37)
  =e=
    sum((fe2ppfEn(entyFE,in),ces_industry_dyn37("enhi",in)),
      ( vm_cesIO(ttot,regi,in) + pm_cesdata(ttot,regi,in,"offset_quantity") )
    * p37_shIndFE(regi,in,secInd37)
    )
  * p37_fctEmi(entyFE)
;

*' The maximum abatable emissions of a given type (industry subsector, fuel or
*' process) are calculated from the baseline emissions and the possible 
*' abatement level (depending on the carbon price of the previous iteration). 
q37_emiIndCCSmax(ttot,regi,emiInd37)$( ttot.val ge cm_startyear ) .. 
  v37_emiIndCCSmax(ttot,regi,emiInd37)
  =e=
    sum(emiMac2mac(emiInd37,macInd37),
      ( sum((secInd37_2_emiInd37(secInd37,emiInd37),entyFE),
          vm_macBaseInd(ttot,regi,entyFE,secInd37)
        )$( NOT sameas(emiInd37,"co2cement_process") )
      + (
          vm_macBaseInd(ttot,regi,"co2cement_process","cement")
        )$( sameas(emiInd37,"co2cement_process") )
      )
    * pm_macSwitch(macInd37)
    * pm_macAbatLev(ttot,regi,macInd37)
  )
;

*' Industry CCS is limited to below the maximum abatable emissions. 
q37_IndCCS(ttot,regi,emiInd37)$( ttot.val ge cm_startyear ) .. 
  vm_emiIndCCS(ttot,regi,emiInd37)
  =l=
  v37_emiIndCCSmax(ttot,regi,emiInd37)
;

*' The CCS capture rates of cement fuel and process emissions are identical, 
*' as they are captured in the same installation. 
q37_cementCCS(ttot,regi)$( ttot.val ge cm_startyear
                          AND pm_macSwitch("co2cement")
                          AND pm_macAbatLev(ttot,regi,"co2cement") ) .. 
    vm_emiIndCCS(ttot,regi,"co2cement")
  * v37_emiIndCCSmax(ttot,regi,"co2cement_process")
  =e=
    vm_emiIndCCS(ttot,regi,"co2cement_process")
  * v37_emiIndCCSmax(ttot,regi,"co2cement")
;

*' Industry CCS costs (by subsector) are equal to the integral below the MAC 
*' cost curve.
*' For the calculation, consider this figure:
*' ![MAC curve example](MAC_costs.png)
*' To make the calculations involving MAC curves leaner, they are discretised 
*' into 5 $/tC steps (parameter `sm_dmac`) and transformed into step-wise 
*' curves.  The parameter `pm_macStep` holds the current step on the MAC curve
*' the model is on (given the CO~2~ price of the last iteration), and 
*' `pm_macAbat` holds the abatement level (as a fraction) on that step.  The 
*' emission abatement equals the area under the MAC curve (turqoise area in the 
*' figure).  To calculate it, `pm_macStep` is multiplied by `pm_macAbat` (the 
*' horizontal and vertical lines enclosing the coloured rectangle in the 
*' figure).  The `sum(steps$( ord(steps) eq pm_macStep ... )` part simply 
*' selects the right step within the MAC curve.  From this product (rectangle),
*' the area above the MAC curve (pink) is subtractad.  To calculate it, the 
*' abatement level at each MAC step up to and including the current step is 
*' summed up.  The area is subdivided into `pm_macStep` rectangles of height 
*' `1 sm_dmac` and width `pm_macAbat(steps)` (which is zero for the first $n$ 
*' steps at which price level no abatement is available). 
*' Multiplying the area under the curve with the step width `sm_dmac` and the 
*' baseline emissions (before mitigation) converts the units to $/tC and GtC.
*'
*' Example:  The carbon price is 43.6 $/tCO~2~, which translates to step 32 on 
*' the discrete MAC curve (43.6 $/tCO~2~ * (44/12 tCO~2~/tC) / (5 $/step)). 
*' The calculation then is:
*' ```
*' vm_emiIndCCS = 
*'     0.001
*'   * vm_macBaseInd
*'   * sm_dmac
*'   * ( 32 * 0.3
*'     - ( 15 * 0
*'       + 14 * 0.2
*'       +  3 * 0.3
*'       )
*'     )
*'

q37_IndCCSCost(ttot,regi,emiInd37)$( ttot.val ge cm_startyear ) .. 
  vm_IndCCSCost(ttot,regi,emiInd37)
  =e=
    1e-3
  * pm_macSwitch(emiInd37)
  * ( sum((enty,secInd37_2_emiInd37(secInd37,emiInd37)),
        vm_macBaseInd(ttot,regi,enty,secInd37)
      )$( NOT sameas(emiInd37,"co2cement_process") )
    + (
        vm_macBaseInd(ttot,regi,"co2cement_process","cement")
      )$( sameas(emiInd37,"co2cement_process") )
    )
  * sm_dmac
  * sum(emiMac2mac(emiInd37,enty),
      ( pm_macStep(ttot,regi,emiInd37)
      * sum(steps$( ord(steps) eq pm_macStep(ttot,regi,emiInd37) ),
          pm_macAbat(ttot,regi,enty,steps)
        )
      )
    - sum(steps$( ord(steps) le pm_macStep(ttot,regi,emiInd37) ),
        pm_macAbat(ttot,regi,enty,steps)
      )
    )
;

***---------------------------------------------------------------------------
*'  Additional hydrogen cost at low penetration level
***---------------------------------------------------------------------------
q37_costAddTeInv(t,regi)..
  vm_costAddTeInv(t,regi,"tdh2s","indst")
  =e=
  ( 1 /(
        1 + (3**v37_costExponent(t,regi))
      )
  ) * (
    s37_costAddH2Inv * 8.76 
    * ( sum(emiMkt, vm_demFeSector(t,regi,"seh2","feh2s","indst",emiMkt)))
  )
  + (v37_expSlack(t,regi)*1e-8)
;

*' Logistic function exponent for additional hydrogen low penetration cost equation
q37_auxCostAddTeInv(t,regi)..
  v37_costExponent(t,regi)
  =e=
  ( (10/(s37_costDecayEnd-s37_costDecayStart)) * ( (v37_H2share(t,regi)+1e-7) -  ((s37_costDecayEnd+s37_costDecayStart)/2) ) ) - v37_expSlack(t,regi)
  ;

*' Hydrogen fe share in industry gases use (natural gas + hydrogen)
q37_H2Share(t,regi)..
  v37_H2share(t,regi) 
  * sum(emiMkt, 
      sum(se2fe(entySe,entyFe,te)$(SAMEAS(entyFe,"feh2s") OR SAMEAS(entyFe,"fegas")),   
        vm_demFeSector(t,regi,entySe,entyFe,"indst",emiMkt)))
  =e=
  sum(emiMkt, 
      sum(se2fe(entySe,entyFe,te)$SAMEAS(entyFe,"feh2s"),   
        vm_demFeSector(t,regi,entySe,entyFe,"indst",emiMkt))) 
;

*** carbonaceous Fe share in industry (solids, gases, liquids)
*** needed to provide a lower bound for ensuring feedstock supply
q37_CFuelShare(t,regi)..
  v37_CFuelshare(t,regi) 
  * sum(emiMkt, 
      sum(se2fe(entySe,entyFe,te)$( entyFe37(entyFe)),   
        vm_demFeSector(t,regi,entySe,entyFe,"indst",emiMkt)))
  =e=
  sum(emiMkt, 
      sum(se2fe(entySe,entyFe,te)$(SAMEAS(entyFe,"fesos") OR SAMEAS(entyFe,"fegas")  OR SAMEAS(entyFe,"fehos") ),   
        vm_demFeSector(t,regi,entySe,entyFe,"indst",emiMkt))) 
;

*** EOF ./modules/37_industry/fixed_shares/equations.gms

