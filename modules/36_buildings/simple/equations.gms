*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/36_buildings/simple/equations.gms

$ifThen.regiPhaseOutFosBuil not "%cm_regiPhaseOutFosBuilSimple%" == "none"
*** Ensure that the whole demand for solids in buildings can be fulfilled with
*** biomass. This is equivalent to a phase out of coal in buildings, since 
*** secondary energy solids can either come from biomass or coal. This will,
*** however, have the "feedback" effect, that the industry sector uses much 
*** more coal.
q36_coalBoundBuildings (t,regi)$(t.val ge 2050 AND regiPhaseOutFosBuil_36(regi)) ..
    vm_cesIO(t,regi,"fesob")
    =l=  
    vm_prodFE(t,regi,"sesobio","fesos","tdfossos")
;
$endIf.regiPhaseOutFosBuil


*** EOF ./modules/36_buildings/simple/equations.gms