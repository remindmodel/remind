*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de


p51_sccLastItr(tall) = p51_scc(tall);
p51_scc(tall)$((tall.val ge 2010) and (tall.val le 2150)) = 1000 *
    sum(regi2,
    sum(tall2$( (tall2.val ge tall.val) and (tall2.val le (tall.val + cm_damages_SccHorizon)) ),   !! add this for limiting horizon of damage consideration: and (tall2.val le 2150)
	 (1 + pm_prtp(regi2))**(-(tall2.val - tall.val))
	* pm_consPC(tall,regi2)/pm_consPC(tall2,regi2) 
        * pm_GDPGross(tall2,regi2) 
	* pm_temperatureImpulseResponseCO2(tall2,tall)
	* pm_damageMarginal(tall2,"USA") !! USA stands as a dummy for a global value here
    )
   )
;

*if(cm_iterative_target_adj eq 10 and cm_emiscen eq 9 and  mod(iteration.val,2) eq 1,   !! update only every uneven iteration to prevent zig-zagging

pm_taxCO2eqSCC(ttot,regi) = 0;

loop(ttot$(ttot.val ge 2010),
	loop(tall$(pm_ttot_2_tall(ttot,tall)),
	    pm_taxCO2eqSCC(ttot,regi)$(ttot.val ge 2010) = p51_scc(tall)   * (44/12)/1000;
	));
	    
*);

* prevent drastic decline towards the final periods
pm_taxCO2eqSCC(ttot,regi)$(ttot.val gt 2100) = pm_taxCO2eqSCC("2100",regi); 

display p51_scc,pm_taxCO2eqSCC;


* convergence indicator:
p51_sccConvergenceMaxDeviation = 100 * smax(tall$(tall.val ge cm_startyear and tall.val lt 2150),abs(p51_scc(tall)/max(p51_sccLastItr(tall),1e-8) - 1) );
display p51_sccConvergenceMaxDeviation;


