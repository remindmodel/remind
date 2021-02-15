*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/31_fossil/grades2poly/datainput.gms
***----------------------------------------------------------------------
*** Get uranium extraction-cost data (3rd-order grades2poly)
***----------------------------------------------------------------------
table f31_costExPoly(all_regi,all_enty,xirog)  "3rd-order polynomial coefficients (Uranium)"
$ondelim
$include "./modules/31_fossil/grades2poly/input/f31_costExPoly.cs3r"
$offdelim
;
p31_costExPoly(all_regi,xirog,all_enty) = f31_costExPoly(all_regi,all_enty,xirog);

p31_costExPoly(all_regi,"xi1","peur") = 0.025; !! forcing the same x intercept value as the region disaggregation method could force an approximated value instead  
***----------------------------------------------------------------------
*** Get oil, gas and coal extraction cost data (7th-order grades2poly based on REMIND output obtained with timeDepGrades)
***----------------------------------------------------------------------
*--------------------- Oil ----------------------------------------------
parameter f31_ffPolyRent(all_regi,all_enty,polyCoeffRent,all_fossilScen)   "Linear rent approx (e.g. Price - average extraction cost) (Oil, Gas and Coal)"
/
$ondelim
$include "./modules/31_fossil/grades2poly/input/f31_ffPolyRent.cs4r"
$offdelim
/
;
p31_ffPolyRent(all_regi,"pecoal",polyCoeffRent) = f31_ffPolyRent(all_regi,"pecoal",polyCoeffRent,"%cm_coal_scen%");
p31_ffPolyRent(all_regi,"peoil",polyCoeffRent)  = f31_ffPolyRent(all_regi,"peoil",polyCoeffRent,"%cm_oil_scen%");
p31_ffPolyRent(all_regi,"pegas",polyCoeffRent)  = f31_ffPolyRent(all_regi,"pegas",polyCoeffRent,"%cm_gas_scen%");

parameter f31_ffPolyCumEx(all_regi,all_enty,char,all_fossilScen)   "Linear rent approx (e.g. Price - average extraction cost) (Oil, Gas and Coal)"
/
$ondelim
$include "./modules/31_fossil/grades2poly/input/f31_ffPolyCumEx.cs4r"
$offdelim
/
;
pm_ffPolyCumEx(all_regi,"pecoal",char) = f31_ffPolyCumEx(all_regi,"pecoal",char,"%cm_coal_scen%");
pm_ffPolyCumEx(all_regi,"peoil",char)  = f31_ffPolyCumEx(all_regi,"peoil",char,"%cm_oil_scen%");
pm_ffPolyCumEx(all_regi,"pegas",char)  = f31_ffPolyCumEx(all_regi,"pegas",char,"%cm_gas_scen%");

table f31_ffPolyCoeffs(all_regi,all_fossilScen,polyCoeffCost)  "3rd-order polynomial coefficients (oil|gas|coal)"  
$ondelim
$include "./modules/31_fossil/grades2poly/input/f31_ffPolyCoeffs.cs3r"
$offdelim
;
p31_ffPolyCoeffs(regi,"pecoal",polyCoeffCost) = f31_ffPolyCoeffs(regi,"%cm_coal_scen%",polyCoeffCost);
p31_ffPolyCoeffs(regi,"peoil",polyCoeffCost) = f31_ffPolyCoeffs(regi,"%cm_oil_scen%",polyCoeffCost);
p31_ffPolyCoeffs(regi,"pegas",polyCoeffCost) = f31_ffPolyCoeffs(regi,"%cm_gas_scen%",polyCoeffCost);

*NB* include data and parameters for the price elastic supply of fossil fuels
p31_fosadjco_xi5xi6(regi,"xi5","pecoal")=0.3;
p31_fosadjco_xi5xi6(regi,"xi6","pecoal")=1/1;
p31_fosadjco_xi5xi6(regi,"xi5","peoil")=0.3;
p31_fosadjco_xi5xi6(regi,"xi6","peoil")=1/1;
p31_fosadjco_xi5xi6(regi,"xi5","pegas")=0.3;
p31_fosadjco_xi5xi6(regi,"xi6","pegas")=1/1;

*RP* Define bound on total PE uranium use in Megatonnes of metal uranium (U3O8, the stuff that is traded at 40-60US$/lb).
s31_max_disp_peur = 23;
*JH* 20140604 (25th Anniversary of Tiananmen) New nuclear assumption for SSP5
if (cm_nucscen eq 6,
  s31_max_disp_peur = 23*10;
);





*** EOF ./modules/31_fossil/grades2poly/datainput.gms
