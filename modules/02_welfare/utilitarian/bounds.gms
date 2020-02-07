*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/02_welfare/utilitarian/bounds.gms

$IFTHEN.INCONV %cm_INCONV_PENALTY% == "on"
v02_sesoInconvPenSlack.lo(t,regi)=0;
v02_inconvPenCoalSolids.fx("2005",regi) = 0;
v02_inconvPenCoalSolids.lo(t,regi) = 0;
v02_inconvPen.lo(t,regi) = 0;
v02_inconvPen.fx("2005",regi) = 0;
$ENDIF.INCONV

$IFTHEN.INCONV_bioSwitch "%cm_INCONV_PENALTY_bioSwitch%" == "on"
v_NegInconvPenFeBioSwitch.fx(ttot,regi,entySe,entyFe,sector,emiMkt)$(NOT((ttot.val ge cm_startyear) AND entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,"ES") AND (entySeBio(entySe)) AND (sameas(emiMkt,"ES")))) = 0;
v_PosInconvPenFeBioSwitch.fx(ttot,regi,entySe,entyFe,sector,emiMkt)$(NOT((ttot.val ge cm_startyear) AND entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,"ES") AND (entySeBio(entySe)) AND (sameas(emiMkt,"ES")))) = 0;
$ENDIF.INCONV_bioSwitch


*** EOF ./modules/02_welfare/utilitarian/bounds.gms