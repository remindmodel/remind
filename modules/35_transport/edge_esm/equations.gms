*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/35_transport/edge_esm/equations.gms


*'  Transportation Final Energy Balance
q35_demFeTrans(ttot,regi,entyFe,emiMkt)$((ttot.val ge cm_startyear) AND (entyFe2Sector(entyFe,"trans"))) ..
  sum((entySe,te)$se2fe(entySe,entyFe,te), 
    vm_demFeSector(ttot,regi,entySe,entyFe,"trans",emiMkt)
  )
  =e=
  sum(fe2es(entyFe,esty,teEs)$(NOT (es_lo35(esty))), vm_demFeForEs(ttot,regi,entyFe,esty,teEs))$(sameas(emiMkt,"ES"))+
  sum(fe2es(entyFe,esty,teEs)$es_lo35(esty), vm_demFeForEs(ttot,regi,entyFe,esty,teEs))$(sameas(emiMkt,"other"));
*** EOF ./modules/35_transport/edge_esm/equations.gms
