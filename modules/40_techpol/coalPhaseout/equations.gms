*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/40_techpol/coalPhaseout/equations.gms
q40_CoalBound(t)$(t.val gt 2011 AND t.val lt 2023)..
*** attention: sum(regi will not work with Nash, therefore please reformulate with the usual iterative update mechanism
sum(regi,
   (sum(te$(sameas(te,"igcc")), sum(te2rlf(te,rlf), vm_deltaCap(t,regi,te,rlf)))*1000)
 + (sum(te$(sameas(te,"pc")), sum(te2rlf(te,rlf), vm_deltaCap(t,regi,te,rlf)))*1000)
 + (sum(te$(sameas(te,"coalchp")), sum(te2rlf(te,rlf), vm_deltaCap(t,regi,te,rlf)))*1000))
    =l= 20 - (2 *( pm_ttot_val(t)-2015)) ;

*** EOF ./modules/40_techpol/coalPhaseout/equations.gms
