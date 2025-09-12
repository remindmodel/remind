*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/25_WACC/standard/declarations.gms

Parameters
***p25_wacc(ttot, all_regi, tewacc)                       "WACC markup for each power technology in each REMIND region"
p25_techwacc(ttot, all_regi, tewacc)                      "WACC markup for each power technology in each REMIND region"
p25_invwacc(ttot, all_regi)                                "WACC markup for each country"
p25_techwaccCostO(ttot, all_regi)                          "reference level value of technology WACC costs of the cuurent and previous period"
p25_invwaccCost0(ttot, all_regi)                           "reference level value of macro investments WACC costs of the cuurent and previous period"
p25_techwaccCost1(ttot, all_regi)                          "reference level value of WACC costs of the previous period"

p25_waccCostO_tewacc(ttot, all_regi, tewacc)                 "reference level value of WACC costs of the cuurent and previous period"
p25_waccCost1_tewacc(ttot, all_regi, tewacc)                 "reference level value of WACC costs of the previous period"

***validPrevYears(t, tPrev)                               "Valid previous years based on operational time shift";
; 

equations 
***q25_waccCost(ttot, all_regi)                           "Calculation of WACC costs considering both new and existing system technologies"
q25_techwaccCost(ttot, all_regi)                          "Calculation of WACC costs considering both new and existing system technologies"   
q25_invwaccCost(ttot, all_regi)                           "Calculation of WACC costs for macro investments"
q25_totwaccCost(ttot, all_regi)                           "Calculation of total WACC costs for both system technologies and macro investments"
;


variables
v25_techwaccCost(ttot, all_regi)                         "WACC costs for financing new and existing technologies in the system"
v25_invWaccCost(ttot, all_regi)                          "WACC costs related to macro investments"
;
*** EOF ./modules/25_WACC/standard/declarations.gms



