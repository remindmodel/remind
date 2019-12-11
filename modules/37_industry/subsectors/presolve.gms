*** SOF ./modules/37_industry/subsectors/presolve.gms

*' The process emissions from cement production are calculated using a fixed
*' CO2-to-clinker ratio (0.5262 kg CO2/kg clinker), region-specific 
*' clinker-to-cement ratios, and the cement production from the production 
*' function.
*' Last iteration's cement production value is used, since the MAC mechanism is
*' outside of the optimisation loop.
vm_macBaseInd.fx(ttot,regi,"co2cement_process","cement")$( ttot.val ge 2005 ) 
  = s37_clinker_process_CO2
  * p37_clinker_cement_ratio(ttot,regi)
  * vm_cesIO.l(ttot,regi,"ue_cement")
  / sm_c_2_co2;
*** EOF ./modules/37_industry/subsectors/presolve.gms
