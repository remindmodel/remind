*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de


if(iteration.val gt 2,

*#' @equations
*#' first-order condition for optimal carbon price of a not-to-exceed temperature target 
*#' see Supplementary Material 2.2 of Schultes et al (2018) for a derivation
p45_taxTempLimit(tall)$((tall.val ge 2010) and (tall.val le 2150)) =
    44/12 * 
    sum(regi2,
    sum(tall2$( (tall2.val ge tall.val) and (tall2.val le 2130)),   !! add this for limiting horizon of damage consideration: and (tall2.val le 2150)
	 (1 + pm_prtp(regi2) )**(-(tall2.val - tall.val))
	* pm_consPC(tall,regi2)/pm_consPC(tall2,regi2) 
        * pm_GDPGross(tall2,regi2) 
	* pm_temperatureImpulseResponseCO2(tall2,tall) 
	*  1/( 1 
           + exp( -(pm_globalMeanTemperature(tall2) - cm_carbonprice_temperatureLimit )/s45_eta )
         )
    )
   )
;
    
*#' feed back optimal price into carbon tax   
loop(ttot$(ttot.val ge 2010),
	loop(tall$(pm_ttot_2_tall(ttot,tall)),
* simple, but may jump over iterations instead of converging:    
*	    pm_taxCO2eq(ttot,regi)$(ttot.val ge 2010) = p45_taxTempLimit(tall);

* instead, adjust price slowly from a small value. 
* The idea is to let the model run a couple of iterations, then impose a pm_taxCO2eq if the temperature limit is binding.
        if(iteration.val eq 3, !! set starting point
            pm_taxCO2eq(ttot,regi)$(ttot.val ge 2010) = 0.5/270 * 1.05**(ttot.val - 2010);
        );    
            pm_taxCO2eq(ttot,regi)$(ttot.val ge 2010) = 
            pm_taxCO2eq(ttot,regi) 
            * max(0.33,min(3,(p45_taxTempLimit(tall)/max(1e-7,pm_taxCO2eq(ttot,regi)))**s45_itrAdjExp)); 
* convergence is easier for high s45_eta and low exponent (def: 0.04) here (which also makes it slower). 


	));
);

* optional: prevent the tax from falling to zero in the last time step
*pm_taxCO2eq("2150",regi) = pm_taxCO2eq("2130",regi);  

* optional, on by default: keep price constant after 2100
* please check that temperature curves look reasonable and consistent with your story 
*#' keep price constant after 2100
pm_taxCO2eq(ttot,regi)$(ttot.val ge 2110)  = pm_taxCO2eq("2100",regi);

display pm_taxCO2eq, p45_taxTempLimit;	    

* display convergence indicators
s45_taxTempLimitConvMaxDeviation = 
    100 * smax(tall$(tall.val le 2130),
            abs(max(1e-4,p45_taxTempLimit(tall))
            /max(p45_taxTempLimitLastItr(tall),1e-4) - 1) 
          );

p45_taxTempLimitLastItr(tall) = p45_taxTempLimit(tall);
display s45_taxTempLimitConvMaxDeviation;


