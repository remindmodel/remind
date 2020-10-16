*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./module/23_capitalMarket/perfect.gms

*'
*' @description
*' The debt_limit realization assumes restricted capital mobility represented by a debt constraints.

*'
*' @limitations
*' The resulting consumption paths and current accounts in initial periods fit roughly to empirical data,
*' but not as well as with imperfect market realization.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/23_capitalMarket/debt_limit/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/23_capitalMarket/debt_limit/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/23_capitalMarket/debt_limit/equations.gms"
*######################## R SECTION END (PHASES) ###############################

*** EOF ./module/23_capitalMarket/perfect.gms
