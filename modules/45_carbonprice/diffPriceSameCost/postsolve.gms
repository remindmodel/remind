*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/diffPriceSameCost/postsolve.gms

* let all regional prices be adjusted by magicc to reach global target
* in here, correct regional carbon prices such that equal relative costs (in NPV) is reached


display pm_taxCO2eq;
*calc relative mitigation costs from policy and baseline consumption. -> p45_mitiCostRel


p45_mitiCostRel(regi) = 1 -
    sum(ttot$((ttot.val ge max(2010,cm_startyear)) and (ttot.val le 2100) ),    (
	pm_ts(ttot-1)/2 * pm_pvp(ttot-1,"good") * vm_cesIO.l(ttot-1,regi,"inco")
      + pm_ts(ttot)/2 *pm_pvp(ttot,"good") *  vm_cesIO.l(ttot,regi,"inco")) )
    
   /
    sum(ttot$((ttot.val ge max(2010,cm_startyear)) and (ttot.val le 2100) ),
	  (     pm_ts(ttot-1)/2 * pm_pvp(ttot -1,"good") * p45_gdpBAU(ttot-1,regi)
	      + pm_ts(ttot)/2 * pm_pvp(ttot,"good") *   p45_gdpBAU(ttot,regi) ) )
;

p45_mitiCostRelGlob = 1 -
    sum(regi,sum(ttot$((ttot.val ge max(2010,cm_startyear)) and (ttot.val le 2100) ),    (
	pm_ts(ttot-1)/2 * pm_pvp(ttot-1,"good") * vm_cesIO.l(ttot-1,regi,"inco")
      + pm_ts(ttot)/2 *pm_pvp(ttot,"good") *  vm_cesIO.l(ttot,regi,"inco")) ))
    
   /
    sum(regi,sum(ttot$((ttot.val ge max(2010,cm_startyear)) and (ttot.val le 2100) ),
	  (     pm_ts(ttot-1)/2 * pm_pvp(ttot -1,"good") * p45_gdpBAU(ttot-1,regi)
	      + pm_ts(ttot)/2 * pm_pvp(ttot,"good") *   p45_gdpBAU(ttot,regi) ) ))
;


option decimals = 4;    
display p45_mitiCostRel,p45_mitiCostRelGlob;
option decimals = 2;    


* correct carbon price at t0 linear(?) in differenece to global mean
*FIXME global mean of relative costs or relative global costs?
pm_taxCO2eq("2020",regi) = pm_taxCO2eq("2020",regi) * (
1 - p45_correctScale * (p45_mitiCostRel(regi) - p45_mitiCostRelGlob )
*1 -  sign((p45_mitiCostRel(regi) - p45_mitiCostRelGlob ))* abs((p45_mitiCostRel(regi) - p45_mitiCostRelGlob)/0.02 )**0.8
);




* calculate new price trajectories

pm_taxCO2eq(ttot,regi)$(ttot.val ge 2005) = pm_taxCO2eq("2020",regi)*cm_co2_tax_growth**(ttot.val-2020);

display pm_taxCO2eq;

*debugging:
p45_debugCprice2020(regi,iteration) = pm_taxCO2eq("2020",regi);
p45_debugMitiCostRel(regi,iteration) = p45_mitiCostRel(regi);
*** EOF ./modules/45_carbonprice/diffPriceSameCost/postsolve.gms
