*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/52_internalizeLCAimpacts/off/realization.gms

*' @description The off-realization of the internalizeLCAimpacts module sets the parameter ADD PARAMETER NAME to zero, meaning no social costs related to environmental impacts are included in the optimization.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "preloop" $include "./modules/52_internalizeLCAimpacts/off/preloop.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/52_internalizeLCAimpacts/off/realization.gms
