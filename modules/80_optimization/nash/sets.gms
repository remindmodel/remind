*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/nash/sets.gms

sets
solveinfo80	"Nash solution stats"
/
  solvestat, modelstat, resusd, objval
/

convMessage80   "contains all convergence criteria"
/
  infes, surplus, nonopt, taxconv, IterationNumber, anticip, target, DevPriceAnticip, regiTarget,
  implicitEnergyTarget, cm_implicitPriceTarget, cm_implicitPePriceTarget, damage
/

activeConvMessage80(convMessage80)   "all active convergence criterias" / /
;

activeConvMessage80("infes") = YES;
activeConvMessage80("surplus") = YES;
activeConvMessage80("nonopt") = YES;
activeConvMessage80("IterationNumber") = YES;
if(cm_TaxConvCheck eq 1, activeConvMessage80("taxconv") = YES;);
***activeConvMessage80("anticip") = YES;
activeConvMessage80("target") = YES;
activeConvMessage80("DevPriceAnticip") = YES;
$if not "%cm_emiMktTarget%" == "off" activeConvMessage80("regiTarget") = YES;
$if not "%cm_implicitQttyTarget%" == "off" activeConvMessage80("implicitEnergyTarget") = YES;
$if not "%cm_implicitPriceTarget%" == "off" activeConvMessage80("cm_implicitPriceTarget") = YES;
$if not "%cm_implicitPePriceTarget%" == "off" activeConvMessage80("cm_implicitPePriceTarget") = YES;
$if not "%internalizeDamages%" == "off" activeConvMessage80("damage") = YES;

*** EOF ./modules/80_optimization/nash/sets.gms
