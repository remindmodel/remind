*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/36_buildings/simple/datainput.gms
*** substitution elasticities
Parameter 
  p36_cesdata_sigma(all_in)  "substitution elasticities"
  /
        enb    0.5
        enhb   3.0
        enhgab 5.0
  /
;
pm_cesdata_sigma(ttot,in)$p36_cesdata_sigma(in) = p36_cesdata_sigma(in);

pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) le 2025  AND sameAs(in, "enb")) = 0.1;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2030  AND sameAs(in, "enb")) = 0.3;

pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) le 2025  AND sameAs(in, "enhb")) = 0.1;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2030  AND sameAs(in, "enhb")) = 0.3;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2035  AND sameAs(in, "enhb")) = 0.6;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2040  AND sameAs(in, "enhb")) = 1.3;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2045  AND sameAs(in, "enhb")) = 2.0;

pm_cesdata_sigma(ttot,"enhgab")$ (ttot.val le 2020) = 0.1;
pm_cesdata_sigma(ttot,"enhgab")$ (ttot.val eq 2025) = 0.6;
pm_cesdata_sigma(ttot,"enhgab")$ (ttot.val eq 2030) = 1.2;
pm_cesdata_sigma(ttot,"enhgab")$ (ttot.val eq 2035) = 2;
pm_cesdata_sigma(ttot,"enhgab")$ (ttot.val eq 2040) = 3;


$IFTHEN.cm_INNOPATHS_enb not "%cm_INNOPATHS_enb%" == "off" 
  pm_cesdata_sigma(ttot,"enb")$pm_cesdata_sigma(ttot,"enb") = pm_cesdata_sigma(ttot,"enb") * %cm_INNOPATHS_enb%;
  pm_cesdata_sigma(ttot,"enb")$( (pm_cesdata_sigma(ttot,"enb") gt 0.8) AND (pm_cesdata_sigma(ttot,"enb") lt 1)) = 0.8; !! If complementary factors, sigma should be below 0.8
  pm_cesdata_sigma(ttot,"enb")$( (pm_cesdata_sigma(ttot,"enb") ge 1) AND (pm_cesdata_sigma(ttot,"enb") lt 1.2)) = 1.2; !! If substitution factors, sigma should be above 1.2
$ENDIF.cm_INNOPATHS_enb



*** additional H2 cost parameters
s36_costAddH2Inv = cm_build_H2costAddH2Inv;
s36_costDecayStart = cm_build_costDecayStart;
s36_costDecayEnd = cm_build_H2costDecayEnd;

*** FE Share Bounds
*** intialize buildings FE share bounds as non-activated
pm_shfe_up(ttot,regi,entyFe,"build")=0;
pm_shfe_lo(ttot,regi,entyFe,"build")=0;
pm_shGasLiq_fe_up(ttot,regi,"build")=0;
pm_shGasLiq_fe_lo(ttot,regi,"build")=0;

*** RR: lower bound for gases and liquids share in buildings for an incumbents scenario
$ifthen.feShareScenario "%cm_feShareLimits%" == "incumbents"
  pm_shGasLiq_fe_lo(t,regi,"build")$(t.val ge 2050) = 0.25;
  pm_shGasLiq_fe_lo(t,regi,"build")$(t.val ge 2030 AND t.val le 2045) = 0.15 + (0.10/20)*(t.val-2030);
$endif.feShareScenario

*** FS: bounds for scenarios with a limited share of FE buildings district heat in EU regions
if ((cm_HeatLim_b lt 1),
  pm_shfe_up(t,regi,"fehes","build")$(regi_group("EUR_regi",regi) AND t.val gt 2030 AND t.val lt 2100) = cm_HeatLim_b+0.05;
  pm_shfe_up(t,regi,"fehes","build")$(regi_group("EUR_regi",regi) AND t.val gt 2040 AND t.val lt 2100) = cm_HeatLim_b;
);

*** FS: bounds for scenarios with a limited share of FE buildings electricity in EU regions
if ((cm_ElLim_b lt 1),
  pm_shfe_up(t,regi,"feels","build")$(regi_group("EUR_regi",regi) AND t.val gt 2030 AND t.val lt 2100) = cm_ElLim_b+0.05;
  pm_shfe_up(t,regi,"feels","build")$(regi_group("EUR_regi",regi) AND t.val gt 2040 AND t.val lt 2100) = cm_ElLim_b;
);

*** Heat pumps markup cost: 0.2 €/kwh = 0.2 / ((10^12)/(10^9*8760)) T$/TWa = 1.752 T$/TWa
p36_heatPumpMkup(t,regi) = 1.752;
*** District heating markup cost: 7$/GJ = 7 * sm_DpGJ_2_TDpTWa T$/TWa = 7 * 0.03154 T$/TWa = 0.22078 T$/TWa
p36_districtHeatingMkup(ttot,all_regi) = 0.22078;

*** EOF ./modules/36_buildings/simple/datainput.gms

