*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
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
;

alias(cesOut2cesIn,cesOut2cesIn2,cesOut2cesIn3);
alias(in,out);
alias(in,in2,in3);
alias(ipf,ipf2);
alias (in, inLocal);
*** EOF ./modules/01_macro/singleSectorGr/sets.gms

