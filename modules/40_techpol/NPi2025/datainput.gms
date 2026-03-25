*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/40_techpol/NPi2025/datainput.gms

*------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------
***                                Capacity Targets
*------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------

Table f40_TechBound(ttot,all_regi,NPi_version,all_te) "Table for all NPi versions with NPi capacity targets (GW)"
$offlisting
$ondelim
$include "./modules/40_techpol/NPi2025/input/f40_NewClimate.cs3r"
$offdelim
$onlisting
;

*** ensure that lower technology bounds are not decreasing
*** this only refers to lower bounds and needs to be revised once upper bounds are introduced.
p40_TechBound(ttot,all_regi,te) = smax(ttot2$(ttot2.val le ttot.val) , f40_TechBound(ttot2,all_regi,"%cm_NPi_version%",te));

*** windoffshore-todo: separate NDC targets for windon and windoff
p40_TechBound(ttot,all_regi,"wind") = f40_TechBound(ttot,all_regi,"%cm_NPi_version%","wind");
p40_ElecBioBound("2030",regi) = p40_TechBound("2030",regi,"bioigcc");

*** In scenarios with 2nd generation bioenergy technology phaseout,
*** switch-off biomass capacity targets of NDC
if (cm_phaseoutBiolc eq 1,
  p40_ElecBioBound(t,regi) = 0;
  );


display p40_ElecBioBound;
display p40_TechBound; 

*------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------
***                                Renewable Share Targets
*------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------


*** renewable share targets per REMIND region from input data
table f40_RenShareTargets(ttot,all_regi,RenShareTargetType) "input data of renewable share targets in NPi [share]"
$ondelim
$include "./modules/40_techpol/NPi2025/input/f40_RenShareTargets.cs3r"
$offdelim
;

*** apply renewable share targets to target year and all time steps afterwards
loop( (ttot,all_regi,RenShareTargetType)$(f40_RenShareTargets(ttot,all_regi,RenShareTargetType)),
  p40_RenShareTargets(t,all_regi,RenShareTargetType)$(t.val ge ttot.val) = f40_RenShareTargets(ttot,all_regi,RenShareTargetType);
);


*** EOF ./modules/40_techpol/NPi2025/datainput.gms


