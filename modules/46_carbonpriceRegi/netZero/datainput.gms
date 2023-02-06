*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/46_carbonpriceRegi/netZero/datainput.gms

p46_zeroYear = 2100;
$ifthen.p46_zeroYear "%cm_netZeroScen%" == "ENGAGE4p5_GlP"
p46_zeroYear = 2200;
$endif.p46_zeroYear


***profile for countries with 2050 target
pm_taxCO2eqRegi("2035",nz_reg2050)=5;
pm_taxCO2eqRegi("2040",nz_reg2050)=10;
pm_taxCO2eqRegi("2045",nz_reg2050)=15;
pm_taxCO2eqRegi("2050",nz_reg2050)=20;
pm_taxCO2eqRegi(ttot,nz_reg2050)$(ttot.val > 2050) = max(0, pm_taxCO2eqRegi("2050", nz_reg2050) * (ttot.val - p46_zeroYear) / (2050 - p46_zeroYear));

*** profile for countries with 2055 CO2 target
pm_taxCO2eqRegi("2035",nz_reg2055)=3;
pm_taxCO2eqRegi("2040",nz_reg2055)=6;
pm_taxCO2eqRegi("2045",nz_reg2055)=10;
pm_taxCO2eqRegi("2050",nz_reg2055)=16;
pm_taxCO2eqRegi("2055",nz_reg2055)=24;
pm_taxCO2eqRegi(ttot,nz_reg2055)$(ttot.val > 2055) = max(0, pm_taxCO2eqRegi("2055", nz_reg2055) * (ttot.val - p46_zeroYear) / (2055 - p46_zeroYear));

*** profile for countries with 2060 target
pm_taxCO2eqRegi("2035",nz_reg2060)=2;
pm_taxCO2eqRegi("2040",nz_reg2060)=5;
pm_taxCO2eqRegi("2045",nz_reg2060)=9;
pm_taxCO2eqRegi("2050",nz_reg2060)=14;
pm_taxCO2eqRegi("2055",nz_reg2060)=20;
pm_taxCO2eqRegi("2060",nz_reg2060)=28;
pm_taxCO2eqRegi(ttot,nz_reg2060)$(ttot.val > 2060) = max(0, pm_taxCO2eqRegi("2060", nz_reg2060) * (ttot.val - p46_zeroYear) / (2060 - p46_zeroYear));

*** profile for countries with 2070 target
pm_taxCO2eqRegi("2035",nz_reg2070)=2;
pm_taxCO2eqRegi("2040",nz_reg2070)=5;
pm_taxCO2eqRegi("2045",nz_reg2070)=9;
pm_taxCO2eqRegi("2050",nz_reg2070)=13;
pm_taxCO2eqRegi("2055",nz_reg2070)=17;
pm_taxCO2eqRegi("2060",nz_reg2070)=21;
pm_taxCO2eqRegi("2065",nz_reg2070)=25;
pm_taxCO2eqRegi("2070",nz_reg2070)=29;
pm_taxCO2eqRegi(ttot,nz_reg2070)$(ttot.val > 2070) = max(0, pm_taxCO2eqRegi("2070", nz_reg2070) * (ttot.val - p46_zeroYear) / (2070 - p46_zeroYear));

*** profile for countries with 2080 target
pm_taxCO2eqRegi("2035",nz_reg2080)=2;
pm_taxCO2eqRegi("2040",nz_reg2080)=4;
pm_taxCO2eqRegi("2045",nz_reg2080)=7;
pm_taxCO2eqRegi("2050",nz_reg2080)=10;
pm_taxCO2eqRegi("2055",nz_reg2080)=13;
pm_taxCO2eqRegi("2060",nz_reg2080)=16;
pm_taxCO2eqRegi("2065",nz_reg2080)=19;
pm_taxCO2eqRegi("2070",nz_reg2080)=22;
pm_taxCO2eqRegi("2075",nz_reg2080)=25;
pm_taxCO2eqRegi("2080",nz_reg2080)=28;
pm_taxCO2eqRegi(ttot,nz_reg2080)$(ttot.val > 2080) = max(0, pm_taxCO2eqRegi("2080", nz_reg2080) * (ttot.val - p46_zeroYear) / (2080 - p46_zeroYear));

***rescale
pm_taxCO2eqRegi(ttot,regi) = sm_DptCO2_2_TDpGtC * pm_taxCO2eqRegi(ttot,regi);

***initialize parameter
p46_taxCO2eqRegiLast(t,regi) = 0;
p46_taxCO2eqLast(t,regi)     = 0;

***define offsets
p46_offset(all_regi) = 0;
$ifthen.cm_netZeroScen "%cm_netZeroScen%" == "ENGAGE4p5_GlP"
p46_offset(nz_reg)$(sameas(nz_reg, "EUR")) = 100;
*** p46_offset(nz_reg)$(sameas(nz_reg, "SSA")) = 2000;
$endif.cm_netZeroScen

*** EOF ./modules/46_carbonpriceRegi/netZero/datainput.gms


