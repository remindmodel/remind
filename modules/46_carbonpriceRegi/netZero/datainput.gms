*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/46_carbonpriceRegi/netZero/datainput.gms

p46_zeroYear = 2100;
$ifthen.p46_zeroYear "%cm_netZeroScen%" == "ELEVATE2p3"
  p46_zeroYear = 2200;
$endif.p46_zeroYear

$ifthen.p46_zeroYear "%cm_netZeroScen%" == "NGFS_v4_20pc"
  p46_zeroYear = 2200;
$endif.p46_zeroYear
$ifthen.p46_zeroYear "%cm_netZeroScen%" == "NGFS_v4"
  p46_zeroYear = 2200;
$endif.p46_zeroYear

***profile for countries with 2050 target
pm_taxCO2eqRegi(t,nz_reg2050)$sameas(t,"2035")=5;
pm_taxCO2eqRegi(t,nz_reg2050)$sameas(t,"2040")=10;
pm_taxCO2eqRegi(t,nz_reg2050)$sameas(t,"2045")=15;
pm_taxCO2eqRegi(t,nz_reg2050)$sameas(t,"2050")=20;
pm_taxCO2eqRegi(t,nz_reg2050)$(t.val > 2050) = max(0, pm_taxCO2eqRegi("2050", nz_reg2050) * (t.val - p46_zeroYear) / (2050 - p46_zeroYear));

*** profile for countries with 2055 CO2 target
pm_taxCO2eqRegi(t,nz_reg2055)$sameas(t,"2035")=3;
pm_taxCO2eqRegi(t,nz_reg2055)$sameas(t,"2040")=6;
pm_taxCO2eqRegi(t,nz_reg2055)$sameas(t,"2045")=10;
pm_taxCO2eqRegi(t,nz_reg2055)$sameas(t,"2050")=16;
pm_taxCO2eqRegi(t,nz_reg2055)$sameas(t,"2055")=24;
pm_taxCO2eqRegi(t,nz_reg2055)$(t.val > 2055) = max(0, pm_taxCO2eqRegi("2055", nz_reg2055) * (t.val - p46_zeroYear) / (2055 - p46_zeroYear));

*** profile for countries with 2060 target
pm_taxCO2eqRegi(t,nz_reg2060)$sameas(t,"2035")=2;
pm_taxCO2eqRegi(t,nz_reg2060)$sameas(t,"2040")=5;
pm_taxCO2eqRegi(t,nz_reg2060)$sameas(t,"2045")=9;
pm_taxCO2eqRegi(t,nz_reg2060)$sameas(t,"2050")=14;
pm_taxCO2eqRegi(t,nz_reg2060)$sameas(t,"2055")=20;
pm_taxCO2eqRegi(t,nz_reg2060)$sameas(t,"2060")=28;
pm_taxCO2eqRegi(t,nz_reg2060)$(t.val > 2060) = max(0, pm_taxCO2eqRegi("2060", nz_reg2060) * (t.val - p46_zeroYear) / (2060 - p46_zeroYear));

*** profile for countries with 2070 target
pm_taxCO2eqRegi(t,nz_reg2070)$sameas(t,"2035")=2;
pm_taxCO2eqRegi(t,nz_reg2070)$sameas(t,"2040")=5;
pm_taxCO2eqRegi(t,nz_reg2070)$sameas(t,"2045")=9;
pm_taxCO2eqRegi(t,nz_reg2070)$sameas(t,"2050")=13;
pm_taxCO2eqRegi(t,nz_reg2070)$sameas(t,"2055")=17;
pm_taxCO2eqRegi(t,nz_reg2070)$sameas(t,"2060")=21;
pm_taxCO2eqRegi(t,nz_reg2070)$sameas(t,"2065")=25;
pm_taxCO2eqRegi(t,nz_reg2070)$sameas(t,"2070")=29;
pm_taxCO2eqRegi(t,nz_reg2070)$(t.val > 2070) = max(0, pm_taxCO2eqRegi("2070", nz_reg2070) * (t.val - p46_zeroYear) / (2070 - p46_zeroYear));

*** profile for countries with 2080 target
pm_taxCO2eqRegi(t,nz_reg2080)$sameas(t,"2035")=2;
pm_taxCO2eqRegi(t,nz_reg2080)$sameas(t,"2040")=4;
pm_taxCO2eqRegi(t,nz_reg2080)$sameas(t,"2045")=7;
pm_taxCO2eqRegi(t,nz_reg2080)$sameas(t,"2050")=10;
pm_taxCO2eqRegi(t,nz_reg2080)$sameas(t,"2055")=13;
pm_taxCO2eqRegi(t,nz_reg2080)$sameas(t,"2060")=16;
pm_taxCO2eqRegi(t,nz_reg2080)$sameas(t,"2065")=19;
pm_taxCO2eqRegi(t,nz_reg2080)$sameas(t,"2070")=22;
pm_taxCO2eqRegi(t,nz_reg2080)$sameas(t,"2075")=25;
pm_taxCO2eqRegi(t,nz_reg2080)$sameas(t,"2080")=28;
pm_taxCO2eqRegi(t,nz_reg2080)$(t.val > 2080) = max(0, pm_taxCO2eqRegi("2080", nz_reg2080) * (t.val - p46_zeroYear) / (2080 - p46_zeroYear));

***rescale
pm_taxCO2eqRegi(t,regi) = sm_DptCO2_2_TDpGtC * pm_taxCO2eqRegi(t,regi);

***initialize parameter
p46_taxCO2eqRegiLast(t,regi) = 0;
p46_taxCO2eqLast(t,regi)     = 0;

*** EOF ./modules/46_carbonpriceRegi/netZero/datainput.gms

