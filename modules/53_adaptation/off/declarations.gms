*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/53_adaptation/off/declarations.gms

parameters
pm_protectionLevelNonSLR(tall,all_regi)		"protection level, non-SLR damages"
pm_protectionLevelSLR(tall,all_regi)		"protection level, SLR damages"
;

positive variable
vm_damageFactorAdapt(ttot,all_regi)      "damage factor after adaptation"
;
*** EOF ./modules/53_adaptation/off/declarations.gms
