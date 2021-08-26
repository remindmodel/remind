*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/24_trade/capacity/datainput.gms


pm_Xport0("2005",regi,peFos) = 0;

*ML* Reintroduction of trade cost for composite good (based on export/import value difference for non-energy goods in GTAP6)
pm_tradecostgood(regi)        = 0.03;

*** load data on transportation costs of imports
parameter pm_costsPEtradeMp(all_regi,all_enty)                   "PE tradecosts (energy losses on import)"
/
$ondelim
$include "./modules/24_trade/capacity/input/pm_costsPEtradeMp.cs4r"
$offdelim
/
;


table pm_costsTradePeFinancial(all_regi,char,all_enty)          "PE tradecosts (financial costs on import, export and use)"
$ondelim
$include "./modules/24_trade/capacity/input/pm_costsTradePeFinancial.cs3r"
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

*set trase se prices to zero
pm_MPortsPrice(ttot,regi,tradeSe)=0;
pm_XPortsPrice(ttot,regi,tradeSe)=0;

***-------------------------------------------------------------------------------
***                            Data for trade model
***-------------------------------------------------------------------------------

PARAMETERS
  p24_cap_absMaxGrowthRate(teTrade)                                             "Absolute maximum yearly growth rate for trade transportation capacity (TWa)"
      / gas_pipe 0.0
        lng_liq 0.020
        lng_gas 100.0
        lng_ves 999999.0
        coal_ves 999999.0 /
  p24_cap_relMaxGrowthRate(teTrade)                                             "Relative maximum yearly growth rate for trade transportation capacity (percent)"
      / gas_pipe 0.0
        lng_liq 0.01
        lng_gas 0.03
        lng_ves 999999.0
        coal_ves 999999.0 /
;

TABLE p24_disallowed(all_regi,all_regi,tradeModes)                    "Trade routes that are explicitly disallowed."
$include "./modules/24_trade/capacity/input/p24_disallowed.prn"
;

TABLE p24_distance(all_regi,all_regi)                                 "Distance between regions (in units of 1000km)"
$include "./modules/24_trade/capacity/input/p24_distance.prn"
;
p24_distance(regi,regi2) = p24_distance(regi,regi2)/1000;

*** EOF ./modules/24_trade/capacity/datainput.gms
