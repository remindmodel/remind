*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/23_capitalMarket/perfect/datainput.gms

pm_ies(regi) = 1;
pm_risk_premium(regi) = 0.0;
p23_debt_growthCoeff(regi) = 0.2 ;

parameter pm_nfa_start(all_regi)       "initial net foreign asset"
/
$ondelim
$include "./modules/23_capitalMarket/perfect/input/pm_nfa_start.cs4r"
$offdelim
/
;

*** EOF ./modules/23_capitalMarket/perfect/datainput.gms
