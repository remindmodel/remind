*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/29_CES_parameters/load/datainput.gms

*** Load CES parameters based on current model configuration
$include "./modules/29_CES_parameters/load/input/%cm_CES_configuration%.inc"

option pm_cesdata:8:3:1;
display "loaded pm_cesdata", pm_cesdata;

*** EOF ./modules/29_CES_parameters/load/datainput.gms
