*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/33_CDR/portfolio/postsolve.gms

*** update bound on spending on net negative emissions 
v33_NetNegEmi_expenses.up(t,regi) = p33_GDP_NetNeg_share(regi) * pm_gdp_gdx(t,regi);

*** update bound on final energy for a sector
p33_FE_limit(t,regi,entyFE,sector)$p33_shfetot_up(t,regi,entyFe,sector) = p33_shfetot_up(t,regi,entyFE,sector) * sum(entyFe2FeType(entyFe2,entyFe), v33_FE_total.l(t,regi,entyFe2));
v33_FEsector_total.up(t,regi,entyFe,sector)$p33_shfetot_up(t,regi,entyFe,sector) = p33_FE_limit(t,regi,entyFE,sector);

*** EOF ./modules/33_CDR/portfolio/postsolve.gms
