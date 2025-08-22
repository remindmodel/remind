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
***q25_waccCost(t, regi)$(t.val > 2005)..
***  vm_waccCost(t, regi)
***  =e=
***  sum((t2, tewacc)$(t.val - t2.val <= p_lifetime_max(regi,tewacc)),  
***      (vm_costInvTeDir(t2, regi, tewacc)          
***       + vm_costInvTeAdj(t2, regi, tewacc)$teAdj(tewacc)
***      ) * p25_wacc(t2, regi, tewacc)              
***  ) - p25_waccCostO(t, regi);  


***0.5 * (p_lifetime_max(regi, tewacc) + p_discountedLifetime(tewacc))

q25_techwaccCost(t, regi)$(t.val > 2005)..
v25_techwaccCost(t, regi)
=e=
sum((t2, tewacc)$((t2.val <= t.val) and (t.val - t2.val <= p_lifetime_max(regi,tewacc))),  
    (vm_costInvTeDir(t2, regi, tewacc)          
     + vm_costInvTeAdj(t2, regi, tewacc)$teAdj(tewacc)
    ) * p25_techwacc(t2, regi, tewacc)              
) - p25_techwaccCostO(t, regi);

q25_invwaccCost(t, regi)$(t.val > 2005) ..
    v25_invWaccCost(t, regi)
    =e=
    sum((t2, in)$(
           (t2.val <= t.val)
        and ((1 - pm_delta_kap(regi,in)) ** (t.val - t2.val)) > 0.01
      ),
      vm_invMacro(t2, regi, in) * p25_invwacc(t2, regi)
    )
    - p25_invwaccCost0(t, regi);

q25_totwaccCost(t, regi)$(t.val > 2005)..
vm_waccCost(t, regi)
=e=
v25_techwaccCost(t, regi) + v25_invWaccCost(t, regi) ;

