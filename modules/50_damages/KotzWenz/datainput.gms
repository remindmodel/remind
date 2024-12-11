*** SOF ./modules/50_damages/KotzWenz/datainput.gms
table f50_countryGDP(tall,iso,all_GDPscen)	"country level GDP from SSPs"
$ondelim
$include "./modules/50_damages/KotzWenz/input/f50_gdp.cs3r"
$offdelim
;

* initialize
pm_damage(tall,regi) = 1;

*calculate and interpolate country GDP fraction of regional GDP, country GDP is in PPP, regional GDP in trl MER!
pm_GDPfrac(tall,iso)=f50_countryGDP(tall,iso,"%cm_GDPscen%")/1000000/(sum(regi2iso(regi,iso),pm_gdp(tall,regi)/pm_shPPPMER(regi))+1e-9);
loop(ttot$(ttot.val ge 2005),
	loop(tall$(pm_tall_2_ttot(tall,ttot)),
		pm_GDPfrac(tall,iso) = 
			(1-pm_interpolWeight_ttot_tall(tall))*pm_GDPfrac(ttot,iso)
			+ pm_interpolWeight_ttot_tall(tall)*pm_GDPfrac(ttot+1,iso);
));

display pm_GDPfrac;

pm_GDPfrac(tall,iso)$(tall.val ge 2150) = pm_GDPfrac("2150",iso);

*** EOF ./modules/50_damages/KotzWenz/datainput.gms
