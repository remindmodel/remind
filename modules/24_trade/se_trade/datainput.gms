*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
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
pm_costsTradePeFinancial(regi,"Mport","peur")                   = 1e-06;

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

$ifthen.import_nzero_EU "%cm_import_EU%" == "nzero"

*** H2 trade:
***   Importing regions: Germany, 100 TWh/yr, and EWN, proportional to German values and FE|Gases demand by 2050 in reference run (NZero run without trade, or NPi?).
***   Exporting regions: UK, Norway and Spain (one-third each)
***   exponential curve starting by 2020 at 4 TWh for Germany

*** calculating share of FE demand per carrier at each region group
  loop(regi_group(ext_regi,regi),
    loop(seAgg,
      p24_FEShareInRegion(ttot,ext_regi,regi,seAgg) = 
        sum(enty$seAgg2se(seAgg,enty), sum(se2fe(enty,enty2,te), p_prodFEReference(ttot,regi,enty,enty2,te))) !! 2050 fe gas 
        /
        sum(regi2$regi_group(ext_regi,regi2), sum(enty$seAgg2se(seAgg,enty), sum(se2fe(enty,enty2,te), p_prodFEReference(ttot,regi2,enty,enty2,te))));
    );
  );

*** defining Germany H2 trade import flows
*** 2050 and onward
  p24_seTradeCapacity(t,"UKI","DEU","seh2")$(t.val ge 2050) = 100 * 1/3;
  p24_seTradeCapacity(t,"NEN","DEU","seh2")$(t.val ge 2050) = 100 * 2/3;
*** 2030
  p24_seTradeCapacity("2030","UKI","DEU","seh2") = 12 * 1/3;
  p24_seTradeCapacity("2030","NEN","DEU","seh2") = 12 * 2/3;

*** defining EWN H2 trade import flows
*** 2050 and onward
  p24_seTradeCapacity(t,"UK","EWN","seh2")$(t.val ge 2050) = 
    (100 / (p24_FEShareInRegion("2050","EUR_regi","DEU","all_sega") / (p24_FEShareInRegion("2050","EUR_regi","DEU","all_sega") + p24_FEShareInRegion("2050","EUR_regi","EWN","all_sega")))) !! total EU imports given DEU = 100 TWh/yr
    * p24_FEShareInRegion("2050","EUR_regi","EWN","all_sega") * 1/3;
  p24_seTradeCapacity(t,"ESW","EWN","seh2")$(t.val ge 2050) = 
    (100 / (p24_FEShareInRegion("2050","EUR_regi","DEU","all_sega") / (p24_FEShareInRegion("2050","EUR_regi","DEU","all_sega") + p24_FEShareInRegion("2050","EUR_regi","EWN","all_sega")))) !! total EU imports given DEU = 100 TWh/yr
    * p24_FEShareInRegion("2050","EUR_regi","EWN","all_sega") * 2/3;
*** 2030
  p24_seTradeCapacity("2030","UKI","EWN","seh2") = 8 * 1/3;
  p24_seTradeCapacity("2030","ESW","EWN","seh2") = 8 * 2/3;

*** exponential curve for years in between
  p24_seTradeCapacity(t,enty,enty2,"seh2")$(p24_seTradeCapacity("2050",enty,enty2,"seh2") and (t.val gt 2030 and t.val lt 2050)) = 
    ((power(p24_seTradeCapacity("2050",enty,enty2,"seh2"),1/4)) / p24_seTradeCapacity("2030",enty,enty2,"seh2")) - 1;

*** E-fuels trade:
***   All regions import proportionally to their 2050 FE|Transport|Pass|Aviation + FE|Industry|Chemicals in a reference run (NZero run without trade, or NPi?)
***   Exporting regions: SSA, LAM and MEA (one-third each)
***   Import quantities: exponential increase with 6 TWh/yr by 2030 for the EU27, and 500 TWh/yr by 2050 (Germany: 100 TWh/yr by 2050)
***   Imports are considered as pure e-liquids (no e-gases for now)

execute_load "input_ref.gdx", p24_demFeForEsReference = vm_demFeForEs.l;
execute_load "input_ref.gdx", p24_demFeIndSubReference = o37_demFeIndSub;

*** calculating share of FE aviation and chemicals demand at each region group
p24_aviationAndChemicalsFEShareInRegion(ttot,ext_regi,regi) = 
  ( 
    p24_demFeForEsReference(ttot,regi,"fedie","esdie_pass_lo","te_esdie_pass_lo") + !! aviation FE demand
    sum((entySe,entyFe,emiMkt)$(sefe(entySe,entyFe) AND entyFe2Sector(entyFe,"indst") AND sector2emiMkt("indst",emiMkt)), o37_demFeIndSub(ttot,regi,entySe,entyFe,"chemicals",emiMkt)) !! chemicals FE demand
  ) /
  sum(regi2$regi_group(ext_regi,regi2), 
    p24_demFeForEsReference(ttot,regi2,"fedie","esdie_pass_lo","te_esdie_pass_lo") + !! aviation FE demand
    sum((entySe,entyFe,emiMkt)$(sefe(entySe,entyFe) AND entyFe2Sector(entyFe,"indst") AND sector2emiMkt("indst",emiMkt)), o37_demFeIndSub(ttot,regi2,entySe,entyFe,"chemicals",emiMkt)) !! chemicals FE demand
  )
  ;

*** defining Germany seliqsyn trade import flows
  loop(regi$(sameas(regi,"SSA") or sameas(regi,"LAM") or sameas(regi,"MEA")), !! supplier regions provide each one-third of total imports
*** 2050 and onward
    p24_seTradeCapacity(t,regi,regi2,"seliqsyn")$(t.val ge 2050) = 
      ( 100 / p24_aviationAndChemicalsFEShareInRegion("2050","EUR_regi","DEU") ) !! total EUR imports based on Germany values
      * p24_aviationAndChemicalsFEShareInRegion("2050","EUR_regi",regi2) * 1/3;
*** 2030 
    p24_seTradeCapacity("2030",regi,regi2,"seliqsyn") = (6 * p24_aviationAndChemicalsFEShareInRegion("2050","EUR_regi",regi2)) * 1/3;
  );

*** exponential curve for years in between
  p24_seTradeCapacity(t,enty,enty2,"seliqsyn")$(p24_seTradeCapacity("2050",enty,enty2,"seliqsyn") and (t.val gt 2030 and t.val lt 2050)) = 
    ((power(p24_seTradeCapacity("2050",enty,enty2,"seliqsyn"),1/4)) / p24_seTradeCapacity("2030",enty,enty2,"seliqsyn")) - 1;

display p24_seTradeCapacity;

$endif.import_nzero_EU

*** EOF ./modules/24_trade/se_trade/datainput.gms
