*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCarbonPrice/datainput.gms


*** if the bau or ref gdx has been run with a carbon tax  
if ( (cm_startyear gt 2005),
  Execute_Loadpoint 'input_ref' p47_taxCO2eqBeforeStartYear = pm_taxCO2eq;
  p47_taxCO2eqBeforeStartYear(ttot,regi)$((ttot.val ge cm_startyear)) = 0;
);

$IFTHEN.emiMktETS not "%cm_emiMktETS%" == "off" 
if ( (cm_startyear gt 2005),
  Execute_Loadpoint 'input_ref' p47_taxemiMktBeforeStartYear = pm_taxemiMkt;
  p47_taxemiMktBeforeStartYear(ttot,regi,emiMkt)$((ttot.val ge cm_startyear)) = 0;
);
$ENDIF.emiMktETS

parameter p47_emiAllowances(tall,ETS_mkt)       "emission allowances (without national aviation)"
/
$ondelim
$include "./modules/47_regipol/regiCarbonPrice/input/p47_emiAllowances.cs4r"
$offdelim
/
;

p47_emiAllowances(tall,ETS_mkt) = p47_emiAllowances(tall,ETS_mkt) / 10**9; !!GtCO2

*removing 3 GtCo2 from allowances in 2018 and 2019 due to market stability reserve (assumption: this amount of allowances will not return to the market)
p47_emiAllowances("2018","EU_ETS") = p47_emiAllowances("2018","EU_ETS") - 1.5; 
p47_emiAllowances("2019","EU_ETS") = p47_emiAllowances("2019","EU_ETS") - 1.5; 

*removing Norway, Iceland and Liechtenstein from the allowances as they are not accounted for now in the REMIND ETS. They account for approximately 1.2% of the total allocated allowances according EEA data (European Environment Agency) 
*adding allowances corresponding to Switzerland emissions in the ETS (5 mtCO2) vs total EU (2 Gt CO2) equal to 0.25%
p47_emiAllowances(tall,"EU_ETS") = p47_emiAllowances(tall,"EU_ETS")*(1-0.0123+0.0025); 

* ETS 2005 reference emissions
* 2368.8517 Mt CO2-equiv/yr, verified stationary emissions from EEA
* 2501.24927010579 Mt CO2-equiv/yr, from EU Reference Scenario
* 2932.555379 Mt CO2-equiv/yr, from REMIND 2005
* 2633.49473 Mt CO2/yr, from REMIND 2005 (should be using this one, but the ETS prices would be too low)
p47_emiAllowances("2005","EU_ETS") = 2.3688517;

$ifThen.emiMktETS not "%cm_emiMktETS%" == "off" 
*removing Norway, Iceland and Liechtenstein from the ETS budget as they are not accounted for now in the REMIND ETS. They account for approximately 1.2% of the total allocated allowances according EEA data (European Environment Agency) 
*removing Switzerland emissions in the ETS (5 mtCO2) vs total EU (2 Gt CO2) equal to 0.25%
p47_regiCO2ETStarget(ttot,target_type,emi_type)$p47_regiCO2ETStarget(ttot,target_type,emi_type) = p47_regiCO2ETStarget(ttot,target_type,emi_type)*(1-0.0123-0.0025);
$endIf.emiMktETS  

$ontext

* Calculating 2030 to 2050 allowances based on 2005 ETS emissions
$IFTHEN.emiMktETS not "%cm_emiMktETS%" == "off" 

* budget target
$IFTHEN.ETS_budget "%cm_emiMktETS_type%" == "budget" 
	loop(tall$((tall.val gt 2030) AND (tall.val le 2050)),
		p47_emiAllowances(tall,"EU_ETS")$p47_emiAllowances("2030","EU_ETS") = 
			p47_emiAllowances("2030","EU_ETS") + 
			( tall.val - 2030 )* (
				( ((( p47_emiAllowances("2005","EU_ETS") ) * (%cm_emiMktETS%))) - p47_emiAllowances("2030","EU_ETS") ) / (2050 - 2030)
			)
	);

	p47_emiTargetETS("2050","EU_ETS") = sum(tall$((tall.val ge 2013) AND (tall.val le 2050)), p47_emiAllowances(tall,"EU_ETS"))/sm_c_2_co2; !! emissions from 2013 to 2050
$ENDIF.ETS_budget

* linear target
$IFTHEN.ETS_budget "%cm_emiMktETS_type%" == "linear" 
	loop(tall$((tall.val gt 2030) AND (tall.val le 2050)),
		p47_emiAllowances(tall,"EU_ETS")$p47_emiAllowances("2030","EU_ETS") = 
			p47_emiAllowances("2030","EU_ETS") + 
			( tall.val - 2030 )* (
				( ((( p47_emiAllowances("2005","EU_ETS") ) * (%cm_emiMktETS%))) - p47_emiAllowances("2030","EU_ETS") ) / (2050 - 2030)
			)
	);

	p47_emiTargetETS("2050","EU_ETS") = sum(tall$((tall.val ge 2013) AND (tall.val le 2050)), p47_emiAllowances(tall,"EU_ETS"))/sm_c_2_co2; !! emissions from 2013 to 2050
$ENDIF.ETS_budget

* year target
$IFTHEN.ETS_yearTarget "%cm_emiMktETS_type%" == "year" 
	p47_emiAllowances("2050","EU_ETS") = p47_emiAllowances("2005","EU_ETS") * %cm_emiMktETS%;
	p47_emiTargetETS("2050","EU_ETS") = p47_emiAllowances("2050","EU_ETS")
$ENDIF.ETS_yearTarget

display p47_emiAllowances, p47_emiTargetETS;

$ENDIF.emiMktETS

$offtext

$IFTHEN.emiMktES not "%cm_emiMktES%" == "off" 

parameter f47_ESTarget(tall,all_regi)      "Effort Sharing emission reduction target (%)"
/
$ondelim
$include "./modules/47_regipol/regiCarbonPrice/input/p47_EStarget.cs4r"
$offdelim
/
;

parameter f47_ESreferenceEmissions(tall,all_regi)      "Effort Sharing 2005 reference emissions (Mt CO2-equiv or Mt CO2)"
/
$ondelim
$if %cm_emiMktES_type% == "netGHG"   $include "./modules/47_regipol/regiCarbonPrice/input/p47_ES_GHG_referenceEmissions.cs4r"
$if %cm_emiMktES_type% == "netCO2"   $include "./modules/47_regipol/regiCarbonPrice/input/p47_ES_CO2_referenceEmissions.cs4r"
$offdelim
/
;

pm_emiTargetES(t,regi)$f47_ESTarget(t,regi) = ( f47_ESreferenceEmissions("2005",regi)/1000 * (1 + f47_ESTarget(t,regi)) ) / sm_c_2_co2;

* Applying modifier if it is assumed that the Effort Sharing Decision target does not need to be reached entirely at 2030
pm_emiTargetES("2030",regi)$pm_emiTargetES("2030",regi) = pm_emiTargetES("2030",regi) * %cm_emiMktES%;

$IFTHEN.emiMktES2050 not "%cm_emiMktES2050%" == "off"
$IFTHEN.emiMktES2050_2 not "%cm_emiMktES2050%" == "linear"
	pm_emiTargetES("2050",regi) = f47_ESreferenceEmissions("2005",regi)*%cm_emiMktES2050%;
$ENDIF.emiMktES2050_2
$ENDIF.emiMktES2050

display pm_emiTargetES;

$ENDIF.emiMktES


***Germany Nuclear phase-out
$IFTHEN.NucRegiPol not "%cm_NucRegiPol%" == "off" 
	pm_earlyreti_adjRate(regi,"tnrs")$(sameas(regi,"DEU")) = 0.2;
$ENDIF.NucRegiPol

$IFTHEN.CCScostMarkup not "%cm_INNOPATHS_CCS_markup%" == "off" 
	pm_inco0_t(ttot,regi,teCCS)$(regi_group("EUR_regi",regi)) = pm_inco0_t(ttot,regi,teCCS)*%cm_INNOPATHS_CCS_markup%;
$ENDIF.CCScostMarkup

$IFTHEN.renewablesFloorCost not "%cm_INNOPATHS_renewables_floor_cost%" == "off" 
	parameter p_new_renewables_floor_cost(all_te) / %cm_INNOPATHS_renewables_floor_cost% /;
	pm_data(regi,"floorcost",te)$((regi_group("EUR_regi",regi)) AND (p_new_renewables_floor_cost(te))) = pm_data(regi,"floorcost",te)  + p_new_renewables_floor_cost(te);
$ENDIF.renewablesFloorCost


$ifThen.quantity_regiCO2target not "%cm_quantity_regiCO2target%" == "off"
loop((ttot,ext_regi,emi_type)$p47_quantity_regiCO2target(ttot,ext_regi,emi_type),
	p47_quantity_regiCO2target(t,ext_regi,emi_type)$(t.val ge ttot.val) = p47_quantity_regiCO2target(ttot,ext_regi,emi_type); 
);
$ENDIF.quantity_regiCO2target

*** intialize FE implicit target parameters
$ifthen.cm_implicitFE not "%cm_implicitFE%" == "off"

	p47_implFETax(ttot,all_regi,entyFe) = 0;
	p47_implFETax_prevIter(ttot,all_regi,entyFe) = 0;
	p47_implFETax0(ttot,all_regi) = 0;

$endIf.cm_implicitFE

*** EOF ./modules/47_regipol/regiCarbonPrice/datainput.gms
