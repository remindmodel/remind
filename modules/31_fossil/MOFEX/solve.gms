*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/31_fossil/MOFEX/solve.gms
*===========================================
* MODULE.....: 31 FOSSIL
* REALISATION: MOFEX
* FILE.......: solve.gms
*===========================================
* Decription: This realisation activates time-dependent grade structures for
*   oil, gas and coal. This enables to take into account exogenous technological
*   change for example.
*===========================================
* Authors...: SB
* Wiki......: http://redmine.pik-potsdam.de/projects/remind-r/wiki/31_fossil
* History...:
*   - 2019-09-10 : Creation
*===========================================

*------------------------------------
*' @code
*------------------------------------
option nlp = conopt4;  !! Greatly speed up convergence process (x3~x4)

*** Iteration loop
o_modelstat = 100;
option solprint=on

*** Solve statement
if(o_modelstat ne 2,
   solve m31_MOFEX using nlp minimizing v31_MOFEX_costMinFuelEx;
   o_modelstat = m31_MOFEX.modelstat;
);

* vm_prodPe.lo(ttot,regi,peExGrade(enty)) = 1.e-9;
* vm_prodPe.up(ttot,regi,peExGrade(enty)) = 1.e+2;

*** Save fuel extraction and trade values
p31_MOFEX_fuelex_costMin(ttot,regi,enty,rlf)  = vm_fuExtr.l(ttot,regi,enty,rlf);
p31_MOFEX_cumfex_costMin(ttot,regi,enty,rlf)  = v31_fuExtrCum.l(ttot,regi,enty,rlf);
p31_MOFEX_Mport_costMin(ttot,regi,trade)      = vm_Mport.l(ttot,regi,trade);
p31_MOFEX_Xport_costMin(ttot,regi,trade)      = vm_Xport.l(ttot,regi,trade);

*** Save values in a gdx
if(m31_MOFEX.modelstat ne 2,
  Execute_Unload 'mofex';
  abort "MOFEX did not find an optimal solution. Stopping job...";
);

vm_prodPe.lo(ttot,regi,peExGrade(enty)) = 1.e-9;
vm_prodPe.up(ttot,regi,peExGrade(enty)) = 1.e+2;

display p31_MOFEX_fuelex_costMin;
option nlp = %cm_conoptv%;

*** EOF ./modules/31_fossil/MOFEX/solve.gms
