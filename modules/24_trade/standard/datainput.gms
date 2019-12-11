*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/24_trade/standard/datainput.gms


pm_Xport0("2005",regi,peFos) = 0;

*ML* Reintroduction of trade cost for composite good (based on export/import value difference for non-energy goods in GTAP6)
pm_tradecostgood(regi)        = 0.03;


*NB* include data and parameters for upper bounds on fossil fuel transport
parameter f24_IO_trade(tall,all_regi,all_enty,char)        "Energy trade bounds based on IEA data"
/
$ondelim
$include "./modules/24_trade/standard/input/f24_IO_trade.cs4r"
$offdelim
/
;
pm_IO_trade(ttot,regi,enty,char) = f24_IO_trade(ttot,regi,enty,char) * sm_EJ_2_TWa;

*LB* use scaled data for export to guarantee net trade = 0 for each traded good
loop(tradePe,
    loop(t,
       if(sum(regi2, pm_IO_trade(t,regi2,tradePe,"Xport")) ne 0,
            pm_IO_trade(t,regi,tradePe,"Xport") = pm_IO_trade(t,regi,tradePe,"Xport") * sum(regi2, pm_IO_trade(t,regi2,tradePe,"Mport")) / sum(regi2, pm_IO_trade(t,regi2,tradePe,"Xport"));
       );
    );
);
display pm_IO_trade;



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
pm_costsTradePeFinancial(regi,"XportElasticity", tradePe(enty)) = 100;
pm_costsTradePeFinancial(regi, "tradeFloor", tradePe(enty))     = 0.0125;

*DK* Only for SSP cases other than SSP2: use default trade costs
if(cm_tradecost_bio = 1,
pm_costsTradePeFinancial(regi,"Xport", "pebiolc") = pm_costsTradePeFinancial(regi,"Xport", "pebiolc")/2;
);

pm_costsTradePeFinancial(regi,"Xport", "pegas") = cm_trdcst * pm_costsTradePeFinancial(regi,"Xport", "pegas") ;
pm_costsTradePeFinancial(regi,"XportElasticity","pegas") = cm_trdadj *pm_costsTradePeFinancial(regi,"XportElasticity","pegas");


*** EOF ./modules/24_trade/standard/datainput.gms