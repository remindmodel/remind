*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/33_CDR/weathering/equations.gms

***---------------------------------------------------------------------------
*'  CDR Final Energy Balance
***---------------------------------------------------------------------------
q33_demFeCDR(t,regi,entyFe)$(entyFe2Sector(entyFe,"cdr")) .. 
  vm_otherFEdemand(t,regi,entyFe)
  =e=
  sum((entySe,te)$se2fe(entySe,entyFe,te), vm_demFeSector(t,regi,entySe,entyFe,"cdr","ETS"))
;

***---------------------------------------------------------------------------
*'  Calculation of the energy demand of enhanced weathering. The first part of the equation describes the electricity demand for grinding, 
*'  the second part the diesel demand for transportation and spreading on crop fields.
***---------------------------------------------------------------------------
q33_otherFEdemand(t,regi,entyFe)$(sameas(entyFe,"feels") OR sameas(entyFe,"fedie"))..
	vm_otherFEdemand(t,regi,entyFe)$(sameas(entyFe,"feels") OR sameas(entyFe,"fedie"))
	=e=
	sum(rlf$(rlf.val le 2), s33_rockgrind_fedem$(sameas(entyFe,"feels")) * sm_EJ_2_TWa * sum(rlf2,v33_grindrock_onfield(t,regi,rlf,rlf2)))
   + sum(rlf$(rlf.val le 2), s33_rockfield_fedem$(sameas(entyFe,"fedie")) * sm_EJ_2_TWa * sum(rlf2,v33_grindrock_onfield(t,regi,rlf,rlf2)))
	;

***---------------------------------------------------------------------------
*'  Calculation of the amount of ground rock spread in timestep t.
***---------------------------------------------------------------------------
q33_capconst_grindrock(t,regi)..
	sum(rlf2,sum(rlf$(rlf.val le 2), v33_grindrock_onfield(t,regi,rlf,rlf2)))
	=l=
	sum(teNoTransform2rlf_dyn33(te,rlf2), vm_capFac(t,regi,"rockgrind") * vm_cap(t,regi,"rockgrind",rlf2))
	;
	
***---------------------------------------------------------------------------
*'  Calculation of the total amount of ground rock on the fields in timestep t. The first part of the equation describes the decay of the rocks added until that time,
*'  the rest describes the newly added rocks.
***---------------------------------------------------------------------------
q33_grindrock_onfield_tot(ttot,regi,rlf,rlf2)$((ttot.val ge max(2010, cm_startyear))$(rlf.val le 2))..
	v33_grindrock_onfield_tot(ttot,regi,rlf,rlf2)$(rlf.val le 2)
	=e=
    v33_grindrock_onfield_tot(ttot-1,regi,rlf,rlf2)$(rlf.val le 2) * exp(-p33_co2_rem_rate(rlf)$(rlf.val le 2) * pm_ts(ttot)) + 
	v33_grindrock_onfield(ttot-1,regi,rlf,rlf2)$(rlf.val le 2) * (sum(tall $ ((tall.val lt (ttot.val-pm_ts(ttot)/2)) $ (tall.val gt (ttot.val-pm_ts(ttot)))),exp(-p33_co2_rem_rate(rlf)$(rlf.val le 2) * (ttot.val-tall.val)))) + 
	v33_grindrock_onfield(ttot,regi,rlf,rlf2)$(rlf.val le 2) * (sum(tall $ ((tall.val le ttot.val) $ (tall.val gt (ttot.val-pm_ts(ttot)/2))),exp(-p33_co2_rem_rate(rlf)$(rlf.val le 2) * (ttot.val-tall.val))))
;  

***---------------------------------------------------------------------------
*'  Calculation of (negative) CO2 emissions from enhanced weathering. 
***---------------------------------------------------------------------------
q33_emiEW(t,regi)..
	v33_emiEW(t,regi)
	=e=
	sum(rlf$(rlf.val le 2),
		- sum(rlf2,v33_grindrock_onfield_tot(t,regi,rlf,rlf2)) * s33_co2_rem_pot * (1 - exp(-p33_co2_rem_rate(rlf)))
	)
	;

***---------------------------------------------------------------------------
*'  Sum of all CDR emissions other than BECCS and afforestation, which are calculated in the core.
***---------------------------------------------------------------------------
q33_emicdrregi(t,regi)..
	vm_emiCdr(t,regi,"co2")
	=e=
	v33_emiEW(t,regi)
	;

***---------------------------------------------------------------------------
*'  O&M costs of EW, consisting of fix costs for mining, grinding and spreading, and transportation costs.
***---------------------------------------------------------------------------	
q33_omcosts_onfield(t,regi)..
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
q33_potential(t,regi,rlf)$(rlf.val le 2)..	
	sum(rlf2,v33_grindrock_onfield_tot(t,regi,rlf,rlf2)$(rlf.val le 2))
	=l=
	f33_maxProdGradeRegiWeathering(regi,rlf)$(rlf.val le 2);

***---------------------------------------------------------------------------
*'  An annual limit for the maximum amount of rocks spred [Gt] can be set via cm_LimRock, e.g. due to sustainability concerns.
***---------------------------------------------------------------------------
q33_LimEmiEW(t,regi)..
             sum(rlf,
                  sum(rlf2,v33_grindrock_onfield(t,regi,rlf,rlf2))
                )
        =l=
        cm_LimRock*p33_LimRock(regi);
		
*** EOF ./modules/33_CDR/weathering/equations.gms
