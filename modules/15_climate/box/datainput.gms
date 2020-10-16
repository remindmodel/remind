*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/15_climate/box/datainput.gms
*JeS climate targets for different rcp_scens
*** values for s15_gr_temp and s15_gr_conc are more or less placeholders. Should be replaced with correct values as soon as runs are actually done.
*JeS* Forcing target is now on RCP forcing instead of total forcing. The difference is about 0.4 W/m^2, therefore the target on the RCP forcing has to be 0.4 higher than the intended total forcing.
*JeS* the dependency on other parameters than rcp_scen should be replaced by an automatic magicc run
$ifthen %cm_rcp_scen% == "none"
    s15_gr_temp = 10;
    s15_gr_conc = 2000;
    s15_gr_forc_nte = 10;
    s15_gr_forc_os = 10;
$elseif %cm_rcp_scen% == "rcp26"
    s15_gr_temp = 2;
    s15_gr_conc = 380;
    s15_gr_forc_nte = 10;
    s15_gr_forc_os = 3.06;
$elseif %cm_rcp_scen% == "rcp37"
    s15_gr_temp = 2.5;
    s15_gr_conc = 450;
    s15_gr_forc_nte = 4.39;
    s15_gr_forc_os = 4.3;
$elseif %cm_rcp_scen% == "rcp45"
    s15_gr_temp = 3;
    s15_gr_conc = 550;
    s15_gr_forc_nte = 5.09;
    s15_gr_forc_os = 5.09;
$elseif %cm_rcp_scen% == "rcp60"
    s15_gr_temp = 5;
    s15_gr_conc = 600;
    s15_gr_forc_nte = 6.0;
    s15_gr_forc_os = 6.0;
$elseif %cm_rcp_scen% == "rcp85"
    s15_gr_temp = 7;
    s15_gr_conc = 700;
    s15_gr_forc_nte = 9.0;
    s15_gr_forc_os = 9.0;
$elseif %cm_rcp_scen% == "rcp20"
    s15_gr_temp = 1.7;
    s15_gr_conc = 300;
    s15_gr_forc_nte = 10;
    s15_gr_forc_os = 2.53;
$else
    abort "please choose a valid cm_rcp_scen"
$endif

*JeS* data_oghgf contains exogenous forcings, data_oghg_emi exogenous emissions (e.g. f-gases), data_emi_so2 exogenous so2 emissions (e.g. from industry), con_oh OH concentration taken from ACC2
$if  %cm_rcp_scen% == "rcp26"    $include "./modules/15_climate/box/input/data_oghgf_rcp3pd.inc";
$if  %cm_rcp_scen% == "rcp37"    $include "./modules/15_climate/box/input/data_oghgf_rcp45.inc";
$if  %cm_rcp_scen% == "rcp45"    $include "./modules/15_climate/box/input/data_oghgf_rcp45.inc";
$if  %cm_rcp_scen% == "rcp60"    $include "./modules/15_climate/box/input/data_oghgf_rcp6.inc";
$if  %cm_rcp_scen% == "rcp85"    $include "./modules/15_climate/box/input/data_oghgf_rcp85.inc";
$if  %cm_rcp_scen% == "rcp20"    $include "./modules/15_climate/box/input/data_oghgf_rcp3pd.inc";
$if  %cm_rcp_scen% == "none"     $include "./modules/15_climate/box/input/data_oghgf_rcp6.inc";

$if  %cm_rcp_scen% == "rcp26"    $include "./modules/15_climate/box/input/con_oh_450.inc";
$if  %cm_rcp_scen% == "rcp37"    $include "./modules/15_climate/box/input/con_oh_550.inc";
$if  %cm_rcp_scen% == "rcp45"    $include "./modules/15_climate/box/input/con_oh_550.inc";
$if  %cm_rcp_scen% == "rcp60"    $include "./modules/15_climate/box/input/con_oh_bau.inc";
$if  %cm_rcp_scen% == "rcp85"    $include "./modules/15_climate/box/input/con_oh_bau.inc";
$if  %cm_rcp_scen% == "rcp20"    $include "./modules/15_climate/box/input/con_oh_450.inc";
$if  %cm_rcp_scen% == "none"     $include "./modules/15_climate/box/input/con_oh_bau.inc";

p15_ta_val(ta10) = ta10.val;

*JeS* include forcing target from previous run
$if %cm_climate_target% == "on" $include "./modules/15_climate/box/input/fromres_forcing_target.put";

*mlb 20140109* just for allowing the climate externality (Nash) to be correctly initialized in module 80 
pm_emicapglob(t) = 1000;
*** EOF ./modules/15_climate/box/datainput.gms
