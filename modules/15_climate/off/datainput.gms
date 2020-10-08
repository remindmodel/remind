*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/15_climate/off/datainput.gms
*JeS* Forcing target is now on RCP forcing instead of total forcing. The difference is about 0.4 W/m^2, therefore the target on the RCP forcing has to be 0.4 higher than the intended total forcing.
*** legend: gr=guardrail, os=Overshoot, nte=Not to exceed

s15_gr_forc_kyo_nte = 0;
s15_gr_forc_kyo     = 0;

p15_forc_magicc(tall) = 0;

*** Read in exogenous forcing from RCP 
$ifi  %cm_rcp_scen% == "rcp26"      $include "./modules/15_climate/off/input/data_oghgf_rcp3pd.inc";
$ifi  %cm_rcp_scen% == "rcp37"      $include "./modules/15_climate/off/input/data_oghgf_rcp45.inc";
$ifi  %cm_rcp_scen% == "rcp45"      $include "./modules/15_climate/off/input/data_oghgf_rcp45.inc";
$ifi  %cm_rcp_scen% == "rcp60"      $include "./modules/15_climate/off/input/data_oghgf_rcp6.inc";
$ifi  %cm_rcp_scen% == "rcp85"      $include "./modules/15_climate/off/input/data_oghgf_rcp85.inc";
$ifi  %cm_rcp_scen% == "rcp20"      $include "./modules/15_climate/off/input/data_oghgf_rcp3pd.inc";
$ifi  %cm_rcp_scen% == "none"       $include "./modules/15_climate/off/input/data_oghgf_rcp6.inc";

*** Read in global or regional emission caps
pm_emicapglob(ttot) = 0;

*** read in parameter pm_emicapglob depending on cm_rcp_scen and cm_multigasscen
if( (cm_multigasscen = 1) or (cm_multigasscen = 3),
$offlisting
$if %cm_rcp_scen% == "rcp20"  $include "./modules/15_climate/off/input/pm_emicapglob_450.inc";
$if %cm_rcp_scen% == "rcp26"  $include "./modules/15_climate/off/input/pm_emicapglob_450.inc";
$if %cm_rcp_scen% == "rcp37"  $include "./modules/15_climate/off/input/pm_emicapglob_550.inc";
$if %cm_rcp_scen% == "rcp45"  $include "./modules/15_climate/off/input/pm_emicapglob_550.inc";
$if %cm_rcp_scen% == "rcp60"  $include "./modules/15_climate/off/input/pm_emicapglob.inc";
$if %cm_rcp_scen% == "rcp85"  $include "./modules/15_climate/off/input/pm_emicapglob.inc";
$if %cm_rcp_scen% == "none"   $include "./modules/15_climate/off/input/pm_emicapglob.inc";
$onlisting
);
if(cm_multigasscen = 2,
$offlisting
$if %cm_rcp_scen% == "rcp20"  $include "./modules/15_climate/off/input/pm_emicapglob_multigas_450.inc";
$if %cm_rcp_scen% == "rcp26"  $include "./modules/15_climate/off/input/pm_emicapglob_multigas_450.inc";
$if %cm_rcp_scen% == "rcp37"  $include "./modules/15_climate/off/input/pm_emicapglob_multigas_550.inc";
$if %cm_rcp_scen% == "rcp45"  $include "./modules/15_climate/off/input/pm_emicapglob_multigas_550.inc";
$if %cm_rcp_scen% == "rcp60"  $include "./modules/15_climate/off/input/pm_emicapglob_multigas.inc";
$if %cm_rcp_scen% == "rcp85"  $include "./modules/15_climate/off/input/pm_emicapglob_multigas.inc";
$if %cm_rcp_scen% == "none"   $include "./modules/15_climate/off/input/pm_emicapglob_multigas.inc";
$onlisting
);
display pm_emicapglob;

*** EOF ./modules/15_climate/off/datainput.gms
