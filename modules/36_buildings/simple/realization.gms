*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/36_buildings/simple/realization.gms

*' @description The `simple` realization represents buildings energy demand
*' within the CES function on a final energy level. We distinguish six energy
*' carriers categories (electricity, solids, liquids, gas, district heating,
*' hydrogen). Electricity if further split into (a) space heating with resitive
*' heating, (b) space heating with heat pumps and (c) everything else (cooling,
*' appliances & lighting, water heating and cooking). Heat pumps and district
*' heating are attached with additional mark up costs used to represent both
*' higher efficiency in the CES function and higher investment cost. Policies
*' supporting a technology can be represented by lowering the respective mark
*' up cost with respect to the calibration.
*'
*' @limitations This realization does not distinguish across end-uses.
*' Also, it does not allow for substitution between energy consumption and
*' end-use capital.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/36_buildings/simple/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/36_buildings/simple/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/36_buildings/simple/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/36_buildings/simple/equations.gms"
$Ifi "%phase%" == "bounds" $include "./modules/36_buildings/simple/bounds.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/36_buildings/simple/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/36_buildings/simple/realization.gms
