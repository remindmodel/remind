*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/25_WACC/standard/bounds.gms
*fix budget equation term to zero for 2005
***vm_waccCost.fx("2005",regi) = 0;

p25_techwaccCostO("2005", regi)  = 0 ;
p25_techwaccCost1("2005", regi)  = 0 ;
p25_invwaccCost0("2005", regi)  = 0 ;
p25_waccCostO_tewacc("2005", regi, tewacc) = 0 ;
p25_waccCost1_tewacc("2005", regi, tewacc) = 0 ;

*** EOF ./modules/25_WACC/standard/bounds.gms








