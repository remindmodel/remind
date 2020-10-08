*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/41_emicapregi/GDPint/equations.gms
*gl* calculate emission cap in absolute terms
*ml 20140110* Nash extension (emiscen=4)

q41_perm_alloc_cap(t,regi) $(t.val gt 2010)..        
     vm_perm(t,regi) =e=
     pm_shPerm(t,regi)* 
         (vm_co2eqGlob(t) $(cm_emiscen ne 4)
        + pm_emicapglob(t) $(cm_emiscen eq 4));
*** EOF ./modules/41_emicapregi/GDPint/equations.gms
