*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/31_fossil/timeDepGrades/datainput.gms
*===========================================
* MODULE.....: 31 FOSSIL
* REALISATION: timeDepGrades
* FILE.......: datainput.gms
*===========================================
* Decription: This realisation activates time-dependent grade structures for
*   oil, gas and coal. This enables to take into account exogenous technological
*   change for example.
*===========================================
* Authors...: JH, NB, TAC
* Wiki......: http://redmine.pik-potsdam.de/projects/remind-r/wiki/31_fossil
* History...:
*   - 2015-12-03 : Cleaning up
*   - 2013-10-01 : Cleaning up
*   - 2012-05-04 : Creation
*===========================================


***----------------------------------------------------------------------
*** Get uranium extraction-cost data (3rd-order grades2poly)
***----------------------------------------------------------------------
table f31_costExPoly(all_regi,all_enty,xirog)  "3rd-order polynomial coefficients (Uranium)"
$ondelim
$include "./modules/31_fossil/grades2poly/input/f31_costExPoly.cs3r"
$offdelim
;
p31_costExPoly(all_regi,xirog,all_enty) = f31_costExPoly(all_regi,all_enty,xirog);

*Summarized p31_costExPoly modification steps found on Rev 7683.
p31_costExPoly(regi,"xi1","peur") = 25/1000;
p31_costExPoly(regi,"xi2","peur") = 0;
p31_costExPoly(regi,"xi3","peur")= ( (300/1000)* 3 ** 1.8) / ((p31_costExPoly(regi,"xi3","peur")* 14 /4.154) * 3) ** 2;
p31_costExPoly(regi,"xi4","peur") = 0;

***----------------------------------------------------------------------
*** Oil
***----------------------------------------------------------------------
*SSP1
$ifthen.cm_oil_scen %cm_oil_scen% == "lowOil"
$include "./modules/31_fossil/timeDepGrades/input/p31_grades_looil.inc"
$include "./modules/31_fossil/timeDepGrades/input/p31_datafosdec_lo.inc"
*SSP2
$elseif.cm_oil_scen %cm_oil_scen% == "medOil"
$include "./modules/31_fossil/timeDepGrades/input/p31_grades_medoil.inc"
$include "./modules/31_fossil/timeDepGrades/input/p31_datafosdec_med.inc"
*SSP5
$elseif.cm_oil_scen %cm_oil_scen% == "highOil"
$include "./modules/31_fossil/timeDepGrades/input/p31_grades_hioil.inc"
$include "./modules/31_fossil/timeDepGrades/input/p31_datafosdec_hi.inc"
$endif.cm_oil_scen
* There is no specific data for cm_oil_scen in this module (use same as in 3)
*if(cm_oil_scen eq 4,
*abort "Error in module 31_fossil -> timeDepGrades: This oil scenario does not exist." ;
*);
*SSP3
*if(cm_oil_scen eq 5,
*$include "./modules/31_fossil/timeDepGrades/input/p31_grades_hioil_learn.inc";
*$include "./modules/31_fossil/timeDepGrades/input/p31_datafosdec_hi.inc";
*);
*SSP4
*if(cm_oil_scen eq 6,
*$include "./modules/31_fossil/timeDepGrades/input/p31_grades_looil_learn.inc";
*$include "./modules/31_fossil/timeDepGrades/input/p31_datafosdec_lo.inc";
*);
*if(cm_oil_scen ge 7,
*abort "Error in module 31_fossil -> timeDepGrades: This oil scenario does not exist." ;
*);

***----------------------------------------------------------------------
*** Gas
***----------------------------------------------------------------------
* There is no specific data for cm_gas_scen in this module (use same as in 1)
*if(cm_gas_scen eq 0,
*$include "./modules/31_fossil/timeDepGrades/input/p31_grades_logas_SSP1.inc";
*abort "Error in module 31_fossil -> timeDepGrades: This gas scenario exists under the grades realisation only" ;
*);
*SSP1
$ifthen.cm_gas_scen %cm_gas_scen% == "lowGas"
$include "./modules/31_fossil/timeDepGrades/input/p31_grades_logas.inc"
*SSP2
$elseif.cm_gas_scen %cm_gas_scen% == "medGas"
$include "./modules/31_fossil/timeDepGrades/input/p31_grades_medgas.inc"

*SSP5
$elseif.cm_gas_scen %cm_gas_scen% == "highGas"
$include "./modules/31_fossil/timeDepGrades/input/p31_grades_higas.inc"
$endif.cm_gas_scen

*if(cm_gas_scen ge 4,
*$include "./modules/31_fossil/timeDepGrades/input/p31_grades_medgas.inc";
*abort "Error in module 31_fossil -> timeDepGrades: This gas scenario does not exist." ;
*);


***----------------------------------------------------------------------
*** Coal
***----------------------------------------------------------------------
*if(cm_coal_scen eq 0,
*$include "./modules/31_fossil/timeDepGrades/input/p31_grades_vlocoal.inc";
*);
$ifthen.cm_coal_scen %cm_coal_scen% == "lowCoal"
$include "./modules/31_fossil/timeDepGrades/input/p31_grades_locoal.inc"

$elseif.cm_coal_scen %cm_coal_scen% == "medCoal"
$include "./modules/31_fossil/timeDepGrades/input/p31_grades_medcoal.inc"

$elseif.cm_coal_scen %cm_coal_scen% == "highCoal"
$include "./modules/31_fossil/timeDepGrades/input/p31_grades_hicoal.inc"
$endif.cm_coal_scen

***----------------------------------------------------------------------
*** Oil, gas and coal
***----------------------------------------------------------------------
*NB* include data and parameters for the price elastic supply of fossil fuels
p31_fosadjco_xi5xi6(regi, "xi5", "pecoal") = 0.3;
p31_fosadjco_xi5xi6(regi, "xi6", "pecoal") = 1/1;
p31_fosadjco_xi5xi6(regi, "xi5", "peoil")  = 0.3;
p31_fosadjco_xi5xi6(regi, "xi6", "peoil")  = 1/1;
p31_fosadjco_xi5xi6(regi, "xi5", "pegas")  = 0.3;
p31_fosadjco_xi5xi6(regi, "xi6", "pegas")  = 1/1;

*NB*110720 include data for constraints on maximum growth and decline of vm_fuExtr, and also the offsets
$include "./modules/31_fossil/timeDepGrades/input/p31_datafosdyn.inc";

*RP* Define bound on total PE uranium use in Megatonnes of metal uranium (U3O8, the commodity that is traded at 40-60US$/lb).
s31_max_disp_peur = 23;

*JH* 20140604 New nuclear assumption for SSP5
if (cm_nucscen eq 6,
  s31_max_disp_peur = 23*10;
);

p31_datafosdyn(regi,"pegas",rlf,"alph") = cm_trdadj * p31_datafosdyn(regi,"pegas",rlf,"alph");

p31_extraseed(ttot,regi,enty,rlf) = 0;
*NB* extra seed value for the US gas sector to reduce initial price in EJ/yr
p31_extraseed("2010","USA","pegas","2") = sm_EJ_2_TWa * 2;

*** EOF ./modules/31_fossil/timeDepGrades/datainput.gms
