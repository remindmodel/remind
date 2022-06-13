*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/33_CDR/weathering/equations.gms

***---------------------------------------------------------------------------
*'  CDR Final Energy Balance.
***---------------------------------------------------------------------------
q33_cdr_FEdemand(t,regi,entyFe)$entyFe2Sector(entyFe, "cdr")..
	sum(se2fe(entySe,entyFe,te), vm_demFeSector(t, regi, entySe, entyFe, "cdr", "ETS"))
	=e=
	sum(fe2fe_cdr(entyFe, entyFe2, te_dyn33), v33_FEdemand(t, regi, entyFe, entyFe2, te_dyn33))
	;

***---------------------------------------------------------------------------
*'  Calculation of electricity demand for grinding and diesel demand for transportation and spreading rock on the fields.
***---------------------------------------------------------------------------
q33_ew_FEdemand(t, regi, entyFe2)$sum(entyFe, fe2fe_cdr(entyFe, entyFe2, "weathering"))..
	sum(entyFe, v33_FEdemand(t, regi, entyFe, entyFe2, "weathering"))
	=e=
	p33_ew_fedem(entyFe2) * sm_EJ_2_TWa * sum((rlf_cz33, rlf), v33_ew_onfield(t,regi,rlf_cz33,rlf))
	;

***---------------------------------------------------------------------------
*'  Calculation of the amount of ground rock spread in timestep t.
***---------------------------------------------------------------------------
q33_ew_capconst(t,regi)..
	sum((rlf, rlf_cz33), v33_ew_onfield(t,regi,rlf_cz33,rlf))
	=l=
	sum(teNoTransform2rlf_dyn33("weathering",rlf), vm_capFac(t,regi,"weathering") * vm_cap(t,regi,"weathering",rlf))
	;

***---------------------------------------------------------------------------
*'  Calculation of the total amount of ground rock on the fields in timestep t. The first part of the equation describes the decay of the rocks added until that time,
*'  the rest describes the newly added rocks.
***---------------------------------------------------------------------------
q33_ew_onfield_tot(ttot,regi,rlf_cz33,rlf)$(ttot.val ge max(2025, cm_startyear))..
	v33_ew_onfield_tot(ttot,regi,rlf_cz33,rlf)
	=e=
    v33_ew_onfield_tot(ttot-1,regi,rlf_cz33,rlf) * exp(-p33_co2_rem_rate(rlf_cz33) * pm_ts(ttot)) +
	v33_ew_onfield(ttot-1,regi,rlf_cz33,rlf) * (sum(tall $ ((tall.val le (ttot.val-pm_ts(ttot)/2)) $ (tall.val gt (ttot.val-pm_ts(ttot)))),exp(-p33_co2_rem_rate(rlf_cz33) * (ttot.val-tall.val)))) +
	v33_ew_onfield(ttot,regi,rlf_cz33,rlf) * (sum(tall $ ((tall.val le ttot.val) $ (tall.val gt (ttot.val-pm_ts(ttot)/2))),exp(-p33_co2_rem_rate(rlf_cz33) * (ttot.val-tall.val))))
;  

***---------------------------------------------------------------------------
*'  Calculation of (negative) CO2 emissions from enhanced weathering. 
***---------------------------------------------------------------------------
q33_ew_emi(t,regi)..
	v33_emi(t,regi,"weathering")
	=e=
	sum(rlf_cz33,
		- sum(rlf,v33_ew_onfield_tot(t,regi,rlf_cz33,rlf)) * s33_co2_rem_pot * (1 - exp(-p33_co2_rem_rate(rlf_cz33)))
	)
	;

***---------------------------------------------------------------------------
*'  Sum of all CDR emissions other than BECCS and afforestation, which are calculated in the core.
***---------------------------------------------------------------------------
q33_emicdrregi(t,regi)..
	vm_emiCdr(t,regi,"co2")
	=e=
	v33_emi(t,regi,"weathering")
	;

***---------------------------------------------------------------------------
*'  O&M costs of EW, consisting of fix costs for mining, grinding and spreading, and transportation costs.
***---------------------------------------------------------------------------	
q33_ew_omcosts(t,regi)..
	vm_omcosts_cdr(t,regi)
	=e=
	sum((rlf_cz33, rlf),
		(s33_costs_fix + p33_transport_costs(regi,rlf_cz33,rlf)) * v33_ew_onfield(t,regi,rlf_cz33,rlf)
	)
	;

***---------------------------------------------------------------------------
*'  Limit total amount of ground rock on the fields to regional maximum potentials.
***---------------------------------------------------------------------------	
q33_ew_potential(t,regi,rlf_cz33)..
	sum(rlf,v33_ew_onfield_tot(t,regi,rlf_cz33,rlf))
	=l=
	f33_maxProdGradeRegiWeathering(regi,rlf_cz33);

***---------------------------------------------------------------------------
*'  An annual limit for the maximum amount of rocks spred [Gt] can be set via cm_LimRock, e.g. due to sustainability concerns.
***---------------------------------------------------------------------------
q33_ew_LimEmi(t,regi)..
	sum((rlf_cz33, rlf), v33_ew_onfield(t,regi,rlf_cz33,rlf))
	=l=
	cm_LimRock*p33_LimRock(regi);
		
*** EOF ./modules/33_CDR/weathering/equations.gms
