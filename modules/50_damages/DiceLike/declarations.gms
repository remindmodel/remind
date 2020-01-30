*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/50_damages/DiceLike/declarations.gms
parameters
p50_damageFuncCoef1			"damage function coefficient, linear in temperature"
p50_damageFuncCoef2 			"damage function coefficient, quadratic in temperture"
;

positive variable
vm_damageFactor(ttot,all_regi)      "damage factor reducing GDP"
;
*** EOF ./modules/50_damages/DiceLike/declarations.gms
