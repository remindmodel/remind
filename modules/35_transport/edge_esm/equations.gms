*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/35_transport/edge_esm/equations.gms

q35_shBioFe(t,regi)..
  sum(se2fe(entySe,fe_with_bio_dyn35,te), vm_prodFe(t,regi,entySe,fe_with_bio_dyn35,te) )
  * vm_shBioFe(t,regi)
  =e=
  sum(se2fe(se_with_bio_dyn35,fe_with_bio_dyn35,te), vm_prodFe(t,regi,se_with_bio_dyn35,fe_with_bio_dyn35,te) )
;
*** EOF ./modules/35_transport/edge_esm/equations.gms
