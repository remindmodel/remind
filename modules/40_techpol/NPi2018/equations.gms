*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/40_techpol/NPi2018/equations.gms

q40_ElecBioBound(t,regi)$(t.val gt 2015)..
***am minimum targets for certain technologies
    sum(te2rlf(te,rlf)$(sameas(te,"biochp") OR sameas(te,"bioigcc") OR sameas(te,"bioigccc")), vm_cap(t,regi,te,rlf))
      * 1000 =g= p40_ElecBioBound(t,regi);	 

q40_PEgasBound(t,regi)$(t.val gt 2015 AND (sameas(regi,"CHN") OR sameas(regi,"CHA")))..
*cb for china, gas PE must be higher than a certain share of total PE
sum(pe2se(enty,enty2,te)$(sameas(enty,"pegas")),vm_demPe(t,regi,enty,enty2,te))
    =g= sum(iso_regi$map_iso_regi(iso_regi,regi),p40_PEgasBound(t,iso_regi)*
  (sum(pe2se(enty,enty2,te)$peBio(enty),vm_demPe(t,regi,enty,enty2,te))
  + sum(pe2se(enty,enty2,te)$(sameas(enty,"peoil") OR sameas(enty,"pecoal") OR sameas(enty,"pegas")),vm_demPe(t,regi,enty,enty2,te))
  + sum(pe2se(enty,entySe,te)$(sameas(enty,"pegeo") OR sameas(enty,"pehyd") OR sameas(enty,"pewin")  OR sameas(enty,"pesol")  OR sameas(enty,"peur") ), 
  vm_prodSe(t,regi,enty,entySe,te)/ p40_noncombust_acc_eff(t,iso_regi,te))) 
  );		

q40_PElowcarbonBound(t,regi)$(t.val ge 2020 AND (sameas(regi,"CHN") OR sameas(regi,"CHA")))..
*cb for china, lowCarbon PE (excl. traditional) must be smaller than lowCarbonshare times total PE (substitution method accounting: increase ren. and nuclear PE by inverse of coal power plant efficiencies) 
  sum(pe2se(enty,entySe,te)$(sameas(enty,"pegeo") OR sameas(enty,"pehyd") OR sameas(enty,"pewin")  OR sameas(enty,"pesol")  OR sameas(enty,"peur") ), 
    sum(iso_regi$map_iso_regi(iso_regi,regi),vm_prodSe(t,regi,enty,entySe,te)/ p40_noncombust_acc_eff(t,iso_regi,te)))
  + sum(pe2se(enty,enty2,te)$peBio(enty),vm_demPe(t,regi,enty,enty2,te))  
  - sum(pe2se(enty,enty2,te)$(peBio(enty) AND sameas(te,"biotr")),vm_demPe(t,regi,enty,enty2,te))
    =g= sum(iso_regi$map_iso_regi(iso_regi,regi),p40_PElowcarbonBound(t,iso_regi)*
  (sum(pe2se(enty,enty2,te)$peBio(enty),vm_demPe(t,regi,enty,enty2,te))
  + sum(pe2se(enty,enty2,te)$(sameas(enty,"peoil") OR sameas(enty,"pecoal") OR sameas(enty,"pegas")),vm_demPe(t,regi,enty,enty2,te))
  + sum(pe2se(enty,entySe,te)$(sameas(enty,"pegeo") OR sameas(enty,"pehyd") OR sameas(enty,"pewin")  OR sameas(enty,"pesol")  OR sameas(enty,"peur") ), 
       vm_prodSe(t,regi,enty,entySe,te)/ p40_noncombust_acc_eff(t,iso_regi,te)) 
  - sum(pe2se(enty,enty2,te)$(peBio(enty) AND sameas(te,"biotr")),vm_demPe(t,regi,enty,enty2,te))
  ));

  q40_FE_RenShare(t,regi)$(t.val ge 2020 AND sameas(regi,"EUR"))..
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
 

	
*** EOF ./modules/40_techpol/NPi2018/equations.gms
