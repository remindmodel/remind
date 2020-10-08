*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/26_agCosts/costs_trade/datainput.gms
*FP* read agricultural costs (all except bioenergy) and trade data from MAgPIE

table pm_totLUcosts(tall,all_regi) "agricultural costs"
$ondelim
$include "./modules/26_agCosts/costs_trade/input/pm_totLUcostsmag.csv";
$offdelim
;

table pm_NXagr(tall,all_regi) "net agricultural exports"
$ondelim
$include "./modules/26_agCosts/costs_trade/input/trade_bal_reg.rem.csv";
$offdelim
;

*** EOF ./modules/26_agCosts/costs_trade/datainput.gms
