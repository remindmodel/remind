*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/35_transport/edge_esm/bounds.gms

*** lower bounds for synthetic fuels up to 2030
$ifthen.ccu %CCU% == "on"
v35_shSynSe.lo(t,regi)$(c_shGreenH2 >  0 AND t.val > 2021) = 0.05;
v35_shSynSe.lo(t,regi)$(c_shGreenH2 >  0 AND t.val > 2025) = 0.1;
v35_shSynSe.lo(t,regi)$(c_shGreenH2 >  0 AND t.val > 2030) = 0.20;
$endif.ccu

*** upper bound on bioliquids to 2020 value for all scenarios
v35_shBioFe.up(t,regi)$(t.val > 2020) = 0.05;

*** EOF ./modules/35_transport/edge_esm/bounds.gms
