*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/40_techpol/NDC2018plus/equations.gms

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

  q40_FE_RenShare(t,regi)$(t.val ge 2020 AND p40_FE_RenShare(t,regi))..
*cb for EUR, renewable SE must be greater than lowCarbonshare times total SE
  ( sum(pe2se(enty,enty2,te)$(sameas(enty,"pegeo") OR sameas(enty,"pehyd") OR sameas(enty,"pewin")  OR sameas(enty,"pesol")  OR sameas(enty,"pebiolc") OR sameas(enty,"pebios") OR sameas(enty,"pebioil")), vm_prodSe(t,regi,enty,enty2,te))
  + sum(pc2te(enty,enty2,te,entySe(enty3))$peBio(enty),
      max(0, pm_prodCouple(regi,enty,enty2,te,enty3)) * vm_prodSe(t,regi,enty,enty2,te))
  )
    =g= p40_FE_RenShare(t,regi)*
  ( sum(pe2se(enty,enty2,te),       vm_prodSe(t,regi,enty,enty2,te))
  + sum(pc2te(enty,enty2,te,entySe(enty3)),
     max(0, pm_prodCouple(regi,enty,enty2,te,enty3)) * vm_prodSe(t,regi,enty,enty2,te))
  );
 

q40_El_RenShare(t,regi)$(t.val ge 2020 AND (sameas(regi,"USA") OR sameas(regi,"JPN")))..
  ( sum(pe2se(enty,"seel",te)$(sameas(enty,"pegeo") OR sameas(enty,"pehyd") OR sameas(enty,"pewin")  OR sameas(enty,"pesol") OR sameas(enty,"pebiolc") OR sameas(enty,"pebios") OR sameas(enty,"pebioil")), vm_prodSe(t,regi,enty,"seel",te))
*** leave out couple production, as many countries even encourage coupled heat and power production, so it's unclear whether rps would disencourage it  
***  + sum(pc2te(enty,entySe(enty3),te,"seel")$(sameas(enty,"pecoal") OR sameas(enty,"peoil") OR sameas(enty,"pegas")),
***      max(0, pm_prodCouple(regi,enty,enty3,te,"seel")) * vm_prodSe(t,regi,enty,enty3,te))
  )
    =g= sum(iso_regi$map_iso_regi(iso_regi,regi),p40_El_RenShare(t,iso_regi))*
  ( sum(pe2se(enty,"seel",te),       vm_prodSe(t,regi,enty,"seel",te))
***  + sum(pc2te(enty,entySe(enty3),te,"seel"),
***     max(0, pm_prodCouple(regi,enty,enty3,te,"seel")) * vm_prodSe(t,regi,enty,enty3,te))
***  - pm_prodCouple(regi,"pegeo","sehe","geohe","seel")*vm_prodSe(t,regi,"pegeo","seel","geohe")
  );
  
  
q40_ElCap_RenShare(t,regi)$((t.val eq 2030) AND (sameas(regi,"IND")))..
***am lower bound for non-fossil share of total installed capacity for India
***sum(teRe(te), sum( te2rlf(te,rlf),vm_cap(t,regi,te,rlf))) + sum( te2rlf("tnrs",rlf),vm_cap(t,regi,"tnrs",rlf)) + sum( te2rlf("fnrs",rlf),vm_cap(t,regi,"fnrs",rlf))
***sum(teRe(te), sum( te2rlf(te,rlf),vm_cap(t,regi,te,rlf))) + sum(te$(sameas(te,"tnrs") OR sameas(te,"fnrs")), sum( te2rlf(te,rlf),vm_cap(t,regi,te,rlf)))
***sum(te$(teRe(te) OR sameas(te,"tnrs") OR sameas(te,"fnrs")), sum( te2rlf(te,rlf),vm_cap(t,regi,te,rlf))) =g= p40_ElCap_RenShare(t,regi) * sum((all_enty,te)$en2en(all_enty,"seel",te),sum( te2rlf(te,rlf),vm_cap(t,regi,te,rlf)));
sum(teRe(te), sum( te2rlf(te,rlf),vm_cap(t,regi,te,rlf))) + sum( te2rlf("tnrs",rlf),vm_cap(t,regi,"tnrs",rlf))  =g= p40_ElCap_RenShare(t,regi) * sum((all_enty,te)$en2en(all_enty,"seel",te),sum( te2rlf(te,rlf),vm_cap(t,regi,te,rlf)));  
   
   
q40_CoalBound(t,regi)$(t.val gt 2016 AND sameas(regi,"USA"))..
*cb upper bound for freely emitting coal power technologies: 1000 GW per year for all regions without policy (=no bound)
   (sum(te$(sameas(te,"igcc")), sum(te2rlf(te,rlf), vm_deltaCap(t,regi,te,rlf)))*1000)
 + (sum(te$(sameas(te,"pc")), sum(te2rlf(te,rlf), vm_deltaCap(t,regi,te,rlf)))*1000)
 + (sum(te$(sameas(te,"coalchp")), sum(te2rlf(te,rlf), vm_deltaCap(t,regi,te,rlf)))*1000)
    =l= (1000-sum(iso_regi$map_iso_regi(iso_regi,regi),p40_CoalBound(t,iso_regi))) ;
*** EOF ./modules/40_techpol/NDC2018plus/equations.gms
