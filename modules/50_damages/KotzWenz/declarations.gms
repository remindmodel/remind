Parameters
pm_GDPfrac(tall,iso)   "country fraction of regional GDP"
p50_globalMeanTemp2020(nboot,tall)      "global mean temperature difference to 2020"
p50_damageIso(tall,iso,nboot)	"country level damage factor"
p50_damageIsoPerc(tall,iso)	"damage percentile - currently mean"
pm_damage(tall,all_regi)	"regional damage factor"
p50_damageMarginalIso(tall,iso,nboot)	"country level damage marginal"
p50_damageMarginalIsoPerc(tall,iso)	"country level marginal percentile - currently mean"
pm_damageMarginal(tall,all_regi)	"regional damage marginal"
p50_r(nboot)	"needed for percentile computation"
p50_pct(*) /median 50.0, 95 95.0/	"possible percentiles for damages"
p50_rank(nboot)	  "needed for percentile computation"
;

positive variable
vm_damageFactor(ttot,all_regi)      "damage factor reducing GDP"
vm_damageProdFactor(ttot,all_regi,all_in)      "damage factor reducing production factors"
;
