*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/32_power/RLDC/equations.gms

***---------------------------------------------------------------------------
*** Balance equation for electricity secondary energy type:
***---------------------------------------------------------------------------
q32_balSe(t,regi,enty2)$(sameas(enty2,"seel"))..
	v32_scaleCap(t,regi) * p32_capFacDem(regi) 
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
;

q32_usableSeTe(t,regi,entySe,te)$(sameas(entySe,"seel") AND teVRE(te))..
 	vm_usableSeTe(t,regi,entySe,te)
 	=e=
 	sum(pe2se(enty,entySe,te), vm_prodSe(t,regi,enty,entySe,te) )
	+ sum(se2se(enty,entySe,te), vm_prodSe(t,regi,enty,entySe,te) )
 	+ sum(pc2te(enty,entySe(enty3),te,entySe)$(pm_prodCouple(regi,enty,enty3,te,entySe) gt 0),
		pm_prodCouple(regi,enty,enty3,te,entySe) * vm_prodSe(t,regi,enty,enty3,te) )
;



***---------------------------------------------------------------------------
*** VRE Shares - theoretical VRE shares: scale the total VRE production down to "RLDC level", then compare it to the size of the RLDC at 0%
***---------------------------------------------------------------------------
q32_shTheo(t,regi,teVRE)..
    v32_shTh(t,regi,teVRE)
    =e=
    sum(pe2se(entyPe,"seel",teVRE), vm_prodSe(t,regi,entyPe,"seel",teVRE) )
    / (
		v32_scaleCap(t,regi) * p32_capFacDem(regi)
		+ sum(pc2te(enty,entySE(enty3),te,enty2), 
			pm_prodCouple(regi,enty,enty3,te,enty2) * vm_prodSe(t,regi,enty,enty3,te) )
		+ sum(pc2te(enty4,entyFE(enty5),te,enty2), 
			pm_prodCouple(regi,enty4,enty5,te,enty2) * vm_prodFe(t,regi,enty4,enty5,te) )
		+ sum(pc2te(enty,enty3,te,enty2),
			sum(teCCS2rlf(te,rlf),
				pm_prodCouple(regi,enty,enty3,te,enty2) * vm_co2CCS(t,regi,enty,enty3,te,rlf) ) )
	)
;

***---------------------------------------------------------------------------
*** Transform the RLDC normalized capacities (0-1) to real world magnitudes
***---------------------------------------------------------------------------
q32_scaleCapTe(t,regi,te)$( (t.val > 2000) AND teRLDCDisp(te) )..  !! scale the capacities of all technologies explicitly represented in the RLDCs
	sum(tese2rlf(te,rlf), vm_cap(t,regi,te,rlf) )
	=e=
	v32_scaleCap(t,regi) * ( sum(LoB, v32_capLoB(t,regi,te,LoB) ) + v32_capER(t,regi,te) )
;

***---------------------------------------------------------------------------
*** Curtailment
***---------------------------------------------------------------------------
q32_curt(t,regi)..
	v32_curt(t,regi)
	=e=
	sum(pe2se(entyPe,"seel",teVRE), vm_prodSe(t,regi,entyPe,"seel",teVRE) )   !! total theoretical VRE production
	- v32_scaleCap(t,regi) * ( p32_capFacDem(regi) - sum(LoB, p32_capFacLoB(LoB) * v32_LoBheight(t,regi,LoB) ) ) !! minus the actually used VRE production, namely the difference between a system without and a system with VRE
	+ v32_overProdCF(t,regi,"csp") * vm_cap(t,regi,"csp","1")  !! add the unused CSP production that is not reflected in seprod
;

q32_curtFit(t,regi)..  !! calculate curtailment as fitted from the DIMES-Results 
	v32_curtFit(t,regi)   !! v32_curtFit can go below 0
	=e=
	p32_curtOn(regi) 
	* (
		  p32_RLDCcoeff(regi,"p00","curtShVRE")
		+ p32_RLDCcoeff(regi,"p10","curtShVRE") * v32_shTh(t,regi,"wind")$teVRE("wind")
		+ p32_RLDCcoeff(regi,"p01","curtShVRE")                                              * ( v32_shTh(t,regi,"spv")$teVRE("spv") + v32_shTh(t,regi,"csp")$teVRE("csp") )
		+ p32_RLDCcoeff(regi,"p20","curtShVRE") * v32_shTh(t,regi,"wind")$teVRE("wind") ** 2
		+ p32_RLDCcoeff(regi,"p11","curtShVRE") * v32_shTh(t,regi,"wind")$teVRE("wind")      * ( v32_shTh(t,regi,"spv")$teVRE("spv") + v32_shTh(t,regi,"csp")$teVRE("csp") )
		+ p32_RLDCcoeff(regi,"p02","curtShVRE")                                              * ( v32_shTh(t,regi,"spv")$teVRE("spv") + v32_shTh(t,regi,"csp")$teVRE("csp") ) ** 2
		+ p32_RLDCcoeff(regi,"p30","curtShVRE") * v32_shTh(t,regi,"wind")$teVRE("wind") ** 3
		+ p32_RLDCcoeff(regi,"p21","curtShVRE") * v32_shTh(t,regi,"wind")$teVRE("wind") ** 2 * ( v32_shTh(t,regi,"spv")$teVRE("spv") + v32_shTh(t,regi,"csp")$teVRE("csp") )
		+ p32_RLDCcoeff(regi,"p12","curtShVRE") * v32_shTh(t,regi,"wind")$teVRE("wind")      * ( v32_shTh(t,regi,"spv")$teVRE("spv") + v32_shTh(t,regi,"csp")$teVRE("csp") ) ** 2
		+ p32_RLDCcoeff(regi,"p03","curtShVRE")                                              * ( v32_shTh(t,regi,"spv")$teVRE("spv") + v32_shTh(t,regi,"csp")$teVRE("csp") ) ** 3
   )
;

q32_curtFitwCSP(t,regi)..
	v32_curt(t,regi)   
	=e=  
	( v32_curtFit(t,regi) + 0.02 ) * sum(pe2se(entyPe,"seel",teVRE), vm_prodSe(t,regi,entyPe,"seel",teVRE) )  !! add 2% of VRE prod. ot curtailment to represent grid losses - comes from the comparison with REMIX
	+ v32_overProdCF(t,regi,"csp") * vm_cap(t,regi,"csp","1")
	+ v32_CurtModelminusFit(t,regi)  * sum(pe2se(entyPe,"seel",teVRE), vm_prodSe(t,regi,entyPe,"seel",teVRE) )       !! this is a positive slack variable that shows how much curtailment due to discretization of RLDC boxes is larger than fitted curtailment -> to move to ex-post
$if %cm_Full_Integration% == "on" + v32_FullIntegrationSlack(t,regi)
;

***---------------------------------------------------------------------------
*** Load Band
***---------------------------------------------------------------------------
q32_LoBheightCumExact(t,regi,LoB)..   
	v32_LoBheightCumExact(t,regi,LoB)
	=e=
      p32_RLDCcoeff(regi,"p00",LoB)
	+ p32_RLDCcoeff(regi,"p10",LoB) * v32_shTh(t,regi,"wind")$teVRE("wind")
	+ p32_RLDCcoeff(regi,"p01",LoB)                                              * ( v32_shTh(t,regi,"spv")$teVRE("spv") + v32_shTh(t,regi,"csp")$teVRE("csp") )
	+ p32_RLDCcoeff(regi,"p20",LoB) * v32_shTh(t,regi,"wind")$teVRE("wind") ** 2                             
	+ p32_RLDCcoeff(regi,"p11",LoB) * v32_shTh(t,regi,"wind")$teVRE("wind")      * ( v32_shTh(t,regi,"spv")$teVRE("spv") + v32_shTh(t,regi,"csp")$teVRE("csp") )
	+ p32_RLDCcoeff(regi,"p02",LoB)                                              * ( v32_shTh(t,regi,"spv")$teVRE("spv") + v32_shTh(t,regi,"csp")$teVRE("csp") ) ** 2
	+ p32_RLDCcoeff(regi,"p30",LoB) * v32_shTh(t,regi,"wind")$teVRE("wind") ** 3                             
	+ p32_RLDCcoeff(regi,"p21",LoB) * v32_shTh(t,regi,"wind")$teVRE("wind") ** 2 * ( v32_shTh(t,regi,"spv")$teVRE("spv") + v32_shTh(t,regi,"csp")$teVRE("csp") )
	+ p32_RLDCcoeff(regi,"p12",LoB) * v32_shTh(t,regi,"wind")$teVRE("wind")      * ( v32_shTh(t,regi,"spv")$teVRE("spv") + v32_shTh(t,regi,"csp")$teVRE("csp") ) ** 2
	+ p32_RLDCcoeff(regi,"p03",LoB)                                              * ( v32_shTh(t,regi,"spv")$teVRE("spv") + v32_shTh(t,regi,"csp")$teVRE("csp") ) ** 3
;

q32_LoBheightCumExactNEW(t,regi,LoB)..    !! introduce slack so that v32_LoBheightCum stay > 0
	v32_LoBheightCum(t,regi,LoB)
	=g=
	v32_LoBheightCumExact(t,regi,LoB)
;

q32_LoBheightExact(t,regi,LoB)..     !! individual load band height - the difference between the cumulated heights
	v32_LoBheight(t,regi,LoB)
    =g=
    ( v32_LoBheightCum(t,regi,LoB) - v32_LoBheightCum(t,regi,LoB+1)$(LoB.val < card(LoB)) )
    * ( 1$(LoB.val < card(LoB)) + ( 1 / p32_capFacLoB(LoB) )$(LoB.val = card(LoB)) )  !! upscale the height of the base-load band to represent the fact that the fit was done with 8760 hours, while no plant runs longer than 7500 hours (CF = 0.86)
;

q32_fillLoB(t,regi,LoB)$(t.val > 2005)..
    sum(teRLDCDisp, v32_capLoB(t,regi,teRLDCDisp,LoB) )    
    =e=
    v32_LoBheight(t,regi,LoB)
;

***---------------------------------------------------------------------------
*** Capacity factor for dispatchable power plants
***---------------------------------------------------------------------------
q32_capFac(t,regi,te)$( teRLDCDisp(te) AND (t.val > 2000) )..
    vm_capFac(t,regi,te)
    =e=
    ( 	sum(LoB, 
			( 	p32_capFacLoB(LoB)$( (LoB.val <> 4) OR NOT sameas(te,"csp") ) 
				+ (4/3 * p32_avCapFac(t,regi,"csp"))$( (LoB.val eq 4) AND sameas(te,"csp") )  !! 4/3 is a factor for the upscaling from SM3/12h to SM4/16h storage
			)
			* v32_capLoB(t,regi,te,LoB)  
		) 
		+ v32_capER(t,regi,te) * 0.01  !! the early retired capacities (v32_capER) are weighted with 1% to represent that they run at least 100h per year
	) 
	/ (sum(LoB, v32_capLoB(t,regi,te,LoB) ) + v32_capER(t,regi,te) + 1e-9)
;

q32_capFacTER(t,regi,te)$( teReNoBio(te) AND teRLDCDisp(te) AND t.val > 2000)..  !! make sure that for dispatchable renewable plants, the average nur is larger than the resulting capFac
    sum(teRe2rlfDetail(te,rlf), 
		pm_dataren(regi,"nur",rlf,te) * vm_capDistr(t,regi,te,rlf) ) 
    / ( vm_cap(t,regi,te,"1") + 1e-10 ) + 3e-5        !! the 1e-5 allows for slightly larger capacity factors, but does not have a large influence, and prevents some infeasibilities
    =g=
    vm_capFac(t,regi,te)
    + v32_overProdCF(t,regi,te)
;

***---------------------------------------------------------------------------
*** Short Term Storage Requirements (from RLDC Fit)
***---------------------------------------------------------------------------
q32_stor_pv(t,regi)$(t.val > 2010)..
	vm_cap(t,regi,"storspv","1")
	=g=
	v32_scaleCap(t,regi) * 
	( 
		  p32_RLDCcoeff(regi,"p00","STScost")
		+ p32_RLDCcoeff(regi,"p10","STScost") * v32_shTh(t,regi,"wind")$teVRE("wind")
		+ p32_RLDCcoeff(regi,"p01","STScost")                                              * ( v32_shTh(t,regi,"spv")$teVRE("spv") + v32_shTh(t,regi,"csp")$teVRE("csp") )
		+ p32_RLDCcoeff(regi,"p20","STScost") * v32_shTh(t,regi,"wind")$teVRE("wind") ** 2
		+ p32_RLDCcoeff(regi,"p11","STScost") * v32_shTh(t,regi,"wind")$teVRE("wind")      * ( v32_shTh(t,regi,"spv")$teVRE("spv") + v32_shTh(t,regi,"csp")$teVRE("csp") )
		+ p32_RLDCcoeff(regi,"p02","STScost")                                              * ( v32_shTh(t,regi,"spv")$teVRE("spv") + v32_shTh(t,regi,"csp")$teVRE("csp") ) ** 2
		+ p32_RLDCcoeff(regi,"p30","STScost") * v32_shTh(t,regi,"wind")$teVRE("wind") ** 3
		+ p32_RLDCcoeff(regi,"p21","STScost") * v32_shTh(t,regi,"wind")$teVRE("wind") ** 2 * ( v32_shTh(t,regi,"spv")$teVRE("spv") + v32_shTh(t,regi,"csp")$teVRE("csp") )
		+ p32_RLDCcoeff(regi,"p12","STScost") * v32_shTh(t,regi,"wind")$teVRE("wind")      * ( v32_shTh(t,regi,"spv")$teVRE("spv") + v32_shTh(t,regi,"csp")$teVRE("csp") ) ** 2
		+ p32_RLDCcoeff(regi,"p03","STScost")                                              * ( v32_shTh(t,regi,"spv")$teVRE("spv") + v32_shTh(t,regi,"csp")$teVRE("csp") ) ** 3
	) 
;

***---------------------------------------------------------------------------
*** Peak capacity equations
***---------------------------------------------------------------------------

q32_peakCap(t,regi)..
	v32_peakCap(t,regi)
	=e=
	  p32_RLDCcoeff(regi,"p00","peak")
	+ p32_RLDCcoeff(regi,"p10","peak") * v32_shTh(t,regi,"wind")$teVRE("wind")
	+ p32_RLDCcoeff(regi,"p01","peak")                                              * ( v32_shTh(t,regi,"spv")$teVRE("spv") + v32_shTh(t,regi,"csp")$teVRE("csp") )
	+ p32_RLDCcoeff(regi,"p20","peak") * v32_shTh(t,regi,"wind")$teVRE("wind") ** 2
	+ p32_RLDCcoeff(regi,"p11","peak") * v32_shTh(t,regi,"wind")$teVRE("wind")      * ( v32_shTh(t,regi,"spv")$teVRE("spv") + v32_shTh(t,regi,"csp")$teVRE("csp") )
	+ p32_RLDCcoeff(regi,"p02","peak")                                              * ( v32_shTh(t,regi,"spv")$teVRE("spv") + v32_shTh(t,regi,"csp")$teVRE("csp") ) ** 2
	+ p32_RLDCcoeff(regi,"p30","peak") * v32_shTh(t,regi,"wind")$teVRE("wind") ** 3
	+ p32_RLDCcoeff(regi,"p21","peak") * v32_shTh(t,regi,"wind")$teVRE("wind") ** 2 * ( v32_shTh(t,regi,"spv")$teVRE("spv") + v32_shTh(t,regi,"csp")$teVRE("csp") )
	+ p32_RLDCcoeff(regi,"p12","peak") * v32_shTh(t,regi,"wind")$teVRE("wind")      * ( v32_shTh(t,regi,"spv")$teVRE("spv") + v32_shTh(t,regi,"csp")$teVRE("csp") ) ** 2
	+ p32_RLDCcoeff(regi,"p03","peak")                                              * ( v32_shTh(t,regi,"spv")$teVRE("spv") + v32_shTh(t,regi,"csp")$teVRE("csp") ) ** 3
;

q32_capAdeq(t,regi)$(t.val > 2005)..    
	sum(teRLDCDisp(te)$(NOT sameas(te,"hydro")),
		sum(tese2rlf(te,rlf), vm_cap(t,regi,te,rlf) )
	)
	+ 0.8 * vm_cap(t,regi,"hydro","1")  !! to represent that it is not fully dispatchable, hydro counts only with 80% of its installed capacity towards peak capacity
	=g=
	v32_scaleCap(t,regi) * ( v32_peakCap(t,regi) + p32_ResMarg(t,regi) )
;

***---------------------------------------------------------------------------
*** CSP - including co-firing
***---------------------------------------------------------------------------
q32_H2cofiring(t,regi)$(t.val > 2010)..
	vm_demSeOth(t,regi,"seh2","csp")                 !! cofiring of h2 to csp 
	+ vm_demSeOth(t,regi,"segabio","csp")               !! cofiring of gas to csp 
	+ vm_demSeOth(t,regi,"segafos","csp")
$if %cm_Full_Integration% == "on"  + 1e6
	=g= 
	v32_H2cof_PVsh(t,regi)
	+ v32_H2cof_Lob4(t,regi)
	+ v32_H2cof_Lob3(t,regi)
	+ v32_H2cof_CSPsh(t,regi)
;

q32_H2cof_LoB3(t,regi)$(t.val > 2005)..
	v32_H2cof_Lob3(t,regi)
	=g=
	1/0.4          !! 1/0.4 is the efficiency of the H2 turbine - to convert from produced electricity to used H2
	* v32_scaleCap(t,regi)                                    !! all the later numbers are relative to peak, and need to be rescaled to full system size
	*  v32_capLoB(t,regi,"csp","3")                          !!  each unit of csp in baseload needs H2 cofiring
	* ( p32_capFacLoB("3") - p32_avCapFac(t,regi,"csp") )     !! the co-firing is only needed for the residual of baseload after avCapFac. CapLob * DiffCapfac = produced electricity
;

q32_H2cof_LoB4(t,regi)$(t.val > 2005)..
	v32_H2cof_Lob4(t,regi)
	=g=
	1/0.4          !! 1/0.4 is the efficiency of the H2 turbine - to convert from produced electricity to used H2
	* v32_scaleCap(t,regi)
	* v32_capLoB(t,regi,"csp","4")                          !!  each unit of csp in baseload needs H2 cofiring
	* ( p32_capFacLoB("4") - 4/3 * p32_avCapFac(t,regi,"csp") )  !! 4/3 is the factor for the upscaling from SM3/12h to SM4/16h storage
;

q32_H2cof_PVsh(t,regi)$(t.val > 2005)..     !! more CSP cofiring if lots of PV is used (correlation between PV and CSP) 
	v32_H2cof_PVsh(t,regi)
	=e=
	1/0.4          !! 1/0.4 is the efficiency of the H2 turbine - to convert from produced electricity to used H2
	* v32_scaleCap(t,regi)
	* 0.5 * vm_cap(t,regi,"csp","1") * (0.65 - p32_avCapFac(t,regi,"csp") ) * v32_shTh(t,regi,"spv")
; 

q32_H2cof_CSPsh(t,regi)$(t.val > 2005)..    !! more CSP cofiring if lots of CSP is used (self-correlation of CSP) 
	v32_H2cof_CSPsh(t,regi)
	=e=
	1/0.4          !! 1/0.4 is the efficiency of the H2 turbine - to convert from produced electricity to used H2
	* v32_scaleCap(t,regi)
	* vm_cap(t,regi,"csp","1") * (0.65 - p32_avCapFac(t,regi,"csp") ) * v32_shTh(t,regi,"csp")
; 

***---------------------------------------------------------------------------
*** produce H2 from curtailed electricity, using a curtailment-dependent load factor
***---------------------------------------------------------------------------
q32_curtCapH2(t,regi)$(t.val > 2005)..
	vm_cap(t,regi,"h2curt","1") / v32_scaleCap(t,regi)   !! 0.5 for area of a triangle
	=l=
	v32_sqrtCurt(t,regi)                                 !! 0.5 as only half of the curtailment can be used
;

q32_curtProdH2(t,regi)$(t.val > 2005)..
	pm_eta_conv(t,regi,"h2curt") * vm_cap(t,regi,"h2curt","1") * 2/3 * v32_sqrtCurt(t,regi)
	=g=
	vm_prodSeOth(t,regi,"seh2","h2curt")
;

q32_sqrtCurt(t,regi)$(t.val > 2005)..
	v32_sqrtCurt(t,regi)
	=e=
	sqrt( 2/3 * ( ( v32_curt(t,regi) ) / v32_scaleCap(t,regi)  / p32_capFacDem(regi)  + 1e-6 ) )
;
!! Assuming curtailment has a triangle shape, 1x wide, 3x high => 3x^2 would be the area of the rectangle. The area of the triangle = 1/2 times this.
!! Area = 3/2 x^2 = curt.   ==> x = 2/3 curt ^ 0.5

***---------------------------------------------------------------------------
*** special constraints on hydropower to prevent hydro being completely flexibily only used for peaking
***---------------------------------------------------------------------------
q32_hydroROR(t,regi)$(t.val > 2005)..  !! require that at least 20% of the hydro are in baseload (counting as run-of-river). This may lead to Baseload being higher than required by the RLDC, and therefore (realistic) curtailment
	p32_capFacLoB("4") * v32_capLoB(t,regi,"hydro","4")
	=g=
	0.2 * sum(LoB, p32_capFacLoB(LoB) * v32_capLoB(t,regi,"hydro",LoB) ) 
;

***---------------------------------------------------------------------------
*** Definition of capacity constraints for CHP technologies:
***---------------------------------------------------------------------------
q32_limitCapTeChp(t,regi)..
	sum(pe2se(enty,"seel",teChp(te)), vm_prodSe(t,regi,enty,"seel",te) )
	=l=
	p32_shCHP(t,regi) 
	* sum(pe2se(enty,"seel",te), vm_prodSe(t,regi,enty,"seel",te) );

***---------------------------------------------------------------------------
*** Calculation of necessary grid installations for centralized renewables:
***---------------------------------------------------------------------------
q32_limitCapTeGrid(t,regi)$( t.val ge 2015 ) ..
   vm_cap(t,regi,"gridwind",'1')      !! Technology is now parameterized to yield marginal costs of ~3.5$/MWh VRE electricity
    / p32_grid_factor(regi)                     !! It is assumed that large regions require higher grid investment
    =g=
    vm_prodSe(t,regi,"pesol","seel","spv")
    + vm_prodSe(t,regi,"pesol","seel","csp")
    + 1.5 * vm_prodSe(t,regi,"pewin","seel","wind")                 !! wind has larger variations accross space, so adding grid is more important for wind (result of REMIX runs for ADVANCE project)
$IFTHEN.WindOff %cm_wind_offshore% == "1"
    + 1.5 * vm_prodSe(t,regi,"pewin","seel","windoff")
$ENDIF.WindOff
;

***---------------------------------------------------------------------------
*** EMF27 limits on fluctuating renewables, only turned on for special EMF27 and AWP 2 scenarios, not for SSP
***---------------------------------------------------------------------------
q32_limitSolarWind(t,regi)$( (cm_solwindenergyscen = 2) OR (cm_solwindenergyscen = 3) )..
	vm_usableSeTe(t,regi,"seel","spv") + vm_usableSeTe(t,regi,"seel","wind") + vm_usableSeTe(t,regi,"seel","csp") 
	=l=
	0.2 * vm_usableSe(t,regi,"seel")
;

***---------------------------------------------------------------------------
*** Calculation of share of electricity production of a technology:
***---------------------------------------------------------------------------
q32_shSeEl(t,regi,teVRE)..
    vm_shSeEl(t,regi,teVRE) / 100 * vm_usableSe(t,regi,"seel")
    =e=
    vm_usableSeTe(t,regi,"seel",teVRE)
;

*** EOF ./modules/32_power/RLDC/equations.gms
