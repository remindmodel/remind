*** SOF ./modules/50_damages/KotzWenz/declarations.gms
Parameters
pm_GDPfrac(tall,iso)	"GDP fraction of a country in its region"
p50_damageIsoPerc(tall,iso,percentile)	"damage factor for country and bootstrapping"
pm_damage(tall,all_regi)	"regional damage factor"
pm_laborBenefit(tall,all_regi)	"beneficial impact on labor"
p50_damageMarginalIsoPerc(tall,iso,percentile)	"marginal damage for country and bootstrapping"
pm_damageMarginal(tall,all_regi)	"regional marginal damage"
;

positive variable
vm_damageProdFactor(ttot,all_regi,all_in)      "damage factor reducing production factors"
;
*** EOF ./modules/50_damages/KotzWenz/declarations.gms
