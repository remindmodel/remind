*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/30_biomass/exogenous/bounds.gms

vm_costFuBio.fx(t,regi) = p30_fix_costfu_bio(t,regi);

vm_fuExtr.fx(t,regi,peBio(enty),rlf) = p30_fix_fuelex(t,regi,peBio,rlf);
*** EOF ./modules/30_biomass/exogenous/bounds.gms
