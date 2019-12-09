*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/33_CDR/DAC/equations.gms
*** new default: gas for heat production is with CCS; assume 90% capture rate.
q33_capconst_dac(t,regi)..
	v33_emiDAC(t,regi)
	=e=
	- sum(teNoTransform2rlf_dyn33(te,rlf2), vm_capFac(t,regi,"dac") * vm_cap(t,regi,"dac",rlf2))
	-  (1 / pm_eta_conv(t,regi,"gash2c")) * fm_dataemiglob("pegas","seh2","gash2c","cco2") * vm_otherFEdemand(t,regi,"fegas")
	;

q33_emicdrregi(t,regi)..
	vm_emiCdr(t,regi,"co2")
	=e=
	v33_emiDAC(t,regi);
	
*** fehes is only district heat. Use gas or h2 to generate heat for DAC plants. 
*** vm_otherFEdemand(t,regi,"fegas") is calculated as the total energy demand for heat minus what is already covered by h2, i.e. vm_otherFEdemand(t,regi,"feh2s") and vice versa.
q33_otherFEdemand(t,regi,entyFe)..
    vm_otherFEdemand(t,regi,entyFe)
    =e=
    - vm_emiCdr(t,regi,"co2") * sm_EJ_2_TWa * p33_dac_fedem(entyFe)
    - vm_otherFEdemand(t,regi,"feh2s")$(sameas(entyFe,"fegas")) - vm_otherFEdemand(t,regi,"fegas")$(sameas(entyFe,"feh2s"))
    ;
	
q33_ccsbal(t,regi,ccs2te(ccsCo2(enty),enty2,te))..
	sum(teCCS2rlf(te,rlf), vm_ccs_cdr(t,regi,enty,enty2,te,rlf))
	=e=
	-vm_emiCdr(t,regi,"co2")
	;

q33_H2bio_lim(t,regi,te)..	         
	vm_prodSE(t,regi,"pebiolc","seh2",te)$pe2se("pebiolc","seh2",te)
	=l=
    vm_prodFe(t,regi,"seh2","feh2s","tdh2s") - vm_otherFEdemand(t,regi,"feh2s")
	;
	
*** EOF ./modules/33_CDR/DAC/equations.gms
