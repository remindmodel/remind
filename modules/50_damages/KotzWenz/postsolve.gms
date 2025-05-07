*** SOF ./modules/50_damages/KotzWenz/postsolve.gms
execute "Rscript run_KotzWenz_damages.R"
execute_loadpoint 'pm_KotzWenz_damageIso' p50_damageIsoPerc=pm_damageIso;
execute_loadpoint 'pm_KotzWenz_damageMarginalIso' p50_damageMarginalIsoPerc=pm_damageMarginalIso;

pm_damageMarginal(tall,regi)$(tall.val gt 2025 and tall.val le 2300) = 
	sum(regi2iso(regi,iso),p50_damageMarginalIsoPerc(tall,iso,"%cm_KotzWenzPerc%")*pm_GDPfrac(tall,iso))
;

*regional damage using SSP country level GDP as weight
pm_damage(tall,regi)$(tall.val gt 2025 and tall.val le 2300) = 
	1-sum(regi2iso(regi,iso),p50_damageIsoPerc(tall,iso,"%cm_KotzWenzPerc%")*pm_GDPfrac(tall,iso))
;

display pm_damage,pm_damageMarginal;
*** EOF ./modules/50_damages/KotzWenz/postsolve.gms
