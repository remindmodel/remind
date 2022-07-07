*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/51_internalizeDamages/LabItr/postsolve.gms

p51_labXi(tall,regi)$(tall.val ge 2150) = p51_labXi("2150",regi);
p51_labEff(tall,regi)$(tall.val ge 2150) = p51_labEff("2150",regi);
p51_labEffgr(tall,regi)$(tall.val ge 2150) = p51_labEffgr("2150",regi);
p51_labRho(tall,regi)$(tall.val ge 2150) = p51_labRho("2150",regi);
p51_lab(tall,regi)$(tall.val ge 2150) = p51_lab("2150",regi);

loop(ttot$(ttot.val ge 2010),
	loop(tall$(pm_tall_2_ttot(tall,ttot)),
		p51_labXi(tall,regi)=(1-pm_interpolWeight_ttot_tall(tall))*pm_cesdata(ttot,regi,"lab","xi")
				     + pm_interpolWeight_ttot_tall(tall) * pm_cesdata(ttot+1,regi,"lab","xi");
		p51_labEff(tall,regi)=(1-pm_interpolWeight_ttot_tall(tall))*pm_cesdata(ttot,regi,"lab","eff")
				     + pm_interpolWeight_ttot_tall(tall) * pm_cesdata(ttot+1,regi,"lab","eff");
		p51_labEffgr(tall,regi)=(1-pm_interpolWeight_ttot_tall(tall))*pm_cesdata(ttot,regi,"lab","effgr")
				     + pm_interpolWeight_ttot_tall(tall) * pm_cesdata(ttot+1,regi,"lab","effgr");
		p51_labRho(tall,regi)=(1-pm_interpolWeight_ttot_tall(tall))*pm_cesdata(ttot,regi,"inco","rho")
				     + pm_interpolWeight_ttot_tall(tall) * pm_cesdata(ttot+1,regi,"inco","rho");
		p51_lab(tall,regi)=(1-pm_interpolWeight_ttot_tall(tall))*pm_lab(ttot,regi)
				     + pm_interpolWeight_ttot_tall(tall) * pm_lab(ttot+1,regi);
));

*calculate damage shift factor, pm_GDPGross is already the GDP net of the labor damage, s I calculate the actual gross GDP
p51_ygross(tall,regi)$((tall.val ge 2010)) = 
	(pm_GDPGross(tall,regi)**p51_labRho(tall,regi)
	+ p51_labXi(tall,regi)*(p51_labEff(tall,regi)*p51_labEffgr(tall,regi)*p51_lab(tall,regi))**p51_labRho(tall,regi)
        *(1-pm_damage(tall,regi)**p51_labRho(tall,regi))
	)**(1/p51_labRho(tall,regi))
;

p51_dy(tall,regi)$((tall.val ge 2010) and (tall.val le 2150)) = pm_GDPGross(tall,regi)/p51_ygross(tall,regi);

display p51_dy;

p51_sccParts(tall,tall2,regi2)$((tall.val ge 2010) and (tall.val le 2150) and (tall2.val ge tall.val) and (tall2.val le 2250)) = 
        pm_GDPGross(tall2,regi2)**(1-p51_labRho(tall2,regi2))* p51_labXi(tall2,regi2)*(p51_labEff(tall2,regi2)*p51_labEffgr(tall2,regi2)*p51_lab(tall2,regi2))**p51_labRho(tall2,regi2)
	* pm_damage(tall2,regi2)**(p51_labRho(tall2,regi2)-1)
	* pm_temperatureImpulseResponseCO2(tall2,tall) * pm_tempScaleGlob2Reg(tall2,regi2)
	* pm_damageMarginal(tall2,regi2)*(-1) 
;	

p51_sccLastItr(tall) = p51_scc(tall);
p51_scc(tall)$((tall.val ge 2010) and (tall.val le 2150)) = 1000 *
    sum(regi2,
    sum(tall2$( (tall2.val ge tall.val) and (tall2.val le (tall.val + cm_damages_SccHorizon)) ),   !! add this for limiting horizon of damage consideration: and (tall2.val le 2150)
	 (1 + pm_prtp(regi2))**(-(tall2.val - tall.val))
	* pm_consPC(tall,regi2)/(pm_consPC(tall2,regi2)+1e-8) 
	* p51_sccParts(tall,tall2,regi2)
    )
   )
;

*if(cm_iterative_target_adj eq 10 and cm_emiscen eq 9 and  mod(iteration.val,2) eq 1,   !! update only every uneven iteration to prevent zig-zagging

pm_taxCO2eqSCC(ttot,regi) = 0;
pm_taxCO2eqSCC(ttot,regi)$(ttot.val ge 2020) = p51_scc(ttot) * (44/12)/1000;

*);

* prevent drastic decline towards the final periods
pm_taxCO2eqSCC(ttot,regi)$(ttot.val gt 2100) = pm_taxCO2eqSCC("2100",regi); 

display p51_scc,pm_taxCO2eqSCC;


* convergence indicator:
*p51_sccConvergenceMaxDeviation = 100 * smax(tall$(tall.val ge cm_startyear and tall.val lt 2150),abs(p51_scc(tall)/max(p51_sccLastItr(tall),1e-8) - 1) );
p51_sccConvergenceMaxDeviation = 100 * smax(tall$(tall.val ge cm_startyear and tall.val lt 2150),abs(p51_scc(tall)/(p51_sccLastItr(tall)+1e-8) - 1) );
display p51_sccConvergenceMaxDeviation;

*** EOF ./modules/51_internalizeDamages/LabItr/postsolve.gms

