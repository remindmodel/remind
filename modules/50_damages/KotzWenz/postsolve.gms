p50_globalMeanTemp2020(nboot,tall)$(tall.val ge 2020 and tall.val le 2300) = 
	pm_globalMeanTemperatureZeroed1900(tall)-pm_globalMeanTemperatureZeroed1900("2020")
;

*set temperature to max temp for each realization if it is higher
loop(tall,
  loop(nboot,
	if((p50_globalMeanTemp2020(nboot,tall) gt f50_maxtemp(nboot)),
	p50_globalMeanTemp2020(nboot,tall) = f50_maxtemp(nboot)
);
);
);

*calculate damage factor for each country and realization
p50_damageIso(tall,iso,nboot)$(tall.val gt 2020 and tall.val le 2300) = 
	f50_beta1(nboot,iso)/100*p50_globalMeanTemp2020(nboot,tall)+f50_beta2(nboot,iso)/100*p50_globalMeanTemp2020(nboot,tall)*p50_globalMeanTemp2020(nboot,tall);

*desired percentile of damages
*hardcode mean for now, think about percentiles later
p50_damageIsoPerc(tall,iso)$(tall.val gt 2020 and tall.val le 2300) = 
	sum(nboot,p50_damageIso(tall,iso,nboot))/1000
;

*marginal
p50_damageMarginalIso(tall,iso,nboot)$(tall.val gt 2020 and tall.val le 2300) =
	f50_beta1(nboot,iso)/100+2*f50_beta2(nboot,iso)/100*p50_globalMeanTemp2020(nboot,tall)
;
	
p50_damageMarginalIsoPerc(tall,iso)$(tall.val gt 2020 and tall.val le 2300) = 
	sum(nboot,p50_damageMarginalIso(tall,iso,nboot))/1000
;

*loop(tall $ (tall.val ge 2020 and tall.val le 2300),
*	loop(iso,
*		p50_rank(nboot)=p50_damageIso(tall,iso,nboot);
*$libInclude rank p50_rank nboot p50_r p50_pct
*		p50_damageIsoPerc(tall,iso)=p50_pct("median");
**		p50_damageIsoPerc(tall,iso)=p50_pct("%cm_DamPerc%")

*		p50_rank(nboot)=p50_damageMarginalIso(tall,iso,nboot);
*$libInclude rank p50_rank nboot p50_r p50_pct
*		p50_damageMarginalIsoPerc(tall,iso)=p50_pct("median");
**		p50_damageMarginalIsoPerc(tall,iso)=p50_pct("%cm_DamPerc%")
*display p50_pct;
*	);
*);


pm_damageMarginal(tall,regi)$(tall.val gt 2020 and tall.val le 2300) = 
*	sum(regi2iso(regi,iso),p50_damageMarginalIsoPerc(tall,iso)*p50_isoGDP(tall,iso))/sum(regi2iso(regi,iso),p50_isoGDP(tall,iso))
	sum(regi2iso(regi,iso),p50_damageMarginalIsoPerc(tall,iso)*pm_GDPfrac(tall,iso))
;

*regional damage using SSP country level GDP as weight
pm_damage(tall,regi)$(tall.val gt 2020 and tall.val le 2300) = 
	1-sum(regi2iso(regi,iso),p50_damageIsoPerc(tall,iso)*pm_GDPfrac(tall,iso))
;

display p50_damageIsoPerc,pm_damage,pm_damageMarginal;

