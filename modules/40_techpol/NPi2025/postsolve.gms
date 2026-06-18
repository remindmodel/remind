*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/40_techpol/NPi2025/postsolve.gms


*------------------------------------------------------------------------------------
***                   Renewable Share in Final Energy
*------------------------------------------------------------------------------------

*** Calculate the renewable FE share including ambient heat from heat pumps
*** This calculation uses the level values (.l) of variables after optimization
*** to check what the actual renewable share in FE is, including the contribution
*** from ambient heat in heat pump technologies.

p40_RenShare_FE(ttot,regi)$( ttot.val ge 2005 ) =
  ( sum(TargetType2ShareEnty("RenFE",enty),
      sum(TargetType2TotalEnty("RenFE",enty2),
*** Renewable SE production of output SE carrier (enty2) as main product
        sum(en2en(enty,enty2,te),
          vm_prodSe.l(ttot,regi,enty,enty2,te)
        )
        +
*** Renewable SE production of output SE carrier (enty2) as second product
        sum(pc2te(enty,enty3,te,enty2),
          max(0, pm_prodCouple(regi,enty,enty3,te,enty2))
          * vm_prodSe.l(ttot,regi,enty,enty3,te)
        )
      )
    )
    +
*** Ambient heat from heat pumps included as renewable FE contribution (added outside the loops to avoid double counting)
    2 * vm_cesIO.l(ttot,regi,"feelhpb")
  )
  /
  ( sum(TargetType2TotalEnty("RenFE",enty2),
*** Total SE production of SE output SE carrier (enty2) as main product
      sum(en2en(enty,enty2,te),
        vm_prodSe.l(ttot,regi,enty,enty2,te)
      )
      +
*** Total SE production of SE output SE carrier (enty2) as second product
      sum(pc2te(enty,enty3,te,enty2),
        max(0, pm_prodCouple(regi,enty,enty3,te,enty2)) 
        * vm_prodSe.l(ttot,regi,enty,enty3,te)
      )
    )
    +
*** Ambient heat from heat pumps included in total FE (added outside the loop to be consistent)
    2 * vm_cesIO.l(ttot,regi,"feelhpb")
  )
;


*** EOF ./modules/40_techpol/NPi2025/postsolve.gms
