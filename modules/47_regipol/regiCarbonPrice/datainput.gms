*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCarbonPrice/datainput.gms


* initialize regipol target deviation parameter
pm_regiTarget_dev(ext_regi,ttot,ttot2) = 0;

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
* 2368.8517 Mt CO2-equiv/yr, verified stationary emissions from EEA, 
*   this is equal to 2333 Mt CO2-equiv/yr = 2368.8517 *(1-0.0123-0.0025) if:
*   - remove Norway, Iceland and Liechtenstein (-1.2% allowances according EEA data), as they are not accounted for now in the REMIND ETS
*   - remove Switzerland emissions in the ETS (5 mtCO2). 0.25% of total EU (2 Gt CO2).
* 2501.24927010579 Mt CO2-equiv/yr, from EU Reference Scenario
* 2345 Mt CO2-equiv/yr, from EEA sectoral data (REMIND needs to be able to reflect this number as close as possible for 2005 emissions)
p47_emiAllowances("2005","EU_ETS") = 2.345;

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
$IFTHEN.emiMktES2050_3 not "%cm_emiMktES2050%" == "linear2010to2050"
	pm_emiTargetES("2050",regi) = f47_ESreferenceEmissions("2005",regi)*%cm_emiMktES2050%;
$ENDIF.emiMktES2050_3
$ENDIF.emiMktES2050_2
$ENDIF.emiMktES2050

display pm_emiTargetES;

$ENDIF.emiMktES

*** Region-specific datainput (with hard-coded regions)

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
	p47_implFETax0(ttot,all_regi) = 0;

$endIf.cm_implicitFE

*** FS: scale down capacity factor for coal power in Germany in the near-term based on observed values in 2020 (~0.35 CF)
*** https://static.agora-energiewende.de/fileadmin/Projekte/2021/2020_01_Jahresauswertung_2020/200_A-EW_Jahresauswertung_2020_WEB.pdf

*** do this only in non-baseline runs for now to not mess with the calibration, the if clause can be removed (or changes moved to mrremind) once covid-corrected calibration input data is there

if( cm_emiscen ne 1,
pm_cf("2020",regi,"pc")$(sameAs(regi,"DEU")) = 0.35;
pm_cf("2025",regi,"pc")$(sameAs(regi,"DEU")) = 0.35;
pm_cf("2030",regi,"pc")$(sameAs(regi,"DEU")) = 0.4;
);


$ifthen.altFeEmiFac not "%cm_altFeEmiFac%" == "off" 
*** Changing Germany and France refineries emission factors to avoid negative emissions on pe2se (changing from 18.4 to 20 zeta joule = 20/31.7098 = 0.630719841 Twa = 0.630719841 * 3.66666666666666 * 1000 * 0.03171  GtC/TWa = 73.33 GtC/TWa)
  pm_emifac(ttot,regi,"peoil","seliqfos","refliq","co2")$(sameas(regi,"DEU") OR sameas(regi,"FRA")) = 0.630719841;
*** Changing Germany and UKI solids emissions factors to be in line with CRF numbers (changing from 26.1 to 29.27 zeta joule = 0.922937989 TWa = 107.31 GtC/TWa)
  pm_emifac(ttot,regi,"pecoal","sesofos","coaltr","co2")$(sameas(regi,"DEU") OR sameas(regi,"UKI")) = 0.922937989;
$endif.altFeEmiFac

*** EOF ./modules/47_regipol/regiCarbonPrice/datainput.gms
