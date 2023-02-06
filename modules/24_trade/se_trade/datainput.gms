*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
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

*** Adjust tradecosts based on switch
pm_costsTradePeFinancial(regi,"Xport", "pebiolc") = pm_costsTradePeFinancial(regi,"Xport", "pebiolc") * cm_tradecostBio;

pm_costsTradePeFinancial(regi,"Xport", "pegas") = 1.5 * pm_costsTradePeFinancial(regi,"Xport", "pegas") ;
pm_costsTradePeFinancial(regi,"XportElasticity","pegas") = 2 * pm_costsTradePeFinancial(regi,"XportElasticity","pegas");

*** initialize secondary energy trade capacity
p24_seTradeCapacity(t,regi2,regi,entySe) = 0;

*** Secondary Energy exogenously defined trade scenarios
$IFTHEN.trade_SE_exog not "%cm_trade_SE_exog%" == "off"
loop( (ttot,ttot2,ext_regi,ext_regi2,entySe)$(p24_trade_exog(ttot,ttot2,ext_regi,ext_regi2,entySe)),
  loop(regi$regi_groupExt(ext_regi,regi),
    loop(regi2$regi_groupExt(ext_regi2,regi2),

*** define trade quantities to converge to in the long-term (ttot2)
      p24_seTradeCapacity(t,regi,regi2,entySe)$(t.val ge ttot2.val)=
        p24_trade_exog(ttot,ttot2,ext_regi,ext_regi2,entySe)
          * sm_EJ_2_TWa
          * pm_gdp(t,regi) / sum(regi3$(regi_groupExt(ext_regi,regi3)),pm_gdp(t,regi3))
          * pm_gdp(t,regi2) / sum(regi4$(regi_groupExt(ext_regi2,regi4)),pm_gdp(t,regi4));
*** define ramp-up of trade quantities, linear increase from ttot (start year) to ttot2 (end year), 
*** ttot should have first non-zero values
      p24_seTradeCapacity(t,regi,regi2,entySe)$(t.val ge (ttot.val-pm_ts(ttot))
                                            AND t.val lt ttot2.val) =
        p24_trade_exog(ttot,ttot2,ext_regi,ext_regi2,entySe)
        * sm_EJ_2_TWa
        * pm_gdp(t,regi) / sum(regi3$(regi_groupExt(ext_regi,regi3)),pm_gdp(t,regi3))
        * pm_gdp(t,regi2) / sum(regi4$(regi_groupExt(ext_regi2,regi4)),pm_gdp(t,regi4))
        * ((t.val - (ttot.val-pm_ts(ttot))) / (ttot2.val - (ttot.val-pm_ts(ttot))));
    );
  );
);
$ENDIF.trade_SE_exog

*** Scenario Assumptions for Imports to the EU from MEA (Ariadne Scenarios)
p24_seTrade_Quantity(regi,regi2,entySe) = 0;

$ifthen.import_h2_EU "%cm_import_EU%" == "bal"
*** EU
  p24_seTrade_Quantity("MEA",regi2,"seh2")$(regi_group("EU27_regi",regi2)) = 1*sm_EJ_2_TWa*pm_gdp("2015",regi2) / sum(regi3$(regi_group("EU27_regi",regi3)),pm_gdp("2015",regi3));
  p24_seTrade_Quantity("MEA",regi2,"seliqsyn")$(regi_group("EU27_regi",regi2)) = 1*sm_EJ_2_TWa*pm_gdp("2015",regi2) / sum(regi3$(regi_group("EU27_regi",regi3)),pm_gdp("2015",regi3));


$ifthen.import_h2_ariadne "%cm_import_ariadne%" == "on"
*** Germany (overrides value from EU above)  
  p24_seTrade_Quantity("MEA","DEU","seel") = 0.25*sm_EJ_2_TWa;
  p24_seTrade_Quantity("MEA","DEU","seh2") = 0.75*sm_EJ_2_TWa;
  p24_seTrade_Quantity("MEA","DEU","seliqsyn") = 0.75*sm_EJ_2_TWa;
$endif.import_h2_ariadne


$endif.import_h2_EU


$ifthen.import_h2_EU "%cm_import_EU%" == "low_elec"
*** EU
  p24_seTrade_Quantity("MEA",regi2,"seh2")$(regi_group("EU27_regi",regi2)) = 0.5*sm_EJ_2_TWa*pm_gdp("2015",regi2) / sum(regi3$(regi_group("EU27_regi",regi3)),pm_gdp("2015",regi3));
  p24_seTrade_Quantity("MEA",regi2,"seliqsyn")$(regi_group("EU27_regi",regi2)) = 0.5*sm_EJ_2_TWa*pm_gdp("2015",regi2) / sum(regi3$(regi_group("EU27_regi",regi3)),pm_gdp("2015",regi3));

$ifthen.import_h2_ariadne "%cm_import_ariadne%" == "on"
*** Germany (overrides value from EU above)  
  p24_seTrade_Quantity("MEA","DEU","seh2") = 0.5*sm_EJ_2_TWa;
  p24_seTrade_Quantity("MEA","DEU","seliqsyn") = 0.3*sm_EJ_2_TWa;
$endif.import_h2_ariadne
$endif.import_h2_EU

$ifthen.import_h2_EU "%cm_import_EU%" == "high_elec"
*** EU
  p24_seTrade_Quantity("MEA",regi2,"seh2")$(regi_group("EU27_regi",regi2)) = 1*sm_EJ_2_TWa*pm_gdp("2015",regi2) / sum(regi3$(regi_group("EU27_regi",regi3)),pm_gdp("2015",regi3));
  p24_seTrade_Quantity("MEA",regi2,"seliqsyn")$(regi_group("EU27_regi",regi2)) = 4*sm_EJ_2_TWa*pm_gdp("2015",regi2) / sum(regi3$(regi_group("EU27_regi",regi3)),pm_gdp("2015",regi3));

$ifthen.import_h2_ariadne "%cm_import_ariadne%" == "on"
*** Germany (overrides value from EU above)  
  p24_seTrade_Quantity("MEA","DEU","seel") = 0.5*sm_EJ_2_TWa;
  p24_seTrade_Quantity("MEA","DEU","seh2") = 1*sm_EJ_2_TWa;
  p24_seTrade_Quantity("MEA","DEU","seliqsyn") = 0.3*sm_EJ_2_TWa;
$endif.import_h2_ariadne
$endif.import_h2_EU

$ifthen.import_h2_EU "%cm_import_EU%" == "low_h2"
*** EU
  p24_seTrade_Quantity("MEA",regi2,"seh2")$(regi_group("EU27_regi",regi2)) = 1*sm_EJ_2_TWa*pm_gdp("2015",regi2) / sum(regi3$(regi_group("EU27_regi",regi3)),pm_gdp("2015",regi3));

$ifthen.import_h2_ariadne "%cm_import_ariadne%" == "on"
*** Germany (overrides value from EU above)  
  p24_seTrade_Quantity("MEA","DEU","seh2") = 0.5*sm_EJ_2_TWa;
  p24_seTrade_Quantity("MEA","DEU","seliqsyn") = 0.3*sm_EJ_2_TWa;
$endif.import_h2_ariadne
$endif.import_h2_EU

$ifthen.import_h2_EU "%cm_import_EU%" == "high_h2"
*** EU
  p24_seTrade_Quantity("MEA",regi2,"seh2")$(regi_group("EU27_regi",regi2)) = 5*sm_EJ_2_TWa*pm_gdp("2015",regi2) / sum(regi3$(regi_group("EU27_regi",regi3)),pm_gdp("2015",regi3));

$ifthen.import_h2_ariadne "%cm_import_ariadne%" == "on"
*** Germany (overrides value from EU above)  
  p24_seTrade_Quantity("MEA","DEU","seel") = 0.3*sm_EJ_2_TWa;
  p24_seTrade_Quantity("MEA","DEU","seh2") = 2*sm_EJ_2_TWa;
  p24_seTrade_Quantity("MEA","DEU","seliqsyn") = 0.5*sm_EJ_2_TWa;
$endif.import_h2_ariadne
$endif.import_h2_EU

$ifthen.import_h2_EU "%cm_import_EU%" == "low_synf"
*** EU
  p24_seTrade_Quantity("MEA",regi2,"seliqsyn")$(regi_group("EU27_regi",regi2)) = 0.75*sm_EJ_2_TWa*pm_gdp("2015",regi2) / sum(regi3$(regi_group("EU27_regi",regi3)),pm_gdp("2015",regi3));
  p24_seTrade_Quantity("MEA",regi2,"segasyn")$(regi_group("EU27_regi",regi2)) = 0.25*sm_EJ_2_TWa*pm_gdp("2015",regi2) / sum(regi3$(regi_group("EU27_regi",regi3)),pm_gdp("2015",regi3));

$ifthen.import_h2_ariadne "%cm_import_ariadne%" == "on"
*** Germany (overrides value from EU above) 
  p24_seTrade_Quantity("MEA","DEU","seliqsyn") = 0.5*sm_EJ_2_TWa;
  p24_seTrade_Quantity("MEA","DEU","segasyn") = 0.1*sm_EJ_2_TWa;
$endif.import_h2_ariadne
$endif.import_h2_EU

$ifthen.import_h2_EU "%cm_import_EU%" == "high_synf"
*** EU
  p24_seTrade_Quantity("MEA",regi2,"seliqsyn")$(regi_group("EU27_regi",regi2)) = 3.5*sm_EJ_2_TWa*pm_gdp("2015",regi2) / sum(regi3$(regi_group("EU27_regi",regi3)),pm_gdp("2015",regi3));
  p24_seTrade_Quantity("MEA",regi2,"segasyn")$(regi_group("EU27_regi",regi2)) = 1.5*sm_EJ_2_TWa*pm_gdp("2015",regi2) / sum(regi3$(regi_group("EU27_regi",regi3)),pm_gdp("2015",regi3));

$ifthen.import_h2_ariadne "%cm_import_ariadne%" == "on"
*** Germany (overrides value from EU above) 
  p24_seTrade_Quantity("MEA","DEU","seel") = 0.3*sm_EJ_2_TWa;
  p24_seTrade_Quantity("MEA","DEU","seh2") = 0.5*sm_EJ_2_TWa; 
  p24_seTrade_Quantity("MEA","DEU","seliqsyn") = 1.6*sm_EJ_2_TWa;
  p24_seTrade_Quantity("MEA","DEU","segasyn") = 0.36*sm_EJ_2_TWa;
$endif.import_h2_ariadne
$endif.import_h2_EU

$ifthen.import_h2_EU not "%cm_import_EU%" == "off"
*** phase in import quantities given by p24_seTrade_Quantity linearly from 2035 to 2050
p24_seTradeCapacity(t,regi,regi2,entySe)$(t.val ge 2050) = p24_seTrade_Quantity(regi,regi2,entySe);
p24_seTradeCapacity(t,regi,regi2,entySe)$(t.val eq 2045) = p24_seTrade_Quantity(regi,regi2,entySe)*0.75;
p24_seTradeCapacity(t,regi,regi2,entySe)$(t.val eq 2040) = p24_seTrade_Quantity(regi,regi2,entySe)*0.5;
p24_seTradeCapacity(t,regi,regi2,entySe)$(t.val eq 2035) = p24_seTrade_Quantity(regi,regi2,entySe)*0.25;
$endif.import_h2_EU

*** in energy security scenario, phase-in trade earlier already from 2030
$ifthen.import_h2_EU "%cm_Ger_Pol%" == "ensec"
*** earlier phase-in of imports, start 2030 already 
*** with about 300 PJ/yr H2+Synfuel if cm_import_EU = "bal" and cm_import_ariadne = "on"
*** corresponds to 10MtH2 2030 import goal of EU disaggregated to Germany via GDP share
  p24_seTradeCapacity(t,regi,regi2,entySe)$(t.val ge 2050) = p24_seTrade_Quantity(regi,regi2,entySe);
  p24_seTradeCapacity(t,regi,regi2,entySe)$(t.val eq 2045) = p24_seTrade_Quantity(regi,regi2,entySe)*0.75;
  p24_seTradeCapacity(t,regi,regi2,entySe)$(t.val eq 2040) = p24_seTrade_Quantity(regi,regi2,entySe)*0.6;
  p24_seTradeCapacity(t,regi,regi2,entySe)$(t.val eq 2035) = p24_seTrade_Quantity(regi,regi2,entySe)*0.4;
  p24_seTradeCapacity(t,regi,regi2,entySe)$(t.val eq 2030) = p24_seTrade_Quantity(regi,regi2,entySe)*0.2;
$endif.import_h2_EU


*** EOF ./modules/24_trade/se_trade/datainput.gms
