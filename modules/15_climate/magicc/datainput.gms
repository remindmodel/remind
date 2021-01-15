*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/15_climate/magicc/datainput.gms
*** cluster rcp_scen into overshoot and not-to-exceed targets
$if %cm_rcp_scen% == "none"    s15_rcpCluster = 1;
$if %cm_rcp_scen% == "rcp20"   s15_rcpCluster = 1;
$if %cm_rcp_scen% == "rcp26"   s15_rcpCluster = 1;
$if %cm_rcp_scen% == "rcp37"   s15_rcpCluster = 1;
$if %cm_rcp_scen% == "rcp45"   s15_rcpCluster = 0;
$if %cm_rcp_scen% == "rcp60"   s15_rcpCluster = 0;
$if %cm_rcp_scen% == "rcp85"   s15_rcpCluster = 0;


s15_forcing_budgetiterationoffset = 1.5;
$if %cm_rcp_scen% == "rcp20" s15_forcing_budgetiterationoffset = 1.2;
s15_forcing_budgetiterationoffset_tax = 0.0;

*JeS* Forcing target is now on RCP forcing instead of total forcing. The 
*** difference is about 0.4 W/m^2, therefore the target on the RCP forcing 
*** has to be 0.4 higher than the intended total forcing.
$if %cm_rcp_scen% == "none"   s15_gr_forc_nte = 100;
$if %cm_rcp_scen% == "rcp26"  s15_gr_forc_nte = 10;
$if %cm_rcp_scen% == "rcp37"  s15_gr_forc_nte = 3.67;
$if %cm_rcp_scen% == "rcp45"  s15_gr_forc_nte = 4.22;
$if %cm_rcp_scen% == "rcp60"  s15_gr_forc_nte = 5.44;
$if %cm_rcp_scen% == "rcp85"  s15_gr_forc_nte = 8.5;
$if %cm_rcp_scen% == "rcp20"  s15_gr_forc_nte = 10;

$if %cm_rcp_scen% == "none"   s15_gr_forc_os = 100;
$if %cm_rcp_scen% == "rcp26"  s15_gr_forc_os = 2.54;
$if %cm_rcp_scen% == "rcp37"  s15_gr_forc_os = 3.67;
$if %cm_rcp_scen% == "rcp45"  s15_gr_forc_os = 4.23;
$if %cm_rcp_scen% == "rcp60"  s15_gr_forc_os = 5.44;
$if %cm_rcp_scen% == "rcp85"  s15_gr_forc_os = 8.5;
$if %cm_rcp_scen% == "rcp20"  s15_gr_forc_os = 1.93;

s15_gr_forc_kyo_nte = 0;
s15_gr_forc_kyo     = 0;

p15_forc_magicc(tall) = 0;

$if  %cm_rcp_scen% == "rcp26"    $include "./modules/15_climate/box/input/data_oghgf_rcp3pd.inc";
$if  %cm_rcp_scen% == "rcp37"    $include "./modules/15_climate/box/input/data_oghgf_rcp45.inc";
$if  %cm_rcp_scen% == "rcp45"    $include "./modules/15_climate/box/input/data_oghgf_rcp45.inc";
$if  %cm_rcp_scen% == "rcp60"    $include "./modules/15_climate/box/input/data_oghgf_rcp6.inc";
$if  %cm_rcp_scen% == "rcp85"    $include "./modules/15_climate/box/input/data_oghgf_rcp85.inc";
$if  %cm_rcp_scen% == "rcp20"    $include "./modules/15_climate/box/input/data_oghgf_rcp3pd.inc";
$if  %cm_rcp_scen% == "none"     $include "./modules/15_climate/box/input/data_oghgf_rcp6.inc";

pm_emicapglob(ttot) = 0;

*** parameter pm_emicapglob is read in depending on cm_rcp_scen and cm_multigasscen
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

p15_gmt0(tall)=1;

*** EOF ./modules/15_climate/magicc/datainput.gms
