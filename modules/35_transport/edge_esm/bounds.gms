*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/35_transport/edge_esm/bounds.gms

*** upper bound on bioliquids to 2020 value for all scenarios
v35_shBioFe.up(t,regi)$(t.val > 2020) = 0.05;

*** EOF ./modules/35_transport/edge_esm/bounds.gms
