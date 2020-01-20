*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/01_macro/singleSectorGr/datainput.gms

*** depreciation rate of capital
pm_delta_kap(regi,"kap") = 0.05;

*** load data for macro investments in 2005, used as bound
parameter p01_boundInvMacro(all_regi)        "macro investments in 2005" 
/
$ondelim
$include "./modules/01_macro/singleSectorGr/input/p01_boundInvMacro.cs4r"
$offdelim
/
;
p01_boundInvMacro(all_regi) = p01_boundInvMacro(all_regi) * pm_shPPPMER(all_regi);
*** EOF ./modules/01_macro/singleSectorGr/datainput.gms