*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/31_fossil/MOFEX/preloop.gms
*===========================================
* MODULE.....: 31 FOSSIL
* REALISATION: MOFEX
* FILE.......: preloop.gms
*===========================================
* Decription: This realisation activates time-dependent grade structures for
*   oil, gas and coal. This enables to take into account exogenous technological
*   change for example.
*===========================================
* Authors...: SB
* Wiki......: http://redmine.pik-potsdam.de/projects/remind-r/wiki/31_fossil
* History...:
*   - 2012-09-10 : Creation
*===========================================

*** Decline and incline rate equation offsets from FFECCM
* Additional factor entering the decline rate equation 
parameter f31_decoffset(all_regi,all_enty,rlf)    "Decline rate equation offset"
/
$ondelim
$include "./modules/31_fossil/timeDepGrades/input/f31_decoffset.cs4r"
$offdelim
/
;
p31_datafosdyn(all_regi,all_enty,rlf,"decoffset")$(not sameas(all_enty,"pecoal")) = f31_decoffset(all_regi,all_enty,rlf);

* Additional factor entering the increase rate equation
p31_datafosdyn(regi, "pegas",  rlf, "incoffset") = 0.002 * p31_grades("2005", regi, "xi3", "pegas",  rlf);
p31_datafosdyn(regi, "peoil",  rlf, "incoffset") = 0.002 * p31_grades("2005", regi, "xi3", "peoil",  rlf);
p31_datafosdyn(regi, "pecoal", rlf, "incoffset") = 0.002 * p31_grades("2005", regi, "xi3", "pecoal", rlf);

* Factor for quadratic adjustment cost function
p31_datafosdyn(regi, enty, rlf, "alph") = 20;

***--------------------------------------
*** MOFEX
***--------------------------------------
*** Small partial model to compute level values of fossil fuel extraction (vm_fuExtr.l) given a 
*** specific demand path

*** Get fossil fuel demand (vm_prodPe) from reference GDX (input.gdx)
p31_MOFEX_peprod_ref(ttot,regi,peExGrade(enty)) = 0; 
p31_MOFEX_Xport_ref(ttot,regi,trade) = 0;
p31_MOFEX_Mport_ref(ttot,regi,trade) = 0;
Execute_Loadpoint 'input', 
  p31_MOFEX_peprod_ref = vm_prodPe.l,
  p31_MOFEX_Xport_ref  = vm_Xport.l,
  p31_MOFEX_Mport_ref  = vm_Mport.l;
display p31_MOFEX_peprod_ref;

*** Fixing MOFEX fossil fuel demand to reference GDX data
vm_prodPe.fx(ttot,regi,peExGrade(enty)) = p31_MOFEX_peprod_ref(ttot,regi,enty);

*** Apply other important bounds
v31_fuExtrCum.up(t,regi,peExGrade(enty),rlf)          = p31_grades(t,regi,"xi3",enty,rlf);
vm_costFuEx.up(t,regi,peExGrade(enty))                = 10.0;
vm_Xport.fx(ttot,regi,trade)$(ttot.val lt cm_startyear) = p31_MOFEX_Xport_ref(ttot,regi,trade);  !! To avoid unbounded results
vm_Mport.fx(ttot,regi,trade)$(ttot.val lt cm_startyear) = p31_MOFEX_Mport_ref(ttot,regi,trade);  !! To avoid unbounded results

display vm_prodPe.l;

*** Model statement
model m31_MOFEX /q31_MOFEX_costMinFuelEx, q31_MOFEX_tradebal, q31_fuExtrDec, q31_fuExtrInc, 
                 q31_fuExtrCum, q31_costFuExGrade, qm_fuel2pe/;

*** EOF ./modules/31_fossil/MOFEX/preloop.gms
