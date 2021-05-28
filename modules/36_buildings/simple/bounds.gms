*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/36_buildings/simple/bounds.gms


*** ---------------------------------------------------------------------------
*** Set bounds for buildings sector
*** ---------------------------------------------------------------------------
*LM* Exogenously fade out fossils in buildings
$ifThen.regiPhaseOutFosBuil not "%cm_regiPhaseOutFosBuilSimple%" == "none"
vm_cesIO.up("2040", regiPhaseOutFosBuil_36, "fegab")                    = 0.10;
vm_cesIO.up("2045", regiPhaseOutFosBuil_36, "fegab")                    = 0.05;
vm_cesIO.up(ttot,   regiPhaseOutFosBuil_36, "fegab")$(ttot.val ge 2050) = 1e-6;

vm_cesIO.up("2040", regiPhaseOutFosBuil_36, "fehob")                    = 0.04;
vm_cesIO.up("2045", regiPhaseOutFosBuil_36, "fehob")                    = 0.02;
vm_cesIO.up(ttot,   regiPhaseOutFosBuil_36, "fehob")$(ttot.val ge 2050) = 1e-6;

*** Phasing out coal in buildings is not that easy in this realization, there 
*** are two options, non is perfect:
*** 1: Phase out coal in the whole stationary sector.
***    This has the "side-effect" that coal is also pased out in industry.
***    Furthermore it seems to lead to infeasibilities.
* vm_prodSe.up(ttot, regiPhaseOutFosBuil_36, "pecoal", "sesofos", "coaltr")$(ttot.val ge 2050) = 1e-6;

*** 2: Phase out solidies in the buildings sector.
***    This has the side effect that also solids from biomass will be phased 
***    out (not only coal).
* vm_cesIO.up(ttot,   regiPhaseOutFosBuil_36, "fesob")$(ttot.val ge 2040) = 1e-6;
$endIf.regiPhaseOutFosBuil
*** EOF ./modules/36_buildings/simple/bounds.gms