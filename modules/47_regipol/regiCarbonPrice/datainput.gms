*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCarbonPrice/datainput.gms


* initialize regipol target deviation parameter
pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt) = 0;

$IFTHEN.emiMkt not "%cm_emiMktTarget%" == "off" 

* initialize carbon taxes before start year 
if ( (cm_startyear gt 2005),
  Execute_Loadpoint 'input_ref' p47_taxCO2eq_ref = pm_taxCO2eq;
  Execute_Loadpoint 'input_ref' p47_taxemiMkt_init = pm_taxemiMkt;

*** copying taxCO2eq value to emiMkt tax parameter for fixed years that contain no pm_taxemiMkt value
  p47_taxemiMkt_init(ttot,regi,emiMkt)$((p47_taxCO2eq_ref(ttot,regi)) and (ttot.val le cm_startyear) and (NOT(p47_taxemiMkt_init(ttot,regi,emiMkt)))) = p47_taxCO2eq_ref(ttot,regi);

*** Initializing European ETS historical and reference prices
	loop(regi$regi_groupExt("EUR_regi",regi),
		p47_taxemiMkt_init("2005",regi,"ETS")$(cm_startyear le 2005) = 0;
		p47_taxemiMkt_init("2010",regi,"ETS")$(cm_startyear le 2010)  = 15*sm_DptCO2_2_TDpGtC;
		p47_taxemiMkt_init("2015",regi,"ETS")$(cm_startyear le 2015)  = 8*sm_DptCO2_2_TDpGtC;
***		p47_taxemiMkt_init("2020",regi,"ETS")$(cm_startyear le 2020)  = 41.28*sm_DptCO2_2_TDpGtC; !! 2018 =~ 16.5€/tCO2, 2019 =~ 25€/tCO2, 2020 =~ 25€/tCO2, 2021 =~ 53.65€/tCO2, 2022 =~ 80€/tCO2 -> average 2020 = 40€/tCO2 -> 40*1.032 $/tCO2 = 41.28 $/t CO2
		p47_taxemiMkt_init("2020",regi,"ETS")$(cm_startyear le 2020)  = 30*sm_DptCO2_2_TDpGtC;

*** Initializing European ESR historical and reference prices
		p47_taxemiMkt_init("2020",regi,"ES")$(cm_startyear le 2020)  = 30*sm_DptCO2_2_TDpGtC;
    p47_taxemiMkt_init("2020",regi,"other")$(cm_startyear le 2020)  = 30*sm_DptCO2_2_TDpGtC;
	);
);

$ENDIF.emiMkt


parameter f47_ETSreferenceEmissions(tall,all_regi)      "ETS 2005 reference emissions (Mt CO2-equiv or Mt CO2)"
/
$ondelim
$include "./modules/47_regipol/regiCarbonPrice/input/p47_ETS_GHG_referenceEmissions.cs4r"
$offdelim
/
;

$IFTHEN.emiMktETS not "%cm_emiMktETS%" == "off" 
pm_emissionsRefYearETS(ETS_mkt) = sum(regi$ETS_regi(ETS_mkt,regi), f47_ETSreferenceEmissions("2005",regi)/1000);

display f47_ETSreferenceEmissions, pm_emissionsRefYearETS;

$ENDIF.emiMktETS

$IFTHEN.emiMktES not "%cm_emiMktES%" == "off" 

parameter f47_ESRTarget(tall,all_regi)      "Effort Sharing emission reduction target (%)"
/
$ondelim
$include "./modules/47_regipol/regiCarbonPrice/input/p47_ESR_target.cs4r"
$offdelim
/
;

parameter f47_ESRreferenceEmissions(tall,all_regi)      "Effort Sharing 2005 reference emissions (Mt CO2-equiv or Mt CO2)"
/
$ondelim
$if %cm_emiMktES_type% == "netGHG"   $include "./modules/47_regipol/regiCarbonPrice/input/p47_ESR_GHG_referenceEmissions.cs4r"
$if %cm_emiMktES_type% == "netCO2"   $include "./modules/47_regipol/regiCarbonPrice/input/p47_ESR_CO2_referenceEmissions.cs4r"
$offdelim
/
;

pm_emissionsRefYearESR(ttot,regi) = f47_ESRreferenceEmissions(ttot,regi)/1000;

pm_emiTargetESR(t,regi)$(f47_ESRTarget(t,regi) and regi_group("EU27_regi",regi)) = ( pm_emissionsRefYearESR("2005",regi) * (1 + f47_ESRTarget(t,regi)) ) / sm_c_2_co2;

* Applying modifier if it is assumed that the Effort Sharing Decision target does not need to be reached entirely at 2030
pm_emiTargetESR("2030",regi)$pm_emiTargetESR("2030",regi) = pm_emiTargetESR("2030",regi) * %cm_emiMktES%;

$IFTHEN.emiMktES2050 not "%cm_emiMktES2050%" == "off"
$IFTHEN.emiMktES2050_2 not "%cm_emiMktES2050%" == "linear"
$IFTHEN.emiMktES2050_3 not "%cm_emiMktES2050%" == "linear2010to2050"
	pm_emiTargetESR("2050",regi) = (pm_emissionsRefYearESR("2005",regi)/sm_c_2_co2)*%cm_emiMktES2050%;
$ENDIF.emiMktES2050_3
$ENDIF.emiMktES2050_2
$ENDIF.emiMktES2050

display pm_emiTargetESR;

$ENDIF.emiMktES

*** Region-specific datainput (with hard-coded regions)

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

*** intialize energy type bound implicit target parameters
$ifthen.cm_implicitEnergyBound not "%cm_implicitEnergyBound%" == "off"
	p47_implEnergyBoundTax0(t,all_regi) = 0;
$endIf.cm_implicitEnergyBound

$ifthen.altFeEmiFac not "%cm_altFeEmiFac%" == "off" 
*** Changing refineries emission factors in regions that belong to cm_altFeEmiFac to avoid negative emissions on pe2se (changing from 18.4 to 20 zeta joule = 20/31.7098 = 0.630719841 Twa = 0.630719841 * 3.66666666666666 * 1000 * 0.03171  GtC/TWa = 73.33 GtC/TWa)
loop(ext_regi$altFeEmiFac_regi(ext_regi), 
  pm_emifac(ttot,regi,"peoil","seliqfos","refliq","co2")$(regi_group(ext_regi,regi)) = 0.630719841;
);
*** Changing Germany and UKI solids emissions factors to be in line with CRF numbers (changing from 26.1 to 29.27 zeta joule = 0.922937989 TWa = 107.31 GtC/TWa)
  pm_emifac(ttot,regi,"pecoal","sesofos","coaltr","co2")$(sameas(regi,"DEU") OR sameas(regi,"UKI")) = 0.922937989;
$endif.altFeEmiFac


*** VRE capacity factor adjustments for Germany in line with ARIADNE assumptions
$ifthen.GerVRECapFac not "%cm_ariadne_VRECapFac_adj%" == "off" 
loop(te$sameas(te,"wind"),
  loop(regi$sameas(regi,"DEU"),
    pm_cf("2025",regi,te) =  1.04 * pm_cf("2025",regi,te);
    pm_cf("2030",regi,te) =  1.08 * pm_cf("2030",regi,te);
    pm_cf("2035",regi,te) =  1.12 * pm_cf("2035",regi,te);
    pm_cf("2040",regi,te) =  1.16 * pm_cf("2040",regi,te);
    pm_cf("2045",regi,te) =  1.2  * pm_cf("2045",regi,te);
    pm_cf(t,regi,te)$(t.val gt 2045) =  pm_cf("2045",regi,te);
  );
);


loop(te$sameas(te,"spv"),
  loop(regi$sameas(regi,"DEU"),
    pm_cf("2025",regi,te) =  1.02 * pm_cf("2025",regi,te);
    pm_cf("2030",regi,te) =  1.04 * pm_cf("2030",regi,te);
    pm_cf("2035",regi,te) =  1.06 * pm_cf("2035",regi,te);
    pm_cf("2040",regi,te) =  1.08 * pm_cf("2040",regi,te);
    pm_cf("2045",regi,te) =  1.10 * pm_cf("2045",regi,te);
    pm_cf(t,regi,te)$(t.val gt 2045) =  pm_cf("2045",regi,te);
  );
);
$endif.GerVRECapFac


*** p_EmiLULUCFCountryAcc contains historic LULUCF emissions from UNFCCC, 
*** used for rescaling land-use change emissions for emissions targets based on national accounting
parameter p47_EmiLULUCFCountryAcc(tall,all_regi)                "historic co2 emissions from landuse change based on country accounting [Mt CO2/yr]"
/
$ondelim
$include "./modules/47_regipol/regiCarbonPrice/input/p_EmiLULUCFCountryAcc.cs4r"
$offdelim
/
;

*** difference between 2015 land-use change emissions from Magpie and UNFCCC 2015 land-use change emissions
p47_LULUCFEmi_GrassiShift(t,regi)$(p47_EmiLULUCFCountryAcc("2015",regi)) = (pm_macBaseMagpie("2015",regi,"co2luc") - p47_EmiLULUCFCountryAcc("2015",regi)* 1e-3/sm_c_2_co2);

*** EOF ./modules/47_regipol/regiCarbonPrice/datainput.gms
