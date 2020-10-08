*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/off/realization.gms

*' @description This realisation does not differentiate between industry 
*' subsectors and does not allow for CCS in industry.  CO~2~ emissions from 
*' industry fuel use are calculated based on final energy use and emission 
*' factors.  CO~2~ process emissions from cement production are calculated 
*' based on an econometric relationship, described in @strefler_challenges_2014.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/37_industry/off/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/37_industry/off/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/37_industry/off/datainput.gms"
$Ifi "%phase%" == "bounds" $include "./modules/37_industry/off/bounds.gms"
$Ifi "%phase%" == "presolve" $include "./modules/37_industry/off/presolve.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/37_industry/off/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################

*** EOF ./modules/37_industry/off/realization.gms

