*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/21_tax/on/sets.gms

*** Define set of regions, in which an emission-factor-based bioenergy tax is
*** active.
$ifthen.regi_bio_EFTax  %cm_regi_bioenergy_EFTax% == "glob"
   set regi_bio_EFTax21(all_regi) "regions in which an emission-factor-based bioenergy tax is active";
   regi_bio_EFTax21(all_regi) = YES;
$else.regi_bio_EFTax
   set regi_bio_EFTax21(all_regi) "regions in which an emission-factor-based bioenergy tax is active" / %cm_regi_bioenergy_EFTax% /;
$endif.regi_bio_EFTax

Sets
teSeTax(all_te)       "all technologies which SE electricity demand tax"
/
elh2
/

teSeTax_coeff          "coefficients of logistic function to describe relationsship between SE tax rate and share of technology in total SE demand"
/
  "a"
  "b"
/
;  

*** EOF ./modules/21_tax/on/sets.gms

*** Module specific set
set tax_import_type_21 "p21_tau_import type" / worldPricemarkup, CO2taxmarkup, avCO2taxmarkup /
