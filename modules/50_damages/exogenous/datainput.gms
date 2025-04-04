*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/50_damages/exogenous/datainput.gms
***----------------------------
*** Damage factors
***----------------------------


$ifthen exist "./modules/50_damages/exogenous/input/p50_damage_exo.inc"
$include "./modules/50_damages/exogenous/input/p50_damage_exo.inc"
$endif

*** EOF ./modules/50_damages/exogenous/datainput.gms
