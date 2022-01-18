*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/48_carbonpriceRegi/netZero/datainput.gms

***profile for countries with 2050 target
pm_taxCO2eq_regi("2035",nz_reg2050)=5;
pm_taxCO2eq_regi("2040",nz_reg2050)=10;
pm_taxCO2eq_regi("2045",nz_reg2050)=15;
pm_taxCO2eq_regi("2050",nz_reg2050)=20;
pm_taxCO2eq_regi("2055",nz_reg2050)=18;
pm_taxCO2eq_regi("2060",nz_reg2050)=16;
pm_taxCO2eq_regi("2065",nz_reg2050)=14;
pm_taxCO2eq_regi("2070",nz_reg2050)=12;
pm_taxCO2eq_regi("2075",nz_reg2050)=10;
pm_taxCO2eq_regi("2080",nz_reg2050)=8;
pm_taxCO2eq_regi("2085",nz_reg2050)=6;
pm_taxCO2eq_regi("2090",nz_reg2050)=4;
pm_taxCO2eq_regi("2095",nz_reg2050)=2;

*** profile for countries with 2060 target
pm_taxCO2eq_regi("2035",nz_reg2060)=2;
pm_taxCO2eq_regi("2040",nz_reg2060)=5;
pm_taxCO2eq_regi("2045",nz_reg2060)=9;
pm_taxCO2eq_regi("2050",nz_reg2060)=14;
pm_taxCO2eq_regi("2055",nz_reg2060)=20;
pm_taxCO2eq_regi("2060",nz_reg2060)=28;
pm_taxCO2eq_regi("2065",nz_reg2060)=22;
pm_taxCO2eq_regi("2070",nz_reg2060)=17;
pm_taxCO2eq_regi("2075",nz_reg2060)=13;
pm_taxCO2eq_regi("2080",nz_reg2060)=10;
pm_taxCO2eq_regi("2085",nz_reg2060)=7;
pm_taxCO2eq_regi("2090",nz_reg2060)=4;
pm_taxCO2eq_regi("2095",nz_reg2060)=2;

***rescale
pm_taxCO2eq_regi(ttot,regi) = sm_DptCO2_2_TDpGtC * pm_taxCO2eq_regi(ttot,regi);

***initialize parameter
p48_taxCO2eq_regi_last(t,regi) =0;
p48_taxCO2eq_last(t,regi)      =0;

*** EOF ./modules/48_carbonpriceRegi/netZero/datainput.gms


