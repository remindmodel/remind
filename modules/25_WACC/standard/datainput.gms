*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/25_WACC/standard/datainput.gms

***---------------------------------------------------------------------------
*** Read WACC values across technologies and countries
***---------------------------------------------------------------------------
*** Initialize WACC parameter for different regions and technologies  
***p25_wacc(t, regi, tewacc) = 0;

***p25_wacc(t, 'CAZ', 'spv') = 0.025;
***p25_wacc(t, 'CHA', 'spv') = 0.022;
***p25_wacc(t, 'EUR', 'spv') = 0.025;
***p25_wacc(t, 'IND', 'spv') = 0.031;
***p25_wacc(t, 'JPN', 'spv') = 0.021;
***p25_wacc(t, 'LAM', 'spv') = 0.043;
***p25_wacc(t, 'MEA', 'spv') = 0.046;
***p25_wacc(t, 'NEU', 'spv') = 0.033;
***p25_wacc(t, 'OAS', 'spv') = 0.035;
***p25_wacc(t, 'REF', 'spv') = 0.042;
***p25_wacc(t, 'SSA', 'spv') = 0.041;
***p25_wacc(t, 'USA', 'spv') = 0.030;

*** Set WACC to 4% specifically for ngcc in EUR region
***p25_wacc(t, regi, 'windon')$sameas(regi,'EUR') = 0.09;
***p25_wacc(t, regi, 'windoff')$sameas(regi,'EUR') = 0.08;
***p25_wacc(t, regi, 'spv')$sameas(regi,'EUR') = 0.07;


***p25_wacc(t, regi, tewacc)$(
***      sameas(regi, "EUR")
***   AND (sameas(tewacc, "windon") OR sameas(tewacc, "windoff") OR sameas(tewacc, "spv"))
***   AND (sameas(t, "2050") OR sameas(t, "2055") OR sameas(t, "2060")  
***        OR sameas(t, "2070") OR sameas(t, "2080") OR sameas(t, "2090")  
***        OR sameas(t, "2100") OR sameas(t, "2110") OR sameas(t, "2130")  
***        OR sameas(t, "2150"))
***) = 0.05;


*** Check if WACC data should be loaded  
Parameter p25_wacc(ttot, all_regi, tewacc)                       "WACC markup for each power technology in each REMIND region"   
   /
$ondelim 
$include "./modules/25_WACC/standard/input/p25_wacc.cs4r"
$offdelim
  /
;

***p25_wacc(ttot, all_regi, tewacc) = 2 * p25_wacc(ttot, all_regi, tewacc);

*** EOF ./modules/25_WACC/standard/datainput.gms
