*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/36_buildings/simple/equations.gms

q36_demFeBuild(ttot,regi,entyFe,emiMkt)$((ttot.val ge cm_startyear) AND (entyFe2Sector(entyFe,"build")) AND (sameas(emiMkt,"ES"))) .. 
  sum((entySe,te)$se2fe(entySe,entyFe,te), vm_demFeSector(ttot,regi,entySe,entyFe,"build",emiMkt)) 
  =e=
  sum(in$(fe2ppfEn(entyFe,in) AND ppfen_buildings_dyn36(in)),
    vm_cesIO(ttot,regi,in)
    + pm_cesdata(ttot,regi,in,"offset_quantity") 
  )
;

*** EOF ./modules/36_buildings/simple/equations.gms
