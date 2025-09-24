*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/50_damages/COACCH/sets.gms

SETS
dam_adapt	"with or without SLR adaptation"
/
noadapt
adapt
/

dam_coef	"coefficients of the damage function"
/
a
b1
b2
/

dam_CI		"percentiles of the damage function uncertainty space"
/
med
low
high
p025
p05
p16
p25
p33
p5
p67
p75
p84
p95
p975
/
;

*** EOF ./modules/50_damages/COACCH/sets.gms
