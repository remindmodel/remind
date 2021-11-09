*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/exogenous/declarations.gms
parameters
    p45_tau_co2_tax(ttot,all_regi)   "Exogenous CO2 tax level"

$if not "%cm_regiExoPrice%" == "off" p45_exo_co2_tax(ext_regi,ttot)   "Exogenous CO2 tax level from switch [$/tCO2]" / %cm_regiExoPrice% /

;

*** EOF ./modules/45_carbonprice/exogenous/declarations.gms
