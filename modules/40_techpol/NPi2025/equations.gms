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
*** Constraint for secondary energy (SE) renewable shares:
*** 1.  RenElec                     "renewable share in secondary energy electricity"
*** 2.  NonBioRenElec               "non-biomass renewable share in secondary energy electricity"
*** 3.  NonFossilElec               "non-fossil share in secondary energy electricity"
*** 4.  SolarWindElec               "solar and wind share in secondary energy electricity"
*** 5.  RenFE                       "renewable share in total final energy"
*** Note that we count hydrogen as a renewable source by assumption since most hydrogen in REMIND is of renewable origin.
q40_RenShare_SE(t,regi,RenShareTargetType)$(p40_RenShareTargets(t,regi,RenShareTargetType)
                                          AND cm_RenShareTargets eq 1
                                            AND NOT sameas(RenShareTargetType,"RenFE"))..
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

*** Renewable FE share including ambient heat from heat pumps
*** This equation includes ambient heat used by heat pump assuming a COP of 3, i.e. 2/3 of the output energy come from ambient heat.
*** This is accounted by adding 2 * electricity demand of buildings heat pumps (feelhpb).  
*** Ambient heat is added to numerator and denominator as it is considered renewable energy. 
q40_RenShare_FE(t,regi,RenShareTargetType)$(p40_RenShareTargets(t,regi,RenShareTargetType)
                                             AND cm_RenShareTargets eq 1
                                             AND sameas(RenShareTargetType,"RenFE"))..
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
  +
*** Ambient heat from heat pumps included as renewable FE contribution 
  2 * vm_cesIO(t,regi,"feelhpb")
  =g=
  p40_RenShareTargets(t,regi,RenShareTargetType)
  * ( sum(TargetType2TotalEnty(RenShareTargetType,enty2),
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
  )
      +
*** Ambient heat from heat pumps included in total FE
    2 * vm_cesIO(t,regi,"feelhpb") 
  ;

*' @stop

*** EOF ./modules/40_techpol/NPi2025/equations.gms
