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
Parameter p25_counwacc(ttot, all_regi)                       "WACC markup for each country"   
   /
$ondelim 
$include "./modules/25_WACC/standard/input/p25_macro_wacc.cs4r"   
$offdelim
  /
;

Parameter p25_techwacc(ttot, all_regi, tewacc)                       "WACC markup for each power technology in each REMIND region"   
   /
$ondelim 
$include "./modules/25_WACC/standard/input/p25_wacc.cs4r"   
$offdelim
  /
;

*** EOF ./modules/25_WACC/standard/datainput.gms