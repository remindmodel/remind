*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/53_adaptation/ACCREU/equations.gms

*' @equations

$ifthen.cm_SLR %cm_SLR% == "on"
q53_adaptSLR(ttot,regi)$(ttot.val ge cm_startyear)..
   v53_protectSLR(ttot,regi) 
  =e=
   s53_effLim*p53_SLRadapt2(regi)*(1-exp(-p53_SLRadapt1(regi)*v53_costProtectSLR(ttot,regi)))
;
$endif.cm_SLR 

q53_adaptNonSLR(ttot,regi)$(ttot.val ge cm_startyear)..
   v53_protectNonSLR(ttot,regi) 
  =e=
   s53_effLim*p53_adapt2(regi)*(1-exp(-p53_adapt1(regi)*v53_costProtectNonSLR(ttot,regi)))
;


q53_adapt(ttot,regi)$(ttot.val ge cm_startyear)..
    vm_damageFactorAdapt(ttot,regi)
   =e=
    1
    - (pm_damageNonSLR(ttot,regi)*(1-v53_protectNonSLR(ttot,regi))+pm_laborBenefit(ttot,regi)+v53_costProtectNonSLR(ttot,regi)/(vm_cesIO(ttot,regi,"inco")+1e-8))
$ifthen.cm_SLR %cm_SLR% == "on"
    - (pm_damageSLR(ttot,regi)*(1-v53_protectSLR(ttot,regi))+v53_costProtectSLR(ttot,regi)/(vm_cesIO(ttot,regi,"inco")+1e-8))
$endif.cm_SLR 
;

*** EOF ./modules/53_adaptation/ACCREU/equations.gms
