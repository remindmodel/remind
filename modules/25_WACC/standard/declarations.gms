*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/25_WACC/standard/declarations.gms

Parameters
***p25_wacc(ttot, all_regi, tewacc)                       "WACC markup for each power technology in each REMIND region"
p25_waccCostO(ttot, all_regi)                          "reference level value of WACC costs of the cuurent and previous period"
p25_waccCost1(ttot, all_regi)                          "reference level value of WACC costs of the previous period"

p25_waccCostO_tewacc(ttot, all_regi, tewacc)                 "reference level value of WACC costs of the cuurent and previous period"
p25_waccCost1_tewacc(ttot, all_regi, tewacc)                 "reference level value of WACC costs of the previous period"

***validPrevYears(t, tPrev)                               "Valid previous years based on operational time shift";
; 

equations 
q25_waccCost(ttot, all_regi)                           "Calculation of WACC costs considering both new and existing system technologies"
;

*** EOF ./modules/25_WACC/standard/declarations.gms



