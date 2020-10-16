*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/29_CES_parameters/load/preloop.gms

$ifthen "%optimization%" == "testOneRegi"
regi_dyn29(all_regi) = regi_dyn80(all_regi);
$else
regi_dyn29(all_regi) = regi(all_regi)
$endif
;
*** EOF ./modules/29_CES_parameters/load/preloop.gms
