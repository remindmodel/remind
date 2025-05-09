*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/25_WACC/standard/postsolve.gms

***---------------------------------------------------------------------------
*'  Calculation of total WACC costs
***---------------------------------------------------------------------------
***  p25_waccCostO(t, regi) =
***  sum((tewacc, t2)$(t.val - t2.val <= p_lifetime_max(regi,tewacc)),  
***      (vm_costInvTeDir.l(t2, regi, tewacc)         
***       + vm_costInvTeAdj.l(t2, regi, tewacc)$teAdj(tewacc)  
***      ) * p25_wacc(t2, regi, tewacc)              
***  ) ;        

p25_waccCostO_tewacc(t, regi, tewacc) =
  sum((t2)$((t.val - t2.val <= p_lifetime_max(regi,tewacc))),  
      (vm_costInvTeDir.l(t2, regi, tewacc)         
       + vm_costInvTeAdj.l(t2, regi, tewacc)$teAdj(tewacc)  
      ) * p25_wacc(t2, regi, tewacc)              
  );

p25_waccCostO(t, regi) = sum(tewacc, p25_waccCostO_tewacc(t, regi, tewacc));       

*** EOF ./modules/25_WACC/standard/postsolve.gms


p25_waccCost1_tewacc(t, regi, tewacc) =
  sum((t2)$((t.val - t2.val <= p_lifetime_max(regi,tewacc)) and (t2.val < t.val)),  
      (vm_costInvTeDir.l(t2, regi, tewacc)         
       + vm_costInvTeAdj.l(t2, regi, tewacc)$teAdj(tewacc)  
      ) * p25_wacc(t2, regi, tewacc)              
  );

p25_waccCost1(t, regi) = sum(tewacc, p25_waccCost1_tewacc(t, regi, tewacc));       

*** EOF ./modules/25_WACC/standard/postsolve.gms

