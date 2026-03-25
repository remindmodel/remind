*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/40_techpol/NPi2025/equations.gms

*' @equations

*------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------
***                                Capacity Targets
*------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------

***am minimum targets for certain technologies
q40_ElecBioBound(t,regi)$(t.val gt 2025)..
    sum(te2rlf(te,rlf)$(sameas(te,"biochp") OR sameas(te,"bioigcc") OR sameas(te,"bioigccc")), vm_cap(t,regi,te,rlf))
      =g= p40_ElecBioBound(t,regi) * 0.001
;	 

*** windoffshore-todo: as long as there is a "wind" target, it is for the sum windon+windoff
q40_windBound(t,regi)$(t.val gt 2025 AND p40_TechBound(t,regi,"wind") gt 0)..
  sum(teWind, vm_cap(t,regi,teWind,"1")) 
    =g= p40_TechBound(t,regi,"wind") * 0.001
;

*------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------
***                                Renewable Share Targets
*------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------


*** Minimum shares of renewable energy should be met in target year based on renewable energy share targets of NPI scenario.
*** Constraint currently supports the following target types (RenShareTargetType):
*** 1.  RenElec                     "renewable share in secondary energy electricity"
*** 2.  NonBioRenElec               "non-biomass renewable share in secondary energy electricity"
*** 3.  NonFossilElec               "non-fossil share in secondary energy electricity"
*** 4.  RenFE                       "renewable share in total final energy"
*** Note that for 4. we approximately use the renewable share in total secondary energy instead of final energy to reduce the complexity of the implementation.
*** Moreover, we count hydrogen as a renewable source by assumption since most hydrogen in REMIND is of renewable origin.
q40_RenShare(t,regi,RenShareTargetType)$(p40_RenShareTargets(t,regi,RenShareTargetType)
                                          AND cm_RenShareTargets eq 1)..
  sum(TargetType2ShareEnty(RenShareTargetType,enty),
    sum(TargetType2TotalEnty(RenShareTargetType,enty2),
*** Renewable SE production of output SE carrier (enty2) as main product
      sum(en2en(enty,enty2,te),
        vm_prodSe(t,regi,enty,enty2,te)
      )
      +
*** Renewable SE production of output SE carrier (enty2) as second product
      sum(pc2te(enty,enty3,te,enty2),
        max(0, pm_prodCouple(regi,enty,enty3,te,enty2))
        * vm_prodSe(t,regi,enty,enty3,te)
      ) 
    )
  )
  =g=
  p40_RenShareTargets(t,regi,RenShareTargetType)
  * sum(TargetType2TotalEnty(RenShareTargetType,enty2),
*** Total SE production of SE output SE carrier (enty2) as main product
      sum(en2en(enty,enty2,te),
        vm_prodSe(t,regi,enty,enty2,te)
      )
      +
*** Total SE production of SE output SE carrier (enty2) as second product
      sum(pc2te(enty,enty3,te,enty2),
        max(0, pm_prodCouple(regi,enty,enty3,te,enty2)) 
        * vm_prodSe(t,regi,enty,enty3,te)
      )
    )
  ;

*' @stop

*** EOF ./modules/40_techpol/NPi2025/equations.gms
