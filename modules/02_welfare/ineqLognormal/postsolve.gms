*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/02_welfare/ineqLognormal/postsolve.gms

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

*for use in the SCC calculation
pm_sccIneq(ttot,regi)$((pm_SolNonInfes(regi) eq 1)) = exp(-1*(2*cm_distrAlphaDam-(pm_ies(regi)+1))*0.5*pm_ies(regi)*v02_distrFinal_SigmaSq_postDam.l(ttot,regi));

*interpolate sigma
loop(ttot$(ttot.val ge 2005),
	loop(tall$(pm_tall_2_ttot(tall, ttot)),
	    pm_sccIneq(tall,regi) =
		(1- pm_interpolWeight_ttot_tall(tall)) * pm_sccIneq(ttot,regi)
		+ pm_interpolWeight_ttot_tall(tall) * pm_sccIneq(ttot+1,regi);
));

* assume sigma is flat from 2150 on (only enters damage calculations in the far future)
pm_sccIneq(tall,regi)$(tall.val ge 2150) = pm_sccIneq("2149",regi); 



*** EOF ./modules/02_welfare/ineqLognormal/postsolve.gms
