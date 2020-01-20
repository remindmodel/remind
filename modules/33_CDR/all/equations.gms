*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/33_CDR/all/equations.gms

***---------------------------------------------------------------------------
*'  Calculation of the amount of ground rock spread in timestep t.
***---------------------------------------------------------------------------
q33_capconst_grindrock(t,regi)..
	sum(rlf2,sum(rlf, v33_grindrock_onfield(t,regi,rlf,rlf2)))
	=l=
	sum(teNoTransform2rlf_dyn33(te,rlf2), vm_capFac(t,regi,"rockgrind") * vm_cap(t,regi,"rockgrind",rlf2))
	;
	
***---------------------------------------------------------------------------
*'  Calculation of the total amount of ground rock on the fields in timestep t. The first part of the equation describes the decay of the rocks added until that time,
*'  the rest describes the newly added rocks.
***---------------------------------------------------------------------------
q33_grindrock_onfield_tot(ttot,regi,rlf,rlf2)$(ttot.val ge max(2010, cm_startyear))..
	v33_grindrock_onfield_tot(ttot,regi,rlf,rlf2)
	=e=
    v33_grindrock_onfield_tot(ttot-1,regi,rlf,rlf2) * exp(-p33_co2_rem_rate(rlf) * pm_ts(ttot)) + 
	v33_grindrock_onfield(ttot-1,regi,rlf,rlf2) * (sum(tall $ ((tall.val lt (ttot.val-pm_ts(ttot)/2)) $ (tall.val gt (ttot.val-pm_ts(ttot)))),exp(-p33_co2_rem_rate(rlf) * (ttot.val-tall.val)))) + 
	v33_grindrock_onfield(ttot,regi,rlf,rlf2) * (sum(tall $ ((tall.val le ttot.val) $ (tall.val gt (ttot.val-pm_ts(ttot)/2))),exp(-p33_co2_rem_rate(rlf) * (ttot.val-tall.val))))
;  

***---------------------------------------------------------------------------
*'  Calculation of (negative) CO2 emissions from enhanced weathering. 
***---------------------------------------------------------------------------
q33_emiEW(t,regi)..
	v33_emiEW(t,regi)
	=e=
	sum(rlf,
		- sum(rlf2,v33_grindrock_onfield_tot(t,regi,rlf,rlf2)) * s33_co2_rem_pot * (1 - exp(-p33_co2_rem_rate(rlf)))
		)
	;	

***---------------------------------------------------------------------------
*'  Calculation of (negative) CO2 emissions from direct air capture. The first part of the equation describes emissions captured from the ambient air, 
*'  the second part calculates the CO2 captured from the gas used for heat production assuming 90% capture rate.
***---------------------------------------------------------------------------
q33_capconst_dac(t,regi)..
	v33_emiDAC(t,regi)
	=e=
	-sum(teNoTransform2rlf_dyn33(te,rlf2), vm_capFac(t,regi,"dac") * vm_cap(t,regi,"dac",rlf2))
	-  (1 / pm_eta_conv(t,regi,"gash2c")) * fm_dataemiglob("pegas","seh2","gash2c","cco2") * vm_otherFEdemand(t,regi,"fegas")	
	;

***---------------------------------------------------------------------------
*'  Sum of all CDR emissions other than BECCS and afforestation, which are calculated in the core.
***---------------------------------------------------------------------------	
q33_emicdrregi(t,regi)..
	vm_emiCdr(t,regi,"co2")
	=e=
	v33_emiEW(t,regi) + v33_emiDAC(t,regi)
	;

***---------------------------------------------------------------------------
*'  Calculation of energy demand of DAC and EW. 
*'  The first part of the equation describes the electricity demand for grinding, 
*'  the second part the diesel demand for transportation and spreading on crop fields.
*'  The third part is DAC electricity demand and the last part is DAC heat demand.
*'  Heat for DAC can be provided by gas or H2; vm_otherFEdemand(t,regi,"fegas") is calculated as the total 
*'  DAC energy demand for heat minus what is already covered by h2, i.e. vm_otherFEdemand(t,regi,"feh2s") and vice versa.
***---------------------------------------------------------------------------	
q33_otherFEdemand(t,regi,entyFe)..
	vm_otherFEdemand(t,regi,entyFe)
	=e=
	sum(rlf, s33_rockgrind_fedem$(sameas(entyFe,"feels")) * sm_EJ_2_TWa * sum(rlf2,v33_grindrock_onfield(t,regi,rlf,rlf2)))
   + sum(rlf, s33_rockfield_fedem$(sameas(entyFe,"fedie")) * sm_EJ_2_TWa * sum(rlf2,v33_grindrock_onfield(t,regi,rlf,rlf2)))
   - v33_emiDAC(t,regi) * sm_EJ_2_TWa * p33_dac_fedem(entyFe)
   - vm_otherFEdemand(t,regi,"feh2s")$(sameas(entyFe,"fegas")) - vm_otherFEdemand(t,regi,"fegas")$(sameas(entyFe,"feh2s"))
	;	
	
***---------------------------------------------------------------------------
*'  Limit the amount of H2 from biomass to the demand without DAC.
***---------------------------------------------------------------------------	
q33_H2bio_lim(t,regi,te)..	         
	vm_prodSE(t,regi,"pebiolc","seh2",te)$pe2se("pebiolc","seh2",te)
	=l=
    vm_prodFe(t,regi,"seh2","feh2s","tdh2s") - vm_otherFEdemand(t,regi,"feh2s")
	;

***---------------------------------------------------------------------------
*'  O&M costs of EW, consisting of fix costs for mining, grinding and spreading, and transportation costs.
***---------------------------------------------------------------------------	
q33_omcosts(t,regi)..
	vm_omcosts_cdr(t,regi)
	=e=
	sum(rlf$(rlf.val le 2), 
	    sum(rlf2,
	       (s33_costs_fix + p33_transport_costs(regi,rlf,rlf2))  
	       * v33_grindrock_onfield(t,regi,rlf,rlf2)
		)
	)
	;

***---------------------------------------------------------------------------
*'  Limit total amount of ground rock on the fields to regional maximum potentials.
***---------------------------------------------------------------------------		
q33_potential(t,regi,rlf)..	
	sum(rlf2,v33_grindrock_onfield_tot(t,regi,rlf,rlf2))
	=l=
	f33_maxProdGradeRegiWeathering(regi,rlf);	

***---------------------------------------------------------------------------
*'  Preparation of captured emissions to enter the CCS chain.
***---------------------------------------------------------------------------		
q33_ccsbal(t,regi,ccs2te(ccsCo2(enty),enty2,te))..
	sum(teCCS2rlf(te,rlf), vm_ccs_cdr(t,regi,enty,enty2,te,rlf))
	=e=
	-v33_emiDAC(t,regi)
	;	

***---------------------------------------------------------------------------
*'  An annual limit for the maximum amount of rocks spred [Gt] can be set via cm_LimRock, e.g. due to sustainability concerns.
***---------------------------------------------------------------------------  
q33_LimEmiEW(t,regi)..
             sum(rlf,
                  sum(rlf2,v33_grindrock_onfield(t,regi,rlf,rlf2))
                )
        =l=
        cm_LimRock*p33_LimRock(regi);
		
*** EOF ./modules/33_CDR/all/equations.gms
