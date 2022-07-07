*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
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
* Authors...: JH, NB, TAC, SB
* Wiki......: http://redmine.pik-potsdam.de/projects/remind-r/wiki/31_fossil
* History...:
*   - 2020-04-15 : Created moinput functions for input data handling, including region-specific constraints
*                  previously in the GAMS code. Data aggregated to H12 regions.
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
*** Get oil gas & coal extraction cost grade data
***----------------------------------------------------------------------
parameter f31_grades_oil(tall,all_regi,all_LU_emi_scen,xirog,rlf) "(Input) information about oil according to the grade structure concept. Unit: TWa"
/
$ondelim
$include "./modules/31_fossil/timeDepGrades/input/p31_grades_oil.cs4r"
$offdelim
/
;

parameter f31_grades_gas(tall,all_regi,all_LU_emi_scen,xirog,rlf) "(Input) information about gas according to the grade structure concept. Unit: TWa"
/
$ondelim
$include "./modules/31_fossil/timeDepGrades/input/p31_grades_gas.cs4r"
$offdelim
/
;

parameter f31_grades_coal(tall,all_regi,all_LU_emi_scen,xirog,rlf) "(Input) information about coal according to the grade structure concept. Unit: TWa"
/
$ondelim
$include "./modules/31_fossil/timeDepGrades/input/p31_grades_coal.cs4r"
$offdelim
/
;

***----------------------------------------------------------------------
*** Oil
***----------------------------------------------------------------------
$ifthen.cm_oil_scen %cm_oil_scen% == "lowOil"
*SSP1
p31_datafosdyn(all_regi,"peoil",rlf,"dec") = f31_grades_oil("2005",all_regi,"SSP1","dec",rlf);
p31_grades(tall,regi,xirog,"peoil",rlf) = f31_grades_oil(tall,regi,"SSP1",xirog,rlf)$(not sameas(xirog,"dec"));

$elseif.cm_oil_scen %cm_oil_scen% == "medOil"
*SSP2
p31_datafosdyn(all_regi,"peoil",rlf,"dec") = f31_grades_oil("2005",all_regi,"SSP2","dec",rlf);
p31_grades(tall,regi,xirog,"peoil",rlf) = f31_grades_oil(tall,regi,"SSP2",xirog,rlf)$(not sameas(xirog,"dec"));

$elseif.cm_oil_scen %cm_oil_scen% == "highOil"
*SSP5
p31_datafosdyn(all_regi,"peoil",rlf,"dec") = f31_grades_oil("2005",all_regi,"SSP5","dec",rlf);
p31_grades(tall,regi,xirog,"peoil",rlf) = f31_grades_oil(tall,regi,"SSP5",xirog,rlf)$(not sameas(xirog,"dec"));
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
p31_datafosdyn(all_regi,"pegas",rlf,"dec") = f31_grades_gas("2005",all_regi,"SSP1","dec",rlf);
p31_grades(tall,regi,xirog,"pegas",rlf) = f31_grades_gas(tall,regi,"SSP1",xirog,rlf)$(not sameas(xirog,"dec"));
*SSP2
$elseif.cm_gas_scen %cm_gas_scen% == "medGas"
p31_datafosdyn(all_regi,"pegas",rlf,"dec") = f31_grades_gas("2005",all_regi,"SSP2","dec",rlf);
p31_grades(tall,regi,xirog,"pegas",rlf) = f31_grades_gas(tall,regi,"SSP2",xirog,rlf)$(not sameas(xirog,"dec"));
*SSP5
$elseif.cm_gas_scen %cm_gas_scen% == "highGas"
p31_datafosdyn(all_regi,"pegas",rlf,"dec") = f31_grades_gas("2005",all_regi,"SSP5","dec",rlf);
p31_grades(tall,regi,xirog,"pegas",rlf) = f31_grades_gas(tall,regi,"SSP5",xirog,rlf)$(not sameas(xirog,"dec"));
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
p31_grades(tall,regi,xirog,"pecoal",rlf) = f31_grades_coal(tall,regi,"SSP1",xirog,rlf)$(not sameas(xirog,"dec"));
$elseif.cm_coal_scen %cm_coal_scen% == "medCoal"
p31_grades(tall,regi,xirog,"pecoal",rlf) = f31_grades_coal(tall,regi,"SSP2",xirog,rlf)$(not sameas(xirog,"dec"));
$elseif.cm_coal_scen %cm_coal_scen% == "highCoal"
p31_grades(tall,regi,xirog,"pecoal",rlf) = f31_grades_coal(tall,regi,"SSP5",xirog,rlf)$(not sameas(xirog,"dec"));
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
*SB*04022020 Hardcoded this into REMIND instead of the FFECCM input routines

*RP* Define bound on total PE uranium use in Megatonnes of metal uranium (U3O8, the commodity that is traded at 40-60US$/lb).
s31_max_disp_peur = 23;

*JH* 20140604 New nuclear assumption for SSP5
if (cm_nucscen eq 6,
  s31_max_disp_peur = 23*10;
);

p31_datafosdyn(regi,"pegas",rlf,"alph") = cm_trdadj * p31_datafosdyn(regi,"pegas",rlf,"alph");

*NB* extra seed value for the US gas sector to reduce initial price in EJ/yr
*SB 04/15/2020* Moved this parameter definition to moinput
parameter p31_extraseed(tall,all_regi,all_enty,rlf)  "extra seed value that scales up the ramp-up potential"
/
$ondelim
$include "./modules/31_fossil/timeDepGrades/input/f31_extraseed.cs4r"
$offdelim
/
;


parameter f31_Xport(ttot,all_regi,all_enty,all_LU_emi_scen) "Upper bounds on exports in early timesteps [TWyr]"
/
$ondelim
$include "./modules/31_fossil/timeDepGrades/input/f31_Xport.cs4r"
$offdelim
/
;


*** EOF ./modules/31_fossil/timeDepGrades/datainput.gms
