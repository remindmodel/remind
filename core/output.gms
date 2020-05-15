*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./core/output.gms

*** INNOPATHS reporting

Parameter 
o_emissions(ttot,all_regi,all_enty)
o_emissions_energy(ttot,all_regi,all_enty)
o_emissions_energy_demand(ttot,all_regi,all_enty)
o_emissions_energy_demand_sector(ttot,all_regi,all_enty,emi_sectors)
o_emissions_energy_supply_gross(ttot,all_regi,all_enty)
o_emissions_energy_supply_gross_carrier(ttot,all_regi,all_enty,all_enty)
o_emissions_energy_extraction(ttot,all_regi,all_enty,all_enty)
o_emissions_energy_negative(ttot,all_regi,all_enty)
o_emissions_industrial processes(ttot,all_regi,all_enty)
o_emissions_AFOLU(ttot,all_regi,all_enty)
o_emissions_DACCS(ttot,all_regi,all_enty)
o_emissions_other(ttot,all_regi,all_enty)

o_capture(ttot,all_regi,all_enty)
o_capture_energy(ttot,all_regi,all_enty)
o_capture_energy_elec(ttot,all_regi,all_enty)
o_capture_energy_other(ttot,all_regi,all_enty)
o_capture_cdr(ttot,all_regi,all_enty)
o_capture_industry(ttot,all_regi,all_enty)
o_capture_energy_bio(ttot,all_regi,all_enty)
o_capture_energy_bio(ttot,all_regi,all_enty)
;

Parameter
emi_conv(all_enty) / 
	co2 3666.6666666666666666666666666667,
	ch4 28,
	n2o 416.4286,
	so2 1,
	bc  1,
	oc  1
 /
;

o_emissions(t,regi,emi) = sum(emiMkt, vm_emiAllMkt.l(t,regi,emi,emiMkt))*emi_conv;

o_emissions_energy(t,regi,emi) = sum(emiMkt, vm_emiTeMkt.l(t,regi,emi,emiMkt))*emi_conv;

o_emissions_energy_demand(t,regi,emi) = 
	sum(sector2emiMkt(sector,emiMkt),
		sum(se2fe(enty,enty2,te),
			pm_emifac(t,regi,enty,enty2,te,emi)
			* vm_demFeSector.l(t,regi,enty,enty2,sector,emiMkt)
		)
	);

o_emissions_energy_demand_sector(t,regi,emi,sector) =
	sum(emiMkt$sector2emiMkt(sector,emiMkt),
		sum(se2fe(enty,enty2,te),
			pm_emifac(t,regi,enty,enty2,te,emi) * vm_demFeSector.l(t,regi,enty,enty2,sector,emiMkt)
		)
	);

o_emissions_energy_supply_gross(t,regi,emi) =
	sum(pe2se(entyPe,entySe,te),
		pm_emifac(t,regi,entyPe,entySe,te,emi)
		* vm_demPE.l(t,regi,entyPe,entySe,te)
	);
	
o_emissions_energy_supply_gross_carrier(t,regi,emi,entySe) =
	sum(pe2se(entyPe,entySe,te),
		pm_emifac(t,regi,entyPe,entySe,te,emi)
		* vm_demPE.l(t,regi,entyPe,entySe,te)
	);

o_emissions_energy_extraction(t,regi,emi,entyPe) =
***   emissions from non-conventional fuel extraction
	( sum(emi2fuelMine(emi,entyPe,rlf),      
		  p_cint(regi,emi,entyPe,rlf)
		* vm_fuExtr(t,regi,entyPe,rlf)
		)$( c_cint_scen eq 1 )
	 )
***   emissions from conventional fuel extraction
	+ ( sum(pe2rlf(entyPe,rlf2),sum(enty2,      
		 (p_cintraw(enty2)
		  * pm_fuExtrOwnCons(regi, enty2, entyPe) 
		  * vm_fuExtr(t,regi,entyPe,rlf2)
		 )$(pm_fuExtrOwnCons(regi, entyPe, enty2) gt 0)    
		))
	)
;

o_emissions_energy_negative(t,regi,emi) =
	sum((ccs2Leak(enty,enty2,te,emi),teCCS2rlf(te,rlf)),
		    pm_emifac(t,regi,enty,enty2,te,emi)
		    * vm_co2CCS(t,regi,enty,enty2,te,rlf)
		  )
***   Industry CCS emissions
	- ( sum(emiMac2mac(emiInd37_fuel,enty2),
		  vm_emiIndCCS(t,regi,emiInd37_fuel)
		)$( sameas(emi,"co2") )
	)
***   LP, Valve from cco2 capture step, to mangage if capture capacity and CCU/CCS capacity don't have the same lifetime
  + ( v_co2capturevalve(t,regi)$( sameas(enty,"co2") ) )
***  JS CO2 from short-term CCU (short term CCU co2 is emitted again in a time period shorter than 5 years)
  + sum(teCCU2rlf(te2,rlf),
		vm_co2CCUshort(t,regi,"cco2","ccuco2short",te2,rlf)$( sameas(enty,"co2") ) 
	)
;	

o_emissions_industrial processes(t,regi,emi) =
	sum(emiMkt,
		sum(emiMacSector2emiMac("co2cement_process",emiMac(emi))$macSector2emiMkt("co2cement_process",emiMkt),
			vm_emiMacSector(t,regi,"co2cement_process")
		)
	);

o_emissions_AFOLU(t,regi,emi) =
	sum(emiMkt,
		sum(emiMacSector2emiMac("co2luc",emiMac(emi))$macSector2emiMkt("co2luc",emiMkt),
			vm_emiMacSector(t,regi,"co2luc")
		)
	);
	
o_emissions_DACCS(t,regi,emi) =
	vm_emiCdr(t,regi,emi)
;

o_emissions_other(t,regi,emi) =
	pm_emiExog(t,regi,emi)
;

***Carbon Management|Carbon Capture (Mt CO2/yr)
o_capture(t,regi,"co2") =
	sum(teCCS2rlf(te,rlf),
		vm_co2capture(t,regi,"cco2","ico2","ccsinje",rlf)
	);

***Carbon Management|Carbon Capture|Process|Energy (Mt CO2/yr)
o_capture_energy(t,regi,"co2") =
	sum(emi2te(enty3,enty4,te2,"cco2"),
		vm_emiTeDetail(t,regi,enty3,enty4,te2,"cco2")
	);
	
***Carbon Management|Carbon Capture|Process|Energy|Electricity (Mt CO2/yr)
o_capture_energy_elec(t,regi,"co2") =
	sum(emi2te(enty3,"seel",te2,"cco2"),
		vm_emiTeDetail(t,regi,enty3,"seel",te2,"cco2")
	);

***Carbon Management|Carbon Capture|Process|Energy|Other (Mt CO2/yr)
o_capture_energy_other(t,regi,"co2") =
	sum(enty4$(NOT(sameas(enty4,"seel"))),
		sum(emi2te(enty3,enty4,te2,"cco2"),
			vm_emiTeDetail(t,regi,enty3,enty4,te2,"cco2")
		)
	);
	
***Carbon Management|Carbon Capture|Process|Direct Air Capture (Mt CO2/yr)
o_capture_cdr(t,regi,"co2") =
	sum(teCCS2rlf("ccsinje",rlf),
      vm_ccs_cdr(t,regi,"cco2","ico2","ccsinje",rlf)
    );

***Carbon Management|Carbon Capture|Process|Industrial Processes (Mt CO2/yr)
o_capture_industry(t,regi,"co2") =
	sum(emiInd37,
      vm_emiIndCCS(t,regi,emiInd37)
    )
;

***Carbon Management|Carbon Capture|Primary Energy|Biomass (Mt CO2/yr)
o_capture_energy_bio(t,regi,"co2") =
	sum(pebio(enty3),
		sum(emi2te(enty3,enty4,te2,"cco2"),
			vm_emiTeDetail(t,regi,enty3,enty4,te2,"cco2")
		)
	);

***Carbon Management|Carbon Capture|Primary Energy|Fossil (Mt CO2/yr)
o_capture_energy_bio(t,regi,"co2") =
	sum(enty3$(NOT(pebio(enty3)),
		sum(emi2te(enty3,enty4,te2,"cco2"),
			vm_emiTeDetail(t,regi,enty3,enty4,te2,"cco2")
		)
	);

***Carbon Management|CCU (Mt CO2/yr)
***Carbon Management|Land Use (Mt CO2/yr)
***Carbon Management|Underground Storage (Mt CO2/yr)

