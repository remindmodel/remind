*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/fixed_shares/output.gms

*** Compute ppf prices from CES derivatives
o37_CESderivatives(t,regi,cesOut2cesIn(out,in))$( vm_cesIO.l(t,regi,in) gt 0 )
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
  o37_CESderivatives(t,regi,"inco",in3)
  = o37_CESderivatives(t,regi,"inco",in2)
  * o37_CESderivatives(t,regi,in2,in3);
);

file file_CESderivatives / "o37_CESderivatives.csv" /;

file_CESderivatives.lw =  0;
file_CESderivatives.nw = 20;
file_CESderivatives.nd = 15;

put file_CESderivatives;

put "scenario;t;regi;pf.out;pf.in;value" /;
loop ((t,regi,in)$( NOT sameas(in,"inco") ),
  put "%c_expname%;", t.tl, ";", regi.tl, ";inco;", in.tl, ";";
  put o37_CESderivatives(t,regi,"inco",in) /;
);

loop ((t,regi,cesOut2cesIn(out,in))$( NOT sameas(out,"inco") ),
  put "%c_expname%;", t.tl, ";", regi.tl, ";", out.tl, ";", in.tl, ";";
  put o37_CESderivatives(t,regi,out,in) /;
);

putclose file_CESderivatives;

*** EOF ./modules/37_industry/fixed_shares/output.gms

