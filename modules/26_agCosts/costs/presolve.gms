*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de

*** Substitude MAC LU costs for stand alone runs by data from REMIND-MAC-LU
*** in coupled runs the two last components are zero and the original data from MAgPIE are used
*** For standalone runs dont include mac costs for CO2luc, because they are already implicitly included in p26_totLUcosts_withMAC (and not in p26_macCostLu)
pm_totLUcosts(ttot,regi) =  p26_totLUcosts_withMAC(ttot,regi) - p26_macCostLu(ttot,regi) + sum(enty$(emiMacMagpie(enty) AND (NOT emiMacMagpieCO2(enty))), pm_macCost(ttot,regi,enty));
