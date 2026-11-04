*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/10_emissions/SectorAggregates/datainput.gms


*' ### Read-in and preparation of energy-related emissions factors

***   1. Read PE-to-SE emissions factors from generisdata_emi.prn.
***      Initialize raw-fuel carbon contents consistently with this input.
***   2. Apply scenario-specific technology and CCS capture-rate assumptions.
***      Convert the resulting factors to REMIND units.
***   3. Adjust captured CO2 for transport-pipeline leakage.
***   4. Allocate PE emissions factors to pm_emifac.
***   5. Set FE demand-side factors and apply their regional adjustments.
***   6. Set emissions factors for PE production, including fossil-fuel
***      extraction-related CO2, CH4, and bioenergy N2O factors.


*** ==================================================================
*' #### 1. Read PE emissions factors and CO2 capture rates of technologies from generisdata_emi.prn
*** ==================================================================

*' Read PE emissions factors and CO2 capture rates from the input file
*' Note that PE emissions factors relate to the whole carbon content of primary energy carriers
*' and not necessarily only the carbon relesed in the conversion step of the technology.
*' Calculation of actual Pe-to-Se emissions factors is done in the preloop.gms file.
*' CO2 capture rates are defined indirectly by this input file
*' as reductions of the PE CO2 emissions factor and a positive CCO2 emissions factor.
table f10_dataemiglob(all_enty,all_enty,all_te,all_enty) "read-in of PE emissions factors for CO2 (co2) and N2O (n2o) as wellas CO2 capture rates (cco2)"
$include "./modules/10_emissions/SectorAggregates/input/generisdata_emi.prn"
;

*' PE emissions factors of coal, oil, and gas consistent with generisdata_emi.prn
pm_cintraw("pecoal") = 26.1 / sm_ZJ_2_TWa;
pm_cintraw("peoil")  = 20.0 / sm_ZJ_2_TWa;
pm_cintraw("pegas")  = 15.3 / sm_ZJ_2_TWa;


*** ==================================================================
*' #### 2. Apply scenario-specific CO2 capture rate assumptions
*** ==================================================================


*' apply scenario-specific CO2 capture rate assumptions
$ifthen.tech_CO2capturerate not "%c_tech_CO2capturerate%" == "off"
 p10_PECarriers_CarbonContent(peFos)=pm_cintraw(peFos);
 p10_PECarriers_CarbonContent("pebiolc")=25 / sm_ZJ_2_TWa;
loop(pe2se(entyPe,entySe,te)$(p10_tech_CO2capturerate(te)),
  if(p10_tech_CO2capturerate(te) gt 0,
    if(p10_tech_CO2capturerate(te) ge 1,
      abort "Error: Inconsistent switch usage. A CO2 capture rate is greater than 1. Check c_tech_CO2capturerate.";
    );
    f10_dataemiglob(entyPe,entySe,te,"cco2") = p10_tech_CO2capturerate(te) * p10_PECarriers_CarbonContent(entyPe) * sm_ZJ_2_TWa;
    if(sameAs(entyPe,"pebiolc"),
      f10_dataemiglob(entyPe,entySe,te,"co2") = -f10_dataemiglob(entyPe,entySe,te,"cco2");
    else
      f10_dataemiglob(entyPe,entySe,te,"co2") = p10_PECarriers_CarbonContent(entyPe) - f10_dataemiglob(entyPe,entySe,te,"cco2");
    );
  );
);
$endif.tech_CO2capturerate

*' Apply alternative CCS capture assumptions used for SSP5.
if (cm_ccscapratescen eq 2,
  f10_dataemiglob("pecoal","seel","igccc","co2")    = 0.2;
  f10_dataemiglob("pecoal","seel","igccc","cco2")   = 25.9;
  f10_dataemiglob("pecoal","seh2","coalh2c","co2")  = 0.2;
  f10_dataemiglob("pecoal","seh2","coalh2c","cco2") = 25.9;
$ifthen "%c_SSP_forcing_adjust%" == "forcing_SSP5"
  f10_dataemiglob("pegas","seel","ngccc","co2")  = 0.1;
  f10_dataemiglob("pegas","seel","ngccc","cco2") = 15.2;
  f10_dataemiglob("pegas","seh2","gash2c","co2")  = 0.1;
  f10_dataemiglob("pegas","seh2","gash2c","cco2") = 15.2;
$endif
);


*' convert emissions factors to REMIND units (GtC/TWa)
f10_dataemiglob(enty,enty2,te,"co2")$pe2se(enty,enty2,te) = 1/sm_ZJ_2_TWa * f10_dataemiglob(enty,enty2,te,"co2");
f10_dataemiglob(enty,enty2,te,"cco2") = 1/sm_ZJ_2_TWa * f10_dataemiglob(enty,enty2,te,"cco2");

*** ==================================================================
*' #### 3. Apply CO2 transport pipeline leakage assumptions
*** ==================================================================

*' CO2 capture rates adjusted to account for CO2 transport pipeline leakage
*' The default assumption is 1% leakage
p10_co2pipe_leakage = 0.01;
loop(emi2te(enty,enty2,te,enty3)$teCCS(te),
  f10_dataemiglob(enty,enty2,te,"co2") = f10_dataemiglob(enty,enty2,te,"co2") + f10_dataemiglob(enty,enty2,te,"cco2") * p10_co2pipe_leakage;
  f10_dataemiglob(enty,enty2,te,"cco2") = f10_dataemiglob(enty,enty2,te,"cco2") * (1 - p10_co2pipe_leakage);
);



*** ==================================================================
*' #### 4. Allocate PE emissions factors to pm_emifac
*** ==================================================================

pm_emifac(ttot,regi,enty,enty2,te,"co2")$emi2te(enty,enty2,te,"co2") = f10_dataemiglob(enty,enty2,te,"co2");
pm_emifac(ttot,regi,enty,enty2,te,"cco2")$emi2te(enty,enty2,te,"cco2") = f10_dataemiglob(enty,enty2,te,"cco2");
pm_emifac(ttot,regi,enty,enty2,te,"n2o")$emi2te(enty,enty2,te,"n2o") = 1.288 * f10_dataemiglob(enty,enty2,te,"n2o");
pm_emifac(t,regi,"pecoal","sesofos","coaltr","ch4") = 9.46 * (1-pm_share_ind_fesos("2005",regi));
pm_emifac(t,regi,"pebiolc","sesobio","biotr","ch4") = 9.46 * (1-pm_share_ind_fesos_bio("2005",regi));

*** ==================================================================
*' #### 5. FE demand-side emissions factors
*** ==================================================================

*' Demand-side emission factors are specified in MtCO2/EJ
*' Source: U.S. Energy Information Administration (EIA), Fuel Emission
*' Factors (Fuel EFs_2.xls):
*' https://www.eia.gov/oiaf/1605/excel/Fuel%20EFs_2.xls
p10_ef_dem(regi,entyFe) = 0;
p10_ef_dem(regi,"fedie") = 69.3;
p10_ef_dem(regi,"fehos") = 69.3;
p10_ef_dem(regi,"fepet") = 68.5;
p10_ef_dem(regi,"fegas") = 50.3;
p10_ef_dem(regi,"fegat") = 50.3;
p10_ef_dem(regi,"fesos") = 90.5;

*' FE emisisons factors aligned with European statistics
*' Source: UBA?
$ifthen.altFeEmiFac not "%cm_altFeEmiFac%" == "off"
*** Replace the default FE factors and refinery/coal factors for configured
*** regions. The latter adjustments prevent negative Pe2Se emissions factors.
loop(ext_regi$altFeEmiFac_regi(ext_regi),
  p10_ef_dem(regi,entyFe)$(regi_group(ext_regi,regi)) = 0;
  p10_ef_dem(regi,"fedie")$(regi_group(ext_regi,regi)) = 74;
  p10_ef_dem(regi,"fehos")$(regi_group(ext_regi,regi)) = 73;
  p10_ef_dem(regi,"fepet")$(regi_group(ext_regi,regi)) = 73;
  p10_ef_dem(regi,"fegas")$(regi_group(ext_regi,regi)) = 55;
  p10_ef_dem(regi,"fesos")$(regi_group(ext_regi,regi)) = 96;
  pm_emifac(ttot,regi,"peoil","seliqfos","refliq","co2")$(regi_group(ext_regi,regi)) = 0.630719841;
);
pm_emifac(ttot,regi,"pecoal","sesofos","coaltr","co2")$(sameas(regi,"DEU") OR sameas(regi,"UKI")) = 0.922937989;
$endif.altFeEmiFac


*' FE emissions factors are converted to REMIND units (GtC/TWa)
pm_emifac(ttot,regi,"segafos","fegas","tdfosgas","co2") = p10_ef_dem(regi,"fegas") / (sm_c_2_co2*1000*sm_EJ_2_TWa);
pm_emifac(ttot,regi,"sesofos","fesos","tdfossos","co2") = p10_ef_dem(regi,"fesos") / (sm_c_2_co2*1000*sm_EJ_2_TWa);
pm_emifac(ttot,regi,"seliqfos","fehos","tdfoshos","co2") = p10_ef_dem(regi,"fehos") / (sm_c_2_co2*1000*sm_EJ_2_TWa);
pm_emifac(ttot,regi,"seliqfos","fepet","tdfospet","co2") = p10_ef_dem(regi,"fepet") / (sm_c_2_co2*1000*sm_EJ_2_TWa);
pm_emifac(ttot,regi,"seliqfos","fedie","tdfosdie","co2") = p10_ef_dem(regi,"fedie") / (sm_c_2_co2*1000*sm_EJ_2_TWa);
pm_emifac(ttot,regi,"segafos","fegat","tdfosgat","co2") = p10_ef_dem(regi,"fegas") / (sm_c_2_co2*1000*sm_EJ_2_TWa);


*** ==================================================================
*' #### 6. Emissions Factors for PE Production
*** ==================================================================

*' Extraction-related CO2 emissions from unconventional fossil-fuel extraction.
*** These factors are used by the MAC curve implementation to calculate the CO2 emissions from unconventional fossil-fuel extraction.
*** Numbers are in GtC per TWa and based on:
*** Charpentier et al. (2009), 10.1088/1748-9326/4/1/014005
*** Brandt (2011), "Upstream greenhouse gas (GHG) emissions from Canadian oil sands as a feedstock for European refineries"
p10_cint(regi,"co2","peoil","4") = 0.0475647000;
p10_cint(regi,"co2","peoil","5") = 0.1078133200;
p10_cint(regi,"co2","peoil","6") = 0.1775748800;
p10_cint(regi,"co2","peoil","7") = 0.2283105600;
p10_cint(regi,"co2","peoil","8") = 0.4153983800;



*' Read methane emissions from fossil-fuel extraction
*** Used for calculating CH4 emissions factor of fossil fuel extraction.
*** The base year determines whether the data comes from CEDS or EDGAR.
$ifthen %cm_emifacs_baseyear% == "2005"
parameter pm_emiFossilFuelExtr(all_regi,all_enty) "methane emissions in 2005 [Mt CH4], needed for pm_PeProdEmifac"
/
$ondelim
$include "./modules/10_emissions/SectorAggregates/input/p_emiFossilFuelExtr.cs4r"
$offdelim
/;
$else
parameter pm_emiFossilFuelExtr(all_regi,all_enty) "methane emissions in 2020 [Mt CH4], needed for pm_PeProdEmifac"
/
$ondelim
$include "./modules/10_emissions/SectorAggregates/input/p_emiFossilFuelExtr2020.cs4r"
$offdelim
/;
$endif

*' Hard-coded values for bioenergy N2O emissions factors differentiated across SSPs
$if %cm_LU_emi_scen% == "SSP1"       pm_PeProdEmifac(regi,"pebiolc","n2obio") = 0.0047 / sm_EJ_2_TWa;
$if %cm_LU_emi_scen% == "SSP2"       pm_PeProdEmifac(regi,"pebiolc","n2obio") = 0.0079 / sm_EJ_2_TWa;
$if %cm_LU_emi_scen% == "SSP2_lowEn" pm_PeProdEmifac(regi,"pebiolc","n2obio") = 0.0079 / sm_EJ_2_TWa;
$if %cm_LU_emi_scen% == "SSP3"       pm_PeProdEmifac(regi,"pebiolc","n2obio") = 0.0079 / sm_EJ_2_TWa;
$if %cm_LU_emi_scen% == "SSP5"       pm_PeProdEmifac(regi,"pebiolc","n2obio") = 0.0066 / sm_EJ_2_TWa;
$if %cm_LU_emi_scen% == "SDP"        pm_PeProdEmifac(regi,"pebiolc","n2obio") = 0.0047 / sm_EJ_2_TWa;



*** ==================================================================
*** ==================================================================
*' ### Non-CO2 emissions plus LUC MACCs
*** ==================================================================
*** ==================================================================

*' Read-in and preparation of data for all emissions that are not CO2 from energy and industry:
*' marginal abatement cost curves (MACCs) of non-CO2 gases and land-use change (LUC) CO2 (usually unused),
*' their baseline emissions, historical emissions used for calibration, and F-gas emissions.

***   1. Read MACC parameters, unit conversions and MAC availability switches.
***   2. Read baseline emissions of the sources that are subject to MACCs
***      (waste, industry-related N2O, land use from exogenous data and MAgPIE).
***   3. Read historical emissions used to calibrate the MAC baselines.
***   4. Read F-gas emissions.
***   5. Load MAC costs from the reference run.


*** ==================================================================
*' #### 1. Marginal abatement cost curves (MACCs), unit conversions and MAC switches
*** ==================================================================

* GA Read choice of non-CO2 MACs version
* PBL_2007 is based on Lucas et al. (2007), and abatement is relative to that study's IMAGE baseline scenario emissions, asssumed relative to ours here
* PBL_2022 is based on van Harmsen et al. (2022), and abatement is relative to that study's IMAGE SSP2 baseline scenario emissions, asssumed relative to ours here
$IFTHEN.MaccVersion %cm_nonco2_macc_version% == "PBL_2007"
* PBL_2007 MACs are discretized in steps of 5 $/tC
sm_dmac = 5 ;
parameter p10_abatparam_CH4(tall,all_regi,all_enty,steps)        "MAC costs for CH4 by source"
/
$ondelim
$include "./modules/10_emissions/SectorAggregates/input/p_abatparam_CH4.cs4r"
$offdelim
/;
parameter p10_abatparam_N2O(tall,all_regi,all_enty,steps)        "MAC costs for N2O by source"
/
$ondelim
$include "./modules/10_emissions/SectorAggregates/input/p_abatparam_N2O.cs4r"
$offdelim
/;
$ELSEIF.MaccVersion %cm_nonco2_macc_version% == "PBL_2022"
*** PBL_2022 MACs are discretized in steps of 20 $/tC
*** PBL_2022 includes three scenarios, read the big file into p10_all_abatparam_CH4 and subset based on c_nonco2_macc_scenario
*** Create the set here, as it's not really used anywhere else
set macc_scens "MAC scenarios for PBL_SSP2_2022 MACCs" /Default, Optimistic, Pessimistic/;
parameter p10_all_abatparam_CH4(tall,all_regi,all_enty,macc_scens,steps)        "MAC costs for CH4 by source for different scenarios, c_nonco2_macc_scenario is chosen for p10_abatparam_CH4"
/
$ondelim
$include "./modules/10_emissions/SectorAggregates/input/p_abatparam_SSP22022_CH4.cs4r"
$offdelim
/;
parameter p10_abatparam_CH4(tall,all_regi,all_enty,steps) "MAC costs for CH4 by source";
*** Pick MACC scenario
p10_abatparam_CH4(tall,all_regi,all_enty,steps) = p10_all_abatparam_CH4(tall,all_regi,all_enty,"%c_nonco2_macc_scenario%",steps)
parameter p10_all_abatparam_N2O(tall,all_regi,all_enty,macc_scens,steps)        "MAC costs for N2O by source for different scenarios, c_nonco2_macc_scenario is chosen for p10_abatparam_N2O"
/
$ondelim
$include "./modules/10_emissions/SectorAggregates/input/p_abatparam_SSP22022_N2O.cs4r"
$offdelim
/;
parameter p10_abatparam_N2O(tall,all_regi,all_enty,steps) "MAC costs for N2O by source";
*** Pick MACC scenario
p10_abatparam_N2O(tall,all_regi,all_enty,steps) = p10_all_abatparam_N2O(tall,all_regi,all_enty,"%c_nonco2_macc_scenario%",steps)
$ENDIF.MaccVersion
;

parameter p10_abatparam_CO2(tall,all_enty,steps)    "MAC costs for CO2 by source"
/
$ondelim
$include "./modules/10_emissions/SectorAggregates/input/p_abatparam_CO2.cs4r"
$offdelim
/;
p10_abatparam_CH4(tall,all_regi,all_enty,steps)$(ord(steps) gt 201) = p10_abatparam_CH4(tall,all_regi,all_enty,"201");
p10_abatparam_N2O(tall,all_regi,all_enty,steps)$(ord(steps) gt 201) = p10_abatparam_N2O(tall,all_regi,all_enty,"201");

*** Unit conversions
p10_emi_quan_conv_ar4(enty) = 1;
p10_emi_quan_conv_ar4(enty)$(emiMacMagpieCH4(enty)) = sm_tgch4_2_pgc * (25/s_gwpCH4);  !! need to use old GWP for MAC cost conversion as it only reverts what has been done in the calculation of the MACs
p10_emi_quan_conv_ar4(enty)$(emiMacMagpieN2O(enty)) = sm_tgn_2_pgc * (298/s_gwpN2O);
p10_emi_quan_conv_ar4(enty)$(emiMacExoCH4(enty)) = sm_tgch4_2_pgc * (25/s_gwpCH4);
p10_emi_quan_conv_ar4(enty)$(emiMacExoN2O(enty)) = sm_tgn_2_pgc * (298/s_gwpN2O);
p10_emi_quan_conv_ar4("ch4coal")    = sm_tgch4_2_pgc * (25/s_gwpCH4);
p10_emi_quan_conv_ar4("ch4gas")     = sm_tgch4_2_pgc * (25/s_gwpCH4);
p10_emi_quan_conv_ar4("ch4oil")     = sm_tgch4_2_pgc * (25/s_gwpCH4);
p10_emi_quan_conv_ar4("ch4wstl")    = sm_tgch4_2_pgc * (25/s_gwpCH4);
p10_emi_quan_conv_ar4("ch4wsts")    = sm_tgch4_2_pgc * (25/s_gwpCH4);
p10_emi_quan_conv_ar4("n2otrans")   = sm_tgn_2_pgc * (298/s_gwpN2O);
p10_emi_quan_conv_ar4("n2oadac")    = sm_tgn_2_pgc * (298/s_gwpN2O);
p10_emi_quan_conv_ar4("n2onitac")   = sm_tgn_2_pgc * (298/s_gwpN2O);
p10_emi_quan_conv_ar4("n2owaste")   = sm_tgn_2_pgc * (298/s_gwpN2O);

***------------------------------------------------------------------------------------
***                                Turning MACs on/off
***------------------------------------------------------------------------------------
*** Turn MACs on/off for different scenarios. The default is to have all MACs on 
*** (except for co2luc and n2ofertsom, which are always off).,
*** but some scenarios may turn off certain MACs. Currently setting to 2
*** turns everything but waste MACs off, while setting to 1 turns everything on.
*** GA: This 2 setting is a leftover from the SSP-RCP scenarios but still useful to keep.
if(cm_macscen eq 2,
  pm_macSwitch(ttot,regi,emiMacSector)  = 0;
);
  pm_macSwitch(ttot,regi,"ch4wstl") = 1;
  pm_macSwitch(ttot,regi,"ch4wsts") = 1;
if(cm_macscen eq 1,
  pm_macSwitch(ttot,regi,emiMacSector) = 1;
);

*** As long as there is hardly any CO2 LUC reduction in MAgPIE we dont need MACs in REMIND
pm_macSwitch(ttot,regi,"co2luc") = 0;
*** The tiny fraction n2ofertsom of total land use n2o can get slightly negative in some cases. Ignore MAC for n2ofertsom by default.
pm_macSwitch(ttot,regi,"n2ofertsom") = 0;


* GA: Deactivate MAC abatement for historical periods, assuming no abatement happens until 2030
pm_macSwitch(ttot,regi,emiMacSector)$(ttot.val le 2025) = 0;


*** ==================================================================
*' #### 2. Baseline emissions of sources subject to MACCs
*** ==================================================================

*** load econometric emission data
*** read in p3 and p4
parameter p10_emineg_econometric(all_regi,all_enty,p)        "parameters for ch4 and n2o emissions from waste baseline and co2 emissions from cement production"
;
p10_emineg_econometric(regi,enty,"p1") = 0;
p10_emineg_econometric(regi,enty,"p2") = 0;
*** p2 is calculated in presolve

parameter p10_macBase2005(all_regi,all_enty)        "baseline emissions of mac options in 2005"
/
$ondelim
$include "./modules/10_emissions/SectorAggregates/input/p_macBase2005.cs4r"
$offdelim
/;
parameter p10_macBase1990(all_regi,all_enty)     "baseline emissions of mac options in 1990"
/
$ondelim
$include "./modules/10_emissions/SectorAggregates/input/p_macBase1990.cs4r"
$offdelim
/;
parameter p10_macBaseCEDS2005(all_regi,all_enty)        "baseline emissions of mac options in 2005 from CEDS"
/
$ondelim
$include "./modules/10_emissions/SectorAggregates/input/p_macBaseCEDS2005.cs4r"
$offdelim
/;
parameter p10_macBaseCEDS2020(all_regi,all_enty)        "baseline emissions of mac options in 2020"
/
$ondelim
$include "./modules/10_emissions/SectorAggregates/input/p_macBaseCEDS2020.cs4r"
$offdelim
/;
parameter p10_macBaseIMAGE(tall,all_regi,all_enty)        "baseline emissions of N2O from transport, adipic acid production, and nitric acid production based on data from van Vuuren"
/
$ondelim
$ifthen %cm_emifacs_baseyear% == "2005" 
$include "./modules/10_emissions/SectorAggregates/input/p_macBaseVanv.cs4r"
$else
$include "./modules/10_emissions/SectorAggregates/input/p_macBaseHarmsen2022.cs4r"
$endif
$offdelim
/;

parameter f10_macBaseExo(tall,all_regi,all_enty,all_LU_emi_scen)        "baseline emissions of N2O and CH4 from landuse based on exogenous data"
/
$ondelim
$include "./modules/10_emissions/SectorAggregates/input/f_macBaseExo.cs4r"
$offdelim
/;
p10_macBaseExo(ttot,regi,emiMacExo(enty))$(ttot.val ge 2005) = f10_macBaseExo(ttot,regi,emiMacExo,"%cm_LU_emi_scen%");


parameter f10_macBaseMagpie(tall,all_regi,all_enty,all_LU_emi_scen,all_rcp_scen)    "baseline emissions of N2O and CH4 from landuse based on data from Magpie"
/
$ondelim
$include "./modules/10_emissions/SectorAggregates/input/f_macBaseMagpie.cs4r"
$offdelim
/;
pm_macBaseMagpie(ttot,regi,emiMacMagpie(enty))$(ttot.val ge 2005) = f10_macBaseMagpie(ttot,regi,emiMacMagpie,"%cm_LU_emi_scen%","%cm_rcp_scen%");

*** pm_macBaseMagpie gets updated in modules/10_emissions/SectorAggregates/presolve.gms when coupling to MAgPIE is active

*** In case of fixing, load p_co2lucSub from input_ref.gdx, since parameters are not automatically treated by the fixing mechanism.
*** Years >= cm_startyear get their values from the lookup table rather than the input_ref.gdx (see below).
if( (cm_startyear gt 2005),
    Execute_Loadpoint "input_ref" p_co2lucSub = p_co2lucSub;
);


*** Overwrite values >= cm_startyear with lookup table, leave values < cm_startyear untouched (from input_ref.gdx, see above).
*** Gets updated for >= cm_startyear in modules/10_emissions/SectorAggregates/presolve.gms when coupling to MAgPIE is active.
p_co2lucSub(ttot,regi,emiMacMagpieCO2Sub(all_enty))$(ttot.val ge cm_startyear) = f10_macBaseMagpie(ttot,regi,emiMacMagpieCO2Sub,"%cm_LU_emi_scen%","%cm_rcp_scen%");

*** p10_macPolCO2luc defines the lower limit for abatement of CO2 landuse change emissions in REMIND
*** The values are derived from MAgPIE runs with very strong mitigation
parameter p10_macPolCO2luc(tall,all_regi)                "co2 emissions from landuse change with strong mitigation in MAgPIE"
/
$ondelim
$include "./modules/10_emissions/SectorAggregates/input/p_macPolCO2luc.cs4r"
$offdelim
/;


*** ==================================================================
*' #### 3. Historical emissions for calibration of MAC baselines
*** ==================================================================

*** Read in mac historical emissions to calibrate MAC reference emissions
parameter p10_histEmiMac(tall,all_regi,all_enty)    "historical emissions per MAC"
/
$ondelim
$include "./modules/10_emissions/SectorAggregates/input/p_histEmiMac.cs4r"
$offdelim
/;
*** Read in historical emissions per sector to calibrate MAC reference emissions
parameter p10_histEmiSector(tall,all_regi,all_enty,emi_sectors,sector_types)    "historical emissions per sector"
/
$ondelim
$include "./modules/10_emissions/SectorAggregates/input/p_histEmiSector.cs4r"
$offdelim
/;


*** ==================================================================
*' #### 4. F-gases
*** ==================================================================

*** read in F-Gas emissions
parameter f10_emiFgas(tall,all_regi,all_SSP_forcing_adjust,all_rcp_scen,all_delayPolicy,all_enty)        "F-gas emissions by single gases from IMAGE"
/
$ondelim
$include "./modules/10_emissions/SectorAggregates/input/f_emiFgas.cs4r"
$offdelim
/;


*** ==================================================================
*' #### 5. MAC costs from the reference run
*** ==================================================================

if (cm_startyear gt 2005,
*' load MAC costs from reference gdx. Values for t (i.e. after cm_start_year) will be overwritten in modules/10_emissions/SectorAggregates/presolve.gms 
execute_load "input_ref.gdx" pm_macCost;
);

*** EOF ./modules/10_emissions/SectorAggregates/datainput.gms
