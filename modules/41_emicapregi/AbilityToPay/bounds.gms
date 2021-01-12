*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/41_emicapregi/AbilityToPay/bounds.gms
*** calculate emission cap in absolute terms
vm_perm.fx(t,regi) = p41_co2eq_bau(t,regi) - p41_precorrection_reduction(t,regi)/p41_correct_factor(t);

display vm_perm.up;

*** disactivate permit trade
if(cm_permittradescen eq 2,
vm_Xport.fx(t,regi,"perm") = 0;
vm_Mport.fx(t,regi,"perm") = 0;
);
*** limited permit trade: limit in terms of share of allocated permits
if(cm_permittradescen ne 1 AND cm_permittradescen ne 2,
vm_Xport.up(t,regi,"perm")$(t.val lt 2100)=abs(cm_permittradescen/100*(p41_co2eq_bau(t,regi)-vm_perm.up(t,regi)));
vm_Mport.up(t,regi,"perm")$(t.val lt 2100)=abs(cm_permittradescen/100*(p41_co2eq_bau(t,regi)-vm_perm.up(t,regi)));
);
*** EOF ./modules/41_emicapregi/AbilityToPay/bounds.gms
