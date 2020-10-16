*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/35_transport/complex/preloop.gms

*RP* set 2005 level value
vm_prodUe.l("2005",regi,"fepet","uepet","apCarPeT") = pm_cesdata("2005",regi,"ueLDVt","quantity");

*** EOF ./modules/35_transport/complex/preloop.gms
