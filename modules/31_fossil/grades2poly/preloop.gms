*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/31_fossil/grades2poly/preloop.gms
***--------------------------------------
*** URANIUM BOUND
***--------------------------------------
model m31_uran_bound_dummy / q31_mc_dummy, q31_totfuex_dummy /;


*** Small CNS model to initiate regional bounds on uranium extraction
v31_fuExtrCumMax.l(regi,peExPol(enty), "1")=0.001;
solve m31_uran_bound_dummy minimizing v31_squaredDiff using nlp;
solve m31_uran_bound_dummy minimizing v31_squaredDiff using nlp;

if (NOT (   m31_uran_bound_dummy.modelstat eq 1 
         OR m31_uran_bound_dummy.modelstat eq 2),
  execute_unload "abort.gdx";
  abort "Uranium bound model m31_uran_bound_dummy could not be solved, aborting!";
);

*AJS* use parameter to save the result of the CNS model
  p31_fuExtrCumMaxBound(regi,"peur","1") = v31_fuExtrCumMax.l(regi,"peur","1");


display v31_squaredDiff.l, p31_fuExtrCumMaxBound, v31_fuExtrMC.l, 
  s31_max_disp_peur;

*** EOF ./modules/31_fossil/grades2poly/preloop.gms

