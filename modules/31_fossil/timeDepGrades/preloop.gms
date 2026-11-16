*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
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
