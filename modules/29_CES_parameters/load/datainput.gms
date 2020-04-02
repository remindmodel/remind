*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/29_CES_parameters/load/datainput.gms
*** Load CES parameters based on current model configuration
*** ATTENTION the file name is replaced by the function start_run()
*##################### R SECTION START (CES INPUT) ##########################
$include "./modules/29_CES_parameters/load/input/stat_off-indu_fixed_shares-buil_simple-tran_complex-POP_pop_SSP2-GDP_gdp_SSP2-Kap_perfect-Reg_690d3718e1.inc"
*###################### R SECTION END (CES INPUT) ###########################



option pm_cesdata:8:3:1;
display "loaded pm_cesdata", pm_cesdata;

*** EOF ./modules/29_CES_parameters/load/datainput.gms
