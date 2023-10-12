*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/51_internalizeDamages/KW_SEitr/postsolve.gms


p51_sccLastItr(tall) = p51_scc(tall);

p51_sccParts(tall,tall2,regi2)$((tall.val ge 2010) and (tall.val le 2150) and (tall2.val ge tall.val) and (tall2.val le 2250)) = 
	 (1 + pm_prtp(regi2) )**(-(tall2.val - tall.val))
	* pm_consPC(tall,regi2)/pm_consPC(tall2,regi2) 
        * pm_GDPGross(tall2,regi2) 
	* (pm_damage(tall2,regi2)-pm_damageImp(tall,tall2,regi2)) 
;

*convert unit from tr$/GtC to $/tCO2 as GDP is in tr$ and pulse is 1 GtC
p51_scc(tall)$((tall.val ge 2010) and (tall.val le 2150)) = 1000*12/44 *
*p51_welf(tall)**(-1) * 
    sum(regi2,
    sum(tall2$( (tall2.val ge tall.val) and (tall2.val le (tall.val + cm_damages_SccHorizon))),   !! add this for limiting horizon of damage consideration: and (tall2.val le 2150)
	p51_sccParts(tall,tall2,regi2)
    )
   )
;
display p51_scc;

*if(cm_iterative_target_adj eq 10 and cm_emiscen eq 9 and  mod(iteration.val,2) eq 1,   !! update only every uneven iteration to prevent zig-zagging

*display "proposed new scc tax:";
*display p51_scc;
*p51_scc(tall) = p51_sccLastItr(tall) * max(0, min(1.4,max(0.6, (p51_scc(tall)/max(p51_sccLastItr(tall),1e-8))**0.7 )));
p51_scc(tall) = p51_sccLastItr(tall) *  min(max( (p51_scc(tall)/max(p51_sccLastItr(tall),1e-8)),1 - 0.5*0.95**iteration.val),1 + 0.95**iteration.val);

pm_taxCO2eqSCC(ttot,regi) = 0;
pm_taxCO2eqSCC(ttot,regi)$(ttot.val ge 2020) = max(0, p51_scc(ttot) * (44/12)/1000);

*);

*optional: prevent drastic decline towards the final periods
*pm_taxCO2eqSCC(ttot,regi)$(ttot.val gt 2100) = pm_taxCO2eqSCC("2100",regi); 
*optional: dampen price adjustment to ease convergence
*pm_taxCO2eqSCC(ttot,regi)$(ttot.val gt 2110) = pm_taxCO2eqSCC("2110",regi) + (ttot.val - 2110) * (pm_taxCO2eqSCC("2110",regi) - pm_taxCO2eqSCC("2100",regi))/10; 

*display p51_scc,pm_taxCO2eqSCC;
display pm_taxCO2eqSCC;


* convergence indicator:
pm_sccConvergenceMaxDeviation = 100 * smax(tall$(tall.val ge cm_startyear and tall.val lt 2150),abs(p51_scc(tall)/max(p51_sccLastItr(tall),1e-8) - 1) );
display pm_sccConvergenceMaxDeviation;


*** EOF ./modules/51_internalizeDamages/KW_SEitr/postsolve.gms
