*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/33_CDR/portfolio/preloop.gms

*** initialize bound on final energy for a sector
p33_FE_limit(t,regi,entyFe,sector)$p33_shfetot_up(t,regi,entyFe,sector) = 1000;

*** EOF ./modules/33_CDR/portfolio/preloop.gms