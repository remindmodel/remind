*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/40_techpol/NPi2018/datainput.gms 
*** SOF means start fo file and EOF means end of file. Use these before and after the body of the code

Parameter p40_TechBound(ttot,all_regi,all_te) "NDC capacity targets for solar, wind, nuclear, hydro, and biomass (GW)"
  /
$ondelim
$include "./modules/40_techpol/NPi2018/input/f40_NDC+REN21+CHN_NUC.cs4r"
$offdelim
  /;

p40_ElecBioBound("2030",regi) = p40_TechBound("2030",regi,"bioigcc");

*** inputs for hard-coded share targets: they only apply if the respective country (or EU28) is a native region in the chosen REMIND setting
*** otherwise, they are not considered in the model
*** to add further targets, include both the respective parameter value below, and extend the equation domain in equations.gms
p40_noncombust_acc_eff(t,iso_regi,te) = 1;!!general efficiency 100%
p40_PEgasBound(t,iso_regi)                = 0;
p40_PElowcarbonBound(t,iso_regi)           = 0;       
p40_El_RenShare(t,iso_regi)                = 0;       
p40_CoalBound(t,iso_regi)                   = 0;      
p40_FE_RenShare(t,iso_regi)              = 0;

*** Chinese PE targets are defined with substitution accounting method
p40_noncombust_acc_eff(t,"CHN",te)$(sameas(te,"spv") OR sameas(te,"csp") OR sameas(te,"wind") OR sameas(te,"tnrs") OR sameas(te,"spv") OR sameas(te,"geohdr") OR sameas(te,"hydro")) = 0.38; !! substitution accounting for low-carbon electricity generation at coal efficiency of 38%
p40_noncombust_acc_eff(t,"CHA",te)$(sameas(te,"spv") OR sameas(te,"csp") OR sameas(te,"wind") OR sameas(te,"tnrs") OR sameas(te,"spv") OR sameas(te,"geohdr") OR sameas(te,"hydro")) = 0.38; !! substitution accounting for low-carbon electricity generation at coal efficiency of 38%
*** lower bound on gas share in PE
p40_PEgasBound("2020","CHN") = 0.1; 
p40_PEgasBound(t,"CHN")$(t.val gt 2020) = min(0.1 ,0.1 - (t.val - 2050) * 0.005 ); !! 10% until 2050 and then declining again, to allow for high LC shares (no bound on gas after 2080)
p40_PEgasBound("2020","CHA") = 0.1; 
p40_PEgasBound(t,"CHA")$(t.val gt 2020) = min(0.1 ,0.1 - (t.val - 2050) * 0.005 ); !! 10% until 2050 and then declining again, to allow for high LC shares (no bound on gas after 2080)
*** lower bound on low carbon share in PE
p40_PElowcarbonBound("2020","CHN") = 0.15; 
p40_PElowcarbonBound(t,"CHN")$(t.val ge 2030)=min(0.15 + (t.val -2030) * 0.00,0.75	); !!Chinas INDC plus extrapolation, is mostly non-binding beyond 2035
p40_PElowcarbonBound("2020","CHA") = 0.15; 
p40_PElowcarbonBound(t,"CHA")$(t.val ge 2030)=min(0.15 + (t.val -2030) * 0.00,0.75	); !!Chinas INDC plus extrapolation, is mostly non-binding beyond 2035


*** EU lower bound on renewable share in gross  final energy (=secondary energy in REMIND)
p40_FE_RenShare(t,"EUR")$(t.val ge 2030)=min(0.32 + (t.val-2030)*0.002,0.5); !!EU Energy and Climate package for 2030, 

display p40_ElecBioBound;
display p40_TechBound; !! good to see if the input is displayed correctly

*** EOF ./modules/40_techpol/NPi2018/datainput.gms


