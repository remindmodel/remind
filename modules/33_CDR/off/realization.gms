*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/33_CDR/off.gms

*' @description 
*' In this realization, no additional CDR option other than BECCS and afforestation is available.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/33_CDR/off/declarations.gms"
$Ifi "%phase%" == "bounds" $include "./modules/33_CDR/off/bounds.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/33_CDR/off.gms
