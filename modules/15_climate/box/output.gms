*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/15_climate/box/output.gms

*-----------------taken from generisreswrite.inc ---------------------
file res_ta;
put res_ta;
loop(ta10,
        put ta10.tl /;
);
putclose res_ta;

*-------------taken from reporting_generic_klima.inc (whole file)-------------

sets 
descr_box(descr)   "???"
/ 
"Concentration|CO2; ppm;"			 
"Concentration|CH4; ppb;"			 
"Concentration|N2O; ppb;"			 
"Forcing; W/m2;"			 
"Forcing|Kyoto Gases; W/m2;"
"Temperature|Global Mean; K;"/;

descr_all(descr) =   descr_all(descr) + descr_box(descr);

*** EOF ./modules/15_climate/box/output.gms
