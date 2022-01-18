** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/48_carbonpriceRegi/netZero/sets.gms

SETS
    nz_reg2050(all_regi) "regions with net-zero 2050 ghg target" / "USA","EUR","JPN" /
    nz_reg2060(all_regi) "regions with net-zero 2060 co2 target" / "CHA" /
    nz_reg(all_regi)     "all regions with net-zero target"      / "USA","EUR","JPN","CHA" /
;

*** EOF ./modules/48_carbonpriceRegi/netZero/sets.gms
