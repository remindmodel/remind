*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/02_welfare/ineqLognormal/datainput.gms

pm_welf(ttot)$(ttot.val ge 2005) = 1;
$if %cm_less_TS% == "on"  pm_welf("2060") = 0.9;

*RP* 2012-03-06: Inconvenience costs on seprod
$IFTHEN.INCONV %cm_INCONV_PENALTY% == "on"
p02_inconvpen_lap(ttot,regi,"coaltr")$(ttot.val ge 2005)      = 0.5;   !! In dollar per GJ seprod at 1.000$/cap GDP, or 10$/GJ at 10.000$_GDP/cap
p02_inconvpen_lap(ttot,regi,"biotr")$(ttot.val ge 2005)       = 1.0;   !! In dollar per GJ seprod
p02_inconvpen_lap(ttot,regi,"biotrmod")$(ttot.val ge 2005)    = 0.25;    !! In dollar per GJ seprod. Biotrmod is a mix of wood stoves and automated wood pellets for heating, which has lower air pollution and other discomfort effects
*' Transformation of coal to liquids/gases/H2 brings local pollution, which is less accepted at higher incomes -> use the inconvenience cost channel
p02_inconvpen_lap(ttot,regi,"coalftrec")$(ttot.val ge 2005)   = 0.1;    !! In dollar per GJ seprod
p02_inconvpen_lap(ttot,regi,"coalftcrec")$(ttot.val ge 2005)  = 0.1;    !!  equivalent to 4$/GJ at 40.000$_GDP/cap, or 10$/GJ at 100.000$_GDP/cap
p02_inconvpen_lap(ttot,regi,"coalgas")$(ttot.val ge 2005)   = 0.1;    !!
p02_inconvpen_lap(ttot,regi,"coalh2")$(ttot.val ge 2005)   = 0.1;    !!
p02_inconvpen_lap(ttot,regi,"coalh2c")$(ttot.val ge 2005)  = 0.1;    !!
p02_inconvpen_lap(ttot,regi,te)$(ttot.val ge 2005) = p02_inconvpen_lap(ttot,regi,te) * 4.3 * 1E-4;            !! this is now equivalent to 1$/GJ at 1000$/per Capita in the welfare logarithm
p02_inconvpen_lap(ttot,regi,te)$(ttot.val ge 2005) = p02_inconvpen_lap(ttot,regi,te) * (1/sm_giga_2_non) / sm_GJ_2_TWa; !! conversion util/(GJ/cap) -> util/(TWa/Gcap)
*RP* these values are all calculated on seprod level.
display p02_inconvpen_lap;
$ENDIF.INCONV

*BS* 2020-03-12: additional inputs for inequality
* To Do: rename file, then also in "files" and moinput::fullREMIND.R
parameter f_ineqTheil(tall,all_regi,all_GDPscen)        "Gini data"
/
$ondelim
$include "./modules/02_welfare/ineqLognormal/input/f_ineqTheil.cs4r"
$offdelim
/
;
p02_ineqTheil(ttot,regi)$(ttot.val ge 2005) = f_ineqTheil(ttot,regi,"%cm_GDPscen%");
display p02_ineqTheil;

* consumption path from base run
* Note: this currently only works for SSP2 due to the SSP2-NDC reference run!!
Execute_Loadpoint 'input_ref' p02_cons_ref = vm_cons.l;
* per capita consumption in reference run (1e3 $ MER 2005)
* p02_consPcap_ref(ttot,regi)$(ttot.val ge 2005) = p02_cons_ref(ttot,regi)/pm_pop(ttot,regi);
* display p02_consPcap_ref;

* parameters of initial lognormal distribution
* this is not required anymore
*p02_distrMu(ttot,regi)$(ttot.val ge 2005) = log(p02_cons_ref(ttot,regi)) - p02_ineqTheil(ttot,regi);
* display p02_distrMu;
* To Do: this is unused and only for checking, remove later
* p02_distrSigma(ttot,regi)$(ttot.val ge 2005) = sqrt(2*p02_ineqTheil(ttot,regi));
* display p02_distrSigma;

* income elasticity of mitigation costs. fixing this to some number for now
p02_distrAlpha(ttot,regi)$(ttot.val ge 2005) = 0.5;
display p02_distrAlpha;

* TN: income elasticity of tax revenues redistribution. fixing this to some number for now
p02_distrBeta(ttot,regi)$(ttot.val ge 2005) = 0;

*expectation value of y^alpha
* p02_distrEVyAlpha(t,regi) = exp(p02_distrAlpha(t,regi)*p02_distrMu(t,regi) + p02_distrAlpha(t,regi)**2 * p02_ineqTheil(t,regi));
* display p02_distrEVyAlpha;

* set start values for variables because they are not contained in the gdx
* trying to get correct order of magnitude here
* v02_consPcap.l(ttot,regi)$(ttot.val ge 2005) = 10;
v02_relConsLoss.l(ttot,regi)$(ttot.val ge 2005) = 0.01;
* v02_distrNormalization.l(ttot,regi)$(ttot.val ge 2005) = 0.01;
* v02_distrNew_mu.l(ttot,regi)$(ttot.val ge 2005) = 1;
* v02_distrNew_SecondMom.l(ttot,regi)$(ttot.val ge 2005) = 100;
v02_distrNew_sigmaSq.l(ttot,regi)$(ttot.val ge 2005) = 1;

* TN
v02_revShare.l(ttot,regi)$(ttot.val ge 2005) = 0.01;
v02_distrFinal_sigmaSq.l(ttot,regi)$(ttot.val ge 2005) = 1;


*** EOF ./modules/02_welfare/ineqLognormal/datainput.gms
