*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/29_CES_parameters/calibrate/output.gms
p29_CESderivative(t,regi_dyn29(regi),cesOut2cesIn(out,in))$( vm_cesIO.l(t,regi,in) gt 0 )
  =
    pm_cesdata(t,regi,in,"xi")
  * pm_cesdata(t,regi,in,"eff")
  * vm_effGr.l(t,regi,in)
  
  * (vm_cesIO.l(t,regi,out)$( NOT ipf_putty(out))
       + vm_cesIOdelta.l(t,regi,out)$( ipf_putty(out))
     )
 ** (1 - pm_cesdata(t,regi,out,"rho"))

  * ( pm_cesdata(t,regi,in,"eff")
    * vm_effGr.l(t,regi,in)
    * (vm_cesIO.l(t,regi,in)$( NOT ipf_putty(out))
       + vm_cesIOdelta.l(t,regi,in)$( ipf_putty(out))
       )
    )
 ** (pm_cesdata(t,regi,out,"rho") - 1);
;

*** Propagate price down the CES tree
loop ((cesLevel2cesIO(counter,in),cesOut2cesIn(in,in2),cesOut2cesIn2(in2,in3)),
  p29_CESderivative(t,regi_dyn29(regi),"inco",in3)
  = p29_CESderivative(t,regi,"inco",in2)
  * p29_CESderivative(t,regi,in2,in3);
);

*** Prices of intermediate production factors are all 1
***p29_CESderivative(t,regi_dyn29(regi),in,ipf_29(in2))$( p29_CESderivative(t,regi,in,in2) ) = 1;

*** Transfer prices
pm_cesdata(t,regi_dyn29(regi),in,"price") 
  = p29_CESderivative(t,regi,"inco",in);

  
put file_CES_calibration;

loop ((t,regi_dyn29(regi),in)$(   ppf_29(in) 
                               OR ppf_beyondcalib_29(in) 
                               OR sameas(in,"inco")
                               OR ppf_putty(in)          ),
  put "%c_expname%", sm_CES_calibration_iteration:0:0, t.tl, regi.tl;
  put "efficiency", in.tl;
  put (pm_cesdata("2005",regi,in,"eff") * vm_effGr.l(t,regi,in)) /;

  put "%c_expname%", sm_CES_calibration_iteration:0:0, t.tl, regi.tl;
  put "efficiency growth", in.tl, vm_effGr.l(t,regi,in) /;

  put "%c_expname%", sm_CES_calibration_iteration:0:0, t.tl, regi.tl, "xi";
  put in.tl, pm_cesdata(t,regi,in,"xi") /;
);

loop ((t,regi_dyn29(regi),in)$(    NOT in_putty(in) 
                               AND (   ppf_29(in) 
                                    OR ppf_beyondcalib_29(in) 
                                    OR sameas(in,"inco"))     ),
  put "%c_expname%", sm_CES_calibration_iteration:0:0, t.tl, regi.tl; 
  put "quantity", in.tl, vm_cesIO.l(t,regi,in) /;
    
  put "%c_expname%", sm_CES_calibration_iteration:0:0, t.tl, regi.tl, "price";
  put in.tl, pm_cesdata(t,regi,in,"price") /;
    
  put "%c_expname%", sm_CES_calibration_iteration:0:0, t.tl, regi.tl; 
  put "total efficiency", in.tl;
  put sum(cesOut2cesIn(out,in), 
        pm_cesdata(t,regi,in,"xi")
     ** (1 / pm_cesdata(t,regi,out,"rho"))
      * ( pm_cesdata("2005",regi,in,"eff")
        * vm_effGr.l(t,regi,in)
        ) 
      ) /;
);

loop ((t,regi_dyn29(regi),in)$(     in_putty(in) 
                               AND (   ppf_29(in) 
                                    OR ppf_beyondcalib_29(in) 
                                    OR sameas(in,"inco"))
                               OR ppf_putty(in)               ),
  put "%c_expname%", sm_CES_calibration_iteration:0:0, t.tl, regi.tl; 
  put "quantity_putty", in.tl, vm_cesIOdelta.l(t,regi,in) /;
    
  put "%c_expname%", sm_CES_calibration_iteration:0:0, t.tl, regi.tl, "price_putty";
  put in.tl, pm_cesdata(t,regi,in,"price") /;
    
  put "%c_expname%", sm_CES_calibration_iteration:0:0, t.tl, regi.tl; 
  put "total efficiency putty", in.tl;
  put sum(cesOut2cesIn(out,in), 
        pm_cesdata(t,regi,in,"xi")
     ** (1 / pm_cesdata(t,regi,out,"rho"))
      * ( pm_cesdata("2005",regi,in,"eff")
        * vm_effGr.l(t,regi,in)
        ) 
      ) /;
);

loop ((ttot,regi_dyn29(regi),te_29_report),
  put "%c_expname%", sm_CES_calibration_iteration:0:0, ttot.tl, regi.tl;
  put "vm_deltaCap", te_29_report.tl;
  put sum(rlf,vm_deltacap.L(ttot,regi,te_29_report,rlf)) /;
);

loop ((t,regi_dyn29(regi),in),
  if (vm_cesIO.lo(t,regi,in) ne 0,
    put "%c_expname%", sm_CES_calibration_iteration:0:0, t.tl, regi.tl;
    put "lower bound", in.tl, vm_cesIO.lo(t,regi,in) /;
  );

  if (vm_cesIO.up(t,regi,in) ne INF,
    put "%c_expname%", sm_CES_calibration_iteration:0:0, t.tl, regi.tl;
    put "upper bound", in.tl, vm_cesIO.up(t,regi,in) /;
  );
);

putclose file_CES_calibration;

*** EOF ./modules/29_CES_parameters/calibrate/output.gms
