*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
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

*** parameters used in cm_import_EU scenarios nzero, nzero_bio and high_bio

*** calculate regional share of each region in the total of region group ext_regi, with respect to FE demand, for each aggregated carrier (liquids, gases,solids)
p24_seAggReference(ttot,regi,seAgg) = sum(enty$seAgg2se(seAgg,enty), sum(se2fe(enty,enty2,te), pm_prodFEReference(ttot,regi,enty,enty2,te)));
p24_FEregiShareInRegiGroup(ttot,ext_regi,regi,seAgg)$(regi_group(ext_regi,regi) and p24_seAggReference(ttot,regi,seAgg)) = p24_seAggReference(ttot,regi,seAgg) / sum(regi2$regi_group(ext_regi,regi2), p24_seAggReference(ttot,regi2,seAgg));

execute_load "input_ref.gdx", p24_demFeForEsReference = vm_demFeForEs.l;
execute_load "input_ref.gdx", p24_demFeIndSubReference = o37_demFeIndSub;

*** calculate regional share of each region in the total of region group ext_regi with respect to FE demand, for chemicals + aviation liquids
p24_aviationAndChemicalsFE(ttot,regi) = p24_demFeForEsReference(ttot,regi,"fedie","esdie_pass_lo","te_esdie_pass_lo") + !! aviation FE demand
  sum((entySe,entyFe,emiMkt)$(sefe(entySe,entyFe) AND entyFe2Sector(entyFe,"indst") AND sector2emiMkt("indst",emiMkt) AND (sameas("fehos",entyFe))), p24_demFeIndSubReference(ttot,regi,entySe,entyFe,"chemicals",emiMkt)); !! chemicals FE demand
p24_aviationAndChemicalsFEShareInRegion(ttot,ext_regi,regi)$(regi_group(ext_regi,regi) and p24_aviationAndChemicalsFE(ttot,regi)) = 
  p24_aviationAndChemicalsFE(ttot,regi) / sum(regi2$regi_group(ext_regi,regi2), p24_aviationAndChemicalsFE(ttot,regi2));

* display p24_aviationAndChemicalsFEShareInRegion;

$ifthen.import_nzero_EU "%cm_import_EU%" == "nzero"

*** NZero scenario with 2050 levels for: 
*** - h2 imports -> DEU: 100 TWh/yr, EWN: ~75 TWh/yr; total EU: ~0.63 EJ
*** - seliqsyn imports -> DEU: 100 TWh/yr, other EU regions proportional to aviation and chemicals FE demand; Total EU: ~ 2 EJ by 2050

*** H2 trade:
***   Importing regions: Germany, 100 TWh/yr, and EWN, proportional to German values and FE|Gases demand by 2050 in the reference NPi run.
***   Exporting regions: UK, Norway and Spain (one-third each)
***   exponential curve starting at 12 TWh by 2030 for Germany


*** defining Germany H2 trade import flows
*** 2050 and onward
  p24_seTradeCapacity(t,regi,"DEU","seh2")$((t.val ge 2050) and (sameas(regi,"UKI") or sameas(regi,"NEN") or sameas(regi,"ESW"))) = (100 / sm_TWa_2_TWh) * 1/3; !! each supplier region provides one-third of the imports
*** 2030
  p24_seTradeCapacity("2030",regi,"DEU","seh2")$((sameas(regi,"UKI") or sameas(regi,"NEN") or sameas(regi,"ESW"))) = (12 / sm_TWa_2_TWh) * 1/3; !! each supplier region provides one-third of the imports

*** defining EWN H2 trade import flows
*** 2050 and onward
  p24_seTradeCapacity(t,regi,"EWN","seh2")$((t.val ge 2050) and (sameas(regi,"UKI") or sameas(regi,"NEN") or sameas(regi,"ESW"))) = (100 / sm_TWa_2_TWh) * (p24_FEregiShareInRegiGroup("2050","EUR_regi","EWN","all_sega")/p24_FEregiShareInRegiGroup("2050","EUR_regi","DEU","all_sega")) * 1/3;
*** 2030
  p24_seTradeCapacity("2030",regi,"EWN","seh2")$((sameas(regi,"UKI") or sameas(regi,"NEN") or sameas(regi,"ESW"))) = (12 / sm_TWa_2_TWh) * (p24_FEregiShareInRegiGroup("2050","EUR_regi","EWN","all_sega")/p24_FEregiShareInRegiGroup("2050","EUR_regi","DEU","all_sega")) * 1/3;

*** exponential curve for years in between
  p24_seTradeCapacity(t,regi,regi2,"seh2")$(p24_seTradeCapacity("2050",regi,regi2,"seh2") and (t.val gt 2030 and t.val lt 2050)) = 
    p24_seTradeCapacity("2030",regi,regi2,"seh2") * ((sqrt(sqrt(p24_seTradeCapacity("2050",regi,regi2,"seh2") / p24_seTradeCapacity("2030",regi,regi2,"seh2")))) ** ((t.val - 2030)/5)) ;

*** E-fuels (e-liquids) trade:
***   All regions (EU-27 and UKI) import proportionally to their 2050 FE|Transport|Pass|Aviation + FE|Industry|Chemicals|Liquids in the reference NPi run.
***   Exporting regions: SSA, LAM and MEA (one-third each)
***   Import quantities: exponential increase from 1.2 TWh/yr by 2030 to 100 TWh/yr by 2050 for Germany

*** defining Germany seliqsyn trade import flows
  loop(regi$(sameas(regi,"SSA") or sameas(regi,"LAM") or sameas(regi,"MEA")), 
*** 2050 and onward
    p24_seTradeCapacity(t,regi,regi2,"seliqsyn")$(t.val ge 2050) = 
      ( (100 / sm_TWa_2_TWh)  / p24_aviationAndChemicalsFEShareInRegion("2050","EUR_regi","DEU") ) !! total EUR imports based on Germany values
      * p24_aviationAndChemicalsFEShareInRegion("2050","EUR_regi",regi2) 
      * 1/3; !! each supplier region provide one-third of total imports
*** 2030 
    p24_seTradeCapacity("2030",regi,regi2,"seliqsyn") = 
      ((0.3 / sm_TWa_2_TWh) / p24_aviationAndChemicalsFEShareInRegion("2050","EUR_regi","DEU") ) 
      * p24_aviationAndChemicalsFEShareInRegion("2050","EUR_regi",regi2) 
      * 1/3;
  );

*** exponential curve for years in between
  p24_seTradeCapacity(t,regi,regi2,"seliqsyn")$(p24_seTradeCapacity("2050",regi,regi2,"seliqsyn") and (t.val gt 2030 and t.val lt 2050)) = 
    p24_seTradeCapacity("2030",regi,regi2,"seliqsyn") * ((sqrt(sqrt(p24_seTradeCapacity("2050",regi,regi2,"seliqsyn") / p24_seTradeCapacity("2030",regi,regi2,"seliqsyn")))) ** ((t.val - 2030)/5)) ;

display p24_seTradeCapacity;

$endif.import_nzero_EU

$ifthen.import_nzero_bio_EU "%cm_import_EU%" == "nzero_bio"

*** EU net-zero trade scenario for high biomass availability sensitivity with 2050 levels for: 
*** - h2 imports -> DEU: 100 TWh/yr, EWN: ~75 TWh/yr; total EU: ~0.63 EJ
*** - seliqsyn imports (reduced pull due to bioliquids availability) -> DEU: 50 TWh/yr, other EU regions proportional to aviation and chemicals FE demand; Total EU: ~ 1 EJ by 2050
*** - seliqbio imports -> EU: 7.44 EJ (~ 8 EJ of biomass primary energy, assuming pebioil.seliqbio.biodiesel eta)

*** H2 trade:
***   Importing regions: Germany, 100 TWh/yr, and EWN, proportional to German values and FE|Gases demand by 2050 in the reference NPi run.
***   Exporting regions: UK, Norway and Spain (one-third each)
***   exponential curve starting at 12 TWh by 2030 for Germany

*** defining Germany H2 trade import flows
*** 2050 and onward
  p24_seTradeCapacity(t,regi,"DEU","seh2")$((t.val ge 2050) and (sameas(regi,"UKI") or sameas(regi,"NEN") or sameas(regi,"ESW"))) = (100 / sm_TWa_2_TWh) * 1/3; !! each supplier region provides one-third of the imports
*** 2030
  p24_seTradeCapacity("2030",regi,"DEU","seh2")$((sameas(regi,"UKI") or sameas(regi,"NEN") or sameas(regi,"ESW"))) = (12 / sm_TWa_2_TWh) * 1/3; !! each supplier region provides one-third of the imports

*** defining EWN H2 trade import flows
*** 2050 and onward
  p24_seTradeCapacity(t,regi,"EWN","seh2")$((t.val ge 2050) and (sameas(regi,"UKI") or sameas(regi,"NEN") or sameas(regi,"ESW"))) = (100 / sm_TWa_2_TWh) * (p24_FEregiShareInRegiGroup("2050","EUR_regi","EWN","all_sega")/p24_FEregiShareInRegiGroup("2050","EUR_regi","DEU","all_sega")) * 1/3;
*** 2030
  p24_seTradeCapacity("2030",regi,"EWN","seh2")$((sameas(regi,"UKI") or sameas(regi,"NEN") or sameas(regi,"ESW"))) = (12 / sm_TWa_2_TWh) * (p24_FEregiShareInRegiGroup("2050","EUR_regi","EWN","all_sega")/p24_FEregiShareInRegiGroup("2050","EUR_regi","DEU","all_sega")) * 1/3;

*** exponential curve for years in between
  p24_seTradeCapacity(t,regi,regi2,"seh2")$(p24_seTradeCapacity("2050",regi,regi2,"seh2") and (t.val gt 2030 and t.val lt 2050)) = 
    p24_seTradeCapacity("2030",regi,regi2,"seh2") * ((sqrt(sqrt(p24_seTradeCapacity("2050",regi,regi2,"seh2") / p24_seTradeCapacity("2030",regi,regi2,"seh2")))) ** ((t.val - 2030)/5)) ;

*** E-fuels (e-liquids) trade:
***   All regions (EU-27 and UKI) import proportionally to their 2050 FE|Transport|Pass|Aviation + FE|Industry|Chemicals|Liquids in the reference NPi run.
***   Exporting regions: SSA, LAM and MEA (one-third each)
***   Import quantities: exponential increase from 0.6 TWh/yr by 2030 to 50 TWh/yr by 2050 for Germany

*** defining Germany seliqsyn trade import flows
  loop(regi$(sameas(regi,"SSA") or sameas(regi,"LAM") or sameas(regi,"MEA")),
*** 2050 and onward
    p24_seTradeCapacity(t,regi,regi2,"seliqsyn")$(t.val ge 2050) = 
      ( (50 / sm_TWa_2_TWh)  / p24_aviationAndChemicalsFEShareInRegion("2050","EUR_regi","DEU") ) !! total EUR imports based on Germany values
      * p24_aviationAndChemicalsFEShareInRegion("2050","EUR_regi",regi2) 
      * 1/3; !! each supplier region provide one-third of total imports
*** 2030 
    p24_seTradeCapacity("2030",regi,regi2,"seliqsyn") = 
      ( (0.3 / sm_TWa_2_TWh) / p24_aviationAndChemicalsFEShareInRegion("2050","EUR_regi","DEU") )
      * p24_aviationAndChemicalsFEShareInRegion("2050","EUR_regi",regi2) 
      * 1/3; 
  );

*** exponential curve for years in between
  p24_seTradeCapacity(t,regi,regi2,"seliqsyn")$(p24_seTradeCapacity("2050",regi,regi2,"seliqsyn") and (t.val gt 2030 and t.val lt 2050)) = 
    p24_seTradeCapacity("2030",regi,regi2,"seliqsyn") * ((sqrt(sqrt(p24_seTradeCapacity("2050",regi,regi2,"seliqsyn") / p24_seTradeCapacity("2030",regi,regi2,"seliqsyn")))) ** ((t.val - 2030)/5)) ;


*** bio-liquids trade:
***   All regions (EU-27 and UKI) import proportionally to their 2050 FE|Transport|Pass|Aviation + FE|Industry|Chemicals|Liquids in the reference NPi run.
***   Exporting regions: SSA and LAM (half each). LAM and SSA as exporting regions were chosen based on this paper: https://doi.org/10.1111/gcbb.12614
***   Import quantities: exponential increase from 0.3 EJ by 2030 to 7.44 EJ by 2050 for EU-27

*** defining EU-27 & UK seliqbio trade import flows
  loop(regi$(sameas(regi,"SSA") or sameas(regi,"LAM")),
*** 2050 and onward
    p24_seTradeCapacity(t,regi,regi2,"seliqbio")$(t.val ge 2050) = 
      ( (7.44 * sm_EJ_2_TWa) / sum(regi3$regi_group("EU27_regi",regi3),p24_aviationAndChemicalsFEShareInRegion("2050","EUR_regi",regi3)) ) !! total EUR imports based on EU-27 values
      * p24_aviationAndChemicalsFEShareInRegion("2050","EUR_regi",regi2) 
      * 1/2; !! each supplier region provide half of total imports
*** 2030 
    p24_seTradeCapacity("2030",regi,regi2,"seliqbio") = 
      ( (0.3 * sm_EJ_2_TWa) / sum(regi3$regi_group("EU27_regi",regi3),p24_aviationAndChemicalsFEShareInRegion("2050","EUR_regi",regi3)) ) !! total EUR imports based on EU-27 values
      * p24_aviationAndChemicalsFEShareInRegion("2050","EUR_regi",regi2) 
      * 1/2;
  );

*** exponential curve for years in between
  p24_seTradeCapacity(t,regi,regi2,"seliqbio")$(p24_seTradeCapacity("2050",regi,regi2,"seliqbio") and (t.val gt 2030 and t.val lt 2050)) = 
    p24_seTradeCapacity("2030",regi,regi2,"seliqbio") * ((sqrt(sqrt(p24_seTradeCapacity("2050",regi,regi2,"seliqbio") / p24_seTradeCapacity("2030",regi,regi2,"seliqbio")))) ** ((t.val - 2030)/5)) ;

display p24_seTradeCapacity;

$endif.import_nzero_bio_EU

$ifthen.high_bio "%cm_import_EU%" == "high_bio"

*** EU net-zero trade scenario for high biomass availability sensitivity with 2050 levels for: 
*** - seliqbio imports -> EU: 7.44 EJ (~ 8 EJ of biomass primary energy, assuming pebioil.seliqbio.biodiesel eta)

*** bio-liquids trade:
***   All regions (EU-27 and UKI) import proportionally to their 2050 FE|Transport|Pass|Aviation + FE|Industry|Chemicals|Liquids in the reference NPi run.
***   Exporting regions: SSA and LAM (half each). LAM and SSA as exporting regions were chosen based on this paper: https://doi.org/10.1111/gcbb.12614
***   Import quantities: exponential increase from 0.3 EJ by 2030 to 7.44 EJ by 2050 for EU-27

*** defining EU-27 & UK seliqbio trade import flows
  loop(regi$(sameas(regi,"SSA") or sameas(regi,"LAM")),
*** 2050 and onward
    p24_seTradeCapacity(t,regi,regi2,"seliqbio")$(t.val ge 2050) = 
      ( (7.44 * sm_EJ_2_TWa) / sum(regi3$regi_group("EU27_regi",regi3),p24_aviationAndChemicalsFEShareInRegion("2050","EUR_regi",regi3)) ) !! total EUR imports based on EU-27 values
      * p24_aviationAndChemicalsFEShareInRegion("2050","EUR_regi",regi2) 
      * 1/2; !! each supplier region provide half of total imports
*** 2030 
    p24_seTradeCapacity("2030",regi,regi2,"seliqbio") = 
      ( (0.3 * sm_EJ_2_TWa) / sum(regi3$regi_group("EU27_regi",regi3),p24_aviationAndChemicalsFEShareInRegion("2050","EUR_regi",regi3)) ) !! total EUR imports based on EU-27 values
      * p24_aviationAndChemicalsFEShareInRegion("2050","EUR_regi",regi2) 
      * 1/2;
  );

*** exponential curve for years in between
  p24_seTradeCapacity(t,regi,regi2,"seliqbio")$(p24_seTradeCapacity("2050",regi,regi2,"seliqbio") and (t.val gt 2030 and t.val lt 2050)) = 
    p24_seTradeCapacity("2030",regi,regi2,"seliqbio") * ((sqrt(sqrt(p24_seTradeCapacity("2050",regi,regi2,"seliqbio") / p24_seTradeCapacity("2030",regi,regi2,"seliqbio")))) ** ((t.val - 2030)/5)) ;

display p24_seTradeCapacity;

$endif.high_bio

*** EOF ./modules/24_trade/se_trade/datainput.gms
