*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/31_fossil/MOFEX/bounds.gms
*===========================================
* MODULE.....: 31 FOSSIL
* REALISATION: MOFEX
* FILE.......: bounds.gms
*===========================================
* Decription: This realisation activates time-dependent grade structures for
*   oil, gas and coal. This enables to take into account exogenous technological
*   change for example.
*===========================================
* Authors...: SB
* Wiki......: http://redmine.pik-potsdam.de/projects/remind-r/wiki/31_fossil
* History...:
*   - 2019-09-10 : Creation
*===========================================

*------------------------------------
*' @code
*------------------------------------
option nlp = conopt4;  !! Greatly speed up convergence process (x3~x4)

*------------------------------------
*' Lower bounds on fossil fuel extraction for all time steps
*' To make the model "see" all grades
*------------------------------------
loop(regi,
  loop(peFos(enty),
    loop(rlf,
      loop(t,
***         Set a lower bound on fuel extraction when p31_grades if non-zero
        if (p31_grades(t,regi,"xi3",enty,rlf) gt 0,
          vm_fuExtr.lo(t,regi,pe2rlf(enty,rlf)) = 1e-9;
        );
      );
    );
  );
);

*------------------------------------
*' Special case for grades declining to a zero value
*' Set lower and upper bounds to 0.0 to make the model converge.
*' p31_grades declines linearly whereas vm_fuExtr declines exponentially
*' This particular situation prevent the model from finding a solution
*' [TODO] In the future a small amount should be added to p31_grades to 
*'        allow for extraction from these grades
*------------------------------------
loop(regi,
  loop(peFos(enty),
    loop(rlf,
      if (p31_grades("2005",regi,"xi3",enty,rlf) gt 0.0 and p31_grades("2035",regi,"xi3",enty,rlf) eq 0.0,
***         For grades larger than 6 do not extract anything
        vm_fuExtr.up(t,regi,pe2rlf(enty,rlf))$(rlf.val ge 6) = 0.0;
        vm_fuExtr.lo(t,regi,pe2rlf(enty,rlf))$(rlf.val ge 6) = 0.0;

***         For other grades, do the same for now 
        vm_fuExtr.up(t,regi,pe2rlf(enty,rlf))$(rlf.val lt 6) = 0.0;
        vm_fuExtr.lo(t,regi,pe2rlf(enty,rlf))$(rlf.val lt 6) = 0.0;
      );
    );
  );
);

if (s31_debug eq 1,
  display vm_fuExtr.lo, vm_fuExtr.up;
);


*------------------------------------
*** Upper bound on cumulative fossil fuel extraction
*------------------------------------
v31_fuExtrCum.up(t,regi,peExGrade(enty),rlf) = p31_grades(t,regi,"xi3",enty,rlf);


*------------------------------------
*' Upper bound on fossil fuel costs
*------------------------------------
***Fixing resource cost upper bound to 10 $/Wa (eq. to 316 $/GJ)
vm_costFuEx.up(t,regi,peExGrade(enty)) = 10.0;

*' @stop

*------------------------------------
*** [Optional] Oil retirement to allow a region to extract less than the lower bound imposed by the decline rate
*------------------------------------
$IFTHEN.cm_OILRETIRE %cm_OILRETIRE% == "on"
  loop(enty2rlf_dec(enty,rlf)$(sameas(enty,"peoil")),
***   multiplying the total grade size by the maximum allowed decrease percentage gives the maximum possible extraction
    p31_max_oil_extraction(regi,enty,rlf) = p31_grades("2020",regi,"xi3",enty,rlf) * p31_datafosdyn(regi,enty,rlf,"dec"); 
***   0.5 is an arbitrarily set upper limit that is probably never reached.
    v31_fuSlack.up(t,regi,enty,rlf) = 0.5 * p31_grades(t,regi,"xi3",enty,rlf) * p31_datafosdyn(regi,enty,rlf,"dec");
    v31_fuSlack.fx("2005",regi,enty,rlf) = 0;
    v31_fuSlack.fx("2010",regi,enty,rlf) = 0;  
  );
  v31_fuSlack.fx(t,regi,enty,rlf)$(NOT SAMEAS(enty,"peoil")) = 0;
$ENDIF.cm_OILRETIRE

*------------------------------------
*** Specific upper bounds
*------------------------------------

*------------------------------------
*** Upper bound on oil extraction
*------------------------------------
*** Otherwise the model extracts everything from MEA, the cheapest region
*** vm_XpRes in 2005 should be equal to 1.4876897061 TWa (46.86 EJ)
*** BP statistics, 2012 says that MEA produced 1.980321 TWa in 2005 and 1.955456 TWa in 2010, however
*** there a linear fit with an average increase of 1.5% per year was found e.g 7% per 5-year period
*** Low and medium resource cases

$ifthen.oilscen %cm_oil_scen% == "lowOil"
vm_Xport.up(t,regi,enty)$(t.val ge 2020 AND t.val le 2035 AND sameas(enty,"peoil")) = 
    f31_Xport(t,regi,enty,"SSP1")$(t.val ge 2020 AND t.val le 2035 AND sameas(enty,"peoil") AND f31_Xport(t,regi,enty,"SSP1") ne 0);
$elseif.oilscen %cm_oil_scen% == "medOil"
vm_Xport.up(t,regi,enty)$(t.val ge 2020 AND t.val le 2035 AND sameas(enty,"peoil")) = 
    f31_Xport(t,regi,enty,"SSP2")$(t.val ge 2020 AND t.val le 2035 AND sameas(enty,"peoil") AND f31_Xport(t,regi,enty,"SSP2") ne 0);
$elseif.oilscen %cm_oil_scen% == "highOil"
vm_Xport.up(t,regi,enty)$(t.val ge 2020 AND t.val le 2035 AND sameas(enty,"peoil")) = 
    f31_Xport(t,regi,enty,"SSP5")$(t.val ge 2020 AND t.val le 2035 AND sameas(enty,"peoil") AND f31_Xport(t,regi,enty,"SSP5") ne 0);
$endif.oilscen


*** EOF ./modules/31_fossil/MOFEX/bounds.gms
