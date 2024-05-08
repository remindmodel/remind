*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/21_tax/on/datainput.gms
***        *CB* Final energy taxes, subsidies and inconvinience costs
***---------------------------------------------------------------------

***gl 20110817 load paths for final energy taxes, subsidies and inconvenience costs (read in in  $/GJ, get rescaled further down to trillion $ / TWa, subsidies also get constrained to avoid negative prices(in preloop.gms))
Parameter f21_tau_fe_tax(tall,all_regi,emi_sectors,all_enty) "2005 final energy tax"
  /
$ondelim
$include "./modules/21_tax/on/input/f21_tau_fe_tax.cs4r"
$offdelim
  /
;
Parameter f21_tau_fe_sub(tall,all_regi,emi_sectors,all_enty) "2005 final energy subsidy"
  /
$ondelim
$include "./modules/21_tax/on/input/f21_tau_fe_sub.cs4r"
$offdelim
  /
;
Parameter f21_tau_fuEx_sub(tall,all_regi,all_enty) "2005 subsidy for fuel extraction"
  /
$ondelim
$include "./modules/21_tax/on/input/f21_tau_pe_sub.cs4r"
$offdelim
  /
;
Parameter f21_tax_convergence(tall,all_regi,all_enty) "Tax convergence level for specific regions, year and final energy type"
  /
$ondelim
$include "./modules/21_tax/on/input/f21_tax_convergence.cs4r"
$offdelim
  /
;
Parameter f21_max_fe_sub(tall,all_regi,all_enty) "maximum final energy subsidy levels (in $/Gj) from REMIND version prior to rev. 5429"
  /
$ondelim
$include "./modules/21_tax/on/input/f21_max_fe_sub.cs4r"
$offdelim
  /
;
Parameter f21_max_pe_sub(tall,all_regi,all_enty) "maximum primary energy subsidy levels (in $/Gj) to provide plausible upper bound: 40$/barrel ~ 8 $/GJ" 
  /
$ondelim
$include "./modules/21_tax/on/input/f21_max_pe_sub.cs4r"
$offdelim
  /
;
Parameter f21_prop_fe_sub(tall,all_regi,all_enty) "subsidy proportional cap to avoid liquids increasing dramatically"
  /
$ondelim
$include "./modules/21_tax/on/input/f21_prop_fe_sub.cs4r"
$offdelim
  /
;

*** transfer data to parameters and rescaling of FE parameters from $/GJ to trillion $ / TWa (subsidies also get adjusted in preloop.gms to avoid neg. prices)

  p21_tau_fe_tax(ttot,all_regi,emi_sectors,entyFe)$f21_tau_fe_tax(ttot,all_regi,emi_sectors,entyFe) = f21_tau_fe_tax(ttot,all_regi,emi_sectors,entyFe)*0.001/sm_EJ_2_TWa;
  p21_tau_fe_sub(ttot,all_regi,emi_sectors,entyFe)$f21_tau_fe_sub(ttot,all_regi,emi_sectors,entyFe) = f21_tau_fe_sub(ttot,all_regi,emi_sectors,entyFe)*0.001/sm_EJ_2_TWa;
  p21_tau_fuEx_sub(ttot,regi,entyPe)$f21_tau_fuEx_sub(ttot,regi,entyPe) = f21_tau_fuEx_sub(ttot,regi,entyPe)*0.001/sm_EJ_2_TWa;

  p21_max_fe_sub(ttot,all_regi,entyFe)$f21_max_fe_sub(ttot,all_regi,entyFe) = f21_max_fe_sub(ttot,all_regi,entyFe)*0.001/sm_EJ_2_TWa;
  p21_prop_fe_sub(ttot,all_regi,entyFe)$f21_prop_fe_sub(ttot,all_regi,entyFe) = f21_prop_fe_sub(ttot,all_regi,entyFe);

if(cm_fetaxscen eq 0,
  p21_tau_fe_tax(ttot,all_regi,emi_sectors,entyFe) = 0;
  p21_tau_fe_sub(ttot,all_regi,emi_sectors,entyFe) = 0;
  p21_tau_fuEx_sub(ttot,regi,all_enty) = 0;
);

*** -------------------------PE2SE Taxes--------------------------(Primary to secondary energy technology taxes, specified by technology)
*** cb 20110923 load paths for technology taxes, subsidies and inconvenience costs 
p21_tau_pe2se_tax(tall,regi,te) = 0;
p21_tau_pe2se_inconv(tall,regi,te) = 0;
p21_tau_pe2se_sub(tall,regi,te)= 0;

*RP* FILE changed by hand after introduction of SO2 taxes and inconvenience penalties on 2012-03-08
*GL* Values try to account for excessive water use, further pollution
*GL* Taxes are given in USD(2005) per GJ 
p21_tau_pe2se_tax(ttot,regi,"igcc")$(ttot.val ge 2005)       = 0.25;
p21_tau_pe2se_tax(ttot,regi,"igccc")$(ttot.val ge 2005)      = 0.25;
p21_tau_pe2se_tax(ttot,regi,"coalftrec")$(ttot.val ge 2005)  = 1.0;
p21_tau_pe2se_tax(ttot,regi,"coalftcrec")$(ttot.val ge 2005) = 1.0;
p21_tau_pe2se_tax(ttot,regi,"coalh2")$(ttot.val ge 2005)     = 0.5;
p21_tau_pe2se_tax(ttot,regi,"coalh2c")$(ttot.val ge 2005)    = 0.5;
p21_tau_pe2se_tax(ttot,regi,"coalgas")$(ttot.val ge 2005)    = 0.5;

***JaS* Introduces inconvenience costs as taxes for the transformation of primary to secondary energy types
***JaS* Taxes are given in USD(2005) per GJ 
*cb* to be exchanged for file with values if needed 
p21_tau_pe2se_inconv(ttot,regi,te)$(ttot.val ge 2005)=0.000000;
*** description: Taxes/subsidies are given in USD(2005) per GJ
*** unit: USD(2005) per GJ
p21_tau_pe2se_inconv(ttot,regi,te)$(ttot.val ge 2005)=0.000000;


***cb20110923 rescaling of PE2SE parameters from $/GJ to trillion $ / TWa 
p21_tau_pe2se_tax(ttot,regi,te)$(ttot.val ge 2005)    = p21_tau_pe2se_tax(ttot,regi,te)    * 0.001 / sm_EJ_2_TWa;
p21_tau_pe2se_sub(ttot,regi,te)$(ttot.val ge 2005)    = p21_tau_pe2se_sub(ttot,regi,te)    * 0.001 / sm_EJ_2_TWa;
p21_tau_pe2se_inconv(ttot,regi,te)$(ttot.val ge 2005) = p21_tau_pe2se_inconv(ttot,regi,te) * 0.001 / sm_EJ_2_TWa;

***cb 20110923 load paths for ressource export taxes
***cb* file for resource export taxes, not used in default settings
Parameter p21_tau_xpres_tax(tall,all_regi,all_enty) "tax path for ressource export"
  /
$ondelim
$include "./modules/21_tax/on/input/p21_tau_xpres_tax.cs4r"
$offdelim
  / ;
*** converted to T$/TWyr   
p21_tau_xpres_tax(ttot,regi,"peoil")$(ttot.val ge 2005) = p21_tau_xpres_tax(ttot,regi,"peoil") * sm_DpGJ_2_TDpTWa;
*LB* use 0 for all regions as default
p21_tau_xpres_tax(ttot,regi,all_enty) = 0;

*JeS for SO2 tax case: tax path in 10^12$/TgS (= 10^6 $/t S) @ GDP/cap of 1000$/cap  (value gets scaled by GDP/cap)
if((cm_so2tax_scen eq 0),
s21_so2_tax_2010=0.0;
elseif(cm_so2tax_scen eq 1),
s21_so2_tax_2010=0.00006;   !! This tax level leads to 600$/t S  @10,000$/cap
elseif(cm_so2tax_scen eq 2),
s21_so2_tax_2010=0.00025;  !! This tax level leads to 2500$/t S  @10,000$/cap
elseif(cm_so2tax_scen eq 3),
s21_so2_tax_2010=0.0006;   !! This tax level leads to 6000$/t S  @10,000$/cap
elseif(cm_so2tax_scen eq 4),
s21_so2_tax_2010=0.000144;
);

*** Implicit discount rates mark-ups over the normal discount rate
if ((cm_DiscRateScen eq 0),
p21_implicitDiscRateMarg(ttot,regi,all_in) = 0;
 elseif (cm_DiscRateScen eq 1),
 p21_implicitDiscRateMarg(ttot,regi,all_in) = 0;
 p21_implicitDiscRateMarg(ttot,regi,"kaphc") = 0.05;  !! 5% for the efficiency capital for the building shell
 p21_implicitDiscRateMarg(ttot,regi,"kapsc") = 0.05;  !! 5% for the efficiency capital for the air conditioning
 p21_implicitDiscRateMarg(ttot,regi,"kapal") = 0.20;  !! 20% for the efficiency capital for appliances
 elseif (cm_DiscRateScen eq 2),
 p21_implicitDiscRateMarg(ttot,regi,all_in) = 0;
 p21_implicitDiscRateMarg(ttot,regi,"kaphc")$(ttot.val ge 2005 AND ttot.val lt cm_startyear) = 0.05;  !! 5% for the efficiency capital for the building shell
 p21_implicitDiscRateMarg(ttot,regi,"kapsc")$(ttot.val ge 2005 AND ttot.val lt cm_startyear) = 0.05;  !! 5% for the efficiency capital for the air conditioning
 p21_implicitDiscRateMarg(ttot,regi,"kapal")$(ttot.val ge 2005 AND ttot.val lt cm_startyear) = 0.20;  !! 20% for the efficiency capital for appliances
 elseif (cm_DiscRateScen eq 3),
 p21_implicitDiscRateMarg(ttot,regi,all_in) = 0;
 
 p21_implicitDiscRateMarg(ttot,regi,"kaphc") = 0.05;  !! 5% for the efficiency capital for the building shell
 p21_implicitDiscRateMarg(ttot,regi,"kapsc") = 0.05;  !! 5% for the efficiency capital for the air conditioning
 p21_implicitDiscRateMarg(ttot,regi,"kapal") = 0.20;  !! 20% for the efficiency capital for appliances

 p21_implicitDiscRateMarg(ttot,regi,in)$(pm_ttot_val(ttot) ge cm_startyear 
                                         AND (sameAs(in,"kaphc") 
                                              OR sameAs(in,"kapsc") 
                                              OR sameAs(in,"kapal")
                                              )
                                        )
                        = 0.25 * p21_implicitDiscRateMarg(ttot,regi,in);
 
elseif (cm_DiscRateScen eq 4),
 p21_implicitDiscRateMarg(ttot,regi,all_in) = 0;
 
 p21_implicitDiscRateMarg(ttot,regi,"kaphc") = 0.05;  !! 5% for the efficiency capital for the building shell
 p21_implicitDiscRateMarg(ttot,regi,"kapsc") = 0.05;  !! 5% for the efficiency capital for the air conditioning
 p21_implicitDiscRateMarg(ttot,regi,"kapal") = 0.20;  !! 20% for the efficiency capital for appliances

 p21_implicitDiscRateMarg(ttot,regi,"kaphc") = min(max((2030 - pm_ttot_val(ttot))/(2030 -2020),0),1)    !! lambda = 1 in 2020 and 0 in 2030; 
                                               *  0.75 * p21_implicitDiscRateMarg(ttot,regi,"kaphc")
                                               +  0.25 * p21_implicitDiscRateMarg(ttot,regi,"kaphc");   !! Reduction of 75% of the Efficiency gap
 p21_implicitDiscRateMarg(ttot,regi,"kapsc") = min(max((2030 - pm_ttot_val(ttot))/(2030 -2020),0),1)    !! lambda = 1 in 2020 and 0 in 2030; 
                                               *  0.75 * p21_implicitDiscRateMarg(ttot,regi,"kapsc")
                                               +  0.25 * p21_implicitDiscRateMarg(ttot,regi,"kapsc");   !! Reduction of 75% of the Efficiency gap
  p21_implicitDiscRateMarg(ttot,regi,"kapal") = min(max((2030 - pm_ttot_val(ttot))/(2030 -2020),0),1)    !! lambda = 1 in 2020 and 0 in 2030; 
                                               *  0.75 * p21_implicitDiscRateMarg(ttot,regi,"kapal")
                                               +  0.25 * p21_implicitDiscRateMarg(ttot,regi,"kapal");   !! Reduction of 75% of the Efficiency gap
);


*** FS: import tax level
*** works only on PEs at the moment as implementation requires pm_pvp
*** which is only available for the commodities of the nash markets
*** zero by default
p21_tau_Import(t,regi,tradePe,tax_import_type_21) = 0;
*** read in import tax values from switch cm_import_tax
$ifThen.import not "%cm_import_tax%" == "off" 
loop((ext_regi,tradePe,tax_import_type_21)$(p21_import_tax(ext_regi,tradePe,tax_import_type_21)),
  loop(regi$regi_groupExt(ext_regi,regi),
    p21_tau_Import(t,regi,tradePe,tax_import_type_21) =  p21_import_tax(ext_regi,tradePe,tax_import_type_21)
  );
);
$endif.import
display p21_tau_Import;


*** sector-specific CO2 tax markup. Loop over ext_regi to set GLO values to individual countries etc.
$ifThen.cm_CO2TaxSectorMarkup not "%cm_CO2TaxSectorMarkup%" == "off"
Parameter
  p21_extRegiCO2TaxSectorMarkup(ext_regi,emi_sectors) "CO2 tax markup in building, industry or transport sector (extended regions)" / %cm_CO2TaxSectorMarkup% /
;
  loop((ext_regi,emi_sectors)$p21_extRegiCO2TaxSectorMarkup(ext_regi,emi_sectors),
    p21_CO2TaxSectorMarkup(ttot,regi,emi_sectors)$(regi_group(ext_regi,regi) AND ttot.val ge cm_startyear) = p21_extRegiCO2TaxSectorMarkup(ext_regi,emi_sectors);
  );
$else.cm_CO2TaxSectorMarkup
  p21_CO2TaxSectorMarkup(ttot,regi,emi_sectors)$(ttot.val ge cm_startyear) = 0;
;
$endIf.cm_CO2TaxSectorMarkup

*** by default PE tax is zero
pm_tau_pe_tax(ttot,regi,all_enty) = 0;

*** by default CES tax is zero
pm_tau_ces_tax(ttot,regi,all_in) = 0;


*** Read in bioenergy emission factor that is used to compute the emission-
*** factor-based bioenergy tax and convert from kgCO2 per GJ to GtC per TWa.
p21_bio_EF(ttot,all_regi) = 0;
p21_bio_EF(ttot,regi_bio_EFTax21) = cm_bioenergy_EF_for_tax * (1/1000 * 12/44) / (sm_EJ_2_TWa);

*** Read in direct investments into renewables from reference scenario
$ifthen.importtaxrc %cm_taxrc_RE% == "REdirect"
Execute_Loadpoint 'input_ref' p21_ref_costInvTeDir_RE = vm_costInvTeDir.l;
Execute_Loadpoint 'input_ref' p21_ref_costInvTeAdj_RE = vm_costInvTeAdj.l;
$endif.importtaxrc

if (cm_startyear gt 2005,
execute_load "input_ref.gdx", pm_taxrevCO2LUC0;
execute_load "input_ref.gdx", pm_taxrevGHG0;
);

*** EOF ./modules/21_tax/on/datainput.gms
