*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/subsectors/presolve.gms



***p37_emiFac(ttot,regi,entyFe) = sum((entySe,te)$(se2fe(entySe,entyFe,te) and entySeFos(entySe)), pm_emifac(ttot,regi,entySe,entyFe,te,"co2"));

*** EOF ./modules/37_industry/subsectors/presolve.gms
