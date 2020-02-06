*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/fixed_shares/equations.gms

*' Industry final energy balance
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
      vm_cesIO(ttot,regi,in)
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
*' $$C_j = E_{\text{base},j} p \sum_{i = 1}^{n} \left(q_{n,j} - q_{i,j}\right)$$
*' with $E_\text{base}$ the baseline emissions, $p$ the price step, and $q_i$ 
*' the abatement fraction at step $i$ on the MAC.
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

*** EOF ./modules/37_industry/fixed_shares/equations.gms

