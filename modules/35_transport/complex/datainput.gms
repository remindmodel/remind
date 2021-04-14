*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/35_transport/complex/datainput.gms

*** substitution elasticities
Parameter 
  p35_cesdata_sigma(all_in)  "substitution elasticities"
  /
        entrp   1.5
          fetf  0.8
  /

  p35_valconv                "temporary parameter used to set convergence between regions"
;
pm_cesdata_sigma(ttot,in)$p35_cesdata_sigma(in) = p35_cesdata_sigma(in);


*RP* read-in of regionalized transport mode shares and efficiencies 
table f35_transp_eff(all_regi,char35)       "read-in of regionalized transport mobility shares and efficiencies"
$ondelim
$include "./modules/35_transport/complex/input/f35_transp_eff.cs3r"
$offdelim
;

*** Developed regions: EU 2.6, US 3.1, CAZ 3.4
p35_pass_FE_target_share = 0.3;
p35_harmonizing_year = 2150;

p35_pass_FE_share_transp(ttot,regi)$(ttot.val ge 2005) = (f35_transp_eff(regi, "share_Pass_nonLDV")*(p35_harmonizing_year-ttot.val)**2+p35_pass_FE_target_share*(ttot.val-2005)**2)/(p35_harmonizing_year-2005)**2;

p35_pass_nonLDV_ES_efficiency(ttot,regi)$(ttot.val ge 2005)  = f35_transp_eff(regi,"Eff_Pass_nonLDV");   
p35_passLDV_ES_efficiency(ttot,regi)$(ttot.val ge 2005)      = f35_transp_eff(regi,"Eff_Pass_LDV");
p35_freight_ES_efficiency(ttot,regi)$(ttot.val ge 2005)      = f35_transp_eff(regi,"Eff_Freight");


p35_valconv = sum((regi),f35_transp_eff(regi,"Eff_Pass_nonLDV"))/ card(regi);

p35_pass_nonLDV_ES_efficiency(ttot,regi)$(ttot.val ge 2005) = (p35_pass_nonLDV_ES_efficiency(ttot,regi)*(p35_harmonizing_year-ttot.val)+p35_valconv*(ttot.val-2005))/(p35_harmonizing_year-2005);

p35_valconv = sum((regi),f35_transp_eff(regi,"Eff_Pass_LDV"))/ card(regi);

p35_passLDV_ES_efficiency(ttot,regi)$(ttot.val ge 2005) = (p35_passLDV_ES_efficiency(ttot,regi)*(p35_harmonizing_year-ttot.val)+p35_valconv*(ttot.val-2005))/(p35_harmonizing_year-2005);

p35_valconv = sum((regi),f35_transp_eff(regi,"Eff_Freight"))/ card(regi);

p35_freight_ES_efficiency(ttot,regi)$(ttot.val ge 2005) = (p35_freight_ES_efficiency(ttot,regi)*(p35_harmonizing_year-ttot.val)+p35_valconv*(ttot.val-2005))/(p35_harmonizing_year-2005);


display p35_pass_nonLDV_ES_efficiency;
display p35_passLDV_ES_efficiency;
display p35_freight_ES_efficiency;


*** bunkers FE demand trajectories
Parameter  p35_bunkers_fedemand(tall,all_regi,all_GDPscen,EDGE_scenario_all)       "Bunkers FE demand [EJ]"
/
$ondelim
$include "./modules/35_transport/complex/input/f35_bunkers_fe.cs4r"
$offdelim
/
;

p35_bunkers_fe(ttot,regi) = sm_EJ_2_TWa * p35_bunkers_fedemand(ttot,regi,"gdp_SSP2","ConvCase");

display p35_bunkers_fe;

*** RP: to be able to better reproduce the 2010 decrease of liquids and solids demand in the US, additionally decrease the refineries build-up in 2005:
table f35_factorVintages(all_regi,opTimeYr,all_te) "factor to be able to better reproduce the 2010 decrease of liquids and solids demand"
$ondelim
$include "./modules/35_transport/complex/input/f35_factorVintages.cs3r"
$offdelim
;
loop(regi,
     loop(opTimeYr,
          loop(te,
               if(f35_factorVintages(regi,opTimeYr,te) = 0,
                  f35_factorVintages(regi,opTimeYr,te) = 1;
               );
          );
     );
);
pm_vintage_in(regi,opTimeYr,te) = f35_factorVintages(regi,opTimeYr,te) * pm_vintage_in(regi,opTimeYr,te);
display pm_vintage_in;
*RP* end vintages


*** EOF ./modules/35_transport/complex/datainput.gms
