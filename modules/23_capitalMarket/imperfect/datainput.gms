*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/23_capitalMarket/imperfect/datainput.gms

*** ML 20181220* substitution elasticity and time preference adjusted to get initial consumption that matches historic consumption shares
*** be careful with changing time preferences as this parameter is used also outside the welfare function

parameter pm_ies(all_regi)        "intertemporal elasticity of substitution"
/
$ondelim
$include "./modules/23_capitalMarket/imperfect/input/pm_ies.cs4r"
$offdelim
/
;

parameter p23_prtp(all_regi)       " regionally differentiated pure rate of time preference"
/
$ondelim
$include "./modules/23_capitalMarket/imperfect/input/p23_prtp.cs4r"
$offdelim
/
;

if(cm_prtpScen eq 3, 
     pm_prtp(regi) = p23_prtp(regi);
);

parameter pm_risk_premium(all_regi)       "risk premium that lowers the use of capital imports"
/
$ondelim
$include "./modules/23_capitalMarket/imperfect/input/pm_risk_premium.cs4r"
$offdelim
/
;

   
p23_debtCoeff = 0.6 ;
p23_debt_growthCoeff(regi) = 0.1 ;


parameter pm_nfa_start(all_regi)       "initial net foreign asset"
/
$ondelim
$include "./modules/23_capitalMarket/imperfect/input/pm_nfa_start.cs4r"
$offdelim
/
;


*** EOF ./modules/23_capitalMarket/imperfect/datainput.gms

