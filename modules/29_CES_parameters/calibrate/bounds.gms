*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/29_CES_parameters/calibrate/bounds.gms

vm_cesIO.fx(t0,regi_dyn29(regi),in_industry_dyn37(in))$( 
                                              NOT sameas(in,"en_otherInd_hth") )
  = pm_cesdata(t0,regi,in,"quantity");

*' Reduce the lower limit on the CES function to accommodate less utilised
*' production factors in (energetically) small regions.  (Example: gas heating
*' in Sub-Sahara Africa -- SSA/enhgab).

if (smax((t,regi_dyn29(regi),in)$(    t.val gt 2005 
                                  AND NOT ue_industry_dyn37(in) ),
      vm_cesIO.lo(t,regi,in)
    - (0.95 * pm_cesdata(t,regi,in,"quantity"))) gt 0,

  put logfile, ">>> Modifying vm_cesIO lower bounds <<<" /;
  loop ((regi_dyn29(regi),in,t)$( t.val gt 2005 AND NOT ue_industry_dyn37(in) ),
    if (vm_cesIO.lo(t,regi,in) gt 0.95 * pm_cesdata(t,regi,in,"quantity"),
      put "vm_cesIO.lo(", t.tl, ",", regi.tl, ",", in.tl, ")   ";
      put vm_cesIO.lo(t,regi,in), " -> ";
      put (0.95 * pm_cesdata(t,regi,in,"quantity")) /;
  
      vm_cesIO.lo(t,regi,in)
      = min(
          vm_cesIO.lo(t,regi,in),
          ( pm_cesdata(t,regi,in,"quantity")
          * 0.95
          ));
    );
  );

  putclose logfile, " " /;
);

*' relax industry fixing over the calibration iterations
sm_tmp = 5;  !! last iteration with bounds on industry
loop (pf_industry_relaxed_bounds_dyn37(in),
  vm_cesIO.lo(t_29(t),regi_dyn29(regi),in)
  = pm_cesdata(t,regi,in,"quantity")
  * max(1e-12, 0.95 + min(0, (1 - %c_CES_calibration_iteration%) / sm_tmp));

  vm_cesIO.up(t,regi_dyn29(regi),in)
  = ( pm_cesdata(t,regi,in,"quantity")
    * (1.05 + max(0, (%c_CES_calibration_iteration% - 1) / sm_tmp))
    )$( %c_CES_calibration_iteration% le sm_tmp )
  + INF$( %c_CES_calibration_iteration% gt sm_tmp );
);

*** EOF ./modules/29_CES_parameters/calibrate/bounds.gms
