*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/33_CDR/weathering/equations.gms

q33_otherFEdemand(t,regi,entyFe)$(sameas(entyFe,"feels") OR sameas(entyFe,"fedie"))..
	vm_otherFEdemand(t,regi,entyFe)$(sameas(entyFe,"feels") OR sameas(entyFe,"fedie"))
	=e=
	sum(rlf$(rlf.val le 2), s33_rockgrind_fedem$(sameas(entyFe,"feels")) * sm_EJ_2_TWa * sum(rlf2,v33_grindrock_onfield(t,regi,rlf,rlf2)))
   + sum(rlf$(rlf.val le 2), s33_rockfield_fedem$(sameas(entyFe,"fedie")) * sm_EJ_2_TWa * sum(rlf2,v33_grindrock_onfield(t,regi,rlf,rlf2)))
	;

q33_capconst_grindrock(t,regi)..
	sum(rlf2,sum(rlf$(rlf.val le 2), v33_grindrock_onfield(t,regi,rlf,rlf2)))
	=l=
	sum(teNoTransform2rlf_dyn33(te,rlf2), vm_capFac(t,regi,"rockgrind") * vm_cap(t,regi,"rockgrind",rlf2))
	;
	
* JeS: timestep in 2060 not yet quite right!  
q33_grindrock_onfield_tot(ttot,regi,rlf,rlf2)$((ttot.val ge max(2010, cm_startyear))$(rlf.val le 2))..
	v33_grindrock_onfield_tot(ttot,regi,rlf,rlf2)$(rlf.val le 2)
	=e=
    v33_grindrock_onfield_tot(ttot-1,regi,rlf,rlf2)$(rlf.val le 2) * exp(-p33_co2_rem_rate(rlf)$(rlf.val le 2) * pm_ts(ttot)) + 
	v33_grindrock_onfield(ttot-1,regi,rlf,rlf2)$(rlf.val le 2) * (sum(tall $ ((tall.val lt (ttot.val-pm_ts(ttot)/2)) $ (tall.val gt (ttot.val-pm_ts(ttot)))),exp(-p33_co2_rem_rate(rlf)$(rlf.val le 2) * (ttot.val-tall.val)))) + 
	v33_grindrock_onfield(ttot,regi,rlf,rlf2)$(rlf.val le 2) * (sum(tall $ ((tall.val le ttot.val) $ (tall.val gt (ttot.val-pm_ts(ttot)/2))),exp(-p33_co2_rem_rate(rlf)$(rlf.val le 2) * (ttot.val-tall.val))))
;  

q33_emiEW(t,regi)..
	v33_emiEW(t,regi)
	=e=
	sum(rlf$(rlf.val le 2),
		- sum(rlf2,v33_grindrock_onfield_tot(t,regi,rlf,rlf2)) * s33_co2_rem_pot * (1 - exp(-p33_co2_rem_rate(rlf)))
	)
	;

q33_emicdrregi(t,regi)..
	vm_emiCdr(t,regi,"co2")
	=e=
	v33_emiEW(t,regi)
	;
	
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
	
q33_potential(t,regi,rlf)$(rlf.val le 2)..	
	sum(rlf2,v33_grindrock_onfield_tot(t,regi,rlf,rlf2)$(rlf.val le 2))
	=l=
	f33_maxProdGradeRegiWeathering(regi,rlf)$(rlf.val le 2);

q33_LimEmiEW(t,regi)..
             sum(rlf,
                  sum(rlf2,v33_grindrock_onfield(t,regi,rlf,rlf2))
                )
        =l=
        cm_LimRock*p33_LimRock(regi);
		
*** EOF ./modules/33_CDR/weathering/equations.gms
