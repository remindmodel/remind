parameter f50_beta1(nboot,iso)	"damage function parameter for temperature"
/
$ondelim
$include "./modules/50_damages/KotzWenz/input/beta1_for_REMIND.csv"
$offdelim
/
;

parameter f50_beta2(nboot,iso)	"damage function parameter for temperature^2"
/
$ondelim
$include "./modules/50_damages/KotzWenz/input/beta2_for_REMIND.csv"
$offdelim
/
;
parameter f50_maxtemp(nboot)	"maximum temperature for which damage function is valid"
/
$ondelim
$include "./modules/50_damages/KotzWenz/input/maxtemp_for_REMIND.csv"
$offdelim
/
;

*read in national population and gdp for weighted regional aggregation
*table f50_countryPop(tall,iso,all_POPscen)	
*$ondelim
*$include "./modules/50_damages/KotzWenz/input/f50_pop.cs3r"
*$offdelim
*;
*p50_isoPop(tall,iso)=f50_countryPop(tall,iso,"%cm_POPscen%");

table f50_countryGDP(tall,iso,all_GDPscen)	"country level GDP"
$ondelim
$include "./modules/50_damages/KotzWenz/input/f50_gdp.cs3r"
$offdelim
;
*p50_isoGDP(tall,iso)=f50_countryGDP(tall,iso,"%cm_GDPscen%");

*interpolate to annual time steps
*loop(ttot$(ttot.val ge 2005),
*	loop(tall$(pm_tall_2_ttot(tall,ttot)),
*		p50_isoPop(tall,iso) = 
*			(1-pm_interpolWeight_ttot_tall(tall))*p50_isoPop(ttot,iso)
*			+ pm_interpolWeight_ttot_tall(tall)*p50_isoPop(ttot+1,iso);
*		p50_isoGDP(tall,iso) = 
*			(1-pm_interpolWeight_ttot_tall(tall))*p50_isoGDP(ttot,iso)
*			+ pm_interpolWeight_ttot_tall(tall)*p50_isoGDP(ttot+1,iso);
*))
*;

*keep constant after 2150 as it is needed until 2300 for SCC calculation
*p50_isoGDP(tall,iso)$(tall.val ge 2150) = p50_isoGDP("2150",iso);
*p50_isoPop(tall,iso)$(tall.val ge 2150) = p50_isoPop("2150",iso);

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

* initialize
pm_damage(tall,regi) = 1;
