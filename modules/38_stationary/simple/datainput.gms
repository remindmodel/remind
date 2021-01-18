*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/38_stationary/simple/datainput.gms
*** substitution elasticities
Parameter 
  p38_cesdata_sigma(all_in)  "substitution elasticities"
  /
    ens     1.3
    ensh    3.0
  /
;
pm_cesdata_sigma(ttot,in)$p38_cesdata_sigma(in) = p38_cesdata_sigma(in);

pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) le 2025  AND sameAs(in, "ens")) = 0.1;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2030  AND sameAs(in, "ens")) = 0.2;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2035  AND sameAs(in, "ens")) = 0.3;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2040  AND sameAs(in, "ens")) = 0.5;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2045  AND sameAs(in, "ens")) = 0.7;

pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) le 2025  AND sameAs(in, "ensh")) = 0.1;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2030  AND sameAs(in, "ensh")) = 0.3;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2035  AND sameAs(in, "ensh")) = 0.6;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2040  AND sameAs(in, "ensh")) = 1.3;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2045  AND sameAs(in, "ensh")) = 2.0;
*** Don't use more than 25/50% H2/district heat in stationary
pm_ppfen_shares(t,regi,"ensh","feh2s") = 0.25;

pm_ppfen_shares(t,regi,"ensh","fehes") = 0.5;

*** Don't use more H2 than gas in stationary
pm_ppfen_ratios(t,"feh2s","fegas") = 1;

*** EOF ./modules/38_stationary/simple/datainput.gms
