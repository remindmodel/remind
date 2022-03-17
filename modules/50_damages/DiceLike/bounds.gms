*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/50_damages/DiceLike/bounds.gms

vm_damageFactor.fx("2005",regi) = 1;

loop(ttot$(ttot.val ge 2010),
	loop(tall$(pm_ttot_2_tall(ttot,tall)),
	    vm_damageFactor.fx(ttot,regi) = pm_damage(tall,regi);
));

*** EOF ./modules/50_damages/DiceLike/bounds.gms
