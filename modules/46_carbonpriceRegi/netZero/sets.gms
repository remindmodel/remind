*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/46_carbonpriceRegi/netZero/sets.gms

SETS
    nz_reg2050(all_regi)    "regions with net-zero 2050 target"   / "USA","EUR","JPN","CAZ" /
    nz_reg2055(all_regi)    "regions with net-zero 2055 target"   /  /
    nz_reg2060(all_regi)    "regions with net-zero 2060 target"   / "CHA","REF" /
    nz_reg2070(all_regi)    "regions with net-zero 2070 target"   / "IND" /
    nz_reg_CO2(all_regi)    "regions with CO2, not GHG target"    / "IND" /
    nz_reg(all_regi)        "all regions with a net-zero target"
;

nz_reg(all_regi) = nz_reg2050(all_regi) + nz_reg2055(all_regi) + nz_reg2060(all_regi) + nz_reg2070(all_regi);

*** EOF ./modules/46_carbonpriceRegi/netZero/sets.gms
