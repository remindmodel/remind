*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/36_buildings/simple/equations.gms

***---------------------------------------------------------------------------
*'  Buildings Final Energy Balance
***---------------------------------------------------------------------------
q36_demFeBuild(ttot,regi,entyFe,emiMkt)$((ttot.val ge cm_startyear) AND (entyFe2Sector(entyFe,"build"))) .. 
  sum((entySe,te)$se2fe(entySe,entyFe,te), vm_demFeSector(ttot,regi,entySe,entyFe,"build",emiMkt)) 
  =e=
  ( sum(in$(fe2ppfEn(entyFe,in) AND ppfen_buildings_dyn36(in)),
    vm_cesIO(ttot,regi,in)
    + pm_cesdata(ttot,regi,in,"offset_quantity") 
   )
  )$(sameas(emiMkt,"ES"))
;

***---------------------------------------------------------------------------
*'  Calculate sector-specific additional t&d cost (here only cost of hydrogen t&d at low hydrogen penetration levels when grid is not yet developed)
***---------------------------------------------------------------------------
q36_costAddTeInv(t,regi,te)$(sameAs(te,"tdh2s"))..
  vm_costAddTeInv(t,regi,te,"build")
  =e=
  v36_costAddTeInvH2(t,regi,te)
;

***---------------------------------------------------------------------------
*'  Additional hydrogen phase in cost at low H2 penetration levels 
***---------------------------------------------------------------------------
q36_costAddH2PhaseIn(t,regi)..
  v36_costAddTeInvH2(t,regi,"tdh2s")
  =e=
  v36_costAddH2LowPen(t,regi)
    * (vm_demFeSector(t,regi,"seh2","feh2s","build","ES"))
    + (v36_expSlack(t,regi)*1e-8)
;



*' barrier cost for low penetration
q36_costAddH2LowPen(t,regi)..
  v36_costAddH2LowPen(t,regi)
  =e=
  1 / (1 + 3**v36_costExponent(t,regi)) 
  * s36_costAddH2Inv 
  * sm_TWa_2_kWh / sm_trillion_2_non
;


*' Logistic function exponent for additional hydrogen low penetration cost equation
q36_auxCostAddTeInv(t,regi)..
  v36_costExponent(t,regi)
  =e=
  ( (10/(s36_costDecayEnd-s36_costDecayStart)) * ( (v36_H2share(t,regi)+1e-7) -  ((s36_costDecayEnd+s36_costDecayStart)/2) ) ) - v36_expSlack(t,regi)
;


*' Hydrogen fe share in buildings gases use (natural gas + hydrogen)
q36_H2Share(t,regi)..
  v36_H2share(t,regi) 
  * sum(se2fe(entySe,entyFe,te)$(SAMEAS(entyFe,"feh2s") OR SAMEAS(entyFe,"fegas")),   
      vm_demFeSector(t,regi,entySe,entyFe,"build","ES"))
  =e=
  sum(se2fe(entySe,entyFe,te)$SAMEAS(entyFe,"feh2s"),
      vm_demFeSector(t,regi,entySe,entyFe,"build","ES"))
;


***---------------------------------------------------------------------------
*'  CES markup cost to represent sector-specific demand-side transformation cost in buildings
***---------------------------------------------------------------------------
q36_costCESmarkup(t,regi,in)$(ppfen_buildings_dyn36(in))..
  vm_costCESMkup(t,regi,in)
  =e=
  p36_CESMkup(t,regi,in)*(vm_cesIO(t,regi,in) + pm_cesdata(t,regi,in,"offset_quantity"))
;


*** EOF ./modules/36_buildings/simple/equations.gms
