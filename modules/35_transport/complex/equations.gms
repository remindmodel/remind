*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/35_transport/complex/equations.gms

q35_shUePeT(t,regi,te)$LDV35(te) ..       !! calculate the share of different LDV types in total LDV usage
  sum(fe2ue(entyFe,"uepet",te2)$LDV35(te2), vm_prodUe(t,regi,entyFe,"uepet",te2) )
  * vm_shUePeT(t,regi,te) / 100
  =e=
  sum(fe2ue(entyFe,"uepet",te), vm_prodUe(t,regi,entyFe,"uepet",te) )
;


q35_shUePeTbal(t,regi) ..       
  sum(fe2ue(entyFe,"uepet",te)$LDV35(te), vm_shUePeT(t,regi,te))
  =e=
  100
;

*** EOF ./modules/35_transport/complex/equations.gms
