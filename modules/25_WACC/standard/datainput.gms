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
***p25_wacc(t, regi, tewacc) = 0;
***p25_techwacc(t, regi, tewacc) = 0;

p25_invwacc(t, 'CAZ') = 0.0043;
p25_invwacc(t, 'CHA') = 0.0083;
p25_invwacc(t, 'EUR') = 0.0085;
p25_invwacc(t, 'IND') = 0.0215;
p25_invwacc(t, 'JPN') = 0.0098;
p25_invwacc(t, 'LAM') = 0.0364;
p25_invwacc(t, 'MEA') = 0.0335;
p25_invwacc(t, 'NEU') = 0.0243;
p25_invwacc(t, 'OAS') = 0.0222;
p25_invwacc(t, 'REF') = 0.0295;
p25_invwacc(t, 'SSA') = 0.0401;
p25_invwacc(t, 'USA') = 0.0055;

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


***Check if WACC data should be loaded  
Parameter p25_techwacc(ttot, all_regi, tewacc)                       "WACC markup for each power technology in each REMIND region"   
   /
$ondelim 
$include "./modules/25_WACC/standard/input/p25_wacc_extended.cs4r"   
$offdelim
  /
;

***Parameter p25_invwacc(ttot, all_regi)                       "WACC markup for each country"   
***   /
***$ondelim 
***$include "./modules/25_WACC/standard/input/p25_wacc_extended.cs4r"   
***$offdelim
***  /
***;

***p25_wacc(ttot, all_regi, tewacc) = 2 * p25_wacc(ttot, all_regi, tewacc);

*** EOF ./modules/25_WACC/standard/datainput.gms