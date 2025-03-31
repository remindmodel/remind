*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/02_welfare/utilitarian/datainput.gms

pm_welf(ttot)$(ttot.val ge 2005) = 1;
pm_welf("2060") = 0.9;

*RP* 2012-03-06: Inconvenience costs on seprod
$IFTHEN.INCONV %cm_INCONV_PENALTY% == "on"
p02_inconvpen_lap(ttot,regi,"coaltr")$(ttot.val ge 2005)      = sm_D2005_2_D2017 * 0;    !! In dollar per GJ seprod at 1.000$/cap GDP, or 10$/GJ at 10.000$_GDP/cap
p02_inconvpen_lap(ttot,regi,"coaltr")$( (ttot.val ge 2005) AND (ttot.val le 2025) ) = 0.33 * p02_inconvpen_lap("2050",regi,"coaltr");  !! phase-in to decrease jump from historic 2020 fesob|foss to model 2025 results
p02_inconvpen_lap("2030",regi,"coaltr") = 0.66 * p02_inconvpen_lap("2050",regi,"coaltr");  !! phase-in to decrease jump from historic 2020 fesob|foss to model 2025 results

p02_inconvpen_lap(ttot,regi,"biotr")$(ttot.val ge 2005)       = sm_D2005_2_D2017 * 1.0;   !! In dollar per GJ seprod
p02_inconvpen_lap(ttot,regi,"biotrmod")$(ttot.val ge 2005)    = sm_D2005_2_D2017 * 0;    !! In dollar per GJ seprod. Biotrmod is a mix of wood stoves and automated wood pellets for heating, which has lower air pollution and other discomfort effects
*' Transformation of coal to liquids/gases/H2 brings local pollution, which is less accepted at higher incomes -> use the inconvenience cost channel
p02_inconvpen_lap(ttot,regi,"coalftrec")$(ttot.val ge 2005)   = sm_D2005_2_D2017 * 0.9;    !! In dollar per GJ seprod
p02_inconvpen_lap(ttot,regi,"coalftcrec")$(ttot.val ge 2005)  = sm_D2005_2_D2017 * 0.9;    !!  equivalent to 4$/GJ at 40.000$_GDP/cap, or 10$/GJ at 100.000$_GDP/cap
p02_inconvpen_lap(ttot,regi,"coalgas")$(ttot.val ge 2005)     = sm_D2005_2_D2017 * 0.9;
p02_inconvpen_lap(ttot,regi,"coalh2")$(ttot.val ge 2005)      = sm_D2005_2_D2017 * 0.9;
p02_inconvpen_lap(ttot,regi,"coalh2c")$(ttot.val ge 2005)     = sm_D2005_2_D2017 * 0.9;
p02_inconvpen_lap(ttot,regi,te)$(ttot.val ge 2005) = p02_inconvpen_lap(ttot,regi,te) * 4.3 * 1E-4;            !! this is now equivalent to 1$/GJ at 1000$/per Capita in the welfare logarithm
p02_inconvpen_lap(ttot,regi,te)$(ttot.val ge 2005) = p02_inconvpen_lap(ttot,regi,te) * (1/sm_giga_2_non) / sm_GJ_2_TWa; !! conversion util/(GJ/cap) -> util/(TWa/Gcap)
*RP* these values are all calculated on seprod level.
display p02_inconvpen_lap;
$ENDIF.INCONV

*** EOF ./modules/02_welfare/utilitarian/datainput.gms
