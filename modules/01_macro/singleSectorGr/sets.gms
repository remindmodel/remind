*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/01_macro/singleSectorGr/sets.gms

Sets

cesOut2cesIn(all_in,all_in)           "CES tree structure"
/
  inco  . (lab, kap, en)
/

cesLevel2cesIO(counter,all_in)        "CES tree structure by level"
cesRev2cesIO(counter,all_in)          "CES tree structure by level - descending order"
cesOut2cesIn_below(all_in,all_in)     "All elements of the CES below located below the first item given"
in_below_putty(all_in)                "All elements of the CES below ppf_putty, excluding ppf_putty. Only meaningful in case putty structures are not intertwined"


in(all_in)                            "All inputs and outputs of the CES function"
/
  inco                                "Macroeconomic output"  
  lab                                 "Labour input"
  kap                                 "Capital input"
  en                                  "Energy input"
/
ppf(all_in)                           "All primary production factors"
ipf(all_in)                           "All intermediate production factors"
ppfKap(all_in)                        "Primary production factors capital"   / kap /
ppfEn(all_in)                         "Primary production factors energy" 
in_putty(all_in)                      "Production factors subject to putty-clay dynamics"
ppf_putty(all_in)                     "All putty-clay primary production factors"
ipf_putty(all_in)                     "All putty-clay intermediate production factors"
ppfIO_putty(all_in)                   "Factors treated in the normal CES as ppf and in putty-clay as output"
nests_putty(all_in,all_in)            "Defines factors which are in the same putty subnest. The first all_in gives the higher factors of the subnest"
in_enerSerAdj(all_in)                 "Energy services factors which should be constrained by adjustment costs" //
in_complements(all_in)                "Factors which are perfect complements"  //
complements_ref(all_in,all_in)        "Correspondence between complementary factors. Necessary to have a reference factor for the constraints equations"
;



in_putty(all_in)    = NO;   
ppf_putty(all_in)   = NO; 
ipf_putty(all_in)   = NO; 
ppfIO_putty(all_in) = NO;  

alias(cesOut2cesIn,cesOut2cesIn2,cesOut2cesIn3);
alias(in,out);
alias(in,in2,in3);
alias(ipf,ipf2);
*** EOF ./modules/01_macro/singleSectorGr/sets.gms

