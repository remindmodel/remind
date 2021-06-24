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
*'  Calculation of (negative) CO2 emissions from direct air capture. The first part of the equation describes emissions captured from the ambient air, 
*'  the second part calculates the CO2 captured from the gas used for heat production assuming 90% capture rate.
***---------------------------------------------------------------------------
q33_capconst_dac(t,regi)..
	v33_emiDAC(t,regi)
	=e=
	- sum(teNoTransform2rlf_dyn33(te,rlf2), vm_capFac(t,regi,"dac") * vm_cap(t,regi,"dac",rlf2))
	-  (1 / pm_eta_conv(t,regi,"gash2c")) * fm_dataemiglob("pegas","seh2","gash2c","cco2") * vm_otherFEdemand(t,regi,"fegas")
	;

***---------------------------------------------------------------------------
*'  Sum of all CDR emissions other than BECCS and afforestation, which are calculated in the core.
***---------------------------------------------------------------------------
q33_emicdrregi(t,regi)..
	vm_emiCdr(t,regi,"co2")
	=e=
	v33_emiDAC(t,regi);
	
***---------------------------------------------------------------------------
*'  Calculation of electricity demand for ventilation of direct air capture.
***---------------------------------------------------------------------------
q33_DacFEdemand_el(t,regi,entyFe)..
    v33_DacFEdemand_el(t,regi,entyFe)
    =e=
	- vm_emiCdr(t,regi,"co2") * sm_EJ_2_TWa *p33_dac_fedem_el(entyFe)
    ;

***---------------------------------------------------------------------------
*'  Calculation of heat demand of direct air capture. Heat can be provided as heat or by electricity, gas or H2; 
*'  For example, vm_otherFEdemand(t,regi,"fegas") is calculated as the total energy demand for heat from fegas minus what is already covered by other carriers (i.e. heat, h2 or elec) 
***---------------------------------------------------------------------------
q33_DacFEdemand_heat(t,regi,entyFe)..
    v33_DacFEdemand_heat(t,regi,entyFe)
    =e=
    - vm_emiCdr(t,regi,"co2") * sm_EJ_2_TWa * p33_dac_fedem_heat(entyFe)
    - v33_DacFEdemand_heat(t,regi,"feh2s")$((sameas(entyFe,"fegas"))OR(sameas(entyFe,"fehes"))OR(sameas(entyFe,"feels"))) 
	- v33_DacFEdemand_heat(t,regi,"fegas")$((sameas(entyFe,"feh2s"))OR(sameas(entyFe,"fehes"))OR(sameas(entyFe,"feels")))
	- v33_DacFEdemand_heat(t,regi,"feels")$((sameas(entyFe,"feh2s"))OR(sameas(entyFe,"fehes"))OR(sameas(entyFe,"fegas")))
	- v33_DacFEdemand_heat(t,regi,"fehes")$((sameas(entyFe,"feh2s"))OR(sameas(entyFe,"fegas"))OR(sameas(entyFe,"feels")))
    ;


***---------------------------------------------------------------------------
*'  Calculation of total energy demand of direct air capture. 
***---------------------------------------------------------------------------
q33_otherFEdemand(t,regi,entyFe)..
    vm_otherFEdemand(t,regi,entyFe)
    =e=
	v33_DacFEdemand_el(t,regi,entyFe) + v33_DacFEdemand_heat(t,regi,entyFe)
    ;

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
q33_H2bio_lim(t,regi,te)..	         
	vm_prodSE(t,regi,"pebiolc","seh2",te)$pe2se("pebiolc","seh2",te)
	=l=
    vm_prodFe(t,regi,"seh2","feh2s","tdh2s") - vm_otherFEdemand(t,regi,"feh2s")
	;
	
*** EOF ./modules/33_CDR/DAC/equations.gms
