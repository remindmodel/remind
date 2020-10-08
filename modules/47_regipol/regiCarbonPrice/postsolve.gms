*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCarbonPrice/postsolve.gms

$IFTHEN.regicarbonprice not "%cm_regiCO2target%" == "off" 

display pm_taxCO2eq;

*** FS: calculate emissions used in regional target
*** net CO2 
	p47_emiTarget(t,regi,"netCO2")
	=
	vm_emiAll.L(t,regi,"co2")
;

*** gross Fossil Fuel and Industry co2 emissions: net energy co2 + cement co2 + BECCS
	p47_emiTarget(t,regi,"grossFFaI")
	=
	  vm_emiTe.L(t,regi,"co2") 
	+ vm_emiMacSector.L(t,regi,"co2cement_process")
	+ sum( (enty,enty2,te)$(pe2se(enty,enty2,te) AND teBio(te)), vm_emiTeDetail.L(t,regi,enty,enty2,te,"cco2"))
;
display p47_emiTarget;
*** to be fixed: netCO2 and gross FFaI do not exactly add up to Emi|Co2 and Emi|Co2|Gross Fossil Fuels and Industry in reporting, 
*** reporting about 10% lower. For now, please check in the reporting mif file whether the deviation is acceptable in your case.  

***  Calculating the current emission levels
***		for region groups
loop((ttot,ext_regi,target_type,emi_type)$(p47_regiCO2target(ttot,ext_regi,target_type,emi_type) AND (NOT(all_regi(ext_regi)))),
	if(sameas(target_type,"budget"), !! budget total CO2 target
		p47_emissionsCurrent(ext_regi) =
			sum(all_regi$regi_group(ext_regi,all_regi),
				sum(t$((t.val ge 2020) AND (t.val le ttot.val)),
					pm_ts(t) * (1 -0.5$(t.val eq 2020 OR t.val eq ttot.val))
					*(p47_emiTarget(t, all_regi,emi_type)*sm_c_2_co2)
			));		
	elseif sameas(target_type,"year"), !! year total CO2 target
		p47_emissionsCurrent(ext_regi) = sum(all_regi$regi_group(ext_regi,all_regi), p47_emiTarget(ttot, all_regi,emi_type)*sm_c_2_co2);
	);
);


***		for single regions (overwrites region groups)  
loop((ttot,ext_regi,target_type,emi_type)$(p47_regiCO2target(ttot,ext_regi,target_type,emi_type) AND (all_regi(ext_regi))),
	if(sameas(target_type,"budget"), !! budget target
		p47_emissionsCurrent(ext_regi) =
			sum(all_regi$sameas(ext_regi,all_regi), !! trick to translate the ext_regi value to the all_regi set
				sum(t$((t.val ge 2020) AND (t.val le ttot.val)),
					pm_ts(t) * (1 -0.5$(t.val eq 2020 OR t.val eq ttot.val))
					*(p47_emiTarget(t, all_regi,emi_type)*sm_c_2_co2)
			));
	elseif sameas(target_type,"year"),
		p47_emissionsCurrent(ext_regi) = sum(all_regi$sameas(ext_regi,all_regi), p47_emiTarget(ttot, all_regi,emi_type)*sm_c_2_co2); 
	);
);

	
***  calculating the CO2 tax rescale factor
loop((ttot,ext_regi,target_type,emi_type)$p47_regiCO2target(ttot,ext_regi,target_type,emi_type),		 
	if(iteration.val lt 10,
		p47_factorRescaleCO2Tax(ext_regi) = max(0.1, (p47_emissionsCurrent(ext_regi))/(p47_regiCO2target(ttot,ext_regi,target_type,emi_type)) ) ** 2;
	else
		p47_factorRescaleCO2Tax(ext_regi) = max(0.1, (p47_emissionsCurrent(ext_regi))/(p47_regiCO2target(ttot,ext_regi,target_type,emi_type)) ) ** 1;
	);
	p47_factorRescaleCO2Tax(ext_regi) =
		max(min( 2 * EXP( -0.15 * iteration.val ) + 1.01 ,p47_factorRescaleCO2Tax(ext_regi)),
			1/ ( 2 * EXP( -0.15 * iteration.val ) + 1.01)
		);
);

***	updating the co2 tax
***		for region groups
loop((ttot,ext_regi,target_type,emi_type)$(p47_regiCO2target(ttot,ext_regi,target_type,emi_type) AND (NOT(all_regi(ext_regi)))),
	loop(all_regi$regi_group(ext_regi,all_regi),
		pm_taxCO2eq(t,all_regi)$(t.val gt 2016 AND t.val ge cm_startyear AND t.val lt 2031)  = max(1* sm_DptCO2_2_TDpGtC, pm_taxCO2eq_iteration(iteration,t,all_regi) * p47_factorRescaleCO2Tax(ext_regi)); !! before 2030
		pm_taxCO2eq(t,all_regi)$(t.val gt 2030) = pm_taxCO2eq("2030",all_regi)*1.05**(t.val-2030); !! post 2030: increase at 5% p.a.
		pm_taxCO2eq(t,all_regi)$(t.val gt 2050) = pm_taxCO2eq("2050",all_regi)*1.0125**(t.val-2050); !! post 2050: increase at 1.25% p.a.
	);
);
***		for single regions (overwrites region groups)
loop((ttot,ext_regi,target_type,emi_type)$(p47_regiCO2target(ttot,ext_regi,target_type,emi_type) AND (all_regi(ext_regi))),
	loop(all_regi$sameas(ext_regi,all_regi), !! trick to translate the ext_regi value to the all_regi set
		pm_taxCO2eq(t,all_regi)$(t.val gt 2016 AND t.val ge cm_startyear AND t.val lt 2031)  = max(1* sm_DptCO2_2_TDpGtC, pm_taxCO2eq_iteration(iteration,t,all_regi) * p47_factorRescaleCO2Tax(ext_regi)); !! before 2030
		pm_taxCO2eq(t,all_regi)$(t.val gt 2030) = pm_taxCO2eq("2030",all_regi)*1.05**(t.val-2030); !! post 2030: increase at 5% p.a.
		pm_taxCO2eq(t,all_regi)$(t.val gt 2050) = pm_taxCO2eq("2050",all_regi)*1.0125**(t.val-2050); !! post 2050: increase at 1.25% p.a.
	);
);

display p47_regiCO2target,p47_emissionsCurrent,p47_factorRescaleCO2Tax;
display pm_taxCO2eq;

$ENDIF.regicarbonprice

*** EOF ./modules/47_regipol/regiCarbonPrice/postsolve.gms

