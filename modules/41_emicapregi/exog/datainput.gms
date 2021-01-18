*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/41_emicapregi/exog/datainput.gms

*AJS* read exogenously given permit path 
p41_emicapregi(t,regi) = 0;

$offlisting
$include "./modules/41_emicapregi/exog/input/emicapregi.inc";
$onlisting

*mlb 20140109* just for allowing the climate externality (Nash) to be correctly initialized in module 80 
pm_shPerm(t,regi) = p41_emicapregi(t,regi)/sum(regi2, p41_emicapregi(t,regi2));
pm_emicapglob(t) = sum(regi, p41_emicapregi(t,regi));
*** EOF ./modules/41_emicapregi/exog/datainput.gms
