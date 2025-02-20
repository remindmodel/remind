*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/40_techpol/NPi2018/equations.gms

*' @equations



***am minimum targets for certain technologies
q40_ElecBioBound(t,regi)$(t.val gt 2025)..
    sum(te2rlf(te,rlf)$(sameas(te,"biochp") OR sameas(te,"bioigcc") OR sameas(te,"bioigccc")), vm_cap(t,regi,te,rlf))
      =g= p40_ElecBioBound(t,regi) * 0.001
;	 

*** ensure that the total wind bound is at least as large as the sum of windon and windoff
q40_windBound(t,regi)$(t.val gt 2025 AND p40_TechBound(t,regi,"wind") gt 0)..
vm_cap(t,regi,"wind","1")) 
    =g=sum(p40_TechBound(t,regi,"windon"), p40_TechBound(t,regi,"windoff"))* 0.001
;

  q40_FE_RenShare(t,regi)$(t.val ge 2025 AND sameas(regi,"EUR"))..
*cb for EUR, renewable SE must be greater than lowCarbonshare times total SE
  ( sum(pe2se(enty,enty2,te)$(sameas(enty,"pegeo") OR sameas(enty,"pehyd") OR sameas(enty,"pewin")  OR sameas(enty,"pesol")  OR sameas(enty,"pebiolc") OR sameas(enty,"pebios") OR sameas(enty,"pebioil")), vm_prodSe(t,regi,enty,enty2,te))
  + sum(pc2te(enty,enty2,te,entySe(enty3))$peBio(enty),
      max(0, pm_prodCouple(regi,enty,enty2,te,enty3)) * vm_prodSe(t,regi,enty,enty2,te))
  )
    =g= sum(iso_regi$map_iso_regi(iso_regi,regi),p40_FE_RenShare(t,iso_regi))*
  ( sum(pe2se(enty,enty2,te),       vm_prodSe(t,regi,enty,enty2,te))
  + sum(pc2te(enty,enty2,te,entySe(enty3)),
     max(0, pm_prodCouple(regi,enty,enty2,te,enty3)) * vm_prodSe(t,regi,enty,enty2,te))
  );

*' @stop

*** EOF ./modules/40_techpol/NPi2018/equations.gms
