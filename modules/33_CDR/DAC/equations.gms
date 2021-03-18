*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/33_CDR/DAC/equations.gms

***---------------------------------------------------------------------------
*'  CDR Final Energy Balance
***---------------------------------------------------------------------------
q33_demFeCDR(t,regi,entyFe)$(entyFe2Sector(entyFe,"cdr")) .. 
  vm_otherFEdemand(t,regi,entyFe)
  =e=
  sum((entySe,te)$se2fe(entySe,entyFe,te), vm_demFeSector(t,regi,entySe,entyFe,"cdr","ETS"))
;

***---------------------------------------------------------------------------
*'  Calculation of (negative) CO2 emissions from direct air capture. 
***---------------------------------------------------------------------------
q33_capconst_dac(t,regi)..
	v33_emiDAC(t,regi)
	=e=
	- sum(teNoTransform2rlf_dyn33(te,rlf2), vm_capFac(t,regi,"dac") * vm_cap(t,regi,"dac",rlf2))
	;

***---------------------------------------------------------------------------
*'  Sum of all CDR emissions other than BECCS and afforestation, which are calculated in the core.
***---------------------------------------------------------------------------
q33_emicdrregi(t,regi)..
	vm_emiCdr(t,regi,"co2")
	=e=
	v33_emiDAC(t,regi);
	
***---------------------------------------------------------------------------
*'  Calculation of energy demand of direct air capture. DAC demands feels and fehes
***---------------------------------------------------------------------------
q33_otherFEdemand(t,regi,entyFe)..
    vm_otherFEdemand(t,regi,entyFe)
    =e=
    - vm_emiCdr(t,regi,"co2") * sm_EJ_2_TWa * p33_dac_fedem(entyFe)
    ;

***---------------------------------------------------------------------------
*'  Preparation of captured emissions to enter the CCS chain.
***---------------------------------------------------------------------------	
q33_ccsbal(t,regi,ccs2te(ccsCo2(enty),enty2,te))..
	sum(teCCS2rlf(te,rlf), vm_ccs_cdr(t,regi,enty,enty2,te,rlf))
	=e=
	-vm_emiCdr(t,regi,"co2")
	;

*** EOF ./modules/33_CDR/DAC/equations.gms
