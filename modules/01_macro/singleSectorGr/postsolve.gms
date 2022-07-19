*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/01_macro/singleSectorGr/postsolve.gms
*** Consumption per capita
pm_consPC(ttot,regi)$(ttot.val gt 2005 and ttot.val le 2150 and (pm_SolNonInfes(regi) eq 1) ) =
    vm_cons.l(ttot,regi)/pm_pop(ttot,regi)
;

*** Interpolate years
loop(ttot$(ttot.val ge 2005),
	loop(tall$(pm_tall_2_ttot(tall, ttot)),
		pm_consPC(tall,regi) =
		    (1- pm_interpolWeight_ttot_tall(tall)) * pm_consPC(ttot,regi)
		    + pm_interpolWeight_ttot_tall(tall) * pm_consPC(ttot + 1,regi);
));
pm_consPC(tall,regi)$(tall.val gt 2150) = pm_consPC("2150",regi);


*** output parameter for diagnostics

*** Compute ppf prices from CES derivatives
o01_CESderivatives(t,regi,cesOut2cesIn(out,in))$( vm_cesIO.l(t,regi,in) gt 0 )
  =
    pm_cesdata(t,regi,in,"xi")
  * pm_cesdata(t,regi,in,"eff")
  * vm_effGr.l(t,regi,in)

  * vm_cesIO.l(t,regi,out)
 ** (1 - pm_cesdata(t,regi,out,"rho"))

  * ( pm_cesdata(t,regi,in,"eff")
    * vm_effGr.l(t,regi,in)
    * vm_cesIO.l(t,regi,in)
    )
 ** (pm_cesdata(t,regi,out,"rho") - 1)
;

loop ((cesLevel2cesIO(counter,in),cesOut2cesIn(in,in2),cesOut2cesIn2(in2,in3)),
  o01_CESderivatives(t,regi,"inco",in3)
  = o01_CESderivatives(t,regi,"inco",in2)
  * o01_CESderivatives(t,regi,in2,in3);
);


*** compute marginal rate of substitution between primary production factors as ratio of CES prices
*** provides the amount of in2 needed to subsitute one unit of in to generate the same economic value
loop((cesOut2cesIn(out,in),cesOut2cesIn2(out,in2))$(ppfen(in)),
  o01_CESmrs(t,regi,in,in2)
  =
  o01_CESderivatives(t,regi,"inco",in) /
  o01_CESderivatives(t,regi,"inco",in2)
  );

*** total CES efficiency as diagnostic output parameter
o01_totalCESEff(ttot,regi,in) = sum(cesOut2cesIn(out,in), 
                               pm_cesdata(ttot,regi,in,"xi") 
                               ** (1/pm_cesdata(ttot,regi,out,"rho"))
                               * pm_cesdata(ttot,regi,in,"eff")
                               * vm_effGr.l(ttot,regi,in));
                      
                             
*** EOF ./modules/01_macro/singleSectorGr/postsolve.gms
