*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/24_trade/se_trade/datainput.gms


pm_Xport0("2005",regi,peFos) = 0;

*ML* Reintroduction of trade cost for composite good (based on export/import value difference for non-energy goods in GTAP6)
pm_tradecostgood(regi)        = 0.03;

*** load data on transportation costs of imports
parameter pm_costsPEtradeMp(all_regi,all_enty)                   "PE tradecosts (energy losses on import)"
/
$ondelim
$include "./modules/24_trade/se_trade/input/pm_costsPEtradeMp.cs4r"
$offdelim
/
;


table pm_costsTradePeFinancial(all_regi,char,all_enty)          "PE tradecosts (financial costs on import, export and use)"
$ondelim
$include "./modules/24_trade/se_trade/input/pm_costsTradePeFinancial.cs3r"
$offdelim
;
pm_costsTradePeFinancial(regi,"XportElasticity", tradePe(enty)) = 100;
pm_costsTradePeFinancial(regi, "tradeFloor", tradePe(enty))     = 0.0125;

*DK* Only for SSP cases other than SSP2: use default trade costs
if(cm_tradecost_bio = 1,
pm_costsTradePeFinancial(regi,"Xport", "pebiolc") = pm_costsTradePeFinancial(regi,"Xport", "pebiolc")/2;
);

pm_costsTradePeFinancial(regi,"Xport", "pegas") = cm_trdcst * pm_costsTradePeFinancial(regi,"Xport", "pegas") ;
pm_costsTradePeFinancial(regi,"XportElasticity","pegas") = cm_trdadj *pm_costsTradePeFinancial(regi,"XportElasticity","pegas");

*** initialize secondary energy trade capacity
p24_seTradeCapacity(t,regi2,regi,entySe) = 0;

*** Secondary Energy exogenously defined trade scenarios
$ifthen.seTradeScenario "%cm_seTradeScenario%" == "DEU_Low_H2"
*Low Hydrogen trade in Germany only (all imports from MEA)
  p24_seTradeCapacity("2040",regi,regi2,"seh2")$(sameas(regi,"MEA") AND sameas(regi2,"DEU")) = 10/8760; !! TWh to TWa
  p24_seTradeCapacity("2045",regi,regi2,"seh2")$(sameas(regi,"MEA") AND sameas(regi2,"DEU")) = 30/8760;
  p24_seTradeCapacity("2050",regi,regi2,"seh2")$(sameas(regi,"MEA") AND sameas(regi2,"DEU")) = 100/8760;
  p24_seTradeCapacity(t,regi,regi2,"seh2")$(sameas(regi,"MEA") AND sameas(regi2,"DEU") AND t.val ge 2055) = 150/8760;
$elseif.seTradeScenario "%cm_seTradeScenario%" == "DEU_High_H2"
  p24_seTradeCapacity("2030",regi,regi2,"seh2")$(sameas(regi,"MEA") AND sameas(regi2,"DEU")) = 30/8760;
  p24_seTradeCapacity("2035",regi,regi2,"seh2")$(sameas(regi,"MEA") AND sameas(regi2,"DEU")) = 100/8760;
  p24_seTradeCapacity("2040",regi,regi2,"seh2")$(sameas(regi,"MEA") AND sameas(regi2,"DEU")) = 200/8760;
  p24_seTradeCapacity("2045",regi,regi2,"seh2")$(sameas(regi,"MEA") AND sameas(regi2,"DEU")) = 400/8760;
  p24_seTradeCapacity("2050",regi,regi2,"seh2")$(sameas(regi,"MEA") AND sameas(regi2,"DEU")) = 500/8760;
  p24_seTradeCapacity(t,regi,regi2,"seh2")$(sameas(regi,"MEA") AND sameas(regi2,"DEU") AND t.val ge 2055) = 600/8760;
$endif.seTradeScenario


*** EOF ./modules/24_trade/se_trade/datainput.gms
