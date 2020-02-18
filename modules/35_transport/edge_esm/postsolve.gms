*** SOF ./modules/35_transport/edge_esm/postsolve.gms
pm_bunker_share_in_nonldv_fe(t,regi) = (
    vm_demFeForEs.l(t,regi,"fedie","esdie_frgt_lo","te_esdie_frgt_lo") +
    vm_demFeForEs.l(t,regi,"fedie","esdie_pass_lo","te_esdie_pass_lo")) /
    sum(fe2es_dyn35("fedie",esty,teEs), vm_demFeForEs.l(t,regi,"fedie",esty,teEs));
display pm_bunker_share_in_nonldv_fe;

*** EOF ./modules/35_transport/edge_esm/postsolve.gms
