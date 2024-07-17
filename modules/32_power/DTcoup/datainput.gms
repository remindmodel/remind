*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/32_power/DTcoup/datainput.gms

*------------------------------------------------------------------------------------
***                        IntC specific data input
*------------------------------------------------------------------------------------

parameter f32_shCHP(ttot,all_regi)  "upper boundary of chp electricity generation"
/
$ondelim
$include "./modules/32_power/IntC/input/f32_shCHP.cs4r"
$offdelim
/
;
p32_shCHP(ttot,all_regi) = f32_shCHP(ttot,all_regi) + 0.05;
p32_shCHP(ttot,all_regi)$(ttot.val ge 2050) = min(p32_shCHP("2020",all_regi) + 0.15, 0.75);
p32_shCHP(ttot,all_regi)$((ttot.val gt 2020) and (ttot.val lt 2050)) = p32_shCHP("2020",all_regi) + ((p32_shCHP("2050",all_regi) - p32_shCHP("2020",all_regi)) / 30 * (ttot.val - 2020));

***parameter p32_grid_factor(all_regi) - multiplicative factor that scales total grid requirements down in comparatively small or homogeneous regions like Japan, Europe or India
parameter p32_grid_factor(all_regi)                "multiplicative factor that scales total grid requirements down in comparatively small or homogeneous regions like Japan, Europe or India"
/
$ondelim
$include "./modules/32_power/IntC/input/p32_grid_factor.cs4r"
$offdelim
/
;

***parameter p32_factorStorage(all_regi,all_te) - multiplicative factor that scales total curtailment and storage requirements up or down in different regions for different technologies (e.g. down for PV in regions where high solar radiation coincides with high electricity demand)
parameter f32_factorStorage(all_regi,all_te)                  "multiplicative factor that scales total curtailment and storage requirements up or down in different regions for different technologies (e.g. down for PV in regions where high solar radiation coincides with high electricity demand)"
/
$ondelim
$include "./modules/32_power/IntC/input/f32_factorStorage.cs4r"
$offdelim
/
;

*** windoffshore-todo
f32_factorStorage(all_regi,"windon") $ (f32_factorStorage(all_regi,"windon") eq 0) = f32_factorStorage(all_regi,"wind");
f32_factorStorage(all_regi,"windoff") = f32_factorStorage(all_regi,"windon");
f32_factorStorage(all_regi,"windon")  = 1.35 * f32_factorStorage(all_regi,"windon"); 

p32_factorStorage(all_regi,all_te) = f32_factorStorage(all_regi,all_te);

$if not "%cm_storageFactor%" == "off" p32_factorStorage(all_regi,all_te)=%cm_storageFactor%*p32_factorStorage(all_regi,all_te);

***parameter p32_storexp(all_regi,all_te) - exponent that determines how curtailment and storage requirements per kW increase with market share of wind and solar. 1 means specific marginal costs increase linearly
p32_storexp(regi,"spv")     = 1;
p32_storexp(regi,"csp")     = 1;
p32_storexp(regi,"windon")  = 1;
p32_storexp(regi,"windoff") = 1;


***parameter p32_gridexp(all_regi,all_te) - exponent that determines how grid requirement per kW increases with market share of wind and solar. 1 means specific marginal costs increase linearly
p32_gridexp(regi,"spv")     = 1;
p32_gridexp(regi,"csp")     = 1;
p32_gridexp(regi,"windon")  = 1;


table f32_storageCap(char, all_te)  "multiplicative factor between dummy seel<-->h2 technologies and storXXX technologies"
$include "./modules/32_power/IntC/input/f32_storageCap.prn"
;

p32_storageCap(te,char) = f32_storageCap(char,te);
display p32_storageCap;

$ontext
parameter p32_flex_maxdiscount(all_regi,all_te) "maximum electricity price discount for flexible technologies reached at high VRE shares"
/
$ondelim
$include "./modules/32_power/IntC/input/p32_flex_maxdiscount.cs4r"
$offdelim
/
; 
*** convert from USD2015/MWh to trUSD2005/TWa
p32_flex_maxdiscount(regi,te) = p32_flex_maxdiscount(regi,te) * sm_TWa_2_MWh * s_D2015_2_D2005 * 1e-12;
display p32_flex_maxdiscount;
$offtext

*** initialize p32_PriceDurSlope parameter
parameter f32_cm_PriceDurSlope_elh2(ext_regi) "slope of price duration curve for electrolysis [#]" / %cm_PriceDurSlope_elh2% /;
p32_PriceDurSlope(regi,"elh2") = f32_cm_PriceDurSlope_elh2("GLO");
loop(ext_regi$f32_cm_PriceDurSlope_elh2(ext_regi),
  loop(regi$regi_groupExt(ext_regi,regi),
    p32_PriceDurSlope(regi,"elh2") = f32_cm_PriceDurSlope_elh2(ext_regi);
  );
); 

*** EOF ./modules/32_power/DTcoup/datainput.gms
