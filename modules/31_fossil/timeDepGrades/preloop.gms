*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/31_fossil/timeDepGrades/preloop.gms
*===========================================
* MODULE.....: 31 FOSSIL
* REALISATION: timeDepGrades
* FILE.......: preloop.gms
*===========================================
* Decription: This realisation activates time-dependent grade structures for
*   oil, gas and coal. This enables to take into account exogenous technological
*   change for example.
*===========================================
* Authors...: JH, NB, TAC, CB, SB
* Wiki......: http://redmine.pik-potsdam.de/projects/remind-r/wiki/31_fossil
* History...:
*   - 2020-04-15 : Created moinput functions for input data handling, including region-specific constraints
*                  previously in the GAMS code. Data aggregated to H12 regions.
*   - 2015-12-03 : Cleaning up
*   - 2015-06-05 : Add test for runs with cm_startyear > 2010, so that fuelex_cum does not create problems
*   - 2015-02-06 : Add abort command to stop REMIND if MOFEX does not converge
*                  and possibility to perform several iterations
*   - 2013-10-01 : Cleaning up
*   - 2012-05-04 : Creation
*===========================================

***--------------------------------------
*** INITIAL EXTRACTION BOUND
***--------------------------------------
*NB*110729 bound on initial extraction from grades
if (s31_debug eq 1,
  display pm_EN_demand_from_initialcap2;
  display pm_IO_trade;
);

*** Calculate initial primary energy production in 2005 (function of PE demand (v05_INIdemEn0) and trade (pm_IO_trade))
*** A dummy factor of 1.1 is used to give GAMS more flexibility 
pm_prodIni(regi,peFos(enty)) = 1.1 * sum(t0,
                                          pm_EN_demand_from_initialcap2(regi,enty)
                                          + pm_IO_trade(t0,regi,enty,"Xport")
                                          - pm_IO_trade(t0,regi,enty,"Mport")
                                       );

if (s31_debug eq 1,
  display pm_prodIni;
);


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
$IFTHEN.mofex %cm_MOFEX% == "on"
option nlp = conopt4;  !! Greatly speed up convergence process (x3~x4)

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

*** Iteration loop
o_modelstat = 100;
p31_sol_itr_max = 10;
loop(sol_itr$(sol_itr.val <= p31_sol_itr_max),

  if(ord(sol_itr)>(p31_sol_itr_max-1),
    option solprint=on
  );

*** Solve statement
  if(o_modelstat ne 2,
    solve m31_MOFEX using nlp minimizing v31_MOFEX_costMinFuelEx;
    o_modelstat = m31_MOFEX.modelstat;
  );

);

vm_prodPe.lo(ttot,regi,peExGrade(enty)) = 1.e-9;
vm_prodPe.up(ttot,regi,peExGrade(enty)) = 1.e+2;

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

display p31_MOFEX_fuelex_costMin;
option nlp = %cm_conoptv%;
$ENDIF.mofex


***--------------------------------------
*** URANIUM BOUND
***--------------------------------------
v31_fuExtrCumMax.l(regi,peExPol(enty), "1")=0.01;
model m31_uran_bound_dummy /q31_mc_dummy, q31_totfuex_dummy/;

*** Small CNS model to initiate regional bounds on uranium extraction
     v31_fuExtrCumMax.l(regi,peExPol(enty), "1")=0.01;
 solve m31_uran_bound_dummy using cns;

*AJS* use parameter to save the result of the CNS model
     p31_fuExtrCumMaxBound(regi,"peur", "1") = v31_fuExtrCumMax.l(regi,"peur", "1");


*** EOF ./modules/31_fossil/timeDepGrades/preloop.gms
