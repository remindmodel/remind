*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/35_transport/edge_esm/equations.gms

*' Adjust the shares of biofuels in transport liquids.
q35_shBioFe(t,regi)..
  sum(se2fe(entySe,fe_transport_liquids_dyn35,te), vm_prodFe(t,regi,entySe,fe_transport_liquids_dyn35,te) )
  * v35_shBioFe(t,regi)
  =e=
  sum(se2fe("seliqbio",fe_transport_liquids_dyn35,te), vm_prodFe(t,regi,"seliqbio",fe_transport_liquids_dyn35,te) )
;


*' Adjust the shares of synfuels in transport liquids.
*' This equation is only effective when CCU is switched on.
$ifthen.ccu %CCU% == "on"
q35_shSynSe(t,regi)..
    sum(se2fe(entySe,fe_transport_liquids_dyn35,te), vm_prodFe(t,regi,entySe,fe_transport_liquids_dyn35,te) ) * v35_shSynSe(t,regi)
    =e=
    vm_prodSe(t,regi,"seh2","seliqfos","MeOH")
;
$endif.ccu

*** EOF ./modules/35_transport/edge_esm/equations.gms
