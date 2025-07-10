*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/52_internalizeLCAimpacts/module.gms

*' @title internalizeLCAimpacts
*'
*' @description If turned on, the module 52_internalizeLCAimpacts calculates costs incurred by other environmental impacts other than climate change. These environmental costs are calculated using prospective LCA and monetary valuation, and are implemented as taxes in REMIND.
*'
*' @authors David Bantje

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%internalizeLCAimpacts%" == "coupled" $include "./modules/52_internalizeLCAimpacts/coupled/realization.gms"
$Ifi "%internalizeLCAimpacts%" == "off" $include "./modules/52_internalizeLCAimpacts/off/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
*** EOF ./modules/52_internalizeLCAimpacts/module.gms