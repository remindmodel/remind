
table f50_countryGDP(tall,iso,all_GDPscen)	"country level GDP from SSPs"
$ondelim
$include "./modules/50_damages/KotzWenz/input/f50_gdp.cs3r"
$offdelim
;
*p50_isoGDP(tall,iso)=f50_countryGDP(tall,iso,"%cm_GDPscen%");

*interpolate to annual time steps
*loop(ttot$(ttot.val ge 2005),
*	loop(tall$(pm_tall_2_ttot(tall,ttot)),
*		p50_isoGDP(tall,iso) = 
*			(1-pm_interpolWeight_ttot_tall(tall))*p50_isoGDP(ttot,iso)
*			+ pm_interpolWeight_ttot_tall(tall)*p50_isoGDP(ttot+1,iso);
*))
*;

*keep constant after 2150 as it is needed until 2300 for SCC calculation
*p50_isoGDP(tall,iso)$(tall.val ge 2150) = p50_isoGDP("2150",iso);

* initialize
pm_damage(tall,regi) = 1;

*calculate and interpolate country GDP fraction of regional GDP for SSP2EU scenario, country GDP is in PPP, regional GDP in trl MER!
pm_GDPfrac(tall,iso)=f50_countryGDP(tall,iso,"%cm_GDPscen%")/1000000/(sum(regi2iso(regi,iso),pm_gdp(tall,regi)/pm_shPPPMER(regi))+1e-9);
loop(ttot$(ttot.val ge 2005),
	loop(tall$(pm_tall_2_ttot(tall,ttot)),
		pm_GDPfrac(tall,iso) = 
			(1-pm_interpolWeight_ttot_tall(tall))*pm_GDPfrac(ttot,iso)
			+ pm_interpolWeight_ttot_tall(tall)*pm_GDPfrac(ttot+1,iso);
));

display pm_GDPfrac;

pm_GDPfrac(tall,iso)$(tall.val ge 2150) = pm_GDPfrac("2150",iso);

