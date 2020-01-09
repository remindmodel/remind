*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/35_transport/edge_esm/bounds.gms
vm_shBioFe.lo(t,regi)$(t.val > 2020) = 0.1;
vm_shBioFe.lo(t,regi)$(t.val > 2025) = 0.2;
vm_shBioFe.lo(t,regi)$(t.val > 2030) = 0.4;
*** EOF ./modules/35_transport/edge_esm/bounds.gms
