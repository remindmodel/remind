*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/expoLinear.gms

*' @description  The exponential price path goes back to the “Hotelling rule”:  
*' a price path that rises exponentially with the discount rate is economically optimal for extracting a finite resource, 
*' in our case the finite remaining carbon budget. However, once CDR is introduced to the portfolio of mitigation options, 
*' the remaining admissible amount of cumulative gross CO2 emissions is no longer finite, and the Hotelling rule no longer represents an economically optimal solution. 
*' A carbon price path following the Hotelling rule leads to rather low emission prices and therefore low emission reductions early in the century, 
*' and to very high emission prices and massive CDR deployment towards the end of the century. 
*' A Hotellling price path can only be considered optimal until the time of net-zero emissions. 
*' Afterwards, a moderate carbon price increase is sufficient to avoid a return of fossil fuels. 
*' Therefore, we choose an exponentially increasing carbon price until the expected time of net-zero emissions and a linear increase at the rate of 2050 or 2060 afterwards.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/45_carbonprice/expoLinear/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/45_carbonprice/expoLinear/datainput.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/45_carbonprice/expoLinear.gms
