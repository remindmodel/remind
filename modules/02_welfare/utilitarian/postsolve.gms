*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/02_welfare/utilitarian/postsolve.gms

$IFTHEN.INCONV_bioSwitch "%cm_INCONV_PENALTY_FESwitch%" == "on"
*** track inconvenience penalty for bio/synfuel switching to check how large it is relative to consumption
p02_inconvPen_Switch_Track(t,regi) = (sum((entySe,entyFe,te,sector,emiMkt)$(se2fe(entySe,entyFe,te) 
                                                                    AND entyFe2Sector(entyFe,sector) 
                                                                    AND sector2emiMkt(sector,emiMkt) 
                                                                    AND (entySeBio(entySe) OR entySeSyn(entySe) OR entySeFos(entySe) )), 
                                                                        v02_NegInconvPenFeBioSwitch.l(t,regi,entySe,entyFe,sector,emiMkt) 
                                                                        + v02_PosInconvPenFeBioSwitch.l(t,regi,entySe,entyFe,sector,emiMkt))/1e3)
																		/ vm_cons.l(t,regi);	
$ENDIF.INCONV_bioSwitch

*the inequality term in the SCC calculation is set to 1 here
pm_sccIneq(tall,regi) = 1;


*** EOF ./modules/02_welfare/utilitarian/postsolve.gms
