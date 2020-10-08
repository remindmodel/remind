*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/ExogSameAsPrevious/datainput.gms
***----------------------------
*** CO2 Tax level
***----------------------------

*** CO2 tax level is taken from a previous run

*GL: tax path in 10^12$/GtC = 1000 $/tC
*** according to Asian Modeling Excercise tax case setup, 30$/t CO2eq in 2020 = 0.110 k$/tC = 0.110 T$/GtC

Parameter p45_CO2_tax_previousScen(tall,all_regi)  "CO2 tax level from previous scenario"
/
$ondelim
$include "./modules/45_carbonprice/ExogSameAsPrevious/input/p45_ExogSameAsPrevious_CO2_tax.cs4r"
$offdelim
/
;

pm_taxCO2eq(ttot,regi)$(ttot.val ge cm_startyear) = p45_CO2_tax_previousScen(ttot,regi) * sm_DptCO2_2_TDpGtC;

display pm_taxCO2eq;

*** EOF ./modules/45_carbonprice/ExogSameAsPrevious/datainput.gms
