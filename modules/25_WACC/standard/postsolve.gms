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
p25_waccCostO_tewacc(t, regi, tewacc) =
  sum((t2)$((t.val - t2.val <= pm_lifetime_max(regi,tewacc)) and (t2.val <= t.val)),  
      (vm_costInvTeDir.l(t2, regi, tewacc)         
       + vm_costInvTeAdj.l(t2, regi, tewacc)$teAdj(tewacc)  
      ) * p25_techwacc(t2, regi, tewacc) * pm_ts(t2)/2);

p25_techwaccCostO(t, regi) = sum(tewacc, p25_waccCostO_tewacc(t, regi, tewacc));       

***This calculates WACC costs only for technologies coming from previous periods
p25_waccCost1_tewacc(t, regi, tewacc) =
  sum((t2)$((t.val - t2.val <= pm_lifetime_max(regi,tewacc)) and (t2.val < t.val)),  
      (vm_costInvTeDir.l(t2, regi, tewacc)         
       + vm_costInvTeAdj.l(t2, regi, tewacc)$teAdj(tewacc)  
      ) * p25_techwacc(t2, regi, tewacc) * pm_ts(t2)/2);

p25_techwaccCost1(t, regi) = sum(tewacc, p25_waccCost1_tewacc(t, regi, tewacc));       

p25_counwaccCostO(t, regi)=
    sum((t2, in)$(
           (t2.val <= t.val)
        and ((1 - pm_delta_kap(regi,in)) ** (t.val - t2.val)) > 0.1
      ),
      vm_invMacro.l(t2, regi, in) * p25_counwacc(t2, regi) * pm_ts(t2) /2
    );

*** EOF ./modules/25_WACC/standard/postsolve.gms



