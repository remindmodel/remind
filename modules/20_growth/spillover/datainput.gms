*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/20_growth/spillover/datainput.gms

* -----------------------------------------------------------
* R&D function parameter values
* -----------------------------------------------------------
* based on huebler at al.(2012)

  p20_coef_EL("en")         = 2;
  p20_coef_EL("lab")        = 1;
  p20_coef_H(ttot, regi)       = 1;
  p20_coeffInno                 = 0.4;
  p20_coeffImi                = 0.12;
  p20_constRD               = 0.001;
* d_exp(ttot,regi,in)         = 1;
  p20_exponInno(ttot,regi,"lab")    = 0.1;
  p20_exponInno(ttot,regi,"en")     = 0.1;
  p20_exponImi(ttot,regi,"lab")    = 0.01;
  p20_exponImi(ttot,regi,"en")     = 0.01;

*Upper and lower bounds
*  invest.lo(ttot,regi,"kap")  = 0.000001;
*  invest.up(ttot,regi,"kap")  = 10000;
*  invest.l (ttot,regi,"kap")  = 1;
  vm_invInno.lo(ttot,regi,inRD20)  = 0.000001;
  vm_invInno.up(ttot,regi,inRD20)  = 10000;
  vm_invInno.l (ttot,regi,inRD20)  = 0.1;
  vm_invImi.lo(ttot,regi,inRD20) = 0.000001;
  vm_invImi.up(ttot,regi,inRD20) = 10000;
  vm_invImi.l (ttot,regi,inRD20) = 0.1;
  vm_cesIO.lo(ttot,regi,"kap")    = 0.000001;
  vm_cesIO.up(ttot,regi,"kap")    = 100000000;

*Education level adjustment based on average of secondary education school enrollment and internet users ratio
p20_coef_H("2005","EUR")    = 0.75;
p20_coef_H("2005","USA")    = 0.85;
p20_coef_H("2005","JPN")    = 0.8;
p20_coef_H("2005","ROW")    = 0.9;
p20_coef_H("2005","CHN")    = 0.75;
p20_coef_H("2005","RUS")    = 0.75;
p20_coef_H("2005","OAS")    = 0.45;
p20_coef_H("2005","IND")    = 0.4;
p20_coef_H("2005","AFR")    = 0.4;
p20_coef_H("2005","LAM")    = 0.45;
p20_coef_H("2005","MEA")    = 0.45;

p20_coef_H(ttot,regi) = ( p20_coef_H("2005",regi) * (2100 - ttot.val) / 95 + 1 * (ttot.val - 2005) / 95 )$(ttot.val < 2100)  + 1$(ttot.val ge 2100) ;


*** EOF ./modules/20_growth/spillover/datainput.gms
