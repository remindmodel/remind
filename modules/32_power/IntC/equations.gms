*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/32_power/IntC/equations.gms

*' @equations

***---------------------------------------------------------------------------
*' Balance equation for electricity secondary energy type:
***---------------------------------------------------------------------------
q32_balSe(t,regi,enty2)$(sameas(enty2,"seel"))..
    sum(pe2se(enty,enty2,te), vm_prodSe(t,regi,enty,enty2,te) )
  + sum(se2se(enty,enty2,te), vm_prodSe(t,regi,enty,enty2,te) )
  + sum(pc2te(enty,entySe(enty3),te,enty2), 
        pm_prodCouple(regi,enty,enty3,te,enty2) * vm_prodSe(t,regi,enty,enty3,te) )
  + sum(pc2te(enty4,entyFe(enty5),te,enty2), 
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


*' This equation calculates the total usable output from all seel-producing technology after deducting storage losses
q32_usableSe(t,regi,entySe)$(sameas(entySe,"seel"))..
    vm_usableSe(t,regi,entySe)
    =e=
    sum(pe2se(enty,entySe,te), vm_prodSe(t,regi,enty,entySe,te) )
  + sum(se2se(enty,entySe,te), vm_prodSe(t,regi,enty,entySe,te) ) 
  + sum(pc2te(entyPe,entySe(enty3),te,entySe)$(pm_prodCouple(regi,entyPe,enty3,te,entySe) gt 0),
        pm_prodCouple(regi,entyPe,enty3,te,entySe)*vm_prodSe(t,regi,entyPe,enty3,te) )
  - sum(teVRE, v32_storloss(t,regi,teVRE) )
;

*' This equation calculates the total usable output from a seel-producing technology, meaning "after storage losses"
q32_usableSeTe(t,regi,entySe,te)$(sameas(entySe,"seel") AND teVRE(te))..
     v32_usableSeTe(t,regi,entySe,te)
     =e=
     sum(pe2se(enty,entySe,te), vm_prodSe(t,regi,enty,entySe,te) )
   + sum(se2se(enty,entySe,te), vm_prodSe(t,regi,enty,entySe,te) )
   + sum(pc2te(enty,entySe(enty3),te,entySe)$(pm_prodCouple(regi,enty,enty3,te,entySe) gt 0),
         pm_prodCouple(regi,enty,enty3,te,entySe) * vm_prodSe(t,regi,enty,enty3,te) )
   - sum(teVRE$sameas(te,teVRE), v32_storloss(t,regi,teVRE) )
;

***---------------------------------------------------------------------------
*' Definition of capacity constraints for storage:
***---------------------------------------------------------------------------
*' This equation calculates the storage capacity for each teStor that needs to be installed based on the amount of
*' v32_storloss that is calculated below in q32_storloss. Multiplying v32_storloss with "eta/(1-eta)" yields
*' the total output of a storage technology; this output has to be smaller than cap * capfac.  
q32_limitCapTeStor(t,regi,teStor)$( t.val ge 2020 ) ..
    ( 0.5$( cm_VRE_supply_assumptions eq 1 )   !! reduce storage investment needs by half for VRE_supply_assumptions = 1 
    + 1$(   cm_VRE_supply_assumptions ne 1 )
    )
  * sum(VRE2teStor(teVRE,teStor), v32_storloss(t,regi,teVRE))
  * pm_eta_conv(t,regi,teStor)
  / (1 - pm_eta_conv(t,regi,teStor))
  =l=
  sum(te2rlf(teStor,rlf),
    vm_capFac(t,regi,teStor)
  * vm_cap(t,regi,teStor,rlf)
  )
;


*** H2 storage implementation:
*** Storage technologies (storspv, storwind etc.) also represent H2 storage.
*** This is implemented by scaling up capacities of H2 turbines (h2turbVRE, seh2 -> seel)
*** with VRE capacities which require storage (according to q32_limitCapTeStor). 
*** These H2 turbines (h2turbVRE) do not have capital cost. Their cost are already considered in storage technologies.
*** H2 turbines are not needed if sufficient gas turbines (ngt) are available to provide flexibility. 
*' Require a certain capacity of either hydrogen or gas turbines as peaking backup capacity. The driver is the teStor capacity, which in turn is determined by v32_storloss 
q32_h2turbVREcapfromTestor(t,regi)..
  vm_cap(t,regi,"h2turbVRE","1")
  + vm_cap(t,regi,"ngt","1")
  =g=
  sum(teStor,
    p32_storageCap(teStor,"h2turbVREcapratio") * vm_cap(t,regi,teStor,"1") )
;

*** h2turbVRE hydrogen turbines should only be built in conjunction with storage capacities and not on its own
q32_h2turbVREcapfromTestorUp(t,regi)..
  vm_cap(t,regi,"h2turbVRE","1")
  =l=
  sum(teStor,
    p32_storageCap(teStor,"h2turbVREcapratio") * vm_cap(t,regi,teStor,"1") )
;

*** build additional electrolysis capacities with stored VRE electricity, phase-in from 2030 to 2040
q32_elh2VREcapfromTestor(t,regi)..
  vm_cap(t,regi,"elh2","1")
  =g=
  sum(teStor,
    p32_storageCap(teStor,"elh2VREcapratio") * vm_cap(t,regi,teStor,"1")
  )
  * p32_phaseInElh2VREcap(t)
;


***---------------------------------------------------------------------------
*' Definition of capacity constraints for CHP technologies:
***---------------------------------------------------------------------------
q32_limitCapTeChp(t,regi)..
    sum(pe2se(enty,"seel",teChp(te)), vm_prodSe(t,regi,enty,"seel",te) )
    =l=
    p32_shCHP(t,regi) 
    * sum(pe2se(enty,"seel",te), vm_prodSe(t,regi,enty,"seel",te) )
;

***---------------------------------------------------------------------------
*' Calculation of necessary grid installations for centralized renewables:
***---------------------------------------------------------------------------
*' Additional grid expansion to integrate VRE are driven linearly by VRE output 
q32_limitCapTeGrid(t,regi)$( t.val ge 2020 ) .. 
    vm_cap(t,regi,"gridwindon",'1')    !! Technology is now parameterized to yield marginal costs of ~3.5$/MWh VRE electricity
    / p32_grid_factor(regi)            !! It is assumed that large regions require higher grid investment 
    =g=
    vm_prodSe(t,regi,"pesol","seel","spv")                
    + vm_prodSe(t,regi,"pesol","seel","csp")
    + 1.5 * vm_prodSe(t,regi,"pewin","seel","windon")  !! wind has larger variations accross space, so adding grid is more important for wind (result of REMIX runs for ADVANCE project)
    + 3   * vm_prodSe(t,regi,"pewin","seel","windoff") !! Getting offshore wind connected has even higher grid costs 
;

***---------------------------------------------------------------------------
*' Calculation of share of electricity production of a technology:
***---------------------------------------------------------------------------
q32_shSeEl(t,regi,teVRE)..
    vm_shSeEl(t,regi,teVRE) / 100 * vm_usableSe(t,regi,"seel")
    =e=
    v32_usableSeTe(t,regi,"seel",teVRE)
;

***---------------------------------------------------------------------------
*' Calculation of necessary storage electricity production:
***---------------------------------------------------------------------------
*' v32_shStor is an aggregated measure for the SPECIFIC (= per kWh) integration challenge of one teVRE. It currently increases linearly in VRE share as p32_storexp is set to 1
*' For solar technologies that have a very strong temporal mathching (PV, CSP), the share of the other technology also increases integration challenges by a reduced factor.    
q32_shStor(t,regi,teVRE)$(t.val ge 2015)..
  v32_shStor(t,regi,teVRE)
  =g=
  p32_factorStorage(regi,teVRE) * 100 
  * 
  (
    ( 1.e-10 
      + (
         vm_shSeEl(t,regi,teVRE)              !! own share 
         + sum(VRE2teVRElinked(teVRE,teVRE2), vm_shSeEl(t,regi,teVRE2)) / s32_storlink     !! share of VRE where the temporal pattern is strongly linekd (PV and CSP) 
        ) / 100 
    ) ** p32_storexp(regi,teVRE)              !! offset of 1.e-10 for numerical reasons: GAMS doesnt like 0 for non-integer exponent 
    - (1.e-10 ** p32_storexp(regi,teVRE) )    !! offset correction
    - 0.07                                    !! first 7% of VRE share have no integration challenges
  )
;

*' v32_storloss is both the energy that is lost due to curtailment and storage losses, and at the same time the main indicator of ABSOLUTE integration challenges,
*' as it drives storage investments and thus the additional costs seen by VRE. It depends linearly on the usableSE output from this VRE, and linearly on the 
*' SPECIFIC integration challenges, which in turn are mainly the adjusted share of the technology itself (v32_shSTor), but also increase when the total VRE share 
*' increases beyond a (time-dependent) threshold.
*' The term "(1-eta)/eta" is equal to the ratio "losses of a teStor" to "output of a teStor". 
*' An example: If the specific integration challenges (v32_shStor + p32_Fact * v32_shAddInt) of eg. PV would reach 100%, then ALL the usable output of PV 
*' would have to be "stabilized" by going through storsp, so the total storage losses & curtailment would exactly represent the (1-eta) values of storspv. When
*' the specific integration challenge term () is below 100%, the required storage and resulting losses are scaled down accordingly.    
q32_storloss(t,regi,teVRE)$(t.val ge 2020)..
  v32_storloss(t,regi,teVRE)
  =e=
  ( v32_shStor(t,regi,teVRE)                                         !! integration challenges due to the technology itself
    + p32_FactorAddIntCostTotVRE * v32_shAddIntCostTotVRE(t,regi)    !! integration challenges due to the total VRE share
  ) / 100    
  * sum(VRE2teStor(teVRE,teStor), (1 - pm_eta_conv(t,regi,teStor) ) /  pm_eta_conv(t,regi,teStor) )
  * v32_usableSeTe(t,regi,"seel",teVRE)
;

q32_TotVREshare(t,regi)..
  v32_TotVREshare(t,regi)
  =e=
  sum(teVRE, 
    vm_shSeEl(t,regi,teVRE) 
  )
;

*' Calculate additional integration costs if total VRE share is above a certain threshold. A system with only 40% VRE will be less challenged to handle 30% PV than
*' a system with 70% VRE, because you have less thermal plants that can act as backup and provide inertia. This threshold increases over time to represent that 
*' network operators learn about managing high-VRE systems, and that technologies such as grid-stabilizing VRE and batteries become widespread. 
q32_shAddIntCostTotVRE(t,regi)..
  v32_shAddIntCostTotVRE(t,regi)
  =g=
  v32_TotVREshare(t,regi)
  - p32_shThresholdTotVREAddIntCost(t)
  - 0.5 * vm_shSeEl(t,regi,"windoff")  !! for offshore wind, the correlation with other VRE is much smaller, reducing the additional integration challenge
;

***---------------------------------------------------------------------------
*' Operating reserve constraint
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

***----------------------------------------------------------------------------
*'  calculate flexibility adjustment used in flexibility tax for technologies with electricity input 
***----------------------------------------------------------------------------

*** This equation calculates the minimal flexible electricity price that flexible technologies (like elh2) can see. It is reached when the VRE share is 100%.
*** It depends on the capacity factor with a hyperbolic function. The equation ensures that by decreasing
*** capacity factor of flexible technologies (teFlex) these technologies see lower electricity prices given that there is a high VRE share in the power system.
*** Note: By default, capacity factors in REMIND are exogenuous (see bounds file of the power module).
*** In that standard case, the minimum electricity price for electrolysis, v32_flexPriceShareMin, only depends on p32_PriceDurSlope,
*** which is defined by scenario assumptions via the switch cm_PriceDurSlope_elh2.
*** It essentially makes an assumption about how many low electricity price hours electrolysis will run on in future VRE-based power systems.
*** The standard value is derived from data of the German Langfristszenarien (see datainput file).

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

*** Calculates the minimum electricity price of flexible technologies depending on VRE share.
*** 100% VRE share will give v32_flexPriceShareMin,
*** 0% VRE share will give 1, i.e. no flexibility benefit or cost.
*** In the latter case, electricity price is annual average electricity price from pm_SEPrice.
*** Linear relation assumed between flexibility benefit or cost in range of 0-100% VRE share.
*** This parameterizes that flexibility benefits increase in power systems with higher VRE shares.
q32_flexPriceShareVRE(t,regi,te)$(teFlex(te))..
  v32_flexPriceShareVRE(t,regi,te)
  =e=
  1 - 
*** maximum flexibility benefit
  (   ( 1-v32_flexPriceShareMin(t,regi,te) )
*** VRE share
    * sum(teVRE, vm_shSeEl(t,regi,teVRE))/100
  )
;

*** Calculate share of electricity demand per technology in total electricity demand
*** Relevant for technologies that see flexibility tax or SE (electricity) taxes.
q32_shDemSeel(t,regi,te)$(teFlex(te) OR teSeTax(te))..
  vm_shDemSeel(t,regi,te)
  * sum(en2en(enty,enty2,te2)$(sameas(enty,"seel")),
        vm_demSe(t,regi,enty,enty2,te2))
  =e=
  sum(en2en(enty,enty2,te)$(sameas(enty,"seel")),
      vm_demSe(t,regi,enty,enty2,te)) 
;

*** Calculates the electricity price of flexible technologies 
*** depending on the share of the flexible technology in total electricity demand
*** At 0% demand share, v32_flexPriceShare = v32_flexPriceShareVRE from above equation.
*** Linear relation between flexibility benefit based on regression 
*** from German Langfristszenarien (see datainput file). 
q32_flexPriceShare(t,regi,te)$(teFlex(te))..
  v32_flexPriceShare(t,regi,te)
  =e=
*** minimum electricity price of flexible technology at this VRE share
    v32_flexPriceShareVRE(t,regi,te)
*** linearly scale with share of flexible technology in total electricity demand
  + p32_flexSeelShare_slope(t,regi,te)
      * vm_shDemSeel(t,regi,te) 
;

*** Note: This equation is not active by default. This means that there is no change in electricity prices for inflexible technologies.
*** The equation is only active if cm_FlexTaxFeedback = 1.
*** This balance ensures that the lower electricity prices of flexible technologies are compensated 
*** by higher electricity prices of inflexible technologies. Inflexible technologies are all technologies
*** which are part of teFlexTax but not of teFlex. The weighted sum of 
*** flexible/inflexible electricity prices (v32_flexPriceShare) and electricity demand must be one. 
q32_flexPriceBalance(t,regi)$(cm_FlexTaxFeedback eq 1)..
  sum(en2en(enty,enty2,te)$(teFlexTax(te)), 
  	vm_demSe(t,regi,enty,enty2,te)) 
  =e=
  sum(en2en(enty,enty2,te)$(teFlexTax(te)), 
  	vm_demSe(t,regi,enty,enty2,te) * v32_flexPriceShare(t,regi,te)) 
;

*** This calculates the flexibility benefit or cost per unit electricity input 
*** of flexibile or inflexible technology.  Flexible technologies benefit
*** (v32_flexPriceShare < 1), while inflexible technologies are penalized
*** (v32_flexPriceShare > 1).  
*** In the tax module, vm_flexAdj is then deduced from the electricity price via
*** the flexibility tax formulation. 
*** Below, pm_SEPrice(t,regi,"seel") is the (average) electricity price from the
*** last iteration, limited between 0 and 230 $/MWh (= 2 T$/TWa) to prevent
*** unreasonable FE prices caused by meaningless marginals in infeasible Nash
*** iterations from propagating through the model.
*** Fixed to 0 if cm_flex_tax != 1, and before 2025.
q32_flexAdj(t,regi,te)$(teFlexTax(te))..
  vm_flexAdj(t,regi,te) 
  =e=
  ( (1 - v32_flexPriceShare(t,regi,te))
  * max(0, min(2, pm_SEPrice(t,regi,"seel")))
  )$( cm_flex_tax eq 1 AND t.val ge 2025 )
;

*' @stop
*** EOF ./modules/32_power/IntC/equations.gms
