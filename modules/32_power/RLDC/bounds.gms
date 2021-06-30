*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
***-----------------------------------------------------------
***                  module specific bounds
***------------------------------------------------------------

vm_usableSe.lo(t,regi,"seel")  = 1e-6;

v32_capLoB.up(t,regi,te,LoB)        =   2;    !! The total power system has maximum demand of 1
v32_LoBheight.up(t,regi,LoB)        =   2;    !! The total power system has maximum demand of 1
v32_LoBheightCum.up(t,regi,LoB)     =   2;    !! The total power system has maximum demand of 1.5 (should be one, but the reforming of the baseload band leads to
v32_shTh.up(t,regi,teVRE)          =   2;    !! Worlds with higher than twice the total energy demand coming from either wind or solar (before curtailment) are unrealistic

v32_scaleCap.up(t,regi)             = 100;    !! no power system will be larger than 100 TW
v32_scaleCap.up(t,regi)            = 20;
v32_scaleCap.lo(t,regi)            = 1e-4;   !! Make sure REMIND does not try to shrink a power system to zero
v32_scaleCap.lo(t,regi)            = 0.01;

loop(te$(NOT teRLDCDisp(te)),
  vm_capFac.fx(t,regi,te) = pm_cf(t,regi,te);
);

vm_capFac.up(t,regi,teRLDCDisp) = 1.00;
vm_capFac.l(t,regi,teRLDCDisp) = pm_cf("2005",regi,teRLDCDisp) * pm_dataren(regi,"nur","1",teRLDCDisp);

v32_capLoB.lo(t,regi,teRLDCDisp,LoB)$(t.val>2015) = 1e-6; !!Lower bound to capacity to avoid infeasibility
*v32_capLoB.lo("2005",regi,"geohdr",LoB) = 1e-6;  !!Necessary to avoid infeasibility due to geohdr being zero in all LoB except for the 4th LoB, making impossible to the vm_capFac to match the v32_capLoB sum, with the lack of v32_capER in the initial year and a p32_capFacLoB != 1

*RP* CCS technologies can make a problem if the caps are fixed to 0, but the capLoBs left free
loop(regi,
  if ( (cm_ccapturescen eq 2) OR (cm_emiscen eq 1) , !! in no-CCS and BAU scenarios, no CCS is allowed
    loop(emi2te(enty,"seel",te,"cco2")$( pm_emifac("2020",regi,enty,"seel",te,"cco2") >0 ),  !! use 2020 as proxy - only limit the seel technologies - the others don't have a capFac and capLob and capER
      loop(te2rlf(te,rlf),
        vm_capFac.fx(ttot,regi,te)      = 0;
        v32_capLoB.fx(t,regi,te,LoB)    = 0;
        v32_capER.fx(t,regi,te)         = 0;
      );
    );
  elseif (cm_ccapturescen eq 5), !! noElecCCS
    loop(emi2te(enty,"seel",te,"cco2")$( pm_emifac("2020",regi,enty,"seel",te,"cco2") >0 ),
      loop(te2rlf(te,rlf),
        vm_capFac.fx(ttot,regi,te)      = 0;
        v32_capLoB.fx(t,regi,te,LoB)    = 0;
        v32_capER.fx(t,regi,te)         = 0;
      );
    );
  );
);

*Avoiding infeasibilities from upper limit on CCS deployment in 2020
loop(regi,
	if( (pm_boundCapCCS(regi) eq 0),
		vm_capFac.fx("2020",regi,teCCS)      = 0;
        v32_capLoB.fx("2020",regi,teCCS,LoB)    = 0;
        v32_capER.fx("2020",regi,teCCS)         = 0;
    );
);


*RP same for nuc:
if ( (cm_nucscen eq 5) , !! in no-Nuc scenarios, no tnrs is allowed
  loop(pe2se("peur",enty,te),
    vm_capFac.fx(t,regi,te)$(t.val > 2060)         = 0;
    v32_capLoB.fx(t,regi,te,LoB)$(t.val > 2060)    = 0;
    v32_capER.fx(t,regi,te)$(t.val > 2060)         = 0;
  );
);

vm_capFac.fx(t,regi,"fnrs")= 0;
v32_capLoB.fx(t,regi,"fnrs",LoB)= 0;
v32_capER.fx(t,regi,"fnrs")= 0;

v32_curt.lo(t,regi)$(t.val>2010)  = 0;

*RP* CHP technologies should not have larger CFs than 0.6, as heat is not always needed. They can still contribute to
*** baseload, but then some other part of the total capacity needs to be underutilized - this could represent costs for thermal storage
loop(te$teChp(te),
  vm_capFac.up(t,regi,te)$(t.val > 2005) = 0.6;
);

***----------------------------------------------
*RP: bounds to make the first runs more feasible
***----------------------------------------------
loop(regi,
  loop(te$( (teRLDCDisp(te)) ),
     if( ( pm_cap0(regi,te) > 0 ) ,
      vm_capFac.up("2005",regi,te) = 1.01 * pm_cf("2005",regi,te);
      vm_capFac.lo("2005",regi,te) = 0.98 * pm_cf("2005",regi,te);
      vm_capFac.lo("2010",regi,te) = 0.009;
      vm_capFac.lo("2015",regi,te) = 0.009;
      if( teReNoBio(te),
        vm_capFac.up("2005",regi,te) = 1.01 * pm_dataren(regi,"nur","1",te) *  pm_cf("2005",regi,te);
        vm_capFac.lo("2005",regi,te) = 0.4 * pm_dataren(regi,"nur","1",te) * pm_cf("2005",regi,te);
      );
      else
        vm_capFac.fx("2005",regi,te) = 0;
    );
  );
);

vm_capFac.up(t,regi,"hydro")$(t.val > 2005) = 0.25;  !! Japan has quite low hydro CFs, so the rule "0.4 * pm_dataren(regi,"nur","1",te)" produces infeasibilities

vm_capFac.lo("2005",regi,"hydro") = 0.2;  !! Japan has quite low hydro CFs, so the rule "0.4 * pm_dataren(regi,"nur","1",te)" produces infeasibilities. As the 2005 bounds are anyway only there to facilitate that the model finds an initial solution, set this limit for all regions

***-----------------------------------------------------
***
***-----------------------------------------------------

***v32_LoBheightCum.lo(t,regi,LoB) = 0.01;
v32_LoBheightCum.lo("2010",regi,"1") = 0.82;
v32_LoBheightCum.lo("2010",regi,"2") = 0.48;
v32_LoBheightCum.lo("2010",regi,"3") = 0.38;
v32_LoBheightCum.lo("2010",regi,"4") = 0.26;

v32_shTh.lo(t,regi,"spv")$(t.val > 2020)           =   0.01;
v32_shTh.lo(t,regi,"wind")$(t.val > 2020)          =   0.01;

v32_curt.up(t,regi)  = 100;
$if %cm_Full_Integration% == "on"  v32_curt.fx(t,regi)  = 0;

*** Advanced technologies can't be build prior to 2015/2020
loop(regi,
  loop(teNoLearn(te),
    if( (pm_data(regi,"tech_stat",te) eq 2),
      v32_capLoB.fx("2010",regi,te,LoB)        =   0;
    elseif (pm_data(regi,"tech_stat",te) eq 3),
      v32_capLoB.fx("2010",regi,te,LoB)        =   0;
      v32_capLoB.fx("2015",regi,te,LoB)        =   0;
    );
  );
);

*** nuclear only as baseload
v32_capLoB.fx(t,regi,"tnrs","1")$(t.val > 2010)    = 0;
v32_capLoB.fx(t,regi,"tnrs","2")$(t.val > 2010)    = 0;
v32_capLoB.fx(t,regi,"tnrs","3")$(t.val > 2010)    = 0;


*** facilitiate finding sulutions in the ADVANCE Full_Integration run
$if %cm_Full_Integration% == "on"  v32_capLoB.lo(t,regi,"spv",LoB)$(t.val > 2030)        =   1e-6;
$if %cm_Full_Integration% == "on"  v32_capLoB.lo(t,regi,"wind",LoB)$(t.val > 2030)       =   1e-6;
$if %cm_Full_Integration% == "on"  vm_cap.lo(t,regi,"spv",LoB)$(t.val > 2030)        =   1e-3;
$if %cm_Full_Integration% == "on"  vm_cap.lo(t,regi,"wind",LoB)$(t.val > 2030)       =   1e-3;

***No slow ramping technologies as peaking plants
v32_capLoB.fx(t,regi,te,"1")$teNotLoB1(te)     = 0;
***Technologies that can not run for 7500 FLh, and therefore cannot be considered at baseload
v32_capLoB.fx(t,regi,te,"4")$teNotBase(te)     = 0;

***Make sure the model sees the h2-el connections
vm_cap.lo(t,regi,"h2turb","1")$(t.val > 2050)           = 1e-6;
vm_cap.lo(t,regi,"elh2","1")$(t.val > 2050)             = 1e-6;
vm_cap.lo(t,regi,"h2curt","1")$(t.val > 2090)           = 1e-5;
$if %cm_Full_Integration% == "on"  vm_cap.fx(t,regi,"h2curt","1")         = 0;
$if %cm_Full_Integration% == "on"  vm_deltaCap.fx(t,regi,"h2curt","1")     = 0;

*** Allow the curtailment->H2 channel:
vm_prodSeOth.up(t,regi,"seh2","h2curt")                                   = 1e6;
vm_prodSeOth.lo(t,regi,"seh2","h2curt")$(t.val > 2090)                     = 1e-6;

$if %cm_Full_Integration% == "on"  vm_prodSeOth.fx(t,regi,"seh2","h2curt")   = 0;    !! no curtailment if all VRE are treated as dispatchable

vm_cap.fx(t,regi,"gridspv","1")$(t.val > 2070)           = 0;
vm_cap.fx(t,regi,"gridcsp","1")$(t.val > 2070)           = 0;
vm_cap.fx(t,regi,"storcsp","1")$(t.val > 2070)           = 0;
vm_cap.fx(t,regi,"storwind","1")$(t.val > 2070)           = 0;
$IFTHEN.WindOff %cm_wind_offshore% == "1"
vm_cap.fx(t,regi,"storwindoff","1")$(t.val > 2070)           = 0;
$ENDIF.WindOff

$if %cm_Full_Integration% == "on" vm_cap.fx(t,regi,"storspv","1")               = 0;
$if %cm_Full_Integration% == "on" vm_deltaCap.fx(t,regi,"storspv","1")           = 0;

vm_deltaCap.up(t,regi,"dot",rlf)$(t.val > 2040) = 1e-5;
