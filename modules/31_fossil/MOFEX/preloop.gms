*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/31_fossil/MOFEX/preloop.gms
*===========================================
* MODULE.....: 31 FOSSIL
* REALISATION: MOFEX
* FILE.......: preloop.gms
*===========================================
* Decription: This realisation activates time-dependent grade structures for
*   oil, gas and coal. This enables to take into account exogenous technological
*   change for example.
*===========================================
* Authors...: SB
* Wiki......: http://redmine.pik-potsdam.de/projects/remind-r/wiki/31_fossil
* History...:
*   - 2012-09-10 : Creation
*===========================================

***--------------------------------------
*** ADDITIONAL HIGH/LOW COSTS OIL SCENARIOS
***--------------------------------------
* High cost oil scenario with learning (from ADVANCE WP3.1)

$IFTHEN.cm_oil_scen "%cm_oil_scen%" == "6" 

if ( (cm_startyear le 2005),
  v31_fuExtrCum.l("2010","LAM","peoil","2") = 0;
  v31_fuExtrCum.l("2010","OAS","peoil","2") = 0;
  v31_fuExtrCum.l("2010","USA","peoil","2") = 0;
  v31_fuExtrCum.l("2010","IND","peoil","2") = 0;
  v31_fuExtrCum.l("2010","IND","peoil","4") = 0;
  v31_fuExtrCum.l("2010","CHA","peoil","2") = 0;
  v31_fuExtrCum.l("2010","EUR","peoil","2") = 0;
  v31_fuExtrCum.l("2010","CAZ","peoil","2") = 0;
  v31_fuExtrCum.l("2010","JPN","pegas","3") = 0;
); 
***cb: in order to be able to access level values for fixed initial periods, they have to be loaded already here:
*** The followig comment line staring "cb20150605readinpos" is therefore replaced by the R-script scripts/run_submis/submit.R with the include statements for the levs.gms file
*** cb20150605readinpositionforlevelfile
if ( (cm_startyear le 2015),
  p31_grades(t,"LAM","xi3","peoil","2") = max(p31_grades(t,"LAM","xi3","peoil","2"), 1.9*v31_fuExtrCum.l("2010","LAM","peoil","2"));
  p31_grades(t,"OAS","xi3","peoil","2") = max(p31_grades(t,"OAS","xi3","peoil","2"), 2.0*v31_fuExtrCum.l("2010","OAS","peoil","2"));
  p31_grades(t,"USA","xi3","peoil","2") = max(p31_grades(t,"USA","xi3","peoil","2"), 1.5*v31_fuExtrCum.l("2010","USA","peoil","2"));
  p31_grades(t,"IND","xi3","peoil","2") = max(p31_grades(t,"IND","xi3","peoil","2"), 2.0*v31_fuExtrCum.l("2010","IND","peoil","2"));
  p31_grades(t,"IND","xi3","peoil","4") = max(p31_grades(t,"IND","xi3","peoil","4"), 1.3*v31_fuExtrCum.l("2010","IND","peoil","4"));
  p31_grades(t,"CHA","xi3","peoil","2") = max(p31_grades(t,"CHA","xi3","peoil","2"), 1.6*v31_fuExtrCum.l("2010","CHA","peoil","2"));
  p31_grades(t,"EUR","xi3","peoil","2") = max(p31_grades(t,"EUR","xi3","peoil","2"), 1.3*v31_fuExtrCum.l("2010","EUR","peoil","2"));
  p31_grades(t,"CAZ","xi3","peoil","2") = max(p31_grades(t,"CAZ","xi3","peoil","2"), 1.6*v31_fuExtrCum.l("2010","CAZ","peoil","2"));
  p31_grades(t,"JPN","xi3","pegas","3") = max(p31_grades(t,"JPN","xi3","pegas","3"), 1.3*v31_fuExtrCum.l("2010","JPN","pegas","3"));
);
if ( (cm_startyear gt 2015),
  p31_grades(t,"LAM","xi3","peoil","2") = max(p31_grades(t,"LAM","xi3","peoil","2"), 1.9*v31_fuExtrCum.l("2020","LAM","peoil","2"));
  p31_grades(t,"OAS","xi3","peoil","2") = max(p31_grades(t,"OAS","xi3","peoil","2"), 2.0*v31_fuExtrCum.l("2020","OAS","peoil","2"));
  p31_grades(t,"USA","xi3","peoil","2") = max(p31_grades(t,"USA","xi3","peoil","2"), 1.5*v31_fuExtrCum.l("2020","USA","peoil","2"));
  p31_grades(t,"IND","xi3","peoil","2") = max(p31_grades(t,"IND","xi3","peoil","2"), 2.0*v31_fuExtrCum.l("2020","IND","peoil","2"));
  p31_grades(t,"IND","xi3","peoil","4") = max(p31_grades(t,"IND","xi3","peoil","4"), 1.3*v31_fuExtrCum.l("2020","IND","peoil","4"));
  p31_grades(t,"CHA","xi3","peoil","2") = max(p31_grades(t,"CHA","xi3","peoil","2"), 1.6*v31_fuExtrCum.l("2020","CHA","peoil","2"));
  p31_grades(t,"EUR","xi3","peoil","2") = max(p31_grades(t,"EUR","xi3","peoil","2"), 1.3*v31_fuExtrCum.l("2020","EUR","peoil","2"));
  p31_grades(t,"CAZ","xi3","peoil","2") = max(p31_grades(t,"CAZ","xi3","peoil","2"), 1.6*v31_fuExtrCum.l("2020","CAZ","peoil","2"));
  p31_grades(t,"JPN","xi3","pegas","3") = max(p31_grades(t,"JPN","xi3","pegas","3"), 1.3*v31_fuExtrCum.l("2020","JPN","pegas","3"));
); 
*** Low cost oil scenario with learning (from ADVANCE WP3.1)
$ELSEIF.cm_oil_scen %cm_oil_scen% == "5"
if (cm_startyear le 2015,
  p31_grades(t,"IND","xi3","peoil","4") = max(p31_grades(t,"IND","xi3","peoil","4"), 1.3*v31_fuExtrCum.l("2010","IND","peoil","4"));
  p31_grades(t,"JPN","xi3","peoil","2") = max(p31_grades(t,"JPN","xi3","peoil","2"), 1.6*v31_fuExtrCum.l("2010","JPN","peoil","2"));
  p31_grades(t,"JPN","xi3","peoil","3") = max(p31_grades(t,"JPN","xi3","peoil","3"), 1.4*v31_fuExtrCum.l("2010","JPN","peoil","3"));
  p31_grades(t,"JPN","xi3","pegas","3") = max(p31_grades(t,"JPN","xi3","pegas","3"), 1.4*v31_fuExtrCum.l("2010","JPN","pegas","3"));
);
if (cm_startyear gt 2015,
  p31_grades(t,"IND","xi3","peoil","4") = max(p31_grades(t,"IND","xi3","peoil","4"), 1.3*v31_fuExtrCum.l("2020","IND","peoil","4"));
  p31_grades(t,"JPN","xi3","peoil","2") = max(p31_grades(t,"JPN","xi3","peoil","2"), 1.6*v31_fuExtrCum.l("2020","JPN","peoil","2"));
  p31_grades(t,"JPN","xi3","peoil","3") = max(p31_grades(t,"JPN","xi3","peoil","3"), 1.4*v31_fuExtrCum.l("2020","JPN","peoil","3"));
  p31_grades(t,"JPN","xi3","pegas","3") = max(p31_grades(t,"JPN","xi3","pegas","3"), 1.4*v31_fuExtrCum.l("2020","JPN","pegas","3"));
);
$ENDIF.cm_oil_scen

***--------------------------------------
*** MOFEX
***--------------------------------------
*** Small partial model to compute level values of fossil fuel extraction (vm_fuExtr.l) given a 
*** specific demand path

*** Model statement
model m31_MOFEX /q31_MOFEX_costMinFuelEx, q31_MOFEX_tradebal, q31_fuExtrDec, q31_fuExtrInc, 
                 q31_fuExtrCum, q31_costFuExGrade, qm_fuel2pe/;

*** Get fossil fuel demand (vm_prodPe) from reference GDX (input.gdx)
p31_MOFEX_peprod_ref(ttot,regi,peExGrade(enty)) = 0; 
p31_MOFEX_Xport_ref(ttot,regi,trade) = 0;
p31_MOFEX_Mport_ref(ttot,regi,trade) = 0;
Execute_Loadpoint 'input', 
  p31_MOFEX_peprod_ref = vm_prodPe.l,
  p31_MOFEX_Xport_ref  = vm_Xport.l,
  p31_MOFEX_Mport_ref  = vm_Mport.l;
display p31_MOFEX_peprod_ref;
display p31_MOFEX_Mport_ref;

*** Fixing MOFEX fossil fuel demand to reference GDX data
vm_prodPe.fx(ttot,regi,peExGrade(enty)) = p31_MOFEX_peprod_ref(ttot,regi,enty);

*** Apply other important bounds
v31_fuExtrCum.up(t,regi,peExGrade(enty),rlf)          = p31_grades(t,regi,"xi3",enty,rlf);
vm_costFuEx.up(t,regi,peExGrade(enty))                = 10.0;
vm_Xport.fx(ttot,regi,trade)$(ttot.val lt cm_startyear) = p31_MOFEX_Xport_ref(ttot,regi,trade);  !! To avoid unbounded results
vm_Mport.fx(ttot,regi,trade)$(ttot.val lt cm_startyear) = p31_MOFEX_Mport_ref(ttot,regi,trade);  !! To avoid unbounded results

*** Fix initial year trade to gdx values
vm_Mport.fx(t0(tall),regi,peFos(enty)) = p31_MOFEX_Mport_ref(tall,regi,enty);
vm_Xport.fx(t0(tall),regi,peFos(enty)) = p31_MOFEX_Xport_ref(tall,regi,enty);

display vm_prodPe.l;


*** EOF ./modules/31_fossil/MOFEX/preloop.gms
