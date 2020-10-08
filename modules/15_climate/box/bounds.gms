*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/15_climate/box/bounds.gms

*AL* initial values
v15_conc.lo(ta10,'CO2') = 0.01;
v15_conc.lo(ta10,'N2O') = 10;
v15_forcComp.lo(ta10,'TTL') = 0.001;

*** additional bounds: 2000-2004
v15_emi.fx('2000','CO2') = 1.55 + 6.91;
v15_emi.fx('2001','CO2') = 1.67 + 7.09;
v15_emi.fx('2002','CO2') = 1.79 + 7.27;
v15_emi.fx('2003','CO2') = 1.92 + 7.45;
v15_emi.fx('2004','CO2') = 2.04 + 7.63;
v15_emi.fx(ta10,'CH4')$(ORD(ta10) le 5) = 301.798931;
v15_emi.fx(ta10,'N2O')$(ORD(ta10) le 5) = 4.706396 + 0.3805;
v15_emi.fx(ta10,'SO2')$(ORD(ta10) le 5) = 57.39272 + 0.0;
v15_emi.fx(ta10,'BC')$(ORD(ta10) le 5) = 5.2286 + 0.0;
v15_emi.fx(ta10,'OC')$(ORD(ta10) le 5) = 13.6616 + 0.0;

*** additional initial value for Petschel-Held model
v15_conc.FX('2000','CH4')        = 1752.1909466911;
v15_conc.FX('2000','N2O')        =  317.0208379148;

*JeS* bounds are only there to limit the solution space
v15_emi.LO(ta10,'CO2') = -5;
v15_emi.L(ta10,'CO2')  = 10;
v15_emi.UP(ta10,'CO2') = 50;
v15_emi.LO(ta10,'CH4') = -10;
v15_emi.L(ta10,'CH4')  = 350;
v15_emi.UP(ta10,'CH4') = 3000;
v15_emi.LO(ta10,'N2O') = -5;
v15_emi.L(ta10,'N2O')  = 7;
v15_emi.UP(ta10,'N2O') = 50;
v15_emi.LO(ta10,'SO2') = 0;
v15_emi.L(ta10,'SO2')  = 70;
v15_emi.UP(ta10,'SO2') = 300;

*---------- Petschel-Held climate module (NEW implementation) ------------
 if (cm_emiscen=2,   v15_temp.up(ta10) = s15_gr_temp);
 if (cm_emiscen = 3, v15_conc.up(ta10,"cO2") = s15_gr_conc);
*GL* forcing constraint for all time 'not to exceed'
*JeS* s15_gr_forc_kyo_nte needed for iterative adaption of forcing target, leads to kink in CO2 emissions
 if (cm_emiscen=5,   v15_forcKyo.up(ta10)$(ord(ta10)>1) = s15_gr_forc_kyo_nte);
*GL* forcing constraint only from 2100 onwards 'overshoot scenario'
*Jes* s15_gr_forc_kyo is adapted between negishi-iterations, look in remindsolve.gms!
 if (cm_emiscen=8,   v15_forcKyo.up(ta10)$(ord(ta10)>100) = s15_gr_forc_kyo);


*** EOF ./modules/15_climate/box/bounds.gms
