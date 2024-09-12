*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/24_trade/standard/datainput.gms


pm_Xport0("2005",regi,peFos) = 0;

*ML* Reintroduction of trade cost for composite good (based on export/import value difference for non-energy goods in GTAP6)
pm_tradecostgood(regi)        = 0.03;

*** load data on transportation costs of imports
parameter pm_costsPEtradeMp(all_regi,all_enty)                   "PE tradecosts (energy losses on import)"
/
$ondelim
$include "./modules/24_trade/standard/input/pm_costsPEtradeMp.cs4r"
$offdelim
/
;


table pm_costsTradePeFinancial(all_regi,char,all_enty)          "PE tradecosts (financial costs on import, export and use)"
$ondelim
$include "./modules/24_trade/standard/input/pm_costsTradePeFinancial.cs3r"
$offdelim
;

*NB* import assumptions for the activation of trade constraints
parameter p24_trade_constraints(all_regi,all_enty,tradeConst)  "parameter for the region specific trade constraints, values different to 1 activate constraints and the value is used as effectiveness to varying degress such as percentage numbers"
/
$ondelim
$include "./modules/24_trade/standard/input/p24_trade_constraints.cs4r"
$offdelim
/
;

display p24_trade_constraints;

pm_costsTradePeFinancial(regi,"XportElasticity", tradePe(enty)) = 100;
pm_costsTradePeFinancial(regi, "tradeFloor", tradePe(enty))     = 0.0125;
pm_costsTradePeFinancial(regi,"Mport","peur")                   = 1e-06;

*** Adjust tradecosts based on switch
pm_costsTradePeFinancial(regi,"Xport", "pebiolc") = pm_costsTradePeFinancial(regi,"Xport", "pebiolc") * cm_tradecostBio;

pm_costsTradePeFinancial(regi,"Xport", "pegas") = 1.5 * pm_costsTradePeFinancial(regi,"Xport", "pegas") ;
pm_costsTradePeFinancial(regi,"XportElasticity","pegas") = 2 * pm_costsTradePeFinancial(regi,"XportElasticity","pegas");

*set trase se prices to zero
pm_MPortsPrice(ttot,regi,tradeSe)=0;
pm_XPortsPrice(ttot,regi,tradeSe)=0;

*** EOF ./modules/24_trade/standard/datainput.gms
