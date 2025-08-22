*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/01_macro/singleSectorGr/datainput.gms

*** depreciation rate of capital
pm_delta_kap(regi,"kap") = 0.05;

p01_investeffectv('CAZ') = 0.8167;
p01_investeffectv('CHA') = 0.8693;
p01_investeffectv('EUR') = 0.7945;
p01_investeffectv('IND') = 0.7404;
p01_investeffectv('JPN') = 0.8565;
p01_investeffectv('LAM') = 0.6906;
p01_investeffectv('MEA') = 0.7231;
p01_investeffectv('NEU') = 0.7940;
p01_investeffectv('OAS') = 0.7458;
p01_investeffectv('REF') = 0.7815;
p01_investeffectv('SSA') = 0.6760;
p01_investeffectv('USA') = 0.87 ;

*AL* initialize parameter (avoid compilation errors)
p01_ppfen_ratios(t,regi,in,in2) = 0; 
p01_ppfen_shares(t,regi,in,in2) = 0;

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
