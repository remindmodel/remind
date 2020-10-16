*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/20_growth/spillover/sets.gms
sets
inRD20(all_in)      "Inputs included in extended endogenous growth"
/lab, en/
 noRD(all_in)      "Inputs not included in endogenous growth"
;

noRD(in) = not inRD20(in);
*** EOF ./modules/20_growth/spillover/sets.gms
