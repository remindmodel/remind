*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/32_power/IntC/bounds.gms

***-----------------------------------------------------------
***                  module specific bounds
***------------------------------------------------------------

*** Fix capacity factors to the standard value from data
vm_capFac.fx(t,regi,te) = pm_cf(t,regi,te);

$IFTHEN.dispatchSetyDown not "%cm_dispatchSetyDown%" == "off"
  loop(pe2se(enty,enty2,te),
    vm_capFac.lo(t,regi,te) = ( 1 - %cm_dispatchSetyDown% / 100 ) * pm_cf(t,regi,te);
  );
$ENDIF.dispatchSetyDown

$IFTHEN.dispatchSeelDown not "%cm_dispatchSeelDown%" == "off"
  loop(pe2se(enty,enty2,te)$sameas(enty2,"seel"),  
    vm_capFac.lo(t,regi,te) = ( 1 - %cm_dispatchSeelDown% / 100 ) * pm_cf(t,regi,te);  
  );
$ENDIF.dispatchSeelDown

*** FS: set bounds for capacity factor of electrolysis

*** by default set capacity factor to value defined by swtich cm_elh2_CF
*** check that value is meaningful between 0 and 1
if ( cm_elh2_CF gt 0 AND cm_elh2_CF le 1,
  vm_capFac.fx(t,regi,"elh2")$(t.val ge 2010) = cm_elh2_CF;
);

*** if flexibility tax with feedback is on, let capacity factor be endogenuously determined between 0.1 and 1
*** for technologies that get flexibility tax/subsity (teFlexTax)
if ( cm_flex_tax eq 1,
  if ( cm_FlexTaxFeedback eq 1,
	  vm_capFac.lo(t,regi,teFlexTax)$(t.val ge 2010) = 0.1;
    vm_capFac.up(t,regi,teFlexTax)$(t.val ge 2010) = pm_cf(t,regi,teFlexTax);
  );
);

*** if flexibility tax is on but feedback if off,
*** electricity price of inflexible technologies shouild be the same as w/o feedback
if ( cm_flex_tax eq 1,
  if ( cm_FlexTaxFeedback eq 0,
    v32_flexPriceShare.fx(t,regi,te)$(teFlexTax(te) AND NOT(teFlex(te))) = 1;
  );
);

*** end capacity factor electrolysis



*** Lower bounds on VRE use (more than 0.01% of electricity demand) after 2015 to prevent the model from overlooking solar and wind
loop(regi,
  loop(te$(teVRE(te)),
    if ( (sum(rlf, pm_dataren(regi,"maxprod",rlf,te)) > 0.01 * pm_IO_input(regi,"seel","feels","tdels")) ,
         vm_shSeEl.lo(t,regi,te)$(t.val>2020) = 0.01; 
    );
  );
);

*RP* upper bound of 90% on share of electricity produced by a single VRE technology, and lower bound on usablese to prevent the solver from dividing by 0
vm_shSeEl.up(t,regi,teVRE) = 90;

vm_usableSe.lo(t,regi,"seel")  = 1e-6;

*** Fix capacity for h2curt technology (modeled only in RLDC)
vm_cap.fx(t,regi,"h2curt",rlf) = 0;


*RP To ensure that the REMIND model doesn't overlook CSP due to gdx effects, ensure some minimum use in regions with good solar insolation, here proxied from the csp storage factor:
loop(regi$(p32_factorStorage(regi,"csp") < 1),
  vm_shSeEl.lo(t,regi,"csp")$(t.val > 2025) = 0.5;
  vm_shSeEl.lo(t,regi,"csp")$(t.val > 2050) = 1;
  vm_shSeEl.lo(t,regi,"csp")$(t.val > 2100) = 2;
);

*** Fix capacity to 0 for elh2VRE now that the equation q32_elh2VREcapfromTestor pushes elh2, not anymore elh2VRE, and capital costs are 1
vm_cap.fx(t,regi,"elh2VRE",rlf) = 0;

*** EOF ./modules/32_power/IntC/bounds.gms
