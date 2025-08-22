*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/25_WACC/off/bounds.gms
*fix the WACC term of the budget equation equal to zero for all times
vm_waccCost(t, regi) = 0;

***vm_techwaccCost(t, regi) = 0;
***vm_invwaccCost(t, regi) = 0;
*** EOF ./modules/25_WACC/off/bounds.gms
