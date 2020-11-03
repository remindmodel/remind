*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/35_transport/edge_esm/postsolve.gms
pm_bunker_share_in_nonldv_fe(t,regi) = (
    vm_demFeForEs.l(t,regi,"fedie","esdie_frgt_lo","te_esdie_frgt_lo") +
    vm_demFeForEs.l(t,regi,"fedie","esdie_pass_lo","te_esdie_pass_lo")) /
    sum(fe2es_dyn35("fedie",esty,teEs), vm_demFeForEs.l(t,regi,"fedie",esty,teEs));
display pm_bunker_share_in_nonldv_fe;

*** EOF ./modules/35_transport/edge_esm/postsolve.gms
