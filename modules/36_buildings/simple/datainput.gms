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
        enb    2.5
        enhb   3.0
        enhgab 5.0
  /
;
pm_cesdata_sigma(ttot,in)$p36_cesdata_sigma(in) = p36_cesdata_sigma(in);

pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) le 2025  AND sameAs(in, "enb")) = 0.1;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2030  AND sameAs(in, "enb")) = 0.3;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2035  AND sameAs(in, "enb")) = 0.6;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2040  AND sameAs(in, "enb")) = 1.3;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2045  AND sameAs(in, "enb")) = 1.7;

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

*** EOF ./modules/36_buildings/simple/datainput.gms

