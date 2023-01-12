*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/32_power/DTcoup/equations.gms

***---------------------------------------------------------------------------
*** Balance equation for electricity secondary energy type:
***---------------------------------------------------------------------------
q32_balSe(t,regi,enty2)$(sameas(enty2,"seel"))..
	sum(pe2se(enty,enty2,te), vm_prodSe(t,regi,enty,enty2,te) )
	+ sum(se2se(enty,enty2,te), vm_prodSe(t,regi,enty,enty2,te) )
	+ sum(pc2te(enty,entySE(enty3),te,enty2), 
		pm_prodCouple(regi,enty,enty3,te,enty2) * vm_prodSe(t,regi,enty,enty3,te) )
	+ sum(pc2te(enty4,entyFE(enty5),te,enty2), 
		pm_prodCouple(regi,enty4,enty5,te,enty2) * vm_prodFe(t,regi,enty4,enty5,te) )
	+ sum(pc2te(enty,enty3,te,enty2),
		sum(teCCS2rlf(te,rlf),
			pm_prodCouple(regi,enty,enty3,te,enty2) * vm_co2CCS(t,regi,enty,enty3,te,rlf) ) )
	+ vm_Mport(t,regi,enty2)
  =e=
    sum(se2fe(enty2,enty3,te), vm_demSe(t,regi,enty2,enty3,te) )
	+ sum(se2se(enty2,enty3,te), vm_demSe(t,regi,enty2,enty3,te) )
	+ sum(teVRE, v32_storloss(t,regi,teVRE) )
	+ sum(pe2rlf(enty3,rlf2), (pm_fuExtrOwnCons(regi, enty2, enty3) * vm_fuExtr(t,regi,enty3,rlf2))$(pm_fuExtrOwnCons(regi, enty2, enty3) gt 0))$(t.val > 2005) !! do not use in 2005 because this demand is not contained in 05_initialCap
	+ vm_Xport(t,regi,enty2)
;

q32_usableSe(t,regi,entySe)$(sameas(entySe,"seel"))..
	vm_usableSe(t,regi,entySe)
	=e=
	sum(pe2se(enty,entySe,te), vm_prodSe(t,regi,enty,entySe,te) )
	+ sum(se2se(enty,entySe,te), vm_prodSe(t,regi,enty,entySe,te) ) 
	+ sum(pc2te(entyPe,entySe(enty3),te,entySe)$(pm_prodCouple(regi,entyPe,enty3,te,entySe) gt 0),
		pm_prodCouple(regi,entyPe,enty3,te,entySe)*vm_prodSe(t,regi,entyPe,enty3,te) )
	- sum(teVRE, v32_storloss(t,regi,teVRE) )
;

q32_usableSeTe(t,regi,entySe,te)$(sameas(entySe,"seel") AND teVRE(te))..
 	vm_usableSeTe(t,regi,entySe,te)
 	=e=
 	sum(pe2se(enty,entySe,te), vm_prodSe(t,regi,enty,entySe,te) )
	+ sum(se2se(enty,entySe,te), vm_prodSe(t,regi,enty,entySe,te) )
 	+ sum(pc2te(enty,entySe(enty3),te,entySe)$(pm_prodCouple(regi,enty,enty3,te,entySe) gt 0),
		pm_prodCouple(regi,enty,enty3,te,entySe) * vm_prodSe(t,regi,enty,enty3,te) )
 	- sum(teVRE$sameas(te,teVRE), v32_storloss(t,regi,teVRE) )
;

***---------------------------------------------------------------------------
*** Definition of capacity constraints for storage:
***---------------------------------------------------------------------------
q32_limitCapTeStor(t,regi,teStor)$( t.val ge 2015 ) ..
    ( 0.5$( cm_VRE_supply_assumptions eq 1 )
    + 1$(   cm_VRE_supply_assumptions ne 1 )
    )
  * sum(VRE2teStor(teVRE,teStor), v32_storloss(t,regi,teVRE))
  * pm_eta_conv(t,regi,teStor)
  / (1 - pm_eta_conv(t,regi,teStor))
  =l=
  sum(te2rlf(teStor,rlf),
    vm_capFac(t,regi,teStor)
  * pm_dataren(regi,"nur",rlf,teStor)
  * vm_cap(t,regi,teStor,rlf)
  )
;


*** H2 storage implementation: Storage technologies (storspv, storwind etc.) also
*** represent H2 storage. This is implemented by automatically scaling up capacities of 
*** elh2VRE (electrolysis from VRE, seel -> seh2) and H2 turbines (h2turbVRE, seh2 -> seel)
*** with VRE capacities which require storage (according to q32_limitCapTeStor):


*** build additional electrolysis capacities with stored VRE electricity
q32_elh2VREcapfromTestor(t,regi)..
  vm_cap(t,regi,"elh2","1") 
  =g= 
  sum(te$testor(te), p32_storageCap(te,"elh2VREcapratio") * vm_cap(t,regi,te,"1") )
;

*** build additional h2 to seel capacities to use stored hydrogen
q32_h2turbVREcapfromTestor(t,regi)..
  vm_cap(t,regi,"h2turbVRE","1") 
  =e= 
  sum(te$testor(te), p32_storageCap(te,"h2turbVREcapratio") * vm_cap(t,regi,te,"1") )
;


***---------------------------------------------------------------------------
*** Definition of capacity constraints for CHP technologies:
***---------------------------------------------------------------------------
q32_limitCapTeChp(t,regi)..
    sum(pe2se(enty,"seel",teChp(te)), vm_prodSe(t,regi,enty,"seel",te) )
    =l=
    p32_shCHP(t,regi)
    * sum(pe2se(enty,"seel",te), vm_prodSe(t,regi,enty,"seel",te) )
;
		 
***---------------------------------------------------------------------------
*** Calculation of necessary grid installations for centralized renewables:
***---------------------------------------------------------------------------
q32_limitCapTeGrid(t,regi)$( t.val ge 2015 ) .. 
    vm_cap(t,regi,"gridwind",'1')      !! Technology is now parameterized to yield marginal costs of ~3.5$/MWh VRE electricity
    / p32_grid_factor(regi)        		!! It is assumed that large regions require higher grid investment 
    =g=
    vm_prodSe(t,regi,"pesol","seel","spv")                
    + vm_prodSe(t,regi,"pesol","seel","csp")
    + 1.5 * vm_prodSe(t,regi,"pewin","seel","wind")                 !! wind has larger variations accross space, so adding grid is more important for wind (result of REMIX runs for ADVANCE project)
$IFTHEN.WindOff %cm_wind_offshore% == "1"
    + 3 * vm_prodSe(t,regi,"pewin","seel","windoff")         
$ENDIF.WindOff
;

***---------------------------------------------------------------------------
*** Calculation of share of electricity production of a technology:
***---------------------------------------------------------------------------
q32_shSeEl(t,regi,teVRE)..
    vm_shSeEl(t,regi,teVRE) / 100 * vm_usableSe(t,regi,"seel")
    =e=
    vm_usableSeTe(t,regi,"seel",teVRE)
;

***---------------------------------------------------------------------------
*** Calculation of necessary storage electricity production:
***---------------------------------------------------------------------------
q32_shStor(t,regi,teVRE)$(t.val ge 2015)..
	v32_shStor(t,regi,teVRE)
	=g=
	p32_factorStorage(regi,teVRE) * 100 
	* (
		(1.e-10 + (vm_shSeEl(t,regi,teVRE)+ sum(VRE2teVRElinked(teVRE,teVRE2), vm_shSeEl(t,regi,teVRE2)) /s32_storlink)/100 ) ** p32_storexp(regi,teVRE)    !! offset of 1.e-10 for numerical reasons: gams doesn't like 0 if the exponent is not integer 
		- (1.e-10 ** p32_storexp(regi,teVRE) )       !! offset correction
		- 0.07                                      !! first 7% of VRE share bring no negative effects
	)
;

q32_storloss(t,regi,teVRE)$(t.val ge 2015)..
	v32_storloss(t,regi,teVRE)
	=e=
	v32_shStor(t,regi,teVRE) / 93    !! corrects for the 7%-shift in v32_shStor: at 100% the value is correct again
	* sum(VRE2teStor(teVRE,teStor), (1 - pm_eta_conv(t,regi,teStor) ) /  pm_eta_conv(t,regi,teStor) )
	* vm_usableSeTe(t,regi,"seel",teVRE)
;

***---------------------------------------------------------------------------
*** Operating reserve constraint
***---------------------------------------------------------------------------
q32_operatingReserve(t,regi)$(t.val ge 2010)..
***1 is the chosen load coefficient
	vm_usableSe(t,regi,"seel")
	=l=    
***Variable renewable coefficients could be expected to be negative because they are variable.
***However they are modeled positive because storage conditions make variable renewables controllable.
	sum(pe2se(enty,"seel",te)$(NOT teVRE(te)),
		pm_data(regi,"flexibility",te) * vm_prodSe(t,regi,enty,"seel",te) )
	+ sum(se2se(enty,"seel",te)$(NOT teVRE(te)),
		pm_data(regi,"flexibility",te) * vm_prodSe(t,regi,enty,"seel",te) )
	+ sum(pe2se(enty,"seel",teVRE),
		pm_data(regi,"flexibility",teVRE) * (vm_prodSe(t,regi,enty,"seel",teVRE)-v32_storloss(t,regi,teVRE)) )
	+
	sum(pe2se(enty,"seel",teVRE),
		sum(VRE2teStor(teVRE,teStor),
			pm_data(regi,"flexibility",teStor) * (vm_prodSe(t,regi,enty,"seel",teVRE)-v32_storloss(t,regi,teVRE)) ) )
;

***---------------------------------------------------------------------------
*** EMF27 limits on fluctuating renewables, only turned on for special EMF27 and AWP 2 scenarios, not for SSP
***---------------------------------------------------------------------------
q32_limitSolarWind(t,regi)$( (cm_solwindenergyscen = 2) OR (cm_solwindenergyscen = 3) )..
	vm_usableSeTe(t,regi,"seel","spv") + vm_usableSeTe(t,regi,"seel","wind") + vm_usableSeTe(t,regi,"seel","csp") 
	=l=
	0.2 * vm_usableSe(t,regi,"seel")
;

***----------------------------------------------------------------------------
*** FS: calculate flexibility adjustment used in flexibility tax for technologies with electricity input 
***----------------------------------------------------------------------------

*** This equation calculates the minimal flexible electricity price that flexible technologies (like elh2) can see. It is reached when the VRE share is 100%.
*** It depends on the capacity factor with a hyperbolic function. The equation ensures that by decreasing 
*** capacity factor of flexible technologies (teFlex) these technologies see lower electricity prices given that there is a high VRE share in the power system.

*** On the derivation of the equation: 
*** The formulation assumes a cubic price duration curve. That is, the effective electricity price the flexible technologies sees
*** depends on the capacity factor (CF) with a cubic function centered at (0.5,1): 
*** p32_PriceDurSlope * (CF-0.5)^3 + 1, 
*** Hence, at CF = 0.5, the REMIND average price pm_SEPrice(t,regi,"seel") is paid. 
*** To get the average electricity price that a flexible technology sees at a certain CF, 
*** we need to integrate this function with respect to CF and divide by CF. This gives the formulation below:
*** v32_flexPriceShareMin = p32_PriceDurSlope * ((CF-0.5)^4-0.5^4) / (4*CF) + 1.
*** This is the new average electricity price a technology sees if it runs on (a possibly lower than one) capacity factor CF 
*** and deliberately uses hours of low-cost electricity.
 q32_flexPriceShareMin(t,regi,te)$(teFlex(te))..
  v32_flexPriceShareMin(t,regi,te) * 4 * vm_capFac(t,regi,te)
  =e=
  p32_PriceDurSlope(regi,te) * (power(vm_capFac(t,regi,te) - 0.5,4) - 0.5**4) +
  4 * vm_capFac(t,regi,te) 
;

*** Calculates the electricity price of flexible technologies:
*** The effective flexible price linearly decreases with VRE share
*** from 1 (at 0% VRE share) to v32_flexPriceShareMin (at 100% VRE). 
q32_flexPriceShare(t,regi,te)$(teFlex(te))..
  v32_flexPriceShare(t,regi,te)
  =e=
  1 - (1-v32_flexPriceShareMin(t,regi,te)) * sum(teVRE, vm_shSeEl(t,regi,teVRE))/100
;

*** This balance ensures that the lower electricity prices of flexible technologies are compensated 
*** by higher electricity prices of inflexible technologies. Inflexible technologies are all technologies
*** which are part of teFlexTax but not of teFlex. The weighted sum of 
*** flexible/inflexible electricity prices (v32_flexPriceShare) and electricity demand must be one. 
*** Note: this is only on if cm_FlexTaxFeedback = 1. Otherwise, there is no change in electricity prices for inflexible technologies. 
q32_flexPriceBalance(t,regi)$(cm_FlexTaxFeedback eq 1)..
  sum(en2en(enty,enty2,te)$(teFlexTax(te)), 
  	vm_demSe(t,regi,enty,enty2,te)) 
  =e=
  sum(en2en(enty,enty2,te)$(teFlexTax(te)), 
  	vm_demSe(t,regi,enty,enty2,te) * v32_flexPriceShare(t,regi,te)) 
;


*** This calculates the flexibility benefit or cost per unit electricity input 
*** of flexibile or inflexibly technology. 
*** In the tax module, vm_flexAdj is then deduced from the electricity price via the flexibility tax formulation. 
*** Below, pm_SEPrice(t,regi,"seel") is the (average) electricity price from the last iteration. 
*** Flexible technologies benefit (v32_flexPriceShare < 1),
*** while inflexible technologies are penalized (v32_flexPriceShare > 1).  
*** Flexibility tax is switched only if cm_flex_tax = 1 and is active from 2025 onwards. 
q32_flexAdj(t,regi,te)$(teFlexTax(te))..
	vm_flexAdj(t,regi,te) 
	=e=
	(1-v32_flexPriceShare(t,regi,te)) * pm_SEPrice(t,regi,"seel")$((cm_flex_tax eq 1) AND (t.val ge 2025) and (pm_SEPrice(t,regi,"seel") gt 0))
;

*** EOF ./modules/32_power/DTcoup/equations.gms
