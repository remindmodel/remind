*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/29_CES_parameters/load/datainput.gms
*** Load CES parameters based on current model configuration
*** ATTENTION the file name is replaced by the function start_run()
*##################### R SECTION START (CES INPUT) ##########################
$include "./modules/29_CES_parameters/load/input/stat_off-indu_fixed_shares-buil_simple-tran_complex-POP_pop_SSP2-GDP_gdp_SSP2-Kap_debt_limit-Reg_62eff8f7.inc"
*###################### R SECTION END (CES INPUT) ###########################

if (cm_GDPcovid eq 1,
   pm_cesdata("2020",all_regi,"lab","effgr") = 0.5 * (pm_cesdata ("2015",all_regi,"lab","effgr") + pm_cesdata ("2020",all_regi,"lab","effgr"));
);

option pm_cesdata:8:3:1;
display "loaded pm_cesdata", pm_cesdata;

*** EOF ./modules/29_CES_parameters/load/datainput.gms
