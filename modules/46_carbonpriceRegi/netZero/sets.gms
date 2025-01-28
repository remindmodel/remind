*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/46_carbonpriceRegi/netZero/sets.gms

$ifthenE.scen (sameas("%cm_netZeroScen%","NGFS_v4"))or(sameas("%cm_netZeroScen%","NGFS_v4_20pc"))
SETS
    nz_reg2050(all_regi)    "regions with net-zero 2050 target"   / "CAZ","EUR","JPN","LAM","USA" /
    nz_reg2055(all_regi)    "regions with net-zero 2055 target"   /  /
    nz_reg2060(all_regi)    "regions with net-zero 2060 target"   / "CHA","REF" /
    nz_reg2070(all_regi)    "regions with net-zero 2070 target"   / "IND" /
    nz_reg2080(all_regi)    "regions with net-zero 2080 target"   /  /
    nz_reg_CO2(all_regi)    "regions with CO2, not GHG target"    / "CHA","IND" /
;
$elseif.scen "%cm_netZeroScen%" == "ELEVATE2p3"
SETS
    nz_reg2050(all_regi)    "regions with net-zero 2050 target"   / "CAZ","EUR","JPN","USA","LAM" /
    nz_reg2055(all_regi)    "regions with net-zero 2055 target"   / "MEA","NEU","OAS", "SSA" /
    nz_reg2060(all_regi)    "regions with net-zero 2060 target"   / "CHA","REF" /
    nz_reg2070(all_regi)    "regions with net-zero 2070 target"   / "IND" /
    nz_reg2080(all_regi)    "regions with net-zero 2080 target"   /  /
    nz_reg_CO2(all_regi)    "regions with CO2, not GHG target"    / "OAS","NEU","SSA", "LAM","MEA", "REF",  "CHA", "IND" /
;
$else.scen
    $error 'In 46_carbonpriceRegi/netZero/sets.gms, no settings for the specified cm_netZeroScen found'
$endif.scen

SETS
    nz_reg(all_regi)        "all regions with a net-zero target"
;
nz_reg(all_regi) = nz_reg2050(all_regi) + nz_reg2055(all_regi) + nz_reg2060(all_regi) + nz_reg2070(all_regi) + nz_reg2080(all_regi);

display nz_reg;
*** EOF ./modules/46_carbonpriceRegi/netZero/sets.gms
