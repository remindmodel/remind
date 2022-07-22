*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/50_damages/Labor/bounds.gms

vm_damageFactor.fx(ttot,regi) = 1;
vm_damageProdFactor.fx(ttot,regi,in) = 1;
vm_damageProdFactor.fx(ttot,regi,"lab")$(ttot.val ge 2020) = pm_damage(ttot,regi);

*** EOF ./modules/50_damages/Labor/bounds.gms

