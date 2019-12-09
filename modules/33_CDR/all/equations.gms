*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/33_CDR/all/equations.gms

q33_capconst_grindrock(t,regi)..
	sum(rlf2,sum(rlf, v33_grindrock_onfield(t,regi,rlf,rlf2)))
	=l=
	sum(teNoTransform2rlf_dyn33(te,rlf2), vm_capFac(t,regi,"rockgrind") * vm_cap(t,regi,"rockgrind",rlf2))
	;
	
* JeS: timestep in 2060 not yet quite right!  
q33_grindrock_onfield_tot(ttot,regi,rlf,rlf2)$(ttot.val ge max(2010, cm_startyear))..
	v33_grindrock_onfield_tot(ttot,regi,rlf,rlf2)
	=e=
    v33_grindrock_onfield_tot(ttot-1,regi,rlf,rlf2) * exp(-p33_co2_rem_rate(rlf) * pm_ts(ttot)) + 
	v33_grindrock_onfield(ttot-1,regi,rlf,rlf2) * (sum(tall $ ((tall.val lt (ttot.val-pm_ts(ttot)/2)) $ (tall.val gt (ttot.val-pm_ts(ttot)))),exp(-p33_co2_rem_rate(rlf) * (ttot.val-tall.val)))) + 
	v33_grindrock_onfield(ttot,regi,rlf,rlf2) * (sum(tall $ ((tall.val le ttot.val) $ (tall.val gt (ttot.val-pm_ts(ttot)/2))),exp(-p33_co2_rem_rate(rlf) * (ttot.val-tall.val))))
;  

q33_emiEW(t,regi)..
	v33_emiEW(t,regi)
	=e=
	sum(rlf,
		- sum(rlf2,v33_grindrock_onfield_tot(t,regi,rlf,rlf2)) * s33_co2_rem_pot * (1 - exp(-p33_co2_rem_rate(rlf)))
		)
	;	

*** new default: gas for heat production is with CCS; assume 90% capture rate.	
q33_capconst_dac(t,regi)..
	v33_emiDAC(t,regi)
	=e=
	-sum(teNoTransform2rlf_dyn33(te,rlf2), vm_capFac(t,regi,"dac") * vm_cap(t,regi,"dac",rlf2))
	-  (1 / pm_eta_conv(t,regi,"gash2c")) * fm_dataemiglob("pegas","seh2","gash2c","cco2") * vm_otherFEdemand(t,regi,"fegas")	
	;
	
q33_emicdrregi(t,regi)..
	vm_emiCdr(t,regi,"co2")
	=e=
	v33_emiEW(t,regi) + v33_emiDAC(t,regi)
	;
	
q33_otherFEdemand(t,regi,entyFe)..
	vm_otherFEdemand(t,regi,entyFe)
	=e=
	sum(rlf, s33_rockgrind_fedem$(sameas(entyFe,"feels")) * sm_EJ_2_TWa * sum(rlf2,v33_grindrock_onfield(t,regi,rlf,rlf2)))
   + sum(rlf, s33_rockfield_fedem$(sameas(entyFe,"fedie")) * sm_EJ_2_TWa * sum(rlf2,v33_grindrock_onfield(t,regi,rlf,rlf2)))
   - v33_emiDAC(t,regi) * sm_EJ_2_TWa * p33_dac_fedem(entyFe)
   - vm_otherFEdemand(t,regi,"feh2s")$(sameas(entyFe,"fegas")) - vm_otherFEdemand(t,regi,"fegas")$(sameas(entyFe,"feh2s"))
	;	
	
q33_H2bio_lim(t,regi,te)..	         
	vm_prodSE(t,regi,"pebiolc","seh2",te)$pe2se("pebiolc","seh2",te)
	=l=
    vm_prodFe(t,regi,"seh2","feh2s","tdh2s") - vm_otherFEdemand(t,regi,"feh2s")
	;

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
	
q33_potential(t,regi,rlf)..	
	sum(rlf2,v33_grindrock_onfield_tot(t,regi,rlf,rlf2))
	=l=
	f33_maxProdGradeRegiWeathering(regi,rlf);	
	
q33_ccsbal(t,regi,ccs2te(ccsCo2(enty),enty2,te))..
	sum(teCCS2rlf(te,rlf), vm_ccs_cdr(t,regi,enty,enty2,te,rlf))
	=e=
	-v33_emiDAC(t,regi)
	;	
  
q33_LimEmiEW(t,regi)..
             sum(rlf,
                  sum(rlf2,v33_grindrock_onfield(t,regi,rlf,rlf2))
                )
        =l=
        cm_LimRock*p33_LimRock(regi);
		
*** EOF ./modules/33_CDR/all/equations.gms
