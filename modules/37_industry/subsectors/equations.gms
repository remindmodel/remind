*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/subsectors/equations.gms

q37_energy_limits(ttot,regi,energy_limits37(out,in))$( ttot.val ge cm_startyear ) .. 
    vm_cesIO(ttot,regi,in)
  * p37_energy_limit(out,in)
  =g=
  vm_cesIO(ttot,regi,out)
;

*** No more than 90% of steel from secondary production
*** FIXME: add check to ensure calibration data abides by this rule
q37_limit_secondary_steel_share(ttot,regi)$( ttot.val ge cm_startyear ) .. 
  9 * vm_cesIO(ttot,regi,"ue_steel_primary")
  =g=
  vm_cesIO(ttot,regi,"ue_steel_secondary")
;

*** EOF ./modules/37_industry/subsectors/equations.gms

