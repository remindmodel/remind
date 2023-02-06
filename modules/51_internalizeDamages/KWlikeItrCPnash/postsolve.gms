*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/51_internalizeDamages/KWlikeItrCPnash/postsolve.gms

* this is the third sum in Eq. (1). computed seperately for computational effectiveness. (this is still expensive, at a couple of seconds!)
p51_marginalDamageCumul(tall,tall2,regi2)$((tall2.val ge tall.val) and (tall.val le 2250) and (tall2.val le 2250)) = 
    sum(tall3$((tall3.val ge tall.val) and (tall3.val le tall2.val)), 
	(pm_temperatureImpulseResponseCO2(tall3,tall) * pm_tempScaleGlob2Reg(tall3,regi2) * pm_damageMarginalT(tall3,regi2) 
	  + pm_temperatureImpulseResponseCO2(tall3-1,tall)*pm_tempScaleGlob2Reg(tall3-1,regi2)*pm_damageMarginalTm1(tall3,regi2) 
	  + pm_temperatureImpulseResponseCO2(tall3-2,tall)*pm_tempScaleGlob2Reg(tall3-2,regi2)*pm_damageMarginalTm2(tall3,regi2))*(-1)
      / ( 1 + pm_damageGrowthRate(tall3,regi2))
    )
;

p51_sccLastItr(tall,regi) = p51_scc(tall,regi);

p51_sccParts(tall,tall2,regi)$((tall.val ge 2010) and (tall.val le 2150) and (tall2.val ge tall.val) and (tall2.val le 2250)) = 
	 (1 + pm_prtp(regi) )**(-(tall2.val - tall.val))
*	* pm_consPC(tall,regi)/pm_consPC(tall2,regi) 
        * pm_damage(tall2,regi) * pm_GDPGross(tall2,regi) 
	* p51_marginalDamageCumul(tall,tall2,regi) 
	* pm_sccIneq(tall2,regi)
;

p51_scc(tall,regi)$((tall.val ge 2010) and (tall.val le 2150)) = 1000 *
*p51_welf(tall)**(-1) * 
    sum(tall2$( (tall2.val ge tall.val) and (tall2.val le (tall.val + cm_damages_SccHorizon))),   !! add this for limiting horizon of damage consideration: and (tall2.val le 2150)
	p51_sccParts(tall,tall2,regi)
   )
;
display p51_scc;

*if(cm_iterative_target_adj eq 10 and cm_emiscen eq 9 and  mod(iteration.val,2) eq 1,   !! update only every uneven iteration to prevent zig-zagging

*display "proposed new scc tax:";
*display p51_scc;
*p51_scc(tall) = p51_sccLastItr(tall) * max(0, min(1.4,max(0.6, (p51_scc(tall)/max(p51_sccLastItr(tall),1e-8))**0.7 )));
p51_scc(tall,regi) = p51_sccLastItr(tall,regi) *  min(max( (p51_scc(tall,regi)/max(p51_sccLastItr(tall,regi),1e-8)),1 - 0.5*0.95**iteration.val),1 + 0.95**iteration.val);

pm_taxCO2eqSCC(ttot,regi) = 0;
pm_taxCO2eqSCC(ttot,regi)$(ttot.val ge 2020) = max(0, p51_scc(ttot,regi) * (44/12)/1000);

*);

*optional: prevent drastic decline towards the final periods
*pm_taxCO2eqSCC(ttot,regi)$(ttot.val gt 2100) = pm_taxCO2eqSCC("2100",regi); 
*optional: dampen price adjustment to ease convergence
*pm_taxCO2eqSCC(ttot,regi)$(ttot.val gt 2110) = pm_taxCO2eqSCC("2110",regi) + (ttot.val - 2110) * (pm_taxCO2eqSCC("2110",regi) - pm_taxCO2eqSCC("2100",regi))/10; 

display p51_scc,pm_taxCO2eqSCC;


* convergence indicator:
p51_sccConvergenceMaxDeviation(regi) = 100 * smax(tall$(tall.val ge cm_startyear and tall.val lt 2150),abs(p51_scc(tall,regi)/max(p51_sccLastItr(tall,regi),1e-8) - 1) );
display p51_sccConvergenceMaxDeviation;


*** EOF ./modules/51_internalizeDamages/KWlikeItrCPnash/postsolve.gms
