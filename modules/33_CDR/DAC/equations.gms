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
  sum((entySe,te)$se2fe(entySe,entyFe,te), vm_demFeSector(t, regi, entySe, entyFe, "cdr", "ETS"))
  =e=
  sum(entyFe2, v33_DacFEdemand(t, regi, entyFe, entyFe2))
  ;

***---------------------------------------------------------------------------
*'  Calculation of electricity demand for ventilation and heat demand for absorption material recovery of direct air capture.
***---------------------------------------------------------------------------
q33_DacFEdemand(t, regi, entyFe2)$sum(entyFe, fe2fe_dac(entyFe, entyFe2))..
	sum(entyFe$fe2fe_dac(entyFe, entyFe2), v33_DacFEdemand(t, regi, entyFe, entyFe2))
	=e=
	- v33_emiDAC(t, regi) * sm_EJ_2_TWa * p33_dac_fedem(entyFe2)
	;

***---------------------------------------------------------------------------
*'  Calculation of (negative) CO2 emissions from direct air capture. The first part of the equation describes emissions captured from the ambient air, 
*'  the second part calculates the CO2 captured from the gas used for heat production assuming 90% capture rate.
***---------------------------------------------------------------------------
q33_capconst_dac(t,regi)..
	v33_emiDAC(t,regi)
	=e=
	- sum(teNoTransform2rlf_dyn33("dac",rlf2), vm_capFac(t,regi,"dac") * vm_cap(t,regi,"dac",rlf2))
	-  (1 / pm_eta_conv(t,regi,"gash2c")) * fm_dataemiglob("pegas","seh2","gash2c","cco2") * v33_DacFEdemand(t,regi,"fegas", "fehes")
	;

***---------------------------------------------------------------------------
*'  Sum of all CDR emissions other than BECCS and afforestation, which are calculated in the core.
***---------------------------------------------------------------------------
q33_emicdrregi(t,regi)..
	vm_emiCdr(t,regi,"co2")
	=e=
	v33_emiDAC(t,regi);


***---------------------------------------------------------------------------
*'  Preparation of captured emissions to enter the CCS chain.
***---------------------------------------------------------------------------	
q33_ccsbal(t,regi,ccs2te(ccsCo2(enty),enty2,te))..
	sum(teCCS2rlf(te,rlf), vm_ccs_cdr(t,regi,enty,enty2,te,rlf))
	=e=
	-vm_emiCdr(t,regi,"co2")
	;

***---------------------------------------------------------------------------
*'  Limit the amount of H2 from biomass to the demand without DAC.
***---------------------------------------------------------------------------
q33_H2bio_lim(t,regi,te)$pe2se("pebiolc","seh2",te)..	         
	vm_prodSE(t,regi,"pebiolc","seh2",te)
	=l=
    vm_prodFe(t,regi,"seh2","feh2s","tdh2s") - sum(entyFe2, v33_DacFEdemand(t,regi,"feh2s", entyFe2))
	;

*** EOF ./modules/33_CDR/DAC/equations.gms
