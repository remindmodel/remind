*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/21_tax/on/datainput.gms
***        *CB* Final energy taxes, subsidies and inconvinience costs
***---------------------------------------------------------------------

***gl 20110817 load paths for final energy taxes, subsidies and inconvenience costs (read in in  $/GJ, get rescaled further down to trillion $ / TWa, subsidies also get constrained to avoid negative prices(in preloop.gms))
Parameter f21_tau_fe_tax_transport(tall,all_regi,all_enty) "2005 tax for transport final energy"
  /
$ondelim
$include "./modules/21_tax/on/input/f21_tau_fe_tax_transport.cs4r"
$offdelim
  /             ;
Parameter f21_tau_fe_sub_transport(tall,all_regi,all_enty) "2005 subsidy for transport final energy"
  /
$ondelim
$include "./modules/21_tax/on/input/f21_tau_fe_sub_transport.cs4r"
$offdelim
  /             ;
  
Parameter f21_tau_fe_tax_bit_st(tall,all_regi,all_in) "2005 tax for stationary/buildings_industry final energy"
  /
$ondelim
$include "./modules/21_tax/on/input/f21_tau_fe_tax_bit_st.cs4r"
$offdelim
  /             ;
Parameter f21_tau_fe_sub_bit_st(tall,all_regi,all_in) "2005 subsidy for stationary/buildings_industry final energy"
  /
$ondelim
$include "./modules/21_tax/on/input/f21_tau_fe_sub_bit_st.cs4r"
$offdelim
  /             ;
  
Parameter p21_tau_fuEx_sub(tall,all_regi,all_enty) "2005 subsidy for fuel extraction"
  /
$ondelim
$include "./modules/21_tax/on/input/p21_tau_fuEx_sub.cs4r"
$offdelim
  /             ;

Parameter f21_tax_convergence(tall,all_regi,all_enty) "Tax convergence level for specific regions, year and final energy type"
  /
$ondelim
$include "./modules/21_tax/on/input/f21_tax_convergence.cs4r"
$offdelim
  /             ;
 
Parameter f21_max_fe_sub(tall,all_regi,all_in) "maximum final energy subsidy levels (in $/Gj) from REMIND version prior to rev. 5429"
  /
$ondelim
$include "./modules/21_tax/on/input/f21_max_fe_sub.cs4r"
$offdelim
  /             ;

Parameter f21_max_pe_sub(tall,all_regi,all_enty) "maximum primary energy subsidy levels (in $/Gj) to provide plausible upper bound: 40$/barrel ~ 8 $/GJ" 
  /
$ondelim
$include "./modules/21_tax/on/input/f21_max_pe_sub.cs4r"
$offdelim
  /             ;

Parameter f21_prop_fe_sub(tall,all_regi,all_in) "subsidy proportional cap to avoid liquids increasing dramatically"
  /
$ondelim
$include "./modules/21_tax/on/input/f21_prop_fe_sub.cs4r"
$offdelim
  /             ;  
  

  
*** transfer data to parameters only for the relevant items. Pathway II
  p21_tau_fe_tax_transport(ttot,all_regi,feForUe) = f21_tau_fe_tax_transport(ttot,all_regi,feForUe);
  p21_tau_fe_sub_transport(ttot,all_regi,feForUe) = f21_tau_fe_sub_transport(ttot,all_regi,feForUe);
  

  p21_tau_fe_tax_transport(ttot,all_regi,feForEs) = f21_tau_fe_tax_transport(ttot,all_regi,feForEs);
  p21_tau_fe_sub_transport(ttot,all_regi,feForEs) = f21_tau_fe_sub_transport(ttot,all_regi,feForEs);

  p21_tau_fe_tax_transport(ttot,all_regi,"fegat") = p21_tau_fe_tax_transport(ttot,all_regi,"fedie");
  p21_tau_fe_sub_transport(ttot,all_regi,"fegat") = p21_tau_fe_sub_transport(ttot,all_regi,"fedie");

loop ( fe_tax_sub_sbi(all_in, in), !! Pathways I from FE to the CES
  p21_tau_fe_tax_bit_st(ttot,all_regi,in) = f21_tau_fe_tax_bit_st(ttot,all_regi,all_in);   !! ppfen in stationary/buildings_industry : all but transport ppfen
  p21_tau_fe_sub_bit_st(ttot,all_regi,in) = f21_tau_fe_sub_bit_st(ttot,all_regi,all_in);   !! ppfen in stationary/buildings_industry : all but transport ppfen
  p21_max_fe_sub(ttot,all_regi,in) = f21_max_fe_sub(ttot,all_regi,all_in) ;
  p21_prop_fe_sub(ttot,all_regi,in) = f21_prop_fe_sub(ttot,all_regi,all_in) ;
);  

loop ( fe_tax_subEs(all_in, esty), !! Pathways III from FE to the CES, via the ES layer
  pm_tau_fe_tax_ES_st(ttot,all_regi,esty) = f21_tau_fe_tax_bit_st(ttot,all_regi,all_in);   !! ppfen in stationary/buildings_industry : all but transport ppfen
  pm_tau_fe_sub_ES_st(ttot,all_regi,esty) = f21_tau_fe_sub_bit_st(ttot,all_regi,all_in);   !! ppfen in stationary/buildings_industry : all but transport ppfen
  p21_max_fe_subEs(ttot,all_regi,esty) = f21_max_fe_sub(ttot,all_regi,all_in) ;
  p21_prop_fe_subEs(ttot,all_regi,esty) = f21_prop_fe_sub(ttot,all_regi,all_in) ;
);  

if(cm_fetaxscen eq 0,
p21_tau_fe_tax_transport(ttot,regi,all_enty)     = 0;
p21_tau_fe_sub_transport(ttot,regi,all_enty)     = 0;
p21_tau_fe_tax_bit_st(ttot,regi,all_in)          = 0; 
p21_tau_fe_sub_bit_st(ttot,regi,all_in)          = 0;
pm_tau_fe_tax_ES_st(ttot,regi,all_esty)          = 0; 
pm_tau_fe_sub_ES_st(ttot,regi,all_esty)          = 0;
p21_tau_fuEx_sub(ttot,regi,all_enty)               = 0;
);


if(cm_fetaxscen ne 0,
***cb20110923 rescaling of FE parameters from $/GJ to trillion $ / TWa (subsidies also get adjusted in preloop.gms to avoid neg. prices)
p21_tau_fe_tax_transport(ttot,regi,entyFE)     = p21_tau_fe_tax_transport(ttot,regi,entyFE)*0.001/sm_EJ_2_TWa; 
p21_tau_fe_sub_transport(ttot,regi,entyFE)     = p21_tau_fe_sub_transport(ttot,regi,entyFE)*0.001/sm_EJ_2_TWa;!!(subsidies also get adjusted in preloop.gms to avoid neg. prices)
p21_tau_fe_tax_bit_st(ttot,regi,ppfen)          = p21_tau_fe_tax_bit_st(ttot,regi,ppfen)*0.001/sm_EJ_2_TWa; 
p21_tau_fe_sub_bit_st(ttot,regi,ppfen)          = p21_tau_fe_sub_bit_st(ttot,regi,ppfen)*0.001/sm_EJ_2_TWa;!!(subsidies also get adjusted in preloop.gms to avoid neg. prices)
pm_tau_fe_tax_ES_st(ttot,regi,esty)          = pm_tau_fe_tax_ES_st(ttot,regi,esty)*0.001/sm_EJ_2_TWa; 
pm_tau_fe_sub_ES_st(ttot,regi,esty)          = pm_tau_fe_sub_ES_st(ttot,regi,esty)*0.001/sm_EJ_2_TWa;!!(subsidies also get adjusted in preloop.gms to avoid neg. prices)
p21_tau_fuEx_sub(ttot,regi,entyPE)              =p21_tau_fuEx_sub(ttot,regi,entyPE)*0.001/sm_EJ_2_TWa;
);

*** -------------------------PE2SE Taxes--------------------------(Primary to secondary energy technology taxes, specified by technology)
*** cb 20110923 load paths for technology taxes, subsidies and inconvenience costs 
p21_tau_pe2se_tax(tall,regi,te)    = 0;
p21_tau_pe2se_inconv(tall,regi,te) = 0;
p21_tau_pe2se_sub(tall,regi,te)= 0;

*RP* FILE changed by hand after introduction of SO2 taxes and inconvenience penalties on 2012-03-08
*GL* Values try to account for excessive water use, further pollution
*GL* Taxes are given in USD(2005) per GJ 
p21_tau_pe2se_tax(ttot,regi,"pcc")$(ttot.val ge 2005)          =0.25;
p21_tau_pe2se_tax(ttot,regi,"pco")$(ttot.val ge 2005)          =0.25;
p21_tau_pe2se_tax(ttot,regi,"igcc")$(ttot.val ge 2005)         =0.25;
p21_tau_pe2se_tax(ttot,regi,"igccc")$(ttot.val ge 2005)        =0.25;
p21_tau_pe2se_tax(ttot,regi,"coalftrec")$(ttot.val ge 2005)    =1.0;
p21_tau_pe2se_tax(ttot,regi,"coalftcrec")$(ttot.val ge 2005)   =1.0;
p21_tau_pe2se_tax(ttot,regi,"coalh2")$(ttot.val ge 2005)       =0.5;
p21_tau_pe2se_tax(ttot,regi,"coalh2c")$(ttot.val ge 2005)      =0.5;
p21_tau_pe2se_tax(ttot,regi,"coalgas")$(ttot.val ge 2005)      =0.5;

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
            
            
*** --------------------
*** CO2 prices
*** --------------------    
*IM* for tax case: future CO2-tax paths are given in different module/45_carbonprice realizations
*RP* historic (2010, 2015) CO2 prices are defined here
parameter f21_taxCO2eqHist(ttot,all_regi)        "historic CO2 prices ($/tCO2)"
/
$ondelim
$include "./modules/21_tax/on/input/pm_taxCO2eqHist.cs4r"
$offdelim
/
;
*** convert from $/tCO2 to T$/GtC
pm_taxCO2eqHist(t,regi) = f21_taxCO2eqHist(t,regi) * sm_DptCO2_2_TDpGtC;


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
 
*** EOF ./modules/21_tax/on/datainput.gms
