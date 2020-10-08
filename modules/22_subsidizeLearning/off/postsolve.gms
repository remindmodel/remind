*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/22_subsidizeLearning/off/postsolve.gms

p22_infoCapcumGlob2050(teLearn) = sum(regi,vm_capCum.l("2050",regi,teLearn));
display p22_infoCapcumGlob2050;
*** EOF ./modules/22_subsidizeLearning/off/postsolve.gms
