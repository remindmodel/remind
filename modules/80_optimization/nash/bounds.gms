*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/nash/bounds.gms
*override fixing of vm_perm set in 41_emicapregi/none/bounds.gms
*mlb 20150609* allow negative permits to compute efficient solution
$ifthen.emiopt %emicapregi% == 'none' 
if(cm_emiscen eq 6,
  vm_perm.lo(t,regi) = -10;
  vm_perm.up(t,regi) = 10000;
);
$endif.emiopt

*ML* in nash with permit allocation only total budgets are meaningful; allowing permit trade
*only for the initial policy period avoids indeterminacy, hence numerical problems
loop(ttot$(ttot.val ne cm_startyear),
    vm_Xport.fx(ttot,regi,"perm")$(cm_emiscen eq 6) = 0;
    vm_Mport.fx(ttot,regi,"perm")$(cm_emiscen eq 6) = 0 ;
);
*** EOF ./modules/80_optimization/nash/bounds.gms
