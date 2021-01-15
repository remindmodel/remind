*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/linear/datainput.gms
***----------------------------
*** CO2 Tax level
***----------------------------

*** CO2 tax level is calculated at a linear increase from the 2020 tax level exogenously defined

*GL: tax path in 10^12$/GtC = 1000 $/tC
*** according to Asian Modeling Excercise tax case setup, 30$/t CO2eq in 2020 = 0.110 k$/tC

if(cm_co2_tax_2020 lt 0,
  abort "please choose a valid cm_co2_tax_2020"
elseif cm_co2_tax_2020 ge 0,
*** convert tax value from $/t CO2eq to T$/GtC
  pm_taxCO2eq("2040",regi)= 3 * cm_co2_tax_2020 * sm_DptCO2_2_TDpGtC;  !! shifted to 2040 to make sure that even in delay scenarios the fixpoint of the linear price path is inside the "t" range, otherwise the CO2 prices from reference run may be overwritten
*** The factor 3 comes from shifting the 2020 value 20 years into the future at linear increase of 10% of 2020 value per year.
);

pm_taxCO2eq(ttot,regi)$((ttot.val gt 2005) AND (ttot.val ge cm_startyear)) = pm_taxCO2eq("2040",regi)*( 1 + 0.1/3 * (ttot.val-2040)); !! no CO2 price in 2005 and only change CO2 prices after ; 
*** annual increase by (10/3)% of the 2040 value is the same as a 10% increase of the 2020 value is the same as a linear increase from 0 in 2010 to the 2020/2040 value

pm_taxCO2eq(ttot,regi)$(ttot.val gt 2110) = pm_taxCO2eq("2110",regi); !! to prevent huge taxes after 2110 and the resulting convergence problems, set taxes after 2110 equal to 2110 value
display pm_taxCO2eq;

*** EOF ./modules/45_carbonprice/linear/datainput.gms
