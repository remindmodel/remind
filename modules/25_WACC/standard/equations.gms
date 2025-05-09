*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de 
*** SOF ./modules/25_WACC/standard/equations.gms

***--------------------------------------------------------------------------- 
*  WACC implementation on capital costs
***---------------------------------------------------------------------------
***This equation calculates the weighted average cost of capital (WACC) costs for new and existing technologies while ensuring that each past investment is assigned the correct WACC from the year
q25_waccCost(t, regi)$(t.val > 2005)..
  vm_waccCost(t, regi)
  =e=
  sum((tewacc, t2)$(t.val - t2.val <= p_lifetime_max(regi,tewacc)),  
      (vm_costInvTeDir(t2, regi, tewacc)          
       + vm_costInvTeAdj(t2, regi, tewacc)$teAdj(tewacc)
      ) * p25_wacc(t2, regi, tewacc)              
  ) - p25_waccCostO(t, regi);  