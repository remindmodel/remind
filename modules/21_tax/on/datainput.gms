*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
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
Parameter f21_tax_convergence_rollback(tall,all_regi,all_enty) "Tax convergence level for specific regions, year and final energy type"
  /
$ondelim
$include "./modules/21_tax/on/input/f21_tax_convergence_rollback.cs4r"
$offdelim
  /
;
if(cm_fetaxscen eq 5,
f21_tax_convergence(ttot,regi,enty) = f21_tax_convergence_rollback(ttot,regi,enty);
);

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
p21_tau_pe2se_sub(tall,regi,te)= 0;

*RP* FILE changed by hand after introduction of SO2 taxes and inconvenience penalties on 2012-03-08
*** Values try to account for excessive water use, further pollution
*** Taxes are given in USD(2005) and converted to USD(2017) per GJ 
if(cm_fetaxscen ne 5,
p21_tau_pe2se_tax(ttot,regi,"igcc")$(ttot.val ge 2005)       = sm_D2005_2_D2017 * 0.25;
p21_tau_pe2se_tax(ttot,regi,"igccc")$(ttot.val ge 2005)      = sm_D2005_2_D2017 * 0.25;
p21_tau_pe2se_tax(ttot,regi,"coalftrec")$(ttot.val ge 2005)  = sm_D2005_2_D2017 * 1.0;
p21_tau_pe2se_tax(ttot,regi,"coalftcrec")$(ttot.val ge 2005) = sm_D2005_2_D2017 * 1.0;
p21_tau_pe2se_tax(ttot,regi,"coalh2")$(ttot.val ge 2005)     = sm_D2005_2_D2017 * 0.5;
p21_tau_pe2se_tax(ttot,regi,"coalh2c")$(ttot.val ge 2005)    = sm_D2005_2_D2017 * 0.5;
p21_tau_pe2se_tax(ttot,regi,"coalgas")$(ttot.val ge 2005)    = sm_D2005_2_D2017 * 0.5;
);
***cb20110923 rescaling of PE2SE parameters from $/GJ to trillion $ / TWa 
p21_tau_pe2se_tax(ttot,regi,te)$(ttot.val ge 2005)    = p21_tau_pe2se_tax(ttot,regi,te)    * 0.001 / sm_EJ_2_TWa;
p21_tau_pe2se_sub(ttot,regi,te)$(ttot.val ge 2005)    = p21_tau_pe2se_sub(ttot,regi,te)    * 0.001 / sm_EJ_2_TWa;

*** SE electricity tax rate tech specific ramp up logistic function parameters
p21_tau_SE_tax_rampup(t,regi,te,teSeTax_coeff) = 0;
$ifThen.SEtaxRampUpParam not "%cm_SEtaxRampUpParam%" == "off" 
  loop((ext_regi,te,teSeTax_coeff)$p21_SEtaxRampUpParameters(ext_regi,te,teSeTax_coeff),
    loop(regi$regi_groupExt(ext_regi,regi),
      p21_tau_SE_tax_rampup(t,regi,te,teSeTax_coeff) = p21_SEtaxRampUpParameters(ext_regi,te,teSeTax_coeff);
    );
  );
$endif.SEtaxRampUpParam

***JeS for SO2 tax case: tax path in 10^12$/TgS (= 10^6 $/t S) @ GDP/cap of 1000$/cap  (value gets scaled by GDP/cap)
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
