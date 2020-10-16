*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/21_tax/on.gms

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/21_tax/on/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/21_tax/on/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/21_tax/on/equations.gms"
$Ifi "%phase%" == "preloop" $include "./modules/21_tax/on/preloop.gms"
$Ifi "%phase%" == "bounds" $include "./modules/21_tax/on/bounds.gms"
$Ifi "%phase%" == "presolve" $include "./modules/21_tax/on/presolve.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/21_tax/on/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/21_tax/on.gms
