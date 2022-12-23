*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/31_fossil/timeDepGrades/bounds.gms
*===========================================
* MODULE.....: 31 FOSSIL
* REALISATION: timeDepGrades
* FILE.......: bounds.gms
*===========================================
* Decription: This realisation activates time-dependent grade structures for
*   oil, gas and coal. This enables to take into account exogenous technological
*   change for example.
*===========================================
* Authors...: JH, NB, TAC, SB
* Wiki......: http://redmine.pik-potsdam.de/projects/remind-r/wiki/31_fossil
* History...:
*   - 2020-04-15 : Created moinput functions for input data handling, including region-specific constraints
*                  previously in the GAMS code. Data aggregated to H12 regions.
*   - 2015-12-03 : Cleaning up
*   - 2015-02-06 : Add possibility for user-defined fuel extraction in 2005 
*                  (skip automatic allocation)
*                  Code cleaning
*   - 2014-01-09 : Remove lower bound (was source of INFES)
*   - 2013-10-22 : Add lower bound to all grades to make them visible to REMIND
*   - 2013-10-01 : Cleaning up
*   - 2012-05-04 : Creation
*===========================================

*------------------------------------
*** Initialise user-defined fuel extraction in 2005
*------------------------------------
p31_fuelexIni(regi, enty, rlf) = 0.0;
***Example: p31_fuelexIni("EUR","pegas","1") = 0.30;
if (s31_debug eq 1,
  display p31_fuelexIni;
);


*------------------------------------
*** Bounds on decline and incline rates 
*------------------------------------
*Taken from WEO 2008/09 via FFECCM model (written by JH 2012)
* Maximum decline rate for oil, gas and coal
p31_datafosdyn(regi, "pegas",  rlf, "dec")$(p31_datafosdyn(regi, "pegas",  rlf, "dec") eq 0) = 0.15;
p31_datafosdyn(regi, "peoil",  rlf, "dec")$(p31_datafosdyn(regi, "peoil",  rlf, "dec") eq 0) = 0.15;
p31_datafosdyn(regi, "pecoal", rlf, "dec")$(p31_datafosdyn(regi, "pecoal", rlf, "dec") eq 0) = 0.15;

* Maximum extraction rate increase of oil, gas and coal
p31_datafosdyn(regi, "pegas",  rlf, "inc") = 0.1;
p31_datafosdyn(regi, "peoil",  rlf, "inc") = 0.1;
p31_datafosdyn(regi, "pecoal", rlf, "inc") = 0.1;


*------------------------------------
*** Upper bounds on fossil fuel extraction in 2005
*------------------------------------
***Initialise resource extraction in 2005 as a function of primary energy demand (v05_INIdemEn0) and trade (pm_IO_trade)
if(ord(iteration) eq 1,
  loop(regi,
    loop(peFos(enty),
***     Now allocate the remaining amount of FF demand to the grades in increasing order
      loop(rlf,
        if(pm_prodIni(regi,enty) ge 0,
***         Initialise production share
          p31_prodShare(regi,enty,rlf) = 0;
***         Calculate production share as a function of the decline rate (assuming depletion over 50 years)
          p31_prodShare(regi,enty,rlf) = p31_datafosdyn(regi,enty,rlf,"dec")/(1-exp(-50*p31_datafosdyn(regi,enty,rlf,"dec")));
***         If the quantity in grade rlf increases over time from 2005 to 2030
          if (p31_grades("2050",regi,"xi3",enty,rlf) gt p31_grades("2005",regi,"xi3",enty,rlf),
***           If a user-defined upper bound is not defined then compute .up using demand information
            if (p31_fuelexIni(regi, enty, rlf) eq 0.0,
***             Update p31_prod_ini
              pm_prodIni(regi,enty) = pm_prodIni(regi,enty) - p31_prodShare(regi,enty,rlf)*p31_grades("2005",regi,"xi3",enty,rlf);
***             Set vm_fuExtr upper bound
              vm_fuExtr.up("2005",regi,pe2rlf(enty,rlf)) = p31_prodShare(regi,enty,rlf)*p31_grades("2005",regi,"xi3",enty,rlf);
            else
***           Otherwise use it
***             Update p31_prod_ini
              pm_prodIni(regi,enty) = pm_prodIni(regi,enty) - p31_fuelexIni(regi, enty, rlf);
***             Set vm_fuExtr upper bound
              vm_fuExtr.up("2005",regi,pe2rlf(enty,rlf)) = p31_fuelexIni(regi, enty, rlf);
            );
          else
***         If the quantity in grade rlf decreases over time from 2005 to 2030 (or is constant)
***           If a user-defined upper bound is not defined then compute .up using demand information
            if (p31_fuelexIni(regi, enty, rlf) eq 0.0,
***             Update p31_prod_ini
              pm_prodIni(regi,enty) = pm_prodIni(regi,enty) - p31_prodShare(regi,enty,rlf)*p31_grades("2035",regi,"xi3",enty,rlf);
***             Set vm_fuExtr upper bound
              vm_fuExtr.up("2005",regi,pe2rlf(enty,rlf)) = p31_prodShare(regi,enty,rlf)*p31_grades("2035",regi,"xi3",enty,rlf);
            else
***           Otherwise use it
***             Update p31_prod_ini
              pm_prodIni(regi,enty) = pm_prodIni(regi,enty) - p31_fuelexIni(regi, enty, rlf);
***             Set vm_fuExtr upper bound
              vm_fuExtr.up("2005",regi,pe2rlf(enty,rlf)) = p31_fuelexIni(regi, enty, rlf);
            );
          );
        else
***         Tiny amount of fuel extraction possible in other grades
          vm_fuExtr.up("2005",regi,pe2rlf(enty,rlf)) = 1e-9;
        );
      );
    );
  );

*------------------------------------
*** [Optional] MOFEX
*------------------------------------
*** If MOFEX was run, fix fossil fuel extraction, cumulative FF Ext. and trade to values computed by MOFEX
$IFTHEN.mofex %cm_MOFEX% == "on"
  vm_fuExtr.l(ttot,regi,pe2rlf(peExGrade(enty),rlf))      = p31_MOFEX_fuelex_costMin(ttot,regi,enty,rlf);
  v31_fuExtrCum.l(ttot,regi,pe2rlf(peExGrade(enty),rlf)) = p31_MOFEX_cumfex_costMin(ttot,regi,enty,rlf);
  vm_Mport.l(ttot,regi,peExGrade(trade))                    = p31_MOFEX_Mport_costMin(ttot,regi,trade);
  vm_Xport.l(ttot,regi,peExGrade(trade))                    = p31_MOFEX_Xport_costMin(ttot,regi,trade);
$ENDIF.mofex

);

*------------------------------------
*' @code
*'
*' Lower bounds on fossil fuel extraction for all time steps
*' To make the model "see" all grades
*------------------------------------
if(ord(iteration) eq 1,
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
);

*------------------------------------
*' Special case for grades declining to a zero value
*' Set lower and upper bounds to 0.0 to make the model converge.
*' p31_grades declines linearly whereas vm_fuExtr declines exponentially
*' This particular situation prevent the model from finding a solution
*' [TODO] In the future a small amount should be added to p31_grades to 
*'        allow for extraction from these grades
*------------------------------------
if(ord(iteration) eq 1,
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
  loop(enty2rlf_dec(enty,rlf)$(sameas(enty,"peoil")),
***   multiplying the total grade size by the maximum allowed decrease percentage gives the maximum possible extraction
    p31_max_oil_extraction(regi,enty,rlf) = p31_grades("2020",regi,"xi3",enty,rlf) * p31_datafosdyn(regi,enty,rlf,"dec"); 
***   0.5 is an arbitrarily set upper limit that is probably never reached.
    v31_fuSlack.up(t,regi,enty,rlf) = 0.5 * p31_grades(t,regi,"xi3",enty,rlf) * p31_datafosdyn(regi,enty,rlf,"dec");
    v31_fuSlack.fx("2005",regi,enty,rlf) = 0;
    v31_fuSlack.fx("2010",regi,enty,rlf) = 0;  
  );
  v31_fuSlack.fx(t,regi,enty,rlf)$(NOT SAMEAS(enty,"peoil")) = 0;

*------------------------------------
*** Specific upper bounds
*------------------------------------

*------------------------------------
*** Upper bound on oil exports
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

*------------------------------------
*** Regionalised upper bound on uranium extraction
*------------------------------------
v31_fuExtrCum.up(ttot,regi,"peur", "1") = p31_fuExtrCumMaxBound(regi,"peur", "1");


*** EOF ./modules/31_fossil/timeDepGrades/bounds.gms
